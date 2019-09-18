@isTest
public class CloseCaseBatch_Test
{
	public static testmethod void testCloseCaseBatch()
    {
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
        System.runAs (thisUser)
        {            
            theUser = TestDataFactory.createUser([SELECT Id FROM UserRole WHERE Name='Project Manager' limit 1].Id, [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id,null, 'user@gmail.com', 'user123123312dsds@gmail.com',  true);
        }
        
        Account theAccount = new Account();
        theAccount = TestDataFactory.createAccount('Demo',theUser.Id,true);
        
        Contact theContact = new Contact();
        theContact = TestDataFactory.createContact('Bill','Nork',theAccount.Id,true,true);
        
        Case theCase = new Case();
        theCase = TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', theContact.Id, theAccount.Id, true);
        
        String query = 'Select Id, Status, OwnerId From Case Where Status != \'Closed\'';
        CloseCaseBatch newCloseCaseBatch = new CloseCaseBatch(query, Date.newInstance(2022, 11, 15));
    	Database.executeBatch(newCloseCaseBatch, 1);
    }
}