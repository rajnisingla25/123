//Name        : AutoRenewalQuoteCreationBatchNew
//Description : This Batch creates quote for all auto renewable assets which are due for renewal in the following month.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteCreationBatchNew implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    global String Query;
    global String assetId;
    global set<ID> AccountIDs = new set<ID>();
    global Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
    global boolean submitAutoRenew = false;
    global String sessionId;
    global Date startDate;
    global Date endDate;
     
    
    global AutoRenewalQuoteCreationBatchNew(set<ID> AcctIDs,Map<Id,Id> mapAccntOpptyId){
        AccountIDs.addall(AcctIDs);
        mapAccountOpportunityId.putAll(mapAccntOpptyId);
        System.debug('AccountIDs:'+AccountIDs);            
        System.debug('mapAccountOpportunityId:'+mapAccountOpportunityId);
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }
                             
    }
    global String session(String user, String pwd) {
        if(sessionId == null) {
            WebserviceCallBigMachineQuoteCls wcbm = new WebserviceCallBigMachineQuoteCls();
            sessionId = wcbm.GetSessionId(null,null);
            System.debug('sessionId:'+sessionId);
        }
        return sessionId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('$$$$$$ AccountIDs:'+AccountIDs);
        Query = 'SELECT ID, Account.OwnerId FROM Account WHERE ID IN :AccountIDs ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Asset> lstupdateAsset = new List<Asset>();
        Map<Id,String> AssetIds = New Map<Id,String>();
        Set<Asset> updateAsstSet = new Set<Asset>();
        Set<Asset> AsstSet = new Set<Asset>();
        List<AutoRenewal__c> Exclusionlst = AutoRenewal__c.getAll().values();
        Set<AutoRenewal__c> Exclusionset = New Set<AutoRenewal__c>(Exclusionlst);
        String AcctOwnrPrfNm = [Select Id, Profile_Name__c from User Where Id = :scope[0].OwnerId].Profile_Name__c;
        Map<Id,String> AcctAsstIds = New Map<Id,String>();
        Set<Id> AsstIdSet = new Set<Id>();
                
        List<Asset> AssetData = [SELECT id, name, Parent_Asset__c, AccountId, Account.OwnerId, Product2Id, 
                                 Product2.ProductCode, Status, Product2.Orderable__c,Asset_Stage__c, Quantity, 
                                 Follow_Up_Status__c, Auto_Renewal__c, BOP_Code__c, Email__c,End_Date__c, Lead_Type__c, 
                                 Line_Type__c, List_Price__c, Market_Zip__c,Market__c, Market_Tier__c, Renewal_Type__c,
                                 Ultimate_Parent__c, Last_Order_Activity_Date__c, Start_Date__c, Total_Net__c, KickoutReason__c
                                 FROM Asset WHERE Asset_Type__c='Parent' AND Status = 'Active' AND 
                                 (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')   
                                 AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                 AND Account.Account_Sub_Type__c='Customer' AND Account.Auto_Renewal__c=true
                                 AND Product2.Auto_Renewal__c =true AND End_Date__c >=: startDate AND End_Date__c <=: endDate 
                                 AND AccountId = :scope[0].ID AND (not Inflight_Quote__c like '%Renew%') ORDER BY AccountId];
        System.debug('AssetData:'+AssetData);
        System.debug('startDate:'+startDate);
        System.debug('endDate:'+endDate);
        session(null,null); 
        System.debug('sessionId:'+sessionId);      
        
        for(Asset Assetloop : AssetData) {
            if(!AcctAsstIds.containsKey(Assetloop.AccountId)) {
                if(Assetloop.Product2.Orderable__c) { // CRM-1649: Added condition to include Zero Dollar Asset for SellerLead
                    if((Assetloop.Total_Net__c != 0  || Assetloop.Product2.ProductCode == 'FIVESTREET' || Assetloop.Product2.ProductCode =='SELLERLEADBUNDLE')) {
                        System.debug('AcctOwnrPrfNm:'+AcctOwnrPrfNm);
                        AutoRenewal__c Exclusions = AutoRenewal__c.getInstance(AcctOwnrPrfNm);
                        System.debug('Exclusions:'+Exclusions);
                        //Verifying Product Exclusions using Custom Settings                       
                        If(Exclusions != NULL && Exclusions.ProductCodes__c != NULL){
                            if(!Exclusions.ProductCodes__c.contains(Assetloop.Product2.ProductCode)){
                                AsstSet.add(Assetloop);
                                System.debug('AsstSet:'+AsstSet);
                            }else{
                                Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                                Assetloop.AutoRenewalPicked__c = true;
                                Assetloop.Renewal_Type__c = 'Manual';
                                Assetloop.KickoutReason__c = 'Product Not orderable';
                                updateAsstSet.add(Assetloop);
                                AcctAsstIds.put(Assetloop.AccountId,'');
                                AsstIdSet.add(Assetloop.Id);
                                System.debug('AsstIdSet:'+AsstIdSet);
                                System.debug('AcctAsstIds:'+AcctAsstIds);
                            }                            
                        }else{                           
                            AsstSet.add(Assetloop);
                            System.debug('AsstSet:'+AsstSet);
                        }
                    }else{
                        Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                        Assetloop.AutoRenewalPicked__c = true;
                        Assetloop.Renewal_Type__c = 'Manual';
                        Assetloop.KickoutReason__c = 'Zero Dollar Asset';
                        updateAsstSet.add(Assetloop);
                        AcctAsstIds.put(Assetloop.AccountId,'');
                        AsstIdSet.add(Assetloop.Id);
                    }
                }else{
                    Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                    Assetloop.AutoRenewalPicked__c = true;
                    Assetloop.Renewal_Type__c = 'Manual';
                    Assetloop.KickoutReason__c = 'Product Not orderable';
                    updateAsstSet.add(Assetloop);
                    AcctAsstIds.put(Assetloop.AccountId,'');
                    AsstIdSet.add(Assetloop.Id);
                    System.debug('AsstIdSet:'+AsstIdSet);
                    System.debug('AcctAsstIds:'+AcctAsstIds);
                }
            }
        }
        
        System.debug('AcctAsstIds:'+AcctAsstIds);
        for(Asset Assetloop: AsstSet) {
            if(!AcctAsstIds.containsKey(Assetloop.AccountId)){
                AssetIds.put(Assetloop.id,'');
                Assetloop.AutoRenewalPicked__c = true;
                Assetloop.Renewal_Type__c = 'Auto';
                if(Assetloop.Last_Order_Activity_Date__c == null)
                   Assetloop.Last_Order_Activity_Date__c =  Assetloop.Start_Date__c;
                updateAsstSet.add(Assetloop);
            }
            System.debug('updateAsstSet:'+updateAsstSet);
        }
                       
        System.debug('AssetIds:'+AssetIds);
        //Create Quote
        if (!Test.isRunningTest() && !AssetIds.isEmpty()){
            WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
            System.debug('sessionId:'+sessionId);
            if(sessionId != null)
                wscbm.bmsessionid = sessionId;
            wscbm.CreateQuote(null,null,scope[0].ID,mapAccountOpportunityId.get(scope[0].ID),null,'Auto-Renew','renew',true,false,AssetIds);
        }
        
        //Update Assets for manual Renewals
        if(!updateAsstSet.isEmpty()){
            lstupdateAsset.addall(updateAsstSet);
            update lstupdateAsset;
            if(!AcctAsstIds.isEmpty())
                autoExcludeAcct(AcctAsstIds,AsstIdSet);
                System.debug('AsstIdSet:'+AsstIdSet);
        } 
                
        
    }
    
    public static void autoExcludeAcct(Map<Id,String> mapAccountId, Set<Id> AsstSetIds) {
        List<Asset> updateAsstList = new List<Asset>();
        Set<Asset> updateAsstSet = new Set<Asset>();
        Date startDate;
        Date endDate;
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }
        //CRM-1752: Updated End Date condition to check for custom dates in Query.
        //CRM-1305 - Auto Renew Quote creation job sets Non AR assets to Manual Renewal
        List<Asset> AsstList = [Select Id, Follow_Up_Status__c, AutoRenewalPicked__c, Renewal_Type__c, KickoutReason__c from Asset where AccountId IN: mapAccountId.keySet() AND Id NOT IN: AsstSetIds AND Fulfillment_Status__c = 'Fulfilled' AND (not Inflight_Quote__c like '%Renew%') AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution') AND Asset_Type__c='Parent' AND Status = 'Active' AND Product2.Auto_Renewal__c =true AND End_Date__c >=: startDate AND End_Date__c <=: endDate];  
        if(!AsstList.isEmpty()) {
            for(Asset asst: AsstList){
                asst.Follow_Up_Status__c = 'Manual Renewal';
                asst.AutoRenewalPicked__c = true;
                asst.Renewal_Type__c = 'Manual';
                asst.KickoutReason__c = 'Forced Manual Renewal';
                updateAsstSet.add(asst);       
            }
        }
        
        //Update Assets for manual Renewals
        if(!updateAsstSet.isEmpty()){
            updateAsstList.addall(updateAsstSet);
            update updateAsstList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('startDate:'+startDate);
        System.debug('endDate:'+endDate);
        List<Asset> AssetList = [SELECT id FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%') 
                               AND Account.Account_Sub_Type__c='Customer' AND Account.Auto_Renewal__c=true AND Product2.Auto_Renewal__c =true
                               AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                               AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')   
                               AND End_Date__c >=: startDate AND End_Date__c <=: endDate];
        //Scheduling further Jobs to process remaining records.                       
        if(!AssetList.isEmpty()) {       
            AutoRenewalQuoteCreationSchedulable ARschBatch = new AutoRenewalQuoteCreationSchedulable();
            Datetime dtt = System.now().addMinutes(2);
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('AutoRenewalBatchJobRecAR'+dtt, sch, ARschBatch);
        } else { //Scheduling Job to delete Oversold QuoteProducts          
            AutoRenewalQuoteProdDeletionBatchSch delBatch = new AutoRenewalQuoteProdDeletionBatchSch();
            Datetime dtt1 = System.now().addMinutes(3);
            String sch1 = dtt1.Second()+' '+dtt1.Minute()+' '+dtt1.hour()+' '+dtt1.day()+' '+dtt1.Month()+' ? '+dtt1.year();
            system.schedule('AutoRenewalBatchJobDelARQ'+dtt1, sch1, delBatch);                               
        }
        
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'AutoRenewalBatchJob%' and State = 'DELETED' and nextfiretime = null limit 10];
        If (listCronTriggerAsset.size() > 0) {
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++) { System.abortJob(listCronTriggerAsset[i].Id); }
        }                     
        
    }
}