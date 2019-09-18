@isTest
Global class Commissions_AssetRenewalBatchSch_Test{
    static testMethod void method1(){
        test.startTest();
        Commissions_AssetRenewalBatchSch sh1 = new Commissions_AssetRenewalBatchSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    }