//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: UpdateCaseOwnerForDetailPageConTest
// Test class for UpdateCaseOwnerForDetailPageController class
//
// 15th April 2015    Kirti Agarwal   Original (Task-T-377382)
// 19th May   2015    Updated Test Class to Improve Coverage and fix failures
//
@isTest(seeallData=false)
private class UpdateCaseOwnerForDetailPageConTest {

  static testMethod void UpdateCaseOwnerForDetailPageConTest() {
      Profile p = [SELECT id FROM Profile WHERE Name = 'System Administrator'];
      User newUser = TestDataFactory.createUser(null, p.id , null, 'trttest786@test.com', 'trttest786@test.com', true);

      System.runAs(newUser){
         //Inserting Customsetting for Account 
            DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
          Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount;
          Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
                    testContact.Email = 'testCon@move.com';
                    insert testContact;
                    
          Group testQueue = new Group(Name='Default Queue', type='Queue');
                insert testQueue;
                
                QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
                System.runAs(new User(Id = UserInfo.getUserId()))
                {
                        insert mappingObject;
                }
                Group g = [select Id from Group where Name='Default Queue' AND Type = 'Queue'];
                
                GroupMember member = new GroupMember();
                    member.UserOrGroupId = newUser.id;
                    System.debug('UserId :'+newUser.Id);
                    System.debug('UserInfo UserId :'+UserInfo.getUserId());
                    member.GroupId = g.Id;
                    insert member;
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
    
 CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
             insert setting;            
          Case testCase = TestDataFactory.createCase('Invalid Rights','New','Email' ,'Test Description', testContact.Id,testAccount.Id,true);

          UpdateCaseOwnerForDetailPageController con_Obj = new UpdateCaseOwnerForDetailPageController(new ApexPages.StandardController(testCase));
          con_Obj.getAllQueue();
          con_Obj.selectedQueue = 'a3v50000000DUDP';
          System.assert(con_Obj.saveRecords() == null);
          con_Obj.selectedQueue = newUser.id;
          System.assert(con_Obj.saveRecords() != null);
          }
      }

}