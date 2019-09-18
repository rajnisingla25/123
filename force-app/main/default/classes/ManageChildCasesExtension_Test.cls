//
// (c) 2015 Appirio, Inc.
//
// Test Class: ManageChildCasesExtension_Test
// For Apex Extension: ManageChildCasesExtension
// For Apex Page: ManageChildCases
// Description: A process where the user can create an email from scratch or from an existing template. The user can then view a
// filterable list of all child cases related to the global parent case. He/she can select one or more child cases to send the mass email to.
// The user should also be able to update the status of the selected cases. The user can then send the email and return to the parent case.
//
// 03rd April 2015   Hemendra Singh Bhati   Original (Task # T-375441)
//
@isTest
private class ManageChildCasesExtension_Test {
  private static final Integer COUNTER = 10;
  private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';

  // This method tests the behaviour of extension class when there are no child cases to process.
  private static testMethod void testCaseNoChildCases() {  
     //Inserting custom setting to avoid NullPointerException    
      DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
        insert trg;      
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email = 'hsingh@appirio.com';
    insert theContact;

    // Inserting Parent Case.
    Case theParentCase = TestDataFactory.createCase('Parent Case', 'New', 'International', 'Parent Case', theContact.Id, theAccount.Id, true);

    PageReference thePage = Page.ManageChildCases;
    Test.setCurrentPage(thePage);

    ApexPages.currentPage().getParameters().put('parentCaseId', theParentCase.Id);
    ApexPages.currentPage().getParameters().put('ParentCaseNumber', theParentCase.CaseNumber);

    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theParentCase);

    Test.startTest();

    ManageChildCasesExtension theExtension = new ManageChildCasesExtension(theStandardController);

    Boolean flag = false;
    List<Apexpages.Message> theMessages = ApexPages.getMessages();
    for(Apexpages.Message theMessage : theMessages) {
      if(theMessage.getDetail().contains('No child cases found.')) {
        flag = true;
        break;
      }
    }

    Test.stopTest();

