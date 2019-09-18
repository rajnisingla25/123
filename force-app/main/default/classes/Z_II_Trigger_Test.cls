@isTest
private class Z_II_Trigger_Test {

 @isTest(seeAllData=false) 
     static void testZ_II_TriggerFunctionality() {
         
          //Custom Settings//
     DisabledTrigger__c Dtrg = new DisabledTrigger__c();
     Dtrg.TaskTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AssetTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AccountTrigger__c = 'datamigration@move.com.sit';
     Dtrg.Name = 'Disabled';
     insert Dtrg;
     
     // Inserting Test Account.
     //List<Account> accountList =new List<Account>();
    Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theTestAccount.Primary_Email__c = 'testEmail1@test.com';
    theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
    //accountList.add(theTestAccount);

    insert theTestAccount;
         //setup for Zuora__ZInvoice__c
         Zuora__ZInvoice__c invData = new Zuora__ZInvoice__c(
         Name = 'INV00195434',
         Zuora__Account__c = theTestAccount.ID,
         Zuora__Balance2__c=234.00,
         Zuora__InvoiceDate__c = Date.Today(),
         Zuora__TargetDate__c = Date.Today()+2
         
         );
         insert invData;
         
         Invoice_Item__c invoice = new Invoice_Item__c(
         Name = 'INV00195434',
         Invoice__c = invData.ID,
         Quantity__c =1
         
         );
         insert invoice;
         Invoice_Item__c invoice2 = new Invoice_Item__c(
         Name = 'INV00195511',
         Invoice__c = invData.ID
         
         );
         insert invoice2;
         invoice2.Quantity__c = 2;
         update invoice2;
     
     
     }


}