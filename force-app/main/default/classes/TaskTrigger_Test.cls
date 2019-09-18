//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: TaskTrigger_Test
// For Testing: TaskTrigger.trigger, TaskTriggerHandler.cls and TaskTriggerHandlerManager.cls
//
// 20th March 2015    Hemendra Singh Bhati   Original (Task # T-372157)
// 09th April 2015    Hemendra Singh Bhati   Modified (Task # T-376903) - Replace Record Type 'Prospect' Checks With Account Sub Type 'Prospect'.
// 08th May 2015            Hemendra Singh Bhati     Modified (Task # T-393511) - Updated Method: testSalesLockUserAndLockExpirationDateFunctionality().
//No need of this test class 
@isTest
private class TaskTrigger_Test {
    private static final Integer COUNTER = 5;

  static testMethod void testSalesLockUserAndLockExpirationDateFunctionality() {
        Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;

    // Inserting custom setting data.
    Switch_TaskTrigger__c theCustomSettingData = TestDataFactory.createSwitchTaskTriggerCustomSettingData(false, false, true);
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Test.startTest();

    // Inserting account records.
    Account testAccount = null;
    List<Account> theAccounts = new List<Account>();
    for(Integer index = 0; index < COUNTER; index++) {
        testAccount = TestDataFactory.createAccount('The Test Account #' + (index + 1), null, false);
      testAccount.Account_Sub_Type__c = (Math.mod(index, 2) == 0) ? 'Prospect' : (index == 1) ? 'Customer' : 'Former Customer';
      testAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccounts.add(testAccount);
    }
    insert theAccounts;

    // Inserting task records for accounts created above.
    Task theTask = null;
    List<Task> theTasks = new List<Task>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                theAccounts.get(index).Id,
                'Test Task #' + (index + 1),
                (Math.mod(index, 2) == 0) ? 'Call' : 'Message',
                Date.today(),
                'In Progress',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTasks.add(theTask);
    }
    insert theTasks;

    Test.stopTest();

   /* system.assert(
      [SELECT Id FROM Account WHERE Sales_Lock_User__c = null AND Lock_Expiration_Date__c = null].size() == 2,
      'Error: The task trigger must update only prospect accounts.'
    );
    system.assert(
      [SELECT Id FROM Account WHERE Sales_Lock_User__c != null AND Lock_Expiration_Date__c != null].size() == 3,
      'Error: The task trigger failed to update prospect account lock fields.'
    );*/
  }
}