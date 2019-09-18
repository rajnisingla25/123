//Name        : PaymentProfileTriggerHandler
//Description : This Handler updates Payment Method field on Payment Profile Object.
//Frequencey  : Every Insert and Update
//Author      : Pallavi Tammana
//History     : CRM-3185: populate Payment Method Id on Payment profile.


public class PaymentProfileTriggerHandler {

    public void BeforeInsertUpdate(List<PaymentProfiles__c> newpayments, Map<Id, PaymentProfiles__c> oldpaymentsMap, Boolean isInsert) {
    
        PaymentProfileTriggerHandlerManager PaymentProfileMgr = new PaymentProfileTriggerHandlerManager();
        PaymentProfileMgr.UpdatePaymentMethod(newpayments, oldpaymentsMap, isInsert);
    }
}