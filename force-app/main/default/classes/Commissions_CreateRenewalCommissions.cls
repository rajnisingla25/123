/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   06-MAY-2015
Usage           :   This main functionality of  this class is to create commission records (New Commissions)
                    from asset record based on the business logic
                      * Create commissions to signing AE ,Asset owner and their managers
                      * Create commissions for LOA
                      * Create commissions for Open Book/Open Sale
                      * Create New Sale Commissions-For New and Legacy assets
CODE MODIFICATION DETAILS :
1. Modified By  :   Srinivas Pendli on 7-JUNE-2016 //ADDED code comments
5. Modified By  :   Srinivas Pendli on 10-Dec-2016 @ JIRA # 708 //Removed all Manager Commissions logic.
********************************************************************************/
Public Class Commissions_CreateRenewalCommissions{ 
    Public void CreateCommissions(Map<id,asset> fullfilledAssets){       
        Map<id,Asset> assetsCreateNewCommissionsRenewals = new Map<id,Asset>();
        DateTime assetCreatedDateDate ; 
        //IDENTIFYING NEW COMMISSIONS,RENEWAL COMMISSIONS,CLAW BACK COMMISSIONS,DOWNFRADE COMMISSIONS AND UPGRADE COMMISSIONS
        for(Asset Assets : fullfilledAssets.Values()){                    
            assetCreatedDateDate = Assets.Start_Date__c;      
            if(assetCreatedDateDate.day() == 1){
                assetCreatedDateDate = assetCreatedDateDate.addHours(8);
            }            
            //AFTER GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate >= Date.newInstance(2016,02,01)){
                if(Assets.Line_Type__c == 'Renew'){ 
                    assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);                 
                }            
            }            
            //BEFORE GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate <= Date.newInstance(2016,02,01)){
                if(Assets.Line_Type__c == 'Renew'){ 
                    assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);                     
                }               
            }                      
        }        
        system.debug('assetsCreateNewCommissionsRenewals $$ :'+assetsCreateNewCommissionsRenewals); 
        //SENDING COLLECTED ASSETS TO 'Commissions_CreateNewCommissionsHandler' CLASS TO CREATE NEW COMMISSIONS
        if(assetsCreateNewCommissionsRenewals.size() > 0){
            system.debug('New Sale - Renewal $$ :'+assetsCreateNewCommissionsRenewals);
            Commissions_CreateNewCommissionsHandler commission = new Commissions_CreateNewCommissionsHandler();
            commission.CreateCommissions(assetsCreateNewCommissionsRenewals);
        }
    }        
}