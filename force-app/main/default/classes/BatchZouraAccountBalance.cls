global class BatchZouraAccountBalance implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    DateTime dt = System.now().addDays(5);
        Query = 'SELECT Id,Zuora__Account__c,Zuora__Balance__c FROM Zuora__CustomerAccount__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Zuora__CustomerAccount__c> scope){
    DateTime dt = System.now();
       List< Account_Balance__c > AccountList = new List< Account_Balance__c >();
       for(Zuora__CustomerAccount__c acc : scope){
           Account_Balance__c ab = new Account_Balance__c();
           ab.Account__c = acc.Zuora__Account__c;
           if(dt.month()>9){ab.BalanceMonthYear__c = dt.month()+''+dt.year();}
           if(dt.month()<10){ab.BalanceMonthYear__c = '0'+dt.month()+''+dt.year();}
           ab.Total_Balance__c = acc.Zuora__Balance__c;
           AccountList.add(ab);
       }
       insert AccountList ;
    }

    global void finish(Database.BatchableContext BC){
    }
}