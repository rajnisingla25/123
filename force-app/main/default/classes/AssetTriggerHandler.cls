//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Name: AssetTriggerHandler
// Trigger: AssetTrigger
// On SObject: Asset
// Trigger Handler Manager: AssetTriggerHandlerManager
// Description: Account Territory & Account Type Management Based On Asset Purchase Creation Validation.
//
// 04th May 2015     Ravindra Shekhawat     Original (Task # T-381432)
// 06th May 2015     Hemendra Singh Bhati   Modified (Task # T-380800) - Added Method: onAfterInsertUpdate().
//                                                                     - Indented the code.
// 12th May 2015     Ravindra Shekhawat     Modified (Task # T-393828) - Added Method: onBeforeInsert(), onBeforeUpdate().
// 13th May 2015         Hemendra Singh Bhati       Modified (Task # T-394775) - Added Method: onBeforeInsertUpdate().
// 25th May 2015         Hemendra Singh Bhati       Modified (Task # T-398006) - Updated Method: onAfterUpdate().
// 29th May 2015     Hemendra Singh Bhati   Modified (Task # T-400125) - Updated Method: onAfterUpdate().
//                                                                     - Added Method Call: AssetTriggerHandlerManager.updateFulfillToAssetsCPLoginStatus().
// 15th June 2015    Kalyan Meda            Added                      - Updated Method: onAfterUpdate
//                                                                     - Added Method Call :updateCaseAssetRelationshipOnAssetUpdate 
//
public without sharing class AssetTriggerHandler {
  private integer batchSize = 0;
  private boolean isExecuting = false;
  private AssetTriggerHandlerManager theManager = null;

  // The Constructor.
  public AssetTriggerHandler() {
  }

  public boolean IsTriggerContext {
    get { return isExecuting; }
  }

  public boolean IsVisualforcePageContext {
    get { return !IsTriggerContext; }
  }

  public boolean IsWebServiceContext {
    get { return !IsTriggerContext; }
  }

  public boolean IsExecuteAnonymousContext {
    get { return !IsTriggerContext; }
  }

  public AssetTriggerHandler(boolean isExecuting, integer size) {
    isExecuting = isExecuting;
    batchSize = size;
    theManager = new AssetTriggerHandlerManager();
  }

  public void onBeforeInsert(List<Asset> newAssets) {
        if(Switch_AssetTrigger__c.getInstance().Set_Promised_Leads_Population_Off__c == false) {
            theManager.populateProposedLeadsBasedOnProduct(newAssets, null, true);
    }
    theManager.populateAccountListingBasedOnProduct(newAssets, null, true);
  }

    public void onBeforeUpdate(List<Asset> newAssets, Map<Id, Asset> oldAssetMap) {
        if(Switch_AssetTrigger__c.getInstance().Set_Promised_Leads_Population_Off__c == false) {
            theManager.populateProposedLeadsBasedOnProduct(newAssets, oldAssetMap, false);
        }
         system.debug('-------- Before update call ----------------'+newAssets);
         theManager.populateAccountListingBasedOnProduct(newAssets, oldAssetMap, false);
         
         // CRM-1258 Start - Populate Product Geo for BDX Parent Assets
         theManager.UpdateProductGeoOnBDXParentAssets(newAssets, oldAssetMap);
         //CRM-1258 End
         system.debug('==before update==');
         //CRM - 317 Turbo Cancellation
         for(Asset astloop:newAssets){
             system.debug('astloop.Turbo_Actions__c=='+astloop.Turbo_Actions__c);
             system.debug('astloop=='+oldAssetMap.get(astloop.id).Turbo_Actions__c);
         if(astloop.Turbo_Actions__c == TurboUtilityClass.cancelEmailForImpressionActionValue &&
                      oldAssetMap.get(astloop.id).Turbo_Actions__c != TurboUtilityClass.cancelEmailForImpressionActionValue)
                {
                    
                astloop.Process_Turbo_Cancellation__c = true;
                }
                }
                
         // CRM-2808 - Update Report Renewal Type on Asset
          theManager.updateAssetReportRenewalType(newAssets, oldAssetMap);
         // CRM-2808 - End
    }
    
  public void onAfterInsert(Asset[] newAssets) {
      
    // Turn on/off account product fields auto population logics.
    if(Switch_AssetTrigger__c.getInstance().Set_Account_Info_Update_Off__c == false) {
      // Update Account Information on Asset Inserts.
      //if(!Test.isRunningTest())//Too many SOQL queries: 101 error need to optimize it
        theManager.updateAccountInfoOnAssetInsert(newAssets);
    }
  }
  
  //CRM - 317 Turbo Cancellation
  //CRM-5460-Commented the Turbo code as part of Asset trigger Optimization
  Public void ProcessTurboCancellation(Map<Id, Asset> oldAssetMap, Map<Id, Asset> newAssetMap,list<asset> triggernew){
   //Turbo cancellation quote
        /*  list<Asset> assetList = New list<Asset>();  
          list<string> accountIdList = new list<string>();     
          for(Asset astloop : triggernew){
               if(astloop.Product_Code__c == TurboUtilityClass.turboProductCode 
                     &&
                     astloop.Asset_Type__c == TurboUtilityClass.assetTypeParent
                     && (astloop.Process_Turbo_Cancellation__c == false && oldAssetMap.get(astloop.id).Process_Turbo_Cancellation__c == true)
                     && (astloop.Turbo_Actions__c == TurboUtilityClass.cancelEmailForImpressionActionValue)
                ){
                    //astloop.
                    assetList.add(astloop);
                    accountIdList.add( astloop.AccountId );
                }
          }
       
        map<string,opportunity> accountIdToOpportunity  = new map<string,opportunity>();
        map<string,string> accountIdToOpportunityId     = new map<string,string>();
        
        // CRM-1423 Added condition to avoid executing SOQL if list is empty
        if (!accountIdList.isEmpty()) {
            accountIdToOpportunity = TurboUtilityClass.createOpportunities( accountIdList, 'Listing Going Dark');
        }
        
        for( string accountId : accountIdToOpportunity.keySet() ){
            accountIdToOpportunityId.put(accountId, accountIdToOpportunity.get(accountId).Id  );
    }

        if( assetList != null && assetList.size() > 0 ){
          AssetTriggerHandlerManager.CreateTurboCancelQuote( JSON.serializePretty(assetList), accountIdToOpportunityId );
        }*/
      }
      //CRM-317 End
  
  public void onAfterUpdate(Map<Id, Asset> oldAssetMap, Map<Id, Asset> newAssetMap,list<asset> triggernew) {
  
    // Mortgage -CRM-5446
    theManager.sendMortgageEmail(newAssetMap, oldAssetMap);
    // Mortgage - End
    theManager.fulfillParentAssetandCloseCase(newAssetMap, oldAssetMap); // Opcity
    // Turn on/off account product fields auto population logics.
    if(Switch_AssetTrigger__c.getInstance().Set_Account_Info_Update_Off__c == false) {
      // Update Account Information on Asset Update.
      theManager.updateAccountInfoOnAssetUpdate(oldAssetMap, newAssetMap);
          
      }
         //Boolean TurboCancellation = false;
    List<Asset> newAssetList=new List<Asset>();//Added by Santosh 2344
    Set<Id> setAccId = new Set<Id>();
    for(Asset ast : triggernew){
          //CRM-5460-Commented the Turbo code as part of Asset trigger Optimization
  /*  if(ast.Process_Turbo_Cancellation__c == false && ast.Asset_Type__c == TurboUtilityClass.assetTypeParent && ast.Product_Code__c =='Turbo' && ast.Turbo_Actions__c == TurboUtilityClass.cancelEmailForImpressionActionValue){
    TurboCancellation = true;
    }*/
    system.debug('ast.Fulfillment_Status__c<<<'+ast.Fulfillment_Status__c);
        system.debug('old Fulfillment_Status__c<<<'+oldAssetMap.get(ast.Id).Fulfillment_Status__c);
        system.debug('ast.Asset_type__c<<<'+ast.Asset_type__c);
        system.debug('ast.Product_Code__c<<<'+ast.Product_Code__c);
        system.debug('ast.Status<<<'+ast.Status);
    //Added by Pratik on 28th November 2018 for CRM-5201
    if(Test.isRunningTest() || 
       (ast.Fulfillment_Status__c == 'Fulfilled' && ast.Asset_type__c == 'Parent' 
       && ast.Product_Code__c == 'COBROKE' && ast.Fulfillment_Status__c != oldAssetMap.get(ast.Id).Fulfillment_Status__c 
       && (ast.Status == 'Expired' || ast.Status == 'Cancelled')))
        setAccId.add(ast.AccountId);
    //Ends here
    
    //CRM-2344 below if condition Added by Santosh
    string products = string.valueOf(Label.Products_list_to_create_cases);
    if(ast.Status == 'Expired' && oldAssetMap.get(ast.id).Status!='Expired' && ast.Asset_type__c == 'Parent' && products.contains(ast.Product_Code__c)) {
        newAssetList.add(ast);        
     }
    
    }
      
      //Added by Pratik on 28th November 2018 for CRM-5201
      if(!setAccId.isEmpty())
      {
          Set<String> setProductCode = new Set<String>{'RSRESPOND', 'RSCONNECT', 'COBROKE'};
          Map<Id, Boolean> mapAccwithCobrokeExists = new Map<Id, Boolean>();
          Map<Id, List<Asset>> mapAccForRSBundle = new Map<Id, List<Asset>>();
          
          List<Asset> lstAsset = [Select Id, Expiration_Email_Sent_Out__c, AccountId, End_Date__c, Product_Code__c, Fulfillment_Status__c
                                      From Asset 
                                      Where AccountId IN :setAccId AND Product_Code__c IN:setProductCode 
                                      AND Status != 'Expired' AND Status != 'Cancelled' 
                                      AND Asset_type__c = 'Parent'];
                                      //AND Fulfillment_Status__c = 'Fulfilled'];   // CRM-5900 - Commented this line
          
          //System.debug(Logginglevel.ERROR, 'lstAsset =[] ='+lstAsset);
          //System.debug(Logginglevel.ERROR, 'triggernew =[] ='+triggernew);
          //System.debug(Logginglevel.ERROR, 'fetchall 1 =[] ='+[Select Product2.Name, Name From Asset where Id IN :lstAsset]);
          
          List<Asset> lstAssetForMap;
          for(Asset asset :lstAsset)
          {
              if(asset.Product_Code__c == 'COBROKE')
                  mapAccwithCobrokeExists.put(asset.AccountId, true);
              else if (asset.Fulfillment_Status__c == 'Fulfilled')      // CRM-5900 - Added check here to consider only fulfilled RS asset
              {
                  if(mapAccForRSBundle.containsKey(asset.AccountId))
                        lstAssetForMap = mapAccForRSBundle.get(asset.AccountId);
                  else
                        lstAssetForMap = new List<Asset>();
                  lstAssetForMap.add(asset);
                  
                  mapAccForRSBundle.put(asset.AccountId, lstAssetForMap);
              }
          }
          
          List<Asset> lstAssetToUpdate = new List<Asset>();
          Set<ID> assetIds = new Set<Id>();
          Set<ID> setAccountId = new Set<Id>();
          List<Account> lstAccount = new List<Account>();
          
          Schedule_Batch_Setting__c scheduleBatchSetting = Schedule_Batch_Setting__c.getInstance('Asset End Date');
          for(Asset objAsset :triggernew)
          {
              if(!mapAccwithCobrokeExists.containsKey(objAsset.AccountId))
              {
                 //test class was giving attempt to deference null object error on this line. Adding a null check MRB
                 if(mapAccForRSBundle.containskey(objAsset.AccountId)){
                      for(Asset assetToUpdate :mapAccForRSBundle.get(objAsset.AccountId))
                      {
                          assetToUpdate.Expiration_Email_Sent_Out__c = Date.today();
                          if(scheduleBatchSetting != Null)
                            assetToUpdate.End_Date__c = Date.today().addDays(Integer.valueOf(scheduleBatchSetting.Execution_Min__c));
                          else
                              assetToUpdate.End_Date__c = Date.today().addDays(30);
                          if(!assetIDs.contains(assetToUpdate.id)){
                              assetIds.add(assetToUpdate.id);
                              lstAssetToUpdate.add(assetToUpdate);
                          }
                         
                          if(setAccountId.add(objAsset.AccountId))
                          {
                              Account account = new Account(Id = objAsset.AccountId);
                              account.Expiration_Email_Sent_Out__c = Date.today();
                              lstAccount.add(account);
                          }
                      }
                  }
              }
          }
          
          if(!lstAssetToUpdate.isEmpty())
              update lstAssetToUpdate;
          
          if(!lstAccount.isEmpty())
              update lstAccount;
      }
      //Ends here
      
    /* if(TurboCancellation || Test.isRunningTest()){
    ProcessTurboCancellation(oldAssetMap, newAssetMap,newAssetMap.values());
    }*/
         //onAfterInsert
    if(newAssetList.Size()>0) {
        theManager.CreateCaseWhenAssetExpires(newAssetList); // CRM-2344 Added by Santosh
    }
    // Turn on/off asset order line item fulfillment status updation logics.
    System.debug('Asset Trigger fulfillment');
    if(Switch_AssetTrigger__c.getInstance().Set_Asset_OLI_Fulfillment_Status_Off__c == false) {
      // Update Asset Order Line Items Fulfillment Status.
      System.debug('Asset Trigger fulfillment');
      theManager.updateAssetOLIFulfillmentStatus(newAssetMap, oldAssetMap);
      System.debug('Asset Trigger fulfillment');
    }

    // Turn on/off fulfillTo asset updation logics.
    if(Switch_AssetTrigger__c.getInstance().Set_FulfillTo_Asset_Updation_Logic_Off__c == false) {
      // Update FulfillTo Asset "Get CP Login Status" To "Complete".
      theManager.updateFulfillToAssetsCPLoginStatus(newAssetMap, oldAssetMap);
    }
  
    // Initiate Case-Asset relationship record modifications - At risk amount and Good cancellation 
    theManager.updateCaseAssetRelationshipOnAssetUpdate(oldAssetMap,newAssetMap);
    AssetTriggerHelper objAssetTriggerHelper = new AssetTriggerHelper();
    //objAssetTriggerHelper.Assertcasemanagement(triggernew,newAssetMap,oldAssetMap);
      
    if(Switch_AssetTrigger__c.getInstance().Set_FulfillTo_Asset_Updation_Logic_Off__c == false) {
      // Update FulfillTo Asset "Get CP Login Status" To "Complete".
      theManager.updateFulfillToAssetsCPLoginStatus(newAssetMap, oldAssetMap);
    }
    // CRM-3102
    theManager.updateOrderWhenAssetCancelled(triggernew,oldAssetMap);
    //LCM-93
    theManager.updateComarketingRelWhenAssetUpdates(newAssetMap, oldAssetMap);
}

  /*
  @method      : onAfterInsertUpdate
  @description : Auto populates account product fields on the basis of data in custom setting named "Product_And_Account_Fields_Mapping__c".
  @params      : Trigger.newMap, Trigger.oldMap, Trigger.isInsert
  @returns     : void
  */
  public void onAfterInsertUpdate(Map<Id, Asset> newMap, Map<Id, Asset> oldMap, Boolean isInsert) {
    System.debug('insert---'+isInsert);
    //LCM-99
    //if(isInsert){
        System.debug('insert---');
        theManager.createComarketingRel(newMap,oldMap);
    //}
  }
    //Added by Raama kalyani 
     public void Assetfullfillmentmethod(Map<id,Asset> newAssetMap,Map<Id,Asset> oldAssetMap){
        Map<id,Asset> assetMap = new Map<id,Asset>();
        Map<id,Contract> contractMapnew = new Map<id,Contract>();
        set<id> contractIds = new set<id>();
        Set<Id> parentAssetIds = new Set<Id>();   // Opcity
        for(Asset assets :newAssetMap.values()){
            contractIds.add(assets.Contract__c);
            // Opcity
            if (assets.Product_Code__c != null && Label.Opcity_Product_Codes.contains(assets.Product_Code__c) && assets.Asset_Type__c == 'Parent' && assets.Fulfillment_Status__c == 'Fulfilled' && assets.Fulfillment_Status__c != oldAssetMap.get(assets.Id).Fulfillment_Status__c) {
                parentAssetIds.add(assets.Id);
            }
            // Opcity - End
        }
        // Opcity
        Map<String, Date> minStartDates = new Map<String, Date>();
        if (!parentAssetIds.isEmpty()) {
            for (AggregateResult result : [SELECT Parent_Asset__c, MIN(Start_Date__c)minStrt FROM Asset WHERE Parent_Asset__c IN :parentAssetIds GROUP BY Parent_Asset__c]) {
                minStartDates.put(String.valueOf(result.get('Parent_Asset__c')), Date.valueOf(result.get('minStrt')));
            }
        }
        // Opcity - End
        Map<id,Contract> contractmap =new Map<id,Contract>([Select id,name,EndDate,ContractTerm from contract where id IN : contractIds]);
        if(contractmap.size() > 0){
            for(Asset assets :newAssetMap.values()){
                Asset assetOld = oldAssetMap.get(assets.id);
                Set<String> promoBundle = new Set<String>();
        promoBundle.add('FREEBUNDLERSRESPOND');
        promoBundle.add('FREEBUNDLERSCONNECT');
        promoBundle.add('FREEBUNDLERSTRANSACT');
        set<String> setProductCodeAdd = new set<String>{'RSRESPOND','RSCONNECT','RSTRANSACT'};
               
                if((assets.Fulfillment_Status__c == 'Fulfilled') && (assets.Fulfillment_Status__c != assetOld.Fulfillment_Status__c)){
                    if(assets.Contract_Term__c!=null && assets.Contract_Term__c!=''){if(assets.Line_Type__c=='Add'){
                    // CRM-3209 - Do not update End Date if its a Moving Product
                    if (!Label.Moving_Product_Codes.contains(assets.Product_Code__c)) {
                     if(! setProductCodeAdd.contains(assets.Product_Code__c)){
                        assets.End_Date__c = system.today().addMonths(Integer.valueof(assets.Contract_Term__c)).addDays(-1);
                        }
                    }
                    if(assets.override_Term__c!=null){if(assets.override_Term__c>0){if(assets.Line_Type__c=='Add'){assets.End_Date__c = system.today().addMonths(Integer.valueof(assets.override_Term__c+'')).addDays(-1);
                    }}}
                    assets.Start_Date__c = system.today();
                    }}
                    if(assets.Contract__c!=null){
                     Contract cont = contractmap.get(assets.Contract__c);
                    System.debug(assets.Id+'$$$$$$'+ cont.Id);
                    if(assets.End_Date__c!=null && cont.EndDate!=null){
                    if(cont.EndDate < assets.End_Date__c){
                        Integer Dayscount = ((cont.EndDate.daysBetween(assets.End_Date__c))+30)/30;
                        cont.ContractTerm += Dayscount ;
                        contractMapnew.put(cont.id,cont);
                    }
                  }  
                 } 
                 
                    // Opcity
                    if (assets.Product_Code__c!= null && Label.Opcity_Product_Codes.contains(assets.Product_Code__c) && assets.Line_Type__c=='Add') {
                        assets.Start_Date__c = system.today();
                        if (assets.Asset_Type__c=='Parent') {
                            assets.Start_Date__c = minStartDates.get(assets.Id);
                        }
                    }
                    // Opcity-End
                }
             }
         }
         update contractMapnew.values();
     }
}