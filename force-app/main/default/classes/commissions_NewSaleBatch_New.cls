/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   13-FEB-2018
Usage              :   The usage of this class is to fetch all assets (line type = Add) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions
                       
                       Find the below conditiond it should meet to create commissions.
                       * Line Type = Add (Line_Type__c)
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
global class commissions_NewSaleBatch_New implements Schedulable,Database.Batchable<sObject>{
    //START METHOD
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //RETRIVING ALL NEW/ADD ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        
        return Database.getQueryLocator([SELECT id,Name,Product2Id,Product2.ProductCode,Sign_in_AE__c,OwnerId,Asset_Type__c,
                Fulfillment_Status__c,Status,Account_Type__c,Line_Type__c,Billing_Period__c,Total_Net__c,Account.recordtypeid,
                Commission_field__c,Delta_Price_w_o_Tax__c,Commissions_are_calculated__c,Order_Line_Item__c 
                FROM Asset where Line_Type__c =: system.label.Commission_Line_Type_Add  
                AND Fulfillment_Status__c =: system.label.Commissions_Asset_Fulfillment_Status
                AND (Commission_field__c =: system.label.Commissions_Calculate Or Commission_field__c = ' ' Or Commission_field__c = Null) 
                AND Asset_Type__c =: system.label.Commissions_Asset_Asset_Type 
                AND (Status =: system.label.Commissions_Asset_Status_Active Or Status =: system.label.Commissions_Asset_Status_Cancelled)  
                AND Commissions_are_calculated__c = FALSE
                AND Record_Processed_for_commission__c = FALSE
                AND Account_Type__c !=: system.label.Commissions_Asset_Account_Type]);
        
               
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        if(scope.size()>0){
            //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
           commissions_NewSaleBatchHandler_New Commission = new commissions_NewSaleBatchHandler_New();
           Commission.CreateCommissions(scope);            
        }      
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) {
        /**
        List<CronTrigger> listCronTriggerAsset = [select Id 
                      FROM CronTrigger 
                      WHERE CronJobDetail.Name LIKE 'Commissions Amend New_Job%' 
                      AND State = 'DELETED' 
                      AND nextfiretime = null limit 10];
        if(listCronTriggerAsset.size() > 0){
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
            { 
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
        Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Commissions Amend New_Job%'];
            
        if(rcount < 2){
            commissions_AmendBatch_New p = new commissions_AmendBatch_New();
            Datetime dtt = System.now().addMinutes(10).addSeconds(1);
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('Commissions Amend New_Job'+dtt, sch, p);

            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            if(listCronTrigger.size() > 0){
                for(Integer i = 0; i < listCronTrigger.size(); i++){
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
        }
        **/
        
    }
    global void execute(SchedulableContext scon) {
        Database.executeBatch(new commissions_NewSaleBatch_New(),100);
    }
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/