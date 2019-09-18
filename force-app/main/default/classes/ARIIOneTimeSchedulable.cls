//Name        : ARIIOneTimeSchedulable
//Description : OneTime Schedule Job for all Auto Renewal Phase II.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class ARIIOneTimeSchedulable implements Schedulable {

    global set<Id> PrcAccset  = new set<Id>();
    
    global void execute(SchedulableContext sc) {

        List<Asset_AR_Association__c> ARNewList = new List<Asset_AR_Association__c>();
        Map<Id, String> AsstIdMap = new Map<Id, String>();
        Map<Id, String> AsstIdPriceMap = new Map<Id, String>();
        Map<Id, BigMachines__Quote_Product__c> bmqpMap = new Map<id, BigMachines__Quote_Product__c>();
        Set<Id> ARIdSet = new Set<Id>();
        Set<Id> setAsstId = new Set<Id>();
        Integer i = 1;
        Date dt;
        
        AutoRenewalNextEndDate__c oneTimeDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal One Time');
        if(oneTimeDate != null) {
            dt = oneTimeDate.Next_Month_Start_Date__c;
        }
            
            for(BigMachines__Quote_Product__c bmqp: [select Id, Price_Tier__c, Billing_Period__c, License_Tier__c, Asset__c, Asset__r.External_ID__c, 
                                BigMachines__Quote__r.BigMachines__Account__c, Contract_Term__c,
                                List_Price__c, Extended_Net_Price__c, Total_Net__c, Promotion__c, 
                                Promo_Discount__c, Promotion_Discount__c, Strategic_Discount__c,
                                Strategic_Discount_dollar__c, Strategic_Discount_Percent__c, 
                                Total_Discount_Percent__c, Total_Discount_Amount__c
                                from BigMachines__Quote_Product__c 
                                where  BigMachines__Quote__r.BigMachines_Quote_Type__c  = 'Auto-Renew' 
                                AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress' 
                                AND (BigMachines__Quote__r.Collections__c = True OR BigMachines__Quote__r.SalesOperations__c = True)
                                AND Asset__r.Follow_Up_Status__c <> 'Manual Renewal' AND Asset__r.Follow_Up_Status__c <> 'Will Not Renew'
                                AND Asset__r.Follow_Up_Status__c <> 'Pending Renewal'
                                AND Asset__r.Status = 'Active' AND  Asset__r.AutoRenewQuoteProduct__c != Null
                                AND Asset__r.AR_Nightly_Update__c = NULL
                                AND BigMachines__Quote__r.LastModifiedDate !=: dt]) {
                if(i <= 400) {
                     if(bmqp.Asset__c != null) {
                        setAsstId.add(bmqp.Asset__c);
                        AsstIdMap.put(bmqp.Asset__c, bmqp.Asset__r.External_ID__c );
                        PrcAccset.add(bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                        String priceInfo = (bmqp.Contract_Term__c != null ? bmqp.Contract_Term__c : '')+'^'; //CRM-2639
                        priceinfo+=(bmqp.List_Price__c != null ? bmqp.List_Price__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Extended_Net_Price__c != null ? bmqp.Extended_Net_Price__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Total_Net__c != null ? bmqp.Total_Net__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Promotion__c != null ? bmqp.Promotion__c : '')+'^'; //CRM-2639
                        priceinfo+=(bmqp.Promo_Discount__c != null ? bmqp.Promo_Discount__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Promotion_Discount__c != null ? bmqp.Promotion_Discount__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Strategic_Discount__c != null ? bmqp.Strategic_Discount__c : '')+'^'; //CRM-2639
                        priceinfo+=(bmqp.Strategic_Discount_dollar__c != null ? bmqp.Strategic_Discount_dollar__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Strategic_Discount_Percent__c != null ? bmqp.Strategic_Discount_Percent__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Total_Discount_Percent__c != null ? bmqp.Total_Discount_Percent__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Total_Discount_Amount__c != null ? bmqp.Total_Discount_Amount__c : 0.00)+'^'; //CRM-2639
                        priceinfo+=(bmqp.Billing_Period__c != null ? bmqp.Billing_Period__c : ''); //CRM-2639

                        AsstIdPriceMap.put(bmqp.Asset__c, priceInfo);
                        bmqpMap.put(bmqp.Asset__c, bmqp);
                        priceInfo = '';
                        i++;
                    }
                }
            }
            if(!setAsstId.isEmpty()) {
                for(Asset_AR_Association__c AR: [Select Id, External_ID__c, Asset_Id__c, Asset_Id__r.External_ID__c from Asset_AR_Association__c where Asset_Id__c IN: setAsstId]){
                    ARIdSet.add(AR.Asset_Id__c);                
                }
            }
        
            if(!ARIdSet.isEmpty()){
                for(Id arId: setAsstId){
                    if(!ARIdSet.contains(arId)) {
                        Asset_AR_Association__c asstAR = new Asset_AR_Association__c();
                        asstAR.Asset_Id__c = arId;
                        asstAR.External_ID__c = AsstIdMap.get(arId);
                        asstAR.AR_Price_Info__c = AsstIdPriceMap.get(arId);
                        asstAR.AR_Renewal_Price_Tier__c = bmqpMap.get(arId).Price_Tier__c; //CRM-2639
                        asstAR.AR_Billing_Frequency__c = bmqpMap.get(arId).Billing_Period__c;  //CRM-2639
                        asstAR.AR_Licenses__c = bmqpMap.get(arId).License_Tier__c != null ? String.valueOf(bmqpMap.get(arId).License_Tier__c) : ''; //CRM-2639
                        ARNewList.add(asstAR);
                    }
                }
            
            }
            else{
                for(Id arId: setAsstId){
                    Asset_AR_Association__c asstAR = new Asset_AR_Association__c();
                    asstAR.Asset_Id__c = arId;
                    asstAR.External_ID__c = AsstIdMap.get(arId);
                    asstAR.AR_Price_Info__c = AsstIdPriceMap.get(arId);
                    asstAR.AR_Renewal_Price_Tier__c = bmqpMap.get(arId).Price_Tier__c; //CRM-2639
                    asstAR.AR_Billing_Frequency__c = bmqpMap.get(arId).Billing_Period__c; //CRM-2639
                    asstAR.AR_Licenses__c = bmqpMap.get(arId).License_Tier__c != null ? String.valueOf(bmqpMap.get(arId).License_Tier__c) : ''; //CRM-2639
                    ARNewList.add(asstAR);
                }
                
            }
             if(!ARNewList.isEmpty())
                insert ARNewList;
            
            if(!PrcAccset.isEmpty()) {                                     
                ARIIOneTimeBatch PriceBatch = new ARIIOneTimeBatch(PrcAccset); 
                database.executebatch(PriceBatch,1);
            }
        }
}