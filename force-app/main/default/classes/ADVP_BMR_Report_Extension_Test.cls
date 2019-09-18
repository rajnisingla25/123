@isTest(seeAllData=false)
private class ADVP_BMR_Report_Extension_Test {
  // Private Data Member.
  private static final Integer COUNTER = 5;

  private static testMethod void testExtensionFunctionality() {
    // Inserting Custom Setting Data.
    CDH_Webservices_Endpoints__c theCustomSettingData = new CDH_Webservices_Endpoints__c();
    theCustomSettingData.BDR_Report_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/default/BMRRealtorList/client';
    theCustomSettingData.BMR_Report_Endpoint__c = 'http://paz02app401/MicroStrategy/asp/Main.aspx?evt=2048001&documentID=BCE7BD6445AD2FF4DC65A5B338A11814&server=PAZ02MST292&Project=Polaris&elementsPromptAnswers=395063C24DA48B3B967B70A6976BB209;395063C24DA48B3B967B70A6976BB209:';
    insert theCustomSettingData;

    // Setting Mock Callout Class.
    // This Causes A Fake Response To Be Generated.
    Test.setMock(WebServiceMock.class, new ADVP_BMR_Report_ExtensionMockCallout());

    // Setting The Current Page.
    PageReference thePage = Page.BMR_Report;
    Test.setCurrentPage(thePage);

    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
   insert arc;         
    // Inserting Test Accounts.
    Account theTestAccount = null;
    List<Account> theTestAccounts = new List<Account>();
    for(Integer index = 0; index < COUNTER; index++) {
      theTestAccount = TestDataFactory.createAccount(
        (index == 0) ? 'The Broker Account' : 'The Realtor Office Account #' + (index + 1),
        null,
        false
      );
      theTestAccount.Primary_Email__c = 'hsingh@appirio.com';
      theTestAccount.Type = (index == 0) ? 'Broker' : 'Realtor Office';
      theTestAccounts.add(theTestAccount);
    }
    insert theTestAccounts;

    // Setting The Report Type.
    ApexPages.currentPage().getParameters().put('type', 'BMR');

    Test.startTest();

    // Test Case 1 - When the broker account is not related to any office account.
    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theTestAccounts.get(0));
    ADVP_BMR_Report_Extension theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.INFO,
        'Sorry! We didn\'t find any office account related to broker account "' + theTestAccounts.get(0).Name + '"'
      )),
      'Error: The extension class failed to notify user that the broker account is not related to any office account.'
    );

    // Inserting Account Relationship Records.
    List<Account_Relationship__c> theAccountRelationships = new List<Account_Relationship__c>();
    for(Integer index = 0; index < COUNTER - 1; index++) {
      theAccountRelationships.add(TestDataFactory.createAccountRelationship(
        theTestAccounts.get(0).Id,
        theTestAccounts.get(index + 1).Id,
        null,
        null,
        true,
        false
      ));
    }
    insert theAccountRelationships;

    // Test Case 2 - When the broker account is related to the office accounts but the office accounts are not related to any MLS record.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.INFO,
        'Sorry! We didn\'t find any MLS Set Ids for office accounts related to broker account "' + theTestAccounts.get(0).Name + '"'
      )),
      'Error: The extension class failed to notify user that the office accounts are not related to any MLS record.'
    );

    // Inserting MLS Records For Office Accounts Inserted Above.
    List<MLS__c> theMLSRecords = new List<MLS__c>();
    for(Integer index = 1; index < COUNTER; index++) {
      theMLSRecords.add(new MLS__c(
        MLS__c = theTestAccounts.get(0).Id,
        Office__c = theTestAccounts.get(index).Id,
        MLS_Set_Type__c = 'Office',
        Status__c = 'Active',
        MLS_Set_ID__c = 'O-NWSD-ERBC-NBH' + index
      ));
    }
    insert theMLSRecords;

    // Test Case 3 - When the report name is left blank by the user.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    theExtension.theReportName = '';
    theExtension.generateReport();
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Please provide report name.'
      )),
      'Error: The extension class failed to notify user that the report name cannot be blank.'
    );

    // Test Case 4 - When the report name is provided by the user but none of the office accounts is selected by the user.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    theExtension.theReportName = 'BMR Report';
    for(ADVP_BMR_Report_Extension.OfficeAccounts theOfficeAccount : theExtension.theOfficeAccounts) {
      theOfficeAccount.isSelected = false;
    }
    theExtension.generateReport();
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Please select at least one office.'
      )),
      'Error: The extension class failed to notify user that none of the office accounts is selected by the user.'
    );

    // Test Case 5 - When the office account Id and MLS Set Id has mapping for the broker office accounts.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    theExtension.theReportName = 'BMR Report';
    theExtension.theOfficeAccountIdAndMLSSetIDMapping = new Map<Id, Set<String>>();
    theExtension.generateReport();
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Sorry! We didn\'t find any MLS Set ID for the selected office accounts.'
      )),
      'Error: The extension class failed to notify user that the selected office accounts has no MLS Set IDs.'
    );

    // Test Case 6 - When the web-service call throws an exception.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    theExtension.theReportName = 'BMR Report - Message Failed';
    theExtension.generateReport();
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Message failed. Please contact your administrator.'
      )),
      'Error: The extension class failed to notify user that the web-service call has failed.'
    );

    // Test Case 7 - When the web-service call returns a non-zero response code.
    theExtension = new ADVP_BMR_Report_Extension(theStandardController);
    theExtension.theReportName = 'BMR Report - Non-Zero Response Code';
    theExtension.generateReport();
    system.assert(
      TestDataFactory.wasMessageAdded(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Message failed. Please contact your administrator.'
      )),
      'Error: The extension class failed to notify user that the web-service call has failed.'
    );

    Test.stopTest();
  }
}