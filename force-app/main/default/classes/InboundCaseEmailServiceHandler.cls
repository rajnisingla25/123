// (c) 2015 Appirio, Inc.  
//
// Class Name: InboundCaseEmailServiceHandler
// Description: HandlerClass for InboundCaseEmailService
//
// 28th April 2015    Ravindra Shekhawat   Original (Task # T-382152)
//
public with sharing class InboundCaseEmailServiceHandler { 
    
    
    public class fromaddrs{
        string display;
        string address;
        string is_group;
    }
    
    public class toaddrs{
        string display;
        string address;
        string is_group;
    }
    
    public class ccaddrs{
        string display;
        string address;
        string is_group;
    }
    
    public class bccaddrs{
        string display;
        string address;
        string is_group;
    }
    
    public class emailwrapper{
        string subject;
        list<fromaddrs> from1;
        list<toaddrs> to;
        list<ccaddrs> cc;
        list<bccaddrs> bcc;
        string caseId;
        string pid;
        string sfu;       
    }
    
    //Final variables to store error msgs
    public static final String caseCreatedMessage ='Case Has Been Created Successfully.';
    private static final String subjectNullErrorMsg ='Subject cannot be Empty\n';
    private static final String bodyNullErrorMsg ='Body cannot be Empty\n';
    private static final String noEmailConfiguredErrorMsg = 'No Email Address Has Been Configured for Email-To-Case Functionality!\n';
    private static final String userNotAuthorizedForEmailToCase = 'You are not Authorized For Email-To-Case Functionality!\n';
    // Error Message To Be Sent To User
    private static String errorMessage ='Cannot Create the Case Due to Following Reason/s\n\n';
    // A map of Email & Config_EmailToCase__c object
    private Map<String,Config_EmailToCase__c> caseEmailConfigMap = new Map<String,Config_EmailToCase__c>();
    // Current Config_EmailToCase__c object Found Using FromEmail
    private Config_EmailToCase__c currentEmailCaseConfig;
    // Current User Found using FromEmail
    private Contact currentContact;
    // Current Account For Case
    private Id accountId;
    // Queue to which case to be assigned
    private Group assignToQueue;
    // Flag to denote whether ToAddress is defined in custom setting
    private boolean isGeneralEmail = false;
    // Case Id used while Sending Email for Merge Fields
    private Id caseId;
    // Constructor
    public InboundCaseEmailServiceHandler() { 
    }
    
    /**
    *  This Method Creates A Case From Email
    *  @subject : Subject of The Email
    *  @body : Body of the Email
    *  @fromEmail : From Email Address
    *  @toEmail : To Email Address
    *  @result : Messaging.InboundEmailResult Object
    */  
    public Messaging.InboundEmailResult createCase(Messaging.InboundEmail oemail,String subject,String body,String fromEmail,String toEmail,Messaging.InboundEmailResult result) {
        getEmailConfigMap(); 
        accountId=null;
        currentContact=null;
        // Validate The Email
        if(validateEmail(subject,body,toEmail)) {
            // Check if Email Came from Unkonwn Email
            if(isGeneralEmail) {
                currentEmailCaseConfig = new Config_EmailToCase__c();
                currentEmailCaseConfig.Queue_Name__c = Constants.MOVE_GENERAL_OPEN_QUEUE;
                currentEmailCaseConfig.Case_Type__c = Constants.MOVE_GENERAL_EMAIL_CASE_TYPE;
                currentEmailCaseConfig.Priority__c = Constants.CASE_PRIORITY_MEDIUM;
            } else {
                currentEmailCaseConfig = caseEmailConfigMap.get(toEmail);
            }
            
            checkForUrgentKeyWord(subject);
            getQueueByName(currentEmailCaseConfig.Queue_Name__c);
            getContactFromEmail(fromEmail);
            SavePoint pSavepoint = DataBase.setSavepoint();
            
            try{ 
                // Insert New Case
                Case newCase = populateCaseObject(subject,body,fromEmail,currentEmailCaseConfig.Queue_Name__c);
                if(newCase!=null) {
                    System.debug('New Case AccountId is : '+newCase.AccountId);
                    string ocaseId = '';
                    system.debug('****bodycase***'+body);
                    ocaseId = getCaseIDfromBody(body);
                    if(ocaseid == '')
                        ocaseId =   getCaseIDfromBody(subject);
                    
                    if(ocaseId == ''){
                        insert newCase;
                    }
                    else{
                        newcase.Id = ocaseId ;
                        case ocase2 = [SELECT ID,subject,Description,CaseNumber,lastmodifieddate from Case WHERE ID=: newcase.ID];
                        newcase.subject = ocase2.subject;
                        newcase.Description  = ocase2.Description;
                        
                        update newcase;
                    }
                    createEmailMessage(oemail,newcase.ID,subject,body);                                                                                                                        
                    system.debug('newcase:'+newCase);
                }
                caseId = newCase.Id;
                result.success = true;
            }catch(Exception ex) {
                /* Roll back to save point */
                DataBase.rollback(pSavepoint);
                result.success = false;
                result.message = ex.getMessage();
            }
        }else{
            result.success = false;
            result.message = errorMessage;
        }
        System.debug('Trace: in CreateCase: '+result);
        return result;  
    }
    
    public void createEmailMessage(Messaging.InboundEmail oemail,Id caseID,string osubject,string obody)
    {
        system.debug('In create email message'+oemail);
        string toaddrses ;
        string ccaddrses ;
        string bccaddrses ;
        
        
        system.debug('In create email message'+oemail.fromAddress);        
        system.debug('In create email message'+oemail.ccAddresses);               
        
        
        
        
        if(oemail.toAddresses != null && oemail.toAddresses.size() > 0){
            for(string toloop :oemail.toAddresses ){
                if(toaddrses == null){
                    toaddrses = toloop;
                }else{
                    toaddrses += ',' + toloop;
                }
            }
        }
        
        if(oemail.ccAddresses != null && oemail.ccAddresses.size() > 0){
            for(string ccloop :oemail.ccAddresses){
                if(ccaddrses == null){
                    ccaddrses = ccloop;
                }else{
                    ccaddrses += ',' + ccloop;
                }
            }
        }
        
        
        //create email message on case
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = oemail.FromAddress,
                                      FromName = oemail.FromName,
                                      ToAddress = toaddrses,
                                      CCAddress = ccaddrses ,
                                      MessageDate = system.Now(),
                                      Subject = oemail.subject,
                                      HtmlBody = obody,
                                      Status = '2',
                                      ParentId = caseID)
                    );
        insert newEmail;        
    }
    public string getCaseIDfromBody(string body){
        
        
        string threadId = '';
        Pattern p = Pattern.compile('ref\\:_[0-9a-zA-Z]+\\._[0-9a-zA-Z]+\\:ref');
        Matcher m = p.matcher(body);
        if (m.find()) {
            for (; m.group() == '' && m.find(); );
            threadId = m.group();    
        }
        
        
        if(threadId != '')
            return ''+ Cases.getCaseIdFromEmailThreadId(threadId);   
        else
            return   '';     
        
    }
    //send email that received from C3tools
    public Messaging.InboundEmailResult sendingemailmethod(String subject,String body,String fromEmail,String toEmail,Messaging.InboundEmailResult result){
        string toaddrses;
        string ccaddrses;
        string bccaddrses;
        string frmaddrses;
        string fromemailpredicator;
        
        system.debug('subject:'+subject);
        JSONParser parser = JSON.createParser(subject);
        emailwrapper emaildata = (emailwrapper)parser.readValueAs(emailwrapper.class);
        system.debug('emaildata:'+emaildata);
        
        if(emaildata.from1.size() > 0){
            for(fromaddrs frmloop :emaildata.from1){
                if(frmaddrses == null){
                    frmaddrses = frmloop.address;
                }else{
                    frmaddrses += ',' + frmloop.address;
                }
            }
        }
        
        if(emaildata.to.size() > 0){
            for(toaddrs toloop :emaildata.to){
                if(toaddrses == null){
                    toaddrses = toloop.address;
                }else{
                    toaddrses += ',' + toloop.address;
                }
            }
        }
        system.debug('toaddrses'+toaddrses);
        if(emaildata.cc.size() > 0){
            for(ccaddrs ccloop :emaildata.cc){
                if(ccaddrses == null){
                    ccaddrses = ccloop.address;
                }else{
                    ccaddrses += ',' + ccloop.address;
                }
            }
        }
        
        if(emaildata.bcc.size() > 0){
            for(bccaddrs bccloop :emaildata.bcc){
                if(bccaddrses == null){
                    bccaddrses = bccloop.address;
                }else{
                    bccaddrses += ',' + bccloop.address;
                }
            }
        }
        
        //Retrieving user data
        Case  Casedata = [SELECT Thread_ID__c,Accountid,ContactId,type FROM Case where id = :emaildata.caseid];
        //Retrieving case data
        user userdata = [select name,email,id from user where alias = :emaildata.sfu limit 1];
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toaddrses};
            mail.setToAddresses(toAddresses);
        if(ccaddrses != null){
            String[] ccAddresses = new String[] {ccaddrses};
                mail.setCcAddresses(ccAddresses);
        }
        if(bccaddrses != null){
            String[] bccAddresses = new String[] {bccaddrses};
                mail.setBccAddresses(bccAddresses);
        }
        //mail.setReferences(Casedata.Thread_ID__c);
        //retrive orgwide email address id for from address
        fromemailpredicator = FromEmailAddresses__c.getInstance(Casedata.Type).FromAddress__c;
        OrgWideEmailAddress orgwidedata = [SELECT Id FROM OrgWideEmailAddress where Address = :fromemailpredicator limit 1];
        //mail.setSubject(emaildata.subject + Casedata.Thread_ID__c);
        mail.setSubject(emaildata.subject);
        mail.setBccSender(false);
        mail.setUseSignature(true);
        mail.setHtmlBody(body + '\r\n' + Casedata.Thread_ID__c);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        List<Task> tasks = new List<Task>();
        //creates a task on case
        tasks.add(new Task(ActivityDate = Date.today(),
                           //Subject= emaildata.subject + Casedata.Thread_ID__c,
                           Subject= emaildata.subject,
                           WhatId = emaildata.caseId,
                           OwnerId = userdata.id,
                           Status='Completed',
                           Type = 'Email',
                           Priority = 'Normal' )
                 );
        //creates a task on Account and Contact
        tasks.add(new Task(ActivityDate = Date.today(),
                           //Subject= emaildata.subject + Casedata.Thread_ID__c,
                           Subject= emaildata.subject,
                           WhatId = Casedata.AccountId,
                           WhoId = Casedata.ContactId,
                           OwnerId = userdata.id,
                           Status='Completed',
                           Type = 'Email',
                           Priority = 'Normal' )
                 );
        insert tasks;        
        
        //create email message on case
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = userdata.email,
                                      FromName = userdata.name,
                                      ToAddress = toaddrses,
                                      CCAddress = ccaddrses,
                                      BCCAddress = bccaddrses,
                                      MessageDate = system.Now(),
                                      Subject = emaildata.subject,
                                      HtmlBody = Body,
                                      ParentId = emaildata.caseId, 
                                      ActivityId = tasks[0].Id)
                    );
        insert newEmail;        
        
        result.success = true;
        return result;  
    }
    
    //send email that received from C3tools
    public Messaging.InboundEmailResult createreplyactivity(String subject,String body,String fromEmail,String toEmail,Messaging.InboundEmailResult result){
        string caseids = '';
        string threadId = '';
        case casedata = new case();
        system.debug('subject:'+subject);
        
        //Retrieving caseid using threadid
        Pattern p = Pattern.compile('ref\\:_[0-9a-zA-Z]+\\._[0-9a-zA-Z]+\\:ref');
        system.debug('pattern:'+p);
        //Matcher m = p.matcher(subject);
        Matcher m = p.matcher(body);
        if (m.find()) {
            for (; m.group() == '' && m.find(); );
            threadId = m.group();    
            system.debug('threadId:'+threadId);
        }
        
        if(threadId != ''){
            caseids =  ''+ Cases.getCaseIdFromEmailThreadId(threadId);   
            system.debug('caseids:'+caseids);
            if (caseids != null){
                casedata = [select contactid,accountid,ownerid,(select id,ownerid from tasks order by CreatedDate DESC LIMIT 1) from case where id = :caseids];
            }
        }
        
        //creates a task on case
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(ActivityDate = Date.today(),
                           Subject= subject,
                           WhatId = caseids,
                           OwnerId = casedata.tasks[0].Ownerid,
                           Status='Completed',
                           Type = 'Email',
                           Priority = 'Normal' )
                 );
        
        //creates a task on Account and Contact
        tasks.add(new Task(ActivityDate = Date.today(),
                           Subject= subject,
                           WhatId = casedata.accountid,
                           WhoId = casedata.Contactid,
                           OwnerId = casedata.tasks[0].Ownerid,
                           Status='Completed',
                           Type = 'Email',
                           Priority = 'Normal' )
                 );
        insert tasks;        
        
        
        //create email message on case
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = fromEmail,
                                      ToAddress = 'customerresponse@realtor.com',
                                      Subject = subject,
                                      MessageDate = system.Now(),
                                      HtmlBody = Body,
                                      ParentId = caseids,
                                      Status = '0',
                                      ActivityId = tasks[0].Id)
                    );
        insert newEmail;        
        
        result.success = true;
        return result;  
    }
    
    /**
    * Validate if Inbound Email
    * @subject : Subject of the Email
    * @body : body of the Email
    * @fromEmail : Email Address of the Sender
    */
    private boolean validateEmail(String subject,String body,String toEmail) {
        boolean isValid = true;
        // Check if Email Addresses are configured in Custom Setting
        if(!(caseEmailConfigMap.size()>0)){
            errorMessage += noEmailConfiguredErrorMsg;
            isValid = false;
        }
        // Check if Subject is Not Null Or Empty
        if(subject == null  || subject.trim() == ''){
            errorMessage += subjectNullErrorMsg;
            isValid = false;
        }
        // Check if Body is Not Null Or Empty
        if(body == null || body.trim() == ''){
            errorMessage += bodyNullErrorMsg;
            isValid = false;
        }
        //Check if From Address Exists in The Email Configured Map
        if(caseEmailConfigMap.get(toEmail)==null){
            isGeneralEmail = true;
        }
        return isValid;
    }
    
    /**
    * Get User from From Email
    * @fromEamil: From Email
    */
    private void getContactFromEmail(String fromEmail) {
        List<Contact> contactList = [SELECT id FROM Contact WHERE Email =: fromEmail and Active__c = true];
        system.debug('contactList:'+contactList);
        if(contactList!=null && contactList.size() == 1){
            currentContact =  contactList[0];
            getAccountFromContact(currentContact);
        }
    }
    
    
    /**
* Create Map of Email and Config_EmailToCase__c Object
*/
    private void getEmailConfigMap() {
        if(Config_EmailToCase__c.getAll()!=null && Config_EmailToCase__c.getAll().size()>0){
            for(Config_EmailToCase__c config : Config_EmailToCase__c.getAll().values())  {
                caseEmailConfigMap.put(config.Email_Address__c,config);
                System.debug('Trace: in getEmailConfigMap'+config);
            }
        }     
    }
    
    /**
    * Populate A Case Object
    * @subject: Case Subject
    * @body : Case Description
    */
    private Case populateCaseObject(String subject, String body,string fromEmail,string quename) {
        Case newCase;
        try {
            newCase = new Case();
            newCase.Subject = subject;
            newCase.Description = body;
            newCase.Incoming_Email_Address__c = label.Incoming_Email_Address;
            newcase.Initial_Queue_Owner__c    = quename;
            newCase.Type = currentEmailCaseConfig.Case_Type__c;
            newCase.Priority = currentEmailCaseConfig.Priority__c;
            newCase.Origin = Constants.EMAIL_ORIGIN;
            newCase.SuppliedEmail = fromEmail;
            if(currentContact != null) {
                newCase.ContactId = currentContact.Id;
            }
            if(accountId != null) {
                newCase.AccountId = accountId;
            }
            if(assignToQueue != null){
                newCase.OwnerId = assignToQueue.Id;
            }
        }catch(Exception e) {
            newCase = null;
            errorMessage = e.getMessage();
        }
        return newCase;
    }
    
    /**
    * This method return the Queue Object based on Queue Name
    * @queueName : Name of the Queue
    */
    private void getQueueByName(String queueName) {
        List<Group> queueList = [SELECT Id FROM Group WHERE Name =: queueName AND Type = 'Queue'];
        if(queueList!=null && queueList.size()>0){
            assignToQueue =  queueList[0];
        }else {
            // Assign to Default Queue : If Queue Mentioned is Not Found
            queueList = [SELECT Id FROM Group WHERE Name = 'Default Case Queue' AND Type = 'Queue'];
            if(queueList!=null && queueList.size()>0)
                assignToQueue = queueList[0];
        }
    }
    
    /**
    * This Method Check If The Email Subject Contain Keywords Defined in the Custom Setting
    * @subject: Email Subject
    */
    private void checkForUrgentKeyWord(String subject) {
        for(String s:Constants.URGENT_KEYWORDS.split(',')) {
            if(subject.containsIgnoreCase(s)) {  
                currentEmailCaseConfig.Priority__c = 'URGENT';
                return;
            }
        }
    }
    
    // This method returns the Account from Account_Relationship object for the current Contact 
    private void getAccountFromContact(Contact currentContact) {
        try {
            List<Account_Relationship__c> contactRelationships = [SELECT Id,Parent_Account__c FROM Account_Relationship__c WHERE ( Contact_To__c =: currentContact.Id AND 
                                                                                                                                  RecordType.DeveloperName =: Constants.CONTACT_RELATIONSHIP_RECORDTYPE_NAME) AND Active__c = true];  
            System.debug('Trace: In getAccountFromContact :Contact Relationships :'+ contactRelationships);
            if(contactRelationships != null && contactRelationships.size() == 1) {
                System.debug('Assigning Account Current : '+contactRelationships.size());
                System.debug('Assigning Account Current : '+contactRelationships.get(0).Parent_Account__c);
                accountId = contactRelationships.get(0).Parent_Account__c;
            }
            
        }catch(Exception e) {
            System.debug('Exception Occured While Getting Account Relationships : '+e.getMessage());
        }
    }
    
    /**
    * Getter method for CaseId
    */   
    public Id getCaseId() {
        return caseId;
    }
    
    /**
    * Getter for Contact
    */
    public Contact getCaseContact() {
        return currentContact;
    }
    
    // Mortgage Start
    public Messaging.InboundEmailResult closeMortgageManaulFulfillmentCase(String subject, String body, Messaging.InboundEmailResult result) {
        SavePoint pSavepoint = DataBase.setSavepoint();
        result.success = true;
        try {
            Pattern p1 = Pattern.compile('.*Asset Id:(.*)');
            Matcher m1 = p1.matcher(subject);
            String assetId = null;
            if (m1.find()) {
                for (; m1.group() == '' && m1.find(); );
                assetId = m1.group(1).trim();
            }
            system.debug('Assetid' + assetId);
            if (assetId != null && assetId != '') {
                List<String> mortgageProdCodes = Label.Mortgage_Product_Codes.split(',');
                system.debug('mortgageProdCodes' + mortgageProdCodes);
                List<Asset> asset = [SELECT Line_Type__c, Cake_Id__c, Order_Line_Item__r.OrderId FROM Asset WHERE Id =:assetId AND Product_Code__c IN :mortgageProdCodes AND Fulfillment_Status__c='Fulfilled' limit 1];
                if (asset.size() > 0) {
                    if (asset[0].Line_Type__c == 'Add' || asset[0].Cake_Id__c == null) {
                        Pattern p2 = Pattern.compile('.*CAKE Id:(.*)\n');
                        Matcher m2 = p2.matcher(body);
                        string cakeId = null;
                        if (m2.find()) {
                            for (; m2.group() == '' && m2.find(); );
                            cakeId = m2.group(1);
                        }
                        system.debug('cakeId' + cakeId);
                        if (cakeId != null && cakeId != '') {
                            asset[0].Cake_Id__c = cakeId;
                            update asset[0];
                        }
                    }
                    if (asset[0].Cake_Id__c != null) {
                        List<Case> cases = new List<Case>();
                        for(case c :[SELECT Status FROM Case WHERE Order__c=:asset[0].Order_Line_Item__r.OrderId AND Type='Order' AND Status != 'Closed']) {
                            c.status = 'Closed';
                            cases.add(c);
                        }
                        if (!cases.isEmpty()) {
                            update cases;
                        }
                    }
                    else {
                        result.success = false;
                        result.message = 'Cake Id Not Found!';
                    }
                }
            }
            else {
                result.success = false;
                result.message = 'Asset Id Not Found!';
            }
        }
        catch(Exception ex) {
            DataBase.rollback(pSavepoint);
            result.success = false;
            result.message = ex.getMessage();
        }
        return result;
    }
    // Mortgage End
}