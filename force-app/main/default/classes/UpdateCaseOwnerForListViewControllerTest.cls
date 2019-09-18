//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: UpdateCaseOwnerForListViewControllerTest
// For Testing: UpdateCaseOwnerForListViewController.cls
//
// 15th April 2015    Kirti Agarwal   Original (Task-T-377382)
//
@isTest(seeallData=false)
private class UpdateCaseOwnerForListViewControllerTest {

  static testMethod void UpdateCaseOwnerForListViewControllerTest(){
      Profile p = [SELECT id FROM Profile WHERE Name = 'System Administrator'];
      User newUser = TestDataFactory.createUser(null, p.id , null, 'trttest@test.com', 'trttest@test.com', true);

      System.runAs(newUser){
            //Inserting Customsetting for Account 
           DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
          Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAcc@move.com';
          insert testAccount;
          Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'testCon@move.com';
          insert testContact;
     Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
    
 CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
             insert setting;                       
          List<Case> caseList = new List<Case>();
          Case testCase = TestDataFactory.createCase('Invalid Rights','New','Test' ,'Test Description', testContact.Id,testAccount.Id,true);
          caseList.add(testCase);
          
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
          
          ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(caseList);
                UpdateCaseOwnerForListViewController con_Obj = new UpdateCaseOwnerForListViewController(setCon);               
          con_Obj.getAllQueue();
          con_Obj.selectedQueue = 'a3v50000000DUDP';
          con_Obj.selectedCases = caseList;
          try{
            System.assertEquals(con_Obj.saveRecords(),null);
          }catch(exception e) {
             con_Obj.getAllQueue();
             con_Obj.selectedQueue = testQueue.Id;
             con_Obj.selectedCases = caseList;
             System.assert(con_Obj.saveRecords()!=null);
          }

      }
  }

}