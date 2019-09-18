@isTest
private class AccountStructure_Test {
    static testMethod void method1(){
        AccountStructure accStr = new AccountStructure();
        boolean isInsert = true;
        boolean isUpdate = true;
        boolean isDelete = true;
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.ShippingState  = 'CA';
            testAccount.ShippingCountry  = 'USA';
            testAccount.Party_ID__c = '11158132';
            testAccount.ShippingPostalCode = '28546';
        insert testAccount;
        accStr.setcurrentId(testAccount.id);
        accStr.getObjectStructure();
        
    }
    static testMethod void method2(){
        AccountStructure accStr = new AccountStructure();
        boolean isInsert = true;
        boolean isUpdate = true;
        boolean isDelete = true;
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.ShippingState  = 'CA';
            testAccount.ShippingCountry  = 'USA';
            testAccount.Party_ID__c = '11158132';
            testAccount.ShippingPostalCode = '28546';
        insert testAccount;
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount1.Primary_Email__c = 'testAccount@move.com';
            testAccount1.ShippingState  = 'CA';
            testAccount1.ShippingCountry  = 'USA';
            testAccount1.Party_ID__c = '11158132';
            testAccount1.ShippingPostalCode = '28546';
            testAccount1.parentid = testAccount.id;
        insert testAccount1;
        
        accStr.setcurrentId(testAccount1.id);
        accStr.getObjectStructure();
        
    }
}