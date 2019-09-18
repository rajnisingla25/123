//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: agentHomeController_Test
// For Apex Class: agentHomeController
// 
//
// 04th June 2015    Manish Soni    

@isTest(seeAllData=false)
private class agentHomeController_Test {
    
    private static final Integer COUNTER = 7;
    
    static testMethod void testAgentHomeController() {
        
        Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
        
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
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
        
        Test.startTest();
        
            agentHomeController controller = new agentHomeController();
            
            SelectOption[] taskViews = controller.getTaskViews();
            
            Task[] taskList = controller.getTasks();
            system.assert(taskList.size() == 5, 'getTasks method should return 5 tasks ');
            
            controller.Next();
            taskList = controller.getTasks();
            system.assert(taskList.size() == 2, 'getTasks method should return 2 tasks ');
            
            controller.Previous();
            taskList = controller.getTasks();
            system.assert(taskList.size() == 5, 'getTasks method should return 5 tasks ');
            
            controller.End();
            taskList = controller.getTasks();
            system.assert(taskList.size() == 2, 'getTasks method should return 2 tasks ');
            
            controller.First();
            taskList = controller.getTasks();
            system.assert(taskList.size() == 5, 'getTasks method should return 5 tasks ');
            
            controller.getDisablePrevious();
            controller.getDisableNext();
            controller.getTotal_size();
            controller.getPageNumber();
            controller.getTotalPages();
            
            String selectedTab = controller.selectedTab; 
            system.assert(selectedTab == 'vwAccTab', 'Default selected tab should be "vwAccTab" ');
            
            controller.selectedTab = 'vwNewTab'; 
            system.assert(Last_Selected_Tab_On_AgentHome__c.getInstance().Last_Selected_Tab__c == 'vwNewTab', 'Custom setting should store new selected tab name. ');
            
            agentHomeController controller2 = new agentHomeController();
            controller2.selectTab();
            selectedTab = controller2.selectedTab; 
            system.assert(selectedTab == 'vwNewTab', '"vwNewTab" tab name should get from the custom setting. ');
            
            controller2.taskIdToBeDeleted = taskList[0].id;
            controller2.deleteTask();
            
            List<Task> deletedTaskList = new List<Task>([SELECT Id FROM Task WHERE Id=: controller2.taskIdToBeDeleted]);
            system.assert(deletedTaskList.size() == 0, 'Task should be deleted and task list size should be zero. ');
            
        
        Test.stopTest();
        
        
      }
}