public class Commissioins_renewalAssets {
    public void inActiveCommissions(Map<id,Asset> newAssetMap,Map<id,Asset> oldAssetMap){
        set<Id> assetIds = new set<Id>();
        for(asset assetNewRecord : newAssetMap.values()){
            asset oldAssetRecord = oldAssetMap.get(assetNewRecord.id);
            if(assetNewRecord.Line_Type__c == 'Renew' && assetNewRecord.Line_Type__c != oldAssetRecord.Line_Type__c
                && assetNewRecord.LastModifiedDate.month() != oldAssetRecord.LastModifiedDate.month()){
                assetIds.add(assetNewRecord.id);
            }
        }
        if(assetIds.size() > 0){
            Map<id,Commission__c> inActiveCommissionsMap = new Map<id,Commission__c>();
            Map<id,Commission__c> mapCommissions = new Map<id,Commission__c>([select id,Name,Status__c,Related_to_Asset__c from Commission__c
                                where Related_to_Asset__c In : assetIds]);
            for(commission__c commissionRecord : mapCommissions.values()){
                commissionRecord.Status__c = 'InActive';
                inActiveCommissionsMap.put(commissionRecord.id,commissionRecord);
            }
            if(inActiveCommissionsMap.size() > 0){
                update inActiveCommissionsMap.values();
            }
        }
    }
}