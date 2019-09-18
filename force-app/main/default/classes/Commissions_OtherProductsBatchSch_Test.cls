@isTest
Global class Commissions_OtherProductsBatchSch_Test {
    static testMethod void method1(){
        test.startTest();
        Commissions_OtherProductsBatchSch sh1 = new Commissions_OtherProductsBatchSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}