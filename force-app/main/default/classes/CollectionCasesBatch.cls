//****************************************************************************************
//Name          : CollectionCasesBatch
//Date          : 2.11.2016
//Created by    : Stanley Sequeira//
//Description   : This Batch Class processes Invoices and creates Collection Cases

//Modified by   : Venkataramana Cheedara - Added condition in line no: 83 to assign case (Leap-7836)               
// *****************************************************************************************

global class CollectionCasesBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query                                 =  'SELECT Id,Zuora__DueDate__c,Collection_Case_Created__c,Zuora__Account__c,Zuora__Account__r.Division__c,Zuora__Account__r.Billing_Preference__c,Zuora__Balance2__c,Zuora__Account__r.Name,Zuora__Account__r.Total_Contract_Value__c'; 
        query                                       += ' FROM Zuora__ZInvoice__c'; 
        query                                       += ' WHERE Zuora__Balance2__c > 0 AND Collection_Case_Created__c=false AND (Zuora__DueDate__c  < YESTERDAY OR Invoice_Status__c = \'Past Due\')';
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Zuora__ZInvoice__c> scope){
        system.debug('@@ CollectionCasesBatch - Execute : Start @@'+scope);
        
        
        Map<Id,Id> invoiceAccountMap                = new Map<Id,Id>();
        List<Case_Invoice_Relationship__c> cirList  = new List<Case_Invoice_Relationship__c>();
        Map<Id,Id> accountCaseMap                   = new Map<Id,Id>();
        List<Case> caseList                         = new List<Case>();
        Map<Id,Id> accountTeammemberMap             = new Map <Id,Id>();
        Map<Id,Id> invoiceCaseMap                   = new Map<Id,Id>();
        List<Id> invoiceIds                         = new List<Id>();
        Map<Id,Id> newCaseAccountMap                = new Map<Id,Id>();
        
    // Process 1: Collect all Invoices which match the criteria and update to Past Due Flag
        for(Zuora__ZInvoice__c loopvar : scope){
                loopvar.Invoice_Status__c           = 'Past Due'; 
                invoiceAccountMap.put(loopvar.Id,loopvar.Zuora__Account__c); 
                invoiceIds.add(loopvar.Id);    
         }
         
    
    // Process 2: Create a Collections Case on the Account which has no open Collections Case
         List<Case> openCollectionCases             = [SELECT Id, Status, SubStatus__c, AccountId
                                                            FROM Case 
                                                            WHERE Status != 'Closed' AND Type = 'Collections' AND Subject like '%Collections Case with Past Due Invoices%'
                                                            AND AccountId IN: invoiceAccountMap.values()
                                                            ]; 
                                                            
        for(Case cse: openCollectionCases){
        // This map contains the open Case and Account records  
            accountCaseMap.put(cse.AccountId,cse.Id);
        }                                                    
        
        system.debug('@@ accountCaseMap @@'+accountCaseMap);
        // Send List of Cases and Invoices                                                                    
        Map<Id,Id> createCIRMap                     = checkCIRrecords(accountCaseMap.values(),invoiceIds);
        
       // This loop should create CIRs which do not exist in the above map 
        for(Id loopvar:createCIRMap.keySet()){
            cirList.add(createCaseInvoiceRelationshipRecords(loopvar,createCIRMap.get(loopvar)));
        }           
        
                                                                            
        
        // Process 3: If a Collections Case is already present on the Account, then create a new CIR record and link the Invoice to the existing Case Record
         
        accountTeamMemberMap                            = fetchAccountTeamMembers(invoiceAccountMap.values());
                                                         
        for(Zuora__ZInvoice__c loopvar: scope){
                    
           // Collections Case is present, create just a CIR and link to the Case   
           // Collections Case is not present, create a new Case and create a New CIR
           if(!accountCaseMap.containsKey(loopvar.Zuora__Account__c)){
                Case cse                                = new Case();
                cse.Status                              = 'New';
                cse.SubStatus__c                        = '';
                cse.Origin                              = 'Web';
                cse.Subject                             = 'Collections Case with Past Due Invoices for the Account ' + loopvar.Zuora__Account__r.Name;
                cse.recordTypeId                        = CaseRecordTypes__c.getValues('Collection').Record_Type_Id__c;
                cse.Type                                = 'Collections';                
                cse.AccountId                           = loopvar.Zuora__Account__c;
                System.debug('Billing Prefrence coming over here is from label'+ label.Billingpreference);
                System.debug('Billing Prefrence coming over here is'+loopvar.Zuora__Account__r.Billing_Preference__c);
                if(loopvar.Zuora__Account__r.Total_Contract_Value__c > integer.valueOf(label.collectioncase_amount) && loopvar.Zuora__Account__r.Total_Contract_Value__c < integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(loopvar.Zuora__Account__r.Billing_Preference__c)){
                    cse.ownerid                         = label.userct1; //Eric
                }
               else if(loopvar.Zuora__Account__r.Total_Contract_Value__c > integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(loopvar.Zuora__Account__r.Billing_Preference__c)){
                    cse.ownerid                         = label.userct2; //Pam
               }
               else if(accountTeammemberMap.containsKey(loopvar.Zuora__Account__c)){//&& !label.Billingpreference.contains(loopvar.Zuora__Account__r.Billing_Preference__c)
                    cse.ownerid                         = accountTeamMemberMap.get(loopvar.Zuora__Account__c);
               }else{
                    cse.setOptions(fetchDMLOptions());
                }
                caseList.add(cse);
                
            }
        }
        
      // Case inserted here 
        try{
                system.debug('@@ caseList @@'+caseList);
                insert caseList;
        }
         catch(DMLException de){
            system.debug('@@ Exception @@'+de);
         }
        
        for(Case cse: caseList){
                newCaseAccountMap.put(cse.AccountId,cse.Id);
        }
        
        for(Zuora__ZInvoice__c loopvar: scope){
          // This will create CIR records for the newly created Cases as it doesn't exist   
            if(newCaseAccountMap.containsKey(loopvar.Zuora__Account__c)){
                cirList.add(createCaseInvoiceRelationshipRecords((loopvar.Id),newCaseAccountMap.get(loopvar.Zuora__Account__c)));
            }
            loopvar.Collection_Case_Created__c=true;
            
         }
        
        // CIR inserted here 
         try{
            system.debug('@@ cirList @@'+cirList);
            insert cirList;
            update scope;
         }
         catch(DMLException de){
            system.debug('@@ Exception @@'+de);
         }
         
         
        
        system.debug('@@ CollectionCasesBatch - Execute : End @@');
    }
    
    global void finish(Database.BatchableContext bc){}
    
    
