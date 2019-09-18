global class MergeServiceSOAP{
    
    //Input from CDH via SOA
    global class MergeInput {
        webservice String SurvivorExternalID;
        webservice list<string> VictimExternalIDs;
        webservice string EntityName;
    }
    
    //Response to CDH via SOA
    global class MergeResponse {
        webservice String Status;
        webservice String ErrorMessage;
        webservice String SurvivorSFDCID;
        webservice String SurvivorExternalID;
    }
    global static boolean SkipTriggerExecution = false;
    
    //Evaluate entity Name
    webservice static List<MergeResponse> MergeObjects(List<MergeInput> lstMergeIDs) {
        List<MergeResponse> response = new List<MergeResponse>();
        Map<String,MergeInput> contactMethodInputMap = new Map<String,MergeInput>();
        //Account merge
        for(MergeInput MergeIDs:lstMergeIDs){
            if(MergeIDs.EntityName == 'Account'){
                Return response = AccountMerge(MergeIDs);
            }
            //Contact merge
            if(MergeIDs.EntityName == 'Contact'){
                Return response = ContactMerge(MergeIDs);
            }
        } 
        //Contact Method merge
        for(MergeInput MergeIDs:lstMergeIDs){              
            if(MergeIDs.EntityName == 'ContactMethod'){
                contactMethodInputMap.put('ContactMethod',MergeIDs);
            }  
        }
        
        if(!contactMethodInputMap.isEmpty()){
            Return response = ContactMethodMerge(lstMergeIDs); 
        }
        
        Return response;
    }    
    
    //Account Merge logic
    webservice static List<MergeResponse> AccountMerge(MergeInput MergeIDs) {
        boolean srvrhasbilling = false;
        boolean srvrhasprmrcnt = false;
        List<MergeResponse>  response = new List<MergeResponse>();
        set<string> vctmids = new set<string>();
        set<id> vctmacctids = new set<id>();        
        List<SObject> updatechilds = new List<SObject>();
        List<SObject> updatechilds2 = new List<SObject>();
        // CRM-3768 Moved harcoded date & term to label
        // Date contractStartDate = date.newinstance(2016, 1, 1);
        // Integer contractTerm = 60;
        Date contractStartDate = date.parse(Label.Merge_Process_Contract_Start_Date);
        Integer contractTerm = Integer.valueOf(Label.Merge_Process_Contract_Term);
        // CRM-3768 End
        boolean srvrisprmry = false;
        
        String ContactMethodType_Email = 'Email';
        String ContactMethodType_Phone = 'Phone';
        String ContactMethodType_Web = 'Web'; 
        
        // CRM-3768 - Moved save point at the top.
        Savepoint sp = Database.setSavepoint();
        
        for(string vctmloop : MergeIDs.VictimExternalIDs){
            vctmids.add(vctmloop);
        }
        
        // CRM-594 Fetch survivor Account Contract and store is id.
        Contract survivorContract = null;
        Account survivorAcct = [SELECT id, (SELECT id, StartDate, ContractTerm, Status FROM Contracts Order By LastModifiedDate Desc) FROM Account WHERE party_id__c = :MergeIDs.SurvivorExternalID];
        if (survivorAcct.Contracts.size() > 0) {
            survivorContract = survivorAcct.Contracts[0];
            for (Contract con : survivorAcct.Contracts) {
                if (con.status == 'Active') {
                    survivorContract = con;
                    break;
                }
            }
        }
        id svracctid = survivorAcct.Id;
        // CRM-594 End
        
        //id svracctid = [select id from account where party_id__c = :MergeIDs.SurvivorExternalID].id;
        
        /*try{
list<Account_Relationship__c> PrntBllng = [select Contact_Role__c,Billing_Contact__c from Account_Relationship__c where Parent_Account__c = :svracctid
and (Billing_Contact__c = true or Contact_Role__c = 'Primary Contact')];
for(Account_Relationship__c actrltnloop : PrntBllng){
if(actrltnloop.Billing_Contact__c){
srvrhasbilling = true;
}
if(actrltnloop.Contact_Role__c == 'Primary Contact'){
srvrhasprmrcnt = true;
}
}
}catch (QueryException e){
srvrhasbilling = false;
srvrhasprmrcnt = false;
}*/
        
        list<Account> vctmacctid = [select id,(select Account_Name__c from Account_Listings__r)
                                    ,(select AccountId, Status, Id from Contracts) // CRM-594 Added Status & Id
                                    ,(select AccountId from Assets)
                                    ,(select Account__c from Payment_Profiles__r)
                                    ,(select AccountId from Opportunities)
                                    ,(select whatId from Tasks)
                                    ,(select AccountId from Events)
                                    ,(select AccountId, ContractId, Status from Orders) // CRM-594 Added ContractId //CRM-3091 Added Status
                                    ,(select AccountId, ContactID from cases)
                                    ,(select AccountId, ID from Contacts)
                                    ,(select Zuora__Account__c from R00N40000001kyLcEAI__r)
                                    ,(select Id,Account__c, Pre_Auth_Contact__c from Waitlists__r) 
                                    ,(select ParentId from Attachments)
                                    ,(select Bill_To_Account__c from Invoice_History__r)
                                    ,(select Fulfill_To_Account_Id__c from Invoice_Line_Item_History__r)
                                    ,(select Bill_To_Account__c from Payment_History__r)
                                    ,(select Account__c from Leads__r)
                                    ,(select Account__c from Campaign_History__r)
                                    from account where party_id__c in :vctmids];
        for(Account vctmacctidlp: vctmacctid ){
            vctmacctids.add(vctmacctidlp.id);
        }
        
        String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
        try{
            // When Child Account is Victim & Survior or Parent Account is Victim & Survior
            
            // Get the Account Relationship records when Child Account is Survior Child_Account__c =: svracctid
            // Get the Account Relationship records when Parent Account is Survior Parent_Account__c =: svracctid         
            /*        list<Account_Relationship__c> AccRelationShipRecSrvr = [select Parent_Account__c, Child_Account__c from Account_Relationship__c 
where Child_Account__c =: svracctid or Parent_Account__c =: svracctid];
// Get the Account Relationship records when Child Account is Victim Child_Account__c in :vctmacctid
// Get the Account Relationship records when Parent Account is Victim Parent_Account__c in :vctmacctid         
list<Account_Relationship__c> AccRelationShipRecVctm = [select Parent_Account__c, Child_Account__c from Account_Relationship__c 
where Child_Account__c in :vctmacctid or Parent_Account__c in :vctmacctid];    

// Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Child Account"
list<Account_Relationship__c> delAccRelationShipRec = new list<Account_Relationship__c>();
if(AccRelationShipRecSrvr.size() > 0 && AccRelationShipRecVctm.size() > 0){ 
for(Integer i = 0; i < AccRelationShipRecSrvr.size(); i++) {
for(Integer j = 0; j < AccRelationShipRecVctm.size(); j++) {
if(
AccRelationShipRecVctm.get(j).Parent_Account__c == AccRelationShipRecSrvr.get(i).Parent_Account__c &&
AccRelationShipRecVctm.get(j).Child_Account__c == AccRelationShipRecSrvr.get(i).Child_Account__c
) {
delAccRelationShipRec.add(AccRelationShipRecVctm.get(j));
}
}
}
}*/
            
            list<Account_Relationship__c> delAccRelationShipRec = new list<Account_Relationship__c>();
            // CRM-866
            // Add Relationships to a set to avoid error - 'Duplicate id in list'
            Set<Account_Relationship__c> delAccRelationShipRecSet = new Set<Account_Relationship__c>();
            
            // When Child Account is Victim & Survior
            
            // Get the Account Relationship records when Child Account is Survior
            list<Account_Relationship__c> AccRelationShipRecSrvrC = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                                                     where Child_Account__c =: svracctid and RecordTypeId =: accountRelationshipRecordTypeId];          
            // Get the Account Relationship records when Child Account is Victim
            list<Account_Relationship__c> AccRelationShipRecVctmC = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                                                     where Child_Account__c in :vctmacctid and RecordTypeId =: accountRelationshipRecordTypeId];            
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Child Account"      
            
            if(AccRelationShipRecSrvrC.size() > 0 && AccRelationShipRecVctmC.size() > 0){ 
                for(Integer i = 0; i < AccRelationShipRecSrvrC.size(); i++) {
                    
                    for(Integer j = 0; j < AccRelationShipRecVctmC.size(); j++) {
                        
                        if(
                            AccRelationShipRecVctmC.get(j).Parent_Account__c == AccRelationShipRecSrvrC.get(i).Parent_Account__c
                            // && AccRelationShipRecVctmC.get(j).Child_Account__c == AccRelationShipRecSrvrC.get(i).Child_Account__c
                        ) {
                            delAccRelationShipRecSet.add(AccRelationShipRecVctmC.get(j));
                            if(AccRelationShipRecVctmC.get(j).Is_Parent_Primary__c){
                                AccRelationShipRecSrvrC.get(i).Is_Parent_Primary__c = true;
                                updatechilds.add(AccRelationShipRecSrvrC.get(i));
                            }
                            //updatechilds.add(AccRelationShipRecSrvrC.get(i));
                        }
                    }
                }
            }
            
            // When Parent Account is Victim & Survior
            
            // Get the Account Relationship records when Parent Account is Survior
            list<Account_Relationship__c> AccRelationShipRecSrvrP = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                                                     where Parent_Account__c =: svracctid and RecordTypeId =: accountRelationshipRecordTypeId];          
            // Get the Account Relationship records when Parent Account is Victim
            list<Account_Relationship__c> AccRelationShipRecVctmP = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                                                     where Parent_Account__c in :vctmacctid and RecordTypeId =: accountRelationshipRecordTypeId];            
            
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Child Account"      
            if(AccRelationShipRecSrvrP.size() > 0 && AccRelationShipRecVctmP.size() > 0){ 
                for(Integer i = 0; i < AccRelationShipRecSrvrP.size(); i++) {
                    for(Integer j = 0; j < AccRelationShipRecVctmP.size(); j++) {
                        if(
                            //AccRelationShipRecVctmP.get(j).Parent_Account__c == AccRelationShipRecSrvrP.get(i).Parent_Account__c &&
                            AccRelationShipRecVctmP.get(j).Child_Account__c == AccRelationShipRecSrvrP.get(i).Child_Account__c
                        ) {
                            delAccRelationShipRecSet.add(AccRelationShipRecVctmP.get(j));
                            if(AccRelationShipRecVctmP.get(j).Is_Parent_Primary__c){
                                AccRelationShipRecSrvrP.get(i).Is_Parent_Primary__c = true;
                                updatechilds.add(AccRelationShipRecSrvrP.get(i));
                            }
                            //updatechilds.add(AccRelationShipRecSrvrP.get(i));
                        }
                    }
                }
            }
            
            
            if(!delAccRelationShipRecSet.isEmpty()) {
                delAccRelationShipRec.addall(delAccRelationShipRecSet);
                delete delAccRelationShipRec;
            }
            // CRM-866
            // Clear both set and list to avoid exception - ENTITY_IS_DELETED
            delAccRelationShipRecSet.clear();
            delAccRelationShipRec.clear();
            
            
            
            // When Child Account is Victim & Survior - deleting the duplicate "Parent Account" + "Child Account" Relationship record at Victim Side 
            
            // Get the Account Relationship records when Child Account is Victim for deletion at Victim side where it have duplicate "Parent Account" + "Child Account" in context with Victim side Relationship Records itself
            AccRelationShipRecVctmC = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                       where Child_Account__c in :vctmacctid and RecordTypeId =: accountRelationshipRecordTypeId];            
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Child Account" in context with Victim side Relationship Records itself     
            if(AccRelationShipRecVctmC.size() > 1){ 
                for(Integer i = 0; i < AccRelationShipRecVctmC.size()-1; i++) {
                    
                    for(Integer j = i+1; j < AccRelationShipRecVctmC.size(); j++) {
                        
                        if( AccRelationShipRecVctmC.get(j).Parent_Account__c == AccRelationShipRecVctmC.get(i).Parent_Account__c ) {
                            delAccRelationShipRecSet.add(AccRelationShipRecVctmC.get(j));
                            if(AccRelationShipRecVctmC.get(j).Is_Parent_Primary__c){
                                AccRelationShipRecVctmC.get(i).Is_Parent_Primary__c = true;
                            }
                        }
                    }
                }
            }
            
            // When Parent Account is Victim & Survior - deleting the duplicate "Parent Account" + "Child Account" Relationship record at Victim Side 
            
            // Get the Account Relationship records when Parent Account is Victim for deletion at Victim side where it have duplicate "Parent Account" + "Child Account" in context with Victim side Relationship Records itself
            AccRelationShipRecVctmP = [select Parent_Account__c, Child_Account__c, Is_Parent_Primary__c from Account_Relationship__c 
                                       where Parent_Account__c in :vctmacctid and RecordTypeId =: accountRelationshipRecordTypeId];     
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Child Account" in context with Victim side Relationship Records itself      
            if(AccRelationShipRecVctmP.size() > 1){ 
                for(Integer i = 0; i < AccRelationShipRecVctmP.size()-1; i++) {
                    for(Integer j = i+1; j < AccRelationShipRecVctmP.size(); j++) {
                        if( AccRelationShipRecVctmP.get(j).Child_Account__c == AccRelationShipRecVctmP.get(i).Child_Account__c ) {
                            delAccRelationShipRecSet.add(AccRelationShipRecVctmP.get(j));
                            if(AccRelationShipRecVctmP.get(j).Is_Parent_Primary__c){
                                AccRelationShipRecVctmP.get(i).Is_Parent_Primary__c = true;
                            }
                        }
                    }
                }
            }
            
            
            if(!delAccRelationShipRecSet.isEmpty()) {
                delAccRelationShipRec.addall(delAccRelationShipRecSet);
                delete delAccRelationShipRec;
            }
            
            
            /*list<Account_Relationship__c> delAccRelationShipRec = [select Child_Account__c from Account_Relationship__c 
where ( Child_Account__c in :vctmacctid or Parent_Account__c in :vctmacctid )  
and ( Parent_Account__c =: svracctid or Child_Account__c =: svracctid ) ];
if(!delAccRelationShipRec.isEmpty()){
delete delAccRelationShipRec;
}

list<Account_Relationship__c> delAccRelationShipRec2 = [select Child_Account__c from Account_Relationship__c 
where Parent_Account__c in :vctmacctid and Child_Account__c =: svracctid];
if(!delAccRelationShipRec2.isEmpty()){
delete delAccRelationShipRec2;
}*/
            
            // Get account relationship records for Survior account
            // When Child Account is Victim & Survior where Child_Account__c = :svracctid
            // When Parent Account is Victim & Survior where Parent_Account__c = :svracctid
            list<Account_Relationship__c> PrntPrmry = [ select Is_Parent_Primary__c from Account_Relationship__c 
                                                       where ( Child_Account__c = :svracctid or Parent_Account__c = :svracctid) and RecordTypeId =: accountRelationshipRecordTypeId];
            try{
                for(Account_Relationship__c actrltnloop : PrntPrmry){
                    if(actrltnloop.Is_Parent_Primary__c){
                        srvrisprmry = true;
                    }
                }
            }catch (QueryException e){
                srvrisprmry = false;
            }
            
            // Get account relationship records for Victim account
            // When Child Account is Victim & Survior where Child_Account__c = :vctmacctids
            // When Parent Account is Victim & Survior where Parent_Account__c = :vctmacctids
            list<Account_Relationship__c> acctrellst = [select Child_Account__c,Parent_Account__c,Billing_Contact__c,Contact_Role__c, Is_Parent_Primary__c from Account_Relationship__c
                                                        where ( Child_Account__c in :vctmacctids or Parent_Account__c in :vctmacctids ) and RecordTypeId =: accountRelationshipRecordTypeId];
            
            for(Account_Relationship__c acctrellstlp : acctrellst ){
                if(vctmacctids.contains(acctrellstlp.Child_Account__c)){
                    if(acctrellstlp.Is_Parent_Primary__c && srvrisprmry){
                        acctrellstlp.Is_Parent_Primary__c = false;
                    }
                    
                    if(acctrellstlp.Is_Parent_Primary__c && !srvrisprmry){
                        acctrellstlp.Is_Parent_Primary__c = false;
                        if(PrntPrmry.size() > 0) {
                            
                            PrntPrmry[0].Is_Parent_Primary__c = true;
                            updatechilds.add(PrntPrmry[0]);
                        }
                    }
                    acctrellstlp.Child_Account__c = svracctid;
                    
                }
                if(vctmacctids.contains(acctrellstlp.Parent_Account__c)){
                    
                    /* if(acctrellstlp.Billing_Contact__c && srvrhasbilling){
//already parent has billing contact so victim billing contact will be added as non billing contact
acctrellstlp.Billing_Contact__c = false;
}

if(acctrellstlp.Contact_Role__c == 'Primary Contact' && srvrhasprmrcnt){
//already parent has primary contact so victim billing contact will be added as non primary contact
acctrellstlp.Contact_Role__c = null;
}*/
                    if(acctrellstlp.Is_Parent_Primary__c && srvrisprmry){
                        acctrellstlp.Is_Parent_Primary__c = false;
                    }
                    
                    if(acctrellstlp.Is_Parent_Primary__c && !srvrisprmry){
                        
                        acctrellstlp.Is_Parent_Primary__c = false;
                        if(PrntPrmry.size() > 0) {
                            PrntPrmry[0].Is_Parent_Primary__c = true;
                            updatechilds.add(PrntPrmry[0]);
                        }
                    }
                    acctrellstlp.Parent_Account__c = svracctid;
                    
                }
                updatechilds.add(acctrellstlp);
                
            }
        }catch(exception e){
            // No action required as this error is no records for this relations 
        } 
        
        // Collect the Contact ids of Cases associated with Victim Account
        set<id> vctmcasecntids = new set<id>();   
        for(Account vctmacctloop : vctmacctid){
            list<case> caselst = new list<case>(vctmacctloop.cases);
            for(case caselstlp :  caselst){
                vctmcasecntids.add(caselstlp.ContactId);
            }
        }
        
        // Collect the Contact ids of Cases associated with Survivor Account
        list<Account> srvrmacct = [select id, (select AccountId, ContactID from cases)
                                   from account where id =: svracctid];      
        set<id> srvrcasecntids = new set<id>();   
        for(Account srvrmacctloop : srvrmacct){
            list<case> caselst = new list<case>(srvrmacctloop.cases);
            for(case caselstlp :  caselst){
                srvrcasecntids.add(caselstlp.ContactId);
            }
        }
        
        // Collect the Case Contact Record at Victim and Survivor Account
        list<Contact> casecnt = [ select id, AccountId from Contact where id in: vctmcasecntids or id in: srvrcasecntids ];
        
        // Update the Account to Survivor Account(if it is Victim Contact) for Contact associated with Cases on Victim/Survivor Account 
        // so it will allow to delete the Victim Account  
        try{
            for(Contact casecntlp : casecnt){
                if( vctmacctids.contains(casecntlp.AccountId) ){
                    casecntlp.AccountId = svracctid;
                    updatechilds.add(casecntlp);
                }
            }
        }catch(exception e){
            // No action required as this error is no records for this relations 
        } 
        
        // CRM-591 Begin
        // If Victim Account has waitlist then update its Pre_Auth_Contact__c accountId to Survivor account id.
        try {
            for(Account vctmacctloop : vctmacctid){
                for(WaitList__c waitList :  vctmacctloop.Waitlists__r){
                    updatechilds.add(new Contact(id=waitList.Pre_Auth_Contact__c, AccountId = svracctid));
                }
            }
        }
        catch (exception e) {}
        // CRM-591 END
        
        /* list<Contact> srvrcasecnt = [ select id, AccountId from Contact where id in: srvrcasecntids ];

for(Contact srvrcasecntlp : srvrcasecnt){
if( vctmacctids.contains(srvrcasecntlp.AccountId) ){
srvrcasecntlp.AccountId = svracctid;
updatechilds.add(srvrcasecntlp);
}
}*/
        // CRM-594
        Map<Id, Contract> activeContracts = new Map<Id, Contract>();
        for(Account vctmacctloop : vctmacctid){
            //Reparenting account_listing__c
            try{
                list<Account_Listing__c> acctlstngs = new list<Account_Listing__c>(vctmacctloop.Account_Listings__r);
                for(Account_Listing__c acctlstngslp : acctlstngs){
                    acctlstngslp.Account_Name__c = svracctid;
                    updatechilds.add(acctlstngslp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting Contracts
            try{
                list<Contract> cntrctlst = new list<Contract>(vctmacctloop.Contracts);
                for(Contract cntrctlstlp : cntrctlst){
                    // CRM-594 Move Contract only if its not Active
                    if (cntrctlstlp.Status != 'Active') {
                        cntrctlstlp.AccountId = svracctid;
                        updatechilds.add(cntrctlstlp);
                    }
                    else {
                        activeContracts.put(cntrctlstlp.Id, cntrctlstlp);
                    }
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting Assets
            try{
                list<Asset> Assetlst = new list<Asset>(vctmacctloop.Assets);
                for(Asset Assetlstlp : Assetlst){
                    Assetlstlp.AccountId = svracctid;
                    updatechilds.add(Assetlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Payment_Profiles__c
            try{
                list<PaymentProfiles__c>  Pmntprflslst = new list<PaymentProfiles__c>(vctmacctloop.Payment_Profiles__r);
                for(PaymentProfiles__c  Pmntprflslstlp :  Pmntprflslst){
                    Pmntprflslstlp.Account__c = svracctid;
                    updatechilds.add( Pmntprflslstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Opportunity
            try{
                list<Opportunity>  opptylst = new list<Opportunity>(vctmacctloop.Opportunities);
                for(Opportunity opptylstlp :  opptylst){
                    opptylstlp.AccountId = svracctid;
                    updatechilds.add( opptylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Tasks
            try{
                list<Task>  tasklst = new list<Task>(vctmacctloop.Tasks);
                for(Task tasklstlp :  tasklst){
                    tasklstlp.whatId = svracctid;
                    updatechilds.add(tasklstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Events
            try{
                list<Event> Eventlst = new list<Event>(vctmacctloop.Events);
                for(Event Eventlstlp :  Eventlst){
                    Eventlstlp.whatId = svracctid;
                    updatechilds.add(Eventlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Orders
            try{
                list<Order> Orderlst = new list<Order>(vctmacctloop.Orders);
                // CRM-3091 De-Activate Active Orders before Reparanting it.
                Map<Id, Order> deactivateOrders = new Map<Id, Order>();
                for(Order Orderlstlp :  Orderlst){
                    if (Orderlstlp.Status == 'Complete') {
                        Orderlstlp.Status = 'Created';
                        deactivateOrders.put(Orderlstlp.Id, Orderlstlp);
                    }
                }
                if(!deactivateOrders.isEmpty()) {
                    update deactivateOrders.values();
                }
                // CRM-3091 End
                
                for(Order Orderlstlp :  Orderlst){
                    Orderlstlp.AccountId = svracctid;
                    // CRM-594 Assign survivor Contract Id if order belongs to an active victim contract
                    if (activeContracts.containsKey(Orderlstlp.ContractId)) {
                        if (survivorContract == null) {
                            survivorContract = new Contract(AccountId = svracctid, Status = 'Draft', StartDate = contractStartDate, ContractTerm = contractTerm);
                            insert survivorContract;
                            // CRM-3768 - Activate Contract
                            survivorContract.Status = 'Active';
                            update survivorContract;
                            // CRM-3768 - end
                        }
                        else if ((survivorContract.StartDate == null || survivorContract.StartDate > contractStartDate) && (survivorContract.ContractTerm == null || survivorContract.ContractTerm < contractTerm)) {
                            survivorContract.StartDate = contractStartDate;
                            survivorContract.ContractTerm = contractTerm;
                            update survivorContract;
                        }
                        Orderlstlp.contractId = survivorContract.Id;
                        // CRM-3091 Activate back all deactivated Orders
                        if (deactivateOrders.containsKey(Orderlstlp.Id)) {
                            Orderlstlp.Status = 'Complete';
                        }
                        // CRM-3091 End
                    }
                    // CRM-594 End
                    updatechilds.add(Orderlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  case
            try{
                list<case> caselst = new list<case>(vctmacctloop.cases);
                for(case caselstlp :  caselst){
                    caselstlp.AccountId = svracctid;
                    caselstlp.Oracle_Quote__c = null;    // CRM-3924 - Clear Oracle_Quote__c
                    updatechilds2.add(caselstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting Zuora__Account__c
            try{
                list<Zuora__CustomerAccount__c> ZuoraAccountlst = new list<Zuora__CustomerAccount__c>(vctmacctloop.R00N40000001kyLcEAI__r);
                for(Zuora__CustomerAccount__c ZuoraAccountlstlp :  ZuoraAccountlst){
                    ZuoraAccountlstlp.Zuora__Account__c = svracctid;
                    updatechilds2.add(ZuoraAccountlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  PaymentProfiles__c
            try{
                /* list<PaymentProfile__c> PaymentProfileslst = new list<PaymentProfile__c>(vctmacctloop.PaymentProfiles__r);
for(PaymentProfile__c PaymentProfileslstlp :  PaymentProfileslst){
PaymentProfileslstlp.Party_ID__c = MergeIDs.SurvivorExternalID;
updatechilds.add(PaymentProfileslstlp);
}*/
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Attachments
            try{
                list<Attachment> Attachmentlst = new list<Attachment>(vctmacctloop.Attachments);
                for(Attachment Attachmentlstlp :  Attachmentlst){
                    Attachmentlstlp.ParentId = svracctid;
                    updatechilds2.add(Attachmentlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Invoice_History__c
            try{
                list<Invoice_History__c> Invoicehistorylst = new list<Invoice_History__c>(vctmacctloop.Invoice_History__r);
                for(Invoice_History__c Invoicehistorylstlp :  Invoicehistorylst){
                    Invoicehistorylstlp.Bill_To_Account__c = svracctid;
                    updatechilds2.add(Invoicehistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Invoice_Line_Item_History__C
            try{
                list<Invoice_Line_Item_History__c> InvoiceLineItemHistorylst = new list<Invoice_Line_Item_History__c>(vctmacctloop.Invoice_Line_Item_History__r);
                for(Invoice_Line_Item_History__c InvoiceLineItemHistorylstlp :  InvoiceLineItemHistorylst){
                    InvoiceLineItemHistorylstlp.Fulfill_To_Account_Id__c = svracctid;
                    updatechilds2.add(InvoiceLineItemHistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Payment_History__C
            try{
                list<Payment_History__C> Paymenthistorylst = new list<Payment_History__C>(vctmacctloop.Payment_History__r);
                for(Payment_History__C Paymenthistorylstlp :  Paymenthistorylst){
                    Paymenthistorylstlp.Bill_To_Account__c = svracctid;
                    updatechilds2.add(Paymenthistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Lead
            try{
                list<Lead> Leadslst = new list<Lead>(vctmacctloop.Leads__r);
                for(Lead Leadslstlp :  Leadslst){
                    Leadslstlp.Account__c = svracctid;
                    updatechilds2.add(Leadslstlp);
                }            
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Campaign_History__c
            try{
                list<Campaign_History__c> Campaignhistorylst = new list<Campaign_History__c>(vctmacctloop.Campaign_History__r);
                for(Campaign_History__c Campaignhistorylstlp :  Campaignhistorylst){
                    Campaignhistorylstlp.Account__c = svracctid;
                    updatechilds2.add(Campaignhistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            //Reparenting  Contact
            Set<Id> setContactAccountIds = new Set<Id>();
            try{
                
                list<Contact> AccountContactlst = new list<Contact>(vctmacctloop.Contacts);
                for(Contact contactlstlp :  AccountContactlst){
                    setContactAccountIds.add(contactlstlp.id);
                    contactlstlp.AccountId = svracctid;
                    updatechilds2.add(contactlstlp);
                    //Campaignhistorylstlp.Account__c = svracctid;
                    //updatechilds.add(Campaignhistorylstlp);
                }
                Map<Id,Case> mapContactCase = new Map<Id,Case>();
                for(Case conn:[Select Id,contactId from case where contactId=:setContactAccountIds]){
                    conn.contactId=null;
                    mapContactCase.put(conn.id,conn);
                }
                update mapContactCase.values();
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            /* CRM-591 - Pre_Auth_Contact__c is a required field, below code will always fail, no need of below code.
try{
Set<Id> setWaitlistIds = new Set<Id>();
list<waitlist__c> Waitlistlst = [Select Id,name,Pre_Auth_Contact__c from waitlist__c where  Pre_Auth_Contact__c=:setContactAccountIds];
for(waitlist__c wtlst :  Waitlistlst){
wtlst.Pre_Auth_Contact__c = null;
}

update Waitlistlst;
}catch(exception e){
// No action required as this error is no records for this relations 
} 
*/
        }
        
        // To avoid - 'Duplicate id in list' error assign list to Set then set back to list to be updated
        Set<SObject> updatechildsSet = new Set<SObject>();
        List<SObject> childsListToUpdate = new List<SObject>();
        
        updatechildsSet.addAll(updatechilds);
        childsListToUpdate.addAll(updatechildsSet);
        
        // CRM-593
        Set<SObject> updatechildsSet2 = new Set<SObject>();
        List<SObject> childsListToUpdate2 = new List<SObject>();
        
        updatechildsSet2.addAll(updatechilds2);
        childsListToUpdate2.addAll(updatechildsSet2);
        
        // To avoid the error - "Cannot have more than 10 types in a single save operation. Please reduce number of types in one save operation."
        // This is because when list is updated with multiple object, data type cannot change more than 10 times.
        /*if(updatechilds.size() > 0){
updatechilds.sort();
}*/
        System.debug('vct acct' + vctmacctid);
        MergeResponse  individualresponse = new MergeResponse();
        // CRM-3768 Moved this save point at the top.
        //Savepoint sp = Database.setSavepoint();
        try{
            SkipTriggerExecution = True;
             SkipAssetTrigger.setSkipTrgTrue();
             SkipOrderTrigger.setSkipTrgTrue();
              SkipCaseTrigger.setSkipTrgTrue();
            //update updatechilds;
            if(childsListToUpdate.size() > 0){
                childsListToUpdate.sort();
                update childsListToUpdate;
            }
            if(childsListToUpdate2.size() > 0){
                childsListToUpdate2.sort();               
                update childsListToUpdate2;
            }
            
            // CRM-594 Delete Active Contracts
            if (activeContracts.size() > 0) {
                delete activeContracts.values();    
            }
            // CRM-594 End
            

            /*if(!victimIdsToBeInserted.isEmpty()){
               insert victimIdsToBeInserted;
            }*/
            
            delete vctmacctid;          
            individualresponse.Status = 'Success';
            individualresponse.ErrorMessage = null;
            individualresponse.SurvivorSFDCID = svracctid;
            individualresponse.SurvivorExternalID = MergeIDs.SurvivorExternalID;
            response.add(individualresponse);
        }catch(exception e){
            Database.rollback(sp);            
            individualresponse.Status = 'Error';
            individualresponse.ErrorMessage = e.getMessage();
            individualresponse.SurvivorSFDCID = svracctid;
            individualresponse.SurvivorExternalID = MergeIDs.SurvivorExternalID;                
            response.add(individualresponse);
        }       
        return response;
    }
    
    //Contact Merge logic
    webservice static List<MergeResponse> ContactMerge(MergeInput MergeIDs) {
        List<MergeResponse>  response = new List<MergeResponse>();
        List<Contact> updateSurvivorContact = new List<Contact>();
        set<string> vctmids = new set<string>(); 
        set<id> vctmcntctids = new set<id>();        
        List<SObject> updatechilds = new List<SObject>();
        List<SObject> updatechilds1 = new List<SObject>();
        //Set<SObject> updatechilds = new Set<SObject>();
        for(string vctmloop : MergeIDs.VictimExternalIDs){
            vctmids.add(vctmloop);
        }
        
        Contact survivorContact = [select id,Accountid,Do_Not_Contact__c from Contact where Contact_Party_ID__c = :MergeIDs.SurvivorExternalID];
        id svrcntctid   = survivorContact.id;
        id svrAccountId = survivorContact.Accountid;
            
        /*id svrcntctid = [select id from Contact where Contact_Party_ID__c = :MergeIDs.SurvivorExternalID].id;
        id svrAccountId = [select Accountid from Contact where Contact_Party_ID__c = :MergeIDs.SurvivorExternalID].Accountid; */
        
        list<Contact> vctmcntctid = [select id, Do_Not_Contact__c
                                     ,(select whatId from Tasks)
                                     ,(select whatId from Events)
                                     ,(select ContactId, AccountId from cases)
                                     ,(select ParentId from Attachments)
                                     ,(select Bill_To_Contact__c from Invoice_History__r)
                                     ,(select Contact__c from Leads__r)
                                     ,(select Contact__c from Campaign_History__r)
                                     ,(select Pre_Auth_Contact__c from Waitlists__r)
                                     ,(select id,contact__c from Contact_Methods__r)
                                     ,(select id,contact__c from Engagement_Activities__r)                                    
                                     from Contact where Contact_Party_ID__c in :vctmids];
        //,(select ContactId from Opportunities)
        //,(select Zuora__Account__c from R00N40000001kyLcEAI__r)
        //,(select Party_ID__c from PaymentProfiles__r)
        //,(select AccountId from Orders)
        //,(select Fulfill_To_Account_Id__c from Invoice_Line_Item_History__r)
        //,(select Bill_To_Account__c from Payment_History__r)
        
        for(Contact vctmcntctidlp: vctmcntctid ){
            vctmcntctids.add(vctmcntctidlp.id);
            
            // If the Victim Contact has Do_Not_Contact__c enabled, transfer the value to survivor contact
            if(vctmcntctidlp.Do_Not_Contact__c){
                survivorContact.Do_Not_Contact__c = TRUE;
                updatechilds1.add(survivorContact);
            }
        }
        
        try{
            String CONTACT_RELATIONSHIP_RECORD_TYPE = 'Contact Relationship';
            Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
            
            list<Account_Relationship__c> delConRelationShipRec = new list<Account_Relationship__c>();
            // Get the Account Relationship records for Survior Contact
            list<Account_Relationship__c> ConRelationShipRecSrvr = [select Parent_Account__c, Contact_To__c, Contact_Role__c, Billing_Contact__c from Account_Relationship__c 
                                                                    where Contact_To__c =: svrcntctid and RecordTypeId =: contactRelationshipRecordTypeId];
            // Get the Account Relationship records for Victim Contact
            list<Account_Relationship__c> ConRelationShipRecVctm = [select Parent_Account__c, Contact_To__c, Contact_Role__c, Billing_Contact__c from Account_Relationship__c 
                                                                    where Contact_To__c in : vctmcntctids and RecordTypeId =: contactRelationshipRecordTypeId];
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Contact To" in context with Survivor side Relationship Records
            if(ConRelationShipRecSrvr.size() > 0 && ConRelationShipRecVctm.size() > 0){ 
                for(Integer i = 0; i < ConRelationShipRecSrvr.size(); i++) {
                    for(Integer j = 0; j < ConRelationShipRecVctm.size(); j++) {
                        if(
                            ConRelationShipRecVctm.get(j).Parent_Account__c == ConRelationShipRecSrvr.get(i).Parent_Account__c 
                            // && ConRelationShipRecVctm.get(j).Contact_To__c == ConRelationShipRecSrvr.get(i).Contact_To__c
                        ) {
                            delConRelationShipRec.add(ConRelationShipRecVctm.get(j));
                            // Transfer the 'Primary Contact' and 'Billing Contact' to Survior Contact relationship
                            if(ConRelationShipRecVctm.get(j).Contact_Role__c == 'Primary Contact'){
                                ConRelationShipRecSrvr.get(i).Contact_Role__c = 'Primary Contact';
                                if(ConRelationShipRecVctm.get(j).Billing_Contact__c){
                                    ConRelationShipRecSrvr.get(i).Billing_Contact__c = true;
                                }
                                updatechilds.add(ConRelationShipRecSrvr.get(i));
                            }
                        }
                    }
                }
            }
            
            if(!delConRelationShipRec.isEmpty()){
                delete delConRelationShipRec;
            }
            
            // Get the Account Relationship records for Victim Contact after deleting if any have duplicate "Parent Account" + "Contact To" with Survivor Contact
            ConRelationShipRecVctm = [select Parent_Account__c, Contact_To__c, Contact_Role__c, Billing_Contact__c from Account_Relationship__c 
                                      where Contact_To__c in : vctmcntctids and RecordTypeId =: contactRelationshipRecordTypeId];
            
            // Collect the Account Rel records for deletion at Victim side where it have duplicate "Parent Account" + "Contact To" in context with Victim side Relationship Records itself
            if( ConRelationShipRecVctm.size() > 1 ){ 
                for(Integer i = 0; i < ConRelationShipRecVctm.size()-1; i++) {
                    for(Integer j = i+1; j < ConRelationShipRecVctm.size(); j++) {
                        if( ConRelationShipRecVctm.get(j).Parent_Account__c == ConRelationShipRecVctm.get(i).Parent_Account__c ){
                            delConRelationShipRec.add(ConRelationShipRecVctm.get(j));
                            // Transfer the 'Primary Contact' and 'Billing Contact' to another Contact relationship which is not going to be delete
                            if(ConRelationShipRecVctm.get(j).Contact_Role__c == 'Primary Contact'){
                                ConRelationShipRecVctm.get(i).Contact_Role__c = 'Primary Contact';
                                if(ConRelationShipRecVctm.get(j).Billing_Contact__c){
                                    ConRelationShipRecVctm.get(i).Billing_Contact__c = true;
                                }
                            }
                        }
                    }
                }
            }
            
            // Get the Account Relationship records for Survior Contact after deleting if any have duplicate "Parent Account" + "Contact To" with Survivor Contact
            ConRelationShipRecSrvr = [select Parent_Account__c, Contact_To__c, Contact_Role__c, Billing_Contact__c from Account_Relationship__c 
                                      where Contact_To__c =: svrcntctid and RecordTypeId =: contactRelationshipRecordTypeId];
            
            // Collect the Account Rel records for deletion at Survivor side where it have duplicate "Parent Account" + "Contact To" in context with Survivor side Relationship Records itself
            if( ConRelationShipRecSrvr.size() > 1 ){ 
                for(Integer i = 0; i < ConRelationShipRecSrvr.size()-1; i++) {
                    for(Integer j = i+1; j < ConRelationShipRecSrvr.size(); j++) {
                        if( ConRelationShipRecSrvr.get(j).Parent_Account__c == ConRelationShipRecSrvr.get(i).Parent_Account__c ){
                            delConRelationShipRec.add(ConRelationShipRecSrvr.get(j));
                            // Transfer  the 'Primary Contact' and 'Billing Contact' to another Contact relationship which is not going to be delete
                            if(ConRelationShipRecSrvr.get(j).Contact_Role__c == 'Primary Contact'){
                                ConRelationShipRecSrvr.get(i).Contact_Role__c = 'Primary Contact';
                                if(ConRelationShipRecSrvr.get(j).Billing_Contact__c){
                                    ConRelationShipRecSrvr.get(i).Billing_Contact__c = true;
                                }
                                updatechilds.add(ConRelationShipRecSrvr.get(i));
                            }
                        }
                    }
                }
            }
            
            if(!delConRelationShipRec.isEmpty()){
                delete delConRelationShipRec;
            }
            /*list<Account_Relationship__c> delConRelationShipRec = [select Contact_To__c from Account_Relationship__c 
where Contact_To__c in :vctmcntctids and Parent_Account__c =: svrAccountId];
if(!delConRelationShipRec.isEmpty()){
delete delConRelationShipRec;
}*/
            
            list<Account_Relationship__c> cntctrellst = [select Contact_To__c from Account_Relationship__c 
                                                         where Contact_To__c in :vctmcntctids];
            for(Account_Relationship__c cntctrellstlp : cntctrellst ){
                cntctrellstlp.Contact_To__c = svrcntctid;
                updatechilds.add(cntctrellstlp);
            }
        }catch(exception e){
            // No action required as this error is no records for this relations 
        } 
        //
        for(Contact vctmcntctloop : vctmcntctid){
            //Reparenting  Tasks
            try{
                list<Task>  tasklst = new list<Task>(vctmcntctloop.Tasks);
                for(Task tasklstlp :  tasklst){
                    //tasklstlp.whatId = svrcntctid;
                    tasklstlp.whoId = svrcntctid;
                    updatechilds.add(tasklstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Events
            try{
                list<Event> Eventlst = new list<Event>(vctmcntctloop.Events);
                for(Event Eventlstlp :  Eventlst){
                    //Eventlstlp.whatId = svrcntctid;
                    Eventlstlp.whoId = svrcntctid;
                    updatechilds.add(Eventlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  case
            try{
                list<case> caselst = new list<case>(vctmcntctloop.cases);
                for(case caselstlp :  caselst){
                    //caselstlp.AccountId = svrcntctid;
                    caselstlp.ContactId = svrcntctid;
                    //caselstlp.AccountId = svrAccountId;
                    updatechilds.add(caselstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Attachments
            try{
                list<Attachment> Attachmentlst = new list<Attachment>(vctmcntctloop.Attachments);
                for(Attachment Attachmentlstlp :  Attachmentlst){
                    Attachmentlstlp.ParentId = svrcntctid;
                    updatechilds.add(Attachmentlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Invoice_History__c
            try{
                list<Invoice_History__c> Invoicehistorylst = new list<Invoice_History__c>(vctmcntctloop.Invoice_History__r);
                for(Invoice_History__c Invoicehistorylstlp :  Invoicehistorylst){
                    //Invoicehistorylstlp.Bill_To_Account__c = svrcntctid;
                    Invoicehistorylstlp.Bill_To_Contact__c = svrcntctid;
                    updatechilds.add(Invoicehistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Lead
            try{
                list<Lead> Leadslst = new list<Lead>(vctmcntctloop.Leads__r);
                for(Lead Leadslstlp :  Leadslst){
                    //Leadslstlp.Account__c = svrcntctid;
                    Leadslstlp.Contact__c = svrcntctid;
                    updatechilds.add(Leadslstlp);
                }            
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Campaign_History__c
            try{
                list<Campaign_History__c> Campaignhistorylst = new list<Campaign_History__c>(vctmcntctloop.Campaign_History__r);
                for(Campaign_History__c Campaignhistorylstlp :  Campaignhistorylst){
                    //Campaignhistorylstlp.Account__c = svrcntctid;
                    Campaignhistorylstlp.Contact__c = svrcntctid;
                    updatechilds.add(Campaignhistorylstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting  Waitlist__c
            try{
                list<Waitlist__c> Waitlistlst = new list<Waitlist__c>(vctmcntctloop.Waitlists__r);
                for(Waitlist__c Waitlistlstlp :  Waitlistlst){
                    Waitlistlstlp.Pre_Auth_Contact__c = svrcntctid;
                    updatechilds.add(Waitlistlstlp);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
            
            //Reparenting ContactMethod__c 
            try{
                list<ContactMethod__c> contactMethodList = new list<ContactMethod__c>(vctmcntctloop.Contact_Methods__r);
                for(ContactMethod__c contactmethod :  contactMethodList){
                    contactmethod.contact__c = svrcntctid;
                    updatechilds1.add(contactmethod);
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            } 
                
            //Reparenting Engagement Activites 
            try{
                list<Engagement_Activity__c > engagementActivities = new list<Engagement_Activity__c >(vctmcntctloop.Engagement_Activities__r);
                for(Engagement_Activity__c  activity :  engagementActivities){
                    activity.contact__c = svrcntctid;
                    updatechilds1.add(activity); 
                }
            }catch(exception e){
                // No action required as this error is no records for this relations 
            }               
        }
        
        // To avoid - 'Duplicate id in list' error assign list to Set then set back to list to be updated
        Set<SObject> updatechildsSet = new Set<SObject>();
        List<SObject> childsListToUpdate = new List<SObject>();
        
        updatechildsSet.addAll(updatechilds);
        childsListToUpdate.addAll(updatechildsSet);
        
        Set<SObject> updatechildsSet1 = new Set<SObject>();
        List<SObject> childsListToUpdate1 = new List<SObject>();
        
        updatechildsSet1.addAll(updatechilds1);
        childsListToUpdate1.addAll(updatechildsSet1);
        
        // To avoid the error - "Cannot have more than 10 types in a single save operation. Please reduce number of types in one save operation."
        // This is because when list is updated with multiple object, data type cannot change more than 10 times
        /* if(updatechilds.size() > 0){
updatechilds.sort();
}*/
        
        if(childsListToUpdate.size() > 0){
            childsListToUpdate.sort();
        }
        
        if(childsListToUpdate1.size() > 0){
            childsListToUpdate1.sort();
        }
        //CRM-4981 - Start - Exclucde Portal Users from deletion in merge
        List<Contact>Portalusercontact = new List<Contact>();
        Set<Id>Portaluserids = new set<Id>();
        for(User ur:[select Id,Name,ContactId,contact.firstname,contact.lastname,accountid,FederationIdentifier from user where Profile.Name like '%Community%' and Isportalenabled = True and ContactId IN:vctmcntctids]){
            If(ur.contactId != null)
                Portaluserids.add(ur.ContactId);
                Contact cnt = new Contact(Id = ur.ContactId);
                cnt.FirstName = ur.contact.firstname + ur.contact.lastname+ur.FederationIdentifier;
                cnt.lastname = 'Community';
                cnt.Contact_Party_ID__c = null;
                cnt.Email = null;
                cnt.Phone = null;
                Portalusercontact.add(cnt);
        }
        if(!Portalusercontact.isEmpty() && !Portaluserids.isEmpty()){
        vctmcntctids.removeall(Portaluserids);
        /*try{
        update Portalusercontact;
        }
        Catch(Exception E){
        System.debug('The exception occured while updating the contact tied to Portal User' + E.getmessage());
        }*/
        }
        //CRM-4981 - End- Exclucde Portal Users from deletion in merge
        MergeResponse  individualresponse = new MergeResponse();
        
        try{
            SkipTriggerExecution = True;
             SkipAssetTrigger.setSkipTrgTrue(); 
            //update updatechilds;
            update childsListToUpdate;           
            update childsListToUpdate1; // This update cannot be combined with above because, the above updated list already has 10 diff objects
             update Portalusercontact; 
            delete [select Id from contact where Id IN:vctmcntctids]; //delete vctmcntctid; //CRM-4981 -- Exclucde Portal Users from deletion in merge
            individualresponse.Status = 'Success';
            individualresponse.ErrorMessage = null;
            individualresponse.SurvivorSFDCID = svrcntctid;
            individualresponse.SurvivorExternalID = MergeIDs.SurvivorExternalID;
            response.add(individualresponse);
        }catch(exception e){
            individualresponse.Status = 'Error';
            individualresponse.ErrorMessage = e.getMessage();
            individualresponse.SurvivorSFDCID = svrcntctid;
            individualresponse.SurvivorExternalID = MergeIDs.SurvivorExternalID;                
            response.add(individualresponse);
        }
        
        return response;
    }    
    
    //Contact Method logic
    webservice static List<MergeResponse> ContactMethodMerge(List<MergeInput> MergeObjectList) {              
        List<MergeResponse> response = new List<MergeResponse>();
        Set<string> vctmids;
        List<SObject> updateRecords;
        List<SObject> deleteDuplicates;        
        Set<SObject> updatechildsSet;
        Set<SObject> deleteRecordSet;        
        List<SObject> childsListToUpdate = new List<SObject>();
        List<SObject> childsListToDelete = new List<SObject>();
        List<MergeHistory__c> victimIdToSurvivorIdHistory = new List<MergeHistory__c>();
        Map<String,String> survivorIdToExternalIdMap = new Map<String,String>();
        List<ContactMethod__c> deleteContactMethods = new List<ContactMethod__c>();  
        Map<String,String> accountContactContactMethodMap = new Map<String,String>();
        Boolean isDuplicateCMBouncedBack = FALSE;
        
        for(MergeInput MergeIDs: MergeObjectList){
            String survivorCMId;
            vctmids = new set<string>();           
            updatechildsSet = new Set<SObject>();
            deleteRecordSet = new Set<SObject>();
            updateRecords = new List<SObject>();
            deleteDuplicates = new List<SObject>();
            
            for(string vctmloop : MergeIDs.VictimExternalIDs){
                vctmids.add(vctmloop);
            }
            
            vctmids.add(MergeIDs.SurvivorExternalID);            
            Map<Id,ContactMethod__c> contactMethodMap = new Map<Id,ContactMethod__c>([Select id,Contact__c, Type__c, External_ID__c, Bounce_Back_Email__c,
                                                                                      (Select id,Contact_Method__c, Activity_Date__c from Engagement_Activities__r),
                                                                                      (Select id,Contact_Method__c,name from Leads__r) from ContactMethod__c where External_ID__c IN: vctmids]);
            for(ContactMethod__c cm: contactMethodMap.values()){
                if(cm.External_ID__c != MergeIDs.SurvivorExternalID){
                    deleteDuplicates.add(cm);                   
                }else{
                    survivorCMId = cm.Id;
                    survivorIdToExternalIdMap.put(cm.Id,cm.External_ID__c);
                }         
            }      
            
            for(ContactMethod__c cm: contactMethodMap.values()){
                if(cm.External_ID__c != MergeIDs.SurvivorExternalID){
                   // If the Victim CM has Bounce Back Enabled, transfer the value to Survivor 
                    if(cm.Bounce_Back_Email__c){
                        contactMethodMap.get(survivorCMId).Bounce_Back_Email__c = TRUE;
                        updateRecords.add(contactMethodMap.get(survivorCMId));
                    }
                    // create an entry in Merge History Table for Victim CM's 
                     victimIdToSurvivorIdHistory.add(new MergeHistory__c(Survivor_Id__c = survivorCMId,Victim_Id__c = cm.Id, Object_Name__c = 'ContactMethod__c'));
                    
                   // Re-assign the Engagement Activity related to Vicitim CM's to Survivior CM
                    if(!cm.Engagement_Activities__r.isEmpty()){
                       for(Engagement_Activity__c engActivity: cm.Engagement_Activities__r){
                         engActivity.Contact_Method__c = survivorCMId; 
                         updateRecords.add(engActivity); 
                       } 
                    }                         
                   // Code to assign Leads related to Victim CM's to Survivor CM
                    if(!cm.Leads__r.isEmpty()){
                        for(lead lrec: cm.Leads__r){
                            lrec.Contact_Method__c = survivorCMId;
                            updateRecords.add(lrec);
                        }
                    }
                }
            }                                      
            
            updatechildsSet.addAll(updateRecords); 
            childsListToUpdate.addAll(updatechildsSet);                        
            
            deleteRecordSet.addAll(deleteDuplicates);
            childsListToDelete.addAll(deleteRecordSet);           
        }
        
        if(childsListToUpdate.size() > 0){
            childsListToUpdate.sort();
        }
        
        if(childsListToDelete.size() > 0){
            childsListToDelete.sort();
        }
        
        try{
            update childsListToUpdate;
            delete childsListToDelete;
            upsert victimIdToSurvivorIdHistory;

            for(String survr: survivorIdToExternalIdMap.KeySet()){
                MergeResponse  successresponse = new MergeResponse();
                successresponse.Status = 'Success';
                successresponse.ErrorMessage = null;
                successresponse.SurvivorSFDCID = survr;
                successresponse.SurvivorExternalID = survivorIdToExternalIdMap.get(survr);
                response.add(successresponse);                
            }    
        }catch(exception e){
            for(String survr: survivorIdToExternalIdMap.KeySet()){ 
                MergeResponse  errorresponse = new MergeResponse();
                errorresponse.Status = 'Error';
                errorresponse.ErrorMessage = e.getMessage(); 
                errorresponse.SurvivorSFDCID = survr;
                errorresponse.SurvivorExternalID = survivorIdToExternalIdMap.get(survr);  
                response.add(errorresponse);
            }
        }
        return response;
    }
}