@isTest (SeeAllData=false)
private class AddNewACHCallback_Test {

    static testMethod void AddNewACHCallbackTest() {
        Test.startTest();
        
        AddNewACHCallback ancc = new AddNewACHCallback();
    ancc.processCallbackParameters();
        
        Test.stopTest();
    }
}