// Method to check whether the Collections Rep is on Vacation or not    
    private Boolean isRepOnVacation(Date startDate , Date endDate){
        
        if (startDate == null || endDate == null)
            return false;
        
        if(system.today()<startDate && system.today()<endDate)
            return false;
        
        if(system.today()>startDate && system.today()<endDate)
            return true;
        
        if (system.today()>endDate && system.today()>startDate)
            return false;
        
        else return false;
        
     }
     
     public Map<Id,Id> fetchAccountTeamMembers(List<Id> accountIds){
         
         Map<Id,Id> accountTeamMemberMap                        = new Map<Id,Id>();
         List<AccountTeamMember> accountTeamList                = [SELECT TeamMemberRole, User.Vacation_Start_Date__c, User.Vacation_End_Date__c,AccountId 
                                                                        FROM AccountTeamMember 
                                                                        WHERE TeamMemberRole = 'Collections Rep' AND AccountId IN: accountIds
                                                                    ];
        
       
        for (AccountTeamMember rep : accountTeamList){
            // Add the account and Rep to the map only if the rep is not on vacation
            if(!isRepOnVacation(rep.User.Vacation_Start_Date__c, rep.User.Vacation_End_Date__c)){
                if(accountTeammemberMap.containsKey(rep.AccountId) == false){
                    accountTeamMemberMap.put(rep.AccountId, rep.UserId);
                }
            }
        } 
        
        return accountTeamMemberMap;
     }
     
     public Database.DMLOptions fetchDMLOptions(){
          //Fetching the assignment rules on case
        List<AssignmentRule> assignmentRule                     = new List<AssignmentRule>();
        assignmentRule                                           = [SELECT Id 
                                                                        FROM AssignmentRule 
                                                                        WHERE SobjectType = 'Case' AND Active = true 
                                                                        limit 1
                                                                    ];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts                             = new Database.DMLOptions();
        if(assignmentRule.size()>0){
            dmlOpts.assignmentRuleHeader.assignmentRuleId       = assignmentRule[0].id;
            return dmlOpts;
        }
        else
            return null;
     } 
     
     private Case_Invoice_Relationship__c createCaseInvoiceRelationshipRecords(Id invoiceId, Id caseId){
            system.debug('@@ createCaseInvoiceRelationshipRecords - Start @@');
            
            Case_Invoice_Relationship__c cir            = new Case_Invoice_Relationship__c();
            cir.Case__c                                 = caseId;
            cir.Invoice__c                              = invoiceId;
            
            system.debug('@@ createCaseInvoiceRelationshipRecords - End @@'+cir);
            return cir;   
                
     }
     
     private Map<Id,Id> checkCIRrecords(List<Id> caseId, List<Id> invoiceId){
        system.debug('@@ checkCIRrecords - Start @@');
        
        Map<Id,Id> invoiceCaseMap                       = new Map<Id,Id>();
        Map<Id,Id> createCIRMap                         = new Map<Id,Id>();
        List<Case_Invoice_Relationship__c> cirList      = [SELECT Id,Case__c,Invoice__c
                                                            FROM Case_Invoice_Relationship__c 
                                                            WHERE Case__c IN:caseId and Invoice__c IN: invoiceId 
                                                            ];
                                                            
            
     // This checks whether a CIR already exists    
        for(Case_Invoice_Relationship__c loopvar: cirList){
            invoiceCaseMap.put(loopvar.Invoice__c,loopvar.Case__c);
        }
        
        for(Id inv: invoiceId){
            for(Id cse: caseId){
              // If contains key, then a record exists;     
                if(!invoiceCaseMap.containsKey(inv)){
                    createCIRMap.put(inv,cse);
                }
            }
        }
        
     // This sends the Invoice / Case for which a CIR record does not exist; hence will trigger creation of a new CIR record    
        system.debug('@@ createCIRMap @@'+createCIRMap);
        system.debug('@@ checkCIRrecords - End @@');
        return createCIRMap;                                                    
        
     }

}