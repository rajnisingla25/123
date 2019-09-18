/********************************************************************************************
*   @Author :       Srinidhi M 
*   @Purpose:       To get Assets that are tied to a Case's Accounts
*   @TestClass      Case_Assets_List_Test
*   @Class          Case_Assets_List
*   @JIRA           SEP-103
*   @CreatedDate:   June 04th, 2018
***********************************************************************************************
JIRA No      Date       Modified By         Description                                Tag No
***********************************************************************************************

*/


@isTest
public class Case_Assets_List_Test{  
    static testMethod void testMethod1(){
        
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;
        
        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='Test@test.com';
        insert dt;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
        
        CaseConsoleSidebarSetting__c ccs = new CaseConsoleSidebarSetting__c(name='Closed');
        ccs.Case_Status__c = 'Closed';
        ccs.Case_Asset_Status__c ='Active';
        insert ccs;
        
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
        
        
        Asset ast=new Asset();
        ast.Name='Asset1';
        ast.AccountId=theAccount.Id;
        ast.Status='Active';
        ast.Asset_Type__c='Parent';
        ast.Renewal_Status__c='Renewal';
        ast.Line_Type__c='Add';
        ast.Fulfillment_Status__c='Fulfilment';
        insert ast;
        
        Test.StartTest();
        //Creating Page Reference for VF page 
        PageReference pageRef = Page.Case_Assets_List; 
        pageRef.getParameters().put('Id', String.valueOf(theCase.Id));
        system.Test.setCurrentPage(pageRef);
        
        Case_Assets_List chl = new Case_Assets_List(); 
        chl.getAssets();
        
        ApexPages.StandardSetController setAsset = new ApexPages.StandardSetController([select id,contactId,accountId from Asset ]);
        Test.setCurrentPage(pageRef);
        
        Test.StopTest();
        
    }
    
}