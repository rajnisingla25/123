global class Z_scheduleSendToZBilling  {
  /*List<String> quoteIdList;
  List<String> accIdList;
  //String sfdcAccountId;
  //String zBillingAccountId;
 
  public Z_scheduleSendToZBilling(List<String> accIdList) {
    //this.quoteIdList = quoteIdList;
    this.accIdList = accIdList;
    //if(quoteIdList.size()<0){
     //   System.debug('No Quotes to sent to Z-Billing');
     //   return;
    //}
  }

  global void execute(SchedulableContext sc)
  { 

    //List<String> listofQuoteIdsToUpdate = new List<String>();
    //List<String> listofQuoteIdsToSend = new List<String>();
    //List<String> listofAccIdsToUpdate = new List<String>();
    ////String quoteId = quoteIdList[0];
    //List<zqu__Quote__c> quotes = [SELECT zqu__Account__c,zqu__ZuoraAccountID__c,zqu__SubscriptionType__c,Charge_To_Be_Updated__c,zqu__Status__c FROM zqu__Quote__c WHERE zqu__Status__c='New' AND zqu__ZuoraAccountID__c IN :accIdList];
    //for(zqu__Quote__c q : quotes){
    //  if(q.Charge_To_Be_Updated__c == true && (q.zqu__SubscriptionType__c == 'Renew Subscription' || q.zqu__SubscriptionType__c == 'Amend Subscription')){      
    //    listofQuoteIdsToUpdate.add(q.Id);
    //    listofAccIdsToUpdate.add(q.zqu__ZuoraAccountId__c);
    //  }else{
    //    listofQuoteIdsToSend.add(q.Id);
    //  }        
    //}

    //if(listofQuoteIdsToUpdate.size() > 0){
    //  System.Debug('size of listOfQuoteIdsToUpdate: ' + listOfQuoteIdsToUpdate.size());
    //  for(String qId : listOfQuoteIdsToUpdate){
    //      System.Debug('Updating Charge');
    //      OrderDecompController.updateCharge(qId);           
    //  }
    //  //OrderDecompController.scheduleSendToZBilling(30, listofAccIdsToUpdate);
    //}

    //if(listofQuoteIdsToSend.size() > 0){
    //  System.debug('Sending quotes to Z-Billing: '+listofQuoteIdsToSend);
    //  OrderDecompController.sendtoZbilling(listofQuoteIdsToSend);
    //}

  }  */
}