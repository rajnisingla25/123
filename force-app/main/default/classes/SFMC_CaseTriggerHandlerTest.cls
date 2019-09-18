/*
 * Created by:	Sarang Deshpande
 * Description:	Test class to test triggered Send SMS and Email functionality.
 * Created Date: 11/2/2019
*/
@isTest
public class SFMC_CaseTriggerHandlerTest {
    


    @testSetup
    public static void intialiseData(){
        DisabledTrigger__c dtrig = new DisabledTrigger__c(name = 'Disabled');
        insert dtrig;
        CaseRecordTypes__c caseRecType = new CaseRecordTypes__c(name = 'Retention');
        insert caseRecType;
        
        Account acc = SFMC_TestDataFactory.createAccount('Test Acc', UserInfo.getUserId(), true);
        Contact con = SFMC_TestDataFactory.createContact('test', 'lastname', acc.id, true, true);
        ContactMethod__c cmRec = SFMC_TestDataFactory.createContactMethod(con.id, '', '', 'abc@xyz.com', true, true);
        cmRec.Email__c = 'abc@xyz.com';
        update cmRec;
        Case caseRec = SFMC_TestDataFactory.createCase('Test', 'New', 'Standard', 'Test', con.id, acc.id, true);
        //Assert that no request is created because NVM Failedd count criteria is not yet met.
        system.assert(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountFirst.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountSecond.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountThird.equals('[]'));
    }

    @isTest
    public static void testCountEmailSendFirst(){
		Case caseRec = [select id, status, RecordTypeId, Related_Contact_FirstName__c, Related_Contact_LastName__c,NVM_Failed_Call_Count__c,
                                account.Email_Address__c, account.PrimaryEmail_CMId__c,account.PrimarySMS_CMId__c, account.SMS_Phone_SFMC__c 
                                from Case
                                where subject =: 'test' limit 1];
        
        ContactMethod__c cmRec = [Select id from contactmethod__c where Email__c =: 'abc@xyz.com'];
		caseRec.NVM_Failed_Call_Count__c = SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1;
        caseRec.account.Email_Address__c = 'abc@xyz.com';
        caseRec.account.PrimaryEmail_CMId__c = cmRec.id;
        caseRec.type = 'Standard';
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendCalloutMock());
        update caseRec; 
        
        system.assert(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountFirst.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountSecond.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountThird.equals('[]')); 
        
        caseRec.type = SFMC_Constants.RECORD_TYPE_COLLECTIONS;        
        update caseRec;
    }
    
    @isTest
    public static void testCountOneEmailSendSuccess(){
		Case caseRec = [select id, type from Case where subject =: 'test' limit 1];
        
        caseRec.type = SFMC_Constants.RECORD_TYPE_COLLECTIONS;
        caseRec.NVM_Failed_Call_Count__c = SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1;
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendCalloutMock());
        
        test.startTest();
        update caseRec;        
        test.stopTest();
        
        //Assert that only request for 1 is made and other 3 are empty.
        system.assert(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountSecond.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountThird.equals('[]'));
        
        system.assertEquals(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountFirst,
                            '[{"To":{"ContactAttributes":{"SubscriberAttributes":{"Related_Contact_LastName__c":"lastname","Related_Contact_FirstName__c":"test","RecordID":"' + caseRec.id + '","SObject":"Case"}}},"From":{"Name":"Customer Care","Address":"customercare@realtor.com"}}]');       
    }
    
    
    @isTest
    public static void testCountSixEmailSend(){
		Case caseRec = [select id, status, NVM_Failed_Call_Count__c,
                                account.Email_Address__c, account.PrimaryEmail_CMId__c 
                                from Case
                                where subject =: 'test' limit 1];
        
        ContactMethod__c cmRec = [Select id from contactmethod__c where Email__c =: 'abc@xyz.com'];
		caseRec.NVM_Failed_Call_Count__c = SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_2;
        caseRec.account.Email_Address__c = 'abc@xyz.com';
        caseRec.account.PrimaryEmail_CMId__c = cmRec.id;
        caseRec.type = 'Collections';
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendCalloutMock());
        
        test.startTest();
        update caseRec;
        test.stopTest();
        
        system.assert(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountFirst.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountThird.equals('[]'));
        
        system.assertEquals(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountSecond,
                            '[{"To":{"ContactAttributes":{"SubscriberAttributes":{"Related_Contact_LastName__c":"lastname","Related_Contact_FirstName__c":"test","RecordID":"' + caseRec.id + '","SObject":"Case"}}},"From":{"Name":"Customer Care","Address":"customercare@realtor.com"}}]'); 
    }
    
    @isTest
    public static void testCountNineEmailSend(){
		Case caseRec = [select id, status, RecordTypeId, Related_Contact_FirstName__c, Related_Contact_LastName__c,NVM_Failed_Call_Count__c,
                                account.Email_Address__c, account.PrimaryEmail_CMId__c,account.PrimarySMS_CMId__c, account.SMS_Phone_SFMC__c 
                                from Case
                                where subject =: 'test' limit 1];
        
        ContactMethod__c cmRec = [Select id from contactmethod__c where Email__c =: 'abc@xyz.com'];
		caseRec.NVM_Failed_Call_Count__c = SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_3;
        caseRec.account.Email_Address__c = 'abc@xyz.com';
        caseRec.account.PrimaryEmail_CMId__c = cmRec.id;
        caseRec.type = 'Collections';
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendCalloutMock());
        update caseRec;        
        
        system.assert(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountFirst.equals('[]') &&
                      SFMC_CaseTriggerHandler.jsonRequestStringNVMCountSecond.equals('[]'));
        
        system.assertEquals(SFMC_CaseTriggerHandler.jsonRequestStringNVMCountThird,
                            '[{"To":{"ContactAttributes":{"SubscriberAttributes":{"Related_Contact_LastName__c":"lastname","Related_Contact_FirstName__c":"test","RecordID":"' + caseRec.id + '","SObject":"Case"}}},"From":{"Name":"Customer Care","Address":"customercare@realtor.com"}}]');        
    }
    
    @isTest
    public static void testError(){
		Case caseRec = [select id, status, RecordTypeId, Related_Contact_FirstName__c, Related_Contact_LastName__c,NVM_Failed_Call_Count__c,
                                account.Email_Address__c, account.PrimaryEmail_CMId__c,account.PrimarySMS_CMId__c, account.SMS_Phone_SFMC__c 
                                from Case
                                where subject =: 'test' limit 1];
        
        ContactMethod__c cmRec = [Select id from contactmethod__c where Email__c =: 'abc@xyz.com'];
		caseRec.NVM_Failed_Call_Count__c = SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1;
        caseRec.account.Email_Address__c = 'abc@xyz.com';
        caseRec.account.PrimaryEmail_CMId__c = cmRec.id;
        caseRec.type = 'Collections';
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendCalloutMock());
        test.setMock(HttpCalloutMock.class, new SFMC_TriggeredSendAccessTokenErrorMock());
        test.startTest();
        update caseRec;
        test.stopTest();
        system.assert([select id from Error__c where Interface_Name__c =: 'SFMC_TriggeredSendQueuable'].size() > 0);
    }
}