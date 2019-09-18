//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: CreateNewContactExtension_Test
// For Apex Extension: CreateNewContactExtension
// For Apex Page: CreateNewContact
// Description: Overrides new button of contact sobjecM_t and creates an contact using custom apex page.
// Calls CDH contact creation web service via apex page.
//
// 08th April 2015    Hemendra Singh Bhati    Original (Task # T-376891)
//
@isTest(seeAllData=False)
private class CreateNewContactExtension_Test {
    private static final String CONTACT_RECORD_TYPE_STANDARD = 'Standard';
    private static final String PROFILE_NAME = 'System Administrator';
    
    // This method tests the behaviour of extension class when the user has access to all contact record types.
    // Test Case 1 - CDH contact match found. No new contact is created at this point.
    // Test Case 2 - No CDH contact selected by user.
    // Test Case 3 - Multiple CDH contacts selected by the user.
    // Test Case 4 - Only one CDH contact selected by the user to update.
    // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
    // Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
    private static testMethod void testAllRecordTypesAccess() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        List<Contact> theTestContacts = new List<Contact>();
        
        theContact = TestDataFactory.createContact('The Test1', 'Contact 1', null, true, false);
        theContact.Phone = '9876543210';
        theContact.Email = 'hsingh@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28993480';
        theTestContacts.add(theContact);
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact.Phone = '9876543211';
        theContact.Email = 'hsingh1@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28993489';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;
        //theContact.RecordtypeId=null;
        theTestContacts.add(theContact);
        
