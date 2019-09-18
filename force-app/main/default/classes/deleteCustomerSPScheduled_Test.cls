@isTest
private class deleteCustomerSPScheduled_Test{
    static testMethod void method1(){
        test.startTest();
        deleteCustomerSPScheduled sh1 = new deleteCustomerSPScheduled();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}