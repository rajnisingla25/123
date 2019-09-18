//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: AccountRelationshipTrigger_Test
// For Testing: AccountRelationshipTrigger.trigger And AccountRelationshipTriggerHandler.cls
//
// 21st May 2015   Ravindra Shekhawat Original Task (Task # T-396116)
//
@isTest
private class AccountRelationshipTrigger_Test {
    private static final Integer COUNTER = 3;
    
    static testMethod void testAccountRelationshipTriggerFunctionality() {
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        
        // Inserting account records.
        Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        insert parentAccount;
        
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';
        insert childAccount; 
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        
        
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
            (parentAccount.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation.Is_Parent_Primary__c = true;
        toBeInserted.add(accountRelation); 
        
        Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
        parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
        insert parentAcc1;
        
        accountRelation = TestDataFactory.createAccountRelationship(
            parentAcc1.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        toBeInserted.add(accountRelation); 
        
        List<Contact> contacts= new List<Contact>();
        //Create Contacts
        Contact testContact = TestDataFactory.createContact('TestContact','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContact@move.com';
        testContact.Type__c = 'Billing';
        contacts.add(testContact);
        //Create Contacts
        testContact = TestDataFactory.createContact('TestContactAct','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContacAct@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        testContact = TestDataFactory.createContact('TestContact1','Last1',parentAccount.id,true,false);
        testContact.Email = 'testContact1@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        insert contacts;
        
        // Create Relationship records for Contact Relationhsip
        accountRelation = TestDataFactory.createAccountRelationship(
            parentAcc1.Id, null, contacts.get(0).Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Billing_Contact__c = true;
        toBeInserted.add(accountRelation); 
        
        
        accountRelation = TestDataFactory.createAccountRelationship(
            parentAccount.Id, null, contacts.get(2).Id, null, true, false);
        accountRelation.Billing_Contact__c = false;
        accountRelation.Is_Parent_Primary__c = true;
        
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        toBeInserted.add(accountRelation);
        
        
        //Test Case 1
        Test.startTest();
        Integer totalInsertsFailed = 0;
        Database.SaveResult[] insertResult = Database.insert(toBeInserted,false);
        for(Database.SaveResult sr : insertResult) {
            if(!sr.isSuccess()) {
                totalInsertsFailed++;
            }
            System.debug('Save Result is : '+sr);
        }
        
        //System.assertEquals(totalInsertsFailed,1);
        
        toBeInserted = [SELECT Id,Active__c FROM Account_Relationship__c WHERE Id in: toBeInserted];
        toBeInserted.get(0).Active__c = false;
        
        update toBeInserted;
        
        
        Test.stopTest();
    }   
}