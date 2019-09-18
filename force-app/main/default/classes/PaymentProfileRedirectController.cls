public with sharing class PaymentProfileRedirectController {
    
    private  String acc; 
    
    
    public PaymentProfileRedirectController(ApexPages.StandardController controller) {
        
    }
    
    public PageReference onLoad(){
        acc =  ApexPages.currentPage().getParameters().get('id');
        //flag = false;
        List<Zuora__CustomerAccount__c> billingAccounts = [
            SELECT
            Id, Zuora__Account__r.Subscription_payment__c,Zuora__Account__r.Type
            FROM
            Zuora__CustomerAccount__c
            WHERE
            Zuora__Account__c = :acc
            LIMIT 1];
        
        if (billingAccounts.size() > 0){
            if(billingAccounts[0].Zuora__Account__r.Type == 'Lender Individual' && billingAccounts[0].Zuora__Account__r.Subscription_payment__c)
                return new PageReference('/apex/LenderPaymentProfile?id='  + acc);  
            else if(billingAccounts[0].Zuora__Account__r.Subscription_payment__c)
            return new PageReference('/apex/ManageSubscriptionPaymentmethods?id='  + acc);
            else               
            return new PageReference('/apex/Z_PaymentProfileManager?id='  + acc);
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'No Zuora Billing Account Exists for this SFDC Account'));
        return null;
    }
    public PageReference redirect(){
        acc =  ApexPages.currentPage().getParameters().get('id');
        return new PageReference('/' + acc);
    }
    //CRM-3829 Create Zuora Account
    public PageReference CreateZuoraBillingAccount(){
        String Billinaccountid = '';
        List<Account> accounts = [SELECT Id,Name,Subscription_payment__c,Type,Billing_Preference__c,Currency_Type__c,
                                  BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,
                                  ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,
                                  Zoura_Account_id__c, Phone, Party_ID__c
                                  FROM Account WHERE Id = :acc LIMIT 1];
        if (accounts.size() > 0) {
            
          Z_PaymentMethodCaptureUtil tt = new Z_PaymentMethodCaptureUtil();
            try{
                Billinaccountid = tt.createZuoraAccount(accounts[0]);
            }catch(Exception ex){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'Failed to Create the Billing Account ' +ex));
                return null;
            }
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.info,'Billing account succesfully created in Zuora ' + Billinaccountid ));
        return null;
    }
    public PageReference ManagePaymentProfile(){
         ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.info,'If Billing account created successfully in Previous attempt. Please use the Sync data from z-Billing on account to sync the billing account from Zuora or wait for some timie and retry. '));
         return new PageReference('/apex/PaymentProfileRedirect?id=' + acc);
    }
    
    
}