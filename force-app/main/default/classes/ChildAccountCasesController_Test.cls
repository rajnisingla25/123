//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: ChildAccountCasesController_Test
// For Testing: ChildAccountCasesController.cls
//
// 6th April 2015    Manish Soni    Original (Task # T-376024)
// 2nd September 2015  Venkataramana cheedara Modified
//See the Apex Language Reference for more information about Testing and Code Coverage.
 
@isTest
private class ChildAccountCasesController_Test {
    static testMethod void testChildAccountCasesQuery() {
       //Inserting custom setting to avoid NullPointerException 
          DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
              insert trg;      
      // Inserting account record.
        Account brokerAccount = TestDataFactory.createAccount('Broker Account', null, false);
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        brokerAccount.Type = 'Broker';
        brokerAccount.Primary_Email__c = 'brokerAccount@b2b.com';
        Account agentAccount = TestDataFactory.createAccount('Agent Account', null, false);
        agentAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2C').RecordTypeId;
        agentAccount.Type = 'Realtor Agent';
        agentAccount.Primary_Email__c = 'agentAccount@b2c.com';
        
        List<Account> listAccount = new List<Account>();
        listAccount.add(brokerAccount);
        listAccount.add(agentAccount);
        insert listAccount;       
    
        // Inserting account relationship records.
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
          Parent_Account__c = brokerAccount.id,
          Child_Account__c = agentAccount.id,
          RecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId,
          Active__c = true
        );
        insert theAccountRelationship;         
        // Insert case for child account
        Case testCase = TestDataFactory.createCase('test subject', 'New', null,null, null, agentAccount.id, false);        
    
        Test.startTest();            
            ApexPages.StandardController stdController = new ApexPages.StandardController(brokerAccount); 
            ChildAccountCasesController controller = new ChildAccountCasesController(stdController);
            
            system.debug('FilterCriteria --> ' + controller.filterCriteria);
            system.assert(controller.filterCriteria.contains(agentAccount.Id));
            
            stdController = new ApexPages.StandardController(agentAccount); 
            controller = new ChildAccountCasesController(stdController);
            system.debug('FilterCriteria --> ' + controller.filterCriteria);
            system.assertEquals(controller.noChildAccounts, true, 'Child cases should not exists.' );
            
        Test.stopTest();
    }
}