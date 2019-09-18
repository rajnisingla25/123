@isTest
private class BatchZouraAccountBalance_Test{
    static testMethod void method1(){
    Account newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '1234567890';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890';
        newAccount.Work_Phone__c = '1234567890';
        newAccount.Mobile1__c = '1234567890';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';   
        newAccount.EssentialsStatus__c = 'Activated';        
        insert newAccount;
        
        Zuora__CustomerAccount__c zca = new Zuora__CustomerAccount__c();
        zca.Zuora__Account__c = newAccount.id;
        zca.Zuora__Balance__c = 30;
        insert zca;
        test.startTest();
            BatchZouraAccountBalance sh1 = new BatchZouraAccountBalance();    
            database.executebatch(sh1,25);  
            
        Test.stopTest();
    }
}