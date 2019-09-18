@isTest(seeAllData=true)
private class MonitorAsyncApexJobController_Test {
    private static testMethod void testMonitorAsyncApexJobandSendEmail() {
        Test.startTest();
        MonitorAsyncApexJobController obj = new MonitorAsyncApexJobController();
        obj.monitorAsyncApexJobandSendEmail();
        Test.StopTest();
        
        System.assert(obj.totalCount != 0);
    }
}