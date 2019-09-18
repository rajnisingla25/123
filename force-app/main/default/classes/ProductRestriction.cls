global without sharing class ProductRestriction {
    private static Id ACCOUNT_REL_RECORD_TYPE_ID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId; 
    webservice static Boolean hasProductRestriction(String agentAccountId) {
       Set<Id> officeIds = new Set<Id>();
       for (Account_Relationship__c rel :[SELECT Parent_Account__c FROM Account_Relationship__c WHERE Child_Account__c=:agentAccountId AND 
                                          active__c=true and RecordTypeId=:ACCOUNT_REL_RECORD_TYPE_ID AND Child_Account__r.type='Realtor Agent' 
                                          AND Parent_Account__r.type='Realtor Office']) {
          officeIds.add(rel.Parent_Account__c);
       }
       
       Integer count = [SELECT count() FROM Asset WHERE Status = 'Active' AND Asset_Type__c = 'Fulfill To' AND Product_code__c = 'ADVANTAGE' 
       AND Parent_Asset__r.ConfigOptions__c EXCLUDES('withoutAgents') AND PRODUCT_TYPE__C = 'Pro' AND AccountId IN :officeIds];    
       if (count > 0) {
           return true;
       }
       return false;
    }
}