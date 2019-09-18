@isTest
public class batchTUpdtAlActAstsToActSch_test {
    public static testMethod void testschedule() {
    Test.StartTest();
    batchToUpdateAllActiveAssetsToActiveSch sh1 = new batchToUpdateAllActiveAssetsToActiveSch();
    String sch = '0 0 23 * * ?'; 
    system.schedule('batchToUpdateAllActiveAssetsToActiveSch_test check', sch, sh1);
    Test.stopTest();
    }
}