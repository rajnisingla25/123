@isTest
private class SFMC_FBLeadgenTest {
    
    @isTest static void test_method_dopost() {
        Campaign campaignRec = SFMC_TestDataFactory.CreateCampaign('Test Campaign', true, true);
        campaignRec.Target_Product__c = SFMC_Constants.PRODUCT_TYPE_TOPIDX;
        update campaignRec;
        FBLeadGen_setting__c fbSettingBase = new FBLeadGen_setting__c(Name='Base setting',FB_SDK_Endpoint__c='www.test.com',App_Id__c='1234567890',FB_API_version__c='v1.0');
        insert fbSettingBase;
        FBLeadGen_setting__c fbSettingPage = new FBLeadGen_setting__c(Name='609696262789730',Access_Token__c='neverendingtoken');
        insert fbSettingPage;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        String reqBody = '{"entry": [{"changes": [{"field": "leadgen", "value": {"created_time": 1554158652, "page_id": "609696262789730", "form_id": "2243857618997938", "leadgen_id": "2271313622919004"}}], "id": "609696262789730", "time": 1554158652}], "object": "page"}';
        request.requestBody = Blob.Valueof(reqBody);
        
        RestContext.request = request;
        RestContext.response =  response;
        
        Test.startTest();
        SFMC_FBLeadgen.doPost();
        Test.stopTest();
        List<Form_Submission__c> fsList = [Select Id,Product_type__c from Form_Submission__c];
        System.debug('>>>***>>>'+fsList);
        System.assertNotEquals(fsList.size(),0);
        System.assertEquals(fsList[0].Product_type__c, SFMC_Constants.PRODUCT_TYPE_TOPIDX);
    }
    
    @isTest static void test_method_doget() {
        FBLeadGen_setting__c fbSettingBase = new FBLeadGen_setting__c(Name='Base setting',FB_SDK_Endpoint__c='www.test.com',App_Id__c='1234567890',FB_API_version__c='v1.0', Webhook_verify_token__c = 'abc123');
        insert fbSettingBase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response =  response;       
        RestContext.request.params.put('hub.verify_token', 'abc123');
        RestContext.request.params.put('hub.challenge', '4125');
        Integer result = SFMC_FBLeadgen.verifyFBTokenAndReturnChallenge();
        system.assertEquals(result, 4125);
    }
    
    @isTest static void test_method_doget_Negative() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response =  response;       
        RestContext.request.params.put('hub.verify_token', 'abc123');
        RestContext.request.params.put('hub.challenge', '4125');
        Integer result = SFMC_FBLeadgen.verifyFBTokenAndReturnChallenge();
        system.assertEquals(result, null);
        
        FBLeadGen_setting__c fbSettingBase = new FBLeadGen_setting__c(Name='Base setting',FB_SDK_Endpoint__c='www.test.com',App_Id__c='1234567890',FB_API_version__c='v1.0', Webhook_verify_token__c = 'abc123');
        insert fbSettingBase;
        
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse();
        RestContext.request = request1;
        RestContext.response =  response;       
        RestContext.request.params.put('hub.verify_token', 'xyz');
        RestContext.request.params.put('hub.challenge', '4125');
        Integer result2 = SFMC_FBLeadgen.verifyFBTokenAndReturnChallenge();
        system.assertEquals(result2, 401);
    }
}