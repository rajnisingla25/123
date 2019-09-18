@isTest(seeAlldata=false)
private class BatchProcessMLSAccountRealSuite_Test{
    static testMethod void method1(){
        //Inserting Customsetting for Account 
       // DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
       // insert Dtrg;       
        SkipAccountTrigger.setSkipTrgTrue();
        Account theAccount1 = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount1.Primary_Email__c = 'theAccount@move.com';
        theAccount1.Type = 'MLS Account';  
        theAccount1.Customer_Id__c = 'LVNV';
        insert theAccount1;   
        
        BatchProcessMLSAccountRealSuite WLBatch = new BatchProcessMLSAccountRealSuite();
        database.executebatch(WLBatch, 1);
            
       // Test.stopTest();
    }
}