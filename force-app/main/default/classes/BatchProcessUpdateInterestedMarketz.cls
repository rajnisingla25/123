global class BatchProcessUpdateInterestedMarketz implements Database.Batchable<sObject>{
    global String Query;
    global set<Id> setAccountIds;
    global BatchProcessUpdateInterestedMarketz(){
            // Query=q;
             //rendat= system.today().addDays(-60);
             //system.debug('####'+rendat);
             Query = 'Select Id,Name from Account LIMIT 1';
               }
     global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('####'+query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Account> accscope){
                       Map<String,Asset> mapUpsellAsset = new Map<String,Asset>();
          Set<Id> setAccountIds = new  Set<Id>();
          Set<String> setMarketIds = new  Set<String>();
          map<String,Inventory_Data__c> mapInventoryData = new map<String,Inventory_Data__c>();
          Map<String,Decimal> LECQuantityMap = new Map<String,Decimal>(); //CRM-5947
          Set<Id> cityAssetsAlreadyPicked = new Set<Id>();
          List<Asset> lstAssetOrder;
          if(Test.isRunningTest())
            lstAssetOrder = [Select Id,Name,AccountId,Product2.productCode,Market__c,Line_type__c, quantity,Asset_Type__c, status from Asset where DAY_ONLY(Last_order_activity_date__c) = Today and (Product2.productCode='COBROKE' OR Product2.productCode='LOCALEXPERT' OR Product2.productCode='LOCALEXPERTCITY')]; //DAP-168 added local expert productcode
          else
              lstAssetOrder = [Select Id,Name,AccountId,Product2.productCode,Market__c,Line_type__c, quantity,Asset_Type__c, Status from Asset where Last_order_activity_date__c = Today and (Product2.productCode='COBROKE' OR Product2.productCode='LOCALEXPERT' OR Product2.productCode='LOCALEXPERTCITY')]; //DAP-168 added local expert productcode
          
          for(Asset att:lstAssetOrder){
            setAccountIds.add(att.AccountId);
            
            
            if(att.product2.productcode == 'LOCALEXPERTCITY' && att.Asset_Type__c=='Parent' && att.status == 'Active'){ //CRM-5947
               cityAssetsAlreadyPicked.add(att.id);
               List<String> lstMarketString = att.market__c.split(', ');
               att.market__c = lstMarketString[1]+'-'+lstMarketString[0];
               system.debug('Key -->'+att.AccountId+'-'+att.market__c);
               if(LECQuantityMap.containskey(att.AccountId+'-'+att.market__c)){
                    
                    Decimal quan = LECQuantityMap.get(att.AccountId+'-'+att.market__c);
                    quan = quan+att.quantity;
                    LECQuantityMap.put(att.AccountId+'-'+att.market__c,quan);
                    system.debug('inside contains key '+quan);
                }else{
                    system.debug('inside the else key'+att.quantity);
                    LECQuantityMap.put(att.AccountId+'-'+att.market__c,att.quantity);
                }         
                
 
            }
            setMarketIds.add(att.Market__c);
            mapUpsellAsset.put(att.AccountId+''+att.Market__c+''+att.product2.productcode,att);
          }
          
         /* 
            Set<String> setStatusString = new Set<String>();
            setStatusString.add('Cancelled');
            setStatusString.add('Expired');
            Date todayDate = System.today();
            Date yesterdayDate = System.today().addDays(-1);
            for(Asset ast:[Select Id,AccountId,End_date__c,Status,Cancellation_Date__c from Asset where Status=:setStatusString and (End_date__c = Today OR End_date__c = Yesterday OR Cancellation_Date__c=Today OR Cancellation_Date__c=Yesterday) and Asset_Type__c='Parent' and Fulfillment_status__c='Fulfilled' and product2.productcode = 'LOCALEXPERTCITY']){
            if(ast.Status=='Expired' && (ast.End_date__c == todayDate || ast.End_date__c == yesterdayDate)){
            setAccountIds.add(ast.AccountId);
            }
            if(ast.Status=='Cancelled' && (ast.Cancellation_Date__c == todayDate)){
            setAccountIds.add(ast.AccountId);
            }
            }
         */ 
           for(Asset att:[Select QUANTITY, id, accountid, market__c,Product2.productCode,Name,Line_type__c, Asset_Type__c,Status from Asset where Product2.productCode='LOCALEXPERTCITY' and Asset_Type__c='Parent' and Status='Active' and AccountId in :setAccountIds]){
               if(!cityAssetsAlreadyPicked.contains(att.id)){
                   List<String> lstMarketString = att.market__c.split(', ');
                   att.market__c = lstMarketString[1]+'-'+lstMarketString[0];
                   if(LECQuantityMap.containskey(att.AccountId+'-'+att.market__c)){
                        Decimal quan = LECQuantityMap.get(att.AccountId+'-'+att.market__c);
                        quan = quan+att.quantity;
                        LECQuantityMap.put(att.AccountId+'-'+att.market__c,quan);
                    }else{
                        LECQuantityMap.put(att.AccountId+'-'+att.market__c,att.quantity);
                    }   
                    setAccountIds.add(att.AccountId);  
                    setMarketIds.add(att.Market__c);
            mapUpsellAsset.put(att.AccountId+''+att.Market__c+''+att.product2.productcode,att);     
            lstAssetOrder.add(att);
               }
           }
            system.debug('LECQuantityMap -->'+json.serialize(LECQuantityMap));
          for(Inventory_Data__c INVDD:[Select Id,name from Inventory_Data__c where Name=:setMarketIds]){
            mapInventoryData.put(INVDD.Name,INVDD);
          }
          system.debug('mapInventoryData -->'+json.serialize(mapInventoryData));
          Map<String,Inventory_account__c> IIAUpdate = new Map<String,Inventory_account__c>();  
                
          for(Asset assst:lstAssetOrder){
            
            if(mapInventoryData.containskey(assst.Market__c)){
            Inventory_account__c Iaa = new Inventory_account__c(); 
            Iaa.account__c = assst.AccountId;
            Iaa.Inventory_Data__c = mapInventoryData.get(assst.Market__c).id;
            //DAP-168
            if(assst.product2.productcode == 'COBROKE'){
                Iaa.has_assets__c = true;
            }
            if(assst.product2.productcode == 'LOCALEXPERT'){
                Iaa.has_assets_LE__c = true;
            }
            if(assst.product2.productcode == 'LOCALEXPERTCITY'){
                
                Iaa.has_assets_LEC__c = true;
                Iaa.Purchased_of_SOV10__c = LECQuantityMap.get(assst.accountId+'-'+assst.market__c); //CRM-5947
            }
           
            //DAP-168 ends
            IIAUpdate.put(assst.AccountId+'##'+assst.Market__c,Iaa);
            }
          }
         for(Inventory_account__c Iaa:[Select Id,name,account__c,Inventory_Data__r.Name,has_assets__c, has_assets_LE__c from Inventory_account__c where account__c=:setAccountIds and Inventory_Data__r.Name=:setMarketIds]){
            if(mapUpsellAsset.containskey(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'COBROKE')){ //DAP-168 added cobroke 
              if(mapUpsellAsset.get(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'COBROKE').Line_type__c=='cancel'){ //DAP-168 added cobroke 
                     Iaa.has_assets__c = false;
                } else{
                  Iaa.has_assets__c = true;
                }
           }
            if(mapUpsellAsset.containskey(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'LOCALEXPERT')){ //DAP-168 added LOCALEXPERT 
              if(mapUpsellAsset.get(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'LOCALEXPERT').Line_type__c=='cancel'){ //DAP-168 added LOCALEXPERT 
                  Iaa.has_assets_LE__c = false;
                } else{
                  Iaa.has_assets_LE__c = true;
                }
            }
            if(mapUpsellAsset.containskey(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'LOCALEXPERTCITY')){ //DAP-168 added LOCALEXPERT 
              system.debug('--- inside the upsell if for city --> ');
              if(mapUpsellAsset.get(Iaa.account__c+''+Iaa.Inventory_Data__r.Name+'LOCALEXPERTCITY').Line_type__c=='cancel'){ //DAP-168 added LOCALEXPERT 
                  system.debug('--- cancellation --> ');
                  system.debug('--- LEC Quanity --> '+LECQuantityMap.get(Iaa.account__c+'-'+Iaa.Inventory_Data__r.Name));

                  Iaa.has_assets_LEC__c = false;
                  Iaa.Purchased_of_SOV10__c = 0;
                } else{
                  system.debug('--- else loop --> ');
                  system.debug('--- LEC Quanity --> '+LECQuantityMap.get(Iaa.account__c+'-'+Iaa.Inventory_Data__r.Name));
                  Iaa.has_assets_LEC__c = true;
                  Iaa.Purchased_of_SOV10__c = LECQuantityMap.get(Iaa.account__c+'-'+Iaa.Inventory_Data__r.Name);
                }
            }
            IIAUpdate.put(Iaa.account__c+'##'+Iaa.Inventory_Data__r.Name,Iaa);
          }
          SYSTEM.DEBUG(JSON.serialize(IIAUpdate));
          upsert IIAUpdate.values();
                       }
                       global void finish(Database.BatchableContext BC){
                        
                       }
}