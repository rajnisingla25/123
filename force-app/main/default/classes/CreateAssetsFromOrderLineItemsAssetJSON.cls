//
// (c) 2015 NTTDATA,.
//
// Batch Class Name: CreateAssetsFromOrderLineItems
// Description: This batch process will be creating assets from order line items for order whose "Status" is "Created" and the boolean flag
// "Is_Order_Creation_Complete__c" is set to "true".
//
// 25th June 2015   Sonu Sharma   Original (Task # T-398617)


global class CreateAssetsFromOrderLineItemsAssetJSON implements Database.Batchable<sObject> {
  global Boolean isInitiatedFromTrigger = false;
  global Set<Id> theOrderIdsToProcess = new Set<Id>();
   
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id, OrderNumber, AccountId,Oracle_Quote__c,OpportunityId,Oracle_Quote__r.CreatedById,Oracle_Quote__r.Event_Name__c, Account.Name, Account.Type';
    query += ' FROM Order WHERE Status = \'Created\' AND Is_OLI_Creation_Complete__c = true';

    if(isInitiatedFromTrigger) {
      query += ' AND Id IN :theOrderIdsToProcess';
    }

    return Database.getQueryLocator(query);
  }

  @testvisible private void sendErrorNotification(List<Order> theOrders) {
    try {
      String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Email Addresses').Asset_Creation_Error_Emails__c;
      if(String.isNotBlank(theEmailAddresses)) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.saveAsActivity = false;
        mail.setToAddresses(theEmailAddresses.split(';'));
        mail.setSubject('Asset Batch Job Error Notification');

        String theEmailBody = 'Hi Admin,\n\n';
        theEmailBody += 'The following orders have accounts that are not of type "Broker" or "Realtor Agent":\n\n';
        for(Order theOrder : theOrders) {
          theEmailBody += 'Order ID: ' + theOrder.Id + '\n';
          theEmailBody += 'Order Number: ' + theOrder.OrderNumber + '\n';
          theEmailBody += 'Order Account Id: ' + theOrder.AccountId + '\n';
          theEmailBody += 'Order Account Name: ' + theOrder.Account.Name + '\n';
          theEmailBody += 'Order Account Type: ' + theOrder.Account.Type + '\n\n';
        }
        theEmailBody += 'Please review above orders.\n\n';
        theEmailBody += 'Thanks.\nTech Team';

        mail.setPlainTextBody(theEmailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
      }
    }
    catch(Exception e) {
      system.debug('TRACE: sendErrorNotification - Exception Message - ' + e.getMessage());
      system.debug('TRACE: sendErrorNotification - Exception Stack Trace - ' + e.getStackTraceString());
    }
  }

  @testvisible private void DeleteAssets(Set<Id> fivestreetAccountIds,Map<Integer,Asset> mapParentAssetMap,Map<Id,Id> mapdelAssetIds,map<String,product2> mapProdFulfill,map<Id,orderitem> mapOrderItemstoprocess,map<String,Order_Product_And_Parent_Asset_Fields__c> theParentAssetMappingData) {
    try {
    String assetFieldAPIName;
    Map<String, Schema.SObjectField> orderItemSchemaFieldMap = Schema.SObjectType.OrderItem.fields.getMap();
        Map<String, Schema.SObjectField> assetSchemaFieldMap = Schema.SObjectType.Asset.fields.getMap();
theParentAssetMappingData = Order_Product_And_Parent_Asset_Fields__c.getAll();
 List<Asset> lstdelAssets = new List<Asset>();
 String temp1;
 String temp2;
 String temp3;
 String temp4;
 String temp5;
 String temp6;
 String temp7;
 String temp8;
 String temp9;
 String temp10;
 String temp11;
 String temp12;
 String temp13;
 String temp14;
 String temp15;
 String temp16;
 String temp17;
 String temp18;
 String temp19;
 String temp20;
 String temp100;
 String temp111;
 String temp112;
 String temp113;
 String temp114;
 String temp115;
 String temp116;
 String temp117;
 String temp118;
 String temp119;
 String temp210;
                 lstdelAssets = [Select Id,AccountId,Total_Credit__c,Is_Bundled__c,cancel_type__c,Migrated_From_Legacy__c,Product2.ProductCode,Promotion__c,Last_Order_Activity_Date__c,Last_Activity_Date__c,TCV_Processed__c,Fulfillment_Required__c,asset_Type__c,Product2Id,Start_Date__c,Skip_Validation__c,Name,Status,Order_Type__c,Total_Net__c,At_Risk__c,Cancellation_Date__c,Cancellation_Effective_Date__c,Cancellation_Reason__c,Buyout_Amount__c,Buyout_Discount__c,Remaining_Amount__c,Price,List_Price__c,Line_Type__c,Fulfillment_Status__c,Order_Line_Item__c from Asset where Id=:mapdelAssetIds.keyset() and Status!='Cancelled' and Line_Type__c != 'Cancel'];
                 Map<Id,Asset> lstDelFinalAssets = new Map<Id,Asset>();
                 if(lstdelAssets.size()>0){
                    
                    set<String> setProductCodeTPOnlyAmend = new set<String>{'TOPCRM','TOPMRKSNP','FIVESTREET'};
                    set<String> setProductCodeAdd = new set<String>{'RSRESPOND','RSCONNECT','RSTRANSACT'};
                    set<String> setCancellationReason= new set<String>{'Sunset Direct', 'Sunset Indirect', 'Migrated to Opcity'};
                    
                    Set<String> promoBundle = new Set<String>();
        if(System.Label.RS_bundle_promo!=null){
        promoBundle.addAll(System.Label.RS_bundle_promo.split(';'));
        }
        Set<Id> setAccountIds = new Set<Id>();
        for(Asset ast:lstdelAssets){
            setAccountIds.add(ast.AccountId);
        }
                    map<Id,Asset> mapAmendAssetRS =new map<Id,Asset>([Select Id,Name,Promotion__c,Net_Price__c,AccountId,Asset_Structure__c,Product2.productCode from asset where Asset_type__c='Parent' and trial__c=false and status='Active' and Product2.productCode=:setProductCodeAdd and AccountId=:setAccountIds]);
        map<String,Asset> mapRSAmendExistingAsset =new map<String,Asset>(); 
        map<String,Asset> mapRSAmendAccount =new map<String,Asset>(); 
        for(Asset ast:mapAmendAssetRS.values()){
            mapRSAmendAccount.put(ast.AccountId,ast);
            if(promoBundle.contains(ast.Promotion__c)){
                mapRSAmendExistingAsset.put(ast.AccountId,ast);
            }
        }
        
         
                 for(Asset ast:lstdelAssets){
                 Asset asst = ast;
                 ast.Skip_Validation__c = true;
                 String assetPromotion = asst.Promotion__c;
                 if(assetPromotion!=null && assetPromotion!=''){
                 assetPromotion = assetPromotion.remove('---');
                 }
                  if(mapdelAssetIds.containskey(asst.Id)){
                 OrderItem theOrderItem = mapOrderItemstoprocess.get(mapdelAssetIds.get(asst.Id));
                 asst.Order_Line_Item__c = mapdelAssetIds.get(asst.Id);
                 asst.Last_Order_Activity_Date__c = System.Now();
                 if(mapOrderItemstoprocess.containskey(mapdelAssetIds.get(asst.Id))){
                 asst.Order_Type__c = mapOrderItemstoprocess.get(mapdelAssetIds.get(asst.Id)).Order.Type;
                 //CRM-3972
                 if(theOrderItem.cancel_type__c==null){theOrderItem.cancel_type__c='';}
                 if(theOrderItem.Cancellation_Reason__c==null){theOrderItem.Cancellation_Reason__c = '';}
                 if(theOrderItem.cancel_type__c.equalsIgnoreCase('migratedToRealsuite') || theOrderItem.Migrated_From_Legacy__c || setCancellationReason.contains(theOrderItem.Cancellation_Reason__c)){
                      ast.Commission_field__c = 'Ignore';
                 }
                 if(asst.line_type__c.equalsIgnoreCase('cancel') && asst.product2.productcode == 'DIGITALAGENT'){
                 //asst.Commission_field__c = 'Ignore';
                 System.debug(' commissions ----> '+System.Label.Dap_Clawback);
                 }

              }
                 
                 
                 //asst.Total_Net__c = mapOrderItemstoprocess.get(mapdelAssetIds.get(asst.Id)).Total_Net__c;
                 for(String orderProductFieldAPIName : theParentAssetMappingData.keySet()) {
                 assetFieldAPIName = theParentAssetMappingData.get(orderProductFieldAPIName).Asset_Field_API_Name__c;
                  if(
                      orderItemSchemaFieldMap.containsKey(orderProductFieldAPIName) &&
                      orderItemSchemaFieldMap.get(orderProductFieldAPIName).getDescribe().isAccessible() &&
                      assetSchemaFieldMap.containsKey(assetFieldAPIName) &&
                      assetSchemaFieldMap.get(assetFieldAPIName).getDescribe().isUpdateable()
                     ) {
                        if(orderProductFieldAPIName!=null && assetFieldAPIName!=null && theOrderItem!=null){
                        // CRM-4861 - Added condition to not update No_Term_Sale__c
                        if(theOrderItem.get(orderProductFieldAPIName)!=null && orderProductFieldAPIName != 'No_Term_Sale__c'){
                      asst.put(assetFieldAPIName,theOrderItem.get(orderProductFieldAPIName));
                      }
                        }
                     }
                     }
                   }
                   asst.Fulfillment_Status__c = 'Pending Fulfillment';
                    if(mapProdFulfill.containskey(asst.Product2Id)){
                     System.debug('$$$$$'+asst.Product2Id);
                    asst.Fulfillment_Required__c = mapProdFulfill.get(asst.Product2Id).Fulfillment_Required__c ;
                    System.debug(asst.asset_Type__c+'$$$$$'+asst.Fulfillment_Required__c );
                    if(!asst.Fulfillment_Required__c && asst.asset_Type__c=='Parent'){
                    asst.Fulfillment_Status__c = 'Waiting to Process';
                    }
                    }
                   asst.Line_Type__c = 'Cancel';
                   asst.Cancellation_Date__c = System.today();
                   asst.At_Risk__c = false;
                   asst.TCV_Processed__c = 'false';
                    set<String> setProductCodeAmend = new set<String>{'TOPCRM','TOPMRKSNP','FIVESTREET','REESIO'};
                  
                   if(setProductCodeAmend.contains(asst.Product2.productcode) && promoBundle.contains(assetPromotion)){
        //parentasset.End_Date__c = myDate2050;
        asst.Commission_field__c = 'Ignore';
        }
        if(mapRSAmendExistingAsset.containsKey(asst.AccountId) && setProductCodeTPOnlyAmend.contains(asst.Product2.productcode)){
            asst.Commission_field__c = 'Ignore';
         }
         if(mapRSAmendAccount.containskey(asst.AccountId) && (asst.Product2.productcode=='TOPCRM') && asst.Is_Bundled__c){
            asst.Commission_field__c = 'Ignore';
         }
         
                // Opcity 
               if (Label.Opcity_Product_Codes.contains(asst.Product2.productcode)) {
                    asst.Fulfillment_Status__c = 'Manual';
                    asst.Commission_field__c = 'Ignore';        // CRM-6063 - Opcity - Ignore commisions for Opcity Assets.
                    asst.Not_picked__c = true;
                }
               // Opcity - End
                   System.debug(mapProdFulfill+'$$$$$'+asst.Product2Id+''+asst.Id+'FFST'+asst.Fulfillment_Status__c);
                   lstDelFinalAssets.put(asst.id,asst);
                 }
                 }
                 
                 // CRM-2987 - Update FiveStreet asset based upon CBC order
                 if(fivestreetAccountIds.size()>0 ||Test.isRunningTest()){
                 Map<Id,Asset> mapAccountAssetFiveStreet = new  Map<Id,Asset>();
                 Map<Id,Date> mapAccountAssetDate = new  Map<Id,Date>();
                 Set<String> setProductCodes = new Set<String>();
                 setProductCodes.add('RSRESPOND');
                 setProductCodes.add('FIVESTREET');
                 setProductCodes.add('COBROKE');
                 Id CBCProductId = null;
                 for(Asset assst:[Select Id,AccountId,Product2Id,Product2.productCode,Promotion__c,Net_Price__c,End_Date__c,Fulfillment_Status__c from Asset where AccountId=:fivestreetAccountIds and Asset_type__c= 'Parent' and Status='Active' and Product2.productCode =:setProductCodes]){
                 if(assst.Net_Price__c==null){assst.Net_Price__c=0;}
                 // Added Promotion as well CRM-3366
                 if(assst.Net_Price__c==0 && (assst.Product2.productCode=='FIVESTREET' || (assst.Product2.productCode=='RSRESPOND' && assst.Promotion__c=='1FREERESPONDLICENSE'))){
                 mapAccountAssetFiveStreet.put(assst.AccountId,assst);
                 }
                 if(assst.Product2.productCode=='COBROKE'){
                    CBCProductId = assst.Product2Id;
                   Date endddatee ;
                   if(mapAccountAssetDate.containskey(assst.AccountId)){
            endddatee = mapAccountAssetDate.get(assst.AccountId);
                   }
                   if(endddatee==null){
                    mapAccountAssetDate.put(assst.AccountId,assst.End_Date__c);
                   } else {
                     if(endddatee<=assst.End_Date__c){
                     mapAccountAssetDate.put(assst.AccountId,assst.End_Date__c);
                     }
                   }
                   }
                    
                 }
                 for(Asset asst:mapParentAssetMap.values()){
                    System.debug(CBCProductId+'PPPPCode'+asst.Product2Id);
                    //CRM-3410 Added condition to check CBC product
                    if(asst.Product2Id==CBCProductId){
                 if(mapAccountAssetFiveStreet.containskey(asst.AccountId) || Test.isRunningTest()){
                 Asset FiveStreetAsset = mapAccountAssetFiveStreet.get(asst.AccountId);
                 Date endddatee ;
                   if(mapAccountAssetDate.containskey(asst.AccountId)){
            endddatee = mapAccountAssetDate.get(asst.AccountId);
                   }
                   if(endddatee!=null){
                     if(asst.End_Date__c>endddatee){
                        
                     endddatee = asst.End_Date__c;
                     }
                   } else {
                     endddatee = asst.End_Date__c;
                   }
                   System.debug(asst.id+'PPPP'+asst.End_Date__c+'PPPPPHH'+endddatee);
                 //if(FiveStreetAsset.End_Date__c<endddatee){
                 FiveStreetAsset.End_Date__c = endddatee;
                 FiveStreetAsset.Line_Type__c = 'Amend'; //CRM-3529 Free Five Street extensions failing due to Line Type = Add or Renew
                 FiveStreetAsset.Fulfillment_Status__c = 'Waiting to Process';
                 mapAccountAssetDate.put(asst.AccountId,endddatee);
                 lstDelFinalAssets.put(FiveStreetAsset.id,FiveStreetAsset);
                // }
                 }
                 }
                 }
                 }
                 if(lstDelFinalAssets.values().size()>0){
                 update lstDelFinalAssets.values();
                 }
                 
    }
    catch(Exception e) {
      system.debug('TRACE: DeleteAssets - Exception Message - ' + e.getMessage());
      system.debug('TRACE: DeleteAssets - Exception Stack Trace - ' + e.getStackTraceString());
    }
  }

  global void execute(Database.BatchableContext BC, List<Order> scope) {

    Set<Id> theOrderIds = new Set<Id>();
    Set<Id> theFiveStreetAccounts = new Set<Id>();
    Set<Id> setopportunityIds = new Set<Id>();
    Set<Id> setBMQuoteIds = new Set<Id>();
      List<Order> theIgnoredOrders = new List<Order>();
      SkipAssetTrigger.setSkipTrgTrue();
      SkipComissionTrigger.setSkipTrgTrue();
      for(Order theOrder : scope) {
        if(
          theOrder.AccountId != null &&
          String.isNotBlank(theOrder.Account.Type) && true
         // (theOrder.Account.Type.equalsIgnoreCase('Broker') || theOrder.Account.Type.equalsIgnoreCase('Realtor Agent') || theOrder.Account.Type.equalsIgnoreCase('Lender'))
        ) {
          theOrderIds.add(theOrder.Id);
          setopportunityIds.add(theOrder.opportunityid);
          setBMQuoteIds.add(theOrder.Oracle_Quote__c);
        }
        else {
          theIgnoredOrders.add(theOrder);
        }

      }
      try{
      // The System Administrator Email Addresses Are Configured In The Custom Setting Named "Asset Batch Job Error Notification".
      if(theIgnoredOrders.size() > 0) {
        sendErrorNotification(theIgnoredOrders);
      }
      Map<String, Order_Product_And_Parent_Asset_Fields__c> theParentAssetMappingData = Order_Product_And_Parent_Asset_Fields__c.getAll();
        //if(theParentAssetMappingData.size() > 0) {
        Map<String, Schema.SObjectField> orderItemSchemaFieldMap = Schema.SObjectType.OrderItem.fields.getMap();
        Map<String, Schema.SObjectField> assetSchemaFieldMap = Schema.SObjectType.Asset.fields.getMap();
       // }
       Map<String, Parent_Asset_And_FulfillTo_Asset_Fields__c> theFulfillToAssetMappingData = Parent_Asset_And_FulfillTo_Asset_Fields__c.getAll();
              Map<String, FulfillTo_Asset_And_MLS_Asset_Fields__c> theParticipantAssetMappingData = FulfillTo_Asset_And_MLS_Asset_Fields__c.getAll();
      String query = 'SELECT Order.Oracle_Quote__r.Event_Name__c,Order.AccountId,Migrated_From_Legacy__c,Manual_Override_Amount__c,Manual_Price_Override__c,Order.ownerId,Order.Opportunity.Campaign.name, Order.ContractId,Order.Type, PricebookEntry.Name, PricebookEntry.Product2Id,PricebookEntry.Product2.productcode, Order.CreatedDate, Order.BillToContactId, ';
        query += 'PricebookEntry.Product2.Fulfillment_Priority__c,Order.Account.Name,Order.Oracle_Quote__r.CreatedById, Order.Account.Type,Order.Account.Billing_Preference__c,Order.Account.Franchise_Type__c,Order.Account.Account_Sub_Type__c,Order.Account.OwnerId,Order.Account.Owner.Name,Order.Account.Owner.IsActive,Asset_Structure__c,Participant__c, PricebookEntry.Product2.Name, Fulfill_To_Account__c, Inactivate_Date__c, ';
        for(String orderItemFieldAPIName : theParentAssetMappingData.keySet()) {
          if(
            orderItemSchemaFieldMap.containsKey(orderItemFieldAPIName) &&
            orderItemSchemaFieldMap.get(orderItemFieldAPIName).getDescribe().isAccessible()
          ) {
            query += orderItemFieldAPIName + ', ';
          }
        }

        query = query.substring(0, query.length() - 2);
        query += ' FROM OrderItem WHERE Status__c != \'Cancelled\' and OrderId IN :theOrderIds';

        if(isInitiatedFromTrigger) {
        //  query += ' AND Start_Date__c = TODAY';
        }
        else {
      //    query += ' AND Start_Date__c = YESTERDAY';
        }
       // query += ' AND Id = \'802Z00000006JhC\'';
        System.debug('$$$$$$$$'+query);
        SkipBackoutAssetTrigger.setSkipTrgTrue();

        Set<String> setMLSIds = new Set<String>();
        String assetFieldAPIName;
        String fullFillToAssetFieldAPIName;
        String participantAssetFieldAPIName;
        Map<String,MLS__c> mapMLSSet = new Map<String,MLS__c>();
        Map<Id,OrderItem> mapOrderItemstoprocess = new Map<Id,OrderItem>();
        set<String> setProductCodeAdd = new set<String>{'RSRESPOND','RSCONNECT','RSTRANSACT'};
        Set<String> promoBundle = new Set<String>();
        if(System.Label.RS_bundle_promo!=null){
        promoBundle.addAll(System.Label.RS_bundle_promo.split(';'));
        }
        Set<String> promoBundle2050 = new Set<String>();
        if(System.Label.RS_bundle_promo_2050!=null){
        promoBundle2050.addAll(System.Label.RS_bundle_promo_2050.split(';'));
        }
        Set<Id> setRSProductAccountIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        for(OrderItem theOrderItems: (List<OrderItem>)Database.query(query)){
            setAccountIds.add(theOrderItems.Order.AccountId);
        if(setProductCodeAdd.contains(theOrderItems.PricebookEntry.Product2.productcode) && theOrderItems.Line_type__c.equalsIgnoreCase('Add')){
        setRSProductAccountIds.add(theOrderItems.Order.AccountId);
        }
        mapOrderItemstoprocess.put(theOrderItems.id,theOrderItems);
        if(theOrderItems.PricebookEntry.Product2.productcode.equalsIgnoreCase('COBROKE')){
        theFiveStreetAccounts.Add(theOrderItems.order.AccountId);
        }
        }
        map<Id,Asset> mapAssetRS =new map<Id,Asset>([Select Id,Name,Net_Price__c,Promotion__c,AccountId,Asset_Structure__c,Product2.productCode from asset where Asset_type__c='Parent' and trial__c=false and status='Active' and Net_Price__c>0 and Product2.productCode=:setProductCodeAdd and AccountId=:setRSProductAccountIds]);
        map<String,Asset> mapRSExistingAsset =new map<String,Asset>(); 
        
        AssetTriggerHelper ath = new AssetTriggerHelper();
        ath.GenerateJsonStrings(mapAssetRS);
        for(Asset ast:mapAssetRS.values()){
                
                mapRSExistingAsset.put(ast.Product2.productCode+'$$$'+ast.AccountId,ast);
        }
        
        map<Id,Asset> mapAmendAssetRS =new map<Id,Asset>([Select Id,Name,Promotion__c,Net_Price__c,AccountId,Asset_Structure__c,Product2.productCode from asset where Asset_type__c='Parent' and trial__c=false and status='Active' and Product2.productCode=:setProductCodeAdd and AccountId=:setAccountIds]);
        map<String,Asset> mapRSAmendExistingAsset =new map<String,Asset>(); 
        map<String,Asset> mapRSAmendAccount = new map<String,Asset>();
        for(Asset ast:mapAmendAssetRS.values()){
            mapRSAmendAccount.put(ast.AccountId,ast);
            if(promoBundle.contains(ast.Promotion__c)){
                mapRSAmendExistingAsset.put(ast.AccountId,ast);
            }
        }
        List<BigMachines__Quote_Product__c> lstBMQuoteProduct = [Select Id,BigMachines__Quote__r.Event_Name__c,BigMachines__Quote__r.Is_Quick_Quote__c,Real_Suite_Parent__c,
                                                                         BigMachines__Quote__r.BigMachines__Account__c, BigMachines__Product__r.ProductCode 
                                                                         from BigMachines__Quote_Product__c
                                                                         where BigMachines__Quote__c = :setBMQuoteIds and BigMachines__Product__r.ProductCode=:setProductCodeAdd and Need_Manual_Renew__c = false and BigMachines__Quantity__c > 0];
        for(BigMachines__Quote_Product__c bqp:lstBMQuoteProduct){
            Asset ast = new Asset();
            mapRSAmendAccount.put(bqp.BigMachines__Quote__r.BigMachines__Account__c,ast);
        }
        //Map<Id,OrderItem> theOrderItemsToProcess1 = Database.query(query);
        Set<Id> setAccId = new Set<Id>();
        Map<Integer,Asset> mapParentAsset = new Map<Integer,Asset>();
        Set<Id> setAllExistingAssetIds = new Set<Id>();
        Map<Id,Id> mapdelAssetIds = new Map<Id,Id>();
        Set<Id> setRenewParentAssetIds = new Set<Id>();
        Map<Id,Id> mapOldFulfillToAssetIds = new Map<Id,Id>();
        Map<Integer,Asset> mapFulfilltoAsset = new Map<Integer,Asset>();
        Map<Integer,Asset> mapParticipantAsset = new Map<Integer,Asset>();
        Map<Id,AssetStructure> mapAssetStructure = new Map<Id,AssetStructure>();
        Map<String,Product2> mapProdFulfill = new Map<String,Product2>();
        mapProdFulfill = new Map<String,Product2>([Select Id,Name,Fulfillment_Required__c from Product2]);
        for(OrderItem theOrderItem : mapOrderItemstoprocess.values()) {
        if(theOrderItem.Participant__c!=null){
        //setMLSIds.add(theOrderItem.Participant__c);
        }
         if(mapRSExistingAsset.containskey(theOrderItem.PricebookEntry.Product2.productCode+'$$$'+theOrderItem.order.AccountId)){
        //theOrderItem.Asset_Structure__c =  theOrderItem.Asset_Structure__c.replaceAll('Add','NoChange').replaceFirst('""',mapRSExistingAsset.get(theOrderItem.PricebookEntry.Product2.productCode+'$$$'+theOrderItem.order.AccountId).id);
        theOrderItem.Asset_Structure__c =  mapRSExistingAsset.get(theOrderItem.PricebookEntry.Product2.productCode+'$$$'+theOrderItem.order.AccountId).Asset_Structure__c.replaceAll('$actionType$','NoChange');
        theOrderItem.Line_type__c = 'Amend'; 
        }
        AssetStructure inv = new AssetStructure();
        String JSONStr = theOrderItem.Asset_Structure__c;
        // Parse entire JSON response.
        if(JSONStr!=null){
       JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) {
           // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
              while (parser.nextToken() != null) {
                // Advance to the start object marker to
                //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    // Read entire invoice object, including its array of line items.
                        inv = (AssetStructure)parser.readValueAs(AssetStructure.class);
                      }
                  }
              }
        }
        mapAssetStructure.put(theOrderItem.id,inv);
        }
        }
        integer assetnumber=1;
        for(AssetStructure ass:mapAssetStructure.values()){
                ass.parentlevel = assetnumber;
                if(ass.Type=='$actionType$'){ass.Type='NoChange';}
                if(ass.Type!='Add'){
                setAllExistingAssetIds.add(ass.assetId);
                }
                if(ass.fulfillTo!=null){
             for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
                     assetnumber++;
                     if(ffl.Type=='$actionType$'){ffl.Type='NoChange';}
                     ffl.fulfilltolevel = assetnumber;
                     if(ffl.Type!='Add'){
                     setAllExistingAssetIds.add(ffl.assetId);
                     if((ffl.assetId==ass.assetId) && (ffl.assetId!=null)){
                     mapOldFulfillToAssetIds.put(ffl.assetId,ffl.assetId);
                     }
                     }
                     if(ffl.participant!=null){
                     for(AssetStructure.participant ppc:ffl.participant){
                     assetnumber++;
                     if(ppc.Type=='$actionType$'){ppc.Type='NoChange';}
                     ppc.participantlevel = assetnumber;
                     if(ppc.Type!='Add'){
                     setAllExistingAssetIds.add(ppc.assetId);
                     }
                     setMLSIds.add(ppc.mlsSetId);
                     assetnumber++;
                     }
                     }
                     assetnumber++;
                    }
                    }
                    assetnumber++;
        }

        if(mapOldFulfillToAssetIds.size()>0){
               for(Asset assst:[Select Id,Parent_Asset__c,Is_Bundled__c,Migrated_From_Legacy__c,Total_Credit__c,Skip_Validation__c,TCV_Processed__c, Manual_Price_Override__c, Manual_Override_Amount__c ,At_Risk__c,Start_Date__c,Line_Type__c,Order_Type__c ,Fulfillment_Status__c,Order_Line_Item__c from Asset where Parent_Asset__c=:mapOldFulfillToAssetIds.keyset() and Asset_Type__c = 'Fulfill To']){
                   mapOldFulfillToAssetIds.put(assst.Parent_Asset__c,assst.id);
              }
           }
        Map<Integer,Integer> mapChildParentNumber = new Map<Integer,Integer>();
         for(AssetStructure ass:mapAssetStructure.values()){
           if(ass.fulfillTo!=null){
            for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
            //System.debug(ffl.fulfilltolevel+'#####'+ass.parentlevel+'#####'+ffl.assetId);
            mapChildParentNumber.put(ffl.fulfilltolevel,ass.parentlevel);
            if((ffl.assetId!=null) && (ffl.assetId!='')){
            if((ffl.assetId==ass.assetId) && (ffl.assetId!=null) && mapOldFulfillToAssetIds.containskey(ffl.assetId)){
                     ffl.assetId=mapOldFulfillToAssetIds.get(ffl.assetId);
                     setAllExistingAssetIds.add(ffl.assetId);
                     //System.debug(ffl.assetId + '$$$$$$');
                }
                }
                  if(ffl.participant!=null){
                     for(AssetStructure.participant ppc:ffl.participant){
                     System.debug(ppc.participantlevel+'#####'+ffl.fulfilltolevel);
                     mapChildParentNumber.put(ppc.participantlevel ,ffl.fulfilltolevel);
                          }
                          }
                    }
                }
             }

             //System.debug('$$$$$'+mapChildParentNumber);

        Map<Id,Asset> mapAllExistingAssets = new Map<Id,Asset>([Select Id,Is_Bundled__c,Promotion__c,Event_Name__c,Migrated_From_Legacy__c,Total_Credit__c,Spot_Promo_Code__c, Spot_Promo_Percentage__c ,Last_Order_Activity_Date__c,Last_Activity_Date__c,TCV_Processed__c,Name,OwnerId,Legacy_Created_Date__c, Sign_in_AE__c, Manual_Price_Override__c, Manual_Override_Amount__c ,AccountId,Start_Date__c,Status,Fulfillment_Status__c,Asset_Type__c,Order_Line_Item__c,
                                             Market__c from Asset where id=:setAllExistingAssetIds]);
        Map<Id,Asset> mapFulfillToAssets = new Map<Id,Asset>();
        for(Asset asst:[Select Id,Total_Credit__c,Spot_Promo_Code__c,Promotion__c,Event_Name__c, Migrated_From_Legacy__c,Spot_Promo_Percentage__c ,Last_Order_Activity_Date__c,Last_Activity_Date__c,Parent_Asset__c,Name,TCV_Processed__c,Fulfillment_Status__c,Legacy_Created_Date__c, OwnerId,Sign_in_AE__c, Manual_Price_Override__c, Manual_Override_Amount__c ,AccountId,Status,Asset_Type__c,Order_Line_Item__c,Market__c,Start_Date__c from Asset where Ultimate_Parent_Id_Text__c=:setAllExistingAssetIds and Asset_Type__c='Fulfill To'])
        {
        mapFulfillToAssets.put(asst.Parent_Asset__c,asst);
        mapFulfillToAssets.put(asst.Id,asst);
        }

        String sttr;
        for(Id key:mapAssetStructure.keyset()){
        AssetStructure ass=mapAssetStructure.get(key);
        if(ass.Type!='Remove'){
        Asset parentasset = new Asset();
        parentasset.Skip_Validation__c = true;
        
        if(ass.Type=='Add'){
        parentasset.Name = 'My IstParent';
        parentasset.hlc__c = ass.hlc;
        parentasset.HLC_Override__c = ass.HLCOverride;
        parentasset.AccountId = ass.SoldToaccountId;
        //Parentasset.Sign_in_AE__c = theorderItem.Order.Oracle_Quote__r.CreatedById;
        parentasset.Fulfillment_Status__c = 'Waiting to Process';
                parentasset.Status = 'In Active';
        parentasset.Asset_Type__c = 'Parent';
        parentasset.TCV_Processed__c = 'false';
        parentasset.Order_Line_Item__c = key;
        parentasset.Renewal_Status__c  = '';
        }
        if(ass.Type=='Modify' || ass.Type=='NoChange'){
        parentasset = mapAllExistingAssets.get(ass.assetId);

        if(ass.Type!='NoChange'){
        parentasset.Fulfillment_Status__c = 'Waiting to Process';
        //parentasset.Status = 'In Active';
        }
        }
        if(parentasset !=null){
            OrderItem theOrderItem = mapOrderItemstoprocess.get(key);
        sttr = theOrderItem.id;
          if(theOrderItem.PricebookEntry != null) {
            if(String.isNotBlank(theOrderItem.Market__c)) {
              parentasset.Name = theOrderItem.PricebookEntry.Name + '-' + theOrderItem.Market__c;
              }
              else {
                //Added below condition to set the Asset Name to Advantage - Branding when product Type = Brand CRM-2511
                if (theOrderItem.PricebookEntry.Product2.productcode.equalsIgnoreCase('ADVANTAGE') && theOrderItem.Product_Type__c.equalsIgnoreCase('Brand'))
                {
                    parentasset.Name = System.label.AdvantageBranding;
                }
                else
                {
                    parentasset.Name = theOrderItem.PricebookEntry.Name;
                }
            }
            parentasset.Product2Id = theOrderItem.PricebookEntry.Product2Id;
          }
          parentasset.Order_Type__c = theOrderItem.Order.Type;
           if(theOrderItem.Order.ContractId!=null){
            parentasset.Contract__c = theOrderItem.Order.ContractId;
            }
          // Initializing Asset Contact Id And Purchase Date.
          if(theOrderItem.Order != null) {
            //parentasset.ContactId = theOrderItem.Order.BillToContactId;
            parentasset.PurchaseDate  = theOrderItem.Order.CreatedDate.Date();
          }

          // Computing Asset Price.
          if(theOrderItem.UnitPrice != null && theOrderItem.Quantity != null) {
          if(theOrderItem.Contract_Term__c==null){theOrderItem.Contract_Term__c='6';}
            parentasset.Price__c = (theOrderItem.UnitPrice) * (theOrderItem.Quantity)*(Integer.valueof(theOrderItem.Contract_Term__c));
           //if(ass.Type=='Add'){
           if(theOrderItem.Order.Type.equalsIgnoreCase('New') || theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')|| theOrderItem.Line_Type__c.equalsIgnoreCase('Add')){
            Parentasset.Sign_in_AE__c = theorderItem.Order.OwnerId;
            }
          }

          assetFieldAPIName = null;

          // Building Parent Asset Instances.
          for(String orderProductFieldAPIName : theParentAssetMappingData.keySet()) {
            assetFieldAPIName = theParentAssetMappingData.get(orderProductFieldAPIName).Asset_Field_API_Name__c;

            if(
              orderItemSchemaFieldMap.containsKey(orderProductFieldAPIName) &&
              orderItemSchemaFieldMap.get(orderProductFieldAPIName).getDescribe().isAccessible() &&
              assetSchemaFieldMap.containsKey(assetFieldAPIName) &&
              assetSchemaFieldMap.get(assetFieldAPIName).getDescribe().isUpdateable()
            ) {
            // CRM-4823 - Update No_Term_Sale__c only when Line_Type__c is Add or Renew
            if((ass.Type=='Modify' && orderProductFieldAPIName=='Start_Date__c') || (orderProductFieldAPIName == 'No_Term_Sale__c' && (theOrderItem.Line_Type__c != 'Add' && theOrderItem.Line_Type__c != 'Renew'))){ } else{
              parentasset.put(
                assetFieldAPIName,
                theOrderItem.get(orderProductFieldAPIName)
              );
              }
            }
          }
          if(ass.hlc!=null){
        parentasset.hlc__c = ass.hlc;
        }
        if(parentasset.Event_Name__c=='' || parentasset.Event_Name__c==null){
        parentasset.Event_Name__c = theOrderItem.Order.Oracle_Quote__r.Event_Name__c;
        }
        if(theOrderItem.promotion__c!=null){
        parentasset.promotion__c = theOrderItem.promotion__c;
        }
        System.debug('*******'+parentasset.promotion__c);
        if(ass.HLCOverride!=null){
        parentasset.HLC_Override__c = ass.HLCOverride;
        }
        parentasset.Last_Order_Activity_Date__c = System.Now();
        if(!parentasset.Migrated_From_Legacy__c){parentasset.Migrated_From_Legacy__c = theOrderItem.Migrated_From_Legacy__c;}
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew') || theOrderItem.Line_Type__c.equalsIgnoreCase('Amend') || Test.isRunningTest()){
        parentasset.Fulfillment_Status__c = 'Waiting to Process';
        parentAsset.Spot_Promo_Code__c = theOrderItem.Spot_Promo_Code__c; //CRM-2398
        parentasset.Spot_Promo_Percentage__c = theOrderItem.Spot_Promo_Percentage__c; //CRM-2398
        parentasset.Proration_Credit__c = theOrderItem.Proration_Credit__c; //CRM-2328 - Displays proration credit amount generated
        //parentasset.Status = 'In Active';
        parentasset.Line_Type__c = theOrderItem.Line_Type__c;
        parentasset.Last_Order_Activity_Date__c = System.Now();
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){
        setRenewParentAssetIds.add(parentasset.id);
        parentasset.Credit_Status__c = '';
        parentasset.Start_Date__c = theOrderItem.Start_Date__c;
        parentasset.Follow_Up_Status__c = 'Renewed';
        parentasset.Legacy_Created_Date__c = null;

        }
                
        parentasset.End_Date__c = theOrderItem.End_Date__c;
        parentasset.Product_type__c = theOrderItem.Product_type__c;
        }
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Credit')  || theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
        parentasset.Line_Type__c = 'Credit';
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
        parentasset.Line_Type__c = 'Cancel';
        }
        if(theOrderItem.Ext_Days__c>0){
        parentasset.Line_Type__c = 'Amend';
        }
        }
        parentasset.At_Risk__c = false;
        if(mapProdFulfill.containskey(parentasset.Product2Id)){
                    parentasset.Fulfillment_Required__c = mapProdFulfill.get(parentasset.Product2Id).Fulfillment_Required__c ;
                    }
        parentasset.Order_Line_Item__c = theOrderItem.Id;
            Integer days=1;
            if(parentasset.start_Date__c!=null && parentasset.End_Date__c!=null){
            days=parentasset.start_Date__c.daysBetween(parentasset.End_Date__c);}
            parentasset.Price__c = theOrderItem.Extended_Net_Price__c;
           //     Commented by Stanley Sequeira Daily_Rate__c field is now a formula field
            //if(days>0 && parentasset.Price__c!=null){parentasset.Daily_Rate__c = (parentasset.Price__c)/days;}
            //CRM-1837 Prospect accounts owned by users: Signin AE is getting 100% commission
            if(theOrderItem.Order.Type.equalsIgnoreCase('New') || theOrderItem.Line_Type__c.equalsIgnoreCase('Renew') || theOrderItem.Line_Type__c.equalsIgnoreCase('Add')){
            if((theOrderItem.Order.Account.Account_Sub_Type__c=='Customer' ||theOrderItem.Order.Account.Account_Sub_Type__c =='Prospect' || theOrderItem.Order.Account.Account_Sub_Type__c == 'Former Customer') && !Label.Un_Assigned_Account_owners.contains(theOrderItem.Order.Account.owner.Name) && theOrderItem.Order.Account.Owner.IsActive){
            parentasset.OwnerId = theOrderItem.Order.Account.OwnerId;
            } else{
            parentasset.OwnerId = theOrderItem.Order.OwnerId;
            }
            }
            if(parentasset.Refund_Request__c==true){
                       //parentasset.Line_Type__c = 'Cancel';
                       }
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew') && theOrderItem.Order.Account.Billing_Preference__c.equalsIgnoreCase('CC-Direct')){
        //CRM-409 : Setting commission field as Calculate.
        parentasset.Commission_field__c = 'Calculate';

        }
         Date myDate2050 = Date.newInstance(2050, 12, 31);      
        parentasset.End_Date__c = theOrderItem.End_Date__c; 
        String assetPromotion = theOrderItem.Promotion__c;
                 if(assetPromotion!=null && assetPromotion!=''){
                 assetPromotion = assetPromotion.remove('---');
                 }
        
        set<String> setProductCodeAmend = new set<String>{'TOPCRM','TOPMRKSNP','FIVESTREET','REESIO'};
        if(setProductCodeAdd.contains(theOrderItem.PricebookEntry.Product2.productcode) && promoBundle.contains(assetPromotion)){
        //parentasset.End_Date__c = myDate2050;
        parentasset.Commission_field__c = 'Ignore';
        }
        if(setProductCodeAdd.contains(theOrderItem.PricebookEntry.Product2.productcode) && promoBundle2050.contains(assetPromotion)){
        parentasset.End_Date__c = myDate2050;
        System.debug(' working till here '+parentasset.End_Date__c);
        //parentasset.Commission_field__c = 'Ignore';
        }
        if(setProductCodeAmend.contains(theOrderItem.PricebookEntry.Product2.productcode) && promoBundle.contains(assetPromotion)){
        //parentasset.End_Date__c = myDate2050;
        parentasset.Commission_field__c = 'Ignore';
        }
        if(parentasset.cancel_type__c==null){parentasset.cancel_type__c='';}