    system.assert(flag == true, 'Error: The extension class failed to notify the user that there are no child cases.');
  }

  // This method tests the behaviour of extension class when parent case has child cases to process. This method validates the following three
  // test cases:
  // Test Case 1 - When parent case status is updated.
  // Test Case 2 - When child cases status is updated.
  // Test Case 3 - When parent case status is applied to selected child cases.
    private static testMethod void testCaseHasChildCases() {
        //Inserting custom setting to avoid NullPointerException    
      DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
        insert trg;
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email = 'hsingh@appirio.com';
    insert theContact;

    // Inserting Parent Case.
    Case theParentCase = TestDataFactory.createCase('Parent Case', 'New', 'International', 'Parent Case', theContact.Id, theAccount.Id, true);

    // Inserting Child Cases.
    Case theChildCase = null;
    List<Case> theChildCases = new List<Case>();
    for(Integer index = 0; index < COUNTER; index++) {
        theChildCase = TestDataFactory.createCase(
         'Child Case #' + index,
         'New',
         'International',
         'Child Case #' + index,
         theContact.Id,
         theAccount.Id,
         false
        );
        theChildCase.ParentId = theParentCase.Id;
        theChildCases.add(theChildCase);
    }
    insert theChildCases;

    PageReference thePage = Page.ManageChildCases;
    Test.setCurrentPage(thePage);

    ApexPages.currentPage().getParameters().put('parentCaseId', theParentCase.Id);
    ApexPages.currentPage().getParameters().put('ParentCaseNumber', theParentCase.CaseNumber);

    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theParentCase);

    Test.startTest();

    ManageChildCasesExtension theExtension = new ManageChildCasesExtension(theStandardController);

    // Test Case 1 - Parent Case Status Updated.
    theExtension.theParentCase.Status = 'Open';
    theExtension.theParentCaseComments = 'Test Comment';
    theExtension.isParentCaseStatusChanged = true;
    theExtension.isChildCaseStatusChanged = false;
    theExtension.applyParentCaseStatusToChildCases = false;
    theExtension.updateStatus();

    system.assert(
      [SELECT Status FROM Case WHERE Id = :theParentCase.Id].Status == 'Open',
      'Error: The extension class failed to update the status of parent case.'
    );

    // Test Case 2 - Child Cases Status Updated.
    Integer index = 0;
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.theChildCase.Status = 'Open';
        theWrapper.isSelected = true;
        index++;
        if(index > 1) {
            break;
        }
    }
    theExtension.isParentCaseStatusChanged = false;
    theExtension.isChildCaseStatusChanged = true;
    theExtension.applyParentCaseStatusToChildCases = false;
    theExtension.theParentCaseComments = 'Test Comment';
    theExtension.updateStatus();

    system.assert(
      [SELECT Status FROM Case WHERE Id != :theParentCase.Id AND Status = 'Open'].size() == 2,
      'Error: The extension class failed to update the status of selected child cases.'
    );

    // Test Case 3 - Apply Parent Case Status To Selected Child Cases.
    index = 0;
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.isSelected = true;
      index++;
      if(index > 3) {
        break;
      }
    }
    theExtension.isParentCaseStatusChanged = false;
    theExtension.isChildCaseStatusChanged = false;
    theExtension.applyParentCaseStatusToChildCases = true;
    theExtension.theParentCaseComments = 'Test Comment';
    theExtension.updateStatus();

    system.assert(
      [SELECT Status FROM Case WHERE Id != :theParentCase.Id AND Status = 'Open'].size() == 4,
      'Error: The extension class failed to apply parent case status to selected child cases.'
    );

    Test.stopTest();
    }

  // This method tests the behaviour of extension class when a user tries to add comments to a parent case and/or selected child cases.
  // The test cases validated in this method are as follows:
  // Test Case 1 - When a user tries to add a blank comment to the closed parent case.
  // Test Case 2 - When a user tries to add a case comment to the parent case and selected child cases.
    private static testMethod void testAddingComments() {
        //Inserting custom setting to avoid NullPointerException    
      DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
        insert trg;
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email = 'hsingh@appirio.com';
    insert theContact;

    // Inserting Parent Case.
    Case theParentCase = TestDataFactory.createCase('Parent Case', 'New', 'International', 'Parent Case', theContact.Id, theAccount.Id, true);

    // Inserting Child Cases.
    Case theChildCase = null;
    List<Case> theChildCases = new List<Case>();
    for(Integer index = 0; index < COUNTER; index++) {
      theChildCase = TestDataFactory.createCase(
       'Child Case #' + index,
       'New',
       'International',
       'Child Case #' + index,
       theContact.Id,
       theAccount.Id,
       false
      );
      theChildCase.ParentId = theParentCase.Id;
      theChildCases.add(theChildCase);
    }
    insert theChildCases;

    PageReference thePage = Page.ManageChildCases;
    Test.setCurrentPage(thePage);

    ApexPages.currentPage().getParameters().put('parentCaseId', theParentCase.Id);
    ApexPages.currentPage().getParameters().put('ParentCaseNumber', theParentCase.CaseNumber);

    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theParentCase);

    Test.startTest();

    ManageChildCasesExtension theExtension = new ManageChildCasesExtension(theStandardController);

    // Test Case 1 - When a user tries to add a blank comment to the closed parent case.
    theExtension.theParentCase.Status = 'Closed';
    theExtension.theParentCaseComments = '';
    theExtension.addCaseComments();

    Boolean flag = false;
    List<Apexpages.Message> theMessages = ApexPages.getMessages();
    for(Apexpages.Message theMessage : theMessages) {
      if(theMessage.getDetail().contains('Please enter case comments.')) {
        flag = true;
        break;
      }
    }

    system.assert(
      flag == true,
      'Error: The extension class failed to notify the user that case comments is a required field when the status of parent case is closed.'
    );

    // Test Case 2 - When a user tries to add a case comment to the parent case and selected child cases.
    theExtension.theParentCase.Status = 'Closed';
    theExtension.theParentCaseComments = 'This is a test comment';

    // Deselecting all child cases.
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.isSelected = false;
    }

    // Selecting two child cases to add case comments.
    Integer index = 0;
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.isSelected = true;
      index++;
      if(index > 1) {
        break;
      }
    }
    theExtension.addCaseComments();

    system.assert(
      [SELECT Id FROM CaseComment].size() == 3,
      'Error: The extension class failed to add case comments to the parent case and selected child cases.'
    );

    Test.stopTest();
    }

  // This method tests the behaviour of extension class when a user selects child cases to send an email to its contacts regarding case updates.
  // The test cases validated in this method are as follows:
  // Test Case 1 - When selected child cases contact has no email address specified.
  // Test Case 2 - When selected child cases contact has an email address specified.
  // Test Case 3 - When an email with no merge fields is sent to selected child cases contact.
  // Test Case 4 - When an email with merge fields is sent to selected child cases contact.
  // Test Case 5 - Validates new email template section rendering.
  // Test Case 6 - Validates new email template creation in folder named "Child Cases Email Templates".
  private static testMethod void testEmailFunctionality() {
      //Inserting custom setting to avoid NullPointerException    
      DisabledTrigger__c trg = new DisabledTrigger__c(Name = 'Disabled' ,TaskTrigger__c = UserInfo.getUserName());
        insert trg;
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email = 'hsingh@appirio.com';
    insert theContact;

    // Inserting Test Contact With No Email Address.
    Contact theContactWithoutEmail = TestDataFactory.createContact('The Test', 'Contact Without Email', theAccount.Id, true, false);
    //theContactWithoutEmail.Email = 'hsingh@appirio.com';
    insert theContactWithoutEmail;    
    // Inserting Parent Case.
    Case theParentCase = TestDataFactory.createCase('Parent Case', 'New', 'International', 'Parent Case', theContact.Id, theAccount.Id, true);

    // Inserting Child Cases.
    Case theChildCase = null;
    List<Case> theChildCases = new List<Case>();
    for(Integer index = 0; index < COUNTER; index++) {
      theChildCase = TestDataFactory.createCase(
       'Child Case #' + index,
       'New',
       'International',
       'Child Case #' + index,
       (index <= 1) ? theContactWithoutEmail.Id : theContact.Id,
       theAccount.Id,
       false
      );
      theChildCase.ParentId = theParentCase.Id;
      theChildCases.add(theChildCase);
    }
    insert theChildCases;

    PageReference thePage = Page.ManageChildCases;
    Test.setCurrentPage(thePage);

    ApexPages.currentPage().getParameters().put('parentCaseId', theParentCase.Id);
    ApexPages.currentPage().getParameters().put('ParentCaseNumber', theParentCase.CaseNumber);

    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theParentCase);

    Test.startTest();

    ManageChildCasesExtension theExtension = new ManageChildCasesExtension(theStandardController);

    // Test Case 1 - When selected child cases contact has no email address specified.
    Integer index = 0;
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.isSelected = true;
      index++;
      if(index > 1) {
        break;
      }
    }
    theExtension.sendEmailToCaseContacts();

    Boolean flag = false;
    List<Apexpages.Message> theMessages = ApexPages.getMessages();
    for(Apexpages.Message theMessage : theMessages) {
      if(theMessage.getDetail().contains('Email address not found for selected child case contact - Case Number #')) {
        flag = true;
        break;
      }
    }

    // Test Case 2 - When selected child cases contact has an email address specified.
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
      theWrapper.isSelected = false;
    }

    index = 0;
    for(ManageChildCasesExtension.ChildCasesWrapper theWrapper : theExtension.childCasesWrapper) {
        if(index > 1 && index < 5) {
            theWrapper.isSelected = true;
        }
      index++;
    }
    theExtension.selectTemplate();
    theExtension.getTemplates();
    theExtension.cancelNewTemplate();
    theExtension.sendEmailToCaseContacts();

    system.assert(
      (theExtension.toAddress != null) && (theExtension.toAddress.length() > 0),
      'Error: The extension class failed to set the value of public email template property "toAddress".'
    );

    // Test Case 3 - When an email with no merge fields is sent to selected child cases contact.
    theExtension.emailSent = false;
    theExtension.fromAddress = 'hsingh@appirio.com';
    theExtension.ccAddress = 'hsingh@appirio.com';
    theExtension.bccAddress = 'hsingh@appirio.com';
    theExtension.emailSubject = 'This is a test email subject.';
    theExtension.emailBody = 'This is a test email body.';
    theExtension.sendEmail();
    
    /*system.assert(
      theExtension.emailSent == true,
      'Error: The extension class failed to send an email message with no merge fields to selected child cases contact.'
    );*/

    // Test Case 4 - When an email with merge fields is sent to selected child cases contact.
    theExtension.emailSent = false;
    theExtension.fromAddress = 'hsingh@appirio.com';
    theExtension.ccAddress = 'hsingh@appirio.com';
    theExtension.bccAddress = 'hsingh@appirio.com';
    theExtension.emailSubject = 'Case {!Case.CaseNumber} is Assigned To You';
    theExtension.emailBody = 'Hi,\n\nCase Number {!Case.CaseNumber}, (Subject: {!Case.Subject}), (Account: {!Account.Name}), ';
    theExtension.emailBody += '(Campaign Name: {!Case.CampaignName__c}) is assigned to you for resolution. Please review it.\n\nThanks.';
    theExtension.sendEmail();

   /*system.assert(
      theExtension.emailSent == true,
      'Error: The extension class failed to send an email message with merge fields to selected child cases contact.'
    );*/

    // Test Case 5 - Validates new email template section rendering.
    theExtension.renderNewTemplateSection = false;
    theExtension.createNewTemplate();

    system.assert(
      theExtension.renderNewTemplateSection == true,
      'Error: The extension class failed to render new email template section.'
    );

    // Test Case 6 - Validates new email template creation in folder named "Child Cases Email Templates".
    // Extracting System Administrator Profile.
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
    system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');

    User theTestUser = TestDataFactory.createUser(null, profile[0].Id, null, 'hurt@life.com', 'life@hurt.com', true);
    system.runAs(theTestUser) {
        theExtension.newEmailTemplate.Name = 'The_Test_Email';
        theExtension.newEmailTemplate.DeveloperName = 'The_Test_Email';
        theExtension.createNewTemplate();
    }

    system.assert(
      theExtension.renderNewTemplateSection == false,
      'Error: The extension class failed to create a new email template in folder named "Child Cases Email Templates".'
    );

    Test.stopTest();
  }
}