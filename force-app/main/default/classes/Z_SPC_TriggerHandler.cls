/**
 * Trigger class that maps the subscription product charges
 * to the right invoice items after amendment.
 * @author Waly K. Ndao (waly.ndao@zuora.com) 
 */
public with sharing class Z_SPC_TriggerHandler {

    private static final String DEBUG_STR = 'Z_SPC_TriggerHandler: ';

    // Constructor
    public Z_SPC_TriggerHandler() {
     
    }
    
    /**
     * Called after rate plan charges are inserted.
     * @param newSPCs the rate plan charges to be inserted.
     */
    public void onAfterInsert(List<Zuora__SubscriptionProductCharge__c> newSPCs) {
        final String FUNC_STR = DEBUG_STR+'onAfterInsert: ';

        Set<String> spc_nums;
        List<Invoice_Item__c> iis_list;
        List<Invoice_Item__c> toUpdate;
        List<Invoice_Item__c> iis;
        Map<String, List<Invoice_Item__c>> iis_map;

        spc_nums = new Set<String>();

        for(Zuora__SubscriptionProductCharge__c spc : newSPCs) {
            spc_nums.add(spc.Z_Charge_Number__c);
        }

        System.debug(FUNC_STR+'The new rate plan charges are: ' + spc_nums);

        iis_list = [SELECT Id,RPC_Zuora_ID__c,Subscription_Product_Charge__c
                FROM Invoice_Item__c
                WHERE RPC_Zuora_ID__c IN: spc_nums];

        iis_map = new Map<String, List<Invoice_Item__c>>();       

        System.debug(FUNC_STR+'The invoice items to be remapped are: ' + iis_list);

        for (Invoice_Item__c ii : iis_list) {
            if (!iis_map.containsKey(ii.RPC_Zuora_ID__c)) {
                iis_map.put(ii.RPC_Zuora_ID__c, new List<Invoice_Item__c>());
                iis_map.get(ii.RPC_Zuora_ID__c).add(ii);
            } else {
                iis_map.get(ii.RPC_Zuora_ID__c).add(ii);
            }
        }

        toUpdate = new List<Invoice_Item__c>();
        for (Zuora__SubscriptionProductCharge__c spc : newSPCs) {
            iis = iis_map.get(spc.Zuora__ChargeNumber__c);
            if (iis != null) {
                for (Invoice_Item__c ii : iis) {
                    ii.Subscription_Product_Charge__c = spc.Id;
                    toUpdate.add(ii);
                }
            }
        }

        System.debug(FUNC_STR+'Updating '+toUpdate.size()+' Invoice Items: ' + toUpdate);
        if (!toUpdate.isEmpty()) { 
            update toUpdate;
        }
    } 

    /**
     * Updates SPC Subscriptions to retrigger logic in Subscription trigger
     * @param spcList List of SPCs to update Subscriptions for
     */
    public void updateRelatedSubs(List<Zuora__SubscriptionProductCharge__c> spcList) {
        final String FUNC_STR = DEBUG_STR+'updateRelatedSubs: ';

        Set<Id> subIdSet = new Set<Id>();
        
        for(Zuora__SubscriptionProductCharge__c subPC : spcList){
            subIdSet.add(subPC.Zuora__Subscription__c);
        }
        
        if(!subIdSet.isEmpty()) {
            List<Zuora__Subscription__c> subList = [SELECT Id,Name 
                    FROM Zuora__Subscription__c WHERE Id=:subIdSet];
        
            if(!subList.isEmpty()) {
                System.debug(FUNC_STR+'Updating '+subList.size()+' Subscriptions: '+subList);
                update subList;
            }
        }
    } 
 
}