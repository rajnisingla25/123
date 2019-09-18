//Name        : ARIIManualrun
//Description : Manual Job for all Auto Renewal Phase II.
//Frequencey  : Manual for Testing
//Author      : Pallavi Tammana
//History     : CRM-3875: Auto Renewal Manual Job for single Account(Controlled test)

public class ARIIManualrun {

    public static void ARAssetmethod(id accountid){  
        
        Set<Id> setAccountId = new Set<Id>();           
        setAccountId.add(accountid);
        ARAssetUpdate(setAccountId);
    
    }
    
    public static void ARNightlymethod(id accountid){
    
        
        Set<Id> setAccountId = new Set<Id>();
        setAccountId.add(accountid);
        ARNightlyUpdate(setAccountId);
    
    }
    
    public static void ARAssetUpdate(Set<Id> setAccountId){  
       
        List<Account> scope = [SELECT ID, Account.OwnerId FROM Account WHERE ID IN :setAccountId ORDER BY ID];
        
        //execute method
        Map<Id,String> AcctAsstIds = New Map<Id,String>();
        Set<Id> AsstIdSet = new Set<Id>();
        Set<Asset> AsstSet = new Set<Asset>();
        Set<Asset> updateAsstSet = new Set<Asset>();
        Map<Id,String> AssetIds = New Map<Id,String>();
        List<Date> AsstDtList = new List<Date>();
        Id AcctId;
        Set<Account> setUpdateAcct = new Set<Account>();
        List<Account> lstUpdateAcct = new List<Account>();
        List<Asset> lstupdateAsset = new List<Asset>();
        Map<Id, Asset_AR_Association__c> ARIdMap = new Map<Id, Asset_AR_Association__c>();
        List<Asset_AR_Association__c> ARNewList = new List<Asset_AR_Association__c>();
        Map<Id, String> AsstIdMap = new Map<Id, String>();
        Date startDate;
        Date endDate;
        
        List<AutoRenewal__c> Exclusionlst = AutoRenewal__c.getAll().values();
        Set<AutoRenewal__c> Exclusionset = New Set<AutoRenewal__c>(Exclusionlst);
        String AcctOwnrPrfNm = [Select Id, Profile_Name__c from User Where Id = :scope[0].OwnerId].Profile_Name__c;
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }
        
