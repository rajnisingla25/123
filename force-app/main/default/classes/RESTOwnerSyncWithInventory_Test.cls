@isTest
private class RESTOwnerSyncWithInventory_Test{
    public static testMethod void main1(){
        Waitlist_Urls__c testSetting = new Waitlist_Urls__c();
        testSetting.Name = 'UpdateOwner';
        testSetting.URL__c = 'http://206.131.186.15:7082/UpdateOwnerService/UpdateOwnerPS/UpdateOwner';
        insert testSetting;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RESTOwnerSyncWithInventory obj = new RESTOwnerSyncWithInventory();
        RESTOwnerSyncWithInventory.JsonVariables obj1 = new RESTOwnerSyncWithInventory.JsonVariables();
        RESTOwnerSyncWithInventory.RESTAccountOwnerSync(1,'owner_name','updated_by','account_sub_type','Phone','001g000000Zs31s');
    Test.stopTest();
    }
  }