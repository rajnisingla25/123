/*
	Class: SFMC_PreferenceCenterController_Test.
	Purpose: Test class for PreferenceCenterController to Fetch and save preference on ACP record.
	Created by: Varun
	Created date : 01/02/2019
*/
@isTest
public class SFMC_PreferenceCenterController_Test {
    @testsetup
	static void testsetup(){
		DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
	}	
	
	@isTest public static void testPreferenceCenterController(){
        ContactMethod__c objContactMethod = new ContactMethod__c(Value__c = 'test', Email__c = 'test@test.com',RDC_Promo_OptIn__c = true, RDC_Info_OptIn__c = true, RDC_Event_OptIn__c = true);
        insert objContactMethod;
        SFMC_PreferenceCenterController.getPreferenceRecord(objContactMethod.Id);
        SFMC_PreferenceCenterController.savePreferenceRecord(objContactMethod.Id, SFMC_Constants.REALTOR_COM, true, false, false);
        SFMC_PreferenceCenterController.saveDataStewardPreferenceRecord(objContactMethod.Id, true, false, false,true, false, false);
        SFMC_PreferenceCenterController.getUserType(UserInfo.getUserId());
        
    }
    
    public testMethod static void getPreferenceRecordPositive(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
				
    	Test.startTest();
    		ContactMethod__c cmFetchRecord = SFMC_PreferenceCenterController.getPreferenceRecord(contactMethodRecord.id);
    		
    		System.assertNotEquals(cmFetchRecord.Email__c, null );
    		
    	Test.stopTest();
    }
    public testMethod static void getPreferenceRecordNegative(){
    	Test.startTest();
    		ContactMethod__c cmFetchRecord = SFMC_PreferenceCenterController.getPreferenceRecord(Null);
    		
    		System.assertEquals(cmFetchRecord, null );
    		
    	Test.stopTest();
    }
    
    public testMethod static void savePreferenceRecordPositive(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
		
		
    	Test.startTest();
    		Boolean isRDCSave = SFMC_PreferenceCenterController.savePreferenceRecord(contactMethodRecord.id,SFMC_Constants.REALTOR_COM,true,true,false);
    		Boolean isTopProducerSave = SFMC_PreferenceCenterController.savePreferenceRecord(contactMethodRecord.id,SFMC_Constants.TOP_PRODUCER,false,true,false);
    		
    		System.assertEquals(isRDCSave, true );
    		System.assertEquals(isTopProducerSave, true );
    		
    	Test.stopTest();
    }
    
    public testMethod static void savePreferenceRecordNegative(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
		
		
		String cmId = contactMethodRecord.id;
		
		delete contactMethodRecord;
		
    	Test.startTest();
    		Boolean isRDCSave = SFMC_PreferenceCenterController.savePreferenceRecord(cmId,SFMC_Constants.REALTOR_COM,true,true,false);
    		
    		System.assertEquals(isRDCSave, false );
    		
    	Test.stopTest();
    }
    
    @isTest
    public static void saveDataStewardPreference(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
    	Test.startTest();
    		Boolean isSave = SFMC_PreferenceCenterController.saveDataStewardPreferenceRecord(contactMethodRecord.id,true, true, true, true, true, true);
    		System.assertEquals(isSave, true );    		
    	Test.stopTest();
    }
    
    
    public testMethod static void savePreferenceRecordMergeCMPositive(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
		String oldCMId = contactMethodRecord.id;
		
		delete contactMethodRecord;
		
		ContactMethod__c survivorContactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email','test@test.com',true, true);
		
		MergeHistory__c mergeHistoryRecord = SFMC_TestDataFactory.createMergeHistory(oldCMId,survivorContactMethodRecord.id,'ContactMethod__c',true);
		
    	Test.startTest();
    		ContactMethod__c latestContactMethod = SFMC_PreferenceCenterController.getPreferenceRecord(oldCMId);
    		
    		System.assertEquals(latestContactMethod.id, survivorContactMethodRecord.id );
    		
    		Boolean isTopProducerSave = SFMC_PreferenceCenterController.savePreferenceRecord(latestContactMethod.id,SFMC_Constants.TOP_PRODUCER,false,true,false);
    		    		
    		System.assertEquals(isTopProducerSave, true );
    		
    	Test.stopTest();
    }
}