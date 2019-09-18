/********************************************************************************************
*   @Author :       Vamsi Ch 
*   @Purpose:       Test class for EmailMessageHandler
*   @Class          EmailMessageHandler_Test
*   @JIRA           SEP-139
*   @CreatedDate:   July 2nd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
@isTest
public class EmailMessageHandler_Test{
    static testMethod void testMethod1(){   
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled';
        insert semt;
        
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;

        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='move@.com';
        insert dt;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
        
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
        User theUser=new User();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {            
            theUser=TestDataFactory.createUser([SELECT Id FROM UserRole WHERE Name='Project Manager' limit 1].Id, [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id,null, 'user@gmail.com', 'user123123312dsds@gmail.com',  true);
        }
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        parentAccount.Primary_Email__c = 'testSender@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        upsert parentAccount;               
        
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
                
       
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.origin = 'Email-Customer Success BETA:betatesters@realtor.com';
        
        Case newCase2=new Case();
        newCase2=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase2.origin = 'Email-Customer Success BETA:betatesters@realtor.com';
        
        list<case> caseList = new list<case>();
        caseList.add(newCase);
        caseList.add(newCase2);
        upsert caseList;
        newCase = [select id,caseNumber,subject from case where id=:newCase.Id];
        system.assert(newCase.id!=null);
        system.assert(newCase.caseNumber!=null);
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.subject = 'TestSubject Case Number '+newCase.caseNumber+' extra text';
        newEmailMsg.ParentId=newCase2.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
}