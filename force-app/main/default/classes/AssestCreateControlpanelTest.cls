@isTest
public class AssestCreateControlpanelTest {
   //public static 
    static testMethod void createcontroltest(){
    String CRON_EXP = '0 0 0 15 10 ? 2022';
      Test.startTest();
        String jobId = System.schedule('ScheduleAssetRenewalClassTest',CRON_EXP,new AssetCreateControlPanel_Schedule());  
       Test.stopTest();
    }
}