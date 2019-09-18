@isTest(seeAllData =false)
public  class AutoBrokerAccountBatch_Test{
    public static testMethod void mainMethod1(){       
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Collection_Users__c collUsers = new Collection_Users__c(Name= 'batchintegration user',Id__c =userinfo.getuserid());
        insert collUsers;
        
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Prospect';
        testAccount.Type = 'Realtor Office';
        testAccount.MLS_Brokerage_Id__c = '123456';
        insert testAccount; 
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account1',null,false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.Account_Sub_Type__c = 'Customer';
        testAccount1.Parent_Broker__c = testAccount.Id;
        testAccount1.Type = 'Broker';
        //testAccount1.Type = 'Realtor Office';
        testAccount1.MLS_Brokerage_Id__c = testAccount.MLS_Brokerage_Id__c ;
        insert testAccount1;    
        //new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(testAccount1.Id, 'Account');        

        Contact testContact2 = Z_LegacyTestFactory.makeContact(testAccount); //Create Contact         
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact2.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = testAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        insert ar; 
        
        Test.StartTest();       
        AutoBrokerAccountBatch AROSch = new AutoBrokerAccountBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();      
    }
    
    public static testMethod void mainMethod2(){       
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Collection_Users__c collUsers = new Collection_Users__c(Name= 'batchintegration user',Id__c =userinfo.getuserid());
        insert collUsers;
        
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Prospect';
        testAccount.Type = 'Realtor Office';
        testAccount.MLS_Brokerage_Id__c = '123456';
        insert testAccount; 
        
        Account testAccount2 = TestDataFactory.createAccount('Test Account2',null,false);
        testAccount2.Primary_Email__c = 'testAccount1@move.com';
        testAccount2.Account_Sub_Type__c = 'Prospect';
        testAccount2.Type = 'Realtor Office';
         testAccount2.Parent_Broker__c = null;
        testAccount2.MLS_Brokerage_Id__c = testAccount.MLS_Brokerage_Id__c ;
        insert testAccount2;  
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account1',null,false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.Account_Sub_Type__c = 'Customer';
        testAccount1.Parent_Broker__c = testAccount.Id;
        testAccount1.Type = 'Realtor Office';
        testAccount1.MLS_Brokerage_Id__c = testAccount.MLS_Brokerage_Id__c ;
        insert testAccount1;    
        //new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(testAccount1.Id, 'Account');
        
        Test.StartTest();       
        AutoBrokerAccountBatch AROSch = new AutoBrokerAccountBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();      
    }
    
}