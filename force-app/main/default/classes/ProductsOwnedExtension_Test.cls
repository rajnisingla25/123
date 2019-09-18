//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: ProductsOwnedExtension_Test
// For Extension Class: ProductsOwnedExtension
// For Apex Page: ProductsOwned
//
// 04th June 2015   Hemendra Singh Bhati   Original (Task # T-396116)
//
@isTest(seeAllData=false)
private class ProductsOwnedExtension_Test {
     
  // Private Data Members.
  private static final Integer COUNTER = 3;
  private static final String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';
  private static final List<String> theAccountTypes = new List<String> {
    'Realtor Agent',
    'Realtor Office',
    'Broker'
  };

  private static testMethod void testExtensionFunctionality() {
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    // Account Relationship Record Type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Inserting Accounts.
    Account theAccount = null;
    List<Account> theAccounts = new List<Account>();
    for(Integer index = 0;index < COUNTER;index++) {
      theAccount = TestDataFactory.createAccount('The ' + theAccountTypes.get(index) + ' Account', null, false);
      theAccount.Type = theAccountTypes.get(index);
      theAccount.Own_CoShow__c = true;
      theAccount.Primary_Email__c = 'hsingh@appirio.com';
      theAccounts.add(theAccount);
    }
    insert theAccounts;

    // Inserting Account Relationship Records.
    Account_Relationship__c theAccountRelationship = null;
    List<Account_Relationship__c> theAccountRelationships = new List<Account_Relationship__c>();
    for(Integer index = 0;index < COUNTER - 1;index++) {
      theAccountRelationship = TestDataFactory.createAccountRelationship(
        theAccounts.get(index + 1).Id,
        theAccounts.get(index).Id,
        null,
        null,
        true,
        false
      );
      theAccountRelationship.Is_Parent_Primary__c = true;
      theAccountRelationship.RecordTypeId = accountRelationshipRecordTypeId;
      theAccountRelationships.add(theAccountRelationship);
    }
    insert theAccountRelationships;

    Test.startTest();

    ApexPages.StandardController theStandardController = new ApexPages.StandardController(theAccounts.get(0));
    ProductsOwnedExtension theExtension = new ProductsOwnedExtension(theStandardController);
    system.assert(
      theExtension.theRealtorAgentOwnCoShow == true,
      'Error: The extension class failed to set the boolean flag to true.'
    );

    Test.stopTest();
  }
}