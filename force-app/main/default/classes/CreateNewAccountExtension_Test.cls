//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: CreateNewAccountExtension_Test
// For Apex Extension: CreateNewAccountExtension
// For Apex Page: CreateNewAccount
// Description: Overrides new button of account sobject and creates an account using custom apex page.
// Calls CDH account creation web service via apex page.
//
// 07th April 2015    Hemendra Singh Bhati    Original (Task # T-376544)
//
@isTest
private class CreateNewAccountExtension_Test {
    private static final String ACCOUNT_RECORD_TYPE_B2B = 'B2B';
  private static final String PROFILE_NAME = 'Move Agent Sales Rep';

  // This method tests the behaviour of extension class when the user has access to all account record types.
  // Test Case 1 - CDH account match found. No new account is created at this point.
  // Test Case 2 - No CDH account selected by user.
  // Test Case 3 - Multiple CDH accounts selected by the user.
  // Test Case 4 - Only one CDH account selected by the user to update.
  // Test Case 5 - The user ignored all the displayed CDH accounts and decided to create a new fresh account.
  // Test Case 6 - No matching CDH accounts found and a new account is created based on the data submitted by the user as search criteria.
  private static testMethod void testAllRecordTypesAccess() {
    // Setting Mock Callout Class.
    // This Causes A Fake Response To Be Generated.
    Test.setMock(WebServiceMock.class, new CreateNewAccountExtensionMockCallout());

    // Inserting Custom Setting Data.
    CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
      Account_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchAccountCDH/matchaccountcdhservice_client_ep?WSDL'
    );
    insert customSettingData;
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    // Inserting Test Accounts.
    Account theAccount = null;
    List<Account> theTestAccounts = new List<Account>();

    theAccount = TestDataFactory.createAccount('The Test Account 1', null, false);
    theAccount.Party_ID__c = '28993489';
    theAccount.Type = 'Agent';
    theAccount.BillingStreet = 'Mahindra World City, Sez';
    theAccount.BillingCity = 'Jaipur';
    theAccount.BillingState = 'Rajasthan';
    theAccount.BillingPostalCode = '302012';
    theAccount.billingcountry = 'Test';
    theAccount.Phone = '9876543210';
    theAccount.Email_Address__c = 'hsingh@appirio.com';
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theTestAccounts.add(theAccount);

    theAccount = TestDataFactory.createAccount('The Test Account 2', null, false);
    theAccount.Party_ID__c = '28993489';
    theAccount.Type = 'Agent';
    theAccount.BillingStreet = 'Mahindra World City, Sez';
    theAccount.BillingCity = 'Jaipur';
    theAccount.BillingState = 'Rajasthan';
    theAccount.BillingPostalCode = '302012';
    theAccount.billingcountry = 'Test';
    theAccount.Phone = '9876543210';
    theAccount.Email_Address__c = 'hsingh@appirio.com';
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theTestAccounts.add(theAccount);

    insert theTestAccounts;

      PageReference thePage = Page.CreateNewAccount;
      Test.setCurrentPage(thePage);

    // Setting record type Id as a URL parameter. 
    ApexPages.currentPage().getParameters().put(
      'RecordType',
      Schema.SObjectType.Account.RecordTypeInfosByName.get(ACCOUNT_RECORD_TYPE_B2B).RecordTypeId
    );

      // Test Case 1 - CDH account match found. No new account is created at this point.
      ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Agent',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        billingcountry = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

    Test.startTest();

