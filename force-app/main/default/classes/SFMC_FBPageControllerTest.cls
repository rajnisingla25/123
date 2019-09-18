@isTest
private class SFMC_FBPageControllerTest {
	
	@isTest static void testGetFBSetting() {
		FBLeadGen_setting__c fbSetting = new FBLeadGen_setting__c(Name='Base setting',FB_SDK_Endpoint__c='www.test.com',App_Id__c='1234567890',FB_API_version__c='v1.0');
		insert fbSetting;
		List<String> fbSettingList = SFMC_FBPageController.getFBSetting();
		System.assertNotEquals(fbSettingList.size(),0);
	}

	@isTest static void testGetPermanantAccessToken_success() {
		FBLeadGen_setting__c fbSetting = new FBLeadGen_setting__c(Name='Base setting',FB_SDK_Endpoint__c='www.test.com',App_Id__c='1234567890',FB_API_version__c='v1.0');
		insert fbSetting;
		SFMC_FBPageController.getPermanantAccessToken('testShortLivedToken','TestPageId');
        //Asserting that a new custom setting is created and populated with permanant access token 
        FBLeadGen_setting__c newFbSetting = [select access_token__c from FBLeadGen_setting__c fbSetting where name =: 'TestPageId'];
		system.assert(newFbSetting != null);
        system.assertEquals(newFbSetting.access_token__c, 'EAAL1iFctlEQBABmbodZANGRZAK4eLvXN3HlYE6aEuIl5Rk6btV4zOKHFNrZBsQfQx46fR3zcahxVeqZCBdtpyC2gRQlym8tLn7WhhaKYozAPjPBOMkw3Jl0MnqHiZBTbB6sZCO5uN1VoVuGpVqZBNoRRGyEJULkUP2jGoDxW4VQMgZDZD');
	}

}