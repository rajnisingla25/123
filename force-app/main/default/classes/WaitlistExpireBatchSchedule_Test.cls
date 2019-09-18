@isTest
public class WaitlistExpireBatchSchedule_Test{
    public static  testMethod void  main() {
        Test.StartTest();
        WaitlistExpireBatchSchedule sh = new WaitlistExpireBatchSchedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, sh);
        Test.stopTest();
    }
}