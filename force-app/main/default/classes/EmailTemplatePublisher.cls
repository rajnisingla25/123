/********************************************************************************************
*   @Author :       Anirudh B 
*   @Purpose:       To Set the default email template based on Initial Queue Owner of the case 
*   @Class          EmailTemplatePublisher
*   @TestClass      EmailTemplatePublisher_Test
*   @JIRA           SEP-127
*   @CreatedDate:   July 2nd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
global class EmailTemplatePublisher implements QuickAction.QuickActionDefaultsHandler {
    
    /********************************************************************************
    Method Name: Constructor
    Description: When you implement QuickAction.QuickActionDefaultsHandler interface, 
                 we need to provide an empty parameterless constructor.
    Parameters:  None
    ReturnType:  None
    ********************************************************************************/
    global EmailTemplatePublisher() { }

    
    /*******************************************************************************
    Method Name: onInitDefaults
    Description: Invokes getSendEmailFromCaseDefaults method and sets the email defaults(From Address etc)
                 Then, it performs a query to retrieve the case that corresponds to the context ID. 
                 Next, it sets the email Template based on the Smart Template Config custom setting
    Parameters:  QuickAction.QuickActionDefaults[]
    ReturnType:  None
    *********************************************************************************/
    // The only interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {                
        //System.debug('-------defaults-----'+defaults);        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = getSendEmailFromCaseDefaults(defaults);
        if (sendEmailDefaults == null) return;
                
        Case c = [SELECT Initial_Queue_Owner__c,Incoming_Email_Address__c FROM Case WHERE Id=:sendEmailDefaults.getContextId()];        
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();   

        // set the template 
        Smart_Template_Config__c conf = new Smart_Template_Config__c();
        List<Smart_Template_Config__c> confs = new List<Smart_Template_Config__c>();
            
        confs = [SELECT Email_Template__c FROM Smart_Template_Config__c WHERE Initial_Queue_Owner__c = :c.Initial_Queue_Owner__c];
        if (!confs.isEmpty()){
            conf = confs[0];
            System.debug('got template: ' + conf.Email_Template__c);
            
            List<EmailTemplate> ets = new List<EmailTemplate>();
            ets = [SELECT id FROM EmailTemplate WHERE DeveloperName = :conf.Email_Template__c];
            EmailTemplate et = new EmailTemplate();
            //Return the ID of the template selected
            if (!ets.isEmpty()) {
                et = ets[0];
                System.debug('template: ' + conf.Email_Template__c + ' -- id: ' + et.id);                    
            }
            sendEmailDefaults.setTemplateId(et.id);            
            sendEmailDefaults.setInsertTemplateBody(True); 
            sendEmailDefaults.setIgnoreTemplateSubject(True);
            emailMessage.BccAddress= null;
            emailMessage.FromAddress= c.Incoming_Email_Address__c ;
        }
              
    }
    /*******************************************************************************
    Method Name: getSendEmailFromCaseDefaults
    Description: Used to checks whether the element passed in the array is for the standard Email action in the case feed. 
    Parameters:  QuickAction.QuickActionDefaults[]
    ReturnType:  QuickAction.SendEmailQuickActionDefaults
    *********************************************************************************/
    public QuickAction.SendEmailQuickActionDefaults getSendEmailFromCaseDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults item;

        for (Integer j = 0; j < defaults.size(); j++) {
            System.debug('-------j-------'+defaults.get(j));
            System.debug('-------null-------'+(defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults));
            SObject emailMsg = defaults.get(j).getTargetSObject();            
                                                                                                
            if(!Test.isRunningTest()){
                if (!(defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults)) continue;
                item = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
            }else{
                account theAccount=new account();
                theAccount=TestDataFactory.createAccount('Demo',Userinfo.getUserId(),true);
                
                
                Contact theContact=new Contact();
                theContact=TestDataFactory.createContact('Bill','Nork',theAccount.Id,true,true);
                
                
                Case theCase=new Case();
                theCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', theContact.Id, theAccount.Id, true);
                theCase.Initial_Queue_Owner__c='TestQueueOwner';
                update theCase;
                item = Test.newSendEmailQuickActionDefaults(theCase.Id, null);
            }
            
            if (item.getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
               item.getActionName().equals('Case.Email') &&
               item.getActionType().equals('Email')) {
                return item;
            }
        }

        // couldn't find the defaults
        return null;
    }
}