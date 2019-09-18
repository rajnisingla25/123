/***********************************************************************
 Class        : SmartSearchUtility_Test
 Author       : Appirio
 Created Date : 4 march 2014
 Descritption : Provide test coverage to SmartSearchUtility.cls
************************************************************************/
@isTest
private class SmartSearchUtility_Test {
  static testMethod void testGetAutoFillValues() {
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account account = new Account(Name = 'Test Account');
    account.Home_Phone__c = '9876543210';
    account.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
    account.BillingCity = 'HOPEWELL JUNCTION';
    account.BillingPostalCode = '12533';
    account.BillingState = 'NY';
    account.BillingCountry = 'USA';
    account.Preferred_Phone__c = 'Home Phone';
    insert account;
        
    Id[] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = account.Id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();

    List<String> lstAutoFillResult = SmartSearchUtility.getAutoFillValues('Test', 'Account', 'Name');
    system.assertEquals(lstAutoFillResult[0], 'Test Account', 'Method should return the name value "Test Account"');

    Test.stopTest();
  }

  static testMethod void testCreateFieldCsv() {
    // We can not create fieldset in the test class, so passing a rendom field set name
    String fieldCSV = SmartSearchUtility.createFieldCsv('Account', 'testFieldSet');
    system.assertEquals(fieldCSV, 'Name,Id', 'If field set does not exist then "Name,Id" should be the default value return by the method.');
  }

  static testMethod void testGetPrefix() {
    String theObjectPrefix = SmartSearchUtility.getPrefix('Account');
    system.assert(theObjectPrefix == '001', 'Error: The utility class failed to extract object prefix.');
  }
}