//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: OrderTrigger
// On SObject: Order
// Description: This trigger will be creating assets from order line items for order whose boolean flag "Is_Order_Creation_Complete__c"
// is updated to "true".
//
// 28th May 2015   Hemendra Singh Bhati   Original (Task # T-398617)
//
trigger OrderTrigger on Order(before update, after update,After Insert) {
DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
public List<Order> lstOrderFullFillAgnt = new List<Order>();
public List<Order> lstOrderFullFillBrk = new List<Order>();
  // Turn off trigger if the value of custom setting field is true. 
  String usercheck='';
        if(Dtrg.Order_Trigger__c!=null){usercheck=Dtrg.Order_Trigger__c;}
        if(!usercheck.contains(UserInfo.getUserName())){
orderTriggerHandler orderHandler = new orderTriggerHandler();
  if(trigger.isAfter && trigger.isUpdate) {
    // Turn on/off the business logic that inserts parent, fulfillTo and participant assets using batch class
    // named "CreateAssetsFromOrderLineItems".
    if(Switch_OrderTrigger__c.getInstance().Set_Asset_Creation_Logic_Off__c == false) {
      // Processing Newly Updated Orders.
      Set<Id> theOrderIdsToProcess = new Set<Id>();
      List<Order> lstOrder = new List<Order>();
      
      for(Order theOrder : trigger.New) {
        if(
          theOrder.Is_OLI_Creation_Complete__c == true &&
          trigger.oldMap.get(theOrder.Id).Is_OLI_Creation_Complete__c == false
        ) {
          theOrderIdsToProcess.add(theOrder.Id);
          lstOrder.Add(theOrder);
        }
        if(trigger.isAfter && trigger.IsUpdate && theOrder.Fulfillment_Status__c == 'Fulfilled' && 
           theOrder.Account_Dont_Call_Notf__c == false){
            system.debug('Account type ++'+theOrder.Account_Type__c);
            if(theOrder.Account_Type__c == 'Broker' || theOrder.Account_Type__c == 'Broker Council') 
               lstOrderFullFillBrk.add(theOrder);
            else if(theOrder.Account_Type__c == 'Realtor Agent' || theOrder.Account_Type__c == 'Agent Team') 
               lstOrderFullFillAgnt.add(theOrder) ;  
        }   
      }
      system.debug('TRACE: OrderTrigger - theOrderIdsToProcess - ' + theOrderIdsToProcess);
      if(trigger.isAfter && trigger.IsUpdate){
      if(theOrderIdsToProcess.size() > 0 && !SkipOrderTrigger.skiptrigger) { 
        CreateAssetsFromOrderLineItemsAssetJSON theBatchProcess = new CreateAssetsFromOrderLineItemsAssetJSON();
        theBatchProcess.isInitiatedFromTrigger = true;
        theBatchProcess.theOrderIdsToProcess = theOrderIdsToProcess;
        //CRM-4054 -- Batch size as 1
        Id theBatchProcessId = Database.executeBatch(theBatchProcess,1);
        system.debug('TRACE: OrderTrigger - theBatchProcessId - ' + theBatchProcessId);
        SkipOrderTrigger.setSkipTrgTrue();
       } 
      }
        //LCM
      orderHandler.onAfterUpdate(trigger.New, trigger.oldmap);
      
      if(lstOrder.size()>0){
      //ProcessOrderToAsset pota = new ProcessOrderToAsset();
      //pota.ProcessOrder(lstOrder);
      }
    }

  }
  /*
      Ravinder - account Owner Update 
  */
  if(trigger.isAfter && trigger.isUpdate){
        orderHandler.onAfterinsertUpdate(trigger.newmap,trigger.oldmap);
        system.debug('Broker List Sze + '+lstOrderFullFillBrk.size() +' Agent List Size + '+lstOrderFullFillAgnt.size());
        //if(!lstOrderFullFillBrk.IsEmpty())
            //orderHandler.insertCasesBrk(lstOrderFullFillBrk);  
        //if(!lstOrderFullFillAgnt.IsEmpty())
          //  orderHandler.insertCasesAgnt(lstOrderFullFillAgnt);  
            
  }
  
  
  
  
  if(trigger.isBefore && trigger.isUpdate)
  {
   if(OrderDecompController.testClassTriggerFlag == true && Test.isRunningTest()){
   
   } else{
   orderTriggerHandlerManager othm = new orderTriggerHandlerManager();
        othm.GenerateJsonOrdersStrings(Trigger.newMap);
    for(Order O : Trigger.new){
       // System.Debug('New: ' + O.Fulfillment_Status__c + '  Old: ' +  Trigger.oldMap.get(O.Id).Fulfillment_Status__c);
       if(Trigger.oldMap.get(O.Id) != null){
        if(O.Fulfillment_Status__c == 'Fulfilled' && Trigger.oldMap.get(O.Id).Fulfillment_Status__c != 'Fulfilled' || Test.isRunningTest()){
                System.Debug('New:' + Trigger.New);
                System.Debug('Old: ' + Trigger.Old);  
                Order order = O;
                System.Debug('Order: ' + order);
                System.Debug('Order Account: ' + order.AccountId);
                
                List<OrderItem> orderItems = [Select Id, quantity, Asset__c,PriceBookEntry.product2.ProductCode, Extended_Net_Price__c, Contract_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, Cancellation_Date__c,Buyout_Amount__c from OrderItem where orderId = :order.Id];

                If(order != null && orderItems.size() > 0  && !SkipOrderTrigger.skiptrigger){
                    // CRM-1212- Added if else
                    Integer jcount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
                    if (jcount <= 85 || Test.isRunningTest()) { 
                        OrderDecompController controller = new OrderDecompController(order);
                        SkipOrderTrigger.setSkipTrgTrue();
                    }
                    else {
                        System.debug('Skipping this order due to limitation on apex schedule job, will be processed with scheduler job - ' + jcount  + '  ' + order.id);
                        order.Run_OrderDecomp__c = true;
                    }
                }
                
                // Advantage change for product exclusion flag - Sonu Sharma
                Boolean hasShowcaseAdvantage=false;
                for(OrderItem oitem:orderItems){
                if(oitem.PriceBookEntry.product2.ProductCode.equalsIgnoreCase('Showcase') || oitem.PriceBookEntry.product2.ProductCode.equalsIgnoreCase('Advantage')){
                if(!hasShowcaseAdvantage){
                hasShowcaseAdvantage = true;
                }
                }
                }
                if(hasShowcaseAdvantage){
        ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
                    if(Trigger.newMap.keyset().size()>0){
                    String OrderIds = '';
                                    for(String s:Trigger.newMap.keyset()) {
                                           OrderIds += (OrderIds==''?'':',')+s;
                                                } 
                    //peth.ShowCaseOfficeAgentProductExclusion(Trigger.newMap.keyset()); 
                            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                                                            arpe.Name = 'Order Trigger';
                                                            arpe.Interface_Name__c = 'OrderTrigger';
                                                            arpe.ClassName__c = 'ProductExclusionTriggerHandler';
                                                            arpe.MethodName__c = 'ShowCaseOfficeAgentProductExclusion';
                                                            arpe.Boolean_Param__c = true;
                                                            arpe.Records_To_Process_Ids__c = OrderIds+'';

                                                          //  insert arpe;
                    
            }   
            }
        }
      }
    }
    }  
  }   
    // CreatedBy: Venkataramana.
    //Usage:  Used to create new child case when Order is upadated to Complete.
    // Created Date:07 july
    ChildCaseCreationUponOrder Handler = new ChildCaseCreationUponOrder();
     if(Trigger.isbefore && Trigger.isUpdate){
       //Handler.ChildCaseCreationUponOrderUpdate(Trigger.new);
        //------------New code Added------------ 
        set<id> parentcaseids = new set<id>();
        id RetentionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Retention').RecordTypeId;        
         for(Order Ord : Trigger.new){
                
           if(Ord.Fulfillment_Status__c == 'Fulfilled'){          
                     
           parentcaseids.add(ord.case__c);           
          
                            }}
                         
           list<case> parentcaselist = [select Status,RecordTypeId from case where id in: parentcaseids];                
                for(case c : parentcaselist)        
                {
                if(c.RecordTypeId == RetentionRtID)
                
                c.Status ='closed';
                
                
                }  
                
                try{
                    update parentcaselist;
                }
                catch(Exception e){}         
            
       //------------New code Added------------
       
       
    }
    // Code Ends
    
    //Added By Srinivas Vadla
    // To update the case status to "ASSETS CANCELLED" when Cancellation Order gets Fulfilled.
    List<case> updateCaseList = new List<case>();
    List<case> CaseList = new List<case>();
    Set<ID> caseId = new Set<ID>();
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Order Ordr : Trigger.new){
            if(Trigger.oldMap.get(Ordr.Id)!=Null && Ordr.Fulfillment_Status__c == 'Fulfilled' && 
               Trigger.oldMap.get(Ordr.Id).Fulfillment_Status__c != 'Fulfilled' && Ordr.Case__c!=null){
               caseId.add(Ordr.Case__c);
            }
        }
        CaseList = [Select Id , recordtype.Name, status from Case where Id IN : caseId];   
        for(Case c : CaseList){      
               if(c.recordtype.Name == 'Collections' && c.status == 'Pending Cancel'){
                c.Status = 'Assets Canceled';
                updateCaseList.add(c);
                }
            }
        }
        if(updateCaseList !=NUll && updateCaseList.size()>0){
            Update updateCaseList;
        }
    }
    }