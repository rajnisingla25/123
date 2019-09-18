/*******************************************************************************
Created By         :   Sourabh Lakhera
Created Date       :   09-May-2018
Usage              :   The usage of this class is to fetch all assets (line type = Renew) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions
                       
                       It will create commissions to signing ae and asset owner,Once the commissions are created we are checking 
                       the flags (Commissions are calculated and Record Processed for commission) to TRUE in asset level 

********************************************************************************/
global class commissions_RenewalComBatchProcess_New implements Database.Batchable<sObject>{
    
    Set<Id> MainAssets = new Set<Id>();
    global commissions_RenewalComBatchProcess_New (Set<Id> listMainAssets)
    {
        MainAssets= listMainAssets;
    }
    
    
    //START METHOD
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //RETRIVING ALL RENEWAL ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        // CRM-4206 : Added field 'Product2.Name' in the asset query
        return Database.getQueryLocator([select id,Name,accountId,Product2Id,Product2.ProductCode, Product2.Name, Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Account.recordtypeid,
                Commission_field__c,Sign_in_AE__r.Team__c,Owner.Profile.Name,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                from asset where id IN:MainAssets]);
                
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        if(scope.size()>0){
            //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
           commissions_NewSaleBatchProcessHdlr_New commission = new commissions_NewSaleBatchProcessHdlr_New ();
           commission.createCommissions(scope);            
        }      
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) 
    {
    }
    }

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/