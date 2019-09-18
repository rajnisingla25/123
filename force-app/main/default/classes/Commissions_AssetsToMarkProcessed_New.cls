global class Commissions_AssetsToMarkProcessed_New implements Database.Batchable<sObject> {
	
	private set<Id> usersToSkip = new set<Id>();
	
	global Commissions_AssetsToMarkProcessed_New(set<Id> usersToSkipParam){
		if(usersToSkipParam != null){
			this.usersToSkip = usersToSkipParam;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {		
        set<String> setCommissionFieldsFilters = new set<string> {'Calculate', ' ', null};
        set<String> setLineStatusesFilter = new set<string> {'Active', 'Cancelled'};
        set<String> setLineTypesFilter = new set<string> {'Add', 'Amend', 'Renew', 'Credit', 'Cancel'};
        Date last2Months = Date.today();
        last2Months = last2Months.addMonths(-2);
		return Database.getQueryLocator([SELECT id, Record_Processed_for_commission__c
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
	                                            And (OwnerId NOT IN :usersToSkip AND Sign_in_AE__c NOT IN :usersToSkip)
	                                         ORDER BY LastModifiedDate DESC lIMIT 100]);
    }   
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
    	if(scope.size() > 0){
    		for(Asset assetToMark : scope){
    			assetToMark.Record_Processed_for_commission__c = true;
    		}    		
    		update scope;
    	}
    
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}