@isTest
private class BrokerAccountCreationTest {

    private static testMethod void testcode(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');        
        insert Dtrg;    
        
        Collection_Users__c collUsers = new Collection_Users__c(Name= 'batchintegration user',Id__c =userinfo.getuserid());
        insert collUsers;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testEmail@test.com';	
        
        try{
            insert testAccount;
            
        }catch(Exception e){
            
            system.debug('ERROR : '+ e.getMessage());
        }
        
        
        test.startTest();
        PageReference pgr = page.BrokerAccountCreation;
        Test.SetCurrentPage(pgr); 
        ApexPages.StandardController sc = New ApexPages.StandardController(testAccount);
        BrokerAccountCreation controller = new BrokerAccountCreation(sc);
        PageReference pRef = controller.brokerAccCreate();
        
        system.assertNotEquals(null, pRef);
        test.stopTest();  
    }
    
    
    
    
    
}