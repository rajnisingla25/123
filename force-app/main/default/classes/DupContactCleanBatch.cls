//History: CRM-4048: Added batch execution in Finish method.

global class DupContactCleanBatch implements Database.Batchable<sObject>, Schedulable {
    
    DuplicateContactBatch__c dcb = DuplicateContactBatch__c.getValues('DupContactCleanBatch');
    List<String> skipRecordTypes = dcb.Skip_Record_Types__c.split(',');    // CRM-3919 - Fetch to skip record types
    
    public void execute(SchedulableContext sc) {
        Integer bsize = Integer.valueof(dcb.Batch_Size__c);
        Database.executeBatch(new DupContactCleanBatch(), bsize);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> badEmailSet = new Set<String>();
        badEmailSet.AddAll(dcb.Bad_Email__c.split(','));
        return Database.getQueryLocator([   SELECT  Email
                                            FROM    Contact 
                                            WHERE   Email != null 
                                                    AND 
                                                    BAD_Email__c IN : badEmailSet
                                                    AND 
                                                    //RecordType.Name != 'Consumer' // CRM-3919-Commented this line and added below condition to skip consumer and moving contacts
                                                    RecordType.Name NOT IN :skipRecordTypes
                                                    AND
                                                    Contact_Party_ID__c != null
                                            Order By Email      
                                            ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactsInScope) {
       try{
           set<string> uniqueEmailIds = new set<String>();
           list<Contact> contactToUpdate = new list<Contact>();
           map<string,list<Contact>> emailToContactList = new map<string,list<Contact>>();
           
           // Weight is used to decide winner and looser contact; Contact with lesser weight will win
          //Based on priority (Accoun type) assigning starting number  
          integer customerBrokerWeight        = 100000000;          
          integer customerAgentWeight         = 200000000;
          integer formerCustomerBrokerWeight  = 300000000;
          integer formerCustomerAgentWeight   = 400000000;
          integer prospectBrokerWeight        = 500000000;
          integer prospectAgentWeight         = 600000000;
          integer randomWeight                = 700000000;
          integer narcustomerBrokerWeight     = 100000;
          integer narcustomerAgentWeight      = 100000;
          integer narformerBrokerWeight       = 100000;
          integer narformerAgentWeight        = 100000;
          integer narprospectBrokerWeight     = 100000;
          integer narprospectAgentWeight      = 100000;
          integer narrandomWeight             = 100000;
          
          //CRM-2147 Give less priority to Billing Contact over Primary Contact
          integer billingContactWeight = 1000;
          
          map<Id,Account_Relationship__c> contactIdToAccountRel = new map<Id,Account_Relationship__c>();
          map<Integer,Id> rankToContactId = new map<Integer,Id>();
          map<string,list<Integer>> emailToOrderedRank = new  map<string,list<Integer>>();
          DuplicateContactBatch__c dcb = DuplicateContactBatch__c.getValues('DupContactCleanBatch');
           
           //Getting all unique email ids
           for( Contact con : contactsInScope){
                    uniqueEmailIds.add( con.Email );
           }
           set<id> avoidDupContactIds = new set<Id>();
           //Fetch all the contacts which has emails in uniqueEmailIds set and create a map of email to contacts
           for( Account_Relationship__c accRel : [ select   Contact_To__r.Id,
                                                            Contact_To__r.Email,
                                                            Contact_To__r.Contact_Party_ID__c,
                                                            Contact_To__r.Process_Flag__c,
                                                            Contact_To__r.Reference_Winner_Id__c,
                                                            Contact_To__r.BAD_Email__c,
                                                            Contact_To__r.NAR_ID__c,
                                                            Parent_Account__r.Account_Sub_Type__c,
                                                            Parent_Account__r.Type,
                                                            Active__c, Billing_Contact__c,Contact_Role__c
                                                    from    Account_Relationship__c 
                                                    where   
                                                            RecordType.DeveloperName                = 'Contact_Relationship'
                                                            AND
                                                            //Contact_To__r.RecordType.DeveloperName  != 'Consumer' // CRM-3919-Commented this line and added below condition to skip consumer and moving contacts
                                                            Contact_To__r.RecordType.Name NOT IN    :skipRecordTypes
                                                            AND
                                                            Contact_To__r.Email In                  :uniqueEmailIds
                                                            AND
                                                            Contact_To__r.BAD_Email__c              != :dcb.Bad_Contact_Email__c
                                                            AND
                                                            Contact_To__r.Contact_Party_ID__c       != null
                                                            AND
                                                            Parent_Account__c                       != null
                                                    order BY CreatedDate
                                                    limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()   ]){
                                            
                if( avoidDupContactIds.add( accRel.Contact_To__r.Id ) ){
                    
                    if( !emailToContactList.containsKey( accRel.Contact_To__r.email ) ){
                        emailToContactList.put( accRel.Contact_To__r.email, new list<Contact>());
                    }
                    
                    emailToContactList.get(accRel.Contact_To__r.email).add( new Contact(  Id                        = accRel.Contact_To__r.Id,
                                                                                          Email                     = accRel.Contact_To__r.Email,
                                                                                          Contact_Party_ID__c       = accRel.Contact_To__r.Contact_Party_ID__c,
                                                                                          Process_Flag__c           = accRel.Contact_To__r.Process_Flag__c,
                                                                                          Reference_Winner_Id__c    = accRel.Contact_To__r.Reference_Winner_Id__c,
                                                                                          BAD_Email__c              = accRel.Contact_To__r.BAD_Email__c));
                                                                                      
                    // Query will retrun old contact record first and then newer 1
                    //assigining rank to contacts based on account type
                    
                    integer rank = 0;
                    
                    if( accRel.Parent_Account__r.Type == 'Broker' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Customer' && 
                        accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = customerBrokerWeight;
                        customerBrokerWeight          += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narcustomerBrokerWeight;
                            narcustomerBrokerWeight        += 100000;
                        }
                        
                    }else if( accRel.Parent_Account__r.Type == 'Realtor Agent' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Customer' &&
                              accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = customerAgentWeight;
                        customerAgentWeight           += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narcustomerAgentWeight;
                            narcustomerAgentWeight        += 100000;
                        }
                        
                    }else if( accRel.Parent_Account__r.Type == 'Broker' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Former Customer' &&
                              accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = formerCustomerBrokerWeight;
                        formerCustomerBrokerWeight    += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narformerBrokerWeight;
                            narformerBrokerWeight        += 100000;
                        }
                        
                    }else if( accRel.Parent_Account__r.Type == 'Realtor Agent' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Former Customer' &&
                              accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = formerCustomerAgentWeight;
                        formerCustomerAgentWeight     += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narformerAgentWeight;
                            narformerAgentWeight        += 100000;
                        }
                        
                    }else if( accRel.Parent_Account__r.Type == 'Broker' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Prospect' &&
                              accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = prospectBrokerWeight;
                        prospectBrokerWeight          += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narprospectBrokerWeight;
                            narprospectBrokerWeight        += 100000;
                        }
                        
                    }else if( accRel.Parent_Account__r.Type == 'Realtor Agent' && accRel.Parent_Account__r.Account_Sub_Type__c == 'Prospect' &&
                              accRel.Active__c == True && ( accRel.Billing_Contact__c == True || accRel.Contact_Role__c == 'Primary Contact' )){
                        rank                          = prospectAgentWeight;
                        prospectAgentWeight           += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narprospectAgentWeight;
                            narprospectAgentWeight        += 100000;
                        }
                        
                    }else {
                        rank                          = randomWeight;
                        randomWeight                  += 1;
                        if(accRel.Contact_To__r.NAR_ID__c != null) {
                            rank                           += narrandomWeight;
                            narrandomWeight        += 100000;
                        }                        
                    }
                    
                    //CRM-2147 Give less priority to Billing Contact over Primary Contact
                    if (accRel.Billing_Contact__c == True && accRel.Contact_Role__c != 'Primary Contact') {
                        rank                        += billingContactWeight;
                        billingContactWeight        += 1;
                    }
                    // CRM-2147 End
                    
                    if( !emailToOrderedRank.containsKey( accRel.Contact_To__r.Email) ){
                        emailToOrderedRank.put( accRel.Contact_To__r.Email, new list<integer>());
                    }
                    
                    rankToContactId.put( rank,accRel.Contact_To__r.Id );
                    emailToOrderedRank.get( accRel.Contact_To__r.Email ).add( rank );
                }
           }
           
            
            for( string email: emailToOrderedRank.keySet() ){
                emailToOrderedRank.get( email ).sort();
            }
        
            string winnerContactId;
            list<Contact> contactListToUpdate = new list<Contact>();  
            
            if( !emailToContactList.isEmpty() ){
                for( String email : emailToContactList.keySet() ){
                        
                    if( emailToContactList.get(email).size() == 1 ){
                        emailToContactList.get(email)[0].Process_Flag__c = true;
                        emailToContactList.get(email)[0].BAD_Email__c = 'No';
                    }else{ 
                        if( emailToContactList.get(email).size() > 1 ){
                            
                            system.debug(' -----emailToOrderedRank----'+emailToOrderedRank);
                            system.debug(' -----rankToContactId----'+rankToContactId);
                            system.debug(' -----emailToOrderedRank.get( email )[0]----'+emailToOrderedRank.get( email )[0]);
                            
                            if( !emailToOrderedRank.isEmpty()  && emailToOrderedRank.get( email ).size() > 0 ){
                                winnerContactId = rankToContactId.get(emailToOrderedRank.get( email )[0]);
                                
                                for( Contact con : emailToContactList.get(email)){
                                    
                                    if( ID.valueOf( con.Id ) != ID.valueOf( winnerContactId ) ){
                                        con.Process_Flag__c = true;
                                        con.Email = 'Bad_' + con.Contact_Party_ID__c + '_' + con.Email;
                                        con.BAD_Email__c = 'BAD Email';
                                        con.Reference_Winner_Id__c = winnerContactId;
                                    }else{
                                        con.Process_Flag__c = true;
                                        con.BAD_Email__c = 'No';
                                        con.Reference_Winner_Id__c = null;
                                    }
                                }
                            }
                        }//End If
                    }
                    contactListToUpdate.addAll( emailToContactList.get(email) );    
                }//End For
            }// End If 
        
            update contactListToUpdate ;
            
        }catch( Exception e){
            system.debug( '******Exception in DupContactCleanBatch******'+e.getStackTraceString());
        }
     }//End Execute
     
    global void finish(Database.BatchableContext BC){
        //CRM-4048: Added batch execution.
        Set<String> setStatus = new Set<String>{'Converted','Rejected'};
        Set<String> setMarketType = new Set<String>{'Event','Auto-Renew','Outbound Call Leads','Opcity'};
        List <Lead> lstLead = [SELECT Name,Id, Status, Rejected_Reason__c  FROM Lead WHERE Marketing_Lead_Type__c != :setMarketType and status!= :setStatus and Can_be_Rejected__c = True];
        if(!lstLead.isEmpty()){
            LeadRejectionBatch ldBatch = new LeadRejectionBatch();
            database.executebatch(ldBatch, 100);
        }
     }
}