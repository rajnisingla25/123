@isTest
private class BatchProcessFindAccount_Test {
    static testMethod void method1(){
        
        Account theAccount1 = TestDataFactory.createAccount('ABCCORP', null, false);
        theAccount1.Primary_Email__c = 'theAccount@move.com';  
        insert theAccount1;
        
        
         Account theAccount2 = TestDataFactory.createAccount('ABCCORPU', null, false);
        theAccount2.Primary_Email__c = 'theAccount@move.com';  
        insert theAccount2;
        Account theAccount3 = TestDataFactory.createAccount('ABCCORPUJ', null, false);
        theAccount3.Primary_Email__c = 'theAccount@move.com';  
        insert theAccount3;
        
        Account_Search__c theCase = new Account_Search__c(
            Name = 'ABCCORP',
            Id__c = '4564',
            Phone__c = '123',
            
            State__c = 'State');
            insert theCase;
        //Test.setCreatedDate(theCase.Id, DateTime.now().addHours(-2));
        
         Id [] fixedSearchResults = new Id[]{theAccount1.Id,theAccount3.Id,theAccount2.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
        
        BatchProcessFindAccount sh1 = new BatchProcessFindAccount();  
        sh1.query = 'SELECT Id,Name,State__c,Phone__c,Result__c FROM Account_Search__c';  
        database.executebatch(sh1, 5);  
        
        Test.stopTest();
    }
}