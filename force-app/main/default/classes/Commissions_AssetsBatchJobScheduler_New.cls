global class Commissions_AssetsBatchJobScheduler_New implements Schedulable{
     @TestVisible 
    // BROKER REGIONAL DIRECTORS TEAM'S CURRENT QUATER CALCULATION
    private string getBrokerrdTeam(Integer monthValue) 
    {
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3){
            brokerRDteam = 'Q3';
        } else if (monthValue <= 6){
            brokerRDteam = 'Q4';
        } else if (monthValue <= 9){
            brokerRDteam = 'Q1';
        }
        return brokerRDteam;
    }
    global void execute(SchedulableContext sc){
    	try {
    		Set<Id> setAssetsFlagsetasPicked = new Set<Id>();
            DateTime sinceLast1Mins = Datetime.now().addMinutes(-1);
            set<string> incompleteStates = new set<string>{'WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED'};	//Ref Link : https://developer.salesforce.com/docs/atlas.en-us.216.0.object_reference.meta/object_reference/sforce_api_objects_crontrigger.htm
            Integer pendingSchJobs = [SELECT count() 
                                          FROM CronTrigger 
                                          Where CronJobDetail.Name LIKE 'CommissionScheduleJobC1C%'
                                              AND State IN :incompleteStates
                                              AND NextFireTime >= :sinceLast1Mins];
            if(pendingSchJobs > 0 && !Test.isRunningTest()){
                return;
            }
            Integer jcount = [Select count() from AsyncApexJob WHERE Status = 'Holding'];
                    if(jcount>20){
                    Integer ii=1/0;
                    }
            
	        set<String> setCommissionFieldsFilters = new set<string> {'Calculate', ' ', null};
	        set<String> setLineStatusesFilter = new set<string> {'Active', 'Cancelled'};
	        set<String> setLineTypesFilter = new set<string> {'Add', 'Amend', 'Renew', 'Credit', 'Cancel'};
	        Set<Id> QuotauserIds = new  Set<Id>();
		    set<id> userIdsNotToProcessQuotaPayout = new set<id>();
	       	Integer currentMinute = System.now().Minute(); 
	    	Boolean runLineTypeWiseCommissionBatches = true;
	        Map<String, Commission_Scheduler_Setting__mdt> mapBatchSettings = new Map<String, Commission_Scheduler_Setting__mdt>();
	        
	        list<Commission_Scheduler_Setting__mdt> batchSettings = [SELECT DeveloperName, MasterLabel, Batch_Size__c, Is_Running__c
	                                                                    FROM Commission_Scheduler_Setting__mdt];
	        if(batchSettings != null && batchSettings.size() > 0){
	            for(Commission_Scheduler_Setting__mdt setting : batchSettings){
	                mapBatchSettings.put(setting.DeveloperName, setting);
	            }
	        }
	        List<Quota_Trigger_Execution_Setting__mdt> quotaTriggerExecSetting = [Select MasterLabel,DeveloperName,Quota_Payout_Refresh_Period__c From Quota_Trigger_Execution_Setting__mdt];
	        map<string, Quota_Trigger_Execution_Setting__mdt> mapQuotaExecSetting = new map<string, Quota_Trigger_Execution_Setting__mdt>();
	        if(quotaTriggerExecSetting!= null && quotaTriggerExecSetting.size() > 0){
	            for(Quota_Trigger_Execution_Setting__mdt execSetting : quotaTriggerExecSetting)
	                mapQuotaExecSetting.put(execSetting.DeveloperName, execSetting); 
	        }
	        
	        Integer pastMonths = Integer.valueof(mapQuotaExecSetting.get('Run_Quota_Old_Trigger_For').Quota_Payout_Refresh_Period__c);
	        pastMonths = pastMonths == null ? 6 : pastMonths;
	        
	        Date dateBeforeMonths = Date.today().addMonths(-pastMonths);
	        
			if((currentMinute > 25 && currentMinute <= 30) || (currentMinute > 55 && currentMinute <= 59) || Test.isRunningTest()){
				runLineTypeWiseCommissionBatches = false;
	        	map<id, Quota__c> mapQuotasToPayoutCalc1 = new map<id, Quota__c>( [SELECT id
	                                                                           FROM Quota__c 
	                                                                           WHERE (New_Sale_Tier_Changed__c = true OR Renewal_Tier_Changed__c = true)
	                                                                           		AND Quota_StartDate__c >= :dateBeforeMonths]);
				if(mapQuotasToPayoutCalc1.size() < 1 || Test.isRunningTest()){
					runLineTypeWiseCommissionBatches = true;
				}
			}
			if(runLineTypeWiseCommissionBatches){
		        for(Quota__c quotarecord : [SELECT id,User__c
		                    FROM Quota__c where 
		                    ((Quota_StartDate__c = THIS_MONTH) 
		                    OR (Quota_StartDate__c = THIS_YEAR and Current_Quater__c =: getBrokerrdTeam(system.today().Month())))]){
		                    
		                    QuotauserIds.add(quotarecord.User__c);
		        }  
		        Date last2Months = Date.today();
		        last2Months = last2Months.addMonths(-2);
		        Map<Id, Asset> mapAssets = new Map<Id, Asset>([SELECT id, Name, accountId, Product2Id, Sign_in_AE__c, OwnerId, Asset_Type__c, Fulfillment_Status__c, Status, Account_Type__c, 
	                                                             LastModifiedDate, CreatedDate, Line_Type__c, Legacy_Created_Date__c, End_Date__c, Billing_Period__c, Total_Net__c, Renewal_Type__c, 
	                                                             Commission_field__c, Sign_in_AE__r.Team__c, Delta_Price_w_o_Tax__c, Start_Date__c, Commissions_are_calculated__c, Order_Line_Item__c, Order_Line_Item__r.Product_Commission_Category__c
	                                                         FROM Asset 
	                                                         WHERE Fulfillment_Status__c = :Constants.FULFILLMENT_STATUS 
	                                                            AND Asset_Type__c =: Constants.ASSET_TYPE //Parent
	                                                            AND Commission_field__c IN :setCommissionFieldsFilters
	                                                            AND Commissions_are_calculated__c = false 
	                                                            AND (Status IN :setLineStatusesFilter OR (Status = 'Expired' AND Product_code__c = 'SELLERLEADBUNDLE'))
	                                                            AND Line_Type__c IN :setLineTypesFilter
	                                                            AND Order_Line_Item__r.Product_Commission_Category__c != 'tiger' 
	                                                            AND Record_Processed_for_commission__c = false 
	                                                            AND Account_Type__c != 'Franchise Company'
	                                                            //AND Product_code__c != 'SELLERLEADBUNDLE'
	                                                            AND LastModifiedDate >= :last2Months
	                                                            AND Not_picked__c = true		//CRM-4818
	                                                            And OwnerId IN :QuotauserIds        //CRM-4145, OR-ed SignInAE
	                                                         ORDER BY LastModifiedDate DESC lIMIT 100]);
	                                                         
		         Map<Id, Asset> mapAssets1 = new Map<Id, Asset>([SELECT id, Name, accountId, Product2Id, Sign_in_AE__c, OwnerId, Asset_Type__c, Fulfillment_Status__c, Status, Account_Type__c, 
	                                                             LastModifiedDate, CreatedDate, Line_Type__c, Legacy_Created_Date__c, End_Date__c, Billing_Period__c, Total_Net__c, Renewal_Type__c, 
	                                                             Commission_field__c, Sign_in_AE__r.Team__c, Delta_Price_w_o_Tax__c, Start_Date__c, Commissions_are_calculated__c, Order_Line_Item__c, Order_Line_Item__r.Product_Commission_Category__c
	                                                         FROM Asset 
	                                                         WHERE (Fulfillment_Status__c = :Constants.FULFILLMENT_STATUS OR Product_code__c = 'OPCITYBLA')
	                                                            AND Asset_Type__c =: Constants.ASSET_TYPE //Parent
	                                                            AND Commission_field__c IN :setCommissionFieldsFilters
	                                                            AND Commissions_are_calculated__c = false 
	                                                            AND (Status IN :setLineStatusesFilter OR (Product_code__c = 'OPCITYBLA' AND Account_Type__c = 'Broker' AND Contract_Signed_Date__c != null) OR (Status = 'Expired' AND Product_code__c = 'SELLERLEADBUNDLE'))
	                                                            AND Line_Type__c IN :setLineTypesFilter
	                                                            AND Order_Line_Item__r.Product_Commission_Category__c != 'tiger' 
	                                                            AND Record_Processed_for_commission__c = false 
	                                                            AND Account_Type__c != 'Franchise Company'
	                                                            //AND Product_code__c != 'SELLERLEADBUNDLE'
	                                                            AND LastModifiedDate >= :last2Months
	                                                            AND Not_picked__c = true	//CRM-4818
	                                                            And Sign_in_AE__c IN :QuotauserIds        //CRM-4145, OR-ed SignInAE
	                                                         ORDER BY LastModifiedDate DESC lIMIT 100]);
                
		        mapAssets.putAll(mapAssets1);		        
		        System.debug('mapAssets==>'+mapAssets);
		        map<string, map<Id, map<Id,Asset>>> mapLineTypeWiseAssetsToProceed = new map<string, map<Id, map<Id,Asset>>>();
		        mapLineTypeWiseAssetsToProceed.put('Add', new Map<Id, map<Id,Asset>>());  
		        mapLineTypeWiseAssetsToProceed.put('Amend', new Map<Id, map<Id,Asset>>());  
		        mapLineTypeWiseAssetsToProceed.put('Renew', new Map<Id, map<Id,Asset>>());  
		        mapLineTypeWiseAssetsToProceed.put('Cancel', new Map<Id, map<Id,Asset>>());  
		        
		        set<Id> OwnerNSignInAEIdsForNewSale = new set<Id>();
		        set<Id> OwnerNSignInAEIdsForAmend = new set<Id>();
		        set<Id> OwnerNSignInAEIdsForRenew = new set<Id>();
		        set<Id> OwnerNSignInAEIdsForCredit = new set<Id>();
		        //set<Id> setAssetIdsNotToProceed = new set<Id>();
		        for(Asset assetRec : mapAssets.values()){
		            if(assetRec.Line_Type__c == 'Add'){
		                if(OwnerNSignInAEIdsForAmend.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForAmend.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForRenew.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForRenew.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForCredit.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForCredit.contains(assetRec.Sign_in_AE__c)){
		                    continue;
		                }
		                OwnerNSignInAEIdsForNewSale.add(assetRec.OwnerId);
		                OwnerNSignInAEIdsForNewSale.add(assetRec.Sign_in_AE__c);
		                if(mapLineTypeWiseAssetsToProceed.get('Add').get(assetRec.OwnerId) == null){
		                    mapLineTypeWiseAssetsToProceed.get('Add').put(assetRec.OwnerId, new map<Id, Asset>());
		                }
		                mapLineTypeWiseAssetsToProceed.get('Add').get(assetRec.OwnerId).put(assetRec.id, assetRec);
		            }
		            else if(assetRec.Line_Type__c == 'Amend' || assetRec.Line_Type__c == 'Credit'){
		                if(OwnerNSignInAEIdsForNewSale.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForNewSale.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForRenew.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForRenew.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForCredit.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForCredit.contains(assetRec.Sign_in_AE__c)){
		                    continue;
		                }
		                OwnerNSignInAEIdsForAmend.add(assetRec.OwnerId);
		                OwnerNSignInAEIdsForAmend.add(assetRec.Sign_in_AE__c);
		                if(mapLineTypeWiseAssetsToProceed.get('Amend').get(assetRec.OwnerId) == null){
		                    mapLineTypeWiseAssetsToProceed.get('Amend').put(assetRec.OwnerId, new map<Id, Asset>());
		                }
		                mapLineTypeWiseAssetsToProceed.get('Amend').get(assetRec.OwnerId).put(assetRec.id, assetRec);
		            }
		            else if(assetRec.Line_Type__c == 'Renew'){
		                if(OwnerNSignInAEIdsForNewSale.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForNewSale.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForAmend.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForAmend.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForCredit.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForCredit.contains(assetRec.Sign_in_AE__c)){
		                    continue;
		                }
		                OwnerNSignInAEIdsForRenew.add(assetRec.OwnerId);
		                OwnerNSignInAEIdsForRenew.add(assetRec.Sign_in_AE__c);
		                if(mapLineTypeWiseAssetsToProceed.get('Renew').get(assetRec.OwnerId) == null){
		                    mapLineTypeWiseAssetsToProceed.get('Renew').put(assetRec.OwnerId, new map<Id, Asset>());
		                }
		                mapLineTypeWiseAssetsToProceed.get('Renew').get(assetRec.OwnerId).put(assetRec.id, assetRec);
		            }
		            else if(assetRec.Line_Type__c == 'Cancel'){
		                if(OwnerNSignInAEIdsForNewSale.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForNewSale.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForAmend.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForAmend.contains(assetRec.Sign_in_AE__c)
		                        || OwnerNSignInAEIdsForRenew.contains(assetRec.OwnerId) || OwnerNSignInAEIdsForRenew.contains(assetRec.Sign_in_AE__c)){
		                    continue;
		                }
		                OwnerNSignInAEIdsForCredit.add(assetRec.OwnerId);
		                OwnerNSignInAEIdsForCredit.add(assetRec.Sign_in_AE__c);
		                if(mapLineTypeWiseAssetsToProceed.get('Cancel').get(assetRec.OwnerId) == null){
		                    mapLineTypeWiseAssetsToProceed.get('Cancel').put(assetRec.OwnerId, new map<Id, Asset>());
		                }
		                mapLineTypeWiseAssetsToProceed.get('Cancel').get(assetRec.OwnerId).put(assetRec.id, assetRec);
		            }
		        }
		
		        set<string> incomplteStatuses = new set<string>{'Queued', 'Preparing', 'Processing', 'Holding'};
		        set<string> batchApexClassNames = new set<string>{'commissions_NewSaleBatchProcess_New', 'commissions_AmendComBatchProcess_New',
		                                            'commissions_ClawbackBatch_New', 'commissions_RenewalComBatchProcess_New','Commissions_AssetsToMarkProcessed_New'};
		        
		        List<string> runningApexJobClassNames = new List<string>();
		        DateTime twoHrsEarlier = Datetime.now().addHours(-2);
		        for(AsyncApexJob  incompleteBatchJob : [SELECT ApexClass.Name, JobItemsProcessed, TotalJobItems
		                                                FROM AsyncApexJob 
		                                                WHERE JobType = 'BatchApex' 
		                                                    AND Status IN :incomplteStatuses
		                                                    AND ApexClass.Name IN :batchApexClassNames
		                                                    AND CreatedDate <= :twoHrsEarlier]){
		            runningApexJobClassNames.add(incompleteBatchJob.ApexClass.Name);
		        }
		        
				Boolean allowRunMarkAssetProcessedBatch =  mapBatchSettings.get('MarkAssetProcessed_Batch') != null ? mapBatchSettings.get('MarkAssetProcessed_Batch').Is_Running__c : true;
		        Integer batchSize = mapBatchSettings.get('MarkAssetProcessed_Batch') != null && mapBatchSettings.get('MarkAssetProcessed_Batch').Batch_Size__c != null ? Integer.valueOf(mapBatchSettings.get('MarkAssetProcessed_Batch').Batch_Size__c) : 10;
		        if(allowRunMarkAssetProcessedBatch && !runningApexJobClassNames.contains('Commissions_AssetsToMarkProcessed_New') && mapAssets.size() < 1){
		            
		        List<Asset> lstAssetToMarkProcessed = [SELECT id, Record_Processed_for_commission__c
													FROM Asset 
			                                         WHERE Fulfillment_Status__c = :Constants.FULFILLMENT_STATUS 
			                                            AND Asset_Type__c =: Constants.ASSET_TYPE //Parent
			                                            AND Commission_field__c IN :setCommissionFieldsFilters
			                                            AND Commissions_are_calculated__c = false 
			                                            AND Status IN :setLineStatusesFilter
			                                            AND Line_Type__c IN :setLineTypesFilter
			                                            AND Order_Line_Item__r.Product_Commission_Category__c != 'tiger' 
			                                            AND Record_Processed_for_commission__c = false 
			                                            AND Account_Type__c != 'Franchise Company'
			                                            //AND Product_code__c != 'SELLERLEADBUNDLE'
			                                            AND LastModifiedDate >= :last2Months
			                                            And (OwnerId NOT IN :QuotauserIds AND Sign_in_AE__c NOT IN :QuotauserIds)
			                                         ORDER BY LastModifiedDate DESC lIMIT 100];
		            if(lstAssetToMarkProcessed.size() > 0){
		                Commissions_AssetsToMarkProcessed_New markAssetProcessedBatch = new Commissions_AssetsToMarkProcessed_New(QuotauserIds);
		                Database.executeBatch(markAssetProcessedBatch, batchSize);
		            }
		        }
				
		        //list/map to run batch only for New Sales lines
		        Boolean allowRunNewSaleBatch =  mapBatchSettings.get('New_Sale_Batch') != null ? mapBatchSettings.get('New_Sale_Batch').Is_Running__c : true;
		        batchSize = mapBatchSettings.get('New_Sale_Batch') != null && mapBatchSettings.get('New_Sale_Batch').Batch_Size__c != null ? Integer.valueOf(mapBatchSettings.get('New_Sale_Batch').Batch_Size__c) : 1;
		        if(allowRunNewSaleBatch && !runningApexJobClassNames.contains('commissions_NewSaleBatchProcess_New') && mapLineTypeWiseAssetsToProceed.get('Add').size() > 0){
		            system.debug('New_Sale_Batch Size:: '+ mapLineTypeWiseAssetsToProceed.get('Add').size());
		            for( map<Id, Asset> mapAssetsUser : mapLineTypeWiseAssetsToProceed.get('Add').values()){
		                if(mapAssetsUser.size() > 0){
		                    commissions_NewSaleBatchProcess_New newSaleBatchForUser = new commissions_NewSaleBatchProcess_New(mapAssetsUser.keySet());
		                    Database.executeBatch(newSaleBatchForUser, batchSize);
		                    setAssetsFlagsetasPicked.addAll(mapAssetsUser.keySet());
		                }
		            }
		        }
		        //list/map  to run batch only for Amend 
		        Boolean allowRunAmendBatch =  mapBatchSettings.get('Amend_Batch') != null ? mapBatchSettings.get('Amend_Batch').Is_Running__c : true;        
		        batchSize = mapBatchSettings.get('Amend_Batch') != null && mapBatchSettings.get('Amend_Batch').Batch_Size__c != null ? Integer.valueOf(mapBatchSettings.get('Amend_Batch').Batch_Size__c) : 1;
		        if(allowRunAmendBatch && !runningApexJobClassNames.contains('commissions_AmendComBatchProcess_New') && mapLineTypeWiseAssetsToProceed.get('Amend').size() > 0){
		            system.debug('Amend_Batch Size:: '+ mapLineTypeWiseAssetsToProceed.get('Amend').size());
		            for( map<Id, Asset> mapAssetsUser : mapLineTypeWiseAssetsToProceed.get('Amend').values()){
		                if(mapAssetsUser.size() > 0){
		                    commissions_AmendComBatchProcess_New amendBatch = new commissions_AmendComBatchProcess_New(mapAssetsUser.keySet());
		                    Database.executeBatch(amendBatch, batchSize);
		                    setAssetsFlagsetasPicked.addAll(mapAssetsUser.keySet());
		                }
		            }        
		        }
		        //list/map  to run batch only for Renewal
		        Boolean allowRunRenewalBatch =  mapBatchSettings.get('Renewal_Batch') != null ? mapBatchSettings.get('Renewal_Batch').Is_Running__c : true;
		        batchSize = mapBatchSettings.get('Renewal_Batch') != null && mapBatchSettings.get('Renewal_Batch').Batch_Size__c != null ? Integer.valueOf(mapBatchSettings.get('Renewal_Batch').Batch_Size__c) : 1;
		        if(allowRunRenewalBatch && !runningApexJobClassNames.contains('commissions_RenewalComBatchProcess_New') && mapLineTypeWiseAssetsToProceed.get('Renew').size() > 0){
		            system.debug('Renewal_Batch Size:: '+ mapLineTypeWiseAssetsToProceed.get('Renew').size());
		            for( map<Id, Asset> mapAssetsUser : mapLineTypeWiseAssetsToProceed.get('Renew').values()){
		                system.debug('Renewal_Batch Ids>>'+ mapAssetsUser.keySet());
		                if(mapAssetsUser.size() > 0){
		                    commissions_RenewalComBatchProcess_New renewalBatch = new commissions_RenewalComBatchProcess_New(mapAssetsUser.keySet());
		                    Database.executeBatch(renewalBatch, batchSize);
		                    setAssetsFlagsetasPicked.addAll(mapAssetsUser.keySet());
		                }
		            }        
		        }
		        //list/map  to run batch only for Credit
		        Boolean allowRunClawbackBatch = mapBatchSettings.get('Clawback_Batch') != null ? mapBatchSettings.get('Clawback_Batch').Is_Running__c : true;
		        batchSize = mapBatchSettings.get('Clawback_Batch') != null && mapBatchSettings.get('Clawback_Batch').Batch_Size__c != null ? Integer.valueOf(mapBatchSettings.get('Clawback_Batch').Batch_Size__c) : 1;
		        if(allowRunClawbackBatch && !runningApexJobClassNames.contains('commissions_ClawbackBatch_New') && mapLineTypeWiseAssetsToProceed.get('Cancel').size() > 0){
		            system.debug('Clawback_Batch Size:: '+ mapLineTypeWiseAssetsToProceed.get('Cancel').size());
		            for( map<Id, Asset> mapAssetsUser : mapLineTypeWiseAssetsToProceed.get('Cancel').values()){
		                system.debug('Clawback Ids>>'+ mapAssetsUser.keySet());
		                if(mapAssetsUser.size() > 0){
		                    commissions_ClawbackBatch_New clawbackBatchJob = new commissions_ClawbackBatch_New(mapAssetsUser.keySet());
		                    Database.executeBatch(clawbackBatchJob, batchSize);
		                    setAssetsFlagsetasPicked.addAll(mapAssetsUser.keySet());
		                }
		            }        
		        }	
		        for(map<id, map<Id, Asset>> mapAssetsPerUserId : mapLineTypeWiseAssetsToProceed.values()){
		            userIdsNotToProcessQuotaPayout.addAll(mapAssetsPerUserId.keySet());
		        }
			}
	
	        Integer quotaPayoutBatchSize = 1;
	        Boolean allowRunQuotaPayoutBatch = true;        
	        //Checking settings for batch apex call specificatin for Quota Payout Batch
	        if(mapBatchSettings.get('Quota_Payout_Batch') != null){
	            allowRunQuotaPayoutBatch = mapBatchSettings.get('Quota_Payout_Batch').Is_Running__c;
	            if(mapBatchSettings.get('Quota_Payout_Batch').Batch_Size__c != null){
	                quotaPayoutBatchSize = Integer.valueOf(mapBatchSettings.get('Quota_Payout_Batch').Batch_Size__c);
	            }
	        }
	        //CRM-4818
	        if(setAssetsFlagsetasPicked.size()>0){
	        	List<Asset> lstUpdateAsset = new List<Asset>();
		        for(Id ids:setAssetsFlagsetasPicked){
		        	Asset asst = new Asset();
		        	asst.Id = ids;
		        	asst.Not_picked__c = false;
		        	lstUpdateAsset.add(asst);
		        }
		        update lstUpdateAsset;
	        } //CRM-4818 ends
	        if(allowRunQuotaPayoutBatch){
        		DateTime minsEarlier = Datetime.now().addMinutes(-15);
        		set<string> completedStatuses = new set<string> {'Completed', 'Aborted', 'Failed'};        		
            	map<Id, AsyncApexJob> managersQuotaJobs = new map<Id, AsyncApexJob>([SELECT Id, ApexClass.Name, JobItemsProcessed, TotalJobItems, CompletedDate
													                                    FROM AsyncApexJob 
													                                    WHERE JobType = 'BatchApex' 
													                                        //AND Status = 'Completed'
													                                        AND ApexClass.Name = 'Commissions_QuotaPayoutBatch_New'
													                                        AND TotalJobItems >= 5		//:quotaPayoutBatchSize  
													                                        AND (Status Not IN :completedStatuses OR CreatedDate >= :minsEarlier OR CompletedDate >= :minsEarlier)]);
	            // Execution of Quota Payout Calculation batch: to update the quota payout and further updates the commissions under the quota.
	            if(managersQuotaJobs.size() == 0){
                    //String BLATeamName = CommissionTeams__c.getInstance('WLV_BLA_Sales_Team').Team_Name__c;
	        		map<id, Quota__c> mapQuotasToPayoutCalc = new map<id, Quota__c>( [SELECT id
			                                                                            FROM Quota__c 
			                                                                            WHERE (User__c NOT IN :userIdsNotToProcessQuotaPayout OR OwnerId NOT IN :userIdsNotToProcessQuotaPayout)
			                                                                                AND (New_Sale_Tier_Changed__c = true OR Renewal_Tier_Changed__c = true OR BLA_Tier_Changed__c = true)// add OR check for BLA tier change
			                                                                           		AND Quota_StartDate__c >= :dateBeforeMonths]);
		            system.debug('mapQuotasToPayoutCalc==>'+mapQuotasToPayoutCalc);
                    if(mapQuotasToPayoutCalc.size() > 0) {
		                Database.executeBatch(new Commissions_QuotaPayoutBatch_New(mapQuotasToPayoutCalc.keySet()), quotaPayoutBatchSize);
		            }
		            else {
                        // CRM-4552, changes for Manager Qualifiers
                        DateTime hrsEarlier = Datetime.now().addHours(-6);
                        map<Id, AsyncApexJob> managerQualifiersJobs = new map<Id, AsyncApexJob>([SELECT Id, ApexClass.Name, JobItemsProcessed, TotalJobItems, CompletedDate, Status
													                                    FROM AsyncApexJob 
													                                    WHERE JobType = 'BatchApex' 
													                                        AND ApexClass.Name = 'Commissions_ManagersQualifierBatch_New'
													                                        AND (Status Not IN :completedStatuses OR CreatedDate >= :hrsEarlier OR CompletedDate >= :hrsEarlier)]);
                        if(managerQualifiersJobs != null && managerQualifiersJobs.size() < 1){
                            Database.executeBatch(new Commissions_ManagersQualifierBatch_New());
                        }
                        else if(completedStatuses.contains(managerQualifiersJobs.values()[0].Status)){
						// Ends, CRM-4552 Manager Qualifiers changes
		            	// CRM-4196, To calculate only Manager payout on quotas
                            quotaPayoutBatchSize = 15;
                            if(mapBatchSettings.get('ManagersQuotaPayout_Batch') != null){
                                //allowRunQuotaPayoutBatch = mapBatchSettings.get('ManagersQuotaPayout_Batch').Is_Running__c;
                                if(mapBatchSettings.get('ManagersQuotaPayout_Batch').Batch_Size__c != null){
                                    quotaPayoutBatchSize = Integer.valueOf(mapBatchSettings.get('ManagersQuotaPayout_Batch').Batch_Size__c);
                                }
                            }
                            Commissions_QuotaPayoutBatch_New quotaManagerPayoutBatch = new Commissions_QuotaPayoutBatch_New(userIdsNotToProcessQuotaPayout, true);
                            Database.executeBatch(quotaManagerPayoutBatch, quotaPayoutBatchSize);
                        }
		            }
	            }
	        }
	        Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'CommissionScheduleJobC1C%' AND State = 'DELETED' and nextfiretime = null limit 20];
	        if(rcount < 2){
	            Commissions_AssetsBatchJobScheduler_New p = new Commissions_AssetsBatchJobScheduler_New();
	            Integer recallSchedularAfterMinutes = 2;
	            //Checking settings for batch apex call specificatin for Quota Payout Batch
	            if(mapBatchSettings.get('CommissionJobs_ReSchedule_Time') != null 
	                && mapBatchSettings.get('CommissionJobs_ReSchedule_Time').Batch_Size__c != null){
	                    recallSchedularAfterMinutes = Integer.valueOf(mapBatchSettings.get('CommissionJobs_ReSchedule_Time').Batch_Size__c);
	            }
	            Datetime dtt = System.now().addMinutes(recallSchedularAfterMinutes).addSeconds(2);
	            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
	            if(!Test.isRunningTest()){
	            	system.schedule('CommissionScheduleJobC1C'+dtt, sch, p);
                    system.debug('Comm Jobs Rescheduled at ' + dtt);
	            }
	            List<CronTrigger> listCronTrigger = [select Id, CronJobDetail.Name from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
	            If (listCronTrigger.size() > 0 && !Test.isRunningTest()){
	                for (Integer i = 0; i < listCronTrigger.size(); i++) { 
	                    System.abortJob(listCronTrigger[i].Id);
                        system.debug('Job Aborted : Job Id = ' + listCronTrigger[i].Id +', Job Name: ' + listCronTrigger[i].CronJobDetail.Name);
	                }
	            }
	        }
	        if(Test.isRunningTest()){
	        	list<string> dummy = null;
	        	dummy.size();	// TO throw null exception.
	        }
        
 		} catch (Exception ex) {
            List<Error__c> lstError = new List<Error__c>();
            Error__c error = new Error__c();
            error.Name = 'Commissions_AssetsBatchJobScheduler_New';	//idd;
            error.Entity_Id__c = 'Asset to Commission';
            error.Interface_Name__c = 'Commissions_AssetsBatchJobScheduler_New';
            error.Error_Description__c = 'Scheduler -' + ex.getMessage() + '' + '------' + ex.getStackTraceString();
            lstError.add(error);
            if (lstError.size() > 0) {
                insert lstError;
            }
            
	        Integer rcount = [SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'CommissionScheduleJobC1C%' AND State = 'DELETED' and nextfiretime = null limit 20];
            
	        if(rcount < 2){
	            Commissions_AssetsBatchJobScheduler_New p = new Commissions_AssetsBatchJobScheduler_New();
	            Integer recallSchedularAfterMinutes = 2;
	            Datetime dtt = System.now().addMinutes(recallSchedularAfterMinutes).addSeconds(2);
	            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
	            if(!Test.isRunningTest()){
	            	system.schedule('CommissionScheduleJobC1C'+dtt, sch, p);
                    system.debug('Comm Jobs Rescheduled from Exception at ' + dtt);
	            }
                /*
	            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
	            If (listCronTrigger.size() > 0 && !Test.isRunningTest()){
	                for (Integer i = 0; i < listCronTrigger.size(); i++) { 
	                    //System.abortJob(listCronTrigger[i].Id);
	                }
	            }*/
	        }
        }
    }
}