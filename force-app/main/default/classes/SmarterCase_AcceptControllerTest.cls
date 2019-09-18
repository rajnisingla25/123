//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: CaseCommentTrigger_Test
// For Testing: SmarterCase_AcceptController
//
// 15th April 2015    Kirti Agarwal   Original (Task-T-377382)
// 17th April 2015    Ravindra Shekhawat Modified ( Separated Test Class From Controller, Increased Coverage)
//
@isTest(seeAllData=false)
private class SmarterCase_AcceptControllerTest {
 
        private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    static testMethod void  testSmarterCase_AcceptController()
    {
    
      Group collectionGroup = TestDataFactory.createPublicGroup('CC Collections Team',true);
      TestDataFactory.createPublicGroupMember(UserInfo.getUserId(),collectionGroup.Id,true);

            // Get System Administrator Profile
      List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
      system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
            
            List<User> users  = new List<User>();
            users.add(TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUser@move.com','adminUser@move.com', true));
          users.add(TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUser1@move.com','adminUser1@move.com', true));
      
          Group testQueue = new Group(Name='Default Queue', type='Queue');
        insert testQueue;
        QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
          System.runAs(new User(Id = UserInfo.getUserId()))
          {
             insert mappingObject;
          } 
          System.runAs(users.get(1)){
            TestDataFactory.createPublicGroupMember(users.get(0).Id, collectionGroup.Id, true);
          }
      System.runAs(users.get(0)){
           //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
       Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
             testAccount.Primary_Email__c ='testCaseAccept@move.com';
         insert testAccount;
         Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
         testContact.Email = 'testCont@move.com';
         insert testContact;
         
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
    
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
             insert setting;    
         
        // Create case of Social Media record Type
        Case testCase = TestDataFactory.createCase('Invalid Rights','New','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
        Case testCase1 = TestDataFactory.createCase('Invalid Rights1','New','Collections' ,'Test Description1', testContact.Id,testAccount.Id,false);
        Case testCase2 = TestDataFactory.createCase('Invalid Rights2','New','Collections' ,'Test Description2', testContact.Id,testAccount.Id,false);
        List<Case> caseList = new List<Case>();
        caseList.add(testCase);
        caseList.add(testCase1);
        testCase1.OwnerId = testQueue.Id;
        caseList.add(testCase2);
        
        insert caseList;
        delete testCase2;
        
        Test.StartTest(); // Start the test
          // Array of cases empty
          String strResult = SmarterCase_AcceptController.Accept(null);
          System.assertEquals(strResult, 'Please select one or more items.');
          
          // Case not exists
          strResult = SmarterCase_AcceptController.Accept(new String[]{testCase2.Id});
          System.assertEquals(strResult, 'Please select one or more items.');
          
          // One case 'Social Media' and one case 'Other'
          strResult = SmarterCase_AcceptController.Accept(new String[]{testCase.Id});
          System.assertNotEquals(strResult, '');
          strResult = SmarterCase_AcceptController.Accept(new String[]{testCase1.Id});
          System.assertEquals(strResult, '');
        Test.StopTest(); // Stop the test
    }
    } 
}