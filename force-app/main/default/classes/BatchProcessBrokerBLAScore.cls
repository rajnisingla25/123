global class BatchProcessBrokerBLAScore implements Database.Batchable<sObject>{
global String query;
global Set<Id> QuoteId = new Set<Id>();
global Set<Id> setBMQIds;
global Set<Id> setIds = new Set<Id>();
global Set<Id> theOrderIdsToProcess = new Set<Id>(); 
    global Database.querylocator start(Database.BatchableContext BC){
        
        if(setIds.size()>0){
        Query = 'SELECT   Id,Name,BLA_score__c,Total_office_BLA_score__c FROM Account where Id=:setIds';
        } else {
        Query = 'SELECT   Id,Name,BLA_score__c,Total_office_BLA_score__c FROM Account where Type=\'Broker\'';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setCaseIds = new Set<Id>();
        Set<Id> setAssetIds = new Set<Id>();
        Set<Id> setLeadIds = new Set<Id>();
        map<Id,Id> mapAccountParentRelationship = new map<Id,Id>();
        map<Id,Id> mapAccountRelationship = new map<Id,Id>();
        map<Id,Account> mapAccount = new map<Id,Account>();
        for(Account acc:scope){
        setAccountIds.add(acc.id);
        }
        for(Account_Relationship__c offct:[Select Id,Name,Parent_Account__c,Child_Account__c from Account_Relationship__c where Parent_Account__c=:setAccountIds and active__c=true]){
        mapAccountRelationship.put(offct.Child_Account__c,offct.Parent_Account__c);
        }
        
        for(Account acct: [Select Id, BLA_score__c, Total_office_BLA_score__c ,name,Green__c,Opcity_Score_Date_Time__c,Yellow_Score__c,Red_Score__c from Account where Id =:mapAccountRelationship.values()]){
        acct.Total_office_BLA_score__c = 0;
       
        mapAccount.put(acct.Id,acct);
        }
        
       
        for(Account acct: [Select Id,name,Green__c,Yellow_Score__c,Red_Score__c,Total_office_BLA_score__c,BLA_score__c from Account where Id =:mapAccountRelationship.keyset()]){
        if(mapAccountRelationship.get(acct.id)!=null){
        if(mapAccount.containskey(mapAccountRelationship.get(acct.id))){
       // mapAccount.get(mapAccountRelationship.get(acct.id)).Opcity_Score_Date_Time__c = null;
        System.debug(acct.Total_office_BLA_score__c+'KKKK');
        mapAccount.get(mapAccountRelationship.get(acct.id)).Total_office_BLA_score__c = mapAccount.get(mapAccountRelationship.get(acct.id)).Total_office_BLA_score__c+(acct.BLA_score__c != null ? acct.BLA_score__c : 0);
               }
        }
        }
        
       
        
       update mapAccount.values();
    }

    global void finish(Database.BatchableContext BC){
   
    
    }
}