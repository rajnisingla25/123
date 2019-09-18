public with sharing class PaymentProfileController {
    @AuraEnabled(cacheable=true)
    public static List<PaymentProfiles__c > getPaymentData(String accId) {
        return [SELECT Id, Name,Account__c,SplitPercentage__c,CreditCardType__c,Reason_Code__c,Expiration_Date__c, ACH_Account_Number_Mask__c  from PaymentProfiles__c  where Account__c =: accId];
    }    
}