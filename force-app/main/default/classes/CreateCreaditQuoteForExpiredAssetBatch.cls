global class CreateCreaditQuoteForExpiredAssetBatch implements Schedulable, Database.Batchable<string>,Database.AllowsCallouts,Database.Stateful {

    map<string,opportunity> accountIdToOpportunity = new map<string,opportunity>();
    map<string,list<Asset>> reason_assetNotProcessedForCredit = new map<string,list<Asset>>();
    list<string> creditStatusForQuery = new list<string>{	TurboUtilityClass.creditInProgressStatus,
    														TurboUtilityClass.creditProcessedStatus,
    														TurboUtilityClass.creditNotRequiredStatus};
    Date dt = System.Today();
    /*
    	Schedulable with batch size 1
    */
    global void execute(SchedulableContext SC) {
        CreateCreaditQuoteForExpiredAssetBatch batchInst = new CreateCreaditQuoteForExpiredAssetBatch();
        ID batchprocessid = Database.executeBatch(batchInst, 1);
    }

    global Iterable<string> start(Database.BatchableContext BC) {

        list<string> accountIdList = new list<string>();
        set<string> uniqueAccountIds = new set<string>();

        for( Asset ast : [ 	Select 	AccountId
        					from 	Asset
        					where
        						Product_Code__c 		= :TurboUtilityClass.turboProductCode
        						AND
        						Credit_Status__c 		NOT IN :creditStatusForQuery
        						AND
        						Status 					= :TurboUtilityClass.assetStatusActive
        						AND
        						Asset_Type__c 			= :TurboUtilityClass.assetTypeParent
        						AND
        						Fulfillment_Status__c	=:TurboUtilityClass.fulfilledStatus
        						AND
        						CampaignId__c 			!= null
        						AND
        						End_date__c             =:dt
        						AND
        						Contractedimpressions__c > 0
        					limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()]){

        	if( uniqueAccountIds.add( ast.AccountId ) ){
        		accountIdList.add(  ast.AccountId  );
        	}

        }

        accountIdToOpportunity = TurboUtilityClass.createOpportunities( accountIdList, 'Expired Ast Credit');
        return accountIdList;
    }

    global void execute(Database.BatchableContext BC, List<string> accountIds) {

        string AccountIdInScope 						=  accountIds.iterator().next();
        integer totalAssetCount 					= 0;
        map<string,Asset> campaignIdToAssetMap 		= new map<string,Asset>();
        list<Asset> assetEligibleForCredit 			= new list<Asset>();
        list<Asset> assetNotEligibleForCredit 		= new list<Asset>();
        list<list<Asset>> assetChunkList			= new list<list<Asset>>();
        list<Asset> assetChunk 						= new list<Asset>();
        list<Asset> eligibleAssetList				= [ Select 	AccountId,
							        							Id,
							        							campaignId__c,
							        							Start_Date__c,
							        							End_Date__c,
							        							Credit_Status__c,
							        							Contractedimpressions__c,
							        							Name
							        					from 	Asset
							        					where
							        						Product_Code__c 			= :TurboUtilityClass.turboProductCode
							        						AND
        													Credit_Status__c 			NOT IN :creditStatusForQuery
							        						AND
							        						Status 						= :TurboUtilityClass.assetStatusActive
							        						AND
							        						Asset_Type__c 				= :TurboUtilityClass.assetTypeParent
							        						AND
							        						Fulfillment_Status__c		=:TurboUtilityClass.fulfilledStatus
							        						AND
							        						CampaignId__c 				!= null
							        						AND
							        						AccountID 					= :AccountIdInScope
							        						AND
        						                            End_date__c             =:dt
							        						AND
							        						Contractedimpressions__c 	> 0

							        					limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()];


        map<string,list<Asset>> failureAssetMap = TurboUtilityClass.createCreditQuoteForAssets_BatchMethod(  eligibleAssetList,
															      											 accountIdToOpportunity,
															      											 AccountIdInScope,
															      											 TurboUtilityClass.expiryCredit);

       if( !failureAssetMap.isEmpty() ){
       	 reason_assetNotProcessedForCredit.putAll(failureAssetMap);
       }

    }

    global void finish(Database.BatchableContext BC) {
    	if( !reason_assetNotProcessedForCredit.isEmpty() ){
    		list<string> groupDevIds = new list<string>();
    		groupDevIds.add('Turbo_Credit_Failure_Notification_Group');
    		TurboUtilityClass.sendEmailNotificationForTurboAssetCreditFailure( TurboUtilityClass.createEmailBodyForAssetCreditFaliureNotification( reason_assetNotProcessedForCredit),
    																			'ALERT: Failed to process credit for Expired Assets',
    																			groupDevIds);
    	}
    }
}