public class WaitlistItemUpdateSpend{
    public static boolean skipCalc = false;

    Public static void updatecurrentutlzdspend(map<id,Asset> NewAssetmap){
    if(!skipCalc){
            map<Id, Decimal>  extendedNetPriceMap = new map<Id, Decimal>();
    
            list<Asset> assetdata = [SELECT Extended_Net_Price__c ,order_line_Item__r.Order.Oracle_Quote__r.Waitlist_Item__c,Id FROM Asset 
                                     where id  in : NewAssetmap.keySet() and Asset_Type__c='Parent' 
                                     and line_type__c = 'Add' and Fulfillment_Status__c = 'Fulfilled' 
                                     and Status = 'Active'];
            
            System.debug('======>>'+assetdata);
            
            for(Asset astloop : assetdata){
                Decimal extendedNetPrice = astloop.Extended_Net_Price__c;
                Id waitlistId = astloop.order_line_Item__r.Order.Oracle_Quote__r.Waitlist_Item__c;
                if(waitlistId != null){
                    if(extendedNetPriceMap.containskey(waitlistId)){
                        Decimal totalExtendedNetPrice = (extendedNetPrice == null ? 0.00 : extendedNetPrice)
                                                        + extendedNetPriceMap.get(waitlistId);
                        extendedNetPriceMap.put(waitlistId, totalExtendedNetPrice);                               
                    } else{
                         extendedNetPriceMap.put(waitlistId,(extendedNetPrice == null ? 0.00 : extendedNetPrice));
                    }
                }            
            }   
            System.debug('=====extendedNetPriceMap=>>'+extendedNetPriceMap);
            
            // CRM-1423 Added condition to avoid executing SOQL if map is empty
            if (!extendedNetPriceMap.isEmpty()) {
                list<Waitlist_Item__c> WLIData = [select id,Current_Utilized_Spend__c from Waitlist_Item__c where Id in: extendedNetPriceMap.keyset() FOR UPDATE];
                for(Waitlist_Item__c WLIloop : WLIData){
                    WLIloop.Current_Utilized_Spend__c += extendedNetPriceMap.get(WLIloop.id);    
                }
                
                if(WLIData.size() > 0){
                    skipCalc = true;
                    Update WLIData; 
                }
             }
        }
        
    }
}