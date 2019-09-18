@isTest
public class WelcomeEmailGenerationBatchTest {
    static testMethod void test1(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name= 'batchintegration user');
        insert coll;
        
        set<Id> accs = new set<Id>();
        Account testAccount1 = TestDataFactory.createAccount('Test Account1', null, false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.type = 'Broker';
        testAccount1.Advertiserid__c = '12345';
        testAccount1.MLS_Set_Id__c = '243365576';
       
        insert testAccount1;
        accs.add(testAccount1.Id);
        
        Test.StartTest();
        System.schedule('WelcomeEmailGenerationBatchSch', '0 0 * * * ?', new WelcomeEmailGenerationBatchSch());
        Database.BatchableContext bc;             
        WelcomeEmailGenerationBatch ARQCB = new  WelcomeEmailGenerationBatch(accs);
        ARQCB.finish(bc);    
        Test.StopTest();
    }
    
}