global class PopulateDeltaAmountOnAsset_Batch implements Schedulable, Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    map<string,opportunity> accountIdToOpportunity = new map<string,opportunity>();
    map<string,list<Asset>> reason_assetNotProcessed = new map<string,list<Asset>>();
    list<string> creditStatusForQuery = new list<string>{	TurboUtilityClass.creditInProgressStatus,
    														TurboUtilityClass.creditProcessedStatus,
    														TurboUtilityClass.creditNotRequiredStatus};
    /*
    	Schedulable with batch size 1
    */
    global void execute(SchedulableContext SC) {
        PopulateDeltaAmountOnAsset_Batch batchInst = new PopulateDeltaAmountOnAsset_Batch();
        ID batchprocessid = Database.executeBatch(batchInst, 5);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

       return Database.getQueryLocator([ 	Select 	Asset_ID_18_Digit__c,
													Start_Date__c,
													End_Date__c,
													Credit_Status__c,
													Renewal_Order_Product__c,
													Renewal_Order_Product__r.Line_Type__c,
													Renewal_Start_Date__c,
													Asset_Type__c,
													Order_Line_Item__c,
													Line_Type__c,
													Fulfillment_Status__c,
													Delta_Price__c,
													Delta_Price_w_o_Tax__c,
													PricePerImpressionSold__c,
													Contractedimpressions__c,
													Total_Net__c,
													Record_Processed_for_commission__c,
													Commissions_are_calculated__c,
													( Select Asset_ID_18_Digit__c
													  from Assets__r
													  where
													  	Asset_Type__c 				= :SellerLeadUtilityClass.assetTypeFulfillTo
													  limit 1 )
				        					from 	Asset
				        					where
				        						End_Date__c                <= YESTERDAY
				        						AND
				        						Product_Code__c 			= :SellerLeadUtilityClass.sellerLeadProductCode
				        						AND
				        						Credit_Status__c 			NOT IN :creditStatusForQuery
				        						AND
				        						Asset_Type__c 				= :TurboUtilityClass.assetTypeParent
				        						AND
				        						Fulfillment_Status__c		= :TurboUtilityClass.fulfilledStatus
				        						AND
				        						Contractedimpressions__c 	>= 0 //CRM-1646
				        					limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()]);

    }

    global void execute(Database.BatchableContext BC, List<sObject> assetListInScope) {

       map<string,list<Asset>> failureAssetMap = SellerLeadUtilityClass.populateDeltaAmountOnAsset_BatchMethod( (list<Asset>) assetListInScope );

       if( !failureAssetMap.isEmpty() ){
       	 reason_assetNotProcessed.putAll(failureAssetMap);
       }

    }

    global void finish(Database.BatchableContext BC) {
    	if( !reason_assetNotProcessed.isEmpty() ){
    		list<string> groupDevIds = new list<string>();
    		groupDevIds.add('Turbo_Credit_Failure_Notification_Group');
    		SellerLeadUtilityClass.sendEmailNotificationForDeltaAssetAmountFailure( SellerLeadUtilityClass.createEmailBodyForDeltaAssetAmountFailureNotification( reason_assetNotProcessed),
    																			'ALERT: Failed to populate delta amount for Renewal/Expired Assets',
    																			groupDevIds);
    	}
    }

}