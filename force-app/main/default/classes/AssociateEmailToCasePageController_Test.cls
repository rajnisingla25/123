/********************************************************************************************
*   @Author :       Vamsi Ch 
*   @Purpose:       Test class for AssociateEmailToCasePageController
*   @Class          AssociateEmailToCasePageController_Test
*   @JIRA           SEP-139
*   @CreatedDate:   July 9th, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
@isTest(SeeAllData=true)
public class AssociateEmailToCasePageController_Test{
    static testmethod void TestMethod1(){
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled1';
        insert semt;
        
       /* Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Name = 'Disabled';
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;*/
        
        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled1';
        dt.TaskTrigger__c='move@gmail.com';
        insert dt;
        
      /*  Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;*/
        
      /*  Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        */
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
        If(parentAccount.Id!=null){
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        newContact.Active__c = true;
        upsert newContact;
            }    
        Case newCase=new Case();
        If(newContact.Id!=null&&parentAccount.Id!=null){
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        upsert newCase;
        }
        newCase = [select id,caseNumber,subject from case where id=:newCase.Id];
        system.assert(newCase.id!=null);
        system.assert(newCase.caseNumber!=null);
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.subject = 'TestSubject Case Number '+newCase.caseNumber+' extra text';
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        newEmailMsg.textbody = 'Hi TestEmail ref:_00D1h8hVe._5001h2Oxeb:ref';
        newEmailMsg.htmlbody = 'Hi TestEmail ref:_00D1h8hVe._5001h2Oxeb:ref';
        newEmailMsg.Internal_Comments__c = 'testInternalComments';
        newEmailMsg.case__c = newCase.Id;
        insert newEmailMsg;     
        
         //Creating Page Reference for VF page 
        PageReference pageRef = Page.AssociateEmailToCasePage; 
        ApexPages.StandardController sc = new ApexPages.StandardController(newEmailMsg);
        AssociateEmailToCasePageController associateE2C = new AssociateEmailToCasePageController(sc);
        associateE2C.emailMsg.Case__c= newCase.Id;
        associateE2C.emailMsg.Internal_Comments__c = 'testInternalComments';
        associateE2C.save();
        system.Test.setCurrentPage(pageRef);       
        Test.setCurrentPage(pageRef);
        Test.StopTest();
    }
}