      CreateNewAccountExtension theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.cancelProcess();
      theExtension.createAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 2,
        'Error: No new account must be created at this point since a CDH account match is found.'
      );

      // Test Case 2 - No CDH account selected by user.
      theExtension.updateExistingAccount();

      Boolean flag = false;
      List<Apexpages.Message> theMessages = ApexPages.getMessages();
      for(Apexpages.Message theMessage : theMessages) {
        if(theMessage.getDetail().contains('Please select at least one account to update.')) {
          flag = true;
          break;
        }
      }

      system.assert(
        flag == true,
        'Error: The extension class failed to notify the user that he/she must select at least one account to update.'
      );

      // Test Case 3 - Multiple CDH accounts selected by the user.
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = true;
      }
    theExtension.updateExistingAccount();

      flag = false;
      theMessages = ApexPages.getMessages();
      for(Apexpages.Message theMessage : theMessages) {
        if(theMessage.getDetail().contains('Please select only one account to update.')) {
          flag = true;
          break;
        }
      }

      system.assert(
        flag == true,
        'Error: The extension class failed to notify the user that he/she must select only one account to update.'
      );

      // Test Case 4 - Only one CDH account selected by the user to update.
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = false;
      }
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = true;
        break;
      }
    theExtension.updateExistingAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 2,
        'Error: The extension class failed to update the selected CDH account.'
      );

      // Test Case 5 - The user ignored all the displayed CDH accounts and decided to create a new fresh account.
    theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Agent',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        billingcountry = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

    theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createNewAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to create a new fresh account when the user ignored all the displayed CDH accounts.'
      );

      // Test Case 6 - No matching CDH accounts found and a new account is created based on the data submitted by the user as search criteria.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Broker',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        billingcountry = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createAccount();
      theExtension.updatename();
      theExtension.copy_billingto_shipping();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to create a new account based on the data submitted by the user as search criteria when no matching CDH accounts found.'
      );

    Test.stopTest();
  }

  // This method tests the behaviour of extension class when the user has access to only one account record type.
  // Test Case 1 - CDH account match found. No new account is created at this point.
  // Test Case 2 - No CDH account selected by user.
  // Test Case 3 - Multiple CDH accounts selected by the user.
  // Test Case 4 - Only one CDH account selected by the user to update.
  // Test Case 5 - The user ignored all the displayed CDH accounts and decided to create a new fresh account.
  // Test Case 6 - No matching CDH accounts found and a new account is created based on the data submitted by the user as search criteria.
  private static testMethod void testDefaultRecordTypeAccess() {
      // Setting Mock Callout Class.
      // This Causes A Fake Response To Be Generated.
      Test.setMock(WebServiceMock.class, new CreateNewAccountExtensionMockCallout());

    // Extracting Move Agent Sales Rep Profile.
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME limit 1];
    system.assert(profile.size() > 0,'Error: Requested profile named ' + PROFILE_NAME + ' does not exist.');

    // Inserting Custom Setting Data.
    CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
      Account_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchAccountCDH/matchaccountcdhservice_client_ep?WSDL'
    );
    insert customSettingData;
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    // Inserting Test Accounts.
    Account theAccount = null;
    List<Account> theTestAccounts = new List<Account>();

    theAccount = TestDataFactory.createAccount('The Test Account 1', null, false);
    theAccount.Party_ID__c = '28993489';
    theAccount.Type = 'Agent';
    theAccount.BillingStreet = 'Mahindra World City, Sez';
    theAccount.BillingCity = 'Jaipur';
    theAccount.BillingState = 'Rajasthan';
    theAccount.BillingPostalCode = '302012';
    theAccount.Phone = '9876543210';
    theAccount.Email_Address__c = 'hsingh@appirio.com';
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theTestAccounts.add(theAccount);

    theAccount = TestDataFactory.createAccount('The Test Account 2', null, false);
    theAccount.Party_ID__c = '28993489';
    theAccount.Type = 'Agent';
    theAccount.BillingStreet = 'Mahindra World City, Sez';
    theAccount.BillingCity = 'Jaipur';
    theAccount.BillingState = 'Rajasthan';
    theAccount.BillingPostalCode = '302012';
    theAccount.Phone = '9876543210';
    theAccount.Email_Address__c = 'hsingh@appirio.com';
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theTestAccounts.add(theAccount);

    insert theTestAccounts;

    // Creating Move Agent Sales Rep User.
    User theSalesRepUser = TestDataFactory.createUser(null, profile[0].Id, null, 'hurt@life.com', 'life@hurt.com', true);
    system.runAs(theSalesRepUser) {
        PageReference thePage = Page.CreateNewAccount;
        Test.setCurrentPage(thePage);

      // Test Case 1 - CDH account match found. No new account is created at this point.
      ApexPages.StandardController theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Agent',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

      Test.startTest();

      CreateNewAccountExtension theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.cancelProcess();
      theExtension.createAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 2,
        'Error: No new account must be created at this point since a CDH account match is found.'
      );

      // Test Case 2 - No CDH account selected by user.
      theExtension.updateExistingAccount();

        Boolean flag = false;
        List<Apexpages.Message> theMessages = ApexPages.getMessages();
        for(Apexpages.Message theMessage : theMessages) {
          if(theMessage.getDetail().contains('Please select at least one account to update.')) {
            flag = true;
            break;
          }
        }

      system.assert(
        flag == true,
        'Error: The extension class failed to notify the user that he/she must select at least one account to update.'
      );

      // Test Case 3 - Multiple CDH accounts selected by the user.
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = true;
      }
      theExtension.updateExistingAccount();

      flag = false;
      theMessages = ApexPages.getMessages();
      for(Apexpages.Message theMessage : theMessages) {
        if(theMessage.getDetail().contains('Please select only one account to update.')) {
          flag = true;
          break;
        }
      }

      system.assert(
        flag == true,
        'Error: The extension class failed to notify the user that he/she must select only one account to update.'
      );

      // Test Case 4 - Only one CDH account selected by the user to update.
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = false;
      }
      for(CreateNewAccountExtension.AccountWrapper theAccountWrapper : theExtension.theSelectedAccounts) {
        theAccountWrapper.isSelected = true;
        break;
      }
      theExtension.updateExistingAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 2,
        'Error: The extension class failed to update the selected CDH account.'
      );

      // Test Case 5 - The user ignored all the displayed CDH accounts and decided to create a new fresh account.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Agent',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createNewAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to create a new fresh account when the user ignored all the displayed CDH accounts.'
      );

      // Test Case 6 - No matching CDH accounts found and a new account is created based on the data submitted by the user as search criteria.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Broker',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        BillingPostalCode = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to create a new account based on the data submitted by the user as search criteria when no matching CDH accounts found.'
      );

      // Test Case 7 - Validate account billing address and shipping address when all the address fields are left blank.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Broker',
        Phone = '9876543210'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createAccount();
      theExtension.updatename();
      theExtension.copy_billingto_shipping();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to validate account billing address and shipping address when all the address fields are left blank.'
      );

      // Test Case 8 - Validate account billing address and shipping address when few address fields are left blank.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Broker',
        Phone = '9876543210',
        BillingStreet = 'Test',
        BillingCity = 'Test',
        BillingState = 'Test',
        ShippingStreet = 'Test',
        ShippingCity = 'Test',
        ShippingState = 'Test',
        Primary_Email__c = 'hsingh@appirio.com'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createAccount();

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to validate account billing address and shipping address when few address fields are left blank.'
      );

      // Test Case 9 - Validating phone number and email address.
      theStandardController = new ApexPages.StandardController(new Account(
        Name = 'The Test Account 3',
        Type = 'Broker',
        Home_Phone__c = '9876543210',
        ShippingStreet = 'Test',
        ShippingCity = 'Test',
        ShippingState = 'Test',
        ShippingPostalCode = 'Test',
        Preferred_Phone__c = 'Home Phone'
      ));

      theExtension = new CreateNewAccountExtension(theStandardController);
      theExtension.createAccount();
      

      system.assert(
        [SELECT Id FROM Account].size() == 3,
        'Error: The extension class failed to validate account phone number and email address.'
      );

      Test.stopTest();
    }
  }
}