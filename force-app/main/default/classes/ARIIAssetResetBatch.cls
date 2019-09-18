//Name        : ARIIAssetResetBatch
//Description : This Batch resets the Assets which are ready for next Auto Renewal Schedule.
//Frequencey  : Every Day
//Author      : Pallavi Tammana
//History     : CRM-3263: SFDC tasks for backup process for additional new fields
//            : CRM-3741: Clear AR fields from Asset
//            : CRM-3743: Run Asset Reset batch for Assets with Start date < today - reset dates

global class ARIIAssetResetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> AsstIdset = new set<ID>();
    global String Query;
       
    global ARIIAssetResetBatch(set<ID> AsstIds) {
        AsstIdset.addall(AsstIds);
    }
   
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ AsstIdset:'+AsstIdset);
        Schedule_Batch_Setting__c resetp = Schedule_Batch_Setting__c.getValues('ARII Reset Asset'); 
        Date d = System.today().addMonths(Integer.valueof(resetp.Assetresttime__c));
        System.debug('d:'+d);
        //CRM-3743: Added condition to check <= today.
        Query = 'Select Id, Follow_Up_Status__c, KickoutReason__c, Renewal_Status__c, Renewal_Type__c, AutoRenewQuoteProduct__c, Reason__c, Reason_Details__c,AutoRenewalPicked__c, FollowUpStatus_Bkup__c, KickoutReason_Bkup__c, QuoteProductId_Bkup__c, Reason_Bkup__c, ReasonDetail_Bkup__c from Asset where Start_Date__c <= :d AND Follow_Up_Status__c = \'Renewed\' AND Status = \'Active\' AND Id IN :AsstIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
    
        List<Asset> AsstUpdList = new List<Asset>();
        Set<Asset> AsstUpdSet = new Set<Asset>();
        Set<Asset_AR_Association__c> AsstARSet = new Set<Asset_AR_Association__c>();
        List<Asset_AR_Association__c> AsstARUpdList = new List<Asset_AR_Association__c>();
        Map<Id, Asset> AsstMap = new Map<Id,Asset>();
                
        for(Asset asst: scope) {
                            
            //Copying the values to Backup fields for reporting   
            asst.FollowUpStatus_Bkup__c    = asst.Follow_Up_Status__c;
            asst.KickoutReason_Bkup__c     = asst.KickoutReason__c;
            asst.QuoteProductId_Bkup__c    = asst.AutoRenewQuoteProduct__c;
            asst.Reason_Bkup__c            = asst.Reason__c;
            asst.ReasonDetail_Bkup__c      = asst.Reason_Details__c;
            
            //Resetting values for next cycle of Auto Renewals   
            asst.AutoRenewalPicked__c      = false;
            asst.Follow_Up_Status__c       = '';
            asst.Reason__c                 = '';
            asst.Reason_Details__c         = '';
            asst.KickoutReason__c          = '';
            asst.AutoRenewQuoteProduct__c  = '';
            asst.Renewal_Type__c           = 'Manual'; 
            asst.Renewal_Status__c         = '';
            
            AsstUpdSet.add(asst);
            AsstMap.put(asst.Id, asst);

        }
         List <Asset_AR_Association__c> ArList = new List <Asset_AR_Association__c>([Select Id, Bkup_Billing_Frequency__c, Bkup_Licenses__c, Bkup_Price_Info__c,                                            
                                            Bkup_Renewal_Price_Tier__c, AR_Price_Info__c, AR_Billing_Frequency__c,
                                            AR_Licenses__c, AR_Renewal_Price_Tier__c, Asset_Id__c, Bkup_CustResp_AutoOrder__c,
                                            Bkup_CustResp_AppliesSpotPromo__c, Bkup_CustResp_Contract_Term__c,
                                            Bkup_CustResp_List_Price__c, Bkup_CustResp_Promo_age__c, Bkup_CustResp_Promotion__c,
                                            Bkup_CustResp_Reason__c, Bkup_CustResp_Renewal_Option__c, Bkup_CustResp_Spot_Promotion__c,
                                            Bkup_CustResp_Spot_Promotion_age__c, Bkup_CustResp_Total_Net__c, Bkup_AR_Price_Info__c, 
                                            Asset_Id__r.CustResp_AppliesSpotPromo__c, Asset_Id__r.CustResp_Contract_Term__c,
                                            Asset_Id__r.CustResp_List_Price__c, Asset_Id__r.CustResp_Promo_age__c, 
                                            Asset_Id__r.CustResp_Reason__c, Asset_Id__r.CustResp_Renewal_Option__c,
                                            Asset_Id__r.CustResp_Spot_Promotion__c, Asset_Id__r.CustResp_Spot_Promotion_age__c,
                                            Asset_Id__r.CustResp_Total_Net__c, Asset_Id__r.CustResp_Promotion__c, Asset_Id__r.CustResp_AutoOrder__c, Asset_Id__r.CustResp_TotalListPrice__c, Bkup_CustResp_TotalListPrice__c, //CRM-2570
                                            Bkup_CustResp_AR_Promotion__c, Bkup_CustResp_AR_Strategic_Promotion_cod__c, Bkup_CustResp_AR_Strategic_Promotion_ag__c,  Bkup_CustResp_AR_Strategic_Promotion__c, //CRM-2490                                       
                                            Asset_Id__r.CustResp_AR_Promotion__c, Asset_Id__r.CustResp_AR_Strategic_Promotion__c, Asset_Id__r.CustResp_AR_Strategic_Promotion_age__c, Asset_Id__r.CustResp_AR_Strategic_Promotion_code__c, //CRM-2490
                                            AR_AMLC_Land__c, AR_AMLC_Rental__c, AR_AMLC_Residential__c, AR_Brand_PPL__c, AR_Lead_PPL__c, AR_Config_Options__c, AR_PPL_Override__c, AR_Product_Type__c,
                                            Bkup_AR_AMLC_Land__c, Bkup_AR_AMLC_Rental__c, Bkup_AR_AMLC_Residential__c, Bkup_AR_Brand_PPL__c, Bkup_AR_Config_Options__c, Bkup_AR_Lead_PPL__c, Bkup_AR_PPL_Override__c, Bkup_AR_Product_Type__c
                                            from Asset_AR_Association__c where Asset_Id__c IN: scope]);
        if(!ArList.isEmpty()){    
            for(Asset_AR_Association__c AR: ArList){
            
                AR.Bkup_Billing_Frequency__c = AR.AR_Billing_Frequency__c;
                AR.Bkup_Licenses__c = AR.AR_Licenses__c;
                //AR.Bkup_Price_Info__c = AR.AR_Price_Info__c;
                AR.Bkup_Renewal_Price_Tier__c = AR.AR_Renewal_Price_Tier__c;
                AR.Bkup_CustResp_AppliesSpotPromo__c = AR.Asset_Id__r.CustResp_AppliesSpotPromo__c;
                AR.Bkup_CustResp_Contract_Term__c = AR.Asset_Id__r.CustResp_Contract_Term__c;
                AR.Bkup_CustResp_List_Price__c = AR.Asset_Id__r.CustResp_List_Price__c;
                AR.Bkup_CustResp_Promo_age__c = AR.Asset_Id__r.CustResp_Promo_age__c;
                AR.Bkup_CustResp_Promotion__c = AR.Asset_Id__r.CustResp_Promotion__c;
                AR.Bkup_CustResp_Reason__c = AR.Asset_Id__r.CustResp_Reason__c;
                AR.Bkup_CustResp_Renewal_Option__c = AR.Asset_Id__r.CustResp_Renewal_Option__c;
                AR.Bkup_CustResp_Spot_Promotion__c = AR.Asset_Id__r.CustResp_Spot_Promotion__c;
                AR.Bkup_CustResp_Spot_Promotion_age__c = AR.Asset_Id__r.CustResp_Spot_Promotion_age__c;
                AR.Bkup_CustResp_Total_Net__c = AR.Asset_Id__r.CustResp_Total_Net__c;
                AR.Bkup_CustResp_AutoOrder__c = AR.Asset_Id__r.CustResp_AutoOrder__c;                
                
                AR.Bkup_CustResp_AR_Promotion__c = AR.Asset_Id__r.CustResp_AR_Promotion__c; //CRM-2490
                AR.Bkup_CustResp_AR_Strategic_Promotion_cod__c = AR.Asset_Id__r.CustResp_AR_Strategic_Promotion_code__c; //CRM-2490
                AR.Bkup_CustResp_AR_Strategic_Promotion_ag__c = AR.Asset_Id__r.CustResp_AR_Strategic_Promotion_age__c; //CRM-2490
                AR.Bkup_CustResp_AR_Strategic_Promotion__c = AR.Asset_Id__r.CustResp_AR_Strategic_Promotion__c; //CRM-2490
                AR.Bkup_CustResp_TotalListPrice__c = AR.Asset_Id__r.CustResp_TotalListPrice__c; //CRM-2570
                AR.Bkup_AR_Price_Info__c = AR.AR_Price_Info__c; //CRM-2645
                
                //CRM-3263 : Added new fields
                AR.Bkup_AR_AMLC_Land__c = AR.AR_AMLC_Land__c;
                AR.Bkup_AR_AMLC_Rental__c = AR.AR_AMLC_Rental__c;
                AR.Bkup_AR_AMLC_Residential__c = AR.AR_AMLC_Residential__c;
                AR.Bkup_AR_Brand_PPL__c = AR.AR_Brand_PPL__c;
                AR.Bkup_AR_Config_Options__c = AR.AR_Config_Options__c;
                AR.Bkup_AR_Lead_PPL__c = AR.AR_Lead_PPL__c;
                AR.Bkup_AR_PPL_Override__c = AR.AR_PPL_Override__c;
                AR.Bkup_AR_Product_Type__c = AR.AR_Product_Type__c;
                
                AR.AR_Billing_Frequency__c = '';
                AR.AR_Licenses__c = '';
                AR.AR_Renewal_Price_Tier__c = 0;
                AR.AR_Price_Info__c = '';
                
                //CRM-3263 : Added new fields
                AR.AR_AMLC_Land__c = 0;
                AR.AR_AMLC_Rental__c = 0;
                AR.AR_AMLC_Residential__c = 0;
                AR.AR_Brand_PPL__c = 0;
                AR.AR_Lead_PPL__c = 0;
                AR.AR_Config_Options__c = '';
                AR.AR_PPL_Override__c = 0;
                AR.AR_Product_Type__c = '';
                //CRM-3741
                Asset asst = AsstMap.get(AR.Asset_Id__c);                                                
                asst.CustResp_AppliesSpotPromo__c = '';
                asst.CustResp_Contract_Term__c = '';
                asst.CustResp_List_Price__c = 0;
                asst.CustResp_Promo_age__c = 0;
                asst.CustResp_Reason__c = '';
                asst.CustResp_Renewal_Option__c = '';
                asst.CustResp_Spot_Promotion__c = '';
                asst.CustResp_Spot_Promotion_age__c = 0;
                asst.CustResp_Total_Net__c = 0;
                asst.CustResp_AutoOrder__c = 'No';
                
                asst.CustResp_Promotion__c = '';
                asst.CustResp_AR_Promotion__c = 0;
                asst.CustResp_AR_Strategic_Promotion_code__c = '';
                asst.CustResp_AR_Strategic_Promotion_age__c = 0;
                asst.CustResp_AR_Strategic_Promotion__c = 0;
                asst.CustResp_TotalListPrice__c = 0;
                                                
                AsstARSet.add(AR);
                
                //AsstUpdSet.add(asst);
            }
        }
                
        if(!AsstARSet.isEmpty()) {
            AsstARUpdList.addAll(AsstARSet);
            update AsstARUpdList;
        }
        
        if(!AsstUpdSet.isEmpty()) {
            AsstUpdList.addAll(AsstUpdSet);
            update AsstUpdList;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {       
         AsyncApexJob[] jobs = [SELECT Id, JobItemsProcessed from AsyncApexJob 
                                    where JobType='BatchApex' AND (status='Processing' OR status = 'Queued' OR status = 'Holding')
                                    AND ApexClassId IN (Select Id from ApexClass where Name = 'ARIIQuoteCreationSchedulable')]; //crm-2516
            if (jobs==null || jobs.size()==0) { 
            ARIIQuoteCreationSchedulable ARschBatch = new ARIIQuoteCreationSchedulable();
                Datetime dtt = System.now().addMinutes(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ARIIBatchJobRecAR'+dtt, sch, ARschBatch);
            }   
    }
}