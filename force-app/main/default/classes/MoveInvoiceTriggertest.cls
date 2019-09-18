@isTest
private class MoveInvoiceTriggertest {
    static testMethod void TestInvoice() {    
        
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.Zuora_Invoice__c = 'testdatamigration@move.com.eut';
        insert disabledTriggerCustomSetting;
 
        Account newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '1234567890';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890';
        newAccount.Work_Phone__c = '1234567890';
        newAccount.Mobile1__c = '1234567890';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';           
        insert newAccount;
            
       Zuora__CustomerAccount__c b = new Zuora__CustomerAccount__c();
       b.Past_Due_Balance__c= 60;
       b.Zuora__Account__c = newAccount.Id;
       insert b;
       
       Zuora__ZInvoice__c a = new Zuora__ZInvoice__c();
       a.Invoice_Status__c='Paid';
       a.Zuora__Balance2__c= 40;
       a.Zuora__BillingAccount__c = b.Id;
       insert a;
       
       a.Invoice_Status__c= 'Past Due';
       update a;

    }
}