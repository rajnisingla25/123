//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: ManuallySendSurveyController_Test
// For Web-Service Class: ManuallySendSurveyController
// Description: This web-service is used to manually send survey of cases to third party system via workflow outbound messages.
//
// 18th May 2015    Hemendra Singh Bhati    Original (Task # T-396116)
//
@IsTest(seeAllData=false)
private class ManuallySendSurveyController_Test {
  private static testMethod void testManualSurveyFunctionality() {
    // Inserting Custom Setting Data.
    Post_Call_Survey_Frequency__c theSurveyFrequency = new Post_Call_Survey_Frequency__c(
      Name = 'International',
      Survey_Frequency__c = 7
    );
    insert theSurveyFrequency;
    
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;

    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email = 'hsingh@appirio.com';
    theContact.Last_Survey_Send_Date__c = null;
    insert theContact;
    
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
    
 CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
             insert setting;     

    // Inserting Test Case.
    Case theTestCase = TestDataFactory.createCase(
      'Test Case',
      'New',
      'International',
      'Test Case',
      null,
      null,
      false
    );
    theTestCase.ContactId = theContact.Id;
    insert theTestCase;

    Test.startTest();

    // Initiating Web-Service Call.
    // Test Case - 1
    Id caseId = null;
    String caseType = null;
    String theResult = ManuallySendSurveyController.sendSurvey(caseId, caseType);
    system.assert(
      theResult.equalsIgnoreCase('Error: Invalid request. Case ID is missing. Please contact system administrator.'),
      'Error: The controller class failed to validate requested case Id.'
    );

    // Test Case - 2
    caseId = theTestCase.Id;
    caseType = null;
    theResult = ManuallySendSurveyController.sendSurvey(caseId, caseType);
    system.assert(
      theResult.equalsIgnoreCase('Error: Invalid request. The case type is not set for the requested case. Please set the case type and try once again.'),
      'Error: The controller class failed to validate requested case type.'
    );

    // Test Case - 3
    caseType = 'International';
    theResult = ManuallySendSurveyController.sendSurvey(caseId, caseType);
    system.assert(
      theResult.equalsIgnoreCase('Success: Survey sent successfully.'),
      'Error: The controller class failed to send the case survey manually.'
    );

    // Test Case - 4
    theContact.Last_Survey_Send_Date__c = Date.today();
    update theContact;
    theResult = ManuallySendSurveyController.sendSurvey(caseId, caseType);
    system.assert(
      theResult.equalsIgnoreCase('Error: Survey cannot be sent before date - ' + String.valueOf(Date.today().addDays(7))),
      'Error: The controller class failed to validate contact last survey send date.'
    );

    // Test Case - 5
    theResult = ManuallySendSurveyController.sendSurvey(caseId, 'FIND');
    system.assert(
      theResult.equalsIgnoreCase('Error: Unable to determine survey frequency for requested case type. Please contact system administrator.'),
      'Error: The controller class failed to inform the user about missing custom setting record for the case type.'
    );

    // Test Case - 6
    theResult = ManuallySendSurveyController.sendSurvey(theContact.Id, caseType);
    system.assert(
      theResult.equalsIgnoreCase('Error: An internal error occurred while processing your request. Please contact system administrator.'),
      'Error: The controller class failed to throw an exception.'
    );

    Test.stopTest();
  }
}