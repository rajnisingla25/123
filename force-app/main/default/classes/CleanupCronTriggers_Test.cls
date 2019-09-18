/*****************************************************************************
    Author : Bala
    Description : Test class for CleanupCronTriggers schedulable class.

******************************************************************************/ 

@isTest
Public class CleanupCronTriggers_Test {
    public static testMethod void  testschedule() {
       Test.StartTest();
            CleanupCronTriggers sh1 = new CleanupCronTriggers();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
           
           String SCHEDULE_NAME = 'test'; 
           id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
           System.abortJob(cronid);
        Test.stopTest();
    }
}