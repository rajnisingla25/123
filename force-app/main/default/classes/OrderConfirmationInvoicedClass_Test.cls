@isTest
private class OrderConfirmationInvoicedClass_Test {

 @isTest(seeAllData=false) 
     static void testOrderConfirmation() {
         //Custom Settings//
     DisabledTrigger__c Dtrg = new DisabledTrigger__c();
     Dtrg.TaskTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AssetTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AccountTrigger__c = 'datamigration@move.com.sit';
     Dtrg.Name = 'Disabled';
     insert Dtrg;
     //Account setup
      List<Account> accountList =new List<Account>();
    Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theTestAccount.Primary_Email__c = 'testEmail1@test.com';
    theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
    //accountList.add(theTestAccount);

    insert theTestAccount;
    // Contract set up//
    Contract contractVar= new Contract(
    AccountID= theTestAccount.ID,
    Status = 'Draft',
    //ActivatedDate = Date.Today(),
    ContractTerm= 1,
    StartDate =Date.Today()
    //EndDate = Date.Today()+30
    );
    insert contractVar;
    // Order set up//
    Order ord= new Order(
    AccountID = theTestAccount.ID,
    EffectiveDate = Date.Today(),
    ContractID = contractVar.ID,
    Status  = 'Created'
    ); 
    insert ord;
     Test.startTest();
    new OrderConfirmationInvoicedClass();
    Test.stopTest();
         
     }

}