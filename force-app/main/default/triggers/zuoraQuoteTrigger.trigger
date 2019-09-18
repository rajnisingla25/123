trigger zuoraQuoteTrigger on zqu__Quote__c (before insert, before update) {

    //DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');

    //// Turn off trigger if the value of custom setting field is true. 
    //if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
    //  if ((Trigger.isbefore && Trigger.isInsert) || (Trigger.isbefore && Trigger.isUpdate)) {
    //      Set<string> accIdSet = new Set<string>();
    //      List<string> accIdList = new List<string>();
    //      Boolean sendToZbillingFlag = false;
        
    //      for(zqu__Quote__c q:Trigger.new){
    //          OrderItem OI = [Select Id, CampaignID__c, Contractedimpressions__c, PricePerImpressionSold__c, 
    //              DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c, quantity, Start_Date__c,Asset__c,
    //              End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, 
    //              Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, 
    //              Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, 
    //              Asset__r.Zoura_Id__c 
    //              FROM OrderItem WHERE Id = :q.Order_Product__c];

    //          if(q.zqu__SubscriptionType__c != 'Cancel Subscription' && q.cancelWithCreditFlag__c == true && (q.zqu__Status__c == 'Sent to Z-Billing' && Trigger.oldMap.get(q.Id).zqu__Status__c != 'Sent to Z-Billing')){                
    //              //NOTE (Mikey): Increasing time for creating Cancel Quote to allow RealTime Sync to sync new Subscription back to SFDC
    //              //OrderDecompController.scheduleProcessInput(30, OI,(String)q.zqu__Account__c, q.zqu__ZuoraAccountID__c, 'Cancel Subscription');
    //              OrderDecompController.scheduleProcessInput(120, OI,(String)q.zqu__Account__c, q.zqu__ZuoraAccountID__c, 'Cancel Subscription');
    //              accIdSet.add(q.zqu__ZuoraAccountID__c);
    //              sendToZbillingFlag = true;
    //          }
    //      }
        
    //      for(String accId : accIdSet){
    //          accIdList.add(accId);
    //      }
    
    //      System.Debug('accIdList: ' + accIdList);
    //      if(sendToZbillingFlag == true){
    //          //NOTE: Increasing send to zbilling job to allow for extra time creating Cancel Quote
    //          //OrderDecompController.scheduleSendToZBilling(200, accIdList);
    //          OrderDecompController.scheduleSendToZBilling(300, accIdList);
    //      }
    //  }
    //}  
}