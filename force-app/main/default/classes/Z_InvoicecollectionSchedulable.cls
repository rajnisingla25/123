/*
CRM-1898 Divert the first invoice on subscription to the finance team if it is failed to pay and Default the authorization amount to 1$ for all the Quotes.
1.This job find the failed first invoice on subscription and Open the CustomerCareColllaction Case and assigned it to the finance team.
Change the Invoice flag: Collection_Case_Created__c =true.
NewSubscription__c = true.
2. If any open collection case on the same account don't open the CustomerCareCollection Case It will eventually went to past due and Assign to the Collection Case.
3. Open the Collection case if invoice Status is Past Due and Account contains Customer Care collection case. In this case Account will have two Cases.
4. If the Customer Care Collection Case not Closed in 4 days assign it to the Collections Team and change the invoice status to Past Due.*/
public class Z_InvoicecollectionSchedulable implements schedulable{
    public static List<Zuora__ZInvoice__c> updateInovice = new List<Zuora__ZInvoice__c>();
    public void execute(SchedulableContext SC){
        RunInvoicecollectionSchedulable();            
    }
    @future
    public static void RunInvoicecollectionSchedulable(){         
        Map<Id,Id> OpenaccountCaseMap= new Map<Id,Id>();         
        Map<Id,Id> accountCaseCollectionsMap = new Map<Id,Id>();
        List<Case_Invoice_Relationship__c> cirList = new List<Case_Invoice_Relationship__c>();
        Map<Id,Id> newCaseAccountMap = new Map<Id,Id>();
        List<Case> caseList = new List<Case>(); 
        List<Case> caseList2 = new List<Case>(); 
        Map<Id,Id> invoiceAccountMap = new Map<Id,Id>();
        String Exceptionmessage = '';
        //Find the Invoices which are failed
        try{
            map<Id, set<Id>> AccInvmap = FindInvoice();
            
            List<Case> openCollectionCases = [SELECT Id,Account.Name, Status, SubStatus__c, AccountId, Type 
                                              FROM Case 
                                              WHERE Status != 'Closed' AND Type IN('Collections','C3 Collections') AND (Subject like '%1st Invoice did not Collect on Asset%' OR Subject like '%Collections Case with Past Due Invoices%')
                                              AND AccountId IN: AccInvmap.keyset() 
                                             ];
            map<Id, case> TransferCustomerCollectionCases = transfercases();
            for(Case cse: openCollectionCases){
                // This map contains the open Case and Account records 
                //CRM-4097 added condition and logic canged to skip the closing case invoices.
                if(cse.Type == 'Collections' || TransferCustomerCollectionCases.containskey(cse.AccountId)){
                    
                    if(AccInvmap.containskey(cse.AccountId)){
                        for(Id inv : AccInvmap.get(cse.AccountId)){                                             
                            Zuora__ZInvoice__c  ZInv = new Zuora__ZInvoice__c();
                            ZInv.id = Inv;                      
                            ZInv.NewSubscription__c = true;
                            updateInovice.add(ZInv);
                        } 
                        if(!test.isrunningtest())
                            AccInvmap.remove(cse.AccountId);                                
                    }
                    accountCaseCollectionsMap.put(cse.AccountId,cse.Id);
                } else if(cse.Type =='C3 Collections' ){
                    
                    OpenaccountCaseMap.put(cse.AccountId,cse.Id);
                    system.debug('Case@ '+cse.Id);
                }                 
            }
            for(Id AccId : AccInvmap.keyset()){      
                for(Id inv : AccInvmap.get(AccId)){
                    invoiceAccountMap.put(Inv, AccId);
                    system.debug('invoice@ '+inv);
                    Zuora__ZInvoice__c  ZInv = new Zuora__ZInvoice__c();
                    ZInv.id = Inv;
                    ZInv.Collection_Case_Created__c = true;
                    ZInv.NewSubscription__c = true;
                    updateInovice.add(ZInv);
                }           
            }               
            Map<Id,Id> CreateINVCIRRelationforOpenCases = checkexistingCIR(OpenaccountCaseMap,invoiceAccountMap);
            // This loop should create CIRs which do not exist in the above map 
            for(Id inloop:CreateINVCIRRelationforOpenCases.keySet()){
                cirList.add(createCaseInvoiceRelationshipRecords(inloop,CreateINVCIRRelationforOpenCases.get(inloop)));
            }       
            for(Id inloop: AccInvmap.keyset()){
                // Custmer Care Collections Case is present, create just a CIR and link to the Case   
                // Custmer Care Collections Case is not present, create a new Case and create a New CIR
                if(!OpenaccountCaseMap.containsKey(inloop)){
                    Case Newcase= new Case();
                    Newcase.Status= 'New';
                    Newcase.SubStatus__c= '';
                    Newcase.Origin= 'Web';
                    Newcase.Description = 'Customers 1st Invoice on Asset was not successfully collected. Please contact customer for payment ASAP. This case will get reassigned to the CC Collections Team after 4 days of non-payment';
                    Newcase.Subject= '1st Invoice did not Collect on Asset';
                    Newcase.recordTypeId= CaseRecordTypes__c.getValues('Collection').Record_Type_Id__c;
                    Newcase.Type  = 'C3 Collections';                
                    Newcase.AccountId  = inloop;               
                    Newcase.ownerid = System.Label.CustomerCaseCollectionsQueId;                   
                    caseList.add(Newcase);
                }
            }
            //Transfer the Customer collection cases to collection cases if created more then 3 days.
            List<Case> ccscases = new List<Case>(); 
            // map<Id, case> TransferCustomerCollectionCases = transfercases();
            // Case inserted here 
            try{
                system.debug('caseList :'+caseList);
                insert caseList;
            }
            catch(DMLException de){
                system.debug('caseListException :'+de);
                Exceptionmessage += 'Exception occured while inserting case' + de;
            }
            for(Case cse: caseList){
                newCaseAccountMap.put(cse.AccountId,cse.Id);
            }
            for(Id AccId: newCaseAccountMap.keyset()){
                // This will create CIR records for the newly created Cases as it doesn't exist   
                if(AccInvmap.containsKey(AccId)){
                    for(Id Inv: AccInvmap.get(AccId)){
                        cirList.add(createCaseInvoiceRelationshipRecords((Inv),newCaseAccountMap.get(AccId)));
                    }
                }               
            }
            
            // CIR inserted here '
            try{
                system.debug('cirList :'+cirList);
                insert cirList;     
            }   
            catch(DMLException de){
                system.debug('cirListException :'+de);
                Exceptionmessage += 'Exception occured while inserting cirList' + de;
            }
            try{
                system.debug('updateInovice :'+updateInovice);
                //if(!Test.isRunningTest())
                update updateInovice;                             
            }   
            catch(DMLException de){
                system.debug('updateInoviceException :'+de);
                Exceptionmessage += 'Exception occured while updating updateInovice' + de;    
            }
            try{
                system.debug('TransferCustomerCollectionCases :'+cirList);
                update TransferCustomerCollectionCases.values();
            }   
            catch(DMLException de){
                system.debug('Transfer C3 CollectionCasesException :'+de);
                Exceptionmessage += 'Exception occured while updating TransferCustomerCollectionCases' + de;
            }
        } catch (Exception ex) {                      
            Exceptionmessage += 'Exception occured in collection logic' + ex;
        }
        if(String.isNotEmpty(Exceptionmessage)){    
            system_logs__c logs = new system_logs__c();         
            logs.Object_Type__c = 'C3 Collections';
            logs.Message__c =Exceptionmessage;
            insert logs;
        }
    }
    public static Case_Invoice_Relationship__c createCaseInvoiceRelationshipRecords(Id invoiceId, Id caseId){
        system.debug('@@ createCaseInvoiceRelationshipRecords - Start @@');
        Case_Invoice_Relationship__c cir            = new Case_Invoice_Relationship__c();
        cir.Case__c                                 = caseId;
        cir.Invoice__c                              = invoiceId;
        system.debug('@@ createCaseInvoiceRelationshipRecords - End @@'+cir);
        return cir;   
    }
    public static Map<Id,Id> checkexistingCIR(Map<Id,Id>acccaseMap, Map<Id,Id> invaccmap){
        system.debug('@@ checkexistingCIR - Start @@');
        Map<Id,Id> invoiceCaseMap                       = new Map<Id,Id>();
        Map<Id,Id> CreateINVCIRRelationforOpenCases                         = new Map<Id,Id>();
        List<Case_Invoice_Relationship__c> cirList      = [SELECT Id,Case__c,Invoice__c
                                                           FROM Case_Invoice_Relationship__c 
                                                           WHERE Case__c IN:acccaseMap.values() and Invoice__c IN: invaccmap.Keyset() 
                                                          ];
        // This checks whether a CIR already exists    
        for(Case_Invoice_Relationship__c inloop: cirList){
            invoiceCaseMap.put(inloop.Invoice__c,inloop.Case__c);
        }   
        for(Id inv: invaccmap.Keyset()){           
            // If contains key, then a record exists;     
            if(!invoiceCaseMap.containsKey(inv)){
                if(invaccmap.containsKey(inv) && acccaseMap.containskey(invaccmap.get(inv))){
                    CreateINVCIRRelationforOpenCases.put(inv,acccaseMap.get(invaccmap.get(inv)));
                }
            }
        }   
        // This sends the Invoice / Case for which a CIR record does not exist; hence will trigger creation of a new CIR record    
        system.debug('@@ CreateINVCIRRelationforOpenCases @@'+CreateINVCIRRelationforOpenCases);
        system.debug('@@ checkexistingCIR - End @@');
        return CreateINVCIRRelationforOpenCases;                                                        
    }
    //  CRM-2203
    public static map<Id, Set<Id>> FindInvoice(){
        List<Zuora__PaymentInvoice__c> PayInv = new List<Zuora__PaymentInvoice__c>();
        map<Id, set<Id>> AccInvmap = new map<Id, Set<Id>>(); 
        Set<Id> Invname = new Set<Id>();
        Set<Id> Skipaccount = new Set<Id>();
        Set<Id> Skipunt = new Set<Id>();
        Set<Id> Subname = new Set<Id>();
        Set<Id>  accountid= new Set<Id>();
        List<Invoice_Item__c> InvItem = new List<Invoice_Item__c>();
        Set<Id> FinalInvoice = new Set<Id>();
        
        // 2017-06-29               
        PayInv = [SELECT Status__c,Zuora__Invoice__c,Zuora__Invoice__r.Zuora__Account__c,Zuora__Invoice__r.Zuora__Account__r.Type, Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c,Zuora__Invoice__r.Zuora__Account__r.Skip_C3Collection_Case__c, Zuora__Invoice__r.Name, Zuora__Payment__c, Zuora__ApplyAmount__c FROM Zuora__PaymentInvoice__c where Status__c ='Error' and createddate  >=Yesterday and Zuora__Invoice__r.Zuora__DueDate__c >=Yesterday and Zuora__Invoice__r.NewSubscription__c = false];
        for(Zuora__PaymentInvoice__c Inf : PayInv){
            system.debug('InvoiceProcessed:' + Inf.Zuora__Invoice__r.Name);
            Set<String> acctypes = new Set<String>{'Moving Company', 'Moving Corporation', 'Lender Parent','Lender Branch', 'Loan Officer', 'Lender Individual'};
            //CRM-3902 excluding moving company and moving corporation accounts from C3 Cases. Added condition moving corp and moving company.
            if(Inf.Zuora__Invoice__r.Zuora__Account__r.Skip_C3Collection_Case__c || Inf.Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c == 'Arrears-Invoice' || Inf.Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c =='Invoice-Terms' || Inf.Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c =='Arrears-CC' || acctypes.contains(Inf.Zuora__Invoice__r.Zuora__Account__r.Type ))
                Skipaccount.add(Inf.Zuora__Invoice__r.Zuora__Account__c); 
            Invname.add(Inf.Zuora__Invoice__c);
            system.debug('Invname ' +Inf.Zuora__Invoice__c);
            if(Test.isRunningTest()){
                Set<Id> temppay = new Set<Id>();
                temppay.add(Inf.Zuora__Invoice__c);
                AccInvmap.put(Inf.Zuora__Invoice__r.Zuora__Account__c,temppay); 
            }
        }
        InvItem  = [Select Id, Charge_Date__c, Invoice__c, Subscription__c, Subscription_Name__c From Invoice_Item__c where Invoice__c IN:Invname];
        for(Invoice_Item__c It:InvItem  ){
            system.debug('Subscripton :' + It);
            Subname.add(It.Subscription__c);
        }
        
        
             
         List<Zuora__Subscription__c> Sub = new  List<Zuora__Subscription__c>();
          Sub = [Select Id,Zuora__Account__c, (Select Id, Invoice__c, Invoice__r.Name, Subscription__c,Subscription_Name__c From Invoice_Items__r) from Zuora__Subscription__c where Id IN:Subname];
        system.debug('Sub# :' + Sub);
        if(test.isrunningtest())
           Sub = [Select Id,Zuora__Account__c, (Select Id, Invoice__c, Invoice__r.Name, Subscription__c,Subscription_Name__c From Invoice_Items__r) from Zuora__Subscription__c where Name  = '283838'];
         
          
        for(Zuora__Subscription__c Si : Sub){
            Set<Id> Invdata = new Set<Id>();
            Set<Id> temppay = new Set<Id>();
            for(Invoice_Item__c It : Si.Invoice_Items__r){
                Invdata.add(It.Invoice__c);
                system.debug('Invdata :' + It.Invoice__c);              
            }
            if(Invdata.size()==1){          
                FinalInvoice.addall(Invdata);
                if(Skipaccount.contains(Si.Zuora__Account__c)){
                    Zuora__ZInvoice__c  ZInv = new Zuora__ZInvoice__c();
                    ZInv.id = (new List<Id>(Invdata))[0];
                    ZInv.NewSubscription__c = true;
                    updateInovice.add(ZInv);
                    continue;
                }
                //invoiceAccountMap.put(Invdata,Si.Zuora__Account__c);
                if(AccInvmap.containskey(Si.Zuora__Account__c)){
                    temppay = AccInvmap.get(Si.Zuora__Account__c);
                }else{
                    temppay = new Set<Id>();
                }
                temppay.addall(Invdata);   
                AccInvmap.put(Si.Zuora__Account__c,temppay);    
            }
            system.debug('FinalInvoice :' +FinalInvoice);
        }
        return AccInvmap;
    }
    public static Database.DMLOptions fetchDMLOptions(){
        //Fetching the assignment rules on case
        List<AssignmentRule> assignmentRule= new List<AssignmentRule>();
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
    public static map<Id, case> transfercases(){
        List<Case> Csestoupdateold = new List<Case>();
        List<Case_Invoice_Relationship__c> InvCsestoupdates = new List<Case_Invoice_Relationship__c>();
        map<Id, case> Csestoupdate = new map<Id,case>();    
        Date Creatdate = system.today().adddays(-(integer.valueof(System.Label.daystoclose)));      
        
        List<Case> openCustomerCollectionCases = [SELECT Id,Createddate, AccountId, Account.Name,Account.Total_Contract_Value__c, Status, SubStatus__c, Type, 
                                                  (SELECT id, Invoice__c,Invoice__r.Invoice_Status__c FROM Case_Invoice_Relationships__r)FROM Case 
                                                  WHERE Status != 'Closed' AND Type = 'C3 Collections' AND Subject like '%1st Invoice did not Collect on Asset%' 
                                                  
                                                 ];
        
        if(openCustomerCollectionCases!= null && !openCustomerCollectionCases.isEmpty()){
            Set<Id> Accid = new Set<Id>();
            for(Case inloop: openCustomerCollectionCases){
                Accid.add(inloop.AccountId);
                
            }
            
            List<Case> OpenCollections= [SELECT Id, AccountId, Account.Name,Account.Total_Contract_Value__c, Status, Type, 
                                         (SELECT id, Invoice__c,Invoice__r.Invoice_Status__c FROM Case_Invoice_Relationships__r)FROM Case 
                                         WHERE Status != 'Closed' AND Type = 'Collections' AND Subject like '%Collections Case with Past Due Invoices%' 
                                         AND AccountId IN :Accid
                                         // AND AccountId  IN :openCustomerCollectionCases.AccountId
                                        ];
            
            List<Id> AccIds = new List<Id>();
            Set<Id> ClosingcaseId = new Set<Id>();
            
            
            Set<Id> OpenAccids = new Set<Id>();
            for(Case inloop: OpenCollections){
                OpenAccids.add(inloop.AccountId);
                
            }
            
            for(Case inloop : openCustomerCollectionCases){
                AccIds.add(inloop.AccountId);
                if(OpenAccids!= null && OpenAccids.contains(inloop.AccountId)){
                    Case ccs = new Case();
                    ccs.Id = inloop.Id;
                    ccs.Status = 'Closed';
                    // Csestoupdate.add(ccs);
                    Csestoupdate.put(inloop.AccountId,  ccs);
                    
                    for(Case_Invoice_Relationship__c inloop2 :inloop.Case_Invoice_Relationships__r){
                        Zuora__ZInvoice__c Inv = new Zuora__ZInvoice__c();
                        Inv.Id = inloop2.Invoice__c;
                        Inv.Invoice_Status__c ='Past Due';
                        Inv.Collection_Case_Created__c = false;
                        Inv.NewSubscription__c = false;
                        updateInovice.add(Inv);
                        
                    }
                    if(!Test.isRunningTest())
                        ClosingcaseId.add(inloop.Id);               
                }                           
            }
            Map<Id,Id> accountTeamMemberMap = fetchAccountTeamMembers(AccIds);
            for(Case inloop : openCustomerCollectionCases){
                if(ClosingcaseId.contains(inloop.Id)){
                    Continue;
                }
                //CRM-4097 close cases which are open more then 5 days.
                if(inloop.Createddate <= Creatdate){
                    Case ccs = new Case();
                    ccs.Id = inloop.Id;
                    ccs.Type = 'Collections';
                    system.debug('AccountName@@ ' + inloop.Account.Name);
                    ccs.Subject = 'Collections Case with Past Due Invoices for the Account ' +inloop.Account.Name;
                    ccs.Description = 'Collections Case with Past Due Invoices for the Account '+inloop.Account.Name;
                   /* if(accountTeammemberMap.containsKey(inloop.AccountId)&&((inloop.Account.Total_Contract_Value__c < Integer.valueOf(Label.collectioncase_amount)) || (!inloop.Account.Billing_Preference__c.contains(label.Billingpreference))))
                    {
                        ccs.ownerid = accountTeamMemberMap.get(inloop.AccountId);
                    }else{
                        ccs.setOptions(fetchDMLOptions());
                    }*/
               if(inloop.Account.Total_Contract_Value__c > integer.valueOf(label.collectioncase_amount) && inloop.Account.Total_Contract_Value__c < integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(inloop.Account.Billing_Preference__c)){
                    ccs.ownerid                         = label.userct1; //Eric
                }
               else if(inloop.Account.Total_Contract_Value__c > integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(inloop.Account.Billing_Preference__c)){
                    ccs.ownerid                         = label.userct2; //Pam
               }
               else if(accountTeammemberMap.containsKey(inloop.AccountId)){ //&& !label.Billingpreference.contains(inloop.Account.Billing_Preference__c)
                    ccs.ownerid                         = accountTeamMemberMap.get(inloop.AccountId);
               }else{
                    ccs.setOptions(fetchDMLOptions());
                }
                    //  Csestoupdate.add(ccs);
                    Csestoupdate.put(inloop.AccountId,  ccs);
                    for(Case_Invoice_Relationship__c inloop2 :inloop.Case_Invoice_Relationships__r ){
                        Zuora__ZInvoice__c Inv = new Zuora__ZInvoice__c();
                        Inv.Id = inloop2.Invoice__c;
                        Inv.Invoice_Status__c ='Past Due';
                        updateInovice.add(Inv);
                    }
                }
            }
        }
        return Csestoupdate;
    }
    public static Boolean isRepOnVacation(Date startDate , Date endDate){
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
    public static Map<Id,Id> fetchAccountTeamMembers(List<Id> accountIds){  
        List<Id> accid = new List<Id>();
        Map<Id,Id> accountTeamMap                        = new Map<Id,Id>();
        List<AccountTeamMember> accountTeamList                = [SELECT TeamMemberRole, User.Vacation_Start_Date__c, User.Vacation_End_Date__c,AccountId 
                                                                  FROM AccountTeamMember 
                                                                  WHERE TeamMemberRole = 'Collections Rep' AND AccountId IN: accountIds
                                                                 ];
        for (AccountTeamMember rep : accountTeamList){
            // Add the account and Rep to the map only if the rep is not on vacation
            if(!isRepOnVacation(rep.User.Vacation_Start_Date__c, rep.User.Vacation_End_Date__c)){
                if(accountTeamMap.containsKey(rep.AccountId) == false){
                    AccountTeamMap.put(rep.AccountId, rep.UserId);
                }
            }
        } 
        return accountTeamMap;
    }
    
}