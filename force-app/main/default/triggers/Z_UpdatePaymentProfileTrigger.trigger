trigger Z_UpdatePaymentProfileTrigger on Zuora__PaymentMethod__c (after update, after insert) {

    List<String> PaymentMethodIdsToUse = new List<String>();
    System.debug('Z_UpdatePaymentProfile Trigger fired');
    List<Zuora__PaymentMethod__c> newPMs = Trigger.new;

    for(Zuora__PaymentMethod__c method : newPMs){
    	PaymentMethodIdsToUse.add(method.Id);
    }
   
  
  
  if (PaymentMethodIdsToUse.size() > 0) {
    System.debug('Calling processing method');
    Z_UpdatePaymentProfile.UpdatePaymentProfile(PaymentMethodIdsToUse);

  }

}