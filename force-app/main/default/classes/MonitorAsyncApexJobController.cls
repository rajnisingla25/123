global class MonitorAsyncApexJobController implements Schedulable {
    public List<ApexJob> jobs {get; set;}
    public Integer totalCount {get; set;}
    
    public class ApexJob {
        public String className {get; set;}
        public Integer count {get; set;}
        public ApexJob(String className, Integer count) {
            this.className = className;
            this.count = count;
        }
    }
   
    public void getLast24HoursApexJobCount() {
        jobs = new List<ApexJob>();
        totalCount = 0;
        DateTime last24Hours = System.now().addHours(-24);
        for (AggregateResult result : [SELECT ApexClass.Name className, COUNT(id) classCount FROM AsyncApexJob WHERE 
                                       CreatedDate >= :last24Hours GROUP BY ApexClass.Name ORDER BY COUNT(id) DESC]) {
            
            ApexJob job = new ApexJob(String.ValueOf(result.get('className')), Integer.valueOf(result.get('classCount')));
            jobs.add(job);
            totalCount = totalCount + job.count;
        }
    }
    
    // For scheduler class to send email
    global void execute(SchedulableContext SC) {
         monitorAsyncApexJobandSendEmail();   
    }
    
    // For scheduler class to send email
    public void monitorAsyncApexJobandSendEmail() {
        Integer threshold = Integer.valueof(Label.AsyncApexJob_Threshold);
        if (threshold != 0) {
            getLast24HoursApexJobCount();
            if (totalCount > threshold || Test.isRunningTest()) {
                String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('MonitorAsyncApexJob').Asset_Creation_Error_Emails__c;
                if (theEmailAddresses != null && theEmailAddresses != '') {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(theEmailAddresses.split(';'));
                    mail.setSenderDisplayName(UserInfo.getName());
                    mail.setSubject('Alert: AsyncApexJob Count - ' + totalCount);
                    String messageBody = '<html><body>Top 5 Classes with high count - <br/> <br/> <table border="1" cellspacing="0" cellpedding="5"> <tr><th>Class Name</th><th>Count</th></tr>' ; 
                    
                    for (Integer i=0; i<5; i++) {
                        messageBody = messageBody  + '<tr><td>' + jobs[i].className + '</td><td>' + jobs[i].count+ '</td></tr>';
                    }
                    
                    messageBody = messageBody + '</table> </body>  </html>';
                    mail.setHtmlBody(messageBody); 
                    system.debug(mail );
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
}