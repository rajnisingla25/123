public class System_Monitoring_Controller {
    public static String NewLine {
        get { return '\r\n'; }
        set;
    }
        
    public static String quotes {
        get { return '"'; }
        set;
    }
    
    public class AnonymousResult {
        public Integer column;
        public String  compileProblem;
        public Boolean compiled;
        public String  exceptionMessage;
        public String  exceptionStackTrace;
        public Integer line;
        public Boolean success;
    }
    
    public class Report {
        @auraEnabled
        public String name {get; set;}
        @auraEnabled
        public Integer count {get; set;}
        @auraEnabled
        public Integer order {get; set;}
        @auraEnabled
        public Integer yellow {get; set;}
        @auraEnabled
        public Integer red {get; set;}
        @auraEnabled
        public String reportUrl {get; set;}
        @auraEnabled
        public String reportDetails {get; set;}
        @auraEnabled
        public Boolean enableEmail {get; set;}
        @auraEnabled
        public String comments {get; set;}
        @auraEnabled
        public String toList {get; set;}
        @auraEnabled
        public String lastRunDateTime {get; set;}
        public DateTime lDateTime {get; 
            set {
                if (value != null) {
                    this.lastRunDateTime = value.format('MM/dd/yyyy HH:mm:ss');
                }
            }
        }
        public Report (String Name, Integer order, Integer yellow, Integer red, String reportUrl, Boolean enableEmail, String reportDetails, String toList, Integer count, DateTime lastRunDateTime ) {
            this.Name = Name;
            this.count = count;
            this.order = order;
            this.yellow = yellow;
            this.red = red;
            this.reportUrl = reportUrl;
            this.enableEmail = enableEmail;
            this.reportDetails = reportDetails;
            this.toList = toList;
            this.count = count;
            this.lDateTime = lastRunDateTime;
        }
        public Report () {}
    }
    
    private static List<String> runApexCode(String apexCode) {
        List<String> ids;
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            String body = EncodingUtil.URLEncode(apexCode, 'UTF-8');
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v30.0/tooling/executeAnonymous/?anonymousBody='+body);
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');
            String response = '{"line":55,"column":1,"compiled":true,"success":false,"compileProblem":null,"exceptionStackTrace":"AnonymousBlock: line 55, column 1","exceptionMessage":"System.SearchException: 001f100001BFsVJAA1,001f100001JcSoZAAV,001j000000bZ3j6AAC"}';
            if (!test.isRunningTest()) {
                HttpResponse res = h.send(req);
                response = res.getBody();
            }
            system.debug(response);
            AnonymousResult result = (AnonymousResult)JSON.deserialize(response, AnonymousResult.Class);
            system.debug(result.exceptionMessage);
            if(!result.success && result.exceptionMessage != null && result.exceptionMessage.contains('System.SearchException')) {
                ids = result.exceptionMessage.replace('System.SearchException:','').replaceAll(' ','').split(',');
            }
        }
        catch (Exception e) {
            system.debug(e);
        }
        return ids;
    }
    
    @AuraEnabled
    public static List<System_Monitoring_Category__c> getCategories() {
       return [SELECT Name, Display_Name__c, To_Email_List__c FROM System_Monitoring_Category__c];
    }
    
    @AuraEnabled
    public static List<Report> getReportDetails(String category) {
       List<Report> reports = new List<Report>();
       for (System_Monitoring_Report__c rec : [SELECT Last_Run_Date_Time__c, Count__c, To_Email_List__c, Report_Details__c, Name, Order__c, Enable_Email__c, yellow_threshold__c, red_threshold__c,Report_URL__c FROM System_Monitoring_Report__c WHERE Category__r.Name=:category AND Active__c=true Order by Order__c asc]) {
           reports.add(new Report(rec.Name, Integer.valueOf(rec.Order__c), Integer.valueOf(rec.yellow_threshold__c), Integer.valueOf((rec.red_threshold__c)),rec.Report_URL__c ,rec.Enable_Email__c, rec.Report_Details__c, rec.To_Email_List__c, Integer.valueOf(rec.Count__c), rec.Last_Run_Date_Time__c));
       }
       return reports;
    }
    
    @AuraEnabled
    public static Report updateReportCount(String name) {
        system.debug(name);
        Integer count = -1;
        System_Monitoring_Report__c record = [SELECT Id, SOQL__c, Apex_Code__c, Run_Apex_Code__c FROM System_Monitoring_Report__c WHERE Name =:Name];
        if (!record.Run_Apex_Code__c) {
            List<AggregateResult> results = DataBase.Query(record.SOQL__c);
            count = Integer.valueOf(results[0].get('cnt'));
        }
        else {
            List<String> ids = runApexCode(record.Apex_Code__c);
            if (ids != null) {
                count = ids.size();
            }
        }
        Report r = new Report();
        if (count >= 0) {
            record.count__c = count;
            record.Last_Run_Date_Time__c = system.now();
            update record;
            r.count = Integer.valueOf(record.count__c);
            r.lDateTime = record.Last_Run_Date_Time__c;
        }
        else {
            r.lastRunDateTime = 'Failed to Run';
            r.count = -1;
        }
        
        return r;
    }
    
    @AuraEnabled
    public static String sendEmailSingleReport(Report rep) {
        String ret = 'Email Sent!';
        system.debug(rep.name);
        System_Monitoring_Report__c record = [SELECT Red_Threshold__c,Apex_Code__c,Run_Apex_Code__c,SOQL__c,Field_Names_For_Email__c,Email_Template_Name__c,To_Email_List__c,Send_Attachment__c FROM System_Monitoring_Report__c WHERE Name =:rep.Name];
        String query = record.SOQL__c;
        query = query.replace('Count(Id)cnt', record.Field_Names_For_Email__c);
        if (record.Run_Apex_Code__c) {
            //List<String> ids = [SELECT Record_Ids__c FROM System_Monitoring_Report_Result__c WHERE System_Monitoring_Report__c = :record.Id AND CreatedBy.Id =:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1].Record_Ids__c.split(',');
            List<String> ids = runApexCode(record.Apex_Code__c);
            query += ' (\''+ String.join(ids, '\',\'')+ '\')';
        }
        try {
           system.debug('Query -- ' + query);
           List<String> fields = record.Field_Names_For_Email__c.split(',');
           List<Map<String, Object>> records = getRecords(query, fields);
           
           List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String htmlBody = rep.comments!=null?rep.comments.replaceAll('\n', '<br/>'):'';
           if (record.Email_Template_Name__c != null)  {   
               EmailTemplate et=[Select id from EmailTemplate where Name=:record.Email_Template_Name__c]; 
               mail = Messaging.renderStoredEmailTemplate(et.Id, null, null);
               String tempBody = mail.getPlainTextBody();
               //htmlBody = '';
               if (tempBody != null) {
                   htmlBody += tempBody.replaceAll('\n' , '<br/>');
               }
               tempBody = mail.getHTMLBody();
               if (tempBody != null) {
                   htmlBody += tempBody;
               }
           }
           mail.setToAddresses(record.To_Email_List__c.split(';'));
           mail.setSenderDisplayName(UserInfo.getUserName()); 
           mail.setSubject(rep.count + ' ' + rep.name + ' (' + System.now().format('MM/dd/yyyy') + ')');
           if ((record.Send_Attachment__c) || (rep.count > record.Red_Threshold__c)) {
               Messaging.EmailFileAttachment attachment = getAttachment(records, record.Field_Names_For_Email__c);
               attachment.setFileName(rep.name + ' ' +system.now() + '.csv');
               mail.setFileAttachments(new List <Messaging.EmailFileAttachment>{attachment});
           }
           else {
               htmlBody += getEmailBody(records, fields);
           }
           system.debug(htmlBody);
           mail.setHtmlBody(htmlBody);
           mail.saveAsActivity = false;
           mails.add(mail);
           Messaging.sendEmail(mails);
       }   
       catch (Exception e) {
           system.debug(e.getMessage());
           ret = e.getMessage();
       }
       return ret;
    }
    
    private static List<Map<String, Object>> getRecords(String query, List<String> fields) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (sObject rec : DataBase.query(query)) {
            Map<String, Object> record = new Map<String, Object>();
            for (String field:fields) {
                sObject obj = rec;
                List<String> strs = field.split('\\.');
                for (integer i=0; i<strs.size()-1; i++) {
                    if (obj != null) {
                        obj = obj.getSObject(strs[i]);
                    }
                }
                if (obj != null) {
                    record.put(field, obj.get(strs[strs.size()-1]));
                }
           
            }
            records.add(record);
            
       }
       return records;
    }
    
    private static Messaging.Emailfileattachment getAttachment(List<Map<String, object>> records, String header) {
       String csv = header;
       for (Map<String, Object> rec: records) {
           csv += NewLine;
           for (String field : header.split(',')) {
               String value = string.ValueOf(rec.get(field));
               value = value!=null&&value.contains(quotes)?value.replaceAll(quotes, quotes+quotes):value;
               csv += quotes + value + quotes + ',';
           }
       }
       Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
       attachment.setBody(blob.valueOf(csv));
       return attachment;
    }
    
    private static String getEmailBody(List<Map<String, object>> records, List<String> fields) {
       String messageBody = '<html><body>REPLACE</body></html>';
       String body = '<br/> <table border="1" cellspacing="0" cellpadding="5" style="font-family: sans-serif;font-size: 14px;">';
       body += '<tr style="background-color: #D3D3D3;">';
       for (String field : fields) {
           body += '<th>' + field + '</th>';
       }
       body += '</tr>';
       for (Map<String, Object> rec: records) {
           body += '<tr>';
           for (String field : fields ) {
               
               if (field == 'Id') {
                   body += '<td> <a href='+ System.URL.getSalesforceBaseUrl().toExternalForm()+ '/' + rec.get(field) + '>' + rec.get(field) + '</a></td>';
               }
               else {
                   body += '<td>' + rec.get(field) + '</td>';
               }
           }
           body += '</tr>';
       }
       body = body + '</table><br/><br/>';
       system.debug(body);
       return messageBody.replace('REPLACE', body);
    }
    
    @AuraEnabled
    public static String sendEmailCategoryReports(String category, List<Report> reports) {
       String ret = 'Email Sent!';
       try {
           System_Monitoring_Category__c cat = [SELECT Email_Subject__c,To_Email_List__c FROM System_Monitoring_Category__c WHERE Name=:category LIMIT 1];
           List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setToAddresses(cat.To_Email_List__c.split(';'));
           mail.setSenderDisplayName(UserInfo.getUserName()); 
           mail.setSubject(cat.Email_Subject__c +' (' + System.now().format('MM/dd/yyyy') + ')');    
           String messageBody = '<html><body>REPLACE</body></html>';
           String body = '<br/> <table border="1" cellspacing="0" cellpadding="5" style="font-family: sans-serif;font-size: 14px;">';
           body += '<tr style="background-color: #D3D3D3;">';
           body += '<th style="padding:15px;width: 100px;">Report Name</th>';
           body += '<th style="padding:15px;width: 200px;">Report Details</th>';
           body += '<th style="padding:15px;width: 50px;">Count</th>';
           body += '<th style="padding:15px;width: 300px;">Comments</th>';
           body += '</tr>';
           for (Report rep: reports) {
               rep.reportDetails = (rep.reportDetails == 'null' || rep.reportDetails == null)? ' ' : rep.reportDetails;
               rep.comments = (rep.comments=='null'||rep.comments==null)?' ':rep.comments;
               body += '<tr>';
               body += '<td>' + rep.Name + '</td>';
               body += '<td>' + rep.reportDetails + '</td>';
               body += '<td style="text-align:center">' + rep.count+ '</td>';
               body += '<td>' + rep.comments + '</td>';
               body += '</tr>';
           }
           body = body + '</table><br/><br/>';
           system.debug(body);
           messageBody = messageBody.replace('REPLACE', body);
           mail.setHtmlBody(body);
           mail.saveAsActivity = false;
           mails.add(mail);
           Messaging.sendEmail(mails);
       }
       catch (exception e) {
           ret = e.getMessage();
       }
       return ret;
    }
}