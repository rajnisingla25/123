public class ARAssociationTriggerHandler{
    public static void updateARIIAssetStatus(List<Asset_Ar_Association__c> arList, boolean isDelete){
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset_AR_Association__c ar: arList){
            Asset a = new Asset();
            a.id = ar.Asset_Id__c;
            if(ar.AR_Price_Info__c != null && ar.AR_Price_Info__c != '' && ar.AR_Price_Info__c != 'NA'){
                  a.ARIIPrice_Info_Status__c = 'Yes';  
             }else{
                  a.ARIIPrice_Info_Status__c = 'No';
             }
             if(isDelete){ a.ARIIPrice_Info_Status__c = 'No';}
             assetsToUpdate.add(a);
        }
        if(!assetsToUpdate.isempty()){
            update assetsToUpdate;
        }
    }
}