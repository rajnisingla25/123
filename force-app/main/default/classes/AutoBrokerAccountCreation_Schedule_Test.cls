@isTest
private class AutoBrokerAccountCreation_Schedule_Test{
    static testMethod void method1(){
        test.startTest();
        AutoBrokerAccountCreation_Schedule sh1 = new AutoBrokerAccountCreation_Schedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}