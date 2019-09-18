public class AutoRenewalManualrun {

    public static void autorenewalmethod(id accountid){
    
        Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
    
        Opportunity theOpportunity = new Opportunity(
                Name = 'The Opportunity',
                StageName = 'Prospecting',
                CloseDate = system.today(),
                AccountId = accountid,
                Is_Renewal_Opp__c = true,
                Account_Type__c = 'Renewal');
        insert theOpportunity;
        
        mapAccountOpportunityId.put(accountid,theOpportunity.Id);
        autorenewalCreate(mapAccountOpportunityId);
    
    }
    
    public static void autorenewalCreate(Map<Id,Id> mapAccountOpportunityId){  
        String assetId;
        set<ID> AccountIDs = new set<ID>();
        //Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
        List<Account> scope = [SELECT ID, Account.OwnerId FROM Account WHERE ID = :mapAccountOpportunityId.keyset() ORDER BY ID];
        
        //execute method
        List<Asset> lstupdateAsset = new List<Asset>();
        Map<Id,String> AssetIds = New Map<Id,String>();
        Set<Asset> updateAsstSet = new Set<Asset>();
        List<AutoRenewal__c> Exclusionlst = AutoRenewal__c.getAll().values();
        Set<AutoRenewal__c> Exclusionset = New Set<AutoRenewal__c>(Exclusionlst);
        String AcctOwnrPrfNm = [Select Id, Profile_Name__c from User Where Id = :scope[0].OwnerId].Profile_Name__c;
        
        List<Asset> AssetData = [SELECT id, name, Parent_Asset__c, AccountId, Account.OwnerId, Product2Id, 
                                 Product2.ProductCode, Status, Product2.Orderable__c,Asset_Stage__c, Quantity, 
                                 Follow_Up_Status__c, Auto_Renewal__c, BOP_Code__c, Email__c,End_Date__c, Lead_Type__c, 
                                 Line_Type__c, List_Price__c, Market_Zip__c,Market__c, Market_Tier__c, Renewal_Type__c,
                                 Ultimate_Parent__c, Last_Order_Activity_Date__c, Start_Date__c, Total_Net__c, KickoutReason__c
                                 FROM Asset WHERE Asset_Type__c='Parent' AND Status = 'Active' AND 
                                 (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')   
                                 AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                 AND Account.Account_Sub_Type__c='Customer' AND Account.Auto_Renewal__c=true
                                 AND Product2.Auto_Renewal__c =true AND End_Date__c = NEXT_MONTH 
                                 AND AccountId = :scope[0].ID AND (not Inflight_Quote__c like '%Renew%') ORDER BY AccountId];
         System.debug('AssetData:'+AssetData);     
        
        for(Asset Assetloop : AssetData) {
            if(Assetloop.Product2.Orderable__c) {
                if(Assetloop.Total_Net__c != 0  || Assetloop.Product2.ProductCode == 'FIVESTREET') {
                    System.debug('AcctOwnrPrfNm:'+AcctOwnrPrfNm);
                    AutoRenewal__c Exclusions = AutoRenewal__c.getInstance(AcctOwnrPrfNm);
                    System.debug('Exclusions:'+Exclusions);
                    //Verifying Product Exclusions using Custom Settings
                    If(Exclusions != NULL && Exclusions.ProductCodes__c != NULL){
                        if(!Exclusions.ProductCodes__c.contains(Assetloop.Product2.ProductCode)){
                            AssetIds.put(Assetloop.id,'');
                            Assetloop.AutoRenewalPicked__c = true;
                            Assetloop.Renewal_Type__c = 'Auto';
                            if(Assetloop.Last_Order_Activity_Date__c == null)
                               Assetloop.Last_Order_Activity_Date__c =  Assetloop.Start_Date__c;
                            updateAsstSet.add(Assetloop);
                        }else{
                            Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                            Assetloop.AutoRenewalPicked__c = true;
                            Assetloop.Renewal_Type__c = 'Manual';
                            Assetloop.KickoutReason__c = 'Product Not orderable';
                            updateAsstSet.add(Assetloop);
                        }                            
                    }else{
                        AssetIds.put(Assetloop.id,'');
                        Assetloop.AutoRenewalPicked__c = true;
                        Assetloop.Renewal_Type__c = 'Auto';
                        if(Assetloop.Last_Order_Activity_Date__c == null)
                           Assetloop.Last_Order_Activity_Date__c =  Assetloop.Start_Date__c;
                        updateAsstSet.add(Assetloop);
                    }
                }else{
                    Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                    Assetloop.AutoRenewalPicked__c = true;
                    Assetloop.Renewal_Type__c = 'Manual';
                    Assetloop.KickoutReason__c = 'Zero Dollar Asset';
                    updateAsstSet.add(Assetloop);
                }
            }else{
                Assetloop.Follow_Up_Status__c = 'Manual Renewal';
                Assetloop.AutoRenewalPicked__c = true;
                Assetloop.Renewal_Type__c = 'Manual';
                Assetloop.KickoutReason__c = 'Product Not orderable';
                updateAsstSet.add(Assetloop);
            }
        }
                       
        System.debug('assetIds:'+assetIds);
        //Create Quote
        if (!Test.isRunningTest() && assetIds.size() > 0 ){
            WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
            wscbm.CreateQuote(null,null,scope[0].ID,mapAccountOpportunityId.get(scope[0].ID),null,'Auto-Renew','renew',true,false,assetIds);
        }
        
        //Update Assets for manual Renewals
        if(!updateAsstSet.isEmpty()){
            lstupdateAsset.addall(updateAsstSet);
            update lstupdateAsset;
        }
        //execute method
    }
}