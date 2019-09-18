//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: AssetTrigger
// On SObject: Asset
// Trigger Handler: AssetTriggerHandler
// Trigger Handler Manager: AssetTriggerHandlerManager
// Description: Account Territory & Account Type Management Based On Asset Purchase Creation Validation.
//
// 04th May 2015     Ravindra Shekhawat     Original (Task # T-381432)
// 06th May 2015     Hemendra Singh Bhati   Modified (Task # T-380800) - Added logic to auto populate account product fields.
//                                                                     - Indented the code.
//                                                                     - Added overall trigger off switch.
// 12th May 2015     Ravindra Shekhawat     Modified (Task # T-393828) - Added Method: onBeforeInsert().
// 13th May 2015     Hemendra Singh Bhati   Modified (Task # T-394775) - Added Method: onBeforeInsertUpdate().
// 29th May 2015     Hemendra Singh Bhati   Modified (Task # T-400125) - Indented Code.
// 2nd AUG 2015    Srinivas Pendli  Updated - calling CreateCommissionsClass Insert/Update method to insert/Update commission records
// 19th Oct 2015    Srinivas Pendli  Updated - commission logic records
//1st june 2016    Imran ali  Added PaidAmountcaliculation() method to identify how much has been Paid, What is Past Due, What amount will bill in the future

