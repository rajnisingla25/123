/* 
Name        : LegacyProsoftBundleFlagupdate
Description : Add 'Prosoft Bundle Flag' for legacy prosoft assets to identify if an asset is part of a bundle or not
Author      : Venu Ravilla
*/
global class LegacyProsoftBundleFlagupdate  implements Schedulable {
global void execute(SchedulableContext sc) {
 Set<Asset> AsstUpdSet = new Set<Asset>();
list<Asset>listasset1 = new list<Asset>(); 
list<Asset>listasset = new list<Asset>(); 
list<Asset>listasset2 = new list<Asset>(); 
 List<Asset> AsstUpdList = new List<Asset>();
 Map<Id, Asset> AsstMap = new Map<Id,Asset>();
 set<ID> AccountIDs = New set<ID>(); 
 map<ID,Date> Assetidmap = new map<ID,Date>();
  map<ID,Date> Assetidmap1 = new map<ID,Date>();
 Set<String> pset = new Set<String>();
 pset.addAll(Label.prosoft_bundle_products.split(','));
 Set<String> promset = new Set<String>();
 promset.addAll(Label.Promotions_Not_In.split(','));
/*
List<Asset> lstAset = [select Id,AccountId,Asset_Type__c,Is_Bundled__c,Promotion__c,Fulfillment_status__c from Asset where Promotion__c like '%Bundle%' and Asset_Type__c = 'Parent' and Fulfillment_status__c = 'Fulfilled' and Status = 'Active' and Promotion__c Not IN:promset and Product_code__c =:pset and Is_Bundled__c = False limit 5];
system.debug('Asset size is'+lstAset.size());
if(lstAset.size()>0){
for(Asset asst: lstAset) {
           asst.Is_Bundled__c = True;                 
            listasset.add(asst);
            AsstMap.put(asst.Id, asst);
            AccountIDs.add(asst.AccountId);
        }
        Update listasset;
        }
else{
    */
    List<AggregateResult> list1 = [select AccountId,Start_Date__c startdates,count(Id) numberofassets from Asset where Combined_Discount__c >0 and Combined_Discount_Percent__c <100 and Product_code__c =:pset and Asset_Type__c = 'Parent' and Promotion__c Not IN:promset and Status = 'Active' and Is_Bundled__c = False and Fulfillment_Status__c = 'Fulfilled' group by AccountId,Start_Date__c HAVING Count(Id) > 1 limit 5];
      if(list1 != null && list1.size() > 0 && !list1.isEmpty()){    
 for(AggregateResult agr:list1){
 Assetidmap.put((Id)agr.get('AccountId'), (Date)agr.get('startdates'));
 }
 }
    System.debug('Filtered Account Ids :' +Assetidmap.keyset());
    System.debug('Total Accounts :' +Assetidmap.keyset().size());    
    For(Asset Aste: [select id,Is_Bundled__c,AccountId from Asset where Combined_Discount__c >0 and Combined_Discount_Percent__c <100 and AccountId IN:Assetidmap.keyset() and Start_Date__c IN:Assetidmap.values() and Product_code__c =:pset and Is_Bundled__c = False and Asset_Type__c = 'Parent' and Promotion__c Not IN:promset and Status = 'Active' and Fulfillment_Status__c = 'Fulfilled']){
            Aste.Is_Bundled__c = True;
            listasset2.add(Aste);
            AsstMap.put(aste.Id, aste);
            }
       List<AggregateResult> list2 = [select AccountId,Start_Date__c startdate,count(Id) numberofasset from Asset where Combined_Discount__c >0 and Combined_Discount_Percent__c <100 and Is_Bundled__c = True and Product_code__c =:pset and Id Not IN:AsstMap.keyset() and Asset_Type__c = 'Parent' and Promotion__c Not IN:promset and Status = 'Active' and Fulfillment_Status__c = 'Fulfilled' group by AccountId,Start_Date__c HAVING Count(Id) < 2 limit 100];
      if(list2 != null && list2.size() > 0 && !list2.isEmpty()){    
 for(AggregateResult agrt:list2){
 Assetidmap1.put((Id)agrt.get('AccountId'), (Date)agrt.get('startdate'));
 }
 }
    For(Asset Ast: [select id,Is_Bundled__c,AccountId from Asset where AccountId IN:Assetidmap1.keyset() and Is_Bundled__c = True and Start_Date__c IN:Assetidmap1.values() and Product_code__c =:pset and Id Not IN:AsstMap.keyset() and Asset_Type__c = 'Parent' and Fulfillment_Status__c = 'Fulfilled' and status = 'Active']){
            Ast.Is_Bundled__c = False;
            listasset1.add(Ast);
        }
        //}
        System.debug('The AssetIds in the set are' + AsstUpdSet.size());
        System.debug('The AssetIds in the list are False ones' + listasset1.size());
        
           if(!listasset2.isEmpty()) {
            //AsstUpdList.addAll(AsstUpdSet);
            update listasset2;
        }
  if(!listasset1.isEmpty()) {
            update listasset1;
        }
Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'LegacyProsoftBundleFlagupdateAA%'];
     if(rcount<2){
     LegacyProsoftBundleFlagupdate p = new LegacyProsoftBundleFlagupdate();
                Datetime dtt = System.now().addMinutes(2).addSeconds(10);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('LegacyProsoftBundleFlagupdateAAAAA'+dtt, sch, p);
     }
}
}