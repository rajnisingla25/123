/*******************************************************************************
Created By         :   Sourabh Lakhera
Created Date       :   09-May-2018
Usage              :   The usage of this class is to fetch all assets (line type = Amend) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions
                       
                       It will create commissions to signing ae and asset owner,Once the commissions are created we are checking 
                       the flags (Commissions are calculated and Record Processed for commission) to TRUE in asset level   

********************************************************************************/
global class commissions_AmendComBatchProcess_New implements Database.Batchable<sObject>{
    
    Set<Id> MainAssets = new Set<Id>();
    global commissions_AmendComBatchProcess_New (Set<Id> listMainAssets)
    {
        MainAssets= listMainAssets;
    }
    
    //START METHOD
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //RETRIVING ALL NEW/ADD ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        // CRM-4206 : Added field 'Product2.Name' in the asset query
        return Database.getQueryLocator([SELECT id,Name,accountId,Account.RecordTypeId,Product2Id,Product2.ProductCode, Product2.Name, Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Owner.Profile.name,
                Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Product_Code__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                FROM asset 
                WHERE id IN:MainAssets]);
               
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
        commissions_AmdClwbckBtchProcessHdlr_New Commission = new commissions_AmdClwbckBtchProcessHdlr_New ();
        Commission.createCommissions(scope);        
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) 
    {
        
    }
   
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/