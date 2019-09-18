/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   13-FEB-2018
Usage              :   The usage of this class is to fetch all assets (line type = Add) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions
                       
                       Find the below conditiond it should meet to create commissions.
                       * Line Type = Cancel (Line_Type__c)
                       * Fulfillment Status = Fulfilled (Fulfillment_Status__c)
                       * Commission field = Calculate (Commission_field__c)     
                       * Asset Type = Parent (Asset_Type__c)
                       * Status = Active or Cancelled                       
                       * Commissions are calculated = FALSE (Commissions_are_calculated__c) 
                       * Record Processed for commission = FALSE (Record_Processed_for_commission__c)
                       * Account_Type != Franchise Company (Account_Type__c)
                       * Order Line Item Product Commission Category != Tiger (Order_Line_Item__r.Product_Commission_Category__c)
                       
                       It will create commissions to signing ae and asset owner,Once the commissions are created we are checking 
                       the flags (Commissions are calculated and Record Processed for commission) to TRUE in asset level   

********************************************************************************/
global class commissions_ClawbackBatch_New implements Database.Batchable<sObject>{
    
    private set<Id> setAssetIds = new set<Id>();
    global commissions_ClawbackBatch_New(set<Id> setUserAssetIds) 
    {
        this.setAssetIds = setUserAssetIds;
    }
    
    //START METHOD
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //RETRIVING ALL NEW/ADD ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        set<string> setCommissionFieldValues = new set<string> {system.label.Commissions_Calculate, ' ', null};
        set<string> setStatuses = new set<string> {system.label.Commissions_Asset_Status_Active, system.label.Commissions_Asset_Status_Cancelled};
        system.debug('AssetIds::: ' + setAssetIds);
        // CRM-4206 : Added field 'Product2.Name' in the asset query
        return Database.getQueryLocator([select id,Name,accountId,Account.RecordTypeId,Product2Id,Product2.Name, Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,Owner.Profile.Name,
                Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                from asset where Line_Type__c =: system.label.Commission_Line_Type_Cancel  
                AND Fulfillment_Status__c =: system.label.Commissions_Asset_Fulfillment_Status
                AND Commission_field__c IN :setCommissionFieldValues
                AND Asset_Type__c =: system.label.Commissions_Asset_Asset_Type 
                AND (Status IN :setStatuses OR (Status = 'Expired' AND Product_code__c = 'SELLERLEADBUNDLE'))
                AND Commissions_are_calculated__c = FALSE
                AND Record_Processed_for_commission__c = FALSE
                AND Account_Type__c !=: system.label.Commissions_Asset_Account_Type
                AND Id In :setAssetIds]);
               
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
        commissions_AmdClwbckBtchProcessHdlr_New amendClawbackHandler = new commissions_AmdClwbckBtchProcessHdlr_New();
        amendClawbackHandler.CreateCommissions(scope);        
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) {
        
    }
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/