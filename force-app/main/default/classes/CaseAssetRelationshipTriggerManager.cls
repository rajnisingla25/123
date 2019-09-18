//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: CaseAssetRelationshipTrigger
// On SObject: Case_Asset_Relationship__c
// Trigger Handler: CaseAssetRelationshipTriggerHandler
// Trigger Manager: CaseAssetRelationshipTriggerManager
//
// Description: This trigger has the following pusposes:
//  Purpose 1: The Asset.At_Risk__c field should be enabled/disabled based on the following scenarios:
//    Enable Asset.At_Risk__c checkbox
//      One or more Case Asset Relationship records exist where the case has the following criteria:
//        Case.Status <> 'Closed'
//        Case.Type__c = 'Retention'
//    Disable Asset.At_Risk__c checkbox
//      If no Case Asset Relationship records exist where the case meets the criteria described above.
//      Deletion of the Case Asset Relationship record.
//
// 29th May    2015     Hemendra Singh Bhati   Original (Task # T-380907)
// 14th June   2015     Kalyan Meda            Created Method updateAtRiskAmountPerAssetAndRollUpToCaseonAfterInsertUpdate()
// 18th June   2018     Pallavi Tammana        CRM-4125: Populating Asset 'Total Net' on 'Case Asset Relationship' from associated 'Asset'.



