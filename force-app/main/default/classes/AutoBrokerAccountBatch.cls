global class AutoBrokerAccountBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT MLS_Brokerage_Id__c FROM Account WHERE Account_Sub_Type__c = 'Prospect' AND Type = 'Realtor Office' AND Parent_Broker__c = null AND MLS_Brokerage_Id__c != null]);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('RAO scope :'+scope);
        Set<String> BrokerageIds = new Set<String>();
        for(Account a : scope){
            BrokerageIds.add(a.MLS_Brokerage_Id__c);            
        }
        if(!BrokerageIds.isEmpty()){
            for(String sbrokerageId : BrokerageIds){
                try{
                integer BIdCustCount = [Select count() FROM Account WHERE Account_Sub_Type__c = 'Customer' AND Type = 'Realtor Office' AND Parent_Broker__c != null AND MLS_Brokerage_Id__c = :sbrokerageId];
                System.debug('RAO iiii :' + BIdCustCount);
                if (BIdCustCount == 1) {
                    String sParentAccId = [Select Parent_Broker__c FROM Account WHERE Account_Sub_Type__c = 'Customer' AND Type = 'Realtor Office' AND MLS_Brokerage_Id__c = :sbrokerageId LIMIT 1].Parent_Broker__c;                
                    map<ID,Account> oAccountBIdOffMap = new map<Id,Account>([select Id FROM Account WHERE Account_Sub_Type__c = 'Prospect' AND Type = 'Realtor Office' AND Parent_Broker__c = null AND MLS_Brokerage_Id__c = :sbrokerageId]);                   
                    for(String oAccountBIdOffId : oAccountBIdOffMap.keySet()){
                        Account_Relationship__c newBrokerRel = new Account_Relationship__c (Child_Account__c=oAccountBIdOffId , Is_Parent_Primary__c=true, Is_Sent_to_CDH__c=false, Parent_Account__c=sParentAccId, Relationship_Type__c='Parent/Child', Active__c=true);
                        insert newBrokerRel;
                        Account offaccountToUpdate = [SELECT Parent_Broker__c FROM Account WHERE Id= :oAccountBIdOffId LIMIT 1];
                        offaccountToUpdate.Parent_Broker__c = sParentAccId;
                        update offaccountToUpdate;
                        System.debug('RAO oAccountBIdOffId :' + oAccountBIdOffId);
                    }
                    System.debug('RAO oAccountBIdOffMap :' + oAccountBIdOffMap);
                    System.debug('RAO ParentBroker :' + sParentAccId);
                } else if (BIdCustCount == 0){
                    String sHighestHLCAccId = [Select Id FROM Account WHERE Account_Sub_Type__c = 'Prospect' AND Type = 'Realtor Office' AND Parent_Broker__c = null AND MLS_Brokerage_Id__c = :sbrokerageId order by Primary_HLC__c desc LIMIT 1].Id;              
                    String id1 = 'id =\'' + sHighestHLCAccId + '\'';
                    String soql = Utils.getCreatableFieldsSOQL('Account', id1 );
                    Account ac1 = (Account)Database.query(soql);
                    system.debug(' **** ac1 **** '+ac1);
                    Account ac2 = ac1.clone(false, true);
                    ac2.Name = ac1.Name + '-Broker';
                    ac2.Type = 'Broker';
                    ac2.Party_ID__c=ac2.Customer_Id__c=ac2.Broker_NAR_Id__c=ac2.Account_NAR_Id__c=ac2.MLS_Set_Id__c=ac2.Ship_To_External_Id__c=ac2.Bill_To_External_Id__c=ac2.website_row_id__c=ac2.Fax_Row_Id__c = '';  
                    ac2.MLS_Brokerage_Id__c= ac1.MLS_Set_Id__c;
                    insert ac2;
                    system.debug(' **** ac1 **** '+ac1);
                    system.debug(' **** ac2 **** '+ac2);
                    String Response;
                    if(!Test.isRunningTest()){
                     Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(ac2.Id, 'Account');   
                    }
                    
                    ac1.Parent_Broker__c = ac2.Id;
                    update ac1;
                    List<Account_Relationship__c> AccRelationships = [Select Active__c, Child_Account__c, Contact_Role__c,Is_Parent_Primary__c,Relationship_Type__c, Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c =:ac1.Id AND Relationship_Type__c = 'Contact'];
                    system.debug('Contact relations: ' + AccRelationships);
                    Id RecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Account Relationship').getRecordTypeId();
                    Id ContactRecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Contact Relationship').getRecordTypeId();
                    for(Account_Relationship__c AR : AccRelationships){
                        Account_Relationship__c newBrokerRel = new Account_Relationship__c (Contact_To__c=AR.Contact_To__c,Contact_Role__c=AR.Contact_Role__c,Is_Parent_Primary__c=AR.Is_Parent_Primary__c, Is_Sent_to_CDH__c=false, Parent_Account__c=ac2.Id, Relationship_Type__c='Contact', Active__c=AR.Active__c, RecordTypeId=ContactRecordTypeId);
                        insert newBrokerRel;          
                    }    
                    String sParent1AccId = ac2.Id;
                    Account_Relationship__c newBrokerRel = new Account_Relationship__c (Child_Account__c=ac1.Id,Is_Parent_Primary__c=true, Is_Sent_to_CDH__c=false, Parent_Account__c=ac2.Id, Relationship_Type__c='Parent/Child', Active__c=true);
                    insert newBrokerRel;
                    map<ID,Account> oAccountOffMap = new map<Id,Account>([select Id FROM Account WHERE Account_Sub_Type__c = 'Prospect' AND Type = 'Realtor Office' AND Parent_Broker__c = null AND MLS_Brokerage_Id__c = :sbrokerageId]);                   
                    for(String oAccountOffId : oAccountOffMap.keySet()){
                        Account_Relationship__c new1BrokerRel = new Account_Relationship__c (Child_Account__c=oAccountOffId , Is_Parent_Primary__c=true, Is_Sent_to_CDH__c=false, Parent_Account__c=sParent1AccId, Relationship_Type__c='Parent/Child', Active__c=true);
                        insert new1BrokerRel;
                        Account offaccountToUpdate = [SELECT Parent_Broker__c FROM Account WHERE Id= :oAccountOffId LIMIT 1];
                        offaccountToUpdate.Parent_Broker__c = sParent1AccId;
                        update offaccountToUpdate;
                        System.debug('RAO New broker :' + sParent1AccId);
                    }                   
                    System.debug('RAO iiii :' + BIdCustCount);
                    System.debug('RAO iiii sHighestHLCAccId:' + sHighestHLCAccId);
                }
            }catch(Exception e) {
                }    
            }
            System.debug('RAO BrokerageIds :'+BrokerageIds);
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}