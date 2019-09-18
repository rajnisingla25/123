/*****************************************************************************
 * Class Name: batchToUpdateAllActiveAssetsToActiveMLS
 * Author: Srinivas Vadla
 * Purposes: This batch will be used to move active assets from Inactive MLS Set to Active MLS Set
 * JIRA : CRM-1248 and CRM-1249
 ****************************************************************************/
// global class batchToUpdateAllActiveAssetsToActiveMLS implements Database.Batchable<sObject>,schedulable{
global class batchToUpdateAllActiveAssetsToActiveMLS implements Database.Batchable<sObject>{
    global batchToUpdateAllActiveAssetsToActiveMLS(){
    }
    
    /****Global start method starts *********************************
     checking the asset records if their related MLS records are having status Inactive and Type !=Office then collecting them for investigation
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
      String query='Select id,name,MLS_Set__c,MLS_Set__r.name,MLS_Set__r.Status__c,MLS_Set__r.Office__c from Asset where status =\'Active\' and MLS_Set__c<>null and MLS_Set__c<>\'\' and (MLS_Set__r.Status__c=\'Inactive\' OR MLS_Set__r.Status__c=\'Active\') AND asset_type__c = \'participant\'';
      system.debug('query'+query);
      return Database.getQueryLocator(query);
   } 

 
    /****Global execute method starts **********************************/
   global void execute(Database.BatchableContext BC, List<Asset> assetRecords){
         /****Global Variable Declaration starts **********************************/
         Map<String,set<Asset>> globalMapForAssetData=new Map<String,set<Asset>>();
         Map<String,set<Asset>> globalMapForAssetDatanew=new Map<String,set<Asset>>();
         List<Asset> updatedList=new List<Asset>();
          /****Global Variable Declaration ends **********************************/
         try{
                /*
                 iterating the asset list and putting them into a unique map where each element will be <MLS Account ID,Set<Asset>>
                 */ 
                 system.debug('###assetRecords###'+assetRecords);
                 for(asset s : assetRecords){
                    if(s.MLS_Set__r.Status__c == 'Inactive'){
                        if(globalMapForAssetData!=null && globalMapForAssetData.containsKey(s.MLS_Set__r.name)){
                            globalMapForAssetData.get(s.MLS_Set__r.name).add(s);
                        }
                        else if(globalMapForAssetData!=null && !globalMapForAssetData.containsKey(s.MLS_Set__c)){
                            globalMapForAssetData.put(s.MLS_Set__r.name,new Set<Asset>{s});
                        }
                    }
                    else if(s.MLS_Set__r.Status__c == 'Active'&& s.MLS_Set__r.Office__c == Null ){
                        if(globalMapForAssetDatanew!=null && globalMapForAssetDatanew.containsKey(s.MLS_Set__r.name)){
                            globalMapForAssetDatanew.get(s.MLS_Set__r.name).add(s);
                        }
                        else if(globalMapForAssetDatanew!=null && !globalMapForAssetDatanew.containsKey(s.MLS_Set__c)){
                            globalMapForAssetDatanew.put(s.MLS_Set__r.name,new Set<Asset>{s});
                        }                       
                    }
                 }
                    system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Got the Asset Map as '+globalMapForAssetData);
                    Map<String,Id> mlsDataRecords=new Map<String,Id>();
                    Map<String,Id> mlsDataRecordsnew=new Map<String,Id>();
                    /*
                    collecting MLS records  
                    */
                    for(MLS__c mls: [Select id ,name from MLS__c where Status__c='Active' and name in: globalMapForAssetData.keySet() limit 50000]){
                        if(mls!=null)
                        mlsDataRecords.put(mls.name,mls.id);
                    }
                    for(MLS__c mls: [Select id ,name from MLS__c where Status__c='Active' and Office__c!= Null and name in: globalMapForAssetDatanew.keySet() limit 50000]){
                        if(mls!=null)
                        mlsDataRecordsnew.put(mls.name,mls.id);
                    }
                    system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Got the MLS Map as '+mlsDataRecords);
                    
                    /*
                    updating Asset records and collecting into a list for updation.  
                    */
                    if(!mlsDataRecords.isEmpty()){
                       for(asset s : assetRecords){
                            if(s.MLS_Set__c!=null && mlsDataRecords.get(s.MLS_Set__r.name)!=Null && s.MLS_Set__r.Status__c =='Inactive'){
                                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mlsDataRecords.get(s.MLS_Set__r.name));
                                s.MLS_Set__c = mlsDataRecords.get(s.MLS_Set__r.name);
                                }
                            if(s.MLS_Set__c!=null && mlsDataRecordsnew.get(s.MLS_Set__r.name)!=Null && s.MLS_Set__r.Status__c =='Active' && s.MLS_Set__r.Office__c == Null){
                                s.MLS_Set__c = mlsDataRecordsnew.get(s.MLS_Set__r.name);
                            }
                                updatedList.add(s);
                                 system.debug('@@@@@@@@@@@@@@@@@@@@@@@@updatedList'+ updatedList);
                            
                        } 
                    }
                    
                    
                    system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@final list will be updated is'+updatedList);
                    /* 
                    updating the Assets...
                    */
                    if(!updatedList.isEmpty()){
                        Database.saveResult[] sr=DataBase.update(updatedList,false);
                        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@updation result is'+sr);
                    }
                    throw new NullPointerException();
         } 
         catch(Exception ex){
             system.debug('@@@@@@@@@@@@@@@@@@@@@@@@Exception happened'+ex.getStackTraceString()+'Line number'+ex.getLineNumber());
         }
         

   }
    /****Global finish method starts **********************************/
   global void finish(Database.BatchableContext BC){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch finished');
   }
   

}