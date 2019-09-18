global class LaunchFutureDatedAmendmentSchedulable implements Schedulable{
    private static final String CTYPE_RECURRING = 'Recurring';
    private static final String CTYPE_NEW = 'New';
    private static final Integer dateOffSet = 1;

    global void execute(SchedulableContext SC) {
        Set<String> listofQuoteIds = new Set<String>();
        Set<String> listofSubNames = new Set<String>();
        Map<String, zqu__Quote__c> subToQuoteMap = new Map<String, zqu__Quote__c>();
        Map<String, Zuora__SubscriptionProductCharge__c> subToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
        Map<Id, String> quoteToSubMap = new Map<Id, String>();
        Map<String,String> subToRatePlanMap = new Map<String,String>();
        Map<String,String> subToRatePlanChrgMap = new Map<String,String>();
        Map<String, String> subNameToZuoraId = new Map<String,String>();
        Date startDate = System.today();
        Date dateCriteria = startdate.addDays(dateOffSet);
        
        List<zqu__Quote__c> listOfQuotes = [SELECT id, zqu__Subscription_Name__c, name, zqu__Account__c, zqu__Opportunity__c, zqu__Currency__c, 
            zqu__ValidUntil__c, zqu__SubscriptionTermStartDate__c, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__InitialTerm__c, zqu__RenewalTerm__c, 
            zqu__ZuoraSubscriptionID__c, zqu__ExistSubscriptionID__c, zqu__Subscription_Term_Type__c, zqu__ZuoraAccountID__c, 
            zqu__InvoiceProcessingOption__c, zqu__RenewalSetting__c, zqu__StartDate__c FROM zqu__Quote__c WHERE Future_Dated_Amendment__c= true And 
            zqu__Status__c =:CTYPE_NEW And zqu__StartDate__c <= :dateCriteria];

        for(zqu__Quote__c quote : listofQuotes){
            if(subToQuoteMap.get(quote.zqu__Subscription_Name__c) == null)
                subToQuoteMap.put(quote.zqu__Subscription_Name__c, quote);
            if(quoteToSubMap.get(quote.Id) == null)
                quoteToSubMap.put(quote.Id, quote.zqu__Subscription_Name__c);
            listofQuoteIds.add(quote.Id);
            listofSubNames.add(quote.zqu__Subscription_Name__c);
            System.debug('QuoteId:' + quote.Id);
        }

        List<Zuora__Subscription__c> listofSubscriptions = [Select Id, Name, Zuora__Zuora_Id__c from Zuora__Subscription__c 
            where name IN :subToQuoteMap.keyset()];
        List<Zuora__SubscriptionProductCharge__c> listSubProductCharges = [Select Id, Zuora__Subscription__c, Zuora__RatePlanId__c, Zuora__Zuora_Id__c, Zuora__Subscription__r.Name
            from Zuora__SubscriptionProductCharge__c where Zuora__Type__c =:CTYPE_RECURRING  AND Zuora__Subscription__r.Name IN :subToQuoteMap.keyset()];
        List<zqu__QuoteRatePlan__c> listQuoteRatePlans = [SELECT Id, zqu__Quote__c, zqu__SubscriptionRatePlanZuoraId__c, zqu__ProductRatePlanZuoraId__c  FROM zqu__QuoteRatePlan__c 
            WHERE zqu__Quote__c IN :listofQuoteIds];
        List<zqu__QuoteRatePlanCharge__c> listQuoteRatePlanCharges = [Select Id, zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__SubscriptionRatePlanChargeZuoraId__c from zqu__QuoteRatePlanCharge__c 
            where zqu__QuoteRatePlan__r.zqu__Quote__c IN :listofQuoteIds and zqu__ChargeType__c =:CTYPE_RECURRING];
            
		try{
			
	        for (Zuora__Subscription__c sub: listofSubscriptions){
	            if (subNameToZuoraId.get(sub.Name) ==  null){
	                subNameToZuoraId.put(sub.Name, sub.Zuora__Zuora_Id__c);
	                System.debug('subzuoraid:'+ sub.Zuora__Zuora_Id__c);
	            }
	        }
	
	        for(Zuora__SubscriptionProductCharge__c spc : listSubProductCharges){
	            if(subToRatePlanMap.get(spc.Zuora__Subscription__r.Name) == null)
	                subToRatePlanMap.put(spc.Zuora__Subscription__r.Name, spc.Zuora__RatePlanId__c);
	            if(subToRatePlanChrgMap.get(spc.Zuora__Subscription__r.Name) == null)
	                subToRatePlanChrgMap.put(spc.Zuora__Subscription__r.Name, spc.Zuora__Zuora_Id__c);
	        }
	
	        for(zqu__Quote__c quote: listOfQuotes){
	            quote.zqu__ExistSubscriptionID__c = subNameToZuoraId.get(quote.zqu__Subscription_Name__c);
	        }
	
	        for(zqu__QuoteRatePlan__c quoteRatePlan : listQuoteRatePlans){
	            quoteRatePlan.zqu__SubscriptionRatePlanZuoraId__c = subToRatePlanMap.get(quoteToSubMap.get(quoteRatePlan.zqu__Quote__c));
	            //quoteRatePlan.zqu__ProductRatePlanZuoraId__c = '';
	            //quoteRatePlan.zqu__ProductRatePlan__c = '';
	        }
	
	        for(zqu__QuoteRatePlanCharge__c quoteRatePlanChrg : listQuoteRatePlanCharges){
	            quoteRatePlanChrg.zqu__SubscriptionRatePlanChargeZuoraId__c = subToRatePlanChrgMap.get(quoteToSubMap.get(quoteRatePlanChrg.zqu__QuoteRatePlan__r.zqu__Quote__c));
	            //quoteRatePlanChrg.zqu__ProductRatePlanChargeZuoraId__c = '';
	            //quoteRatePlanChrg.zqu__ProductRatePlanCharge__c = '';
	        }

            if(!listOfQuotes.isEmpty())
                Update listOfQuotes;
            if(!listQuoteRatePlans.isEmpty())
                Update listQuoteRatePlans;
            if(!listQuoteRatePlanCharges.isEmpty())
                Update listQuoteRatePlanCharges;
            
            if(!listofQuoteIds.isEmpty() && !Test.isRunningTest())
            	Z_SendToZBillingInstantiator.futureSend(listofQuoteIds);
           
        }catch(Exception e){
            System.debug('Exception occured while updating Quote objects:' + e.getMessage());
        }

        //Z_SendToZBillingInstantiator.synchronousSend(listofQuoteIds);
        //todo make this a custom setting
    }
}