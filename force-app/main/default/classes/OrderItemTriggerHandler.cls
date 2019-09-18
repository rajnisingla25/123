//****************************************************************************************
//Name          : OrderItemTriggerHandler
//Date          : 16-DEC-2015
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : This Class is meant to update Assets based on Order Products
//
// *****************************************************************************************

public with sharing class OrderItemTriggerHandler{
    static boolean DecommAssetsupdated = false;
    public static boolean IsOrderTgrExecuted = false;
    //  This method is invoked from the Trigger. The Entry point to update Case Asset Relationship based on Order Product
    //public static void updateCaseAssetRelationship(List<OrderItem> orderItems){
    public static void updateCaseAssetRelationshipInNonFuture(set<Id> orderItemids){
        updateCaseAssetRelationship(orderItemids);
    }   
    @future
    public static void updateCaseAssetRelationshipInFuture(set<Id> orderItemids){
        updateCaseAssetRelationship(orderItemids);
    }
    public static void updateCaseAssetRelationship(set<Id> orderItemids){
        System.debug('Number of Orderitems coming Here are' +orderItemids.size());
        List<OrderItem> orderItems = [select id,Fulfillment_Status__c,Discount_Type__c,OrderId,Refund_Request__c,Buyout_Amount__c,Delta_Price__c,Extension_Type__c,Zuora_Status__c,Credit_Amount__c,Line_type__c,Zuora_Comment__c,asset__c,DecommissionedAsset__c from OrderItem where Id In:orderItemids];
        system.debug('@@ updateCaseAssetRelationship - Start @@' +orderItems.size());
        Set<Id> orderLineItemIds = new Set<Id>();
        Set<Id> decommorderItemIds = new Set<Id>();
        set<Id> setAssetIds = new Set<Id>();
        Set<Id> orderProductAssetIdSet                              = new Set<Id>();
        Map<Id,Id> orderAndLineItemMap                              = new Map<Id,Id>();
        Map<Id,Id> caseAndAssetIDMap                                = new Map<Id,Id>();
        Map<Id,Case_Asset_Relationship__c> caseAssetRelationshipMap = new Map<Id,Case_Asset_Relationship__c>();
        Map<Id,Case_Asset_Relationship__c> caseAssetRelationshipList    = new Map<Id,Case_Asset_Relationship__c>();
        Map<Id,List<Case_Asset_Relationship__c>> carAssetCountMap   = new Map<Id, List<Case_Asset_Relationship__c>>();
        Set<Id> DecommAssets = new Set<Id>();
        List<Asset> lstAssets = New List<Asset>();
        
        for(OrderItem loopvar: orderItems){
            if(loopvar.Fulfillment_Status__c == 'Fulfilled'){
                orderAndLineItemMap.put(loopvar.Id,loopvar.OrderId);
                // CRM-796 commented loopvar.Zuora_Comment__c=='Sent to Z-Billing'
                if(loopvar.Zuora_Status__c == 'Success' /*&& loopvar.Zuora_Comment__c=='Sent to Z-Billing'*/ && loopvar.Refund_Request__c ==true && (loopvar.Line_type__c =='Credit' || loopvar.Line_type__c =='Cancel' || loopvar.Line_type__c =='Buyout')){
                    orderLineItemIds.add(loopvar.OrderId);
                }
                if(loopvar.Zuora_Status__c == 'Success' && (loopvar.Zuora_Comment__c=='Sent to Z-Billing' || loopvar.Zuora_Comment__c=='No Zuora Changes')){
                    setAssetIds.add(loopvar.asset__c);
                }
                
                // CRM-2331
                else if ((loopvar.Zuora_Comment__c+'').contains(Label.Zuora_Success_Message)) {
                    setAssetIds.add(loopvar.asset__c);
                }
                // CRM-2331 End
            }
            //Start-Advantage project -> coded by subbu
            If(loopvar.DecommissionedAsset__c != null){
                DecommAssets.add(loopvar.DecommissionedAsset__c);
                decommorderItemIds.add(loopvar.Id);
            }
        }
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        List<OrderItem> orditmlst = new List<OrderItem>();
        if (!decommorderItemIds.isEmpty()) {
            orditmlst = [Select Id,Order.Oracle_quote__r.Name,DecommissionedAsset__c from OrderItem where Id=:decommorderItemIds];
        }    
        Map<id,string> qtnmbrmap = New Map<id,string>();
        for(OrderItem orditmlp : orditmlst){
            qtnmbrmap.put(orditmlp.DecommissionedAsset__c,orditmlp.Order.Oracle_quote__r.Name);
        }
        
        //End-Advantage project
        
        if(setAssetIds.size()>0){
            lstAssets = [Select Id,Renewal_Status__c,Product_code__c,Inflight_Quote__c,Line_type__c,Order_Type__c from Asset where id=:setAssetIds];
            for(Asset ast:lstAssets){
                ast.Inflight_Quote__c = '';
                if(ast.Line_type__c=='Credit' && ast.Order_Type__c=='Auto-Credit'){
                    ast.Credit_Status__c = 'Processed';
                }
                if(ast.Line_type__c=='Credit' && ast.Product_code__c=='SELLERLEADBUNDLE'){
                    // ast.Credit_Status__c = 'Processed';
                }
                //Start-Advantage project -> coded by subbu
                if(!DecommAssets.isEmpty()){
                    If(DecommAssets.contains(ast.id)){
                        ast.Renewal_Status__c = 'Renewed As Advantage';
                        ast.Inflight_Quote__c = qtnmbrmap.get(ast.id) + '*Renew*PendingRenewalQuote';
                        DecommAssets.remove(ast.id);
                    }
                }
            }
        }
        
        //updating assets if any are not present in lstAssets
        If(!DecommAssets.isEmpty()){
            for(Id DecommId : DecommAssets){
                Asset tempasst = New Asset();
                tempasst.id = DecommId;
                tempasst.Renewal_Status__c = 'Renewed As Advantage';
                tempasst.Inflight_Quote__c = qtnmbrmap.get(DecommId) + '*Renew*PendingRenewalQuote';
                lstAssets.add(tempasst);
            }
        }
        
        If(lstAssets.size()>0){
            //CRM-5460 avoiding asset triggerrecursive run as part optimization.
            SkipAssetTrigger.setSkipTrgTrue(); 
            update lstAssets;
        }
        
        // Construct Maps here
        Map<Id,Id> orderItemAssetMap                        = createOrderItemAssetMap(orderAndLineItemMap.keySet());
        Map<Id,Id> orderQuotesMap                           = createOrderQuoteMap(orderAndLineItemMap.values());
        Map<Id,Id> quoteCasesMap                            = createQuotesCaseMap(orderQuotesMap.values());
        Map<Id,Decimal> mapQuoteIdCreditAmount = new Map<Id,Decimal>();
        //Map<Id,Id> orderItemQuotesMap  = new Map<Id,Id>();
        List<Error__c> errorList = new List<Error__c>();
        Map<Id,OrderItem> mapQuoteOwnerIds = new Map<Id,OrderItem>();
        System.debug('TRRRRRR'+orderLineItemIds);
        Set<Id> setQuoteIds = new Set<Id>();
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!orderLineItemIds.isEmpty()) {
            for(OrderItem iddd:[Select Id,Order.Oracle_quote__c,Order.Oracle_quote__r.BigMachines__Description__c,Credit_Amount__c,Order.Oracle_quote__r.OwnerId,Order.AccountId,Order.Oracle_quote__r.Account__c from OrderItem where OrderId=:orderLineItemIds]){
                if(iddd.Order.Oracle_quote__c!=null){
                    setQuoteIds.add(iddd.Order.Oracle_quote__c);
                }
            }
        }
        System.debug('TRRRRRRFF'+setQuoteIds);
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!setQuoteIds.isEmpty() || test.isRunningTest()) {
            for(OrderItem iddd:[Select Id,Order.Oracle_quote__c,Order.Oracle_quote__r.BigMachines__Description__c,Credit_Amount__c,Order.Oracle_quote__r.OwnerId,Order.AccountId,Order.Oracle_quote__r.Account__c from OrderItem where Order.Oracle_quote__c=:setQuoteIds]) {
                mapQuoteOwnerIds.put(iddd.Order.Oracle_quote__c,iddd);
                Decimal creditAmount=0.0;
                if(mapQuoteIdCreditAmount.containskey(iddd.Order.Oracle_quote__c)){
                    creditAmount = mapQuoteIdCreditAmount.get(iddd.Order.Oracle_quote__c);
                }
                if(iddd.Credit_Amount__c!=null){
                    if(mapQuoteIdCreditAmount.containskey(iddd.Order.Oracle_quote__c)){
                        creditAmount = mapQuoteIdCreditAmount.get(iddd.Order.Oracle_quote__c)+ iddd.Credit_Amount__c;
                    } else {
                        creditAmount = iddd.Credit_Amount__c;
                    }
                }
                mapQuoteIdCreditAmount.put(iddd.Order.Oracle_quote__c,creditAmount);
            }
        }
        
        System.debug('$$$$$$');
        if(mapQuoteOwnerIds.keyset().size()>0){
            System.debug('######'+mapQuoteOwnerIds);
            FinanceCase(mapQuoteOwnerIds,mapQuoteIdCreditAmount,'FinanceCase');
        }
        
        //  Construct Map of Case and Asset
        
        for(OrderItem oli: orderItems){
            if(orderItemAssetMap.get(oli.Id)!= Null && orderQuotesMap.get(oli.OrderId)!= Null){
                caseAndAssetIDMap.put(quoteCasesMap.get(orderQuotesMap.get(oli.OrderId)),orderItemAssetMap.get(oli.Id));
            }
        }
        
        
        caseAssetRelationshipMap                            = fetchCaseAssetRelationship(caseAndAssetIDMap.keyset(), caseAndAssetIDMap.values());
        Map<Id,String>  assetDatesMap                       = createAssetDateMap(caseAndAssetIDMap.values());
        carAssetCountMap                                    =  fetchCARCount(assetDatesMap);
        
        system.debug('@@ orderAndLineItemMap @@'+orderAndLineItemMap);
        system.debug('@@ orderItemAssetMap @@'+orderItemAssetMap);
        system.debug('@@ orderQuotesMap @@'+orderQuotesMap);
        system.debug('@@ quoteCasesMap @@'+quoteCasesMap);
        system.debug('@@ caseAndAssetIDMap @@'+caseAndAssetIDMap);
        system.debug('@@ caseAssetRelationshipMap @@'+caseAssetRelationshipMap);
        
        
        // Iterating over the loop to update the results
        
        if(!caseAssetRelationshipMap.isEmpty()){
            for(OrderItem loopvar: orderItems){
                if(orderQuotesMap.get(loopvar.OrderId)!=Null)
                    if(quoteCasesMap.get(orderQuotesMap.get(loopvar.OrderId)) !=Null){
                        Case_Asset_Relationship__c car                  = caseAssetRelationshipMap.get(quoteCasesMap.get(orderQuotesMap.get(loopvar.OrderId)));
                        car.Line_Action__c                              = loopvar.Line_Type__c;
                        car.Credit_Amount__c                            = loopvar.Credit_Amount__c;
                        car.Extension_Type__c                           = loopvar.Extension_Type__c;
                        car.Discount_Type__c                            = loopvar.Discount_Type__c;
                        car.Delta_Price__c                              = loopvar.Delta_Price__c;
                        car.Buyout_Amount__c                            = loopvar.Buyout_Amount__c;
                        
                        
                        //  system.debug('@@ carAssetCountMap.get(orderItemAssetMap.get(loopvar.Id)).size() @@'+carAssetCountMap.get(orderItemAssetMap.get(loopvar.Id)).size());
                        
                        // Retension field calculations
                        
                        if(car.Asset__r.Daily_Rate__c!= Null){
                            if(car.At_Risk_Amount__c == 0.0 || car.At_Risk_Amount__c == Null){
                                car.At_Risk_Amount__c                   = (Date.today().daysBetween(car.Asset__r.End_Date__c)+1) * car.Asset__r.Daily_Rate__c;
                            }
                            
                            
                            if(car.Line_Action__c.equalsIgnoreCase('Credit')){
                                if(car.Extension_Type__c =='paid'){
                                    car.New_Risk__c                     = car.At_Risk_Amount__c + car.Delta_Price__c;//for Credited Extention
                                    car.Saved_Amount__c                 = car.New_Risk__c;
                                }
                                else if(car.Credit_Amount__c == Null){
                                    car.Credit_Amount__c                = 0.0;
                                }else
                                    car.New_Risk__c                         = car.At_Risk_Amount__c - car.Credit_Amount__c;
                                car.Saved_Amount__c                     = car.New_Risk__c;
                            }
                            else if(car.Line_Action__c.equalsIgnoreCase('Amend')){
                                if(car.Delta_Price__c==null){car.Delta_Price__c=0;}
                                if(car.At_Risk_Amount__c==null){car.At_Risk_Amount__c=0;}
                                car.New_Risk__c                     = car.At_Risk_Amount__c + car.Delta_Price__c;
                                car.Saved_Amount__c                 = car.New_Risk__c;
                            }
                            
                            else if(car.Line_Action__c.equalsIgnoreCase('Buyout')){
                                car.New_Risk__c                         = car.Asset__r.Total_Net__c - car.At_Risk_Amount__c;
                                car.Saved_Amount__c                     = car.Buyout_Amount__c;
                            } else if(car.Line_Action__c.equalsIgnoreCase('Cancel')){
                                car.New_Risk__c  =  0;
                                // car.New_Risk__c                         = car.Asset__r.Total_Net__c - car.At_Risk_Amount__c;
                                car.Saved_Amount__c                     = 0;
                            }
                            
                        }
                        if(orderItemAssetMap.containskey(loopvar.Id)){
                            if(carAssetCountMap.containskey(orderItemAssetMap.get(loopvar.Id))){
                                if(carAssetCountMap.get(orderItemAssetMap.get(loopvar.Id)).size()>1){
                                    car.Saved_Amount__c                     = 0;
                                }
                            }
                        }
                        
                        caseAssetRelationshipList.put(car.id,car);
                    }
            }
            
            try{
                if(!caseAssetRelationshipList.values().isEmpty())
                    update caseAssetRelationshipList.values();
            }
            catch(Exception de){
                system.debug('@@ DML Exception Occured @@'+de);
                errorList.add(new Error__c(Name ='CAR Save-Amount Failed to update',Entity_Id__c = 'updateCaseAssetRelationship',Interface_Name__c = 'OrderItemTriggerHandler',Error_Description__c = 'Error Message returned is '+de.getMessage() + ' and Cause for the error is ' + de.getCause() + 'The line Number it occured is '+de.getLineNumber()));
            }
            if(errorList.isEmpty()){
                insert errorList;
            }
            errorList.clear();
        }
        
        system.debug('@@ updateCaseAssetRelationship - End @@');
        
    }
    
    
    // This method creates a map of OrderItemsId and Asset Ids
    private static Map<Id,Id> createOrderItemAssetMap(Set<Id> orderItemsId){
        system.debug('@@ fetchAssets - Start @@');
        
        Map<Id,Id> orderItemAssetMap                 =  new Map<Id,Id>();
        List<OrderItem> assetList                    = [SELECT Id,Asset__r.Asset_Type__c,Asset__c
                                                        FROM OrderItem
                                                        WHERE Id =:orderItemsId
                                                        AND Asset__r.Asset_Type__c = 'Parent'
                                                       ];
        
        // Only Parent Asset is added to the list and there always will be one Parent Asset asscociated with any Order Product
        if(assetList.size()>0){
            for(OrderItem loopvar: assetList){
                orderItemAssetMap.put(loopvar.Id,loopvar.Asset__c);
            }
            
        }
        
        system.debug('@@ fetchAssets - End @@');
        return orderItemAssetMap;
    }
    
    // This method creates a map of Order and Quote Ids
    private static Map<Id,Id> createOrderQuoteMap(List<Id> orderIdSet){
        system.debug('@@ createOrderQuoteMap - Start @@');
        Map<Id,Id> orderQuotesMap                       = new Map<Id,Id>();
        Set<Id> quotesId                                = new Set<Id>();
        
        //  Fetch the Quotes from Order
        List<Order> orderList                           = [SELECT Oracle_Quote__c
                                                           FROM Order
                                                           WHERE Id IN: orderIdSet
                                                          ];
        
        for(Order loopvar: orderList){
            orderQuotesMap.put(loopvar.Id,loopvar.Oracle_Quote__c);
        }
        
        system.debug('@@ createOrderQuoteMap - End @@');
        return  orderQuotesMap;
    }
    
    // This method creates a map of Quote and Case
    private static Map<Id,Id> createQuotesCaseMap(List<Id> quotesId){
        system.debug('@@ createQuotesCaseMap - Start @@');
        
        Map<Id,Id> quoteCasesMap                         = new Map<Id,Id>();
        //  Fetch cases from Quotes
        // CRM-1423 Added condition to avoid executing SOQL if list is empty
        if (!quotesId.isEmpty()) {
            List<BigMachines__Quote__c> caseList             = [SELECT Id,Case__c,Case__r.Type
                                                                FROM BigMachines__Quote__c
                                                                WHERE (Case__r.Type = 'Retention' OR
                                                                       // CRM-3055 Added extra condition to handel ProSoft cases
                                                                       (Case__r.Type = 'ProSoft' AND Case__r.RecordType.Name = 'Retention'))
                                                                AND Id IN:quotesId
                                                               ];
            
            //   This loop constructs the Case and Quote Id Map
            for(BigMachines__Quote__c loopvar: caseList){
                quoteCasesMap.put(loopvar.Id, loopvar.Case__c);
            }
        }
        
        system.debug('@@ createQuotesCaseMap - End @@');
        return quoteCasesMap;
    }
    
    // This method fetches the Case - Asset Relationship
    private static Map<Id,Case_Asset_Relationship__c> fetchCaseAssetRelationship(Set<Id> caseId, List<Id> assetId){
        system.debug('@@ fetchCaseAssetRelationship - Start @@');
        
        Map<Id,Case_Asset_Relationship__c> caseAssetRelationshipMap = new Map<Id,Case_Asset_Relationship__c>();
        
        List<Case_Asset_Relationship__c> caseAssetRelList           = new List<Case_Asset_Relationship__c>();
        
        caseAssetRelList                                            = [SELECT Id,Line_Action__c,Case__c,Credit_Amount__c,Extension_Type__c,Discount_Type__c,New_Risk__c,At_Risk_Amount__c,Saved_Amount__c,Asset__r.Total_Net__c,Asset__r.Daily_Rate__c,Asset__r.End_Date__c
                                                                       FROM Case_Asset_Relationship__c
                                                                       WHERE Case__c IN: caseId
                                                                       AND Asset__c IN: assetId
                                                                       AND Previous_CAR_Exists_For_This_Term__c = False
                                                                      ];
        
        
        for(Case_Asset_Relationship__c loopvar: caseAssetRelList){
            caseAssetRelationshipMap.put(loopvar.Case__c,loopvar);
        }
        
        system.debug('@@ fetchCaseAssetRelationship - End @@');
        return caseAssetRelationshipMap;
        
    }
    
    Public Static List<Case> FinanceCase(Map<Id, OrderItem> setQuoteDapIds,Map<Id,Decimal> mapQuoteIdCreditAmount,String productcaseValue){
        Integer rrrcount=0;
        List<Case> lstCases = new List<Case>();
        System.debug('Finance Case ***'+productcaseValue);
        ProductCase__c ppcase= ProductCase__c.getValues(productcaseValue);
        if(ppcase!=null){
            if(setQuoteDapIds.keyset().size()>0){
                System.debug(setQuoteDapIds+'AdVer');
                List<Case> lstCase = [Select Id,Refund_Amount__c,Oracle_Quote__c from case where Oracle_Quote__c=:setQuoteDapIds.keyset() and Type = :ppcase.Case_Type__c];//
                System.debug('TRRRRRRFF'+lstCases);
                if(lstCase.size()<1 || test.isRunningTest()){
                    //List<Asset> lstAsset= [Select AccountId,Line_type__c,order_line_item__r.order.Oracle_Quote__c from Asset where asset_type__c='Parent' and (Fulfillment_Status__c='Fulfilled') and Product_Code__c='DIGITALAGENT' and order_line_item__r.order.Oracle_Quote__c=:setQuoteDapIds];
                    
                    Id quoteIdds = null;
                    Id accid = null;
                    
                    
                    Map<String,String> mapManualQueueName = new Map<String,String>();
                    for(Group grp:[SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type='Queue']){
                        mapManualQueueName.put(grp.DeveloperName,grp.Id);
                    }
                    Map<String,String> mapRecordTypeName = new Map<String,String>();
                    for(RecordType grp:[SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case']){
                        mapRecordTypeName.put(grp.DeveloperName,grp.id);
                    }
                    System.debug('Finance Case ***'+mapManualQueueName);
                    
                    // CRM-2940 - Case needs to be assigned using Assignment Rule, so fetch the same and store it in DMLOptions.
                    //AssignmentRule assignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true limit 1];
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.useDefaultRule= true;
                    // dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRule.id;
                    // CRM-2940 End
                    
                    for(Id idd:setQuoteDapIds.keyset()){
                        Case caseToAdd = new Case();
                        caseToAdd.Status = 'New';
                        caseToAdd.Origin = 'Web';
                        caseToAdd.Type = ppcase.Case_Type__c;
                        caseToAdd.Is_Tiger_Lead__c = false;
                        System.debug('Finance Case ***'+idd);
                        caseToAdd.Oracle_Quote__c  = idd;
                        caseToAdd.Description  = setQuoteDapIds.get(idd).Order.Oracle_quote__r.BigMachines__Description__c;
                        caseToAdd.Is_Pre_Welcome_Call__c = false;
                        if(mapRecordTypeName.containskey(ppcase.Case_Record_Type__c)){
                            caseToAdd.RecordTypeId = mapRecordTypeName.get(ppcase.Case_Record_Type__c);
                        }
                        caseToAdd.Area__c = ppcase.Case_Area__c;
                        caseToAdd.Subject = ppcase.Case_Subject__c;
                        caseToAdd.Refund_Amount__c = mapQuoteIdCreditAmount.get(idd);
                        caseToAdd.Sub_Area__c = ppcase.Case_Sub_Area__c;
                        caseToAdd.Quote_Owner__c =  setQuoteDapIds.get(idd).Order.Oracle_quote__r.ownerId;
                        if(setQuoteDapIds.get(idd).Order.AccountId!=null){
                            System.debug(setQuoteDapIds.get(idd).Order.AccountId+'PPPP');
                            caseToAdd.AccountId = setQuoteDapIds.get(idd).Order.AccountId;
                        }
                        
                        // CRM-2940 - Commented below lines of code, now case owner will be based on assignment rule
                        /*
if(ppcase.Case_Subject__c!=null){
if(mapManualQueueName.containskey(ppcase.Queue__c)){
caseToAdd.ownerId = mapManualQueueName.get(ppcase.Queue__c);
}
}
*/
                        
                        // CRM-2940 - Set option to dmlOpts, which has Assignment Rule Id set.
                        caseToAdd.setOptions(dmlOpts);
                        // CRM-2940 End
                        
                        lstCases.add(caseToAdd);
                    }
                    if(lstCases.size()>0){
                        Insert lstCases;
                    }
                } else {
                    System.debug('TRRRRRRFF'+lstCase);
                    for(Case cse:lstCase){
                        cse.Refund_Amount__c = mapQuoteIdCreditAmount.get(cse.Oracle_Quote__c);
                    }
                    System.debug('TRRRRRRFF'+lstCase);
                    update lstCase;
                }
            }
        }
        return lstCases;
    }
    
    // This method constructs the map of CAR Count and related Asset
    Public static Map<Id, List<Case_Asset_Relationship__c>> fetchCARCount(Map<Id,String> assetDatesMap){
        
        system.debug('@@ fetchCARCount - Start @@');
        
        Map<Id, List<Case_Asset_Relationship__c>> carAssetCountMap  = new Map<Id, List<Case_Asset_Relationship__c>>();
        
        
        List<Case_Asset_Relationship__c> caseAssetRelList           = new List<Case_Asset_Relationship__c>();
        
        // CRM-1423 Added condition to avoid executing SOQL if map is empty
        if (!assetDatesMap.isEmpty()) {
            caseAssetRelList                                            = [SELECT Id, Asset__c, Asset__r.Start_Date__c, Asset__r.End_Date__c, CreatedDate
                                                                           FROM Case_Asset_Relationship__c
                                                                           WHERE Asset__c IN: assetDatesMap.keySet() and Case__r.Type ='Retention' and 
                                                                           Case__r.RecordType.Name ='Retention'
                                                                          ];
        }
        
        // This basically maintains a map where a count is maintained of the CAR v/s Assets
        // check if the list can be passed
        for(Case_Asset_Relationship__c loopvar: caseAssetRelList){
            
            List<String> dateFromMap    = assetDatesMap.get(loopvar.Asset__c).split(';');
            Date startDate              = Date.valueof(dateFromMap.get(0));
            Date endDate                = Date.valueof(dateFromMap.get(1));
            
            system.debug('@@ loopvar.CreatedDate @@'+loopvar.CreatedDate);
            system.debug('@@ startDate @@'+startDate);
            system.debug('@@ endDate @@'+endDate);
            
            if(loopvar.CreatedDate>=startDate && loopvar.CreatedDate <= endDate && carAssetCountMap.containsKey(loopvar.Asset__c)){
                carAssetCountMap.get(loopvar.Asset__c).add(loopvar);
                system.debug('@@ inside if@@');
            }
            else if(loopvar.CreatedDate>=startDate && loopvar.CreatedDate <= endDate){
                carAssetCountMap.put(loopvar.Asset__c,new List<Case_Asset_Relationship__c> {loopvar});
                system.debug('@@ inside else@@');
            }
        }
        
        system.debug('@@ fetchCARCount - End @@'+carAssetCountMap);
        
        return carAssetCountMap;
        
    }
    
    // This method constructs the map of Asset Id and Start / End Dates
    Public static Map<Id,String> createAssetDateMap(List<Id> assetId){
        system.debug('@@ createAssetDateMap - Start @@');
        
        Map<Id,String>  assetDatesMap       = new Map<Id,String>();
        List<Asset> lstAssets               = [SELECT Start_Date__c, End_Date__c
                                               FROM Asset
                                               WHERE Id =: assetId
                                              ];
        
        for(Asset loopvar: lstAssets){
            assetDatesMap.put(loopvar.Id, String.valueOf(loopvar.Start_Date__c)+';'+String.valueOf(loopvar.End_Date__c));
        }
        
        system.debug('@@ createAssetDateMap - End @@'+assetDatesMap);
        return assetDatesMap;
    }
    
    //Added by Pratik on 13th December 2018 for CRM-3405
    public static void handleAfterInsert(List<OrderItem> lstOrderItem)
    {
        IsOrderTgrExecuted = true;
        //Set<String> setLineString = new Set<String>{'Add','Renew','Amend'};
        List<OrderItem> lstOrderItemRec = [Select Id, Order.AccountId, Line_Type__c, 
                                           Pricebookentry.Product2.ProductCode, 
                                           Fulfillment_Status__c, Case__c, Part_Number__c, 
                                           Order.Account.Type 
                                           From OrderItem 
                                           Where Id IN:lstOrderItem
										   AND (
       ((Order.Account_Type__c = 'Broker' OR Order.Account_Type__c = 'Region') AND (Line_Type__c = 'Renew' OR Line_Type__c = 'Add' OR Line_Type__c = 'Amend'))
		OR 
		(Order.Account_Type__c = 'Realtor Agent' AND Line_Type__c = 'Add'))];
       System.debug('The value coming here is *Ve##nu##'+lstOrderItemRec);   
        
        Set<Id> setAccId = new Set<Id>();
        Set<Id> setBrokerAccId = new Set<Id>();
        
        for(OrderItem item :lstOrderItemRec)
        { 
            //if(item.Order.Account.Type == 'Realtor Agent' && ()){
            setAccId.add(item.Order.AccountId);
            //}
            
            if(item.Order.Account.Type == 'Region' || item.Order.Account.Type == 'Broker')
                setBrokerAccId.add(item.Order.AccountId);
        }
        System.debug(' Update 2'+lstOrderItemRec);
        //Set<String> setAccountTypes = new Set<String>{'Realtor Agent','Broker','Region'};
        Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, 
                                                            (Select Id,Description,Type,Status,Origin,Area__c,Sub_Area__c,AccountId From Cases 
                                                             Where Status != 'Closed' 
                                                             AND Subject Like '%Welcome Call%' 
                                                             AND Type = 'Outbound' 
                                                             AND Area__c = 'Product Set Up') 
                                                            From Account 
                                                            Where Id IN:setAccId /*and Type=:setAccountTypes*/]);
        System.debug(' Update 3'+mapAccount);
        
        // CRM-6037 - Start
        //Set<String> setPart = new Set<String>{'LISTHUBPRO', 'REESIO'};
        List<String> prodCodes = Label.Skip_Welcome_Case_Products.split(',');
        Set<String> setPart = new Set<String>();
        setPart.addAll(prodCodes);
        // CRM-6037 - End
        //List<Case> lstCase = new List<Case>();
        Map<String, Case> mapAccountIdVsCase = new Map<String, Case>();
        Set<String> setPartNumber = new Set<String>{'TOPCRM', 'TOPIDX', 'TOPMRKSNP', 'TOPWEB'};
            //Set<Id> setAccountId = new Set<Id>();
            Map<String, String> mapAccountIdVsCaseDesc = new Map<String, String>();
        String products;
        for(Account acc:mapAccount.values()){
            String codeDescription;
            if(acc.Cases.size()>0 && acc.Cases[0].Description!=null){
                //for(){
                codeDescription = acc.Cases[0].Description;
                // }
                
                mapAccountIdVsCaseDesc.put(acc.id,codeDescription);
                mapAccountIdVsCase.put(acc.Id, acc.Cases[0]);
            }
        }
        
        Map<Id, Id> mapAccountVsOwnerId = new Map<Id, Id>();
        if(!setBrokerAccId.isEmpty() || test.isRunningTest())
        {
            List<AccountTeamMember> lstAccountTeam = [Select AccountId, UserId From AccountTeamMember 
                                                      Where TeamMemberRole = 'Account Manager' 
                                                      AND AccountId IN:setBrokerAccId];
            
            for(AccountTeamMember accountTeam :lstAccountTeam)
                mapAccountVsOwnerId.put(accountTeam.AccountId, accountTeam.UserId);
        }
        
        Set<String> setProductCode = new Set<String>();
        // AssignmentRule assignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRule.id;
        Map<Id, Boolean> mapAccountIdVsLagacyFlag = new Map<Id, Boolean>();
        
        for(OrderItem item :lstOrderItemRec)
        {
            // if(setProductCode.add(item.Pricebookentry.Product2.ProductCode))
            // {
            if(mapAccountIdVsCaseDesc.containsKey(item.Order.AccountId))
            {
                products = mapAccountIdVsCaseDesc.get(item.Order.AccountId);
                if(!products.contains(item.Pricebookentry.Product2.ProductCode)){
                    products += ','+ item.Pricebookentry.Product2.ProductCode;
                }
            }
            else {
                products = item.Pricebookentry.Product2.ProductCode;
                //products += ','+ item.Pricebookentry.Product2.ProductCode;
            }
            
            mapAccountIdVsCaseDesc.put(item.Order.AccountId, products);
            //}
        }
        for(OrderItem item :lstOrderItemRec)
        {
            
            /*if((item.Order.Account.Type == 'Broker' && item.Line_Type__c == 'Renew' 
|| item.Line_Type__c == 'Add') && item.Fulfillment_Status__c == 'Fulfilled' 
&& !setPart.contains(item.Part_Number__c) && mapAccount.get(item.Order.AccountId) != Null  && mapAccount.get(item.Order.AccountId).Cases.isEmpty() 
&& !mapAccountIdVsCase.containsKey(item.Order.AccountId))
{*/
            if(!setPart.contains(item.Part_Number__c) && mapAccount.get(item.Order.AccountId) != Null  && mapAccount.get(item.Order.AccountId).Cases.isEmpty() 
               && !mapAccountIdVsCase.containsKey(item.Order.AccountId)){
                System.debug(' Update 4');
                Case caseToAdd = new Case();
                caseToAdd.Status = 'New';
                caseToAdd.Origin = 'Web';
                caseToAdd.Type = 'Outbound';
                caseToAdd.Area__c = 'Product Set Up';
                caseToAdd.Sub_Area__c = 'New';
                caseToAdd.Subject = 'Welcome Call';
                caseToAdd.AccountId = item.Order.AccountId;
                
                if(mapAccountVsOwnerId.containsKey(item.Order.AccountId))
                    caseToAdd.ownerId = mapAccountVsOwnerId.get(item.Order.AccountId);
                else
                    caseToAdd.setOptions(dmlOpts);
                //lstCase.add(caseToAdd);
                System.debug(caseToAdd);
                mapAccountIdVsCase.put(item.Order.AccountId, caseToAdd);
            }
            if(item.Part_Number__c!=null && setPartNumber.contains(item.Part_Number__c))
                mapAccountIdVsLagacyFlag.put(item.Order.AccountId, True);
            
        }

        Case caseNew;
        for(String accountId :mapAccountIdVsCaseDesc.keySet())
        {
            if(mapAccountIdVsCase.containsKey(accountId)) {
                System.debug(' Update 5');
                caseNew = mapAccountIdVsCase.get(accountId);
                caseNew.Description = mapAccountIdVsCaseDesc.get(accountId);
                if(mapAccountIdVsLagacyFlag.containsKey(accountId))
                    caseNew.Legacy_Product__c = True;
                if(!mapAccountVsOwnerId.containsKey(accountId)){caseNew.setOptions(dmlOpts);} 
                else if(mapAccountVsOwnerId.containsKey(accountId)){
                    caseNew.ownerId = mapAccountVsOwnerId.get(accountId);}
                mapAccountIdVsCase.put(accountId, caseNew);
            }
            else if(mapAccount.containsKey(accountId) && !mapAccount.get(accountId).Cases.isEmpty())
            {
                /* caseNew = mapAccount.get(accountId).Cases[0];
                    caseNew.Description = mapAccountIdVsCaseDesc.get(accountId);
                    if(mapAccountIdVsLagacyFlag.containsKey(accountId))
                    caseNew.Legacy_Product__c = True;
                    if(!mapAccountVsOwnerId.containsKey(accountId)){caseNew.setOptions(dmlOpts);}
                    else if(mapAccountVsOwnerId.containsKey(accountId)){
                    caseNew.ownerId = mapAccountVsOwnerId.get(accountId);}
                    mapAccountIdVsCase.put(accountId, caseNew);
                    System.debug(' Update 6');*/
                
            }
        }
        
        if(!mapAccountIdVsCase.isEmpty())
            system.debug('My case links : '+mapAccountIdVsCase.values());
        upsert mapAccountIdVsCase.values();
        
        for(OrderItem item :lstOrderItemRec)
        {
            if(mapAccountIdVsCase.containsKey(item.Order.AccountId))
                item.Case__c = mapAccountIdVsCase.get(item.Order.AccountId).Id;
        }
        SkipOrderItemTrigger.setSkipTrgTrue();
        update lstOrderItemRec;
    }
    
    /*  public static void handleAfterUpdate(List<OrderItem> lstOrderItem, Map<Id, OrderItem> mapOrderItem)
		{
            Set<String> setPart = new Set<String>{'LISTHUBPRO', 'REESIO'};
            List<OrderItem> lstOrderItemRec = new List<OrderItem>();
            
            for(OrderItem item :lstOrderItem)
            {
            System.debug(' Update 1'); //item.Order.Account.Type == 'Broker' && 
            if((item.Line_Type__c == 'Renew' 
            || item.Line_Type__c == 'Add' || item.Line_Type__c == 'Amend') 
            && item.Fulfillment_Status__c == 'Fulfilled' 
            && item.Fulfillment_Status__c != mapOrderItem.get(item.Id).Fulfillment_Status__c 
            && !setPart.contains(item.Part_Number__c))
            {
            lstOrderItemRec.add(item);
            }
            }
            
            if(!lstOrderItemRec.isEmpty())
            handleAfterInsert(lstOrderItemRec);
            }*/
    //Ends here
}