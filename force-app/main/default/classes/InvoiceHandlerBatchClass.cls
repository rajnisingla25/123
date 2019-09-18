//****************************************************************************************
//Name          : InvoiceHandlerBatchClass
//Date          : 
//Created by    : 
//Modified by   : 02-04-2016 Stanley Sequeira
//Description   : This Batch Class processes Invoices and creates Collection Cases
//               
// *****************************************************************************************

global class InvoiceHandlerBatchClass implements Database.Batchable<sObject>{
    
    global List<sObject> listAllInvoices        = new List<sObject>();
    Boolean  isFromTrigger                      = false ;
    
    global InvoiceHandlerBatchClass(List<sObject> allInvoices, Boolean fromTrigger){
        
        isFromTrigger                           = fromTrigger ;
        listAllInvoices                         = allInvoices;
        
    }
     global InvoiceHandlerBatchClass(){}
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT Id,Zuora__DueDate__c,Zuora__Status__c,Zuora__Account__c,Zuora__Balance2__c,Collection_Case_Created__c,Zuora__Account__r.Name FROM Zuora__ZInvoice__c WHERE Collection_Case_Created__c = false AND Zuora__Balance2__c > 0 AND Zuora__Status__c!=\'Cancelled\' AND Zuora__DueDate__c  < YESTERDAY';
        
        //  Return the List of Invoices from Query. Else Return the query String if its being called from Cronjob . 
        if(isFromTrigger){
            return (DataBase.getQueryLocator(   [   SELECT Id,Zuora__Account__c,Zuora__Status__c  
                                                    FROM Zuora__ZInvoice__c 
                                                    WHERE Id IN :listAllInvoices 
                                                 ]
                                             ));
        }
        else{
            return Database.getQueryLocator(query);
        }
    }
    
    global void Execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<Zuora__ZInvoice__c> InvoicesList               =  scope ;
        Set<Id> sInvoiceIds                                 = new Set<Id>();
        Set<Id> accountids                                  = new Set<Id>();
        Map<Id,Id> accountTeammemberMap                     = new Map <Id,Id>();
        Map<Id,Id> pastDueinvoiceAccountMap                 = new Map <Id,Id>();
        List<Case_Invoice_Relationship__c> CIRList          = new List <Case_Invoice_Relationship__c>();
        List<Zuora__ZInvoice__c> lstInvoiceUpdate           = new List<Zuora__ZInvoice__c>();
        List<Case> CaseList                                 = new List<Case>();
        List<Case_Invoice_Relationship__c> newCIRRecordsList= new List < Case_Invoice_Relationship__c > ();
        Map<Id,Zuora__ZInvoice__c> InvoicesMap              = new Map<Id,Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c objInvoice;
        
        system.debug('@@ Invoices Received @@' + InvoicesList);
        
     // Get all the invoice and account Id's
        for (Zuora__ZInvoice__c z: invoicesList) {
            sInvoiceIds.add(z.id);
            accountids.add(z.Zuora__Account__c);
            z.Collection_Case_Created__c    = true;
            InvoicesMap.put(z.Id,z);
        }
        
        Map<Id,Zuora__ZInvoice__c> mapZuoraInvoice          = new Map<Id,Zuora__ZInvoice__c>();
        Set<Id> setInvoiceIds                               = new Set<Id>();
        
        // Filter past due invoices and collect them                                   
        for (Zuora__ZInvoice__c Zinvoice: InvoicesList){
            
            if (Zinvoice.Zuora__Balance2__c > 0) {                  
                objInvoice                                  = new Zuora__ZInvoice__c(id=Zinvoice.id);
                objInvoice.Invoice_Status__c                = 'Past Due';           
                lstInvoiceUpdate.add(objInvoice);  
                pastDueinvoiceAccountMap.put(Zinvoice.Zuora__Account__c, Zinvoice.id);
                mapZuoraInvoice.put(Zinvoice.id, Zinvoice); 
                
            }                  
        }
        
        // Update invoices that are past due (Status = Past Due)
        if(!lstInvoiceUpdate.isEmpty()){
            try{
                update lstInvoiceUpdate; 
            }catch (Exception e){
                system.debug('@@ Invoice update failed with the error @@' + e.getMessage());
            }
        }
        
        
        Map<Id,Case_Invoice_Relationship__c> mapInvoiceRelationship     = new  Map<Id,Case_Invoice_Relationship__c>();
        
        for(Case_Invoice_Relationship__c crr:                           [SELECT id,Invoice__c 
                                                                            FROM Case_Invoice_Relationship__c 
                                                                            WHERE Invoice__c=:mapZuoraInvoice.keyset()
                                                                        ]){
                                                                        
                     mapInvoiceRelationship.put(crr.Invoice__c,crr);
        }
        
        // For insert not AccountId IN: accountids 
        // Get the cases on the invoice is present already.
        List<Case> openCollectionCases                                  = [SELECT id, Status, SubStatus__c, AccountId 
                                                                            FROM Case 
                                                                            WHERE Status != 'Closed' AND Type = 'Collections' AND Subject like '%Collections Case with Past Due Invoices%'
                                                                            AND AccountId IN: pastDueinvoiceAccountMap.keySet()
                                                                            ]; 
        
        system.debug('@@ Past Due account Invoice Map @@'+ pastDueinvoiceAccountMap);
        system.debug('@@ Open Collection Cases @@'+ openCollectionCases);
        
        Set<Id> sAccID                          = new Set<Id>();
        Map<Id,Id> noCaseinvoiceAccountMap      = pastDueinvoiceAccountMap; // Copy the invoice account Map
        Account objAcc;
        
        Map<Id,Id> mapCollectionAccCase         = new Map<Id,Id>(); 
        
        for (Case cs: openCollectionCases) { 
            if(sAccID.contains(cs.AccountId) == false){
                sAccID.add(cs.AccountId);
                mapCollectionAccCase.Put(cs.AccountId, cs.id);
                
                // create CIR record  if the case account is in the map 
                if(pastDueinvoiceAccountMap.containskey(cs.AccountId)){
                    // remove the invoices/account KV pair which have cases already
                    mapZuoraInvoice.remove(pastDueinvoiceAccountMap.get(cs.AccountId)); 
    
                    Case_Invoice_Relationship__c cir        = new Case_Invoice_Relationship__c();
                    cir.Case__c                             = cs.id;
                    cir.Invoice__c                          = pastDueinvoiceAccountMap.get(cs.AccountId);
                    cir.Past_Due_Amount__c                  = InvoicesMap.get(pastDueinvoiceAccountMap.get(cs.AccountId)).Zuora__Balance2__c;
                    cir.Days_Past__c                         = InvoicesMap.get(pastDueinvoiceAccountMap.get(cs.AccountId)).Zuora__DueDate__c.daysBetween(System.Today());
                 //   system.debug('@@ cir.Past_Due_Amount__c @@'+cir.Past_Due_Amount__c); 
                 //   system.debug('@@ cir.Days_Past__c @@'+cir.Days_Past__c); 
                    CIRList.add(cir); 
                 }else {
                    // removing the key if there is an open collections case. For these invoices new cases+CIR have to be created 
                    noCaseinvoiceAccountMap.remove(cs.AccountId);
                 }
             }
         }

        system.debug('@@ TRACE  New CIR List @@'+ CIRList);
        system.debug('@@ TRACE Invoices with no case on them: @@'+noCaseinvoiceAccountMap);
        system.debug('@@ TRACE Zuora Account Invoice MAp: @@'+ mapZuoraInvoice);

        
        // if the collection case is open on the account, the account past_due__c field is already true
        // accountids - sAccID = the accounts that does not have open collections case and they need to be made past due field = true
        
        // flagging the accounts as past due if there is no open collections case open on them but a past due invoice 
        List<Account> lstAccpuntPastDue                     = [SELECT Id 
                                                                FROM Account 
                                                                WHERE id in: noCaseinvoiceAccountMap.keySet()
                                                              ];
        for(Account acc: lstAccpuntPastDue){
            acc.Past_Due__c             = true;
        }
        
        if(!lstAccpuntPastDue.isEmpty()){
            try{
                update lstAccpuntPastDue;
            }catch (Exception e){
                system.debug('@@ TRACE : Account update failed with the error: @@' + e.getMessage());
            }
        }
        
        
        
        // Query Collection Reps assigned to the Accounts on which new cases have to be created
        List<AccountTeamMember> CollectionRepsOnTheAccount = [SELECT TeamMemberRole, User.Vacation_Start_Date__c, User.Vacation_End_Date__c,AccountId 
                                                              FROM AccountTeamMember 
                                                              WHERE TeamMemberRole = 'Collections Rep' AND AccountId IN: noCaseinvoiceAccountMap.keySet()];
        
        system.debug('@@ CollectionRepsOnTheAccount @@' + CollectionRepsOnTheAccount.size());
        
        // Map Accounts and Reps
        for (AccountTeamMember rep : CollectionRepsOnTheAccount){
            // Add the account and Rep to the map only if the rep is not on vacation
            if(!isRepOnVacation(rep.User.Vacation_Start_Date__c, rep.User.Vacation_End_Date__c)){
                if(accountTeammemberMap.containsKey(rep.AccountId) == false){
                    accountTeammemberMap.put(rep.AccountId, rep.UserId);
                }
            }
        } 
        
        // case insertion via Apex will not run assignment rules by default. So setting DMLOptions on Database.
        //Fetching the assignment rules on case
        AssignmentRule AR                               = new AssignmentRule();
        AR                                              = [SELECT Id 
                                                            FROM AssignmentRule 
                                                            WHERE SobjectType = 'Case' AND Active = true 
                                                            limit 1
                                                           ];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts                         = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId       = AR.id; 
        
        // IF No Open collections case on Account . So creating new cases
        system.debug('@@ TRACE Zuora Account Invoice Map @@'+ mapZuoraInvoice);
        Map<Id,Integer> mapZouraCase                        = new Map<Id,Integer>();
        Map<Integer,Id> mapZouraCaseM                       = new Map<Integer,Id>();
        Integer ii                                          = 0;
        
        Set<Id> sAccountIdNew                               = new Set<Id>();
        for (Zuora__ZInvoice__c z: mapZuoraInvoice.values()) {
            
            // Will create case and assign invoices to it. So even if the update of invoices fail,The case will be created and will have 
            //invoices associated to it.  Admins can look into the issue later. Created cases so the reps can start collection process
             if(sAccountIdNew.contains(z.Zuora__Account__c) == false && mapCollectionAccCase.containskey(z.Zuora__Account__c) == false){
                sAccountIdNew.add(z.Zuora__Account__c);
                mapZouraCase.put(z.id,ii);
                
                Case cs                     = new Case();
                cs.Status                   = 'New';
                cs.SubStatus__c             = '';
                cs.Origin                   = 'Web';
                cs.Subject                  = 'Collections Case with Past Due Invoices for the Account ' + z.Zuora__Account__r.Name;
                cs.recordTypeId             = CaseRecordTypes__c.getValues('Collection').Record_Type_Id__c;
                cs.Type                     = 'Collections';                
                cs.Accountid                = z.Zuora__Account__c;
                
                if(accountTeammemberMap.containsKey(z.Zuora__Account__c)){
                    cs.ownerid = accountTeammemberMap.get(z.Zuora__Account__c);
                }else{
                    cs.setOptions(dmlOpts);
                }
                ii++;
                CaseList.add(cs); // new cases that need to be inserted
                
            }
        }
        
        system.debug('@@ TRACE New cases Inserted @@' + CaseList);
        
        
        // Try to insert the cases and catch the exception if it fails
        if(CaseList.size()>0){
            try{
                insert CaseList;
            }catch (Exception e){                        
                system.debug('@@ TRACE : Cases creation failed with the error @@' + e.getMessage());
            }  
        }
        
        for (Zuora__ZInvoice__c Z: mapZuoraInvoice.values()) {
            if(!mapInvoiceRelationship.containskey(Z.id)){
                if(mapZouraCase.containskey(Z.id) && mapCollectionAccCase.containskey(z.Zuora__Account__c) == false){                
                    
                    Case_Invoice_Relationship__c cir            = new Case_Invoice_Relationship__c();
                    cir.Case__c                                 = CaseList[mapZouraCase.get(Z.id)].id;
                    cir.Invoice__c                              = Z.id;
                    cir.Past_Due_Amount__c                      = Z.Zuora__Balance2__c;
                    system.debug('@@ z.Zuora__DueDate__c @@'+z.Zuora__DueDate__c);
                    cir.Days_Past__c                            = z.Zuora__DueDate__c.daysBetween(System.Today()); 
                    newCIRRecordsList.add(cir);
                }
                if(mapCollectionAccCase.containskey(z.Zuora__Account__c)){              
                   
                    Case_Invoice_Relationship__c cir            = new Case_Invoice_Relationship__c();
                    cir.Case__c                                 = mapCollectionAccCase.get(z.Zuora__Account__c);
                    cir.Invoice__c                              = Z.id;
                    cir.Past_Due_Amount__c                      = Z.Zuora__Balance2__c;
                    system.debug('@@ z.Zuora__DueDate__c @@'+z.Zuora__DueDate__c);
                    cir.Days_Past__c                            = z.Zuora__DueDate__c.daysBetween(System.Today());
                    newCIRRecordsList.add(cir);
                  
                }
            }      
        }     
        
        
        system.debug('@@ TRACE CIRList @@'+ CIRList);
        system.debug('@@ TRACE : New CIR records @@'+newCIRRecordsList);
        
        // Add the new CIR records to the ones for the existing CIR records
        CIRList.addAll(newCIRRecordsList);
        
        system.debug('@@ CIRList After Add All@@'+CIRList);
        
        // Inserting the CIR for the cases which are existing sizeOf(invoiceAccountMap - openCollectionCases )
        if (CIRList.size() > 0){
            try{
                insert CIRList;
            }catch (Exception e){
                system.debug('@@TRACE : CIR  update failed with the error: @@' + e.getMessage());
            }
            CIRList.clear();
        }
        
        update InvoicesList;
        system.debug('@@ Invoices Updated @@'+InvoicesList);
       
    }
    
    global void finish(Database.BatchableContext bc){}
    
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

}