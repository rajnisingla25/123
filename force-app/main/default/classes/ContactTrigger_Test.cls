//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: ContactTrigger_Test
// For Testing: ContactTrigger.trigger And ContactTriggerHandler.cls
//
// 15th March 2015    Hemendra Singh Bhati    Original (Task # T-369907)
// 23rd March 2015    Hemendra Singh Bhati    Modified (Task # T-372662) - Modified Inserting Contact Records Section.
// 8th April 2015     Kirti Agarwal           (Task # T-376543)
//
@isTest
private class ContactTrigger_Test {
  private static final Integer COUNTER = 2;
  private static final String CONTACT_RECORD_TYPE_STANDARD = 'Standard';

  static testMethod void testContactTriggerFunctionality() {
   //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
    // Inserting account record.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theaccount@b2b.com';
    // Inserting contact records.
    Contact theContact = null;
    Id contactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId;
    List<Contact> theContacts = new List<Contact>();
    for(Integer index = 0; index < COUNTER; index++) {
        theContact = TestDataFactory.createContact(
        'Test Contact',
        '#' + (index + 1),
        theAccount.Id,
        true,
        false
      );
      theContact.Type__c = 'Other';
      theContact.Email = 'testCont'+index+'@move.com';
      theContact.RecordTypeId = contactRecordTypeId;
        theContacts.add(theContact);
    }
      insert theContacts;

    // Inserting account relationship records.
    List<Account_Relationship__c> theAccountRelationships = new List<Account_Relationship__c>();
    for(Integer index = 0; index < 1; index++) {
        theAccountRelationships.add(
        TestDataFactory.createAccountRelationship(
          theAccount.Id,
          theAccount.Id,
          theContacts.get(index).Id,
          Math.mod(index, 2) == 0 ? 'Primary Contact' : 'Billing Contact',
          true,
          false
        )
        );
    }
    insert theAccountRelationships;

    Test.startTest();

    // Testing the contact trigger functionality.
    for(Integer index = 0; index < COUNTER; index++) {
        theContacts.get(index).Active__c = false;
        theContacts.get(index).Inactivation_Reason__c = 'Test Inactivation Reason.';
    }
    Database.update(theContacts,false);

    Test.stopTest();

    // Validating the contact trigger functionality.
    system.assert([SELECT Id FROM Contact WHERE Active__c = false].size() == 1, 'Error: Contact trigger handler functionality failed.');
    system.assert(
      [SELECT Id FROM Account_Relationship__c WHERE Active__c = false].size() == 0,
      'Error: Contact trigger handler failed to deactivate account relationship records.'
    );
  }

  static testMethod void contactCDHWebService_Test() {
   //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
     Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
     theAccount.Primary_Email__c = 'theaccount@move.com';
     insert theAccount;

    // Inserting contact records.
    Contact theContact = null;
    Id contactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId;
    List<Contact> theContacts = new List<Contact>();
    for(Integer index = 0; index < COUNTER; index++) {
        theContact = TestDataFactory.createContact(
        'Test Contact',
        '#' + (index + 1),
        theAccount.Id,
        true,
        false
      );
      theContact.Type__c = 'Other';
      theContact.Email = 'tehcon@move.com';
      theContact.RecordTypeId = contactRecordTypeId;
        theContacts.add(theContact);
    }
      insert theContacts;
      Integer i = 0;
      for(Contact con : theContacts) {
        if(i == 0) {
          con.Title = 'testt';
        }else if(i == 1) {
          con.Email = 'testt@test.com';
        }
        else if(i == 2) {
            con.Preferred_Phone__c ='Home Phone';
          con.HomePhone = '543534';
        }
        i++;
      }
      update theContacts;
  }
}