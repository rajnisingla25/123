/*******************************************************************************
Created By         :   Sourabh Lakhera
Created Date       :   23-APR-2018
Usage              :   The usage of this class is to fetch all assets (line type = Add) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions.
                                              
                       It will create commissions to signing ae and asset owner,Once the commissions are created we are checking 
                       the flags (Commissions are calculated and Record Processed for commission) to TRUE in asset level   

********************************************************************************/
global class commissions_NewSaleBatchProcess_New implements Database.Batchable<sObject>
{
    //START METHOD
    
    Set<Id> MainAssets = new Set<Id>();
    global commissions_NewSaleBatchProcess_New (Set<Id> listMainAssets)
    {
        MainAssets= listMainAssets;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //RETRIVING ALL NEW/ADD ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        // CRM-4206 : Added field 'Product2.Name' in the asset query
        return Database.getQueryLocator([SELECT id,Name,Product2Id,Product2.ProductCode, Product2.Name,Owner.Profile.Name, Sign_in_AE__c,OwnerId,Asset_Type__c,
                Fulfillment_Status__c,Status,Account_Type__c,Line_Type__c,Billing_Period__c,Total_Net__c,Account.recordtypeid,
                Commission_field__c,Delta_Price_w_o_Tax__c,Commissions_are_calculated__c,Order_Line_Item__c 
                FROM Asset where id IN :MainAssets]);
        
               
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) 
    {
        if(scope.size()>0)
        {
            //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
           commissions_NewSaleBatchProcessHdlr_New Commission = new commissions_NewSaleBatchProcessHdlr_New();
           Commission.CreateCommissions(scope);            
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