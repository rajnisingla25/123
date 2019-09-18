global class BatchProcessOfficeScore implements Database.Batchable<sObject>{
global String query;
global Set<Id> QuoteId = new Set<Id>();
global Set<Id> setBMQIds;
global Set<Id> setIds;
global Set<Id> theOrderIdsToProcess = new Set<Id>(); 
    global Database.querylocator start(Database.BatchableContext BC){
        
        Query = 'SELECT   Id,Name FROM Account where Id=:setIds';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Id> setAccountIds = new Set<Id>();
        map<Id,Id> mapAccountParentRelationship = new map<Id,Id>();
        map<Id,Id> mapAccountRelationship = new map<Id,Id>();
        map<Id,Account> mapAccount = new map<Id,Account>();
        for(Account acc:scope){
        setAccountIds.add(acc.id);
        }
        for(Account_Relationship__c offct:[Select Id,Name,Parent_Account__c,Child_Account__c from Account_Relationship__c where Parent_Account__c=:setAccountIds]){
        mapAccountRelationship.put(offct.Child_Account__c,offct.Parent_Account__c);
        }
        
        for(Account_Relationship__c offct:[Select Id,Name,Parent_Account__c,Child_Account__c from Account_Relationship__c where Child_Account__c=:setAccountIds and Active__c = true]){
        mapAccountParentRelationship.put(offct.Child_Account__c,offct.Parent_Account__c);
        }
        
        for(Account acct: [Select Id,name,Green__c,Opcity_Score_Date_Time__c,Yellow_Score__c,Red_Score__c from Account where Id =:mapAccountRelationship.values()]){
        acct.Green__c = 0;
        acct.Yellow_Score__c = 0;
        acct.Red_Score__c = 0;
        mapAccount.put(acct.Id,acct);
        }
        
        for(Account acct: [Select Id,name,Green__c,Opcity_Score_Date_Time__c,Yellow_Score__c,Red_Score__c from Account where Id =:mapAccountParentRelationship.values()]){
        //acct.Green__c = 0;
        //acct.Yellow_Score__c = 0;
        //acct.Red_Score__c = 0;
        mapAccount.put(acct.Id,acct);
        }
        for(Account acct: [Select Id,name,Green__c,Yellow_Score__c,Red_Score__c from Account where Id =:mapAccountRelationship.keyset()]){
        if(mapAccountRelationship.get(acct.id)!=null){
        if(mapAccount.containskey(mapAccountRelationship.get(acct.id))){
        mapAccount.get(mapAccountRelationship.get(acct.id)).Opcity_Score_Date_Time__c = null;
        System.debug(acct.Green__c+'KKKK'+acct.Red_Score__c+''+acct.Yellow_Score__c+'PPPP'+mapAccount.get(mapAccountRelationship.get(acct.id)));
        mapAccount.get(mapAccountRelationship.get(acct.id)).Green__c = mapAccount.get(mapAccountRelationship.get(acct.id)).Green__c+(acct.Green__c != null ? acct.Green__c : 0);
        mapAccount.get(mapAccountRelationship.get(acct.id)).Yellow_Score__c = mapAccount.get(mapAccountRelationship.get(acct.id)).Yellow_Score__c+(acct.Yellow_Score__c != null ? acct.Yellow_Score__c : 0);
        mapAccount.get(mapAccountRelationship.get(acct.id)).Red_Score__c = mapAccount.get(mapAccountRelationship.get(acct.id)).Red_Score__c+(acct.Red_Score__c != null ? acct.Red_Score__c : 0);
        }
        }
        }
        
        for(Account acct: [Select Id,name,Green__c,Yellow_Score__c,Red_Score__c from Account where Id =:mapAccountParentRelationship.keyset()]){
        if(mapAccountParentRelationship.get(acct.id)!=null){
        if(mapAccount.containskey(mapAccountParentRelationship.get(acct.id))){
        mapAccount.get(mapAccountParentRelationship.get(acct.id)).Opcity_Score_Date_Time__c = System.now();
        }
        }
        }
        
       update mapAccount.values();
    }

    global void finish(Database.BatchableContext BC){
   
   
    }
}