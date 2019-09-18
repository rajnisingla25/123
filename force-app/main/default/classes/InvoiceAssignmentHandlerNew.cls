// Trigger Handler: InvoiceAssignmentClass
// Trigger Name: InvoiceAssignment
// On SObject: Zuora__ZInvoice__c
// Description: Invoice assignment to a open Collection case which have any Past Due Invoices.


public without sharing class InvoiceAssignmentHandlerNew {
    
    /*
@method      : onAfterUpdate
@description : Gets called on before update trigger event.
@params      : trigger.new
@returns     : void
@Help        : Imagine 100 invoices come in and 10 of them are past due and 5 of them have open collection cases on it. 
Read thru the code for comments like 100 invoices, size = 10-5... all these are provided to understand the code in a easy way coz this code logic is very confusing 
and the code had to be written in a complex way
*/
    Public void InvoiceCaseInvoiceBalance(Map <Id,Zuora__ZInvoice__c > InvoicesList){
    //Set<Id> setInvoiceChangeIds = new 
    Map<Id,Case_Invoice_Relationship__c> mapCaseInvoice = new Map<Id,Case_Invoice_Relationship__c>([Select Id,Name,Invoice__c, Past_Due_Amount__c,Days_Past__c from Case_Invoice_Relationship__c where Invoice__c=:InvoicesList.keyset()]);
    for(Case_Invoice_Relationship__c cai:mapCaseInvoice.values()){
    //system.debug('#######'+InvoicesList.get(cai.Invoice__c).Zuora__Balance2__c);
    cai.Past_Due_Amount__c = InvoicesList.get(cai.Invoice__c).Zuora__Balance2__c;
    cai.Days_Past__c       = InvoicesList.get(cai.Invoice__c).Days_Past_Due__c;
    /* cai.Days_Past__c =0;
    if(InvoicesList.get(cai.Invoice__c).Zuora__DueDate__c!=null){   
    cai.Days_Past__c = InvoicesList.get(cai.Invoice__c).Zuora__DueDate__c.daysBetween(System.Today()); 
   } */
    }
    if(mapCaseInvoice.values().size()>0){
    update mapCaseInvoice.values();
    }
    }
    Public void InvoiceCaseAssignmentMethod(List < Zuora__ZInvoice__c > InvoicesList ) {
        
        set<Id> sInvoiceIds = new set<Id>();
        set<Id> accountids = new set<Id>();
        Map< Id, Id > accountTeammemberMap = new Map < Id,Id >();
        Map< Id, Id > pastDueinvoiceAccountMap = new Map < Id,Id >();
        List < Case_Invoice_Relationship__c > CIRList = new List < Case_Invoice_Relationship__c > ();
        List<Zuora__ZInvoice__c> lstInvoiceUpdate = new List<Zuora__ZInvoice__c>();
        List<Case> CaseList = new List<Case>();
        List < Case_Invoice_Relationship__c > newCIRRecordsList = new List < Case_Invoice_Relationship__c > ();
        Zuora__ZInvoice__c objInvoice;
        
        system.debug('TRACE Invoices Received : ' + InvoicesList);
        // Get all the invoice and account Id's
        for (Zuora__ZInvoice__c z: invoicesList) {
            sInvoiceIds.add(z.id);
            accountids.add(z.Zuora__Account__c);
            // 100 Invoices
        }
        
        Map<Id,Zuora__ZInvoice__c> mapZuoraInvoice = new Map<Id,Zuora__ZInvoice__c>();
        // Filter past due invoices and collect them                                   
        for (Zuora__ZInvoice__c Zinvoice: [Select id ,Zuora__DueDate__c,Zuora__Balance2__c ,Invoice_Status__c, Zuora__Account__c,
                                           Zuora__Account__r.Name from Zuora__ZInvoice__c where id in: sInvoiceIds]) //100 Invoices
        {
            system.debug('TRACE : Invoices - '+ Zinvoice);
            if (Zinvoice.Zuora__DueDate__c < System.TODAY() && (Zinvoice.Zuora__Balance2__c > 0 )) {                  
                objInvoice = new Zuora__ZInvoice__c(id=Zinvoice.id);
                objInvoice.Invoice_Status__c  = 'Past Due'; // size  = 10           
                lstInvoiceUpdate.add(objInvoice);  // Collect the past due invoice Id's 
                // past due invoice and account Map
                pastDueinvoiceAccountMap.Put(Zinvoice.Zuora__Account__c, Zinvoice.id); //10
                mapZuoraInvoice.put(Zinvoice.id, Zinvoice); // size = 10
                
            }                  
        }
        
        // Update invoices that are past due ( Status = Past Due)
        if(!lstInvoiceUpdate.isEmpty()){
            try{
                update lstInvoiceUpdate; // 10 Invoices
            }catch (Exception e){
                system.debug('TRACE : Invoice update failed with the error: ' + e.getMessage());
            }
        }
        
        // For insert not AccountId IN: accountids 
        // Get the cases on the invoice is present already.
        List<Case> openCollectionCases = [Select id, Status, SubStatus__c, AccountId from Case where Status != 'closed' and Type = 'Collections'
                                          and AccountId IN: pastDueinvoiceAccountMap.keySet()]; // 5 cases
        
        system.debug('TRACE Past Due account Invoice Map:'+ pastDueinvoiceAccountMap);
        system.debug('TRACE Open Collection Cases : '+ openCollectionCases);
        set<Id> sAccID = new set<Id>();
        Map< Id, Id > noCaseinvoiceAccountMap = pastDueinvoiceAccountMap; // Copy the invoice account Map
        Account objAcc;
        
        for (Case cs: openCollectionCases) { // 5 times
            sAccID.add(cs.AccountId); 
            // create CIR record  if the case account is in the map 
            if(pastDueinvoiceAccountMap.containskey(cs.AccountId)){
                // remove the invoices/account KV pair which have cases already
                mapZuoraInvoice.remove(pastDueinvoiceAccountMap.get(cs.AccountId)); 

                Case_Invoice_Relationship__c cir = new Case_Invoice_Relationship__c();
                cir.Case__c = cs.id;
                cir.Invoice__c = pastDueinvoiceAccountMap.get(cs.AccountId);
                CIRList.add(cir); // 5 CIR recs
            }else {
                // removing the key if there is an open collections case. For these invoices new cases+CIR have to be created 
                noCaseinvoiceAccountMap.remove(cs.AccountId); // size = 10-5 =5
             }
         }

        system.debug('TRACE  New CIR List '+ CIRList);
        system.debug('TRACE Invoices with no case on them: '+noCaseinvoiceAccountMap);
        
        
        
        // if the collection case is open on the account, the account past_due__c field is already true
        // accountids - sAccID = the accounts that does not have open collections case and they need to be made past due field = true
        
        // flagging the accounts as past due if there is no open collections case open on them but a past due invoice 
        List<Account> lstAccpuntPastDue = [select id from Account where id in: noCaseinvoiceAccountMap.keySet()];
        for(Account acc: lstAccpuntPastDue){ // size = 5 accounts
            acc.Past_Due__c = True;
        }
        
        if(!lstAccpuntPastDue.isEmpty()){
            try{
                update lstAccpuntPastDue;
            }catch (Exception e){
                system.debug('TRACE : Account update failed with the error: ' + e.getMessage());
            }
        }
        
        
        
        // Query Collection Reps assigned to the Accounts on which new cases have to be created
        List<AccountTeamMember> CollectionRepsOnTheAccount = [SELECT TeamMemberRole, User.Vacation_Start_Date__c, User.Vacation_End_Date__c,AccountId 
                                                              FROM AccountTeamMember WHERE TeamMemberRole = 'Collections Rep' AND 
                                                              AccountId IN: noCaseinvoiceAccountMap.keySet()];
        
        system.debug('CollectionRepsOnTheAccount : ' + CollectionRepsOnTheAccount.size());
        // Map Accounts and Reps
        for (AccountTeamMember rep : CollectionRepsOnTheAccount){
            // Add the account and Rep to the map only if the rep is not on vacation
            if(!isRepOnVacation(rep.User.Vacation_Start_Date__c, rep.User.Vacation_End_Date__c)){
                if(accountTeammemberMap.containsKey(rep.AccountId) == false){
                    accountTeammemberMap.Put(rep.AccountId, rep.UserId);
                }
            }
        } 
        
        // case insertion via Apex will not run assignment rules by default. So setting DMLOptions on Database.
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id; 
        
        // IF No Open collections case on Account . So creating new cases
        system.debug('TRACE Zuora Account Invoice MAp: '+ mapZuoraInvoice);
        for (Zuora__ZInvoice__c z: mapZuoraInvoice.values()) {
            // Will create case and assign invoices to it. So even if the update of invoices fail,The case will be created and will have 
            //invoices associated to it.  Admins can look into the issue later. Created cases so the reps can start collection process
            
            case cs = new case ();
            cs.Status = 'New';
            cs.SubStatus__c = '';
            cs.Origin = 'Web';
            cs.Subject = 'Collections Case with Past Due Invoices for the Account ' + z.Zuora__Account__r.Name;
            cs.recordTypeId = CaseRecordTypes__c.getValues('Collection').Record_Type_Id__c;
            cs.Type = 'Collections';
            cs.Accountid = z.Zuora__Account__c;
            if(accountTeammemberMap.containsKey(z.Zuora__Account__c)){
                cs.ownerid = accountTeammemberMap.get(z.Zuora__Account__c);
            }else{
                cs.setOptions(dmlOpts);
            }
            CaseList.add(cs); // new cases that need to be inserted
        }
        
        system.debug(' TRACE New cases Inserted  :' + CaseList);
        
        
        // Try to insert the cases and catch the exception if it fails
        if(CaseList.size()>0){
            try{
                insert CaseList;
            }catch (Exception e){                        
                system.debug('TRACE : Cases update failed with the error: ' + e.getMessage());
            }  
        }
        
        
        system.debug('newCIRRecordsList: ' + newCIRRecordsList);                    

        for (case c: CaseList) {
            for (Zuora__ZInvoice__c Z: InvoicesList) {                    
                Case_Invoice_Relationship__c cir = new Case_Invoice_Relationship__c();
                cir.Case__c = c.id;
                cir.Invoice__c = Z.id;
                newCIRRecordsList.add(cir);
                system.debug('newCIRRecordsList: ' + newCIRRecordsList.size());                    
            }
        } 
        
        system.debug('TRACE CIRList :'+ CIRList);
        system.debug('TRACE : New CIR records '+newCIRRecordsList);
        
        // Add the new CIR records to the ones for the existing CIR records
        CIRList.addAll(newCIRRecordsList);
        
        // Inserting the CIR for the cases which are existing sizeOf(invoiceAccountMap - openCollectionCases )
        if (CIRList.size() > 0) { // size =5
            try{
                insert CIRList;
            }catch (Exception e){
                
                system.debug('TRACE : CIR  update failed with the error: ' + e.getMessage());
            }
            CIRList.clear();
            
        }
        
    }       
    
    public boolean isRepOnVacation(Date startDate , Date endDate){
        
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