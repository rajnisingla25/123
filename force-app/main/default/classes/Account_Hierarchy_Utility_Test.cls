//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: Account_Hierarchy_Utility_Test
// For Apex Class: Account_Hierarchy_Utility
// Description: Its a webservice class to extract account and relationship records.
//
// 20th May 2015    Hemendra Singh Bhati    Original (Task # T-396116)
//
@isTest(seeAllData=false)
private class Account_Hierarchy_Utility_Test {
  // Private Data Member.
  private static final Integer COUNTER = 5;
    String myStrTTT = '';
    private static testMethod void testAccountHierarchyWebService() {
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    
    // Inserting Parent Accounts.
    Account theAccount;
    List<Account> theParentAccounts = new List<Account>();
    for(Integer index = 0; index < COUNTER; index++) {
      theAccount = TestDataFactory.createAccount('The Parent Account #' + (index + 1), null, false);
      theAccount.Primary_Email__c = 'hsingh@appirio.com';

      theParentAccounts.add(theAccount);
    }
    insert theParentAccounts;

    // Inserting Child Accounts.
    List<Account> theChildAccounts = new List<Account>();
    for(Integer index = 0; index < COUNTER; index++) {
      theAccount = TestDataFactory.createAccount('The Child Account #' + (index + 1), null, false);
      theAccount.Primary_Email__c = 'hsingh@appirio.com';

      theChildAccounts.add(theAccount);
    }
    insert theChildAccounts;

    // Inserting Parent And Child Account Relationships.
    List<Account_Relationship__c> theParentAndChildAccountRelationships = new List<Account_Relationship__c>();
    for(Integer index = 0; index < COUNTER; index++) {
      theParentAndChildAccountRelationships.add(new Account_Relationship__c(
        Parent_Account__c = theParentAccounts.get(index).Id,
        Child_Account__c = theChildAccounts.get(index).Id,
        Is_Parent_Primary__c = true,
        Active__c = true
      ));
    }
    insert theParentAndChildAccountRelationships;

    // Inserting Test Products.
    List<Product2> theTestProducts = new List<Product2>();
    for(Integer index = 0; index < COUNTER; index++) {
      theTestProducts.add(new Product2(
        Name = 'The Test Product #' + (index + 1),
        S_No__c = index + 1,
        Family = 'Hardware'
      ));
    }
    insert theTestProducts;

    Test.startTest();

    // Test Case 1 - Validate Method: getAccountName(String AccountId).
    Account_Hierarchy_Utility.AccountDetails theAccountNameDetails = Account_Hierarchy_Utility.getAccountName(theParentAccounts.get(0).Id);
    system.assert(
      theAccountNameDetails != null && theAccountNameDetails.Name == 'The Parent Account #1',
      'Error: The account hierarchy utility class failed to extract account name.'
    );

    // Test Case 2 - Validate Method: getAccountName(String AccountId).
    theAccountNameDetails = Account_Hierarchy_Utility.getAccountName(theTestProducts.get(0).Id);
    system.assert(
      theAccountNameDetails == null,
      'Error: The account hierarchy utility class failed to return null for invalid account Id.'
    );

    // Test Case 3 - Validate Method: getChildRelationships(String AccountId).
    List<Account_Hierarchy_Utility.AccountDetails> theChildRelationships = Account_Hierarchy_Utility.getChildRelationships(theParentAccounts.get(0).Id);
    system.assert(
      theChildRelationships.size() != 0,
      'Error: The account hierarchy utility class failed to extract child relationships records.'
    );

    // Test Case 4 - Validate Method: getParentRelationships(String AccountId).
    List<Account_Hierarchy_Utility.AccountDetails> theParentRelationships = Account_Hierarchy_Utility.getParentRelationships(theChildAccounts.get(0).Id);
    system.assert(
      theParentRelationships.size() != 0,
      'Error: The account hierarchy utility class failed to extract parent relationships records.'
    );

    // Test Case 5 - Validate Method: getAccountDetails(String AccountId).
    List<Account_Hierarchy_Utility.AccountDetail> theAccountDetails = Account_Hierarchy_Utility.getAccountDetails(theParentAccounts.get(0).Id);
    system.assert(
      theAccountDetails.size() != 0,
      'Error: The account hierarchy utility class failed to extract account details of given account Id.'
    );

    // Test Case 6 - Validate Method: getProductList().
    List<Account_Hierarchy_Utility.ProductData> theProductList = Account_Hierarchy_Utility.getProductList();
    system.assert(
      theProductList.size() != 0,
      'Error: The account hierarchy utility class failed to extract a list of all products.'
    );

    Test.stopTest();
    }
}