global class CreateCreditQuoteForRenewalAssetBatch implements Schedulable, Database.Batchable<string>,Database.AllowsCallouts,Database.Stateful {
    
    global map<string,opportunity> accountIdToOpportunity               = new map<string,opportunity>();
    global map<string,list<Asset>> reason_assetNotProcessedForCredit    = new map<string,list<Asset>>(); 
    list<string> creditStatusForQuery = new list<string>{	TurboUtilityClass.creditInProgressStatus,
    														TurboUtilityClass.creditProcessedStatus,
    														TurboUtilityClass.creditNotRequiredStatus};
    /* 
        Schedulable with batch size 1
    */
    global void execute(SchedulableContext SC) {
        CreateCreditQuoteForRenewalAssetBatch batchInst = new CreateCreditQuoteForRenewalAssetBatch();
        ID batchprocessid = Database.executeBatch(batchInst, 1);
    }
    
    global Iterable<string> start(Database.BatchableContext BC) {
     
        list<string> accountIdList = new list<string>(); 
        set<string> uniqueAccountIds = new set<string>();
     
        for( Asset ast : [  Select  AccountId
                            from    Asset
                            where   
                                Product_Code__c             = :TurboUtilityClass.turboProductCode
                                AND
                                Credit_Status__c 		NOT IN :creditStatusForQuery
                                AND
                                Status                      NOT In ('Cancelled','Expired')
                                AND
                                Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                AND
                                Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus 
                                AND
                                CampaignId__c               != null
                                AND
                                Contractedimpressions__c    > 0
                                AND
                                Renewal_Order_Product__c    != null
                                AND
                                Renewal_Order_Product__r.Line_Type__c = 'Renew'
                                AND
                                Renewal_Start_Date__c       != null
                                AND
                                End_Date__c                 <= YESTERDAY
                            limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()]){
        
            if( uniqueAccountIds.add( ast.AccountId ) ){
                accountIdList.add(  ast.AccountId  );
            }
            
        }
        accountIdToOpportunity = TurboUtilityClass.createOpportunities( accountIdList, 'Renewal Asset Opp');
        return accountIdList;
    }
    
    global void execute(Database.BatchableContext BC, List<string> accountIds) {
        string AccountIdInScope                 =  accountIds.iterator().next();
        list<Asset> eligibleAssetList           = [ Select  Id,
                                                            AccountId,
                                                            campaignId__c,
                                                            Start_Date__c,
                                                            End_Date__c,
                                                            Credit_Status__c,
                                                            Contractedimpressions__c,
                                                            Name
                                                    from    
                                                        Asset
                                                    where   
                                                        Product_Code__c             = :TurboUtilityClass.turboProductCode
                                                        AND
                                                        Credit_Status__c 			NOT IN :creditStatusForQuery
                                                        AND
                                                        Status                      NOT In ('Cancelled','Expired')
                                                        AND
                                                        Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                                        AND
                                                        Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus 
                                                        AND
                                                        CampaignId__c               != null
                                                        AND
                                                        Contractedimpressions__c    > 0
                                                        AND
                                                        Renewal_Order_Product__c    != null
                                                        AND
                                                        Renewal_Order_Product__r.Line_Type__c = 'Renew'
                                                        AND
                                                        Renewal_Start_Date__c       != null
                                                        AND
                                                        End_Date__c                 <= YESTERDAY
                                                        AND
							        					AccountID 					= :AccountIdInScope
                                                    limit: 
                                                        Limits.GetLimitQueryRows() - Limits.GetQueryRows()];
                                                                                                        
        map<string,list<Asset>> failureAssetMap = TurboUtilityClass.createCreditQuoteForAssets_BatchMethod(  eligibleAssetList,
                                                                                                             accountIdToOpportunity,
                                                                                                             AccountIdInScope,
                                                                                                             TurboUtilityClass.renewCredit);
                                                
       if( !failureAssetMap.isEmpty() ){
         reason_assetNotProcessedForCredit.putAll(failureAssetMap);
       }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if( !reason_assetNotProcessedForCredit.isEmpty() ){
            list<string> groupDevIds = new list<string>();
            groupDevIds.add('Turbo_Credit_Failure_Notification_Group');
            TurboUtilityClass.sendEmailNotificationForTurboAssetCreditFailure( TurboUtilityClass.createEmailBodyForAssetCreditFaliureNotification( reason_assetNotProcessedForCredit),
                                                                                'ALERT: Failed to process credit for Assets to be Renewed',
                                                                                groupDevIds);
        }
    }
}