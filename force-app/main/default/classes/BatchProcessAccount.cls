global class BatchProcessAccount implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    DateTime dt = System.now();
        Query = 'SELECT   Account_Sub_Type__c,Sales_lock_Date__c,Lock_Expiration_Date__c,Sales_Lock_User__c FROM Account WHERE Sales_lock_Date__c <= :dt order by Sales_lock_Date__c ASC limit 25';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<account> scope){
       List<Account> AccountList = new List<Account>();
       for(account acc : scope){
           acc.Lock_Expiration_Date__c = null;
           acc.Sales_Lock_User__c = null;
           acc.Sales_lock_Date__c = null;
           AccountList.add(acc);
       }
       update AccountList ;
    }

    global void finish(Database.BatchableContext BC){
    }
}