/********************************************************************************************
*   @Author :       Vamsi Ch(Brillio Technologies) 
*   @Purpose:       Test Class for CaseProcessBuilderHandler
*   @TestClass      CaseProcessBuilderHandler_Test
*   @Class          CaseProcessBuilderHandler
*   @JIRA           
*   @CreatedDate:   June 7, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
@isTest
private class CaseProcessBuilderHandler_Test{
    static testMethod void invokeCaseAssignmentRules_Test(){
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
        }
        account theAccount=new account();
        theAccount=TestDataFactory.createAccount('Demo',theUser.Id,true);
        
        Contact theContact=new Contact();
        theContact=TestDataFactory.createContact('Bill','Nork',theAccount.Id,true,true);
        
        Case theCase=new Case();
        theCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', theContact.Id, theAccount.Id, true);
        list<case> caseList = new list<case>();
        caseList.add(theCase);
        
        Test.StartTest();      
            CaseProcessBuilderHandler.invokeCaseAssignmentRules(caseList);
        test.stopTest();
        
    }
    static testMethod void exception_Test(){
        Test.StartTest();      
            CaseProcessBuilderHandler.invokeCaseAssignmentRules(null);
        test.stopTest();
    }
}