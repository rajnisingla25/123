/*
Test Class for  : AccountConsolidatedBilling
*/
@isTest(seealldata = true)
//@isTest
private class AccountConsolidatedBilling_Test{
    
    private static Account testAccount;
    private static Zuora__CustomerAccount__c billingAccount;
    private static Zuora__Subscription__c subscription;
    
    static testMethod void checkByPassNullAccountIdSecanrios(){
        
        test.startTest();
            AccountConsolidatedBilling.consolidateAccountInZuora(null, null);
            AccountConsolidatedBilling obj = new AccountConsolidatedBilling();
        test.stopTest();
    }
    
    static testMethod void checkByPassAccountIdSecanrios(){
        
        // insert custom setting
        DisabledTrigger__c disTrigCustomSett = new DisabledTrigger__c();
        disTrigCustomSett.Name = 'Disabled';
        disTrigCustomSett.TaskTrigger__c = 'test@gmail.com';
        disTrigCustomSett.AccountTrigger__c = 'test@gmail.com';
       // insert disTrigCustomSett;
        
        //DisabledTrigger__c disTrigCustomSett = Z_LegacyTestFactory.CreateDisabledTriggerSingle();
        
        
        // insert Account
        testAccount = Z_LegacyTestFactory.makeAccount(); //Create Account
        // insert Billing Account
        billingAccount = Z_LegacyTestFactory.makeBillingAccount(testAccount);
        
        //update account
        testAccount.Consolidated_Billing_Flag__c = true;
        testAccount.Collections_Hold__c = true;
        update testAccount;
        
         testAccount = Z_LegacyTestFactory.makeAccount(); //Create Account
        // insert Billing Account
        billingAccount = Z_LegacyTestFactory.makeBillingAccount(testAccount);
        
        //update account
        testAccount.Consolidated_Billing_Flag__c = true;
        testAccount.Collections_Hold__c = true;
        update testAccount;
        
        //test.startTest();
            
        //test.stopTest();
        
        /*
        // insert subscription
        subscription = Z_LegacyTestFactory.makeSubscription(account, billingAccount);
        
        //insert Product
        zqu__zProduct__c zprod = Z_LegacyTestFactory.makeProduct();
        
        // insert rateplan
        List<zqu__ProductRatePlan__c> p_rateplans = Z_LegacyTestFactory.makeRatePlan(zprod);
        
        //insert Rateplancharge
        List<zqu__ProductRatePlanCharge__c> ratePlanCharges = Z_LegacyTestFactory.makeRatePlanCharges(p_rateplans);
        */
        /*
        test.startTest();
            AccountConsolidatedBilling.consolidateAccountInZuora(account.Id, string.valueOf(system.now()));
        test.stopTest();
        */
    }
}