         List<Asset> AssetData = [SELECT id, name, External_ID__c, Parent_Asset__c, AccountId, Account.OwnerId, Product2Id, 
                                 AR_Total_Discount__c, Product2.AR_Max_Discount_Threshold__c,
                                 Product2.ProductCode, Status, Product2.Orderable__c, Asset_Stage__c, Quantity, 
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
        
        for(Asset Assetloop : AssetData) {
            if(!AcctAsstIds.containsKey(Assetloop.AccountId)) {
                if(Assetloop.Product2.Orderable__c) { // CRM-1649: Added condition to include Zero Dollar Asset for SellerLead
                    if((Assetloop.Total_Net__c != 0  || Assetloop.Product2.ProductCode == 'FIVESTREET' || Assetloop.Product2.ProductCode =='SELLERLEADBUNDLE')) {
                        System.debug('AcctOwnrPrfNm:'+AcctOwnrPrfNm);
                        AutoRenewal__c Exclusions = AutoRenewal__c.getInstance(AcctOwnrPrfNm);
                        System.debug('Exclusions:'+Exclusions);
                        if(Assetloop.AR_Total_Discount__c <= Assetloop.Product2.AR_Max_Discount_Threshold__c) {
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
                            Assetloop.KickoutReason__c = 'High Discount Asset';
                            updateAsstSet.add(Assetloop);
                            AcctAsstIds.put(Assetloop.AccountId,'');
                            AsstIdSet.add(Assetloop.Id);
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
                       
        System.debug('assetIds:'+assetIds);
        for(Asset Assetloop: AsstSet) {
            if(!AcctAsstIds.containsKey(Assetloop.AccountId)){
                AssetIds.put(Assetloop.id,'');
                Assetloop.AutoRenewalPicked__c = true;
                Assetloop.Renewal_Type__c = 'Auto';
                if(Assetloop.Last_Order_Activity_Date__c == null)
                   Assetloop.Last_Order_Activity_Date__c =  Assetloop.Start_Date__c;
                updateAsstSet.add(Assetloop);
                AsstIdMap.put(Assetloop.Id, Assetloop.External_ID__c );
            }
            System.debug('updateAsstSet:'+updateAsstSet);
        }
                       
        System.debug('AssetIds:'+AssetIds);
        if(!updateAsstSet.isEmpty()){
        for(Asset asst: updateAsstSet){
                AsstDtList.add(asst.End_Date__c);
                AcctId = asst.AccountId;
            }
            AsstDtList.sort();
            
            if(!AsstDtList.isEmpty()){
                Account acct = new Account();
                acct.Id = AcctId;
                acct.Asset_Earliest_End_Date__c = AsstDtList[0];
                setUpdateAcct.add(acct);
                AsstDtList.clear();
            }
        }
        //Update Assets for manual Renewals
        if(!updateAsstSet.isEmpty()){
            lstupdateAsset.addall(updateAsstSet);
            update lstupdateAsset;
            if(!AcctAsstIds.isEmpty())
                ARIIAssetUpdateBatch.autoExcludeAcct(AcctAsstIds,AsstIdSet);
                System.debug('AsstIdSet:'+AsstIdSet);
        } 
        if(!setUpdateAcct.isEmpty()){
            lstUpdateAcct.addall(setUpdateAcct);
            update lstUpdateAcct;
        }
        
        for(Asset_AR_Association__c AR: [Select Id, External_ID__c, Asset_Id__c, Asset_Id__r.External_ID__c from Asset_AR_Association__c where Asset_Id__c IN: AsstIdMap.keyset()]){
                ARIdMap.put(AR.Asset_Id__c, AR);                
        }
        
        if(!ARIdMap.isEmpty()){
            for(Id arId: AsstIdMap.keyset()){
                if(!ARIdMap.containsKey(arId)) {
                    Asset_AR_Association__c asstAR = new Asset_AR_Association__c();
                    asstAR.Asset_Id__c = arId;
                    asstAR.External_ID__c = AsstIdMap.get(arId);
                    ARNewList.add(asstAR);
                }
            }
        
        }
        else{
            for(Id arId: AsstIdMap.keyset()){
                Asset_AR_Association__c asstAR = new Asset_AR_Association__c();
                asstAR.Asset_Id__c = arId;
                asstAR.External_ID__c = AsstIdMap.get(arId);
                ARNewList.add(asstAR);
            }
            
        }
         if(!ARNewList.isEmpty())
            insert ARNewList;
    }
    //CRM-3875: Updated the below method to get the NightlyUpdate from CPQ.
    public static void ARNightlyUpdate(Set<Id> setAccountId){  
    
        List<Asset> AsstUpdList = new List<Asset>();
        Map<Id, String> AcctbmqIdMap = new Map<Id, String>();
        Set<Id> AsstIdSet = new Set<Id>();
        String QuoteId = null;
        String AsstConfigoptions = null;
        String options = null;
        Decimal term = null;
        
        List<Account> scope = [SELECT ID, Account.OwnerId FROM Account WHERE ID IN :setAccountId ORDER BY ID];
        
        for(BigMachines__Quote__c bmq: [select Id, BigMachines__Transaction_Id__c, BigMachines__Account__c, Name from BigMachines__Quote__c 
                                where BigMachines__Account__c =: scope[0].ID order by CreatedDate desc limit 1]){
            AcctbmqIdMap.put(bmq.BigMachines__Account__c, bmq.BigMachines__Transaction_Id__c);
            QuoteId = bmq.BigMachines__Transaction_Id__c;
        }    
                
        for(Asset asst: [Select id, name, Parent_Asset__c, AccountId, Account.AR_Default_Renewal_Term__c, Product2Id, Product2.ProductCode, Product2.Orderable__c
                        FROM Asset WHERE Asset_Type__c = 'Parent' AND Status = 'Active' AND AccountId = :scope[0].ID
                        AND Follow_Up_Status__c != 'Pending Renewal' AND Follow_Up_Status__c != 'Will Not Renew' 
                        AND Follow_Up_Status__c != 'Renewed' AND Follow_Up_Status__c != 'Manual Renewal'
                        AND Account.Auto_Renewal__c = True AND Product2.Auto_Renewal__c  = True AND Product2.Orderable__c  = True
                        AND AutoRenewalPicked__c = True AND AutoRenewQuoteProduct__c = Null AND AR_Nightly_Update__c != Today
                        AND AccountId = : scope[0].ID ORDER BY ID]) {
                         //AND AR_Oversold_Flag__c = False 
            //Remove end date condition in the above Query
            asst.AR_Nightly_Update__c = System.Today();
            AsstUpdList.add(asst);
            AsstIdSet.add(asst.Id);
            term = asst.Account.AR_Default_Renewal_Term__c;
            if(asst.ConfigOptions__c != null){
                options = asst.ConfigOptions__c;
                if(options.contains(';')){AsstConfigoptions=options.replace(';','~'); }
                else
                    AsstConfigoptions=options;
                System.debug('AsstConfigoptions'+AsstConfigoptions);
            }
        }
        
        //Price Update call to CPQ
        if (!Test.isRunningTest() && !AsstIdSet.isEmpty()){
             ARIICPQCalls wscbm = new ARIICPQCalls();
            String returnResponse = ARIICPQCalls.AssetNightlyPriceUpdate(QuoteId, 'plainSave_t', AsstIdSet, AsstConfigoptions);
            if(!returnResponse.contains('Exception')){
            ARIICPQCalls.AssetNightlyPriceUpdate(QuoteId, 'autoRenewAssetExport', AsstIdSet, AsstConfigoptions);
            }
        }
        // Update Asset Nightly Price Date to today
        update AsstUpdList;
    }
}