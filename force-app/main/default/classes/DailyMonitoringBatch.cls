public class DailyMonitoringBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    System_Monitoring_Category__c category;
    String query;
    public void execute(SchedulableContext SC) {
        for (System_Monitoring_Category__c cat : [SELECT Name FROM System_Monitoring_Category__c]) {
            Database.executeBatch(new DailyMonitoringBatch(cat.Name), 1);
        }
    }
    
    public DailyMonitoringBatch() { }
    
    public DailyMonitoringBatch(String cat) {
        this.category = [SELECT Id, Name, Failure_To_List__c, Minimum_Last_Run_Minutes__c FROM System_Monitoring_Category__c WHERE Name=:cat];
        this.query = 'SELECT Id, Last_Run_Date_Time__c, Name, Report_Details__c, Count__c FROM System_Monitoring_Report__c WHERE Active__c=true AND Category__c=\''+ category.Id + '\' Order by Order__c asc';
    }
    
    public Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
     public void execute(Database.BatchableContext BC, List<System_Monitoring_Report__c> scope) {
         System_Monitoring_Controller.updateReportCount(scope[0].Name);        // batch size must be one
     }
     
     public void finish(Database.BatchableContext BC) {
         Boolean reportRan = true;
         List<System_Monitoring_Controller.Report> reports = new List<System_Monitoring_Controller.Report>();
         for (System_Monitoring_Report__c rep : DataBase.query(query)) {
             Double lastRunBefore = category.Minimum_Last_Run_Minutes__c+1;
             if (rep.Last_Run_Date_Time__c != null) {
                 lastRunBefore = (System.now().getTime()-rep.Last_Run_Date_Time__c.getTime())/60000;
                 system.debug('lastRunBefore - ' + lastRunBefore );
             }
             if (lastRunBefore > category.Minimum_Last_Run_Minutes__c) {
                 reportRan = false;
                 break;
             }      
             
             System_Monitoring_Controller.Report report = new System_Monitoring_Controller.Report();
             report.count = Integer.valueOf(rep.Count__c);
             report.Name = rep.Name;
             report.reportDetails = rep.Report_Details__c;
             reports.add(report);
         }
         
         if (reportRan) {
             System_Monitoring_Controller.sendEmailCategoryReports(category.Name, reports);
         }
         else {
             sendFailureEmail();
         }
     }
     
     public void sendFailureEmail() {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(category.Failure_To_List__c.split(';'));
        mail.setSenderDisplayName(UserInfo.getUserName()); 
        mail.setSubject('Failed To Send Email for DM - ' + category.Name);    
        String messageBody = 'One ore more reports failed to run for Category ' + category.Name + '. Please manually run the reports and send email!';
        mail.setHtmlBody(messageBody);
        mail.saveAsActivity = false;
        mails.add(mail);
        Messaging.sendEmail(mails);
     }
}