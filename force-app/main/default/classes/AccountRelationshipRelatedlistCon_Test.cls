//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: AccountRelationshipRelatedlistCon_Test
// For Testing: AccountRelationshipRelatedlistController class
//
//13th April 2015     Kirti Agarwal           (Task # T-376900)
//20th May 2015       Ravindra Shekhawat            (Updated Test Class Failures and Improved Coverage)
//
@isTest
private class AccountRelationshipRelatedlistCon_Test {

  static testMethod void AccountRelationshipRelatedlistCon_Test() {
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account theAccount = TestDataFactory.createAccount('The Test Account for', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    List<Account> accounts = new List<Account>();
    accounts.add(theAccount);
    theAccount = TestDataFactory.createAccount('The Test Account for 1', null, false);
    theAccount.Primary_Email__c = 'agent@move.com';
    theAccount.Type = Constants.AGENT_ACCOUNT_TYPE;
    accounts.add(theAccount);
    insert accounts;

    AccountRelationshipRelatedlistController objOfAccountRelationship =
      new AccountRelationshipRelatedlistController(new ApexPages.StandardController(accounts.get(0)));

    //account record related to this class should not be null
    System.assertEquals(objOfAccountRelationship.parentFieldName , 'Office__c');
    
    objOfAccountRelationship =
      new AccountRelationshipRelatedlistController(new ApexPages.StandardController(accounts.get(1)));
    System.debug('URL Field is : '+objOfAccountRelationship.url);
   //account record related to this class should not be null
    System.assertEquals(objOfAccountRelationship.parentFieldName , 'Agent__c'); 
  }
}