public with sharing class AssetStructureClass {
public String assetname { get; set; }

    public id Accid;
    Public boolean SaveButton{get;set;}
    Public boolean DisplayAllButton{get;set;}
    Public String baseurl{get;set;}
    List<AssetDisplayOrderStructure> lstAssetDisplay = new List<AssetDisplayOrderStructure>();
      List<AssetDisplayOrderStructure> lstAssetDisplay1 = new List<AssetDisplayOrderStructure>();
    Map<Id,Id> mapAllAssetIdmap = new Map<Id,Id>();
    Map<Id,List<Asset>> mapParentChildAssets = new Map<Id,List<Asset>>();
    Map<Id,List<Asset>> mapFulfilltoChildAssets = new Map<Id,List<Asset>>();
    Map<Id,Asset> maplstAsset = new Map<Id,Asset>();
    Map<Id,Asset> maplstParentAsset = new Map<Id,Asset>();
    Map<Id,Zuora__Subscription__c> mapSubscription = new Map<Id,Zuora__Subscription__c>();
     Set<Id> setAllParentIds = new Set<Id>();
    public AssetStructureClass(ApexPages.StandardController controller) {
        baseurl = System.URL.getSalesforceBaseUrl().toExternalForm();
        Accid = String.valueOf(ApexPages.CurrentPage().getParameters().get('id'));   
        if(Accid==Label.OpcityAccountId){Accid='';}      
        DisplayAllButton = true;
        //Leap 3202
        //To diaplay all assets with conditions(status-Expired and Active)
        DiaplayAssets();
        //To display active assets only 
        //DisplayActiveAssets();
    }
    
    public void DiaplayAssets(){
        if(DisplayAll == false){
        //Set<String> setStatus = new Set<String>{'Active','Cancelled','Converted','Pending Fulfillment','Expired'};
        Set<String> setStatus = new Set<String>{'Active','In Active'};
        //CRM-2441 Added haircut flag in query //CRM-2874 Added Fields 'Asset Performance','License' & 'Renewal Type' in query 
        //CRM-3126 Venu Ravilla-- Added Product type field
        //CRM-5916/6050 Added Non Renewal reason & Prosoft evergreen Flag .
        maplstParentAsset = new Map<Id,Asset>([Select id,name,MLS_Set__r.Name,Non_Renewable_Reason__c,Haircut_Asset__c,No_Term_Sale__c,Commerce_Group__c,Asset_Performance__c,Renewal_Type__c,ARIIPrice_Info_Status__c,License_Tier__c,Auto_Renewal__c, BOP_Code__c, Renewal_Status__c ,Prosoft_Evergreen_Renewal__c,Asset_Number__c,asset_type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Start_Date__c,Fulfillment_Status__c,Follow_Up_Status__c,End_Date__c,Lead_Type__c,Total_Net__c,Extended_Net_Price__c,Product_Type__c from asset where Status = :setStatus and accountId=:Accid order by Status,End_Date__c ASC]);
           if(maplstParentAsset.values().size()>0){
           setAllParentIds.addAll(maplstParentAsset.keyset());
            for(Zuora__Subscription__c subs:[Select Asset__c,Id, Zuora__MRR__c,Zuora__TCV__c from Zuora__Subscription__c where Asset__c=:setAllParentIds]){
            mapSubscription.put(subs.Asset__c,subs);
            }
            //CRM-2441 Added haircut flag //CRM-2874 Added Fields 'Asset Performance','License' & 'Renewal Type' in query //CRM-5916/6050 Added Non Renewal reason & Prosoft evergreen Flag .
            maplstAsset = new Map<Id,Asset>([Select id,name, MLS_Set__r.Name,No_Term_Sale__c,Non_Renewable_Reason__c,Prosoft_Evergreen_Renewal__c,Haircut_Asset__c, Commerce_Group__c ,Asset_Performance__c,Renewal_Type__c,ARIIPrice_Info_Status__c,License_Tier__c,Auto_Renewal__c, BOP_Code__c ,Asset_Number__c,Renewal_Status__c,Follow_Up_Status__c ,asset_type__c,Fulfillment_Status__c,Start_Date__c,End_Date__c,Lead_Type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Product_Type__c from asset where  Status =:setStatus and (Ultimate_Parent_Id_Text__c=:setAllParentIds)]);
            if(maplstParentAsset!=null){
            maplstAsset.putAll(maplstParentAsset);
            }
            }
        }
             
        for(Asset ass: maplstAsset.values()){
            if(ass.asset_type__c==Constants.ASSET_TYPE_FULFILL){
                if(mapParentChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapParentChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARTICIPANT){
                if(mapFulfilltoChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapFulfilltoChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            mapAllAssetIdmap.put(ass.id,ass.parent_asset__c);
        }
        
        for(Asset ass : maplstAsset.values()){
        System.debug(ass.asset_type__c+'=='+Constants.ASSET_TYPE_PARENT);
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARENT){
                AssetDisplayOrderStructure assetdisparent = new AssetDisplayOrderStructure();
                assetdisparent.assetrowid = ass.id;
                assetdisparent.assetId    = ass.id;
                assetdisparent.assetName  = ass.Name;
                assetdisparent.assetNumber  = (ass.Asset_Number__c+'');
                assetdisparent.assetType  = ass.asset_type__c;
                assetdisparent.assetHaircut  = ass.Haircut_Asset__c;
                assetdisparent.assetevergreen  = ass.Prosoft_Evergreen_Renewal__c; //CRM-6050
                assetdisparent.assetnonrenewreason  = ass.Non_Renewable_Reason__c; //CRM-5916
                assetdisparent.assetQuantity = ass.Quantity;
                assetdisparent.assetProductType = ass.Product_Type__c;
                assetdisparent.assetStatus  = ass.Status;
                assetdisparent.includeAsset = ass.Include_Asset__c;
                assetdisparent.assetnotermsale  = ass.No_Term_Sale__c;
                assetdisparent.assetFulfilmentStatus = ass.Fulfillment_Status__c;
                assetdisparent.assetStartDate = ass.Start_Date__c;
                assetdisparent.assetEndDate = ass.End_Date__c;
                system.debug(assetdisparent.assetEndDate +'=='+ ass.End_Date__c);
                assetdisparent.assetleadtype = ass.Lead_Type__c;
                assetdisparent.assetRenewalStatus = ass.Renewal_Status__c;   
                assetdisparent.assetTCV = ass.Total_Net__c;
                assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                assetdisparent.assetFollow = ass.Follow_Up_Status__c;
               
    
            /*
                if(mapSubscription.containskey(ass.id)){
                if(mapSubscription.get(ass.id).Zuora__TCV__c!=null){
                assetdisparent.assetTCV = mapSubscription.get(ass.id).Zuora__TCV__c.setScale(2);
                }
                if(mapSubscription.get(ass.id).Zuora__MRR__c!=null){
                assetdisparent.assetCMMR = mapSubscription.get(ass.id).Zuora__MRR__c.setScale(2);
                }
                } 
            */
            
                assetdisparent.assetAutoRenewal =  ass.Auto_Renewal__c;
                if (ass.ARIIPrice_Info_Status__c == 'Yes')
               
                {
                    assetdisparent.assetAutoRenew =  true;
                }
                else
                {
                    assetdisparent.assetAutoRenew = false;
                }
                assetdisparent.assetRenewalType=  ass.Renewal_Type__c;
                assetdisparent.assetLicenses =  ass.License_Tier__c;
                assetdisparent.assetPerformance = ass.Asset_Performance__c;
                assetdisparent.assetBopCode =  ass.BOP_Code__c;  
                assetdisparent.assetMlsSet =  ass.MLS_Set__r.Name;
                assetdisparent.assetProductBundle = ass.Commerce_Group__c;
                lstAssetDisplay.add(assetdisparent);
                //System.debug(mapParentChildAssets.containskey(ass.id)+'$$$$$$$'+mapParentChildAssets+'PPPPP'+ass.id);
                if(mapParentChildAssets.containskey(ass.id)){
                    Integer ii=0;
                    for(Asset asst:mapParentChildAssets.get(ass.id)){
                    System.debug(asst+'PPPPP');
                        AssetDisplayOrderStructure assetdisparentff = new AssetDisplayOrderStructure();
                        //CRM-1360 :- changed separater from fff to ffffffffff
                        assetdisparentff.assetrowid = ass.id+'ffffffffff'+ii;
                        assetdisparentff.assetId    = asst.id;
                        assetdisparentff.assetName  = asst.Name;
                        assetdisparentff.assetnonrenewreason  = asst.Non_Renewable_Reason__c; //CRM-5916
                        assetdisparentff.assetNumber  = (asst.Asset_Number__c+'');
                        assetdisparentff.assetType  = asst.asset_type__c;
                        assetdisparentff.assetevergreen  = asst.Prosoft_Evergreen_Renewal__c; //CRM-6050
                        assetdisparentff.assetQuantity = asst.Quantity;
                        assetdisparentff.assetProductType = asst.Product_Type__c;
                        assetdisparentff.assetStatus  = asst.Status;
                        assetdisparentff.includeAsset = asst.Include_Asset__c;
                        assetdisparentff.assetFulfilmentStatus = asst.Fulfillment_Status__c;
                        assetdisparentff.assetStartDate = asst.Start_Date__c;
                        assetdisparentff.assetEndDate = asst.End_Date__c;
                        assetdisparentff.assetleadtype = asst.Lead_Type__c;
                        assetdisparentff.assetRenewalStatus = asst.Renewal_Status__c; 
                        assetdisparentff.assetFollow = asst.Follow_Up_Status__c;
                        assetdisparentff.assetnotermsale  = asst.No_Term_Sale__c;
                        assetdisparent.assetTCV = ass.Total_Net__c;
                        assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                                  
                        //assetdisparentff.assetTCV = 100.00;
                        //assetdisparentff.assetCMMR = 250.00;
                        assetdisparentff.assetAutoRenewal =  asst.Auto_Renewal__c;
                        assetdisparentff.assetRenewalType=  asst.Renewal_Type__c;
                        if (asst.ARIIPrice_Info_Status__c == 'Yes')
                        {
                            assetdisparentff.assetAutoRenew =  true;
                        }
                        else
                        {
                            assetdisparentff.assetAutoRenew = false;
                        }
                        assetdisparentff.assetLicenses =  asst.License_Tier__c;
                        assetdisparentff.assetPerformance = asst.Asset_Performance__c;
                        assetdisparentff.assetBopCode =  asst.BOP_Code__c;  
                        assetdisparentff.assetProductBundle = asst.Commerce_Group__c;
                        assetdisparentff.assetMlsSet =  asst.MLS_Set__r.Name;
                        lstAssetDisplay.add(assetdisparentff);
                        if(mapFulfilltoChildAssets.containskey(asst.id)){
                            Integer jj=0;
                            for(Asset asstp:mapFulfilltoChildAssets.get(asst.id)){
                                AssetDisplayOrderStructure assetdisparentpp = new AssetDisplayOrderStructure();
                                //CRM-1360 :- changed separater from fff to ffffffffff
                                assetdisparentpp.assetrowid = ass.id+'ffffffffff'+ii+asst.id+'pppppppppp'+jj;
                                assetdisparentpp.assetId    = asstp.id;
                                assetdisparentpp.assetName  = asstp.Name;
                                assetdisparentpp.assetnonrenewreason  = asstp.Non_Renewable_Reason__c; //CRM-5916
                                assetdisparentpp.assetType  = asstp.asset_type__c;
                                assetdisparentpp.assetevergreen  = asstp.Prosoft_Evergreen_Renewal__c; //CRM-6050
                                assetdisparent.assetNumber  = (ass.Asset_Number__c+'');
                                assetdisparentpp.assetQuantity = asstp.Quantity;
                                assetdisparentpp.assetProductType = asstp.Product_Type__c;
                                assetdisparentpp.includeAsset = asstp.Include_Asset__c;
                                assetdisparentpp.assetStatus  = asstp.Status;
                                assetdisparentpp.assetFulfilmentStatus = asstp.Fulfillment_Status__c;
                                assetdisparentpp.assetStartDate = asstp.Start_Date__c;
                                assetdisparentpp.assetEndDate = asstp.End_Date__c;
                                assetdisparentpp.assetleadtype = asstp.Lead_Type__c;
                                assetdisparentpp.assetRenewalStatus = asstp.Renewal_Status__c;   
                                assetdisparentpp.assetFollow = asstp.Follow_Up_Status__c;
                                assetdisparentpp.assetnotermsale  = asstp.No_Term_Sale__c;
                                assetdisparent.assetTCV = ass.Total_Net__c;
                                assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                                
                                //assetdisparentpp.assetTCV = 100.00;
                                //assetdisparentpp.assetCMMR = 250.00;
                                assetdisparentpp.assetAutoRenewal =  asstp.Auto_Renewal__c;
                                assetdisparentpp.assetRenewalType=  asstp.Renewal_Type__c;
                                if (asstp.ARIIPrice_Info_Status__c == 'Yes')
                                {
                                    assetdisparentpp.assetAutoRenew =  true;
                                }
                                else
                                {
                                    assetdisparentpp.assetAutoRenew = false;
                                }
                                assetdisparentpp.assetLicenses =  asstp.License_Tier__c;
                                assetdisparentpp.assetPerformance = asstp.Asset_Performance__c;
                                assetdisparentpp.assetBopCode =  asstp.BOP_Code__c;  
                                assetdisparentpp.assetMlsSet =  asstp.MLS_Set__r.Name;
                                assetdisparentpp.assetProductBundle = asstp.Commerce_Group__c;
                                lstAssetDisplay.add(assetdisparentpp);
                                jj++;
                            }
                        }
                        ii++;
                    }
                }
            }
        }
    }
    public void DisplayActiveAssets(){
        if(DisplayAll == false){
        Set<String> setStatus = new Set<String>{'Active'};
        //CRM-2874 Added Fields 'Asset Performance','License' & 'Renewal Type' in query
        maplstParentAsset = new Map<Id,Asset>([Select id,Haircut_Asset__c,name,No_Term_Sale__c,Non_Renewable_Reason__c,Prosoft_Evergreen_Renewal__c,MLS_Set__r.Name, Commerce_Group__c,Asset_Performance__c,Renewal_Type__c,ARIIPrice_Info_Status__c,License_Tier__c,Auto_Renewal__c, BOP_Code__c, Renewal_Status__c ,Asset_Number__c,asset_type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Start_Date__c,Fulfillment_Status__c,Follow_Up_Status__c,End_Date__c,Lead_Type__c,Total_Net__c,Extended_Net_Price__c,Product_Type__c from asset where Status = :setStatus and accountId=:Accid order by Status,End_Date__c ASC]);
           if(maplstParentAsset.values().size()>0){
           setAllParentIds.addAll(maplstParentAsset.keyset());
            for(Zuora__Subscription__c subs:[Select Asset__c,Id, Zuora__MRR__c,Zuora__TCV__c from Zuora__Subscription__c where Asset__c=:setAllParentIds]){
            mapSubscription.put(subs.Asset__c,subs);
            }
            //CRM-2874 Added Fields 'Asset Performance','License' & 'Renewal Type' in query
            maplstAsset = new Map<Id,Asset>([Select id,name,Haircut_Asset__c,No_Term_Sale__c,MLS_Set__r.Name,Non_Renewable_Reason__c,Prosoft_Evergreen_Renewal__c,Commerce_Group__c ,Asset_Performance__c,Renewal_Type__c,ARIIPrice_Info_Status__c,License_Tier__c,Auto_Renewal__c, BOP_Code__c ,Asset_Number__c,Renewal_Status__c,Follow_Up_Status__c ,asset_type__c,Fulfillment_Status__c,Start_Date__c,End_Date__c,Lead_Type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Product_Type__c from asset where  Status =:setStatus and (Ultimate_Parent_Id_Text__c=:setAllParentIds)]);
            if(maplstParentAsset!=null){
            maplstAsset.putAll(maplstParentAsset);
            }
            }
        }
             
        for(Asset ass: maplstAsset.values()){
            if(ass.asset_type__c==Constants.ASSET_TYPE_FULFILL){
                if(mapParentChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapParentChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARTICIPANT){
                if(mapFulfilltoChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapFulfilltoChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            mapAllAssetIdmap.put(ass.id,ass.parent_asset__c);
        }
        
        for(Asset ass : maplstAsset.values()){
        System.debug(ass.asset_type__c+'=='+Constants.ASSET_TYPE_PARENT);
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARENT){
                AssetDisplayOrderStructure assetdisparent = new AssetDisplayOrderStructure();
                assetdisparent.assetrowid = ass.id;
                assetdisparent.assetId    = ass.id;
                assetdisparent.assetName  = ass.Name;
                assetdisparent.assetNumber  = (ass.Asset_Number__c+'');
                assetdisparent.assetType  = ass.asset_type__c;
                assetdisparent.assetHaircut = ass.Haircut_Asset__c;
                assetdisparent.assetevergreen  = ass.Prosoft_Evergreen_Renewal__c; //CRM-6050
                assetdisparent.assetnonrenewreason  = ass.Non_Renewable_Reason__c; //CRM-5916
                assetdisparent.assetQuantity = ass.Quantity;
                assetdisparent.assetProductType = ass.Product_Type__c;
                assetdisparent.assetStatus  = ass.Status;
                assetdisparent.includeAsset = ass.Include_Asset__c;
                assetdisparent.assetFulfilmentStatus = ass.Fulfillment_Status__c;
                assetdisparent.assetStartDate = ass.Start_Date__c;
                assetdisparent.assetEndDate = ass.End_Date__c;
                system.debug(assetdisparent.assetEndDate +'=='+ ass.End_Date__c);
                assetdisparent.assetleadtype = ass.Lead_Type__c;
                assetdisparent.assetRenewalStatus = ass.Renewal_Status__c;   
                assetdisparent.assetTCV = ass.Total_Net__c;
                assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                assetdisparent.assetFollow = ass.Follow_Up_Status__c;
                assetdisparent.assetnotermsale  = ass.No_Term_Sale__c;
    
            /*
                if(mapSubscription.containskey(ass.id)){
                if(mapSubscription.get(ass.id).Zuora__TCV__c!=null){
                assetdisparent.assetTCV = mapSubscription.get(ass.id).Zuora__TCV__c.setScale(2);
                }
                if(mapSubscription.get(ass.id).Zuora__MRR__c!=null){
                assetdisparent.assetCMMR = mapSubscription.get(ass.id).Zuora__MRR__c.setScale(2);
                }
                } 
            */
            
                assetdisparent.assetAutoRenewal =  ass.Auto_Renewal__c;
                assetdisparent.assetRenewalType=  ass.Renewal_Type__c;
                if (ass.ARIIPrice_Info_Status__c == 'Yes')
                {
                    assetdisparent.assetAutoRenew =  true;
                }
                else
                {
                    assetdisparent.assetAutoRenew = false;
                }
                assetdisparent.assetLicenses =  ass.License_Tier__c;
                assetdisparent.assetPerformance = ass.Asset_Performance__c;
                assetdisparent.assetBopCode =  ass.BOP_Code__c;  
                assetdisparent.assetMlsSet =  ass.MLS_Set__r.Name;
                assetdisparent.assetProductBundle = ass.Commerce_Group__c;
                lstAssetDisplay1.add(assetdisparent);
                if(mapParentChildAssets.containskey(ass.id)){
                    Integer ii=0;
                    for(Asset asst:mapParentChildAssets.get(ass.id)){
                        AssetDisplayOrderStructure assetdisparentff = new AssetDisplayOrderStructure();
                        assetdisparentff.assetrowid = ass.id+'ffffffffff'+ii;
                        assetdisparentff.assetId    = asst.id;
                        assetdisparentff.assetName  = asst.Name;
                        assetdisparentff.assetnonrenewreason  = asst.Non_Renewable_Reason__c; //CRM-5916
                        assetdisparentff.assetNumber  = (asst.Asset_Number__c+'');
                        assetdisparentff.assetType  = asst.asset_type__c;
                        assetdisparentff.assetQuantity = asst.Quantity;
                        assetdisparentff.assetProductType = asst.Product_Type__c;
                        assetdisparentff.assetStatus  = asst.Status;
                        assetdisparentff.includeAsset = asst.Include_Asset__c;
                        assetdisparentff.assetFulfilmentStatus = asst.Fulfillment_Status__c;
                        assetdisparentff.assetStartDate = asst.Start_Date__c;
                        assetdisparentff.assetEndDate = asst.End_Date__c;
                        assetdisparentff.assetleadtype = asst.Lead_Type__c;
                        assetdisparentff.assetRenewalStatus = asst.Renewal_Status__c; 
                        assetdisparentff.assetFollow = asst.Follow_Up_Status__c;
                        assetdisparentff.assetnotermsale  = asst.No_Term_Sale__c;
                        assetdisparentff.assetevergreen  = asst.Prosoft_Evergreen_Renewal__c; //CRM-6050
                        assetdisparent.assetTCV = ass.Total_Net__c;
                        assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                                  
                        //assetdisparentff.assetTCV = 100.00;
                        //assetdisparentff.assetCMMR = 250.00;
                        assetdisparentff.assetAutoRenewal =  asst.Auto_Renewal__c;
                        assetdisparentff.assetRenewalType=  asst.Renewal_Type__c;
                        if (asst.ARIIPrice_Info_Status__c == 'Yes')
                        {
                            assetdisparentff.assetAutoRenew =  true;
                        }
                        else
                        {
                            assetdisparentff.assetAutoRenew = false;
                        }
                        assetdisparentff.assetLicenses =  asst.License_Tier__c;
                        assetdisparentff.assetPerformance = asst.Asset_Performance__c;
                        assetdisparentff.assetBopCode =  asst.BOP_Code__c;  
                        assetdisparentff.assetProductBundle = asst.Commerce_Group__c;
                        assetdisparentff.assetMlsSet =  asst.MLS_Set__r.Name;
                        lstAssetDisplay1.add(assetdisparentff);
                        if(mapFulfilltoChildAssets.containskey(asst.id)){
                            Integer jj=0;
                            for(Asset asstp:mapFulfilltoChildAssets.get(asst.id)){
                                AssetDisplayOrderStructure assetdisparentpp = new AssetDisplayOrderStructure();
                                assetdisparentpp.assetrowid = ass.id+'ffffffffff'+ii+asst.id+'pppppppppp'+jj;
                                assetdisparentpp.assetId    = asstp.id;
                                assetdisparentpp.assetName  = asstp.Name;
                                assetdisparentpp.assetnonrenewreason  = asstp.Non_Renewable_Reason__c; //CRM-5916
                                assetdisparentpp.assetevergreen  = asstp.Prosoft_Evergreen_Renewal__c; //CRM-6050
                                assetdisparentpp.assetType  = asstp.asset_type__c;
                                assetdisparent.assetNumber  = (ass.Asset_Number__c+'');
                                assetdisparentpp.assetQuantity = asstp.Quantity;
                                assetdisparentpp.assetProductType = asstp.Product_Type__c;
                                assetdisparentpp.includeAsset = asstp.Include_Asset__c;
                                assetdisparentpp.assetStatus  = asstp.Status;
                                assetdisparentpp.assetFulfilmentStatus = asstp.Fulfillment_Status__c;
                                assetdisparentpp.assetStartDate = asstp.Start_Date__c;
                                assetdisparentpp.assetEndDate = asstp.End_Date__c;
                                assetdisparentpp.assetleadtype = asstp.Lead_Type__c;
                                assetdisparentpp.assetRenewalStatus = asstp.Renewal_Status__c;   
                                assetdisparentpp.assetFollow = asstp.Follow_Up_Status__c;
                                assetdisparentpp.assetnotermsale  = asstp.No_Term_Sale__c;
                                assetdisparent.assetTCV = ass.Total_Net__c;
                                assetdisparent.assetCMMR = ass.Extended_Net_Price__c;
                                
                                //assetdisparentpp.assetTCV = 100.00;
                                //assetdisparentpp.assetCMMR = 250.00;
                                assetdisparentpp.assetAutoRenewal =  asstp.Auto_Renewal__c;
                                assetdisparentpp.assetRenewalType=  asstp.Renewal_Type__c;
                                if (asstp.ARIIPrice_Info_Status__c == 'Yes')
                                {
                                    assetdisparentpp.assetAutoRenew =  true;
                                }
                                else
                                {
                                    assetdisparentpp.assetAutoRenew = false;
                                }
                                assetdisparentpp.assetLicenses =  asstp.License_Tier__c;
                                assetdisparentpp.assetPerformance = asstp.Asset_Performance__c;
                                assetdisparentpp.assetBopCode =  asstp.BOP_Code__c;  
                                assetdisparentpp.assetMlsSet =  asstp.MLS_Set__r.Name;
                                assetdisparentpp.assetProductBundle = asstp.Commerce_Group__c;
                                lstAssetDisplay1.add(assetdisparentpp);
                                jj++;
                            }
                        }
                        ii++;
                    }
                }
            }
        }
    }

    
    public AssetStructureClass(){
        SaveButton = true;
        DisplayAllButton = false;
    }
    Boolean DisplayAll = false;
    public void display(){
        DisplayAll = true;
        DiaplayAssets(); 
        DisplayActiveAssets();
    }
    
    Public PageReference SaveAsset(){
    List<Asset> lstAsset = new List<Asset>();
    for(AssetDisplayOrderStructure ados:lstAssetDisplay){
    if(maplstAsset.containskey(ados.assetId)){
    if(maplstAsset.get(ados.assetId).Include_Asset__c!=null){
    if(maplstAsset.get(ados.assetId).Include_Asset__c !=ados.includeAsset){
    Asset asst = new Asset();
    asst.Id = ados.assetId;
    asst.Include_Asset__c = ados.includeAsset;
    lstAsset.add(asst); 
    }
    }
    }
    }
    if(lstAsset.size()>0){
    SkipComissionTrigger.setSkipTrgTrue();
    update lstAsset;
    }
    return null;
    } 
    
    Public PageReference SaveAsset1(){
    List<Asset> lstAsset = new List<Asset>();
    for(AssetDisplayOrderStructure ados:lstAssetDisplay1){
    if(maplstAsset.containskey(ados.assetId)){
    if(maplstAsset.get(ados.assetId).Include_Asset__c!=null){
    if(maplstAsset.get(ados.assetId).Include_Asset__c !=ados.includeAsset){
    Asset asst = new Asset();
    asst.Id = ados.assetId;
    asst.Include_Asset__c = ados.includeAsset;
    lstAsset.add(asst); 
    }
    }
    }
    }
    if(lstAsset.size()>0){
    SkipComissionTrigger.setSkipTrgTrue();
    update lstAsset;
    }
    return null;
    } 
    
    Public PageReference NewAsset(){
    PageReference pr = new PageReference('https://cs17.salesforce.com/02i/e?retURL='+Accid);
    return pr;
    }
   
    Public List<AssetDisplayOrderStructure> getlstAssetDisplay(){
    system.debug(lstAssetDisplay.size()+'KKKKKKK');
        return lstAssetDisplay;
    } 
     Public List<AssetDisplayOrderStructure> getlstAssetDisplay1(){
        return lstAssetDisplay1;
    }
    Public class AssetDisplayOrderStructure{
        public string assetrowid{get;set;}
        Public string assetId{get;set;}
        Public string assetName{get;set;}
        Public string assetnonrenewreason{get;set;}
        Public string assetType{get;set;}
        Public Boolean assetHaircut{get;set;}
        Public Boolean assetevergreen{get;set;}
        Public Boolean assetnotermsale{get;set;}
        Public string assetNumber{get;set;}
        Public Decimal assetQuantity{get;set;}
        Public string assetProductType{get;set;}
        Public string assetStatus{get;set;}
        Public string assetFulfilmentStatus{get;set;}
        Public Date assetStartDate{get;set;}
        Public Date assetEndDate{get;set;}
        Public string assetleadtype{get;set;}  
        Public string assetRenewalStatus{get;set;}   
        Public string assetFollow{get;set;}  
        Public Decimal assetTCV{get;set;} 
        Public Decimal assetCMMR{get;set;}
        Public string assetAutoRenewal{get;set;} 
        //CRM-2874 : Adding 'Asset Performance','License' and'Renewal Type' 
        Public Decimal assetPerformance{get;set;} 
        Public Decimal assetLicenses{get;set;}
        Public string assetRenewalType{get;set;}
        Public Boolean assetAutoRenew{get;set;} // CRM-2874
        Public string assetBopCode{get;set;}   
        Public string assetMlsSet{get;set;}     
        Public string assetProductBundle{get;set;}  
        Public Boolean includeAsset{get;set;}
    }      
    
}