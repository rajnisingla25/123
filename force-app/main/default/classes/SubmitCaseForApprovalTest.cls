@isTest
private class SubmitCaseForApprovalTest {
    
    @isTest(seeAllData=false) static void testSubmitCaseForApproval(){
        //creating test data
        Profile testProfile = [select id from profile where name='System Administrator'];
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();    
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
        insert setting;
        User testUser = TestDataFactory.createUser(null, testProfile.Id, null, 'testeuserl@test.com', 'testemuserl@test.com', true);
        Account testAccount = TestDataFactory.createAccount('testAccount', testUser.id, true);
        Contact testContact = TestDataFactory.createContact('testFirstName', 'testLastName', testAccount.id, true, true);
        Case testCase = TestDataFactory.createCase('Invalid Rights','New','Collections' ,'Test Description', testContact.Id,testAccount.Id,true);

        Test.startTest();
        try{
        SubmitCaseForApproval.handleApproval(testCase.id);
        }
        catch(Exception e){}
        Test.stopTest();
    }

    
  
}