//Name        : PaymentProfileTriggerHandlerManager
//Description : This Handler updates Payment Method field on Payment Profile Object.
//Frequencey  : Every Insert and Update
//Author      : Pallavi Tammana
//History     : CRM-3185: populate Payment Method Id on Payment profile.


public class PaymentProfileTriggerHandlerManager {

    public void UpdatePaymentMethod(List<PaymentProfiles__c> newpayments, Map<Id, PaymentProfiles__c> oldpaymentsMap, Boolean isInsert) {
    
        Set<String> PaymentSet = new Set<String>();
        Map<String,Id> PMethodsMap = new Map<String,Id>();
        
        for(PaymentProfiles__c payment : newpayments){
            PaymentSet.add(payment.PaymentMethodId__c);
        }
        
        for(Zuora__PaymentMethod__c PMethod: [Select Id, Zuora__External_Id__c from Zuora__PaymentMethod__c where Zuora__External_Id__c IN: PaymentSet]) {
            PMethodsMap.put(PMethod.Zuora__External_Id__c, PMethod.Id);
        }
        
        for(PaymentProfiles__c payment : newpayments) {
            if(isInsert){
                payment.Payment_Method__c = PMethodsMap.get(payment.PaymentMethodId__c);
            }
            else if(oldpaymentsMap.get(payment.Id).PaymentMethodId__c != payment.PaymentMethodId__c || (payment.PaymentMethodId__c != null && payment.Payment_Method__c == null)){
                payment.Payment_Method__c = PMethodsMap.get(payment.PaymentMethodId__c);   
            }
        }
    }
}