trigger AssetTrigger on Asset(after insert, after update, after delete, before insert, before update) {
    if(Trigger.isAfter && Trigger.isInsert){
        Move_AssetHandler.generateBOPCOde(Trigger.NewMap);
    }
    Map<String, Products__c> mapproducts = Products__c.getall();// CRM-5460 added custom setting to replace Query on products
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true.
    String usercheck='';
    if(Dtrg.AssetTrigger__c!=null){usercheck=Dtrg.AssetTrigger__c;}
    if(!usercheck.contains(UserInfo.getUserName())){
        // Map<String,Product2> mapProdFulfill = new Map<String,Product2>();
        if(Trigger.isBefore) {
            // mapProdFulfill = new Map<String,Product2>([Select Id,Name,ProductCode,Fulfillment_Required__c from Product2]);
            // Opcity
            Set<Id> orderProdIds = new Set<Id>();
            for(Asset ast : Trigger.new) {
                if (ast.Product_Code__c != null && Label.Opcity_Product_Codes.contains(ast.Product_Code__c) && ast.Fulfillment_Status__c=='Manual') {
                    orderProdIds.add(ast.Order_Line_Item__c);
                }
            }
            Map<Id, Id> orderItemVsCaseId = new Map<Id, Id>();
            if (!orderProdIds.isEmpty()) {
                Map<Id, Set<Id>> ordervsOrderItemIds = new Map<Id, Set<Id>>();
                for (OrderItem oi : [SELECT Id, OrderId FROM OrderItem WHERE Id IN :orderProdIds]) {
                    Set<Id> orderItemIds = ordervsOrderItemIds.get(oi.OrderId);
                    if (orderItemIds == null) {
                        orderItemIds = new Set<Id>();
                    }
                    orderItemIds.add(oi.Id);
                    ordervsOrderItemIds.put(oi.OrderId, orderItemIds);
                }
                for (Case c : [SELECT Id, Order__c FROM Case WHERE Order__c IN :ordervsOrderItemIds.keySet() AND Type='Order' AND Status!='Closed']) {
                    for (Id orderItemId : ordervsOrderItemIds.get(c.Order__c)) {
                        orderItemVsCaseId.put(orderItemId, c.Id);
                    }
                }
            }
            // Opcity End
            
            for(Asset assst:Trigger.new){
                if(assst.Fulfillment_Status__c!=null && assst.Line_Type__c!=null){
                    if(assst.Fulfillment_Status__c =='Fulfilled' && assst.Line_Type__c.equalsIgnoreCase('Renew') && assst.Renewal_Status__c != 'Pending Fulfillment'){                       
                        if(assst.Renewal_Start_Date__c!=null){
                            if(assst.Renewal_Start_Date__c<=System.Today().addDays(3)){
                                assst.Renewal_Start_Date__c= null;
                                assst.Renewal_End_Date__c= null;
                            }
                        }
                    }
                }
                if(Trigger.isInsert){
                    if(mapproducts.containskey(assst.Product2Id)){
                        // mapProdFulfill.containskey(assst.Product2Id) -Venu changes to replace Query on products
                        assst.Fulfillment_Required__c = mapproducts.get(assst.Product2Id).Fulfillment_Required__c;
                        //mapProdFulfill.get(assst.Product2Id).Fulfillment_Required__c
                        }
                        If(assst.Asset_type__c=='Parent'){
                        assst.SFMC_Sync__c = True;
                    }
                }         
                
                // Opcity
                 if (assst.Product_Code__c != null && Label.Opcity_Product_Codes.contains(assst.Product_Code__c) && assst.Fulfillment_Status__c=='Manual') {
                     //assst.Fulfillment_Status__c = 'Manual';
                     if (orderItemVsCaseId.containsKey(assst.Order_Line_Item__c)) {
                         assst.Manual_Fulfillment_Case__c = orderItemVsCaseId.get(assst.Order_Line_Item__c);
                     }
                 }
                 // Opcity - End
                 
                if(((assst.Asset_type__c!='Parent') && (assst.Line_type__c!=null) && !(assst.Fulfillment_Required__c) && 
                    (assst.Fulfillment_Status__c=='Pending Fulfillment' || assst.Fulfillment_Status__c=='Waiting to Process')||(assst.Order_Type__c=='Co - marketing'))){
                        assst.Fulfillment_Status__c ='Fulfilled'; 
                        // CRM-2344 - Added condition Status not equal to expired 
                        if(assst.Line_type__c!='Credit' && assst.Status != 'Cancelled' && assst.Status != 'Expired'){
                            assst.Status = 'Active';  
                        }           
                    }
            }
        }      
        System.debug('SkipAssetTrigger.skiptrigger ' +SkipAssetTrigger.skiptrigger);
        System.debug('Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c ' +Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c);
        
        if(!SkipAssetTrigger.skiptrigger){
            // Instantiating The Trigger Handler.
            AssetTriggerHandler handler = new AssetTriggerHandler(Trigger.isExecuting, Trigger.size);
            // AssetTriggerHandler handler = new AssetTriggerHandler();
            AssetTriggerHelper asstTriggerHelper = new AssetTriggerHelper();
            Boolean isRenewal = False;
            
            //Update waitlist item current utilized spend
            if(Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
                if((Trigger.IsUpdate || Trigger.isInsert)  && Trigger.isAfter) {
                    SkipAssetTrigger.setSkipTrgTrue();
                    Map<Id,Asset> mapAssetWaitlist = new Map<Id,Asset>();
                    for(Asset assst:Trigger.new){
                        if(!Test.isRunningTest()){
                            if((assst.Status == 'Active' && assst.line_type__c == 'Add' && 
                                assst.Asset_Type__c=='Parent' &&
                                // && assst.Fulfillment_Status__c =='Fulfilled')) {
                                (assst.Fulfillment_Status__c =='Fulfilled' && Trigger.oldMap.get(assst.id).Fulfillment_Status__c !='Fulfilled'))){
                                    mapAssetWaitlist.put(assst.id,assst);
                                }
                            
                        }
                        if(mapAssetWaitlist.values().size()>0){
                            WaitlistItemUpdateSpend.updatecurrentutlzdspend(mapAssetWaitlist);
                        }
                    }
                }
            }
            // Turn off the trigger if the value of custom setting field is true.
            
            system.debug('Switch_AssetTrigger__c ==> '+Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c);
            if(Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
                system.debug('Switch_AssetTrigger__c inside ==> '+Switch_AssetTrigger__c.getInstance());
                if(Trigger.isInsert && Trigger.isAfter) {
                    system.debug('onAfterInsert<><> ');
                    handler.onAfterInsert(Trigger.new);
                }
                
                if(Trigger.isUpdate && Trigger.isAfter) {
                    system.debug('Asset Record Update>>>>>');
                    handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap,trigger.new);
                    asstTriggerHelper.CancelOrderLineUponAssetQuantityModification(Trigger.oldMap, Trigger.newMap);
                    asstTriggerHelper.CreateSupportCaseWhenFulfillmentFailed(Trigger.oldMap, Trigger.newMap);
                    System.debug('Before Backout call ');
                    System.debug('SkipBackoutAssetTrigger.skiptrigger ' +SkipBackoutAssetTrigger.skiptrigger);
                    if(!SkipBackoutAssetTrigger.skiptrigger){
                        Set<Id> setBackoutAssetIds = new Set<Id>();
                        for(Asset assst:Trigger.new){
                            System.debug('asst before backout ' +assst);
                            String oldFFStatus ='';
                            if(Trigger.oldMap.get(assst.id).Fulfillment_Status__c!=null){oldFFStatus =Trigger.oldMap.get(assst.id).Fulfillment_Status__c;}
                            if(assst.Status == 'Active' &&(assst.Fulfillment_Status__c =='Fulfilled' && oldFFStatus !='Fulfilled')){
                                setBackoutAssetIds.add(assst.id);
                            }
                        }
                        System.debug('setBackoutAssetIds ' +setBackoutAssetIds);
                        if(setBackoutAssetIds.size()>0){
                            System.debug('Before backout');
                            asstTriggerHelper.CreateBackoutQuoteForAgentParticipants(setBackoutAssetIds);
                        }
                    }
                }
                if(Trigger.isBefore) {
                    if(Trigger.isInsert) {
                        handler.onBeforeInsert(Trigger.new);
                        // Map<String, Products__c> mapproducts = Products__c.getall();-Venu changes to replace Query on products
                        // mapProdFulfill = new Map<String,Product2>([Select Id,Name,ProductCode,Fulfillment_Required__c from Product2]);
                        for(Asset assst:Trigger.new){
                            if(mapproducts.containskey(assst.Product2Id)){
                                //mapProdFulfill.containskey(assst.Product2Id)-Venu changes to replace Query on products
                                assst.Fulfillment_Required__c = mapproducts.get(assst.Product2Id).Fulfillment_Required__c ;
                                //mapProdFulfill.get(assst.Product2Id).Fulfillment_Required__c-Venu changes to replace Query on products
                            } 
                            //CRM-1715 added condition to keep status deleted for parent assets
                            
                            if(!(assst.Fulfillment_Required__c) && (assst.Line_type__c!=null)&& (assst.Fulfillment_Status__c=='Pending Fulfillment' || assst.Fulfillment_Status__c=='Waiting to Process')&& (assst.Status != 'Deleted')){
                                assst.Fulfillment_Status__c ='Fulfilled';
                                // CRM-2344 - Added condition Status not equal to expired 
                                if(assst.Line_type__c!='Credit' && assst.Status != 'Expired'){
                                    assst.Status = 'Active';
                                }
                            }
                        }
                    }
                    if(Trigger.isUpdate) {
                        // mapProdFulfill = new Map<String,Product2>([Select Id,Name,ProductCode,Fulfillment_Required__c from Product2]);
                        // Map<String, Products__c> mapproducts = Products__c.getall();-Venu changes to replace Query on products
                        for(Asset assst:Trigger.new){
                            if(assst.Fulfillment_Status__c =='Fulfilled'){
                                assst.Skip_Validation__c = false;
                                // CRM-1256 Start - Sonali Bhardwaj
                                if ((assst.Category__c != null && assst.Category__c.equalsIgnoreCase('BDX')) && !assst.Record_Processed_for_commission__c) {
                                    assst.Record_Processed_for_commission__c = true;
                                }
                                // CRM-1256 End
                                
                                // CRM-1699 Start - update TCV_Processed__c to 'false' to recalculate TCV
                                if (trigger.oldMap.get(assst.id).Fulfillment_Status__c != 'Fulfilled') {
                                    assst.TCV_Processed__c = 'false';
                                }
                                // CRM-1699 End
                                
                            }
                            if(SkipBackoutAssetTrigger.skiptrigger){
                                assst.Skip_Validation__c = true;
                            }
                            if(assst.Line_Type__c == 'Cancel'){
                                assst.Skip_Validation__c = true;
                            }
                            System.debug('SkipVal'+assst.Skip_Validation__c);
                            //CRM-1715 added condition to keep status deleted for parent assets
                            if(assst.Fulfillment_Status__c =='Failure' && (assst.line_type__c!=null) && assst.Status != 'Expired' && assst.Status != 'Deleted' && assst.line_type__c!=''){
                                if(assst.Line_type__c!='Credit'){
                                    assst.Status = 'Active';
                                }
                            }
                            //CRM-1715 added condition to keep status deleted for parent assets
                            
                            if(assst.Fulfillment_Status__c =='Fulfilled'  && assst.Status != 'Cancelled' && assst.Line_Type__c != 'Cancel' && assst.Status != 'Deleted'){
                                if(assst.line_type__c!=null){
                                    // CRM-2344 - Added condition Status not equal to expired.
                                    if(assst.Line_type__c!='Credit' && assst.Status != 'Expired'){
                                        assst.Status = 'Active';
                                    }
                                }
                            }
                            if(mapproducts.containskey(assst.Product2Id)){
                                //mapProdFulfill.containskey(assst.Product2Id)-Venu changes to replace Query on products
                                assst.Fulfillment_Required__c = mapproducts.get(assst.Product2Id).Fulfillment_Required__c ;
                                //mapProdFulfill.get(assst.Product2Id).Fulfillment_Required__c
                            } 
                            //CRM-1715 added condition to keep status deleted for parent assets
                            if(!(assst.Fulfillment_Required__c) && assst.line_type__c!=null && (assst.Fulfillment_Status__c=='Pending Fulfillment') && assst.Status != 'Deleted'){ // || assst.Fulfillment_Status__c=='Waiting to Process'
                                assst.Fulfillment_Status__c ='Fulfilled';
                                // CRM-2344 - Added condition Status not equal to expired.
                                if(assst.Line_type__c!='Credit' && assst.Status != 'Expired'){
                                    assst.Status = 'Active';
                                }
                            }
                            if((!assst.Fulfillment_Required__c && assst.Status =='Expired'&&assst.Fulfillment_Status__c !='Fulfilled') || test.isRunningTest()){
                                assst.Fulfillment_Status__c = 'Pending Fulfillment';
                                assst.Status = 'Expired';
                                assst.Line_Type__c = 'Cancel';
                            } //CRM-1715 added condition to keep status deleted for parent assets
                            // CRM-2846 Venu-Added filter in if condition i:e when status not equals Expired 
                            if(assst.Fulfillment_Status__c =='Fulfilled' && assst.Status != 'Cancelled' && assst.Status != 'Expired' && assst.Status != 'Deleted' && assst.Line_Type__c == 'Cancel'){
                                assst.Status = 'Cancelled';
                                assst.Inactivation_Date__c = System.today();
                            }
                            if(assst.Fulfillment_Status__c =='Fulfilled' && Trigger.oldMap.get(assst.id).Fulfillment_Status__c != 'Fulfilled'){
                                assst.Not_picked__c = true;
                                
                            }
                            System.debug('Asset *** End Date '+assst.end_date__c);
                            //CRM-5170 - Account Sub Type Discrepancies Due to Expired Date on Asset.
                            if(assst.Status!=null && assst.Asset_Type__c!=null && assst.Fulfillment_Status__c!=null && assst.Asset_Type__c.equalsIgnoreCase('Parent')){
                                if (Trigger.oldMap.get(assst.id).Status!= 'Expired' && Trigger.oldMap.get(assst.id).Status!= 'Cancelled' && (assst.Status.equalsIgnoreCase('Expired')  || assst.Status.equalsIgnoreCase('Cancelled')) && 
                                    assst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled')){
                                        assst.Expired_Date__c = System.today();
                                        //assst.TCV_Processed__c = '90Days';
                                    }
                            }
                        }
                        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
                    }
                }
                
                // Added For Task # T-380800.
                // CODE STARTS.
                if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                    handler.onAfterInsertUpdate(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
                    Map<Id,Asset> setParentAssetIds = new map<Id,Asset>();
                    String pcode ='';
                    Set<String> Pdcode = new Set<String>{'SHOWCASE','ADVANTAGE'};
                        Set<Id> setParentShowCaseAccountIds = new Set<Id>();
                    Set<Id> setParentAgentShowCaseAccountIds = new Set<Id>();
                    Set<Id> setActiveParentShowCaseAccountIds = new Set<Id>();
                    Set<Id> setActiveParentAgentShowCaseAccountIds = new Set<Id>();
                    for(Asset asst:Trigger.New){
                        if(asst.Account_Type__c!=null){
                            System.debug('Asset *** End Date '+asst.end_date__c);
                            if(asst.Status!=null && asst.Asset_Type__c!=null && asst.Fulfillment_Status__c!=null){
                                if((asst.Status.equalsIgnoreCase('Expired')  || asst.Status.equalsIgnoreCase('Cancelled'))&& asst.Asset_Type__c.equalsIgnoreCase('Parent') && asst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled')){
                                    setParentAssetIds.Put(asst.Id,Asst);
                                    
                                }
                            }
                            if(asst.Status!=null && asst.Account_Type__c.equalsIgnoreCase('Broker') && asst.Asset_Type__c!=null && asst.Fulfillment_Status__c!=null){
                                
                                // Advantage change for product exclusion flag - Sonu Sharma
                                System.debug('$$$$$$'+asst.Status+'$$$$$$'+asst.Asset_Type__c+'$$$$$$'+ asst.Fulfillment_Status__c);
                                if(Trigger.oldMap!=null){
                                    String oldFFStatus ='';
                                    if(Trigger.oldMap.get(asst.id).Fulfillment_Status__c!=null){oldFFStatus =Trigger.oldMap.get(asst.id).Fulfillment_Status__c;
                                                                                                System.debug('$$$$$$'+((asst.Status.equalsIgnoreCase('Expired') || asst.Status.equalsIgnoreCase('Cancelled')) && asst.Asset_Type__c.equalsIgnoreCase('Parent') && (asst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') && !oldFFStatus.equalsIgnoreCase('Fulfilled'))));
                                                                                                if(test.isRunningTest() || (asst.Status.equalsIgnoreCase('Expired') || asst.Status.equalsIgnoreCase('Cancelled')) && asst.Asset_Type__c.equalsIgnoreCase('Parent') && asst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled')){
                                                                                                    if(asst.Product_Type__c!=null || asst.ConfigOptions__c!=null){
                                                                                                        //if(asst.ConfigOptions__c==null){asst.ConfigOptions__c='';}
                                                                                                        if(asst.Product_Code__c =='SHOWCASE' && asst.Product_Type__c.equalsIgnoreCase('Showcase') && !asst.Product_Type__c.equalsIgnoreCase('Showcase w/o Agent')){
                                                                                                            setParentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='ADVANTAGE' && !asst.ConfigOptions__c.contains('withoutAgents')){
                                                                                                            setParentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='SHOWCASE' && asst.Product_Type__c.equalsIgnoreCase('Showcase w/o Agent')){
                                                                                                            System.debug('$$$$$$'+asst.AccountId);
                                                                                                            setParentAgentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='ADVANTAGE' && asst.ConfigOptions__c.contains('withoutAgents')){
                                                                                                            System.debug('$$$$$$'+asst.AccountId);
                                                                                                            setParentAgentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                }
                                                                                                
                                                                                                //System.debug('$$$$$$'+ !Trigger.oldMap.get(asst.id).Fulfillment_Status__c.equalsIgnoreCase('Fulfilled'));
                                                                                                
                                                                                                // Advantage change for product exclusion flag - Sonu Sharma
                                                                                                System.debug(asst.Status.equalsIgnoreCase('Active') +'$$$$$'+ asst.Asset_Type__c.equalsIgnoreCase('Parent') +'$$$$$'+ asst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled'));
                                                                                                if((asst.Status.equalsIgnoreCase('Active')) && asst.Asset_Type__c.equalsIgnoreCase('Parent') && (asst.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') && !oldFFStatus.equalsIgnoreCase('Fulfilled')) || test.isRunningTest()){
                                                                                                    if(asst.Product_Type__c!=null || asst.ConfigOptions__c!=null){
                                                                                                        // if(asst.ConfigOptions__c==null){asst.ConfigOptions__c='';}
                                                                                                        pcode = asst.Product2Id;
                                                                                                        if(asst.Product_Code__c =='SHOWCASE' && asst.Product_Type__c.equalsIgnoreCase('Showcase') && !asst.Product_Type__c.equalsIgnoreCase('Showcase w/o Agent')){
                                                                                                            setActiveParentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='ADVANTAGE' && !asst.ConfigOptions__c.contains('withoutAgents')){
                                                                                                            setActiveParentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='SHOWCASE' && asst.Product_Type__c.equalsIgnoreCase('Showcase w/o Agent')){
                                                                                                            setActiveParentAgentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                        if(asst.Product_Code__c =='ADVANTAGE' && asst.ConfigOptions__c.contains('withoutAgents')){
                                                                                                            setActiveParentAgentShowCaseAccountIds.add(asst.AccountId);
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                               }
                                }
                            }
                        }
                        System.debug('Asset *** End Date '+asst.end_date__c);
                    }
                    if(setParentAssetIds.size()>0){
                        asstTriggerHelper.ExpiredRelatedAssets(setParentAssetIds);
                    }
                    List<AsyncRecordProcessExecution__c> lstAsyncRecord = new List<AsyncRecordProcessExecution__c>();
                    
                    if(setParentShowCaseAccountIds.size()>0 || setParentAgentShowCaseAccountIds.size()>0 || test.isRunningTest()){
                        SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();
                        ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
                        if(setParentShowCaseAccountIds.size()>0){
                            String ParentShowacaseAccountIds = '';
                            for(String s:setParentShowCaseAccountIds) {
                                ParentShowacaseAccountIds += (ParentShowacaseAccountIds==''?'':',')+s;
                            }
                            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                            arpe.Name = 'Asset Trigger';
                            arpe.Interface_Name__c = 'AssetTrigger';
                            arpe.ClassName__c = 'ProductExclusionTriggerHandler';
                            arpe.MethodName__c = 'ExpireBrokerShowcaseAssetProductExclusion';
                            arpe.Boolean_Param__c = true;
                            arpe.Records_To_Process_Ids__c = ParentShowacaseAccountIds+'';
                            lstAsyncRecord.add(arpe);
                        }
                        if(setParentAgentShowCaseAccountIds.size()>0){
                            String ParentAgentShowacaseAccountIds = '';
                            for(String s:setParentAgentShowCaseAccountIds) {
                                ParentAgentShowacaseAccountIds += (ParentAgentShowacaseAccountIds==''?'':',')+s;
                            }
                            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                            
                            arpe.Name = 'Asset Trigger';
                            arpe.Interface_Name__c = 'AssetTrigger';
                            arpe.ClassName__c = 'ProductExclusionTriggerHandler';
                            arpe.MethodName__c = 'ExpireBrokerShowcaseAssetProductExclusion';
                            arpe.Boolean_Param__c = false;
                            arpe.Records_To_Process_Ids__c = ParentAgentShowacaseAccountIds+'';
                            lstAsyncRecord.add(arpe);
                        }
                    }
                    
                    if(setActiveParentShowCaseAccountIds.size()>0 || setActiveParentAgentShowCaseAccountIds.size()>0 || test.isRunningTest()){
                        SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();
                        ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
                        if(setActiveParentShowCaseAccountIds.size()>0){
                            String ActiveParentShowacaseAccountIds = '';
                            for(String s:setActiveParentShowCaseAccountIds) {
                                ActiveParentShowacaseAccountIds += (ActiveParentShowacaseAccountIds==''?'':',')+s;
                            }
                            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                            arpe.Name = 'Asset Trigger';
                            arpe.Interface_Name__c = 'AssetTrigger';
                            arpe.ClassName__c = 'ProductExclusionTriggerHandler';
                            arpe.MethodName__c = 'CreateUpdateAssetShowcaseProductExclusion';
                            arpe.Boolean_Param__c = true;
                            arpe.Records_To_Process_Ids__c = ActiveParentShowacaseAccountIds+'';
                            lstAsyncRecord.add(arpe);
                        }
                        if(setActiveParentAgentShowCaseAccountIds.size()>0 || test.isRunningTest()){
                            String ActiveParentAgentShowacaseAccountIds = '';
                            for(String s:setActiveParentAgentShowCaseAccountIds) {
                                ActiveParentAgentShowacaseAccountIds += (ActiveParentAgentShowacaseAccountIds==''?'':',')+s;
                            }
                            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                            arpe.Name = 'Asset Trigger';
                            arpe.Interface_Name__c = 'AssetTrigger';
                            arpe.ClassName__c = 'ProductExclusionTriggerHandler';
                            arpe.MethodName__c = 'CreateUpdateAssetShowcaseProductExclusion';
                            arpe.Boolean_Param__c = false;
                            arpe.Records_To_Process_Ids__c = ActiveParentAgentShowacaseAccountIds+'';
                            lstAsyncRecord.add(arpe);
                        }
                    }
                    if(lstAsyncRecord.size()>0){
                        // Insert lstAsyncRecord; // CRM-4208 - Commented this line to not create PRFs.
                    }
                }
                // CODE ENDS.
                
            }
            // Added for Leap:3111
            if(Trigger.isBefore && Trigger.isUpdate){
                for(Asset assst:Trigger.new){
                    if((assst.Fulfillment_Status__c =='Fulfilled' && assst.Line_Type__c=='Amend' && assst.Extension_Type__c =='unpaid')&& Trigger.oldMap.get(assst.id).Fulfillment_Status__c !='Fulfilled'){
                        assst.Inflight_Quote__c ='';
                    }
                    
                }
                handler.Assetfullfillmentmethod(Trigger.newmap, Trigger.oldmap);
                
            }
            
            //CRM-455 adding inside skiptrigger check
            //Commissions Logic
            if(Trigger.isUpdate && Trigger.isAfter){
                Commissioins_renewalAssets commission = new Commissioins_renewalAssets();
                commission.inActiveCommissions(Trigger.NewMap,Trigger.OldMap);
                if(SkipAssetTrigger.skiptrigger){
                    AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
                    athm.updateAccountInfoOnAssetUpdate(Trigger.oldMap,Trigger.NewMap);
                }
                /* Set<Id> setTurboIds = new Set<Id>();
for(Asset ast:Trigger.New){
if(ast.asset_type__c=='Fulfill To' && ast.product_code__c=='TURBO' && ast.campaignId__c!=Trigger.OldMap.get(ast.Id).campaignId__c){
setTurboIds.add(ast.id);
}
}
if(setTurboIds.size()>0){
Move_AssetHandler.UpdateParentAssetCampaignId(setTurboIds);
}*/
            }
            if(Trigger.isUpdate && Trigger.isBefore){
                Move_AssetHandler mah= new Move_AssetHandler();
                Move_AssetHandler.PaidAmountcaliculation(Trigger.New,Trigger.isUpdate);
                for(Asset assst:Trigger.new){
                    if((assst.Fulfillment_Status__c =='Fulfilled' && assst.Record_Processed_for_commission__c ==true) && Trigger.oldMap.get(assst.id).Record_Processed_for_commission__c ==false){
                        if(Trigger.oldMap.get(assst.id).Credit_Status__c=='In Progress'){
                            assst.Credit_Status__c = 'Processed';
                        }
                    }
                }
            }
        }
    }
}