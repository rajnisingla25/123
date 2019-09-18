/*
	Class: SFMC_ContactMethodTriggerHelper_Test.
	Purpose: Test class for Preference update to update and save preference on CM record.
	Created by: Varun Agarwal (Brillio Technologies)
	Created date : 02/11/2019
*/
@isTest
Public class SFMC_ContactMethodTriggerHelper_Test{
	 @testsetup
	static void testsetup(){
		DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        
	}
	public testMethod static void updatePreferenceRecordPositive(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	String emailaddress = 'test@test.com';
    	List<ContactMethod__c> cmList = new List<ContactMethod__c>();
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.RDC_Info_OptIn__c = false;
		contactMethodRecord.RDC_Promo_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		contactMethodRecord.TP_Info_OptIn__c = false;
		contactMethodRecord.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord);
		
		ContactMethod__c contactMethodRecord2 = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord2.RDC_Event_OptIn__c = false;
		contactMethodRecord2.RDC_Info_OptIn__c = false;
		contactMethodRecord2.RDC_Promo_OptIn__c = false;
		contactMethodRecord2.TP_Event_OptIn__c = false;
		contactMethodRecord2.TP_Info_OptIn__c = false;
		contactMethodRecord2.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord2);
		
		insert cmList;
		
    	Test.startTest();
    		CheckRecursiveTrigger.executeTriggerOnce = false;
    		
    		ContactMethod__c cmRecord = [select RDC_Event_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id =: contactMethodRecord.id limit 1]; 
    		cmRecord.RDC_Event_OptIn__c = true;
    		cmRecord.RDC_Promo_OptIn__c = false;
    		cmRecord.TP_Event_OptIn__c = true;    		
    		update cmRecord;
    		
    		ContactMethod__c cm2Record = [select RDC_Event_OptIn__c,TP_Event_OptIn__c,RDC_Promo_OptIn__c from ContactMethod__c where id =: contactMethodRecord2.id limit 1];
    		System.assertEquals(cm2Record.RDC_Event_OptIn__c,true);
    		System.assertEquals(cm2Record.TP_Event_OptIn__c,true);
    		System.assertEquals(cm2Record.RDC_Promo_OptIn__c,false);
    	Test.stopTest();
    }
	public testMethod static void updatePreferenceRecordPositiveWithOtherUser(){
    	User user1 = SFMC_TestDataFactory.createUser(null,userInfo.getProfileId(),null,'myuser@email.com','myuser@email.com',true);
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	String emailaddress = 'test@test.com';
    	List<ContactMethod__c> cmList = new List<ContactMethod__c>();
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.RDC_Info_OptIn__c = false;
		contactMethodRecord.RDC_Promo_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		contactMethodRecord.TP_Info_OptIn__c = false;
		contactMethodRecord.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord);
		
		ContactMethod__c contactMethodRecord2 = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord2.RDC_Event_OptIn__c = false;
		contactMethodRecord2.RDC_Info_OptIn__c = false;
		contactMethodRecord2.RDC_Promo_OptIn__c = false;
		contactMethodRecord2.TP_Event_OptIn__c = false;
		contactMethodRecord2.TP_Info_OptIn__c = false;
		contactMethodRecord2.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord2);
		
		insert cmList;
		
    	Test.startTest();
    		CheckRecursiveTrigger.executeTriggerOnce = false;
    		System.runAs(user1) {
    		
	    		ContactMethod__c cmRecord = [select RDC_Event_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id =: contactMethodRecord.id limit 1]; 
	    		cmRecord.RDC_Event_OptIn__c = true;
	    		cmRecord.TP_Event_OptIn__c = true;
	    		update cmRecord;
	    		
	    		ContactMethod__c cm2Record = [select RDC_Event_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id =: contactMethodRecord2.id limit 1];
	    		System.assertEquals(cm2Record.RDC_Event_OptIn__c,true);
	    		System.assertEquals(cm2Record.TP_Event_OptIn__c,true);
    		}
    	Test.stopTest();
    }
    
    
    public testMethod static void updatePreferenceRecordBulk(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	String emailaddress = 'test@test.com';
    	List<ContactMethod__c> cmList = new List<ContactMethod__c>();
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.RDC_Info_OptIn__c = false;
		contactMethodRecord.RDC_Promo_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		contactMethodRecord.TP_Info_OptIn__c = false;
		contactMethodRecord.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord);
		
		ContactMethod__c contactMethodRecord2 = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord2.RDC_Event_OptIn__c = false;
		contactMethodRecord2.RDC_Info_OptIn__c = false;
		contactMethodRecord2.RDC_Promo_OptIn__c = false;
		contactMethodRecord2.TP_Event_OptIn__c = false;
		contactMethodRecord2.TP_Info_OptIn__c = false;
		contactMethodRecord2.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord2);
		
		ContactMethod__c contactMethodRecord3 = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Main Email',emailaddress,true, false);
		contactMethodRecord3.RDC_Event_OptIn__c = false;
		contactMethodRecord3.RDC_Info_OptIn__c = false;
		contactMethodRecord3.RDC_Promo_OptIn__c = false;
		contactMethodRecord3.TP_Event_OptIn__c = false;
		contactMethodRecord3.TP_Info_OptIn__c = false;
		contactMethodRecord3.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord3);
		
		insert cmList;
		
    	Test.startTest();
    		CheckRecursiveTrigger.executeTriggerOnce = false;
    		ContactMethod__c cmRecord = [select TP_Promo_OptIn__c from ContactMethod__c where id =: contactMethodRecord.id limit 1]; 
    		cmRecord.TP_Promo_OptIn__c = true;    		
    		update cmRecord;
    		
    		ContactMethod__c cm2Record = [select TP_Promo_OptIn__c from ContactMethod__c where id =: contactMethodRecord2.id limit 1];
    		System.assertEquals(cm2Record.TP_Promo_OptIn__c,true);
    		
    		ContactMethod__c cm3Record = [select TP_Promo_OptIn__c from ContactMethod__c where id =: contactMethodRecord3.id limit 1];
    		System.assertEquals(cm3Record.TP_Promo_OptIn__c,true);
    		
    	Test.stopTest();
    }
    
    public testMethod static void preferenceRecordForPhone(){
    	Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);    	
    	Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
    	Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
    	
    	String phone = '2345323458';
    	List<ContactMethod__c> cmList = new List<ContactMethod__c>();
    	ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Phone','primary phone',phone,true, false);
		contactMethodRecord.RDC_Event_OptIn__c = false;
		contactMethodRecord.RDC_Info_OptIn__c = false;
		contactMethodRecord.RDC_Promo_OptIn__c = false;
		contactMethodRecord.TP_Event_OptIn__c = false;
		contactMethodRecord.TP_Info_OptIn__c = false;
		contactMethodRecord.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord);
		
		ContactMethod__c contactMethodRecord2 = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Phone','primary phone',phone,true, false);
		contactMethodRecord2.RDC_Event_OptIn__c = false;
		contactMethodRecord2.RDC_Info_OptIn__c = false;
		contactMethodRecord2.RDC_Promo_OptIn__c = false;
		contactMethodRecord2.TP_Event_OptIn__c = false;
		contactMethodRecord2.TP_Info_OptIn__c = false;
		contactMethodRecord2.TP_Promo_OptIn__c = false;
		
		cmList.add(contactMethodRecord2);
		
		insert cmList;
		
    	Test.startTest();
    		CheckRecursiveTrigger.executeTriggerOnce = false;
    		ContactMethod__c cmRecord = [select RDC_Event_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id =: contactMethodRecord.id limit 1]; 
    		cmRecord.RDC_Event_OptIn__c = true;
    		cmRecord.TP_Event_OptIn__c = true;
    		update cmRecord;
    		
    		ContactMethod__c cm2Record = [select RDC_Event_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id =: contactMethodRecord2.id limit 1];
    		System.assertEquals(cm2Record.RDC_Event_OptIn__c,false);
    		System.assertEquals(cm2Record.TP_Event_OptIn__c,false);
    	Test.stopTest();
    }	
}