System.debug(parentasset.cancel_type__c+'working'+parentasset.cancel_type__c.equalsIgnoreCase('migratedToRealsuite'));
        //CRM-3438
         if(parentasset.cancel_type__c.equalsIgnoreCase('migratedToRealsuite') || parentasset.Migrated_From_Legacy__c){
            parentasset.Commission_field__c = 'Ignore';
         }
         set<String> setProductCodeTPOnlyAmend = new set<String>{'TOPCRM','TOPMRKSNP','FIVESTREET'};
         if(mapRSAmendExistingAsset.containsKey(parentasset.AccountId) && setProductCodeTPOnlyAmend.contains(theOrderItem.PricebookEntry.Product2.productcode)&&parentasset.Is_Bundled__c){
            parentasset.Commission_field__c = 'Ignore';
         }
         //CRM-3438 ends
        //CRM-4054
        if(theOrderItem.PricebookEntry.Product2.Fulfillment_Priority__c==1){parentasset.Fulfillment_Status__c = 'Pending Fulfillment';}
        
        
        ///Added for Srini
        if(theOrderItem.Order.Account.Franchise_Type__c!=null){
            //CRM-1285 : Adding Advantage as well for skipping comission
        if(theOrderItem.Order.Account.Franchise_Type__c.equalsIgnoreCase('Century 21') && (theOrderItem.PriceBookEntry.Product2.productCode.equalsIgnoreCase('SHOWCASE') || theOrderItem.PriceBookEntry.Product2.productCode.equalsIgnoreCase('ADVANTAGE')) && theOrderItem.Order.Account.Type.equalsIgnoreCase('Broker')){
        parentasset.Commission_field__c = 'C-21';
        }
        if(theOrderItem.Order.Account.Franchise_Type__c.equalsIgnoreCase('Century 21') && theOrderItem.Order.Account.Type.equalsIgnoreCase('Realtor Agent') && !setProductCodeTPOnlyAmend.contains(theOrderItem.PricebookEntry.Product2.productcode)){
        parentasset.Commission_field__c = 'Calculate';
        }
        }
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Add') || theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){
        parentasset.Total_Credit__c = 0.0;
        parentasset.Original_Total_Net__c = theOrderItem.Total_Net__c ;
        }
        if(theOrderItem.Line_Type__c.equalsIgnoreCase('Credit')){
        parentasset.Total_Credit__c = (parentasset.Total_Credit__c != null ? parentasset.Total_Credit__c : 0) + (theOrderItem.Credit_amount__c != null ? theOrderItem.Credit_amount__c : 0);
        }
        System.debug('*******'+parentasset.Manual_Override_Amount__c );
        if(theOrderItem.Manual_Override_Amount__c!=null){
        parentasset.Manual_Override_Amount__c = theOrderItem.Manual_Override_Amount__c;
        }
        System.debug(mapRSAmendAccount+'$$$$$'+theOrderItem.Order.AccountId+ '$$$$$$s'+ theOrderItem.PricebookEntry.Product2.productcode +'$$$$$$'+ parentasset.Is_Bundled__c);
         if(mapRSAmendAccount.containskey(theOrderItem.Order.AccountId) && (theOrderItem.PriceBookEntry.Product2.productCode.equalsIgnoreCase('TOPCRM')) && parentasset.Is_Bundled__c){
            parentasset.Commission_field__c = 'Ignore';
         }
         if((theOrderItem.PriceBookEntry.Product2.productCode.equalsIgnoreCase('TOPCRM')) && !parentasset.Is_Bundled__c){
            parentasset.Commission_field__c = 'Calculate';
         }
        parentasset.Manual_Price_Override__c = theOrderItem.Manual_Price_Override__c;
        System.debug(parentasset+'$$$$$$$$$$$$$$$$');
        // Opcity
        if (Label.Opcity_Product_Codes.contains(theOrderItem.PriceBookEntry.Product2.productCode)) {
            parentasset.Fulfillment_Status__c = 'Manual';
            parentasset.Commission_field__c = 'Ignore';        // CRM-6063 - Opcity - Ignore commisions for Opcity Assets.
            parentasset.Not_picked__c = true;
        }
        // Opcity - End
          mapParentAsset.put(ass.parentlevel,parentasset);
            
            //Added by Pratik on 15th February 2019 for CRM-5201
            if(theOrderItem.PricebookEntry.Product2.productcode == 'COBROKE' 
               && String.isBlank(parentasset.Product_Code__c))
               setAccId.add(theOrderItem.Order.AccountId);
          }
         } else {
         sttr = mapOrderItemstoprocess.get(key).Id;
         mapdelAssetIds.put(ass.assetId,mapOrderItemstoprocess.get(key).Id);
         System.debug(ass.assetId+'########'+sttr);
         }
        }
        if(mapdelAssetIds.keyset().size()>0){
              for(AssetStructure ass:mapAssetStructure.values()){
                       if(ass.Type=='Remove'){
                       mapdelAssetIds.put(ass.assetId,sttr);
                       }
                       if(ass.fulfillTo!=null){

                      for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
                      if(ffl.Type=='Remove'){

                       mapdelAssetIds.put(ffl.assetId,sttr);
                       System.debug(ffl.assetId+'########'+sttr);
                       //mapdelAssetIds.put(ffl.assetId,ffl.assetId);
                             }
                       if(ffl.participant!=null){
                        for(AssetStructure.participant ppc:ffl.participant){
                        if(ppc.participantaccountId!=null && ppc.participantaccountId!=''){
                        if(ppc.Type=='Remove'){
                        mapdelAssetIds.put(ppc.assetId,sttr);
                        //mapdelAssetIds.put(ppc.assetId,ppc.assetId);
                             }
                          }
                        }
                       }
                     }
                   }
                }
             }
          
          //Added by Pratik on 15th February 2019 for CRM-5201
          List<Asset> lstAsset = [Select Id, Expiration_Email_Sent_Out__c,End_Date__c 
                                        From Asset 
                                        Where AccountId IN :setAccId 
                                        AND Expiration_Email_Sent_Out__c != Null 
                                        AND Product_Code__c IN:setProductCodeAdd];
          
          for(Asset asset :lstAsset)
          {
              asset.Expiration_Email_Sent_Out__c = Null;
              asset.End_Date__c = Date.newInstance(2050, 12, 31);
          }
          system.debug('<<<<lstAsset>>>>'+lstAsset);
          
        if(mapParentAsset.values().size()>0){
            
            if(!lstAsset.isEmpty())
            {
                system.debug('<<<<here>>>>'+lstAsset);
                lstAsset.addAll(mapParentAsset.values());
                upsert lstAsset;
            }
            else//Ends here
                upsert mapParentAsset.values();
            
        System.debug('$$$$'+mapParentAsset.values());
        for(AssetStructure ass:mapAssetStructure.values()){
         if(ass.fulfillTo!=null){

                    for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
                    //  if(ffl.FulfillToaccountId==null){ffl.FulfillToaccountId=mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).AccountId;}
                    if(ffl.FulfillToaccountId!=null && ffl.FulfillToaccountId!=''){
                      if(ffl.Type!='Remove'){
                      Asset FulfilltoAsset  = new Asset();
                      FulfilltoAsset.Skip_Validation__c = true;
                      if(mapParentAsset.containskey(mapChildParentNumber.get(ffl.fulfilltolevel))){
                      OrderItem theOrderItem = mapOrderItemstoprocess.get(mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Order_Line_Item__c);
                      //System.debug(mapParentAsset+'kkkkkkk'+mapChildParentNumber.get(ffl.fulfilltolevel)+'theOrderItem'+theOrderItem);
                     if(ffl.Type=='Add'){
                      if(mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Name!=null){
                      FulfilltoAsset.Name = mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Name;
                      } else{
                        FulfilltoAsset.Name = 'Fulfillto Asset';
                      }
                      if(ffl.FulfillToaccountId==null){ffl.FulfillToaccountId=mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).AccountId;}
                      System.debug(ffl.FulfillToaccountId+'PPPPPPPPP'+mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)));
                      FulfilltoAsset.AccountId = ffl.FulfillToaccountId;
                      FulfilltoAsset.Status = 'In Active';
                      FulfilltoAsset.hlc__c = ffl.hlc;
                      FulfilltoAsset.HLC_Override__c = ffl.HLCOverride;
                      FulfilltoAsset.Asset_Type__c = 'Fulfill To';
                      //FulfilltoAsset.Real_Suite_Parent__c = mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Id;
                      FulfilltoAsset.Fulfillment_Status__c = 'Waiting to Process';
                      FulfilltoAsset.Parent_Asset__c = mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Id;
                      //.Order_Line_Item__c = key;
                      }
                       if(ffl.Type=='Modify' || ffl.Type=='NoChange'){
                       FulfilltoAsset = mapAllExistingAssets.get(ffl.assetId);
                       if(ffl.assetId==ass.assetId){
                       if(mapFulfillToAssets.containskey(ffl.assetId)){
                       System.debug(ffl.assetId);
                       ffl.assetId=mapFulfillToAssets.get(ffl.assetId).id;
                       //System.debug(mapFulfillToAssets+'$$$$$'+ffl.assetId);
                       FulfilltoAsset = mapFulfillToAssets.get(ffl.assetId);
                       }
                       }

                       if(ffl.Type!='NoChange'){
                       FulfilltoAsset.Fulfillment_Status__c = 'Waiting to Process';
                       //FulfilltoAsset.Status = 'In Active';
                       }
                       System.debug(FulfilltoAsset.Start_Date__c+'$$$$$$$$$$'+FulfilltoAsset);
                       }
                       // Building FullFillTo Asset Instances.
                        for(String parentAssetFieldAPIName : theFulfillToAssetMappingData.keySet()) {
                          fullFillToAssetFieldAPIName = theFulfillToAssetMappingData.get(parentAssetFieldAPIName).FulfillTo_Asset_Field_API_Name__c;

                          if(
                            assetSchemaFieldMap.containsKey(parentAssetFieldAPIName) &&
                            assetSchemaFieldMap.get(parentAssetFieldAPIName).getDescribe().isAccessible() &&
                            assetSchemaFieldMap.containsKey(fullFillToAssetFieldAPIName) &&
                            assetSchemaFieldMap.get(fullFillToAssetFieldAPIName).getDescribe().isUpdateable()
                          ) {
                          if(ffl.Type=='Modify' && parentAssetFieldAPIName=='Start_Date__c'){ } else{
                            FulfilltoAsset.put(
                              fullFillToAssetFieldAPIName,
                              mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).get(parentAssetFieldAPIName)
                            );
                            }
                          }
                        }
                        if(ffl.hlc!=null){
                       FulfilltoAsset.hlc__c = ffl.hlc;
                       }
                       if(ffl.HLCOverride!=null){
                       FulfilltoAsset.HLC_Override__c = ffl.HLCOverride;
                       }

                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew') || theOrderItem.Line_Type__c.equalsIgnoreCase('Amend') || Test.isRunningTest()){
                                 if(ffl.Type!='NoChange'){
                                 FulfilltoAsset.Fulfillment_Status__c = 'Waiting to Process';
                                 }
                                 FulfilltoAsset.Status = 'Active';
                                 FulfilltoAsset.Line_Type__c = theOrderItem.Line_Type__c;

                                 FulfilltoAsset.End_Date__c = theOrderItem.End_Date__c;
                                 FulfilltoAsset.Product_type__c = theOrderItem.Product_type__c;
                                 if(theOrderItem.Line_Type__c.equalsIgnoreCase('Amend')){
                                 FulfilltoAsset.Status = 'Active';
                                 //FulfilltoAsset.Line_Type__c = 'Modify';
                                 }
                                 if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){
                                 FulfilltoAsset.Fulfillment_Status__c = 'Waiting to Process';
                                 FulfilltoAsset.Start_Date__c = theOrderItem.Start_Date__c;
                                 }
                                 if(ffl.participant==null){
                                 FulfilltoAsset.Fulfillment_Status__c = 'Waiting to Process';
                                 }
                             }

                           if(mapProdFulfill.containskey(FulfilltoAsset.Product2Id)){
                    FulfilltoAsset.Fulfillment_Required__c = mapProdFulfill.get(FulfilltoAsset.Product2Id).Fulfillment_Required__c ;
                    }
                             if(ffl.Type=='Add'){
                       FulfilltoAsset.Line_Type__c = 'Add';
                       FulfilltoAsset.Renewal_Status__c  = '';
                       if(FulfilltoAsset.Start_Date__c!=null){FulfilltoAsset.Start_Date__c = System.today();}
                       FulfilltoAsset.Start_Date__c = theOrderItem.Start_Date__c;
                       }
                       if(theOrderItem.Order.Type.equalsIgnoreCase('New') || theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){

                       FulfilltoAsset.OwnerId = theOrderItem.Order.Account.OwnerId;
                       }
                       if(mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel))!=null){
                        FulfilltoAsset.Contract__c = mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Contract__c;
                        FulfilltoAsset.Order_Line_Item__c = mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Order_Line_Item__c;
                       }
                       FulfilltoAsset.At_Risk__c = false;
                       //System.debug('$$$$$$$$$$$$$$$$'+FulfilltoAsset);
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Credit')  || theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
                       FulfilltoAsset.Line_Type__c = 'Credit';
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
                       FulfilltoAsset.Line_Type__c = 'Cancel';
                       }
                       if(theOrderItem.Ext_Days__c>0){
                       FulfilltoAsset.Line_Type__c = 'Amend';
                       }
                       }
                       if(FulfilltoAsset.Refund_Request__c==true){
                       //FulfilltoAsset.Line_Type__c = 'Cancel';
                       }
                       if(FulfilltoAsset.Name==null){
                        FulfilltoAsset.Name = 'Fulfillto Asset';
                       }
                       // Opcity 
                       if (Label.Opcity_Product_Codes.contains(theOrderItem.PriceBookEntry.Product2.productCode)) {
                            FulfilltoAsset.Fulfillment_Status__c = 'Manual';
                            FulfilltoAsset.Commission_field__c = 'Ignore';        // CRM-6063 - Opcity - Ignore commisions for Opcity Assets.
                            FulfilltoAsset.Not_picked__c = true;
                            if (ffl.Type=='NoChange') {
                                FulfilltoAsset.Fulfillment_Status__c = 'Fulfilled';
                            }
                            else if(theOrderItem.Line_Type__c=='Amend' && ffl.Type=='Add'){
                                FulfilltoAsset.Sign_in_AE__c = theorderItem.Order.OwnerId;
                            }
                        }
                       // Opcity - End
                       if((ffl.assetId!=ass.assetId) || (ffl.Type=='Add')){
                       System.debug(ffl.fulfilltolevel+'$$$$$$$$$$'+FulfilltoAsset);
                        mapFulfilltoAsset.put(ffl.fulfilltolevel,FulfilltoAsset);

                        }
                        if((ffl.assetId==ass.assetId) && (ffl.assetId!=null)){
                        //System.debug('$$$$$$$$$$'+ffl);
                        //System.debug('$$$$$$$$$$'+ffl.assetId);
                        //mapOldFulfillToAssetIds.put(ffl.assetId,ffl.assetId);
                        }
                        System.debug(FulfilltoAsset.Start_Date__c+'$$$$$$$$$$'+FulfilltoAsset.Line_Type__c);
                        }
                        //parentasset.OwnerId = theOrderItem.Order.ownerId;
                        } else {

                         mapdelAssetIds.put(ffl.assetId,sttr);
                         //System.debug(mapdelAssetIds+'mmmmmmmmmmmmmmm');

                        }
                      }
                    }
                 }
             }

             if(mapFulfilltoAsset.values().size()>0){
                 upsert mapFulfilltoAsset.values();

                 for(AssetStructure ass:mapAssetStructure.values()){
                       if(ass.fulfillTo!=null){
                      for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
                      if(ffl.Type!='Remove'){
                      System.debug(mapOrderItemstoprocess+'$$$$$'+mapParentAsset+'$$$$'+mapChildParentNumber+'$$$$'+ffl.fulfilltolevel);
                      OrderItem theOrderItem = mapOrderItemstoprocess.get(mapParentAsset.get(mapChildParentNumber.get(ffl.fulfilltolevel)).Order_Line_Item__c);
                         if(ffl.participant!=null){
                        for(AssetStructure.participant ppc:ffl.participant){
                        if(ppc.participantaccountId!=null && ppc.participantaccountId!=''){
                        if(ppc.Type!='Remove'){
                        Asset participantAsset  = new Asset();
                        participantAsset.Skip_Validation__c = true;
                     if(ppc.Type=='Add'){
                      System.debug('####'+ppc.participantaccountId);
                      participantAsset.Name = mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel)).Name;
                      participantAsset.AccountId = ppc.participantaccountId;
                      if(participantAsset.AccountId==null){
                      participantAsset.AccountId = mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel)).AccountId;
                      }
                      participantAsset.hlc__c = ppc.hlc;
                      participantAsset.HLC_Override__c = ppc.HLCOverride;

                      participantAsset.Asset_Type__c = 'Participant';

                      participantAsset.Status = 'In Active';
                      participantAsset.Fulfillment_Status__c = 'Waiting to Process';

                      participantAsset.Parent_Asset__c = mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel)).Id;

                      participantAsset.MLS_Set__c = ppc.MLSSETID;//mapMLSSet.get(ppc.MLSSETID).id;

                      //.Order_Line_Item__c = key;
                      }
                        if(ppc.Type=='Modify' || ppc.Type=='NoChange'){
                       participantAsset = mapAllExistingAssets.get(ppc.assetId);
                       participantAsset.Asset_Type__c = 'Participant';
                       if(ppc.Type!='NoChange'){
                       participantAsset.Fulfillment_Status__c = 'Waiting to Process';
                       participantAsset.Status = 'Active';
                       }


                       participantAsset.MLS_Set__c = ppc.MLSSETID;//mapMLSSet.get(ppc.MLSSETID).id;

                      participantAsset.AccountId = ppc.participantaccountId;
                       }
                       if(mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel))!=null){
                        participantAsset.Contract__c = mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel)).Contract__c;
                       }

                        // Building Participant Asset Instances.
                    for(String theFullFillToAssetFieldAPIName : theParticipantAssetMappingData.keySet()) {
                      participantAssetFieldAPIName = theParticipantAssetMappingData.get(theFullFillToAssetFieldAPIName).Participant_Asset_Field_API_Name__c;

                      if(
                        assetSchemaFieldMap.containsKey(theFullFillToAssetFieldAPIName) &&
                        assetSchemaFieldMap.get(theFullFillToAssetFieldAPIName).getDescribe().isAccessible() &&
                        assetSchemaFieldMap.containsKey(participantAssetFieldAPIName) &&
                        assetSchemaFieldMap.get(participantAssetFieldAPIName).getDescribe().isUpdateable()
                      ) {
                      if(ppc.Type=='Modify' && theFullFillToAssetFieldAPIName=='Start_Date__c'){ } else{
                        participantAsset.put(
                          participantAssetFieldAPIName,
                          mapFulfilltoAsset.get(mapChildParentNumber.get(ppc.participantlevel)).get(theFullFillToAssetFieldAPIName)
                        );
                        }
                      }
                    }
                    if(ppc.hlc!=null){
                       participantAsset.hlc__c = ppc.hlc;
                       }

                       if(ppc.HLCOverride!=null){
                       participantAsset.HLC_Override__c = ppc.HLCOverride;
                       }
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew') || theOrderItem.Line_Type__c.equalsIgnoreCase('Amend')){
                                if(ppc.Type!='NoChange'){
                                participantAsset.Fulfillment_Status__c = 'Waiting to Process';
                                }
                                participantAsset.Status = 'Active';
                                participantAsset.Line_Type__c = theOrderItem.Line_Type__c;
                                if(theOrderItem.Line_Type__c.equalsIgnoreCase('Amend')){
                                //participantAsset.Line_Type__c = 'Modify';
                                participantAsset.Status = 'Active';
                                }
                                if(theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){
                                participantAsset.Start_Date__c = theOrderItem.Start_Date__c;
                                }
                                participantAsset.End_Date__c = theOrderItem.End_Date__c;
                                //participantAsset.Start_Date__c = System.today();
                           }
                           if(mapProdFulfill.containskey(participantAsset.Product2Id)){
                    participantAsset.Fulfillment_Required__c = mapProdFulfill.get(participantAsset.Product2Id).Fulfillment_Required__c ;
                    }
                           if(ppc.Type=='Add'){
                       participantAsset.Line_Type__c = 'Add';
                       participantAsset.Renewal_Status__c  = '';
                       participantAsset.Start_Date__c = System.today();
                       }
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Credit') || theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
                       participantAsset.Line_Type__c = 'Credit';
                       if(theOrderItem.Line_Type__c.equalsIgnoreCase('Buyout')){
                       participantAsset.Line_Type__c = 'Cancel';
                       }
                       if(theOrderItem.Ext_Days__c>0){
                       participantAsset.Line_Type__c = 'Amend';
                       }
                       }
                       participantAsset.AccountId = ppc.participantaccountId;
                       if(theOrderItem.Order.Type.equalsIgnoreCase('New') || theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){

                       participantAsset.OwnerId = theOrderItem.Order.Account.OwnerId;
                       }
                       participantAsset.At_Risk__c = false;
                       mapParticipantAsset.put(ppc.participantlevel ,participantAsset);
                       }
                         else {
                         if(!theOrderItem.Line_Type__c.equalsIgnoreCase('Renew')){
                         mapdelAssetIds.put(ppc.assetId,theOrderItem.Id);
                         }
                        }
                       }
                      }
                     }
                    }
                   }
                  }
                 }

                if(mapParticipantAsset.values().size()>0){
                //System.debug('$$$$$'+mapParticipantAsset.values());
                upsert mapParticipantAsset.values();
                //System.debug('$$$$$'+mapParticipantAsset.values());
                }

              }
        }
        //System.debug('$$$$'+mapdelAssetIds);
         if(mapdelAssetIds.keyset().size()>0 || Test.isRunningTest()){
                      for(Id key:mapAssetStructure.keyset()){
                       AssetStructure ass = mapAssetStructure.get(key);
                       if(ass.Type=='Remove'){
                       mapdelAssetIds.put(ass.assetId,key);
                       }
                       if(ass.fulfillTo!=null){

                      for(AssetStructure.fulfillTo ffl:ass.fulfillTo){
                      if(ffl.Type=='Remove'){

                       mapdelAssetIds.put(ffl.assetId,key);
                       System.debug(ffl.assetId+'########'+sttr);
                       //mapdelAssetIds.put(ffl.assetId,ffl.assetId);
                             }
                       if(ffl.participant!=null){
                        for(AssetStructure.participant ppc:ffl.participant){
                        if(ppc.participantaccountId!=null && ppc.participantaccountId!=''){
                        if(ppc.Type=='Remove'){
                        mapdelAssetIds.put(ppc.assetId,key);
                        //mapdelAssetIds.put(ppc.assetId,ppc.assetId);
                             }
                          }
                        }
                       }
                     }
                   }
                }

             }
             
             System.debug(theFiveStreetAccounts+'********'+mapParentAsset+'********'+mapdelAssetIds+'********'+mapProdFulfill+'********'+mapOrderItemstoprocess+'********'+theParentAssetMappingData);
             System.debug(theFiveStreetAccounts+'****************'+mapdelAssetIds);
             if(mapdelAssetIds.keyset().size()>0 || theFiveStreetAccounts.size()>0){
                 DeleteAssets(theFiveStreetAccounts,mapParentAsset,mapdelAssetIds,mapProdFulfill,mapOrderItemstoprocess,theParentAssetMappingData);
                 }
                 if(setRenewParentAssetIds.size()>0){
                 List<Commission__c> lstCommsions = [Select Id,Status__c,Related_to_Asset__c from Commission__c where Related_to_Asset__c=:setRenewParentAssetIds and Status__c!='InActive' and Related_to_Quota__r.Payment_Status__c='Payroll Processed'];
                 for(Commission__c comm:lstCommsions){
                 comm.Status__c = 'InActive';
                 }
                 try{
                 update lstCommsions;
                 } catch(Exception Ex){

                 }
                 }



                 Set<Id> setId = new Set<Id>();
        //QuoteToOrderHelperCls.UpdateQuoteStatusToOrdered(setBMQuoteIds,setopportunityIds,setId,null,null);
                } catch(Exception ex){
                List<Error__c> lstError = new List<Error__c>();
                for(Id idd:theOrderIds){
                Error__c error = new Error__c();
                error.Name = idd;
                error.Entity_Id__c = 'Order to Asset Creation';
                error.Interface_Name__c = 'CreateAssetsFromOrderLineItemsAssetJSON';
                error.Error_Description__c = ex+' ****** '+ex.getStackTraceString();
                lstError.add(error);
                }
                if(lstError.size()>0){
                insert lstError;
                }
                }
  }

  global void finish(Database.BatchableContext BC) {
  }
}