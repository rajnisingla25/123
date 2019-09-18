// (c) 2015 Appirio, Inc.  
//
// Class Name: InboundCaseEmailService
// Description: InboundEmailService for Case Creation through Email
//
// 28th April 2015    Ravindra Shekhawat   Original (Task # T-382152)
//
global class InboundCaseEmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        boolean createactivities = false;
        list<FromEmailAddresses__c> FromEmailAddresses = FromEmailAddresses__c.getall().values();
        
        for(FromEmailAddresses__c emailloop : FromEmailAddresses){
            if(emailloop.FromAddress__c == email.toAddresses[0]){
               createactivities = true; 
            }
        }
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try {
            InboundCaseEmailServiceHandler serviceHandler = new InboundCaseEmailServiceHandler();
            System.debug('TRACE: IN handleInboundEmail -- CONFIRMATION CODE : '+email.plainTextBody);
            // Mortgage Start
            if(Label.Mortgage_Cake_User_Email_Address.contains(email.fromAddress)){
                serviceHandler.closeMortgageManaulFulfillmentCase(email.subject,email.plainTextBody,result);
            }
            // Mortgage End
            else if(email.fromAddress == 'c3tools@realtor.com'){
                System.debug('html body: '+email.HtmlBody);                                
                serviceHandler.sendingemailmethod(email.subject,email.htmlBody,email.fromAddress,email.toAddresses[0],result);   
            }else if(createactivities){
                createactivities = false;
                System.debug('fromAddress1:'+email.fromAddress);
                serviceHandler.createreplyactivity(email.subject,email.htmlBody,email.fromAddress,email.toAddresses[0],result);   
            }else{
                System.debug('email instance:'+email);
                // Call Service Handler to create Case
                serviceHandler.createCase(email,email.subject,email.plainTextBody,email.fromAddress,email.toAddresses[0],result);  
                Contact cont = serviceHandler.getCaseContact();
                EmailTemplate et;
                if(Test.isRunningTest()) {
                    et = [Select Id, Subject, HtmlValue, Body from EmailTemplate LIMIT 1];
                }
                else {
                    // Get Email Template
                    et = [Select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName=: Constants.EMAIL_TO_CASE_SUCCESS_TEMPLATE];
                }
                // If Case Successfully created Send Email Confirmation 
                if(result.success && cont != null) {  
                    System.debug('Case Successful and Found Contact'); 
                    // Parse the Email Template to Replace Merge Fields With Values in Html/Text Body
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(et.Id);
                    mail.setTargetObjectId(cont.Id);
                    mail.setCcAddresses(new String[]{String.valueOf(email.fromAddress)});
                    mail.setWhatId(serviceHandler.getCaseId());
                    mail.setSaveAsActivity(false);
                    mail.setSenderDisplayName('Move-Email To Case Team');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                } else if(result.success){
                    System.debug('Case Successful and Did Not Find Contact'); 
                    result.message = et.Body; 
                }
            }
        }catch(Exception e) {
            System.debug('Exception Occured: '+e.getMessage()); 
            System.debug('getStackTraceString Occured: '+e.getStackTraceString()); 
            System.debug('getLineNumber Occured: '+e.getLineNumber()); 
        }
        return result;   
        
    } 
}