// CRM-1787

global class UpdatePrivateContactsAccountBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, AccountId, (SELECT Parent_Account__c, Active__c FROM Contact__r WHERE Parent_Account__c != '' ORDER BY CreatedDate DESC) 
                                        FROM Contact WHERE AccountId = '' AND ID IN (SELECT Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c != '') AND Owner.IsActive=true LIMIT 100]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        system.debug(scope);
        for(Contact con : scope) {
            if (con.Contact__r.size() > 0) {
                for (Account_Relationship__c rel : con.Contact__r) {
                    if (rel.Active__c) {
                        con.AccountId = rel.Parent_Account__c;
                        break;
                    }
                }
                if (con.AccountId == null) {
                    con.AccountId = con.Contact__r[0].Parent_Account__c;
                }
            }
        }
        update scope;                                                   
    }
    
    global void finish(Database.BatchableContext BC){
    }
}