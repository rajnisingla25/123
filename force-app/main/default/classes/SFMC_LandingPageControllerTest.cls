/*
 * Created by: Sarang D
 * description: Test class for Landing Page controller.
*/
@isTest
public class SFMC_LandingPageControllerTest {
    
    @testsetup
    static void testsetup(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
    }	
    
    public static testMethod void testController(){
        SFMC_LandingPageController.getValueForParam('Test');
    }
    
    public static testMethod void saveFormPositive(){
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true); 
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);   
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false); 	
        ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
        
        Map<String,String> urlParamMap = new Map<String,String>();
        urlParamMap.put(SFMC_Constants.CONTACT_METHOD_ID,contactMethodRecord.id);
        urlParamMap.put(SFMC_Constants.UTM_CAMPAIGN_ID,campaignRecord.id);
        urlParamMap.put(SFMC_Constants.ACCOUNT_ID,accountRecord.id);
        
        Test.startTest();
        
        
        String urlParamStr = JSON.serialize(urlParamMap);
        SFMC_LandingPageController.saveFormSubmissionRecord( urlParamStr, formSubmissionObj);
        SFMC_LandingPageController.getPicklistValues(contactMethodRecord.id);
        Form_Submission__c insertedFormSubmission = [select Account_Id__c,Contact_Method_Id__c,Campaign_Id__c from Form_Submission__c where id =: formSubmissionObj.id];
        System.assertNotEquals(insertedFormSubmission.Contact_Method_Id__c,null);
        System.assertNotEquals(insertedFormSubmission.Campaign_Id__c,null);
        
        Test.stopTest();
    }
    
    public static testMethod void saveFormWithGarbageParam(){
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        
        
        Map<String,String> urlParamMap = new Map<String,String>();
        urlParamMap.put(SFMC_Constants.CONTACT_METHOD_ID,'jfiwi3242972');
        urlParamMap.put(SFMC_Constants.CAMPAIGN_ID,'rekei572753');
        urlParamMap.put(SFMC_Constants.ACCOUNT_ID,'sffnsh853752');
        
        Test.startTest();
        
        String urlParamStr = JSON.serialize(urlParamMap);
        SFMC_LandingPageController.saveFormSubmissionRecord( urlParamStr, formSubmissionObj);
        
        Form_Submission__c insertedFormSubmission = [select Account_Id__c,Contact_Method_Id__c,Campaign_Id__c from Form_Submission__c where id =: formSubmissionObj.id];
        System.assertEquals(insertedFormSubmission.Account_Id__c,null);
        System.assertEquals(insertedFormSubmission.Contact_Method_Id__c,null);
        System.assertEquals(insertedFormSubmission.Campaign_Id__c,null);
        
        Test.stopTest();
    }
    
    public static testMethod void saveFormWithoutParam(){
        Lead objLead = new Lead(LastName = 'Test', Company = 'test', status = 'New');
        insert objLead;
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
		formSubmissionObj.Lead__c = objLead.Id;        
        Test.startTest();
        
        SFMC_LandingPageController.saveFormSubmissionRecord( null, formSubmissionObj);
        SFMC_LandingPageController.updateLeadforProdType( formSubmissionObj.Id, 'rdc');
        
        Form_Submission__c insertedFormSubmission = [select Account_Id__c,Contact_Method_Id__c,Campaign_Id__c from Form_Submission__c where id =: formSubmissionObj.id];
        System.assertEquals(insertedFormSubmission.Account_Id__c,null);
        System.assertEquals(insertedFormSubmission.Contact_Method_Id__c,null);
        System.assertEquals(insertedFormSubmission.Campaign_Id__c,null);
        
        Test.stopTest();
        
    }
    
    public static testMethod void saveFormNegative(){
        Test.startTest();
        SFMC_LandingPageController.saveFormSubmissionRecord( null, null);
        Test.stopTest();
    }
    
    public static testMethod void testEnableDisablePopUp(){
        Landing_Page_Pop_Up_Settings__c setting = new Landing_Page_Pop_Up_Settings__c(Name = 'PopUpSettings');
        setting.Enable_Pop_Up__c = true;
        insert setting;
        system.assert(SFMC_LandingPageController.enableDisablePopUp());
    }
}