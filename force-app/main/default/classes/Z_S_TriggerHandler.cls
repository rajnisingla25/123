/**
 * Trigger class that maps the subscriptions to the right nvoice items after amendments.
 * Also handles logic for updating Assets with their Zuora Subscription Information
 * @author Waly K. Ndao (waly.ndao@zuora.com) 
 */
public with sharing class Z_S_TriggerHandler { 

    private static final String CT_ONETIME = 'One-Time';
    private static final String DEBUG_STR = 'Z_S_TriggerHandler: ';
 
    // Constructor
    public Z_S_TriggerHandler() { } 
     
    /**
     * Called after subscriptions are inserted. Updates Invoice Items to have a link 
     * to their respective Subscription
     * @param newSs The subscriptions being inserted from trigger.
     */
    public void onAfterInsert(List<Zuora__Subscription__c> newSs) {
        final String FUNC_STR = DEBUG_STR+'onAfterInsert: ';

        Set<String> s_names; 
        List<Invoice_Item__c> iis_list;
        List<Invoice_Item__c> toUpdate;
        List<Invoice_Item__c> iis;
        Map<String, List<Invoice_Item__c>> iis_map;

        s_names = new Set<String>();
        for (Zuora__Subscription__c s : newSs) {
            s_names.add(s.Name);
        }

        System.debug(FUNC_STR+'The newly created subscriptions are: ' + s_names);

        iis_list = [SELECT Id, Subscription__c, Subscription_Zuora_ID__c
                    FROM Invoice_Item__c
                    WHERE Subscription_Zuora_ID__c in: s_names];

        System.debug(FUNC_STR+'The invoice items to be remapped are: ' + iis_list);

        iis_map = new Map<String, List<Invoice_Item__c>>();
        for (Invoice_Item__c ii : iis_list) {
            if(!iis_map.containsKey(ii.Subscription_Zuora_ID__c)) {
                iis_map.put(ii.Subscription_Zuora_ID__c, new List<Invoice_Item__c>());
                iis_map.get(ii.Subscription_Zuora_ID__c).add(ii);
            } else {
                iis_map.get(ii.Subscription_Zuora_ID__c).add(ii);
            }             
        }

        toUpdate = new List<Invoice_Item__c>();
        for (Zuora__Subscription__c s : newSs) {
            iis = iis_map.get(s.Name);
            if (iis != null) {
                for(Invoice_Item__c ii : iis) {
                    if (ii.Subscription__c != s.Id) {
                        ii.Subscription__c = s.Id;
                        toUpdate.add(ii);
                    } 
                }
            }
        }

        System.debug(FUNC_STR+'Updating '+toUpdate.size()+' Invoice Items: ' + toUpdate); 
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }    
    }
  
    /**
     * Updates Assets with their Zuora Subscription information
     * @param newSs Subscriptions being inserted/updated from trigger
     */
    public void updateAssetSubscriptionIds(List<Zuora__Subscription__c> newSs) {
        final String FUNC_STR = DEBUG_STR+'updateAssetSubscriptionIds: ';
        
        //Set of Subscription IDs
        Set<Id> setIds = new Set<Id>();

        //Stores mapping of RatePlan Name to ProductRatePlanCharge ZuoraId
        Map<String,String> prpNameToChargeIdMap  = new Map<String,String>();

        //Stores mapping of RatePlan Name to ProductRatePlan ZuoraId        
        Map<String,String> prpNameToPlanIdMap  = new Map<String,String>();

        //Stores mapping of Asset Id to SubscriptionProductCharge 
        Map<String,Zuora__SubscriptionProductCharge__c> assetToSubChargeMap = new Map<String,Zuora__SubscriptionProductCharge__c>();

        //Stores mapping of Asset Id to Subscription
        Map<String,Zuora__Subscription__c> assetToSubMap = new Map <String,Zuora__Subscription__c>();
        
        set<String> Paymentmethods = new set<String>();
        Set<String> accountset = new set<String>();
        for (Zuora__Subscription__c zsub:newSs) {
            setIds.add(zsub.id);
            Paymentmethods.add(zsub.PaymentMethodId__c);
            accountset.add(zsub.Zuora__Account__c);         
            assetToSubMap.put(zsub.Asset__c,zsub);
        }
        //CRM-4351 Accept the payment method at the subscription level.
        Map<String,String > payidmap = new Map<String,id>();
        if(Paymentmethods.size()>0){
            for(PaymentProfiles__c inloop: [Select Id, PaymentMethodId__c, Account__c   From PaymentProfiles__c Where Account__c IN: accountset and PaymentMethodId__c IN:Paymentmethods]){            
                payidmap.put(inloop.PaymentMethodId__c, inloop.Id);            
            }
        }
        //Code Added by Preya 05-18-2016                                               
        List<Asset> updAssets = [SELECT Id,Record_Processed_for_commission__c,Line_Type__c, Renewal_status__c,
                Start_Date__c,End_Date__c,Name,Zoura_Id__c,Zoura_Product_Rate_Plan_Charge_Id__c,order_line_item__r.Fulfillment_status__c,
                ZuoraProductRatePlanId__c,Subscription_Start_Date__c,Subscription_End_Date__c, 
                Term_Start_Date__c, Term_End_Date__c, Subscription_Id__c,Next_Charge_Date__c
                FROM Asset 
                WHERE Id=:assetToSubMap.keyset()];
        System.debug(FUNC_STR+'Retrieved : '+updAssets.size()+' Assets to update: '+updAssets); 
                       
        //Update Subscription-level details on Asset                        
        for (Asset asset: updAssets ){           
            System.debug(FUNC_STR+'Asset Id : ' + asset.id);
            if(assetToSubMap.containskey(asset.id)) {
                Zuora__Subscription__c sub = assetToSubMap.get(asset.id);
                if(payidmap.containskey(sub.PaymentMethodId__c))
                asset.Payment_Profile__c = payidmap.get(sub.PaymentMethodId__c);
                asset.Subscription_Id__c = sub.Zuora__Zuora_Id__c;
                //CRM-1489
                asset.Zuora_Subscription_Name__c = sub.Name;
                asset.Subscription_End_Date__c = sub.Zuora__SubscriptionEndDate__c;
                asset.Subscription_Start_Date__c = sub.Zuora__SubscriptionStartDate__c;
                asset.Term_Start_Date__c = sub.Zuora__TermStartDate__c;
                asset.Term_End_Date__c = sub.Zuora__TermEndDate__c;
                asset.Next_Charge_Date__c = sub.Zuora__NextChargeDate__c;
            }
        }
        
        //if (!updAssets.isEmpty()) {
        //    update updAssets;
        //    System.debug(FUNC_STR+'Assets updated with Subscription info.');
        //}  
        //Ends
        
        List<Zuora__SubscriptionProductCharge__c> lstSubProdCharge = [SELECT Id, 
                Zuora__BillingPeriodStartDay__c, Zuora__Subscription__r.Zuora__SubscriptionStartDate__c,
                Zuora__Subscription__r.Zuora__SubscriptionEndDate__c,Zuora__Subscription__c,
                Zuora__Subscription__r.Zuora__Zuora_Id__c,Zuora__Subscription__r.Zuora__NextChargeDate__c,Zuora__Subscription__r.Zuora__Version__c,Zuora__RatePlanName__c ,Zuora__RatePlanId__c,Zuora__Subscription__r.Asset__c,
                Zuora__Subscription__r.AssetID__c, Zuora__Subscription__r.Zuora__TermStartDate__c,Zuora__Subscription__r.Zuora__TermSettingType__c, 
                Zuora__Subscription__r.Zuora__TermEndDate__c  
                FROM Zuora__SubscriptionProductCharge__c
                 
                WHERE Zuora__Subscription__c =:setIds AND Zuora__Type__c !=: CT_ONETIME];
  
        for (Zuora__SubscriptionProductCharge__c zsubpc: lstSubProdCharge) {
            System.debug(FUNC_STR+'Asset###'+zsubpc.Zuora__Subscription__r.Asset__c);
            assetToSubChargeMap.put(zsubpc.Zuora__Subscription__r.Asset__c,zsubpc);
            prpNameToChargeIdMap.put(zsubpc.Zuora__RatePlanName__c,'');
        }
  
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT zqu__ProductRatePlan__r.Id,
                zqu__ProductRatePlan__r.zqu__ZuoraId__c,zqu__ProductRatePlan__r.Name,zqu__ZuoraId__c 
                FROM zqu__ProductRatePlanCharge__c 
                WHERE zqu__Deleted__c = false AND zqu__ProductRatePlan__r.Name =:prpNameToChargeIdMap.keyset()];
  
        for (zqu__ProductRatePlanCharge__c prpc: prpcList) {
            prpNameToChargeIdMap.put(prpc.zqu__ProductRatePlan__r.Name,prpc.zqu__ZuoraId__c);
            prpNameToPlanIdMap.put(prpc.zqu__ProductRatePlan__r.Name,prpc.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
        }
  
        //Replacing with above query of Assets
        //List<Asset> lstAsset = [SELECT Id,Record_Processed_for_commission__c,Line_Type__c,Start_Date__c,End_Date__c ,name,Zoura_Id__c,
        //    Zoura_Product_Rate_Plan_Charge_Id__c,ZuoraProductRatePlanId__c,Subscription_Start_Date__c,
        //    Subscription_End_Date__c, Term_Start_Date__c, Term_End_Date__c 
        //    FROM Asset 
        //    WHERE Id =: assetToSubChargeMap.keyset()];
        
        //Update SubscriptionCharge-level details on Assets                        
        for(Asset asst:updAssets) {
            System.debug(FUNC_STR+'Asset###'+asst.id);
            if(assetToSubChargeMap.containskey(asst.id)) {
                Zuora__SubscriptionProductCharge__c subProdChrg = assetToSubChargeMap.get(asst.id);
                asst.Zoura_Id__c = subProdChrg.Zuora__RatePlanId__c;
                asst.Zoura_Product_Rate_Plan_Charge_Id__c =  prpNameToChargeIdMap.get(subProdChrg.Zuora__RatePlanName__c);
                asst.ZuoraProductRatePlanId__c = prpNameToPlanIdMap.get(subProdChrg.Zuora__RatePlanName__c);
                asst.Period_Start_Day__c = subProdChrg.Zuora__BillingPeriodStartDay__c;
                //CRM-1796 TPCRM Assets End Date updating to 12 months instead of 12/31/2026 upon Renewal
                //CRM-3305 add condition Termed.
                if(asst.Line_Type__c == 'Add' && assetToSubChargeMap.get(asst.id).Zuora__Subscription__r.Zuora__Version__c == 1 && assetToSubChargeMap.get(asst.id).Zuora__Subscription__r.Zuora__TermSettingType__c =='TERMED'){
                    if(asst.Start_Date__c.daysBetween(subProdChrg.Zuora__Subscription__r.Zuora__TermStartDate__c)>0 || 
                       asst.End_Date__c.daysBetween((subProdChrg.Zuora__Subscription__r.Zuora__TermEndDate__c).addDays(-1))>0) 
                    {
                        if(asst.Record_Processed_for_commission__c==true) {
                            asst.Start_Date__c = subProdChrg.Zuora__Subscription__r.Zuora__TermStartDate__c;
                            if(subProdChrg.Zuora__Subscription__r.Zuora__TermEndDate__c!=null)
                            asst.End_Date__c = subProdChrg.Zuora__Subscription__r.Zuora__TermEndDate__c.addDays(-1);
                            asst.Line_Type__c = 'AssetSync';
                        }
                    }
                }
                if(asst.order_line_item__r.Fulfillment_status__c=='Fulfilled' && asst.Line_Type__c == 'Renew'){
                if(asst.renewal_status__c == 'Pending Fulfillment'){
                asst.renewal_status__c = '';
                }
                }
            }
        }
        
        //Update Assets
        if(!updAssets.isEmpty()) {
            update updAssets;
        }
    }
}