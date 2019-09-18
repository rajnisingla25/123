/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SFMC_PreferenceUtils_Test {

	 @testsetup
	static void testsetup(){
		DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        List<Business_Unit_From_Domain__c> buList = new List<Business_Unit_From_Domain__c>();
        Business_Unit_From_Domain__c businessUnit = new Business_Unit_From_Domain__c();
        businessUnit.name = SFMC_Constants.BUSINESS_UNIT_REALTOR;
        businessUnit.Business_Unit__c = SFMC_Constants.RDC;
        buList.add(businessUnit);
        
        Business_Unit_From_Domain__c businessUnit2 = new Business_Unit_From_Domain__c();
        businessUnit2.name = SFMC_Constants.BUSINESS_UNIT_TOP_PRODUCER;
        businessUnit2.Business_Unit__c = SFMC_Constants.TOP_PRODUCER;
        buList.add(businessUnit2);
        
        insert buList;
	}	
	
	
    public static testMethod void preferenceUpdateRDCPositive(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true); 
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);   
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false); 	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		insert contactMethodRecord;	
        
        contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		update contactMethodRecord;	
        
                
        Test.startTest();
        
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        formSubmissionObj.Product_Type__c = SFMC_Constants.RDC;
        formSubmissionObj.Contact_Method_Id__c = contactMethodRecord.id;
        formSubmissionObj.Account_Id__c = accountRecord.id;
        formSubmissionObj.Business_Unit__c = SFMC_Constants.RDC;
        insert formSubmissionObj;
        
        Test.stopTest();       
        
        ContactMethod__c cmObj = [SELECT RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c FROM ContactMethod__c where id =: contactMethodRecord.id];
        System.assertEquals(cmObj.RDC_Event_OptIn__c,true);
        System.assertNotEquals(cmObj.TP_Event_OptIn__c,true);
    }
    public static testMethod void preferenceUpdateTPPositive(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true); 
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);   
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false); 	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		insert contactMethodRecord;	
        
        contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		update contactMethodRecord;	
		
		        
        Test.startTest();
        
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        formSubmissionObj.Product_Type__c = SFMC_Constants.Top_Producer;
        formSubmissionObj.Contact_Method_Id__c = contactMethodRecord.id;
        formSubmissionObj.Account_Id__c = accountRecord.id;
        formSubmissionObj.Business_Unit__c = SFMC_Constants.Top_Producer;
        insert formSubmissionObj;
        
        Test.stopTest();       
        
        ContactMethod__c cmObj = [SELECT RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c FROM ContactMethod__c where id =: contactMethodRecord.id];
        System.assertNotEquals(cmObj.RDC_Event_OptIn__c,true);
        System.assertEquals(cmObj.TP_Event_OptIn__c,true);
    }
    public static testMethod void preferenceUpdateBulkPositive(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true); 
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);   
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false); 	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		insert contactMethodRecord;		
                
        
        List<Form_Submission__c> formList = new List<Form_Submission__c>();
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        formSubmissionObj.Product_Type__c = SFMC_Constants.RDC;
        formSubmissionObj.Business_Unit__c = SFMC_Constants.RDC;
        formSubmissionObj.Contact_Method_Id__c = contactMethodRecord.id;
        formSubmissionObj.Account_Id__c = accountRecord.id;
        formList.add(formSubmissionObj);
        
        Form_Submission__c formSubmissionObj2 =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);
        formSubmissionObj2.Product_Type__c = SFMC_Constants.Top_Producer;
        formSubmissionObj2.Business_Unit__c = SFMC_Constants.Top_Producer;
        formSubmissionObj2.Contact_Method_Id__c = contactMethodRecord.id;
        formSubmissionObj2.Account_Id__c = accountRecord.id;
        formList.add(formSubmissionObj2);
        
        Test.startTest();        
        insert formList;
        Test.stopTest();       
        
        ContactMethod__c cmObj = [SELECT RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c FROM ContactMethod__c where id =: contactMethodRecord.id];
        System.assertEquals(cmObj.RDC_Event_OptIn__c,true);
        System.assertEquals(cmObj.TP_Event_OptIn__c,true);
    }
    
    public static testMethod void preferenceUpdateNoChangeNegative(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true); 
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);   
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false); 	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		insert contactMethodRecord;		
        
        contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		update contactMethodRecord;	
        
        Test.startTest();
                
        Form_Submission__c formSubmissionObj =  SFMC_TestDataFactory.createFormSubmission('testName','email@email.com','12345678',false);        
        formSubmissionObj.Contact_Method_Id__c = contactMethodRecord.id;
        formSubmissionObj.Account_Id__c = accountRecord.id;
        insert formSubmissionObj;
        
        Test.stopTest();       
        
        ContactMethod__c cmObj = [SELECT RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c FROM ContactMethod__c where id =: contactMethodRecord.id];
        System.assertNotEquals(cmObj.RDC_Event_OptIn__c,true);
        System.assertNotEquals(cmObj.TP_Event_OptIn__c,true);
    }        
}