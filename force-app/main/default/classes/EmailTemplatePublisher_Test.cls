@isTest
private class EmailTemplatePublisher_Test {

    static testMethod void testChooseTemplate() {
        //Create the custom setting
        Smart_Template_Config__c sc = new Smart_Template_Config__c(name='Default Template',Email_Template__c='TestTemplate',Initial_Queue_Owner__c='TestQueueOwner');        
        insert sc;
        //Creating Custom settings
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;

        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='srini';
        insert dt;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
        
        CaseConsoleSidebarSetting__c ccs = new CaseConsoleSidebarSetting__c(name='Closed');
        ccs.Case_Status__c = 'Closed';
        insert ccs;
        //Creating related data using TestDataFactory class
        User theUser=new User();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {            
            theUser=TestDataFactory.createUser([SELECT Id FROM UserRole WHERE Name='Project Manager' limit 1].Id, [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id,null, 'user@gmail.com', 'user123123312dsds@gmail.com',  true);
            EmailTemplate e = new EmailTemplate (developerName = 'TestTemplate', folderId=UserInfo.getUserId(),TemplateType= 'Custom', Name = 'TestTemplate'); 
            insert e;
        }
        account theAccount=new account();
        theAccount=TestDataFactory.createAccount('Demo',theUser.Id,true);
        
        Contact theContact=new Contact();
        theContact=TestDataFactory.createContact('Bill','Nork',theAccount.Id,true,true);
        
        Case theCase=new Case();
        theCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', theContact.Id, theAccount.Id, true);
        theCase.Initial_Queue_Owner__c='TestQueueOwner';
        update theCase;
        list<case> caseList = new list<case>();
        caseList.add(theCase);
        
        String defaultsAsJSON = '[{"targetSObject":{"attributes":{"type":"EmailMessage"},"TextBody":"",'
        + '"FromName":"Test","FromAddress":"test@example.com","HtmlBody":"<html><body></body></html>","BccAddress":"test@example.com",'
        + '"CcAddress":"","ToAddress":"test@example.com","Subject":"Testing"},"contextId":"50011000005ZtcRAAS","actionType":"Email",'
        + '"actionName":"Case.Email","fromAddressList":["salesforce@test.com"]}]';
        
        QuickAction.QuickActionDefaults[] defaultsSettings = 
        (QuickAction.QuickActionDefaults[])JSON.deserialize(defaultsAsJSON, QuickAction.QuickActionDefaults[].class);
        
        
        Test.StartTest();     
            QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(theCase.Id, null);
            
            EmailTemplatePublisher st = new EmailTemplatePublisher();
            
        
        
        st.getSendEmailFromCaseDefaults(defaultsSettings);
        st.onInitDefaults(defaultsSettings );
        

        Test.stopTest();
                               
    }
    static testMethod void testException() {
        Test.StartTest();         
            EmailTemplatePublisher st = new EmailTemplatePublisher();
        Test.stopTest();
    }
}