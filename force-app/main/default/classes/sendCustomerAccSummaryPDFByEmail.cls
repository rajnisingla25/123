global class sendCustomerAccSummaryPDFByEmail{
    global static boolean isEmailSignature {get;set;}

    global sendCustomerAccSummaryPDFByEmail(){
        isEmailSignature = false;
         Id userId = UserInfo.getUserId();
        String u = [Select id, signature from user where id = :userId][0].signature; 
        if(u != '' && u != null){
isEmailSignature = true;
        }
    }
    
    WebService static String verifyIfEmailAlreadySent(string accountId){
        isEmailSignature = false;
        List<Task> existingTaskList = [select id, createdDate from Task where WhatId =:accountId 
                                       and subject ='Sent Customer Account Summary' and status ='Completed' and type = 'Email'
                                       order by CreatedDate desc limit 1];

        if(existingTaskList.isEmpty()){
            Datetime dt = DateTime.now();
            String currentDT = dt.format('MMMM d, yyyy');
            return 'The Customer Account Summary will be generated on '+currentDT+'. Do you want to send it now?';
        } else {
            Datetime dt = existingTaskList[0].createdDate;
            String createdDT = dt.format('MMMM d, yyyy');
            return 'The Customer Account Summary was already sent on '+createdDT+'. Would you like to send it again now?';

        }
        
    }
    WebService static string emailAccountSummaryPdf(string accountId){
        string attachement;
        Id conId;
        isEmailSignature = false;
        
        List<Asset> assetlist = new List<Asset> ();
        assetlist = [Select id from Asset where 
                     Status = 'Active' and Fulfillment_Status__c != 'Failure' and Asset_Type__c = 'Parent' and AccountId =: accountId limit 1];
        
        if(assetlist.isEmpty()) {
            return 'There are no Active Assets on this account, so no Account Summary will be sent.';
        }
        
        PageReference pdfPage = Page.customerAccountSummary;
        Id currentLoggedInUser;
        List<User> userDetail;
        pdfPage.getParameters().put('id',accountId);
        Blob pdf1;
        if (Test.IsRunningTest())
        {
            pdf1 = Blob.valueOf('UNIT.TEST');
        } else {
            pdf1 = pdfPage.getContentAsPDF();
        }
        
        // Get Primary contact Email address
        List <Account_Relationship__c> accConRelList = [select id, Parent_Account__r.name, Parent_Account__r.email_address__c, Contact_To__c, Contact_To__r.email, Contact_To__r.name 
                                                        from Account_Relationship__c 
                                                        where Relationship_Type__c = 'Contact' and Parent_Account__c =:accountId
                                                        and Contact_Role__c = 'Primary Contact' limit 1];
       
        List < String > toAddresses = new List < String > ();
        for(Account_Relationship__c accConRel : accConRelList){
            // ACP: Send email to account's email
            toAddresses.add(accConRel.Parent_Account__r.email_address__c);
            attachement = accConRel.Parent_Account__r.name;
            conId = accConRel.Contact_To__c;
        }
        
        String fromEmail = System.Label.CustomerAcctSummaryFromEmail;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :fromEmail];
        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Customer Account Summary'];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Create an email attachment 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(attachement+ '.pdf');
        efa.setBody(pdf1);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        // Send Email template as body
        mail.setTemplateID(templateId.Id); 
        mail.setWhatId(conId);
        mail.setTargetObjectId(conId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSaveAsActivity(false);

        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        system.debug('status--->>>'+r[0].success);
        
        // If email sent successfully then create a task on account
        if(r[0].success){
            Set<task> taskSet = new Set<task>();
            List<task> taskList = new List<task>();
    
            task t = new task();
            t.type = 'Email';
            t.subject = 'Sent Customer Account Summary';
            t.status = 'Completed';
            t.WhatId = accountId;
            t.Outcome__c = 'Emailed Account Summary';
            t.ActivityDate = Date.today();
            taskSet.add(t);
            if(!taskSet.isEmpty()){
                taskList.addAll(taskSet);
                if(!Test.IsRunningTest()){
                    insert taskList;}
                system.debug('task---'+taskList);
            }
            
        }
        return 'An email has been sent to the customer and a new Task has been generated under Activity History on the Account.';
    }
}