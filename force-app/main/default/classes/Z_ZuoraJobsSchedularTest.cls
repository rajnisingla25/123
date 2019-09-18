@isTest
public class Z_ZuoraJobsSchedularTest {
    public static testMethod void TestMethodOne(){
        ZuoraSchedulesJobSetting__c Zsetting = new ZuoraSchedulesJobSetting__c();
        Zsetting.Name = 'Z_InvoicecollectionSchedulable';
        Zsetting.Is_Running__c = true;
        Zsetting.Schedule_Time__c = System.now().addminutes(-2);
        Zsetting.Execution_interval__c  = 5; 
        Zsetting.Individual_Job__c = false;
        insert Zsetting;
        ZuoraSchedulesJobSetting__c Zsetting2 = new ZuoraSchedulesJobSetting__c();
        Zsetting2.Name = 'Z_ZuoraJobsSchedular';
        Zsetting2.Is_Running__c = true;
        Zsetting2.Schedule_Time__c = System.now().addminutes(-2);
        Zsetting2.Execution_interval__c  = 5; 
        Zsetting2.Individual_Job__c = true;
        insert Zsetting2;
        String CRON_EXP = '0 0 0 * * ?';
        System.schedule('Test Check', CRON_EXP, new Z_ZuoraJobsSchedular());     
        Z_ZuoraJobsSchedular.sendemail('exception');
        //Z_ZuoraJobsSchedular ee= new Z_ZuoraJobsSchedular();
        //Z_ZuoraJobsSchedular.execute(null);
        
        ZuoraSchedulesJobSetting__c Zsetting4 = new ZuoraSchedulesJobSetting__c();
        Zsetting4.Name = 'Z_ZuoraJobsSchedular12';
        Zsetting4.Is_Running__c = true;
        Zsetting4.Schedule_Time__c = System.now().addminutes(-2);
        Zsetting4.Execution_interval__c  = 5; 
        Zsetting4.Individual_Job__c = false;
        insert Zsetting4;
        Z_ZuoraJobsSchedular.execute(null);
        
       
    }
}