/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   13-FEB-2018
Usage              :   The usage of this class is to fetch all assets (line type = Renew) which are ready for 
                       commission process/fulfilled assets and sending to handler class to create new commissions
                       
                       Find the below conditiond it should meet to create commissions.
                       * Line Type = Renew (Line_Type__c)
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
global class commissions_RenewalCommissionsBatch_New implements Schedulable,Database.Batchable<sObject>{
    /***
    String query;
    global commissions_RenewalCommissionsBatch_New(String queryString) 
    {
        query = queryString;
    }
    **/
    //START METHOD
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //RETRIVING ALL RENEWAL ASSETS WHICH ARE READY FOR CREATING COMMISSIONS/FULFILLED ASSETS
        return Database.getQueryLocator([select id,Name,accountId,Product2Id,Product2.ProductCode,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Account.recordtypeid,
                Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                from asset where Line_Type__c =: system.label.Commission_Line_Type_Renew
                AND Fulfillment_Status__c =: system.label.Commissions_Asset_Fulfillment_Status
                AND (Commission_field__c =: system.label.Commissions_Calculate Or Commission_field__c = ' ' Or Commission_field__c = Null) 
                AND Asset_Type__c =: system.label.Commissions_Asset_Asset_Type  
                AND (Status =: system.label.Commissions_Asset_Status_Active Or Status =: system.label.Commissions_Asset_Status_Cancelled) 
                AND Commissions_are_calculated__c = FALSE
                AND Record_Processed_for_commission__c = FALSE
                AND Account_Type__c !=: system.label.Commissions_Asset_Account_Type ]);
                
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        if(scope.size()>0){
            //PROCESSING ALL RETRIVED ASSETS FOR TO CREATE NEW COMMISSIONS (Commissions_CreateNewCommissionHndlr_New)
           commissions_NewSaleBatchHandler_New commission = new commissions_NewSaleBatchHandler_New();
           commission.createCommissions(scope);            
        }      
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) {
         /***
         List<CronTrigger> listCronTriggerAsset = [select Id 
                      FROM CronTrigger 
                      WHERE CronJobDetail.Name LIKE 'Commissions Renewal New_JobA1A%' 
                      AND State = 'DELETED' 
                      AND nextfiretime = null limit 10];
        if(listCronTriggerAsset.size() > 0){
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
            { 
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
        Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Commissions Renewal New_JobA1A%'];
            
        if(rcount<2){
            commissions_RenewalCommissionsBatch_New p = new commissions_RenewalCommissionsBatch_New();
            Datetime dtt = System.now().addMinutes(10).addSeconds(2);
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('Commissions Renewal New_JobA1A'+dtt, sch, p);

            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            if(listCronTrigger.size() > 0){
                for(Integer i = 0; i < listCronTrigger.size(); i++){
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
        }
        ****/
    }
    global void execute(SchedulableContext scon) {
        //Database.executeBatch(new commissions_RenewalCommissionsBatch_New(),100);
    }
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/