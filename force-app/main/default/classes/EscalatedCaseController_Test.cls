// (c) 2015 Appirio, Inc.  
//
// Class Name: EscalatedCaseController_Test
// Description: Test Class for EscalatedCaseController
//
// 21st May 2015    Ravindra Shekhawat   Original (Task # T-397063)
//
@isTest(seeAllData=false)
global class EscalatedCaseController_Test{
    
    private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    static testMethod void testEscalatedCaseFunctionality() {
      Group collectionGroup = TestDataFactory.createPublicGroup('CC Collections Team',true);
      TestDataFactory.createPublicGroupMember(UserInfo.getUserId(),collectionGroup.Id,true);      

            // Get System Administrator Profile
      List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
      system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
            
            List<User> users  = new List<User>();
            users.add(TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUserTesting@move.com','adminUser@move.com', true));
          users.add(TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUserTesting1@move.com','adminUser1@move.com', true));
      
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
          //Inserting custom setting to avoid NullPointerException 
          DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
              insert trg;      
       Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
             testAccount.Primary_Email__c ='testCaseAccept@move.com';
         insert testAccount;
         Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
         testContact.Email = 'testCont@move.com';
         insert testContact;
       
       //Prepare Custom Setting Data
       List<Custom_Field_Ids_For_Case_Escalation__c> configList = new List<Custom_Field_Ids_For_Case_Escalation__c>();
       configList.add(new Custom_Field_Ids_For_Case_Escalation__c(Name='Case.Area__c',Id__c='00NK0000001jRRI'));
       configList.add(new Custom_Field_Ids_For_Case_Escalation__c(Name='Case.Sub_Area__c',Id__c='00NK0000001jRRT'));
       insert configList;
       
       // Create case of Social Media record Type
       Case testCase = TestDataFactory.createCase('Invalid Rights','New','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
         testCase.Area__c = 'Account Information';
         testCase.Origin = 'Phone';
         testCase.Sub_Area__c = 'Current';
         insert testCase;
      Test.startTest();
         EscalatedCaseController controller = new EscalatedCaseController(new ApexPages.StandardController(testCase));
         System.assert(controller.prepareEscalatedChildCase() == null);
             System.assert(TestDataFactory.wasMessageAdded(new ApexPages.Message(
                                                            ApexPages.Severity.ERROR, 'Invalid Case Id. Please Enter Correct Information!')));
                
             ApexPages.currentPage().getParameters().put('caseId',testCase.Id);
             System.assert(controller.prepareEscalatedChildCase() != null);
             System.assert(controller.redirectBack() != null);
                     
         Case testCase1 = TestDataFactory.createCase('Invalid Rights1','Escalated','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
         testCase1.Area__c = 'Account Information';
         testCase1.Sub_Area__c = 'Current';
         testCase1.SubStatus__c = 'Review';
         testCase1.ParentId = testCase.Id;
         insert testCase1;

         
         ApexPages.currentPage().getParameters().put('caseId',testCase.Id);
         
         System.assert(controller.prepareEscalatedChildCase() != null);
         System.assert(TestDataFactory.wasMessageAdded(new ApexPages.Message(
                                                            ApexPages.Severity.ERROR, 'The Case Has Been Escalated Earlier. You Cannot Escalated It Again!')));
      Test.stopTest();
     }
    }
}