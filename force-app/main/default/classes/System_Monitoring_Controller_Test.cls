@isTest(seeAllData=false)
public class System_Monitoring_Controller_Test {
    public static testMethod void test1() {
        System_Monitoring_Category__c cat = new System_Monitoring_Category__c(Frequency_To_Send_Email_hr__c=1,Email_Subject__c='test', Failure_To_List__c='test@test.com', Minimum_Last_Run_Minutes__c=14,To_Email_List__c='test@test.com', Name = 'Internal', Display_Name__c='Internal Reports');
        insert cat;
        System_Monitoring_Report__c rep1 = new System_Monitoring_Report__c(To_Email_List__c='test@test.com', Order__c=1, Red_Threshold__c=1,Name='Fulfillment Failure', SOQL__c='SELECT Count(Id)cnt FROM System_Monitoring_Report__c', Category__c=cat.Id, Field_Names_For_Email__c='Id');
        insert rep1;
        System_Monitoring_Report__c rep2 = new System_Monitoring_Report__c(Send_Attachment__c=true,Apex_Code__c='integer i=0;', run_apex_code__c=true,To_Email_List__c='test@test.com', Order__c=1, Red_Threshold__c=1,Name='Expiration Failure', Category__c=cat.Id, Field_Names_For_Email__c='Id',SOQL__c='SELECT Count(Id)cnt FROM System_Monitoring_Report__c WHERE ID IN ');
        insert rep2;
        System_Monitoring_Report__c rep3 = new System_Monitoring_Report__c(Send_Attachment__c=false,Apex_Code__c='integer i=0;', run_apex_code__c=true,To_Email_List__c='test@test.com', Order__c=1, Red_Threshold__c=1,Name='Expiration', Category__c=cat.Id, Field_Names_For_Email__c='Id',SOQL__c='SELECT Count(Id)cnt FROM System_Monitoring_Report__c WHERE ID IN ');
        insert rep3;
        test.StartTest();
        List<System_Monitoring_Category__c> categories = System_Monitoring_Controller.getCategories();
        List<System_Monitoring_Controller.Report> reports = System_Monitoring_Controller.getReportDetails(categories[0].Name);
        System_Monitoring_Controller.updateReportCount(reports[0].Name);
        System_Monitoring_Controller.sendEmailSingleReport(reports[0]);
        System_Monitoring_Controller.sendEmailCategoryReports(categories[0].Name, reports);
        String s = System_Monitoring_Controller.NewLine;
        s = System_Monitoring_Controller.quotes;
        test.StopTest();
    }
    
    public static testMethod void test2() {
        System_Monitoring_Category__c cat = new System_Monitoring_Category__c(Frequency_To_Send_Email_hr__c=1,Email_Subject__c='test', Failure_To_List__c='test@test.com', Minimum_Last_Run_Minutes__c=15,To_Email_List__c='test@test.com', Name = 'Internal', Display_Name__c='Internal Reports');
        insert cat;
        System_Monitoring_Report__c rep3 = new System_Monitoring_Report__c(Send_Attachment__c=false,Apex_Code__c='integer i=0;', run_apex_code__c=true,To_Email_List__c='test@test.com', Order__c=1, Red_Threshold__c=1,Name='Expiration', Category__c=cat.Id, Field_Names_For_Email__c='Id',SOQL__c='SELECT Count(Id)cnt FROM System_Monitoring_Report__c WHERE ID IN ');
        insert rep3;
        test.StartTest();
        DailyMonitoringBatch b = new DailyMonitoringBatch('Internal');
        Database.executeBatch(b, 1);
        b.sendFailureEmail();
        test.StopTest();
    }
    
}