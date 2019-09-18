public with sharing class Z_UpdatePaymentProfile {

    public static void UpdatePaymentProfile(List<String> methods){
        //get payment method information
        //CRM-5442 added Zuora__BankIdentificationNumber__c field to the Query to update payment profile CRM-5442.
        List<Zuora__PaymentMethod__c> Pms = [SELECT ID, Zuora__External_Id__c, Zuora__AchAbaCode__c,Zuora__BankIdentificationNumber__c , Zuora__AchAccountName__c, Zuora__AchAccountNumberMask__c, Zuora__AchAccountType__c, Zuora__AchBankName__c, Zuora__BillingAccount__c, Zuora__Type__c , Zuora__CreditCardExpirationMonth__c, Zuora__CreditCardExpirationYear__c, Zuora__CreditCardHolderName__c, Zuora__CreditCardMaskNumber__c, Zuora__CreditCardType__c FROM Zuora__PaymentMethod__c WHERE id in :methods];
        System.debug('Pms: ' + Pms);
        Map<String,Zuora__PaymentMethod__c> methodMap = new Map<String,Zuora__PaymentMethod__c>();
        //make list of linking to payment profile
        List<String> zuoraId = new List<String>();
        for(Zuora__PaymentMethod__c pm : Pms ){
            if(String.isNotBlank(pm.Zuora__External_Id__c)){
                zuoraId.add(pm.Zuora__External_Id__c);//switch this to zuora id
                methodMap.put(pm.Zuora__External_Id__c, pm);
            }    
        }

        //search for all information 
        List<PaymentProfiles__c> profiles = [SELECT ID, PaymentMethodId__c, ACH_ABA_Code__c,Credit_Card_BIN__c , ACH_Account_Name__c, ACH_Account_Number_Mask__c, ACH_Account_Type__c, ACH_Bank_Name__c, BillingAccountId__c, Payment_Method_Type__c, ExpirationDate__c, CardholderName__c, MaskNumber__c, CreditCardType__c FROM PaymentProfiles__c WHERE PaymentMethodId__c in :zuoraId];
        System.debug('profiles: '+ profiles);
        //put both into a map based on id to PM and PP
        Map<String,PaymentProfiles__c> profileMap = new Map<String,PaymentProfiles__c>();
        for(PaymentProfiles__c profile : profiles){
            profileMap.put(profile.PaymentMethodId__c, profile);
        }

        PaymentProfiles__c tempProfile;
        Zuora__PaymentMethod__c tempMethod;

        for(String id : methodMap.keySet()){
            tempMethod = methodMap.get(id);
            System.debug('tempMethod: '+tempMethod);
            tempProfile = profileMap.get(id);
            System.debug('tempProfile: ' + tempProfile);
            if(tempProfile != null){
                tempProfile.ACH_ABA_Code__c = tempMethod.Zuora__AchAbaCode__c;
                tempProfile.ACH_Account_Name__c = tempMethod.Zuora__AchAccountName__c;
                tempProfile.ACH_Account_Number_Mask__c = tempMethod.Zuora__AchAccountNumberMask__c;
                tempProfile.ACH_Account_Type__c = tempMethod.Zuora__AchAccountType__c;
                tempProfile.ACH_Bank_Name__c = tempMethod.Zuora__AchBankName__c;
                tempProfile.BillingAccountId__c = tempMethod.Zuora__BillingAccount__c;
                tempProfile.Payment_Method_Type__c = tempMethod.Zuora__Type__c;
                tempProfile.Credit_Card_BIN__c  = tempMethod.Zuora__BankIdentificationNumber__c;
                tempProfile.ExpirationDate__c = tempMethod.Zuora__CreditCardExpirationMonth__c + '/' + tempMethod.Zuora__CreditCardExpirationYear__c;
                tempProfile.CardholderName__c = tempMethod.Zuora__CreditCardHolderName__c;
                tempProfile.MaskNumber__c = tempMethod.Zuora__CreditCardMaskNumber__c;
                tempProfile.CreditCardType__c = tempMethod.Zuora__CreditCardType__c;
            }
           
        }

        //update info  and save
        update profileMap.values();
    }

}
/*
Zuora__AchAbaCode__c
Zuora__AchAccountName__c
Zuora__AchAccountNumberMask__c
Zuora__AchAccountType__c
Zuora__AchBankName__c
Zuora__BillingAccount__c
Zuora__Type__c
Zuora__CreditCardExpirationMonth__c
Zuora__CreditCardExpirationYear__c
Zuora__CreditCardHolderName__c
Zuora__CreditCardMaskNumber__c
Zuora__CreditCardType__c


ACH_ABA_Code__c
ACH_Account_Name__c
ACH_Account_Number_Mask__c
ACH_Account_Type__c
ACH_Bank_Name__c
BillingAccountId__c
Payment_Method_Type__c
ExpirationDate__c
CardholderName__c
MaskNumber__c
CreditCardType__c
*/