public without sharing class CaseAssetRelationshipTriggerManager {
    /*
@method      : updateAssetRiskFlagOnAfterInsertUpdateDelete
@description : Updates asset field "At_Risk__c" for all the scenarios mentioned in the description above.
@params      : Map<Id, Case_Asset_Relationship__c> newMap, Map<Id, Case_Asset_Relationship__c> oldMap, Boolean isInsert,
: List<Case_Asset_Relationship__c> old
@returns     : void
*/
    
    public void updateAssetRiskFlagOnAfterInsertUpdateDelete(Map<Id, Case_Asset_Relationship__c> newMap, Map<Id, Case_Asset_Relationship__c> oldMap,
                                                             Boolean isInsert, List<Case_Asset_Relationship__c> old) {
                                                                 // Processing Newly Inserted/Updated/Deleted Case Asset Relationship Records.
                                                                 Set<Id> theAssetIds = new Set<Id>();
                                                                 Set<Id> theCaseIds = new Set<Id>();
                                                                 
                                                                 if(newMap != null) {
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - Case Asset Relationship Records Inserted/Updated.');
                                                                     for(Case_Asset_Relationship__c theRelationship : newMap.values()) {
                                                                         // Case Asset Relationship Inserted.
                                                                         if(isInsert && theRelationship.Asset__c != null) {
                                                                             theAssetIds.add(theRelationship.Asset__c);
                                                                         }
                                                                         // Case Asset Relationship Updated.
                                                                         else if(!isInsert) {
                                                                             // Asset Updated.
                                                                             if(oldMap.get(theRelationship.Id).Asset__c != theRelationship.Asset__c) {
                                                                                 // Keeping Track Of Old Asset.
                                                                                 if(oldMap.get(theRelationship.Id).Asset__c != null) {
                                                                                     theAssetIds.add(oldMap.get(theRelationship.Id).Asset__c);
                                                                                 }
                                                                                 // Keeping Track Of New Asset.
                                                                                 if(theRelationship.Asset__c != null) {
                                                                                     theAssetIds.add(theRelationship.Asset__c);
                                                                                 }
                                                                             }
                                                                             
                                                                             // Case Updated.
                                                                             if(oldMap.get(theRelationship.Id).Case__c != theRelationship.Case__c) {
                                                                                 // Keeping Track Of Old Case.
                                                                                 if(oldMap.get(theRelationship.Id).Case__c != null) {
                                                                                     theCaseIds.add(oldMap.get(theRelationship.Id).Case__c);
                                                                                 }
                                                                                 // Keeping Track Of New Case.
                                                                                 if(theRelationship.Case__c != null) {
                                                                                     theCaseIds.add(theRelationship.Case__c);
                                                                                 }
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                                 else {
                                                                     // Processing Recently Deleted Case Asset Relationship Records.
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - Case Asset Relationship Records Deleted.');
                                                                     for(Case_Asset_Relationship__c theRelationship : old) {
                                                                         if(theRelationship.Asset__c != null) {
                                                                             theAssetIds.add(theRelationship.Asset__c);
                                                                         }
                                                                     }
                                                                 }
                                                                 system.debug('TRACE: CaseAssetRelationshipTriggerManager - theAssetIds - ' + theAssetIds);
                                                                 system.debug('TRACE: CaseAssetRelationshipTriggerManager - theCaseIds - ' + theCaseIds);
                                                                 
                                                                 // Processing Cases Updated In Case Asset Relationship Records.
                                                                 if(theCaseIds.size() > 0) {
                                                                     for(Case_Asset_Relationship__c theRelationship : [SELECT Asset__c FROM Case_Asset_Relationship__c WHERE Case__c IN :theCaseIds
                                                                                                                       AND Asset__c != null]) {
                                                                                                                           theAssetIds.add(theRelationship.Asset__c);
                                                                                                                       }
                                                                     theCaseIds.clear();
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - theAssetIds - ' + theAssetIds);
                                                                 }
                                                                 
                                                                 // Extracting Cases For Assets Filtered Above.
                                                                 if(theAssetIds.size() > 0) {
                                                                     theCaseIds = new Set<Id>();
                                                                     Map<Id, Set<Id>> theAssetCaseMapping = new Map<Id, Set<Id>>();
                                                                     for(Case_Asset_Relationship__c theRelationship : [SELECT Asset__c, Case__c FROM Case_Asset_Relationship__c WHERE Asset__c IN :theAssetIds
                                                                                                                       AND Case__c != null]) {
                                                                                                                           theCaseIds.add(theRelationship.Case__c);
                                                                                                                           if(!theAssetCaseMapping.containsKey(theRelationship.Asset__c)) {
                                                                                                                               theAssetCaseMapping.put(theRelationship.Asset__c, new Set<Id>());
                                                                                                                           }
                                                                                                                           theAssetCaseMapping.get(theRelationship.Asset__c).add(theRelationship.Case__c);
                                                                                                                       }
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - theCaseIds - ' + theCaseIds);
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - theAssetCaseMapping - ' + theAssetCaseMapping);
                                                                     
                                                                     // Extracting Cases Where Status != 'Closed' And Type = 'Retention'.
                                                                     Set<Id> theOpenRetentionCasesIds = new Set<Id>();
                                                                     if(theCaseIds.size() > 0) {
                                                                         for(Case theCase : [SELECT Id FROM Case WHERE Id IN :theCaseIds AND Status != 'Closed' AND Type = 'Retention']) {
                                                                             theOpenRetentionCasesIds.add(theCase.Id);
                                                                         }
                                                                     }
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - theOpenRetentionCasesIds - ' + theOpenRetentionCasesIds);
                                                                     
                                                                     // Determining Assets At Risk.
                                                                     Set<Id> theAssetsAtRisk = new Set<Id>();
                                                                     if(theOpenRetentionCasesIds.size() > 0) {
                                                                         for(Id theCaseId : theOpenRetentionCasesIds) {
                                                                             for(Id theAssetId : theAssetCaseMapping.keySet()) {
                                                                                 if(theAssetCaseMapping.get(theAssetId) != null && theAssetCaseMapping.get(theAssetId).contains(theCaseId)) {
                                                                                     theAssetsAtRisk.add(theAssetId);
                                                                                 }
                                                                             }
                                                                         }
                                                                     }
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - theAssetsAtRisk - ' + theAssetsAtRisk);
                                                                     
                                                                     Asset theAsset = null;
                                                                     Map<Id, Asset> toBeUpdated = new Map<Id, Asset>();
                                                                     
                                                                     for(Id theAssetId : theAssetCaseMapping.keySet()) {
                                                                         theAsset = new Asset(Id = theAssetId);
                                                                         if(theAssetsAtRisk.contains(theAssetId)) {
                                                                             theAsset.At_Risk__c = true;
                                                                         }
                                                                         else {
                                                                             theAsset.At_Risk__c = false;
                                                                         }
                                                                         toBeUpdated.put(theAssetId, theAsset);
                                                                     }
                                                                     
                                                                     for(Id theAssetId : theAssetIds) {
                                                                         if(!theAssetCaseMapping.containsKey(theAssetId) && !toBeUpdated.containsKey(theAssetId)) {
                                                                             toBeUpdated.put(theAssetId, new Asset(
                                                                                 Id = theAssetId,
                                                                                 At_Risk__c = false
                                                                             ));
                                                                         }
                                                                     }
                                                                     system.debug('TRACE: CaseAssetRelationshipTriggerManager - toBeUpdated - ' + toBeUpdated);
                                                                     
                                                                     // Updating Assets.
                                                                     if(toBeUpdated.size() > 0) {
                                                                         //SkipAssetTrigger.setSkipTrgTrue(); 
                                                                         update toBeUpdated.values();
                                                                     }
                                                                 }
                                                             }
    /*
@method      : updateduplicateflagonCAR
@description : updates the CAR based on the Duplicate Asset
@params      : Map<Id, Case_Asset_Relationship__c> newMap,  Boolean isInsert
@returns     : void
*/
    public void updateduplicateflagonCAR(Map<Id,Case_Asset_Relationship__c> lstCA, Map<Id, Case_Asset_Relationship__c> oldMap,Boolean isInsert) {
        Map<Id,Date>AssetstartDatesMap = new Map<Id,Date>();
        Map<Id,Date>AssetendDatesMap = new Map<Id,Date>();
        Map<Id,Id>CARAssetMap = new Map<Id,Id>();
        Map<Id,Id>CaseMap = new Map<Id,Id>();
        set<Id> sAssetId = new set<Id>();
        set<Id> sAssetIds = new set<Id>();
        List<Case_Asset_Relationship__c>UpdateCarlist = new List<Case_Asset_Relationship__c>();   
        
        for(Case_Asset_Relationship__c theRelationship : lstCA.values()) {
            if(isInsert && theRelationship.Asset__c!=null && theRelationship.Case__c!=null){
                System.debug('cominghere venu' +theRelationship.Asset__c);
                sAssetId.add(theRelationship.Asset__c);
            AssetstartDatesMap.put(theRelationship.Asset__c,theRelationship.Asset_Start_Date__c);
            AssetendDatesMap.put(theRelationship.Asset__c,theRelationship.Asset_End_Date__c);
            CARAssetMap.put(theRelationship.Asset__c,theRelationship.Id);
            CaseMap.put(theRelationship.Case__c,theRelationship.Id);
            }
        }
        System.debug('CAR***Ravilla***Debug*'+AssetstartDatesMap.values() + 'End date'+AssetendDatesMap.values()+ 'New Case'+CaseMap);
        List<Case_Asset_Relationship__c> carlist = [Select Id,Asset__c,CreatedDate,Case__c,Previous_CAR_Exists_For_This_Term__c from Case_Asset_Relationship__c where Asset__c IN:sAssetId and Case__r.status = 'Closed' and Case__r.Type ='Retention'];
        System.debug('The case Asset relationship Count' +carlist);
        if(carlist.size()>0 || test.isRunningTest()){
            for(Case_Asset_Relationship__c car:carlist){  
                System.debug('CAR Coming here***Ravilla***Debug*'+AssetstartDatesMap.values() + 'End date'+AssetendDatesMap.values()+ 'New Case'+CaseMap);
                If(!CaseMap.containskey(car.Case__c) && car.Createddate  >= AssetstartDatesMap.get(car.Asset__c) && car.Createddate  <= AssetendDatesMap.get(car.Asset__c)){
                    sAssetIds.add(car.Asset__c);
                }              
            }
            if(!sAssetIds.isEmpty()){
                System.debug('TheValueComingHere**Venu'+sAssetIds.size());
                for(Id AssetId:sAssetIds){
                    If(CARAssetMap.containskey(AssetId)){
                        Case_Asset_Relationship__c car = new Case_Asset_Relationship__c(Id = CARAssetMap.get(AssetId));
                        car.Previous_CAR_Exists_For_This_Term__c=true;
                        UpdateCarlist.add(car);
                    }
                }
            }
        }
        System.debug('The Final Update List Size is ' +UpdateCarlist.size());
        If(!UpdateCarlist.isEmpty())
            update UpdateCarlist;
    }
    
    
    /*
@method      : updateAtRiskAmountPerAssetAndRollUpToCaseonAfterInsertUpdate
@description : Calculates the At risk Amount for the asset based on the product of daily rate and days remaining on the asset and update the value on 
Jn obj record
@params      : Map<Id, Case_Asset_Relationship__c> newMap,  Boolean isInsert
@returns     : void
@History     : CRM-4125: Populating Asset 'Total Net' on 'Case Asset Relationship' from associated 'Asset'.
*/
    
    public void updateAtRiskAmountPerAssetAndRollUpToCaseonAfterInsertUpdate(List<Case_Asset_Relationship__c> lstCA, Map<Id, Case_Asset_Relationship__c> newMap, Boolean isInsert){                                           
        
        // Processing Newly Inserted/Updated/Deleted Case Asset Relationship Records.
        system.debug('########newMap'+lstCA);
        
        if(isInsert == true){   
            set<Id> sAssetId = new set<Id>();
            Map<Id, Decimal> mapAtRisk = new Map<Id, Decimal>();
            Map<Id, Decimal> mapTotalNet = new Map<Id, Decimal>();
            
            for(Case_Asset_Relationship__c theRelationship : lstCA) {
                sAssetId.add(theRelationship.Asset__c);
            }
            
            // Calculate the At risk amount for each CAR record.
            if(!sAssetId.isEmpty()){
                List<Asset> lstAsset = [select id, End_Date__c,start_date__c, Daily_Rate__c,Renewal_Price__c ,Total_Net__c, Renewal_Start_Date__c  from Asset where id in: sAssetId];
                for(Asset ast: lstAsset){
                    if(ast.End_Date__c != null){      
                        Integer intDateDifference =  system.today().daysBetween(ast.End_Date__c );
                        Integer startendDateDifference = ast.start_date__c.daysBetween(ast.End_Date__c );
                        
                        system.debug('## intDateDifference: ' + intDateDifference);
                        if(ast.Daily_Rate__c != null){ 
                            // Commented by Stan - Daily Rate is now a formula field
                            //ast.Daily_Rate__c = ast.Total_Net__c/(startendDateDifference+1);
                            
                            Decimal intAtRisk = Integer.valueOf(ast.Daily_Rate__c*(intDateDifference +1));
                            
                            // Check if the asset has been renewed already which will cause the Risk amount to shoot up by the renewal price
                            //  if (ast.End_Date__c != null && ast.Renewal_Start_Date__c!= null){
                            //    if(( ast.End_Date__c.daysBetween(ast.Renewal_Start_Date__c))>=0){
                            //     intAtRisk += ast.Renewal_Price__c;
                            
                            //    }
                            //  }
                            
                            mapAtRisk.Put(ast.id, intAtRisk);
                            
                            
                        }
                    }
                    //CRM-4125: Populating Asset 'Total Net' on 'Case Asset Relationship' from associated 'Asset'.
                    if(ast.Total_Net__c != null) {
                        mapTotalNet.put(ast.Id, ast.Total_Net__c);
                    }                   
                }
            }            
            for(Case_Asset_Relationship__c theRelationship : lstCA) {
                if(mapAtRisk.containskey(theRelationship.Asset__c) && mapAtRisk.get(theRelationship.Asset__c) != null){
                    
                    theRelationship.At_Risk_Amount__c = mapAtRisk.get(theRelationship.Asset__c);
                    
                }
                //CRM-4125: Populating Asset 'Total Net' on 'Case Asset Relationship' from associated 'Asset'.
                if(mapAtRisk.containskey(theRelationship.Asset__c) && mapAtRisk.get(theRelationship.Asset__c) != null){
                    
                    theRelationship.Assets_Total_Net__c = mapTotalNet.get(theRelationship.Asset__c);
                    
                }
                
            }
        }
        
        
        if(newMap != null) {
            system.debug('TRACE: CaseAssetRelationshipTriggerManager - Case Asset Relationship Records Inserted/Updated.');
            List<Case_Asset_Relationship__c> caseAssetRelationships = [Select Id,Asset__r.Daily_Rate__c, Asset__r.End_Date__c from Case_Asset_Relationship__c where Id IN:newMap.keyset()];
            system.debug('## caseAssetRelationships : ' + caseAssetRelationships);
            for(Case_Asset_Relationship__c theRelationship : caseAssetRelationships) {
                system.debug('### theRelationship: ' + theRelationship.Id);
                // Case Asset Relationship Inserted.
                // if(isInsert && theRelationship.Asset__c != null) {
                //theAssetIds.add(theRelationship.Asset__c);
                // }  
                system.debug('### theRelationship:Asset: ' + theRelationship.Asset__c);
                system.debug('### theRelationship:Asset.End Date : ' + theRelationship.Asset__r.End_Date__c);
                if(theRelationship.Asset__r.End_Date__c != null){      
                    Integer intDateDifference =  system.today().daysBetween( theRelationship.Asset__r.End_Date__c );
                    system.debug('## intDateDifference: ' + intDateDifference);
                    if(theRelationship.Asset__r.Daily_Rate__c != null){        
                        newMap.get(theRelationship.Id). At_Risk_Amount__c = intDateDifference * theRelationship.Asset__r.Daily_Rate__c;
                        
                        
                    }
                }           
            }
        }
    }
}