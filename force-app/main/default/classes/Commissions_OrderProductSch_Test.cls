@isTest
public class Commissions_OrderProductSch_Test{
    Static TestMethod void ScheduleMethod(){
        Test.StartTest();
            Commissions_OrderProductSch sh1 = new Commissions_OrderProductSch();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
           
           String SCHEDULE_NAME = 'test'; 
           id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
           System.abortJob(cronid);
        Test.stopTest();
    }
}