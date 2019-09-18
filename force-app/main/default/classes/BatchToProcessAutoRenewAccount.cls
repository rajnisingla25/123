global class BatchToProcessAutoRenewAccount implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    DateTime dt = System.now();
    String status = 'Active';
    Set<String> notAccountType = new Set<String>{'MLS Account','Realtor Office'};
        Query = 'SELECT Id , Auto_Renewal__c FROM Account where Status__c=:status and Type!=:notAccountType';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<account> scope){
       List<Account> AccountList = new List<Account>();
       for(account acc : scope){
           acc.Auto_Renewal__c = true;
           AccountList.add(acc);
       }
       update AccountList ;
    }

    global void finish(Database.BatchableContext BC){
    }
}