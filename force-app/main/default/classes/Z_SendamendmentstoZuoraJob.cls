//CRM-3328 Zuora Process to Suspend and Resume all Active Current CoBroke Subscriptions.
global class Z_SendamendmentstoZuoraJob implements 
Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {  
    global final String Query;     
    global String effectivedates;
    global String actions; 
    global String casnumber; 
    
    global Z_SendamendmentstoZuoraJob(String q, String Effectivedate, String Action, String casenumber)  
    {  
        system.debug('eft' + Effectivedate + 'act' + Action);
        Query=q;
        effectivedates =Effectivedate;
        actions=Action;   
        casnumber = casenumber;
    }  
    
    global Integer RecordsFailed = 0;
    global Integer RecordsProcessed = 0;
    global Integer TotalNumberofRecords = 0;  
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);          
    }
    
    global void execute(Database.BatchableContext bc, List<Zuora__Subscription__c> scope){
        List<Zuora__Subscription__c> Results =new  List<Zuora__Subscription__c>();
        String Description = 'Amend from Lead suspension Case'; 
        z_amendsubscription.zuoraApiAccess(); 
        for(Zuora__Subscription__c inloop: scope) { 
            String Result ='';
            TotalNumberofRecords++;
            system.debug('Sub ' + inloop + 'ect' + effectivedates + 'act' + actions);                    
            Result = Z_amendsubscription.createAmendment(inloop.name,inloop.Zuora__Zuora_Id__c,effectivedates,Description, actions,'Leadsuspensioncase'); 
            if(Result!=null && Result.contains('Failed to amend Subscription')){
                RecordsFailed++;
                Zuora__Subscription__c sub = new Zuora__Subscription__c();
                Sub.Id = inloop.Id;
                sub.Zuora_Comment__c = Result;
                Sub.Status__c = 'Error';
                Results.add(sub);
            }else{
                Zuora__Subscription__c sub = new Zuora__Subscription__c();
                sub.Status__c = 'Processed';
                sub.Id = inloop.Id;
                Results.add(sub);
                RecordsProcessed++;
            }
        }
        if(Results.size()>0)
            update Results;       
    }
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed ');
       
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        if(RecordsFailed > 0 || (job.NumberOfErrors!=null && job.NumberOfErrors >0 || Test.isRunningTest())){
            String toAddresses = job.CreatedBy.Email;
            String custAddresses = Error_Notification_Email_Settings__c.getInstance('SuspensionEmail').Suspension_Failure__c;   
            if(custAddresses!=null)
               toAddresses += ';'+custAddresses;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                     
            mail.setToAddresses(toAddresses.split(';'));
            mail.setSubject('Suspend/Resume Failure '+ casnumber);
            String messageBody = '<html><body> Total Number of Records: ' +TotalNumberofRecords + '<br><br> Records Processed: ' +RecordsProcessed+ '<br><br> Records Failed: ' +RecordsFailed + '<br><br> Job Details : '+job+'</body></html>';
            mail.setHtmlBody(messageBody);       
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
}