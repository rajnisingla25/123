@istest
public class CaseAssignmentHistoric_ScheduleTest {
static testmethod void testSchedule() {
   Test.startTest();
	  	String ownerId = UserInfo.getUserId();
        Omni_Overflow_Queue__c cs = new Omni_Overflow_Queue__c();
        cs.QueueId__c = ownerId;
    	cs.Name = 'OwnerId';
        insert cs;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;     
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = '000');
        insert setting;           
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

      String jobId = System.schedule('CaseAssignmentHistoric_ScheduleTest',
      CaseAssignmentHistoric_Schedule.CRON_EXP, 
         new CaseAssignmentHistoric_Schedule());
    
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CaseAssignmentHistoric_Schedule.CRON_EXP, 
         ct.CronExpression);
      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);
   Test.stopTest();
   }
}