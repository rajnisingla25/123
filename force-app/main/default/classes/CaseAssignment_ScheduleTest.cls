@istest
public class CaseAssignment_ScheduleTest {
static testmethod void testSchedule() {
   Test.startTest();
        String ownerId = UserInfo.getUserId();
        Service_Followup_Queue__c cs = new Service_Followup_Queue__c();
        cs.QueueId__c = ownerId;
        cs.Name = 'OwnerId';
        insert cs;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;     
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention');
        insert setting;   
        Schedule_Batch_Setting__c batchsetting = new Schedule_Batch_Setting__c(Name = 'CaseAssignmentprocess' , Execution_Time_hr__c = 1.0);
        insert batchsetting;    
        Schedule_Batch_Setting__c batchsetting1 = new Schedule_Batch_Setting__c(Name = 'MLSSupportdays' , Execution_Time_hr__c = 1);
        insert batchsetting1;  
        Datetime dt = system.now();    
        Case cs1 = TestDataFactory.createCase(
                'Test Case #1',
                'New',
                'Retention',
                'Test Case #1',
                null,
                null,
                false
            );
        cs1.Status='Review';
        cs1.Last_Worked__c = dt;
        insert cs1;
      // Schedule the test job

      String jobId = System.schedule('testBasicScheduledApex',
      CaseAssignment_Schedule.CRON_EXP, 
         new CaseAssignment_Schedule());
    
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CaseAssignment_Schedule.CRON_EXP, 
         ct.CronExpression);
      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);
   Test.stopTest();
   }
}