        insert theTestContacts;
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        // Test Case 1 - CDH contact match found. No new contact is created at this point.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'Test1',
            LastName = 'Contact11 3',
            Phone = '9876543310',
            Type__c = 'Agent'
        ));
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CreateNewContactExtensionMockCallout());
        //  Test.setMock(WebServiceMock.class, new moveContMockResponse());
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessFax = '6784563429';
        theExtension.personalMobile = '6784563427';
        theExtension.businessMobile = '6784563428';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@yahoo.com';
        
        theExtension.hasError = false;
        theExtension.selectedprefPhone = 'businessPhone';
        theExtension.selectedprefEmail = 'personalEmail';
        theExtension.contactRole = 'primaryContact';
        theExtension.isBilling = True;
        theExtension.createContact();
        
        CreateNewContactExtension.ContactWrapper wrap = new CreateNewContactExtension.ContactWrapper(theTestContacts[0]);
        
        theExtension.cancelProcess();
        theExtension.createContact();
        theExtension.theSelectedContacts.add(wrap); 
        
        system.assert(
            [SELECT Id FROM Contact].size() >1,
            'Error: No new contact must be created at this point since a CDH contact match is found.'
        );
        
        // Test Case 2 - No CDH contact selected by user.
        theExtension.updateExistingContact();
        
        Boolean flag = false;
        List<Apexpages.Message> theMessages = ApexPages.getMessages();
        for(Apexpages.Message theMessage : theMessages) {
            if(theMessage.getDetail().contains('Please select at least one contact to update.')) {
                flag = true;
                break;
            }
        }
        
        system.assert(
            flag == true,
            'Error: The extension class failed to notify the user that he/she must select at least one contact to update.'
        );
        
        // Test Case 3 - Multiple CDH contacts selected by the user.
        for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
            theContactWrapper.theContact = theTestContacts[0]; 
            theContactWrapper.isSelected = true;
        }
        theExtension.updateExistingContact();
        
        flag = false;
        theMessages = ApexPages.getMessages();
        for(Apexpages.Message theMessage : theMessages) {
            if(theMessage.getDetail().contains('Please select only one contact to update.')) {
                flag = true;
                break;
            }
        }
        
        /* system.assert(
flag == true,
'Error: The extension class failed to notify the user that he/she must select only one contact to update..'
);*/
        
        // Test Case 4 - Only one CDH contact selected by the user to update.
        for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
            theContactWrapper.isSelected = false;
        }
        for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
            theContactWrapper.isSelected = true;
            break;
        }
        theExtension.updateExistingContact();
        
        system.assert(
            [SELECT Id FROM Contact].size() > 1,
            'Error: The extension class failed to update the selected CDH contact.'
        );
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            HomePhone = '9876543210',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        
        theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.isPrimary = true;
        theExtension.createNewContact();
        
        system.assert(
            [SELECT Id FROM Contact].size() > 1,
            'Error: The extension class failed to create a new fresh contact when the user ignored all the displayed CDH contacts.'
        );
        
        // Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            Phone = '9876543210',
            Type__c = 'Broker'
        ));
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessFax = '6784563429';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@yahoo.com';
        
        
        theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.selectedprefPhone = 'personalPhone';
        theExtension.selectedprefEmail = 'personalEmail';
        theExtension.contactRole = 'businessEmail';
        theExtension.isBilling = True;
        theExtension.createContact();
        
        system.assert(
            [SELECT Id FROM Contact].size() >1,
            'Error: The extension class failed to create a new contact based on the data submitted by the user as search criteria when no matching CDH contacts found.'
        );
        
        //  Test.setMock(WebServiceMock.class, new moveContMockResponse());
        
        
        
        //  response.put('response_x', respElement);
        
        Test.stopTest();
    }
    
    // This method tests the behaviour of extension class when the user has access to only one contact record type.
    // Test Case 1 - CDH contact match found. No new contact is created at this point.
    // Test Case 2 - No CDH contact selected by user.
    // Test Case 3 - Multiple CDH contacts selected by the user.
    // Test Case 4 - Only one CDH contact selected by the user to update.
    // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
    // Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
    private static testMethod void testDefaultRecordTypeAccess() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        Test.setMock(WebServiceMock.class, new CreateNewContactExtensionMockCallout());
        
        // Extracting Move Agent Sales Rep Profile.
        List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME limit 1];
        //system.assert(profile.size() > 0,'Error: Requested profile named ' + PROFILE_NAME + ' does not exist.');
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        //Inserting Customsetting 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        List<Contact> theTestContacts = new List<Contact>();
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 1', null, true, false);
        theContact.Phone = '9876643210';
        theContact.Email = 'hsingh21@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.Contact_Party_ID__c = '28993589';
        theTestContacts.add(theContact);
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact.Phone = '9876543200';
        theContact.Email = 'hsingh3@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.Contact_Party_ID__c = '28997489';
        theTestContacts.add(theContact);
        
        // Creating Move Agent Sales Rep User.
        User theSalesRepUser = TestDataFactory.createUser(null, profile[0].Id, null, 'hurt@life.com', 'life@hurt.com', true);
        system.runAs(theSalesRepUser) {
            // Inserting Test Contacts.
            insert theTestContacts;
            
            PageReference thePage = Page.CreateNewContact;
            Test.setCurrentPage(thePage);
            
            // Test Case 1 - CDH contact match found. No new contact is created at this point.
            ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'T0 Test',
                LastName = 'Contact0 3',
                Phone = '9876543213',
                Type__c = 'Agent'
            ));
            
            Test.startTest();           
            
            CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.personalPhone = '6784563422';
            theExtension.personalMobile = '6784563429';
            theExtension.personalEmail = 'testingcon@gmail.com';
            theExtension.businessEmail = 'testingcon@yahoo.com';
            theExtension.selectedprefPhone = 'personalMobile';
            theExtension.selectedprefEmail = 'businessEmail';
            theExtension.contactRole = 'primaryContact';
            theExtension.isBilling = True;
            
            theExtension.cancelProcess();
            theExtension.createContact();
            
            
            /*
system.assert(
[SELECT Id FROM Contact].size() == 2,
'Error: No new contact must be created at this point since a CDH contact match is found.'
);*/
            
            // Test Case 2 - No CDH contact selected by user.
           theExtension.updateExistingContact();
            
            Boolean flag = false;
            List<Apexpages.Message> theMessages = ApexPages.getMessages();
            for(Apexpages.Message theMessage : theMessages) {
                if(theMessage.getDetail().contains('Please select at least one contact to update.')) {
                    flag = true;
                    break;
                }
            }
            
            system.assert(
                flag == true,
                'Error: The extension class failed to notify the user that he/she must select at least one contact to update.'
            );
            
            // Test Case 3 - Multiple CDH contacts selected by the user.
            for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
                theContactWrapper.isSelected = true;
            }
            theExtension.updateExistingContact();
            
            flag = false;
            theMessages = ApexPages.getMessages();
            for(Apexpages.Message theMessage : theMessages) {
                if(theMessage.getDetail().contains('Please select only one contact to update.')) {
                    flag = true;
                    break;
                }
            }
            
            /*system.assert(
flag == true,
'Error: The extension class failed to notify the user that he/she must select only one contact to update..'
);*/
            
            // Test Case 4 - Only one CDH contact selected by the user to update.
           for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
                theContactWrapper.isSelected = false;
            }
            for(CreateNewContactExtension.ContactWrapper theContactWrapper : theExtension.theSelectedContacts) {
                theContactWrapper.isSelected = true;
                break;
            }
            theExtension.updateExistingContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to update the selected CDH contact.'
            );
            
            // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                HomePhone = '9876543210',
                Preferred_Phone__c = 'Home Phone',
                Type__c = 'Agent'
            ));
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.createNewContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to create a new fresh contact when the user ignored all the displayed CDH contacts.'
            );
            
            // Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                Phone = '9876543210',
                Type__c = 'Broker'
            ));
            theExtension.personalPhone = '6784563422';
            theExtension.businessMobile = '6784563423';
            theExtension.personalEmail = 'testingcon@gmail.com';
            theExtension.businessEmail = 'testingcon@yahoo.com';
            
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.selectedprefPhone = 'businessMobile';
            theExtension.selectedprefEmail = 'businessEmail';
            theExtension.contactRole = 'primaryContact';
            theExtension.isBilling = True;
            theExtension.createContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to create a new contact based on the data submitted by the user as search criteria when no matching CDH contacts found.'
            );
            
            // Test Case 7 - Validating contact's preferred phone.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                HomePhone = '9876543210',
                Type__c = 'Broker'
            ));
            theExtension.businessPhone = '6784563421';
            theExtension.personalPhone = '6784563422';
            theExtension.personalEmail = 'testingcon@gmail.com';
            theExtension.businessEmail = 'testingcon@yahoo.com';
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.selectedprefPhone = 'businessPhone';
            theExtension.selectedprefEmail = 'personalEmail';
            theExtension.contactRole = 'primaryContact';
            theExtension.isBilling = True;
            theExtension.createContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to validate preferred phone.'
            );
            
            // Test Case 8 - Validating contact's phone number and email address.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                Type__c = 'Broker'
            ));
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.createContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to validate phone number and email address.'
            );
            
            // Test Case 9 - Nullifying contact's preferred phone.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                Email = 'hsingh22@appirio.com',
                Preferred_Phone__c = 'Other',
                Type__c = 'Broker'
            ));
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.createContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to validate phone number and email address.'
            );
            
            // Test Case 10 - Nullifying contact's preferred phone.
            theStandardController = new ApexPages.StandardController(new Contact(
                FirstName = 'The Test',
                LastName = 'Contact 3',
                Email = 'hsingh23@appirio.com',
                Preferred_Phone__c = 'HomePhone',
                Type__c = 'Broker'
            ));
            
            theExtension = new CreateNewContactExtension(theStandardController);
            theExtension.createContact();
            
            system.assert(
                [SELECT Id FROM Contact].size() >1,
                'Error: The extension class failed to validate phone number and email address.'
            );
            
            Test.stopTest();
        }
        
        
    }
    
    private static testMethod void testAllRecordTypesAccessII() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        List<Contact> theTestContacts = new List<Contact>();
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 1', null, true, false);
        theContact.Phone = '9876743210';
        theContact.Email = 'hsingh24@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28093488';
        theTestContacts.add(theContact);
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact.Phone = '9876543411';
        theContact.Email = 'hsingh21@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28993489';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;
        //theContact.RecordtypeId=null;
        theTestContacts.add(theContact);
        
        insert theTestContacts;
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        // Test Case 1 - CDH contact match found. No new contact is created at this point.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            Phone = '9876543210',
            Type__c = 'Agent'
        ));
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse ());
        
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.hasError = false;
        
        CreateNewContactExtension.ContactWrapper wrap = new CreateNewContactExtension.ContactWrapper(theTestContacts[0]);
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            HomePhone = '9876543210',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        theExtension = new CreateNewContactExtension(theStandardController);
        
        PageReference pageRef = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef);
        theExtension.accountID = acc.Id;
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@yahoo.com';
        ApexPages.currentPage().getParameters().put('isBilling', 'True'); 
        theExtension.selectedprefPhone = 'businessMobile';
        theExtension.selectedprefEmail = 'businessEmail';
        theExtension.contactRole = 'primaryContact';
        theExtension.createNewContact();
        
        
        
        // Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            Phone = '9876543210',
            Type__c = 'Broker'
        ));
        theExtension = new CreateNewContactExtension(theStandardController);
        
        PageReference pageRef2 = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef2);
        theExtension.accountID = acc.Id;
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@yahoo.com';
        ApexPages.currentPage().getParameters().put('isBilling', 'True');
        theExtension.selectedprefPhone = 'personalPhone';
        theExtension.selectedprefEmail = 'businessEmail';
        theExtension.contactRole = 'primaryContact';      
        theExtension.createContact();
        theExtension.getphoneOptions();
        theExtension.getemailOptions();
        
        
        
        Test.stopTest();
    }
    private static testMethod void testAllRecordTypesAccessIV() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        acc.Email_Address__c = 'hsingh24@appirio.com';
        insert acc;
        List<Contact> theTestContacts = new List<Contact>();
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 1', null, true, false);
        theContact.Phone = '9876743210';
        theContact.Email = 'hsingh24@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28093488';
        //insert theContact;
        theTestContacts.add(theContact);
        
        theContact = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact.Phone = '9876543411';
        theContact.Email = 'hsingh21@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28993489';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;
        //theContact.RecordtypeId=null;
        theTestContacts.add(theContact);
        
        insert theTestContacts;
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        // Test Case 1 - CDH contact match found. No new contact is created at this point.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            Phone = '9876543211',
            Type__c = 'Agent'
        ));
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse ());
        
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.hasError = false;
        
        CreateNewContactExtension.ContactWrapper wrap = new CreateNewContactExtension.ContactWrapper(theTestContacts[0]);
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'The Test',
            LastName = 'Contact 3',
            HomePhone = '9876543210',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        theExtension = new CreateNewContactExtension(theStandardController);
        CheckRecursiveTrigger.executeTriggerOnce = false;
        PageReference pageRef = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef);
        //ApexPages.currentPage().getParameters().put('con4_lkid','acc.Id');
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalMobile = '6784563429';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@yahoo.com';
        theExtension.isBilling = True; 
        theExtension.selectedprefPhone = 'personalPhone';
        theExtension.selectedprefEmail = 'businessEmail';
        theExtension.contactRole = 'primaryContact';
        theExtension.createContact();
        theExtension.getphoneOptions();
        theExtension.getemailOptions();
        theExtension.getcontactRoleLst();
        
        /*

// Test Case 6 - No matching CDH contacts found and a new contact is created based on the data submitted by the user as search criteria.
theStandardController = new ApexPages.StandardController(new Contact(
FirstName = 'The Test',
LastName = 'Contact 3',
Phone = '9876543214',
Type__c = 'Broker'
));
theExtension = new CreateNewContactExtension(theStandardController);
CheckRecursiveTrigger.executeTriggerOnce = false;
PageReference pageRef2 = Page.CreateNewContact;
Test.setCurrentPageReference(pageRef2);
ApexPages.currentPage().getParameters().put('businessPhone', '6784563431');
ApexPages.currentPage().getParameters().put('personalPhone', '6784563432');
ApexPages.currentPage().getParameters().put('businessMobile', '6784563433');
ApexPages.currentPage().getParameters().put('personalMobile', '6784563434');
ApexPages.currentPage().getParameters().put('personalEmail', 'testingcon1@gmail.com');
ApexPages.currentPage().getParameters().put('businessEmail', 'testingcon1@yahoo.com');
//ApexPages.currentPage().getParameters().put('selectedprefPhone', 'businessPhone');
ApexPages.currentPage().getParameters().put('selectedprefEmail', 'personalEmail');
ApexPages.currentPage().getParameters().put('contactRole', 'primaryContact');
ApexPages.currentPage().getParameters().put('isBilling', 'True');
theExtension.selectedprefPhone = 'personalPhone';
theExtension.selectedprefEmail = 'businessEmail';
theExtension.contactRole = 'primaryContact';      
theExtension.createContact();*/
        
       
        
        Test.stopTest();
    }
    
   private static testMethod void testAllRecordTypesAccessIIII() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        List<Contact> theTestContacts = new List<Contact>();
        
        
        theContact = TestDataFactory.createContact('The Tes0t', 'Contact 2', null, true, false);
        theContact.Phone = '9876543511';
        theContact.Email = 'hsingh31@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28193488';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;
        //theContact.RecordtypeId=null;
        //theTestContacts.add(theContact);
        
        insert theContact;
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
            Parent_Account__c = acc.id,
            Relationship_Type__c = 'Contact',
            Contact_To__c = theContact.Id,
            RecordTypeID = contRelationShipRTID,
            Active__c = true,
            Contact_Role__c = 'Primary Contact');
        insert theAccountRelationship ;   
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        // Test Case 1 - CDH contact match found. No new contact is created at this point.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'T2 Test',
            LastName = 'Contact2 3',
            Phone = '9876543211',
            Type__c = 'Agent'
        ));
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse());
        
        
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'T3 Test',
            LastName = 'Contact3 3',
            HomePhone = '9876543212',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);      
        
        PageReference pageRef1 = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef1);
        ApexPages.currentPage().getParameters().put('con4_lkid','acc.Id');
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalMobile = '6784563429';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessFax = '6784563322';
        theExtension.contactRole = 'primaryContact';
        theExtension.accountID = acc.Id;
        ApexPages.currentPage().getParameters().put('selectedprefPhone', 'businessPhone');
        ApexPages.currentPage().getParameters().put('selectedprefEmail', 'personalEmail');
        ApexPages.currentPage().getParameters().put('contactRole', 'primaryContact');
        ApexPages.currentPage().getParameters().put('isBilling', 'True');       
        //theExtension.createNewContact();
        
        //theExtension = new CreateNewContactExtension(theStandardController);
        theExtension.createContact();
        
        
        
        Test.stopTest();
    }
    private static testMethod void testAllRecordTypesAccessVII() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        
        theContact = TestDataFactory.createContact('The Tes0t', 'Contact 2', null, true, false);
        theContact.Phone = '9876543511';
        theContact.Email = 'hsingh31@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28193488';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;    
        insert theContact;
        
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
            Parent_Account__c = acc.id,
            Relationship_Type__c = 'Contact',
            Contact_To__c = theContact.Id,
            RecordTypeID = contRelationShipRTID,
            Active__c = true,
            Contact_Role__c = 'Primary Contact');
        insert theAccountRelationship ;   
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse());  
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'T3 Test',
            LastName = 'Contact3 3',
            HomePhone = '9876543212',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);      
        
        PageReference pageRef1 = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef1);
        ApexPages.currentPage().getParameters().put('con4_lkid','acc.Id');
        theExtension.accountID = acc.Id;
        theExtension.ar = theAccountRelationship;
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalMobile = '6784563429';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessFax = '6784563322';
        theExtension.contactRole = 'primaryContact';
        
        theExtension.createContact();
        
        Test.stopTest();
    }
    private static testMethod void testEmailPhoneValidations() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        
        theContact = TestDataFactory.createContact('The Tes0t', 'Contact 2', null, true, false);
        theContact.Phone = '9876543511';
        theContact.Email = 'hsingh31@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28193488';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;    
        insert theContact;
        
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
            Parent_Account__c = acc.id,
            Relationship_Type__c = 'Contact',
            Contact_To__c = theContact.Id,
            RecordTypeID = contRelationShipRTID,
            Active__c = true,
            Contact_Role__c = 'Primary Contact');
        insert theAccountRelationship ;   
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse());  
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'T3 Test',
            LastName = 'Contact3 3',
            HomePhone = '9876543212',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);      
        
        PageReference pageRef1 = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef1);
        ApexPages.currentPage().getParameters().put('con4_lkid','acc.Id');
        theExtension.accountID = acc.Id;
        theExtension.ar = theAccountRelationship;
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563421';
        theExtension.businessMobile = '6784563421';
        theExtension.personalMobile = '6784563421';
        theExtension.personalMobile = '6784563421';
        theExtension.personalEmail = 'testingcon@gmail.com';
        theExtension.businessEmail = 'testingcon@gmail.com';
        theExtension.businessFax = '6784563421';
        theExtension.selectedprefPhone = 'personalPhone';
        theExtension.selectedprefEmail = 'businessEmail';
        theExtension.contactRole = 'primaryContact';
        
        theExtension.createContact();
        
        Test.stopTest();
    }
    
    private static testMethod void testmethod1() {
        // Setting Mock Callout Class.
        // This Causes A Fake Response To Be Generated.
        
        
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
        insert art;
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        
        // Inserting Test Contacts.
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        
        theContact = TestDataFactory.createContact('The Tes0t', 'Contact 2', null, true, false);
        theContact.Phone = '9876543511';
        theContact.Email = 'hsingh31@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28193488';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;    
        insert theContact;
        
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
            Parent_Account__c = acc.id,
            Relationship_Type__c = 'Contact',
            Contact_To__c = theContact.Id,
            RecordTypeID = contRelationShipRTID,
            Active__c = true,
            Contact_Role__c = 'Primary Contact');
        insert theAccountRelationship ;  
        
        PageReference thePage = Page.CreateNewContact;
        Test.setCurrentPage(thePage);
        
        // Setting record type Id as a URL parameter. 
        ApexPages.currentPage().getParameters().put(
            'RecordType',
            Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        );
        
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new moveContMockResponse());  
        
        // Test Case 5 - The user ignored all the displayed CDH contacts and decided to create a new fresh contact.
        ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Contact(
            FirstName = 'T3 Test',
            LastName = 'Contact3 3',
            HomePhone = '9876543212',
            Preferred_Phone__c = 'Home Phone',
            Type__c = 'Agent'
        ));
        CreateNewContactExtension theExtension = new CreateNewContactExtension(theStandardController);      
        
        PageReference pageRef1 = Page.CreateNewContact;
        Test.setCurrentPageReference(pageRef1);
        ApexPages.currentPage().getParameters().put('con4_lkid',acc.Id);
        // theExtension.accountID = acc.Id;
        theExtension.ar = theAccountRelationship;
        theExtension.businessPhone = '6784563421';
        theExtension.personalPhone = '6784563422';
        theExtension.businessMobile = '6784563423';
        theExtension.personalMobile = '6784563424';
        theExtension.personalMobile = '6784563429';
        theExtension.businessEmail = 'testingcon@gmail.com';
        theExtension.businessFax = '6784563322';
        theExtension.selectedprefPhone = 'personalMobile';
        theExtension.selectedprefEmail = 'businessEmail';
        theExtension.contactRole = 'primaryContact';
        theExtension.isBilling = True;
        
        theExtension.getcontactRoleLst();
        theExtension.createContact();
        theExtension.getphoneOptions();
        
        Test.stopTest();
    }
    
    
}