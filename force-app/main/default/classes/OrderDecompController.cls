/*    Copyright (c) 2014 Zuora, Inc.
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy of 
*   this software and associated documentation files (the "Software"), to use copy, 
*   modify, merge, publish the Software and to distribute, and sublicense copies of 
*   the Software, provided no fee is charged for the Software.  In addition the
*   rights specified above are conditioned upon the following:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
*   or promote products derived from this Software without specific prior written
*   permission from Zuora, Inc.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
*   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
*   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
*   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
*   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
*   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
*   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
*
*   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
*
*   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
*   Description: This class is executed from the OrderTrigger when the Order Fulfillment Status is changed to Fulfilled
*   A Zuora Billing Account is first created or found
*   Order Items are then processed and converted to Zuora Quotes
*   The first 50 Order Items are queued up to be processed
*   The Send To Z-Billing Process (Send Zuora Quotes to Zuora) is scheduled for 5 minutes ahead
*   This process will queue up any remaining Order Items, then begin the Sending process
*/
public class OrderDecompController {
    private static final String FREE_CREDIT_CPQ_ID    = 'CREDIT';
    private static final String BUYOUT_CPQ_ID         = 'CREDIT';
    private static final String COTERM_CPQ_ID         = 'COTERM';
    
    //Used purely for debugging purposes
    private static final String DEBUG_STR = 'OrderDecompController: ';
   
    public static Map<String, Boolean> hasRuns = new Map<String, Boolean>();
    public static Boolean sent = false;
    public static Boolean sent_ba = false;
    public static Boolean errorStatus;
    public static String errorMessage;
    public static Boolean testClassTriggerFlag = false;
    public static Set<id> triggeredOrderIds;
    public static boolean stopCreatingAccount = false;
   // public static boolean stopCreatingAccountobj= false;
    
    public OrderDecompController(Order order) {
        final String FUNC_STR = DEBUG_STR+'constructor: ';
        System.debug(FUNC_STR+'Starting constructor for OrderDecompController');
        if (triggeredOrderIds!=null && triggeredOrderIds.contains(order.Id)){
            System.debug(FUNC_STR+'OrderDecompController was already triggered order will not process');
            return;
        } else {
            triggeredOrderIds= new Set<id>{order.Id};
                }
        
        if(Test.IsRunningTest()){
            testClassTriggerFlag = true;
        }
        
        errorStatus = false;
        errorMessage = '';
        
        if (order.AccountId == null) {
            System.debug(FUNC_STR+'Salesforce Account passed to createAccountZObject is null');
            errorMessage = 'Salesforce Account passed to createAccountZObject is null';
            errorStatus = true;
            updateOrder(order.Id,errorMessage);
            return;
        }
        
        //Create Billing Account in Zuora if none exist
        List<Zuora__CustomerAccount__c> sfdcBillingAccountList = [Select Id,Name, Zuora__Account__r.Past_Due__c, Zuora__Account__r.Consolidated_Billing_Flag__c, Zuora__Zuora_Id__c, Zuora__External_Id__c 
                                                                  FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :order.AccountId LIMIT 1];
        
        System.debug('Size of sfdcBillingAccountList:' + sfdcBillingAccountList.size());
        
        if(sfdcBillingAccountList == null || sfdcBillingAccountList.size() == 0) {
            System.debug(FUNC_STR+'Creating Zuora Account');
            if(!stopCreatingAccount){
                createZuoraAccount(order.Id,  Id.valueOf(order.AccountId));
            }
        } else {
            System.debug(FUNC_STR+'Zuora Account already exists ');
            String zBillingAccountId = sfdcBillingAccountList[0].Zuora__Zuora_Id__c;      
            
            List<Zuora__Subscription__c> listofSubs = [Select Id from Zuora__Subscription__c 
                                                       WHERE Zuora__CustomerAccount__r.Zuora__External_Id__c = :zBillingAccountId 
                                                       AND Zuora__Status__c = 'Active' AND Zuora__SubscriptionEndDate__c >= :System.Today() AND Zuora__TermEndDate__c >= :System.Today()];
            
            //Check for TigerLead Products
            List<OrderItem> accountOrderItems = [Select Id, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, 
                                                 Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, 
                                                 Subscription_Term__c, Line_Type__c, Billing_Period__c, Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, 
                                                 Credit_Amount__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                                                 FROM OrderItem 
                                                 WHERE orderId = :order.Id];
            
            List<String> product2Ids = new List<String>();
            Boolean hasTigerLeadOrCfs = false;
            
            Boolean consBillFlag = sfdcBillingAccountList[0].Zuora__Account__r.Consolidated_Billing_Flag__c;
            for(OrderItem OI1 : accountOrderItems) {
                if(OI1.Pricebookentry.Product2Id != null){
                    product2Ids.add(OI1.Pricebookentry.Product2Id);
                }
            }
            
            List<Product2> orderProduct2s = [SELECT Id, ProductCode,Fulfillment_ID__c FROM Product2 WHERE Id IN :product2Ids];
            System.Debug(FUNC_STR+'orderProduct2s: ' + orderProduct2s);
            if(orderProduct2s != null) { 
                for(Product2 product : orderProduct2s) {
                    if(product.Fulfillment_ID__c == 'Tigerleads' || 
                       ( (product.ProductCode =='SELLERLEADBUNDLE' || product.ProductCode == 'SELLERLEAD') 
                        && consBillFlag == true)) {
                            hasTigerLeadOrCfs = true;
                        }
                }
            }
            
            //End of check for TigerLead Products  
            System.debug(FUNC_STR+'hasTigerLeadOrCfs : '+hasTigerLeadOrCfs );
            
            if((listofSubs == null && !sfdcBillingAccountList[0].Zuora__Account__r.Past_Due__c) || (listofSubs.size() == 0 && !sfdcBillingAccountList[0].Zuora__Account__r.Past_Due__c) || hasTigerLeadOrCfs == true) {
                System.Debug(FUNC_STR+'Updating Billing Account');
                //final String FUNC_STR = DEBUG_STR+'createZuoraAccount: ';
                String orderId = (String)order.Id;
                List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
                
                Account acc = [Select Id,Name,Currency_Type__c, Type, Billing_Preference__c,BillingStreet,BillingCity,
                               BillingState, BillingCountry,BillingPostalCode, ShippingStreet,ShippingCity,ShippingCountry,
                               ShippingPostalCode,ShippingState, Party_Id__c
                               FROM Account 
                               WHERE Id = :order.AccountId];
                 //if(!stopCreatingAccount){
                updateBillingAccount(orderId, zBillingAccountId);
               //}
            }
            
            convertOrderLines(order.Id, Id.valueOf(order.AccountId), zBillingAccountId);
        }
    }  
    
    public static void startOrderDecomp(String orderId, String sfdcAccountId, String zBillingAccount) {
        final String FUNC_STR = DEBUG_STR+'startOrderDecomp: ';
        if(sent_ba == false) {
            sent_ba = true;
            /*Subbu modified to fix scheduling problem */
            //DateTime now = datetime.now().addSeconds(seconds);
            DateTime now = datetime.now().addSeconds(180);
            String scheduledDateTime = '';
            scheduledDateTime += now.second();
            scheduledDateTime += ' ' + now.minute();
            scheduledDateTime += ' ' + now.hour();
            scheduledDateTime += ' ' + now.day();
            scheduledDateTime += ' ' + now.month();
            scheduledDateTime += ' ' + '?';
            scheduledDateTime += ' ' + now.year();
            String scheduledTaskName = 'ScheduledSend scheduled on ' + DateTime.now() + System.currentTimeMillis();
            String scheduledJobId = System.schedule(scheduledTaskName, scheduledDateTime, new Z_CreateBillingAccount(orderId,sfdcAccountId, zBillingAccount));
            System.debug(FUNC_STR+'####### INFO: Zuora Send scheduled in 5 seconds');
        } 
    }
    
    @future(callout = true)
    public static void updateBillingAccount(String orderId, String zBillingAccountId) {
       final String FUNC_STR = DEBUG_STR+'updateBillingAccount: ';
        String Idd= '' ;
        String Bill ='';
        String Upda = '';
        String Billingid= '';
        Zuora.zApi zApi = new Zuora.zApi();
        if(!Test.isRunningTest()){
            zApi = zuoraApiAccess();
            zApi.zLogin();
        }
       
        
        Order o = [SELECT Id, AccountId FROM Order WHERE Id = :orderId];   
        
        Account acc = [SELECT Id,Name,Subscription_payment__c, Consolidated_Billing_Flag__c, Currency_Type__c, Type, Billing_Preference__c,
                       BillingStreet,BillingCity,BillingState, BillingCountry,BillingPostalCode, 
                       ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState, Party_Id__c
                       FROM Account WHERE Id = :o.AccountId];
        
        Zuora.ZObject updatedAccount = createAccountZObject(orderId, acc, true);
        updatedAccount.setValue('Id', zBillingAccountId);
        updatedAccount.setValue('Status', 'Active');
        System.Debug(FUNC_STR+'Updated Account: ' + updatedAccount);
        System.Debug(FUNC_STR+'zBillingAccountId: ' + zBillingAccountId);
        
        List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
        try {
            if(!Test.isRunningTest()) {
                updateAccResults = zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount});
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            } else { 
                updateAccResults = new List<Zuora.ZApi.SaveResult>();
                Zuora.ZApi.SaveResult updateAccResult = new Zuora.ZApi.SaveResult();
                updateAccResult.Success = true;
                updateAccResults.add(updateAccResult);
            }
        } catch (Exception ex) {
            System.debug(FUNC_STR+'Error occurred trying to create Account in Zuora: '+ex.getMessage());
            errorMessage = FUNC_STR+'Error occurred trying to create Account in Zuora: '+ex.getMessage();
            errorStatus = true;
        }
        System.debug(FUNC_STR+'Update Account in Zuora results: '+updateAccResults);  
    
    }    
    @future(callout = true)
    public static void updateOrdWithNoZChanges(String orderId, List<String> serOrderItemDoNotProcess, Boolean multiLineType){ 
        try{ 
            List<Order> lstorder = [Select Id, Zuora_Status__c, Zuora_Comment__c from Order where Id =: orderId];
            List<OrderItem> orderItemsDoNotProcess = new List<OrderItem>();
            
            for (String ser : serOrderItemDoNotProcess){
                OrderItem ordItem = (OrderItem) JSON.deserialize(ser, OrderItem.class);
                ordItem.Zuora_Status__c = 'Success';
                ordItem.Zuora_Comment__c = 'No Zuora Changes';
                orderItemsDoNotProcess.add(ordItem);
            }
            
            if(!orderItemsDoNotProcess.isEmpty())
                update orderItemsDoNotProcess;
            
            if(!lstorder.isEmpty() && multiLineType == false)
            {
                lstorder[0].Zuora_Status__c = 'Success';
                lstorder[0].Zuora_Comment__c = 'No Zuora Changes';
                
                update lstorder;
                system.debug('Order updated with No Zuora Changes');
            }
        }catch(Exception ex){
            System.debug('Exception while updating Order: ' + ex.getMessage());
        }
    }
    
    public static void convertOrderLines(String orderId, String sfdcAccountId, String zBillingAccountId){
        final String FUNC_STR = DEBUG_STR+'convertOrderLines: ';
        System.debug(FUNC_STR+'Starting convertOrderLines with orderId: '+orderId+', sfdcAccountId: '+sfdcAccountId+', zBillingAccountId: '+zBillingAccountId);
        errorStatus = false;
        errorMessage = '';
        
        //LEAP-8834
        
        //[4/21/16] Jeff Tan - LEAP-8363 Order Decomp Large Order Fix
        //Start processing order items, then Send To Z-Billing
        List<OrderItem> orderItems = [Select Id, Zuora_Status__c, Zuora_Payment_Method__c, CampaignID__c, Contractedimpressions__c, PricePerImpressionSold__c,
                                      DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c, quantity,Realsuite_Bill__c, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Product_Type__c, 
                                      Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, 
                                      Line_Type__c, Billing_Period__c,Promotion__c, Cancellation_Date__c,Cancellation_Effective_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, 
                                      Asset__r.Zoura_Id__c,Asset__r.Product2.RealSuite_Family__c,Trial__c, Pricebookentry.Product2.RealSuite_Family__c, Asset__r.Zuora_Billing_Account_Id__c, Run_Zoura_Process__c, Zuora_Comment__c from OrderItem where orderId = :orderId and Zuora_Status__c = ''];
        
        List<OrderItem> orderItemsDoNotProcess = new List<OrderItem>();
        List<OrderItem> orderItemsToProcess = new List<OrderItem>();
        Boolean multiLineType = false;
        System.debug(orderItems.size());
        //CRM-3109 
        for (Integer i =0; i< orderItems.size() ; i++){
            system.debug('OrderITem' +orderItems[i].Part_Number__c + 'RealSuite ' + orderItems[i].Asset__r.Product2.RealSuite_Family__c + ' Bill' + orderItems[i].Realsuite_Bill__c);
            if(orderItems[i].Run_Zoura_Process__c == false || (orderItems[i].Asset__r.Product2.RealSuite_Family__c && !orderItems[i].Realsuite_Bill__c) || orderItems[i].Trial__c){
                orderItemsDoNotProcess.add(orderItems[i]);
            }else{
                orderItemsToProcess.add(orderItems[i]);
                multiLineType = true;
            }        
        }  
        try{    
            if(!orderItemsDoNotProcess.isEmpty()){
                List<String> serOrderItemDoNotProcess = new List<String> ();
                for (Integer i =0; i< orderItemsDoNotProcess.size() ; i++){
                    serOrderItemDoNotProcess.add(JSON.serialize(orderItemsDoNotProcess[i]));
                }
                updateOrdWithNoZChanges(orderId, serOrderItemDoNotProcess, multiLineType);
            }
            
        }catch(Exception ex){
            System.debug('Error occured while bulk update on OrderProduct:' + ex.getMessage());
        }
        
        //Check for billing account ID
        if(zBillingAccountId == null || zBillingAccountId == ''){
            System.debug(FUNC_STR+'Billing Account Id is blank');
            for(OrderItem orderItem1 : orderItemsToProcess){
                errorStatus = true;
                errorMessage = 'No billing account found';
                updateOrderItem(orderItem1.Id);
            }
            return;
        }
        
        //Queue max 50 order items jobs at a time
        List<String> jobIDList = new List<String>();
        for(Integer a = 0; a < (orderItemsToProcess.size() > 50 ? 50 : orderItemsToProcess.size()); a++){
            System.debug(FUNC_STR+'Queueing Z_queueableProcessInput with orderId: '+orderId+', orderItem: '+orderItemsToProcess[a]+', sfdcAccountId: '+sfdcAccountId+', zBillingAccountId: '+zBillingAccountId);
            if ( orderItemsToProcess[a].Asset__r.Zuora_Billing_Account_Id__c !=null &&  orderItemsToProcess[a].Asset__r.Zuora_Billing_Account_Id__c != ''){               
                zBillingAccountId = orderItemsToProcess[a].Asset__r.Zuora_Billing_Account_Id__c;
            }
            jobIDList.add(String.valueOf(System.enqueueJob(new Z_queueableProcessInput(orderId, orderItemsToProcess[a], sfdcAccountId, zBillingAccountId))));
        }
        
        //Schedule any remaining Order Items and Send To Z-Billing
        List<OrderItem> remainingOrderItems = new List<OrderItem>();
        if (orderItemsToProcess.size() > 50){
            for(Integer b = 50; b < orderItemsToProcess.size(); b++){
                remainingOrderItems.add(orderItemsToProcess[b]);
            }
        }
        
        System.debug(FUNC_STR+'Remaining Order Items:' + remainingOrderItems.size());
        //if(remainingOrderItems.size() > 0)
        Z_scheduleProcessInputAndSendToZBilling.scheduleProcessInputAndSendToZBilling(300, jobIDList, orderId, remainingOrderItems, sfdcAccountId, zBillingAccountId);
    }
    
    //Update Order Object with the status of Zuora calls
    public static void updateOrderItemWithQuote(String quoteId, boolean errorBoolean, String message){
        final String FUNC_STR = DEBUG_STR+'updateOrderItemWithQuote: ';
        zqu__Quote__c[] quotes = [Select Id, Order_Product__c from zqu__Quote__c where Id = :quoteId];
        if (quotes.size() > 0){
            updateOrderItem(quotes[0].Order_Product__c, errorBoolean, message);
        }
    }
    
    //Update Order Object with the status of Zuora calls
    public static void updateOrderItem(String orderItemId){
        final String FUNC_STR = DEBUG_STR+'updateOrderItem(orderItemId): ';
        OrderItem orderItem = new orderItem();
        String orderr='';
        String Dependentt = '';
        String Itemnu ='';
        orderItem = [SELECT Id, quantity , Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c, Extended_Net_Price__c, 
                     Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, Cancellation_Date__c,
                     Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c from OrderItem where Id = :orderItemId
                     FOR UPDATE];
        
        if(errorStatus==true) {
            orderItem.Zuora_Status__c = 'Error';
        } else{
            orderItem.Zuora_Status__c = 'Success';
        }
        orderItem.Zuora_Comment__c = errorMessage;
        update orderItem;
    }
    
    //Sets Zuora Status and Comments on Order Item, conditionally performs the update, and returns the OI
    public static OrderItem updateOrderItem(String orderItemId, boolean errorBoolean, String message, Boolean doUpdate) {
        final String FUNC_STR = DEBUG_STR+'updateOrderItem(orderItemId,errorBoolean,message,doUpdate): ';
        OrderItem[] orderItems = [SELECT Id, Zuora_Status__c, Zuora_Comment__c FROM OrderItem WHERE Id = :orderItemId FOR UPDATE];
        if (orderItems.size() > 0) {
            OrderItem orderItem = orderItems[0];
            //TODO: revisit this to ensure accuracy. Do we always want to append zuora comment in case of status already "Error"?
            if (orderItem.Zuora_Status__c == 'Error') {
                if (String.isEmpty(orderItem.Zuora_Comment__c)) {
                    orderItem.Zuora_Comment__c = message;
                } else {
                    orderItem.Zuora_Comment__c += '. ' + message;
                }
            } else {
                if(errorBoolean) {
                    orderItem.Zuora_Status__c = 'Error';
                    system_logs__c logs = new system_logs__c();
                    logs.Record_ID__c = orderItem.Id;
                    logs.Object_Type__c = 'OrderItem';
                    logs.Message__c = message;
                    insert logs;
                } else{
                    orderItem.Zuora_Status__c = 'Success';
                }
                orderItem.Zuora_Comment__c = message;
            }
            //TODO: remove abbreviation after confirming with Ravi
            orderItem.Zuora_Comment__c = orderItem.Zuora_Comment__c.abbreviate(250);
            if (doUpdate) {
                update orderItem;
            }
            return orderItem;
        } else {
            return null;
        }
    }
    
    //Update Order Item Object with the status of Zuora calls
    public static void updateOrderItem(String orderItemId, boolean errorBoolean, String message) {
        final String FUNC_STR = DEBUG_STR+'updateOrderItem(orderItemId,errorBoolean,message): ';
        OrderItem oi = updateOrderItem(orderItemId,errorBoolean,message,true);
    }
    
    //Helper method for updating Order Item with an error message
    public static void updateOrderItemError(String orderItemId, String message) {
        OrderItem oi = updateOrderItem(orderItemId,true,message,true); 
    }
    
    //Helper method for updating Order Item with a success message
    public static void updateOrderItemSuccess(String orderItemId, String message) {
        OrderItem oi = updateOrderItem(orderItemId,false,message,true); 
    }
    
    //Update Order Object with status and messages
    public static void updateOrder(String orderId, boolean success, Set<String> messages){
        final String FUNC_STR = DEBUG_STR+'updateOrder(orderId,success,messages): ';
        String errorStringConcatonate = String.join(new List<String>(messages), '. ' );
        Order orderToUpdate = new Order();
        orderToUpdate.Id = orderId;
        //TODO: remove abbreviation after confirming with Ravi
        orderToUpdate.Zuora_Comment__c = errorStringConcatonate.abbreviate(250);
        if (success){
            orderToUpdate.Zuora_Status__c = 'Success';   
        }else{
            orderToUpdate.Zuora_Status__c = 'Error';
        }
        update orderToUpdate;
    }
    
    //Update Order Object with the status of Zuora calls
    public static void updateOrder(String orderId, String Message){
        final String FUNC_STR = DEBUG_STR+'updateOrder(orderId): ';
        Order order = [SELECT Zuora_Status__c,Zuora_Comment__c from Order where Id = :orderId FOR UPDATE];
        //Order order;
        order.Id =orderId;         
        order.Zuora_Status__c = 'Error';
        order.Zuora_Comment__c= Message.abbreviate(250);
        update order;
        // if(!Test.isRunningTest()){
        // throw (new CommonException(Message));
        //}
        
    }
    
    public static void UpdateOrderItemswithmultipleQuoteIdsfailure(List<String> quoteIds, string message){
        List<zqu__Quote__c> listofQuote =[select Order_Product__c  from zqu__Quote__c where ID IN:quoteIds];
        Set<Id> orderItemsIds = new Set<id>();
        List<OrderItem> OrderItems = new List<OrderItem>();
        List<OrderItem> updateOIList = new List<OrderItem>();
        for(zqu__Quote__c quote: listofQuote){
            system.debug('testquote'+quote+'value'+quote.Order_product__c);
            if(quote.Order_Product__c!=null)
                orderItemsIds.add(quote.Order_Product__c);
        }
        errorMessage = 'An error occured when sending to Z-Billing '+message;
        OrderItems = [select id,Zuora_Status__c,Zuora_Comment__c from OrderItem where ID IN:orderItemsIds];
        if(OrderItems.size()>0){
            
            for(OrderItem OI: OrderItems){
                OI.Zuora_Status__c = 'Error';
                OI.Zuora_Comment__c = errorMessage;
                updateOIList.add(OI);
            }
            if(!updateOIList.IsEmpty()){
                update updateOIList;
            }
        }
    }
    
    public static zqu__Quote__c createZuoraQuote(OrderItem OI, String sfdcAccountId, String zBillingAccountId, String type, Decimal initialTerm, Decimal renewalTerm, String assetId, Date cancelDate){
        
        Date defaultStartDate;
        
        if(OI.Line_Type__c == 'Add')
        { 
            defaultStartDate = OI.Start_Date__c;
            // defaultStartDate = Date.valueOf('2017-02-03');
            System.debug('defaultStartDate@@' +defaultStartDate );
            
            
            // defaultStartDate = Date.valueOf('2017-02-03');
        }
        else
            defaultStartDate = System.today();
        
        return createZuoraQuote(OI,sfdcAccountId,zBillingAccountId,type,initialTerm,renewalTerm,assetId,cancelDate,defaultStartDate);
    }
    
    public static zqu__Quote__c createZuoraQuote(OrderItem OI, String sfdcAccountId, String zBillingAccountId, String type, Decimal initialTerm, Decimal renewalTerm, String assetId, Date cancelDate, Date startDate){
        final String FUNC_STR = DEBUG_STR+'createZuoraQuote: ';
        System.debug(FUNC_STR+'In create Quote method');
        System.debug(FUNC_STR+'type='+type+',cancelDate='+cancelDate);
        zqu__Quote__c newQuote = new zqu__Quote__c();
        string Zuora_subscriptionId='';
        string zuora_subscriptionName='';
        List<Zuora.zObject> zuora_Subs = new List<Zuora.zObject>();
        Account myAccount = [SELECT Id,Name,Currency_Type__c,Subscription_payment__c, Type, Bill_To_Parent__c,Billing_Preference__c,BillingStreet,BillingCity,BillingState, BillingCountry,
                             BillingPostalCode, ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState, Consolidated_Billing_Flag__c, Party_Id__c 
                             FROM Account WHERE Id = :sfdcAccountId LIMIT 1];
        
        newQuote.zqu__Account__c = myAccount.Id;
        newQuote.zqu__ZuoraAccountID__c = zBillingAccountId;
        newQuote.zqu__SubscriptionType__c = type;
        //CRM-3305 start commenting for proddeployment  add Bill_To_Parent__c in Query.
        Set<String>childAccTypes = new Set<String>{'Moving Company', 'Lender Branch', 'Loan Officer'};
        if(childAccTypes.contains(myAccount.Type) && myAccount.Bill_To_Parent__c == 'Yes'){
             List<Account_Relationship__c>  relationact = [Select Id, Parent_Account__c,Parent_Account__r.Bill_To_Parent__c,Parent_Account__r.Type, Child_Account__c From Account_Relationship__c where Child_Account__c = :myAccount.id and Parent_Account__c !=null and Active__c  = true and Relationship_Type__c  = 'Parent/Child' LIMIT 1];
            if(relationact!=null && relationact.size()>0 && !childAccTypes.contains(relationact[0].Parent_Account__r.Type)){            
               Zuora__CustomerAccount__c zact =   [select id, Zuora__Zuora_Id__c  From Zuora__CustomerAccount__c where Zuora__Account__c = :relationact[0].Parent_Account__c];
                   newQuote.zqu__InvoiceOwnerId__c = zact.Zuora__Zuora_Id__c;
            }                
         }
     
	        //CRM-2864 uncheck the invoice seperate for rebert slack even though not consoliated
        List<String> uncheckinvseperatelst = (System.label.UncheckInvSeperate+'').split(',');
        Set<String> uncheckinvseperate = new Set<String>();
        for(String str :uncheckinvseperatelst){
            uncheckinvseperate.add(str);
        }
            //zqu__AutoRenew__c 
                
        //TODO: LEAP-8388: Moved this section from below so tiger lead always set invoice separately to false
        // CRM-4123 Zuora must make all bundled RS products as ever green (always Auto Renew)
         Set<String> RSbundle = new Set<String>();
        if(System.Label.RS_bundle_promo_2050!=null){
        RSbundle.addAll(System.Label.RS_bundle_promo_2050.split(';'));
        }
       
        //Set<String> bundle = new set<String>{'FREEBUNDLERSTRANSACT','FREEBUNDLERSCONNECT','FREEBUNDLERSRESPOND', 'FREEBUNDLETRANSACT', 'FREEBUNDLERESPOND' , 'FREEBUNDLECONNECT'};
         if(OI.Promotion__c!=null && RSbundle.contains(OI.Promotion__c)){
                newQuote.zqu__AutoRenew__c = true;                
          }
        if(myAccount.Consolidated_Billing_Flag__c == false && !uncheckinvseperate.contains(myAccount.Id)) {       
            newQuote.zqu__InvoiceSeparately__c = true;      
        } else {        
            newQuote.zqu__InvoiceSeparately__c = false;     
        }
        //CRM-3305 start commenting for proddeployment
        Set<String> accTypes = new Set<String>{'Moving Company', 'Moving Corporation', 'Lender Parent','Lender Branch', 'Loan Officer'};
       if(accTypes.contains(myAccount.Type)){
            newQuote.zqu__Subscription_Term_Type__c ='EVERGREEN';
             newQuote.zqu__InvoiceSeparately__c = false; 
        }
         
       
        //End.
        if(Type != 'Renew Subscription') {
            //newQuote.zqu__StartDate__c = Date.today();
            newQuote.zqu__StartDate__c = startDate;
            //newQuote.zqu__Service_Activation_Date__c = Date.today();
            newQuote.zqu__Service_Activation_Date__c = startDate;
        } else{
            List<Zuora__Subscription__c> subs = [SELECT Id, Zuora__Zuora_Id__c,Zuora__TermStartDate__c, AssetID__c,Zuora__SubscriptionStartDate__c,Zuora__SubscriptionEndDate__c,
                                                 Zuora__InitialTerm__c,Zuora__AutoRenew__c, Zuora__TermSettingType__c,Assetcounter__c
                                                 FROM Zuora__Subscription__c WHERE AssetID__c = :assetId ORDER BY CreatedDate DESC];
            
            
            if(subs.size() == 0) {
                //newQuote.zqu__StartDate__c = Date.today();
                newQuote.zqu__StartDate__c = startDate;
                //newQuote.zqu__Service_Activation_Date__c = Date.today();
                //newQuote.zqu__Service_Activation_Date__c = startDate;
                newQuote.zqu__Service_Activation_Date__c = System.today(); 
                
            } else {
                //CRM-4409Prevent the double renewals on subscription.
                if(subs[0].Zuora__TermStartDate__c != null && subs[0].Zuora__TermStartDate__c >= system.today().adddays(-5) && !Test.isRunningtest()){
                   updateOrderItem(OI.Id,TRUE,'Subscription Renewed');    
                    return null;
                }
                newQuote.zqu__StartDate__c = subs[0].Zuora__SubscriptionEndDate__c;
                newQuote.zqu__Service_Activation_Date__c = subs[0].Zuora__SubscriptionEndDate__c;
                String assetCounterStr = subs[0].Assetcounter__c;
                if(String.isBlank(assetCounterStr)){
                    newQuote.Assetcounter__c = '1';
                } else{
                    try{
                        Integer assetCounter = Integer.valueOf(assetCounterStr);
                        assetCounter++;
                        newQuote.Assetcounter__c = String.valueOf(assetCounter);
                    }catch (Exception ex) {
                        updateOrderItem(OI.Id,TRUE,'An error occured when converting asset counter on subscription to Integer: '+ex.getMessage());
                    }
                    
                }
            }
        }
        
        newQuote.zqu__Currency__c = 'USD';
        newQuote.syncCounter__c = 0;
        newQuote.Order_Product__c = OI.Id;
        
        
        //The setting below is added for Turbo Product by David Li
        if(OI.Line_Type__c == 'Add' || Type == 'Renew Subscription'){
            //commented out the line for Campaign, since it is now a formula field
            //newQuote.CampaignID__c = OI.CampaignID__c;
            newQuote.ContractedImpressions__c = (OI.ContractedImpressions__c == null) ? null : OI.ContractedImpressions__c.toPlainString();
            newQuote.PricePerImpressionSold__c = (OI.PricePerImpressionSold__c == null) ? null : OI.PricePerImpressionSold__c.toPlainString();
            
            Integer initialTermForCalculation = Integer.valueOf(OI.Contract_Term__c);
            Date startDateForCalculation = OI.Start_Date__c;
            Date endDateForCalculation = startDateForCalculation.addMonths(initialTermForCalculation);
            Decimal daysBetweenForCalculation = startDateForCalculation.daysBetween(endDateForCalculation);
            Decimal impressionPerDay = (OI.Contractedimpressions__c == null) ? 0 : ((OI.Contractedimpressions__c) / (daysBetweenForCalculation)).setScale(2); 
            
            newQuote.Impressions_Per_Day__c = impressionPerDay.toPlainString();
        }
        
        
        //Removed 1-06-2016 as its not necessary and creates additional unwanted T&C amendments
        //if(newQuote.zqu__SubscriptionType__c == 'New Subscription' || newQuote.zqu__SubscriptionType__c =='Renew Subscription')
        newQuote.zqu__InitialTerm__c = initialTerm;
        newQuote.zqu__RenewalTerm__c = renewalTerm;
        
        if(OI.Line_Type__c == 'Coterm'){
            newQuote.zqu__StartDate__c = OI.Start_Date__c;
            newQuote.zqu__SubscriptionTermStartDate__c = OI.Start_Date__c;
        }
        
        if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0){
            newQuote.cancelWithCreditFlag__c = true;
        }
        
        //Turbo modification: 
        //by David Li, Zuora Inc
        
        //cancel with no credit => line type == 'Cancel'
        //cancel with credit => line type == 'Cancel With Credit'
        //expiration with credit => line type == 'Credit' ; MAKE SURE to populate Credit Amount on Order Product 
        if(OI.Line_Type__c == 'Cancel'  || OI.Line_Type__c == 'Cancel With Credit' || OI.Line_Type__c == 'Credit'){
            //setting Turbo fields
            newQuote.DeliveredImpressions__c = (OI.DeliveredImpressions__c != null) ? OI.DeliveredImpressions__c.toPlainString() : null;
            newQuote.DeliveredImpressionsUpdatedDate__c = (OI.DeliveredImpressionsUpdatedDate__c != null) ? String.valueOfGmt(OI.DeliveredImpressionsUpdatedDate__c) : null;
            //newQuote.Test_DeliveredImpressions__c = OI.Test_DeliveredImpressions__c;
        }else if(Type == 'Renew Subscription'){
            newQuote.DeliveredImpressions__c = '0';
            newQuote.DeliveredImpressionsUpdatedDate__c = String.valueOfGmt(System.now());
        }    
        
        if(newQuote.zqu__SubscriptionType__c != 'New Subscription') {
            if(String.isBlank(assetId)){
                System.debug(FUNC_STR+'Asset ID is required');
                errorMessage='Asset ID is required';
                errorStatus=true;
                updateOrderItem(OI.Id);
                return null;
            }
            
            List<Zuora__Subscription__c> subs = [SELECT Id, Name, PaymentMethodId__c ,Zuora__Zuora_Id__c, Zuora__TermStartDate__c,
                                                 AssetID__c,Zuora__SubscriptionStartDate__c,Zuora__SubscriptionEndDate__c, 
                                                 Zuora__InitialTerm__c, Zuora__AutoRenew__c, Zuora__RenewalTerm__c, Zuora__TermSettingType__c 
                                                 FROM Zuora__Subscription__c 
                                                 WHERE AssetID__c = :assetId 
                                                 ORDER BY CreatedDate DESC];
            
            System.Debug(FUNC_STR+'Subs: ' + subs);
            if(subs.size()>0 && subs[0].Zuora__AutoRenew__c== true){
                newQuote.zqu__AutoRenew__c = true;
                
            }
            // CRM-4351 Accept the payment method at the subscription level.
        if(myAccount.Subscription_payment__c && OI.Zuora_Payment_Method__c  != null){            
            newQuote.PaymentMethodId__c  = OI.Zuora_Payment_Method__c;
            newQuote.AutoPay__c = 'On';
             if(subs[0].PaymentMethodId__c != null && subs[0].PaymentMethodId__c != OI.Zuora_Payment_Method__c){
             Integer Result =  [SELECT count() From  Zuora__PaymentInvoice__c where Zuora__Invoice__r.Zuora__Account__c  =:sfdcAccountId and Zuora__Invoice__r.Zuora__Balance2__c > 1 and Status__c = 'Processed' and Zuora__Payment__r.ZPaymentMethodId__c = :subs[0].PaymentMethodId__c];
                    if(Result > 1){
                        system.debug(FUNC_STR +' Updating Invoices to stop retry '+ Result);
                        Z_UpdateInvoiceToStopRetry.UpdateInoivceFlag(myAccount.Id, subs[0].PaymentMethodId__c); 
                    }
             }
        }
            if(!Test.IsRunningTest()){
                if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0){               
                    Zuora.zApi api = zuoraApiAccess();
                    system.debug('Zuora Quote2 Values Updated');
                    String query = 'SELECT Id, Name FROM Subscription WHERE Status = \'Active\' AND AssetID__c = \''+assetId+'\'';
                    zuora_Subs = api.zQuery(query);
                }
            }
            
            if(zuora_Subs.size()>0){
                Zuora_subscriptionId = string.valueof(zuora_Subs[0].getValue('Id'));
                zuora_subscriptionName = string.valueof(zuora_Subs[0].getValue('Name'));
            }
            if(subs.size()==0 && zuora_Subs.size()==0){
                System.debug(FUNC_STR+'No existing subscription associated with the Order Asset: '+assetId);
                errorMessage='No existing subscription associated with the Order Asset: '+assetId;
                errorStatus=true;
                updateOrderItem(OI.Id);
                return null;
            }
            system.debug('Zuora_subscriptionId'+Zuora_subscriptionId+'zuora_subscriptionName'+zuora_subscriptionName);            
            if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0 && Zuora_subscriptionId!='' && zuora_subscriptionName!=''){
                system.debug('Zuora Quote Values Updated');
                newQuote.zqu__ExistSubscriptionID__c = Zuora_subscriptionId;
                newQuote.zqu__Hidden_Subscription_Name__c = zuora_subscriptionName;
            }else{
                newQuote.zqu__ExistSubscriptionID__c = subs[0].Zuora__Zuora_Id__c;
                newQuote.zqu__Hidden_Subscription_Name__c = subs[0].Name;
            }
            if(newQuote.zqu__SubscriptionType__c == 'Amend Subscription'){
                //CRM-3089 Reasuite changes.
                Date newStartDate;
                if(OI.Line_Type__c == 'Add'){
                    newStartDate =  OI.Start_Date__c;                  
                }else if(OI.Term_Start_Date__c == null){                   
                    System.debug(FUNC_STR+'Term Start Date is required');
                    errorMessage='Term Start Date is required';
                    errorStatus=true;
                    updateOrderItem(OI.Id);
                    return null;
                } else{
                 newStartDate = OI.Term_Start_Date__c;
                }
                if(!Test.IsRunningTest()){
                    newQuote.zqu__SubscriptionTermStartDate__c = subs[0].Zuora__SubscriptionStartDate__c + subs[0].Zuora__SubscriptionStartDate__c.daysBetween(newStartDate);
                    //if(subs[0].Zuora__SubscriptionEndDate__c < Date.Today()){
                    if(subs[0].Zuora__SubscriptionEndDate__c < startDate){
                        newQuote.zqu__StartDate__c = subs[0].Zuora__SubscriptionEndDate__c;
                        newQuote.zqu__Service_Activation_Date__c = subs[0].Zuora__SubscriptionEndDate__c;
                    }
                } else {
                    newQuote.zqu__SubscriptionTermStartDate__c = OI.Term_Start_Date__c;
                }
                
                if(subs[0].Zuora__TermSettingType__c != 'EVERGREEN'){
                    if(initialTerm!=Decimal.valueOf(subs[0].Zuora__InitialTerm__c.replaceAll('[^0-9]+', '')))
                        newQuote.zqu__InitialTerm__c = initialTerm;
                    if(renewalTerm!=Decimal.valueOf(subs[0].Zuora__RenewalTerm__c.replaceAll('[^0-9]+', '')))
                        newQuote.zqu__RenewalTerm__c = renewalTerm;
                }
            }
        }else {
            newQuote.Assetcounter__c = '0';
             if(myAccount.Subscription_payment__c && OI.Zuora_Payment_Method__c != null){            
           	 newQuote.PaymentMethodId__c  = OI.Zuora_Payment_Method__c ;
             newQuote.AutoPay__c = 'On';
             }
        }
        
        if(newQuote.zqu__SubscriptionType__c == 'Cancel Subscription') {
            newQuote.zqu__CancellationDate__c = cancelDate;
            newQuote.zqu__CancellationEffectiveDate__c = 'Enter a Date';        
        }
        if(newQuote.zqu__SubscriptionType__c == 'Renew Subscription') {
            newQuote.zqu__Amendment_Name__c = 'Renewal Amendment';
        }
        System.debug(FUNC_STR+'Inserting Quote');
        insert newQuote;
        return newQuote;
    }
    
    public static Date getCancelDate(String bcd){
        final String FUNC_STR = DEBUG_STR+'getCancelDate: ';
        String getcan ='';
        String getallt='';
        String getallmt='';
        //Jeffrey Tan - 1/31/2016 Fix to handle EOM string and fix cancellation date logic
        if (bcd.containsIgnoreCase('EOM')){
            bcd = '31';
        }
        String newbcd = bcd.replaceAll('[^0-9]+', '');
        Integer bcdInt = Integer.valueOf(newbcd);
        
        Date todayDate = Date.today();
        Integer numberOfDaysCurrentMonth = Date.daysInMonth(todayDate.year(), todayDate.month());
        Date newDate = Date.newInstance(todayDate.year(), todayDate.month(), bcdInt > numberOfDaysCurrentMonth ? numberOfDaysCurrentMonth : bcdInt);
        
        if(newDate < todayDate){
            numberOfDaysCurrentMonth = Date.daysInMonth(todayDate.year(), todayDate.month()+1);
            newDate = Date.newInstance(todayDate.year(), todayDate.month()+1, bcdInt > numberOfDaysCurrentMonth ? numberOfDaysCurrentMonth : bcdInt);
        }
        
        System.debug(FUNC_STR+'Cancellation Date is: '+newDate+' for BCD: '+bcd);
        return newDate;
    }
    
    public static Boolean prepareTermsAndConditionChanges(String assetId, zqu__Quote__c currentQuote, String price, String orderItemId, List<zqu.zChargeGroup> chargeGroups){
        final String FUNC_STR = DEBUG_STR+'prepareTermsAndConditionChanges: ';
        System.Debug(FUNC_STR+'In prepareTermsAndConditionChanges');
        List<Zuora__Subscription__c> subs = [Select Id, Zuora__Zuora_Id__c,Zuora__CurrentTerm__c, Zuora__TermSettingType__c, Zuora__TermStartDate__c, Zuora__InitialTerm__c, 
                                             Zuora__RenewalTerm__c, Zuora__AutoRenew__c, AssetID__c from Zuora__Subscription__c 
                                             where AssetID__c = :assetId order by CreatedDate DESC];
        
        if(subs.size()==0){
            System.debug(FUNC_STR+'No existing subscription associated with the Order Asset: '+assetId);
            errorMessage='No existing subscription associated with the Order Asset: '+assetId;
            errorStatus=true;
            updateOrderItem(orderItemId);
            return errorStatus;
        }
        
        zqu__Quote__c quote = [Select Id, zqu__ExistSubscriptionID__c, zqu__Subscription_Term_Type__c, zqu__InitialTerm__c, 
                               zqu__SubscriptionTermStartDate__c, zqu__SubscriptionType__c, zqu__AutoRenew__c, zqu__RenewalTerm__c, Charge_To_Be_Updated__c, Order_Product__r.Subscription_Term__c, 
                               Order_Product__r.Extended_Net_Price__c from zqu__Quote__c where Id = :currentQuote.Id];
        
        Map<String,Object> termsAndConditionChanges = getTermAndConditionChanges(subs[0], quote, price, chargeGroups);
        
        //Added 1-06-2016 Code to check if terms and condition amendment is needed
        System.Debug(FUNC_STR+'Testing whether T&C amendment is needed');
        System.Debug(FUNC_STR+'Autorenew Existing/Updating: ' + subs[0].Zuora__AutoRenew__c + subs[0].Zuora__AutoRenew__c);
        //System.Debug(FUNC_STR+'Renewal Term Existing/Updating:' + subs[0].Zuora__RenewalTerm__c + Integer.valueOf(quote.zqu__RenewalTerm__c));
        System.Debug(FUNC_STR+'TermSettingType Existing/Updating: ' + (String)subs[0].Zuora__TermSettingType__c + quote.zqu__Subscription_Term_Type__c);
        System.Debug(FUNC_STR+'Zuora__TermStartDate__c Existing/Updating' + (Datetime)subs[0].Zuora__TermStartDate__c + quote.zqu__SubscriptionTermStartDate__c);
        System.Debug(FUNC_STR+'Term type on order product ' + quote.Order_Product__r.Subscription_Term__c);
        //System.Debug(FUNC_STR+'Initial Term :' + subs[0].Zuora__InitialTerm__c + quote.zqu__InitialTerm__c);
        // CRM-3824 Contract Term is not changing on the Subscription after it renewed. aad condtion Current Condition.
        if(subs[0].Zuora__TermSettingType__c != 'EVERGREEN' && ((Boolean)subs[0].Zuora__AutoRenew__c != quote.zqu__AutoRenew__c || (Integer.valueOf(subs[0].Zuora__RenewalTerm__c.split(' ', 2)[0]) != quote.zqu__RenewalTerm__c && quote.zqu__RenewalTerm__c != 0 )) && quote.zqu__SubscriptionType__c == 'Renew Amendment'){
            //Pass the changes to subscriptionTermsMap to be used when the quote record is upserted
            System.Debug(FUNC_STR+'T&C amendment is needed');
            setSubscriptionTermChanges(quote.Id, termsAndConditionChanges);
        } else if (subs[0].Zuora__TermSettingType__c != 'EVERGREEN' && ((Boolean)subs[0].Zuora__AutoRenew__c != quote.zqu__AutoRenew__c || (Integer.valueOf(subs[0].Zuora__RenewalTerm__c.split(' ', 2)[0]) != quote.zqu__RenewalTerm__c && quote.zqu__RenewalTerm__c != 0 ) || (String)subs[0].Zuora__TermSettingType__c != quote.zqu__Subscription_Term_Type__c || (Datetime)subs[0].Zuora__TermStartDate__c != quote.zqu__SubscriptionTermStartDate__c || (((Integer.valueOf(subs[0].Zuora__InitialTerm__c.split(' ', 2)[0]) != quote.zqu__InitialTerm__c) || (Integer.valueOf(subs[0].Zuora__CurrentTerm__c.split(' ', 2)[0]) != quote.zqu__InitialTerm__c)) && quote.zqu__InitialTerm__c != 0)) && quote.zqu__SubscriptionType__c != 'Renew Amendment') {
            //Pass the changes to subscriptionTermsMap to be used when the quote record is upserted
            System.Debug(FUNC_STR+'T&C amendment is needed');
            setSubscriptionTermChanges(quote.Id, termsAndConditionChanges);
        } else if (subs[0].Zuora__TermSettingType__c == 'EVERGREEN' && (Datetime)subs[0].Zuora__TermStartDate__c != quote.zqu__SubscriptionTermStartDate__c) {
            //Pass the changes to subscriptionTermsMap to be used when the quote record is upserted
            System.Debug(FUNC_STR+'T&C amendment is needed');
            setSubscriptionTermChanges(quote.Id, termsAndConditionChanges);
        }//else if (quote.zqu__Subscription_Term_Type__c.equalsIgnoreCase('Evergreen')){
        // System.Debug(FUNC_STR+'T&C amendment is needed for EVERGREEN');
        
        //setSubscriptionTermChanges(quote.Id, termsAndConditionChanges);
        
        //}
        
        return false;
    }
    
    //LEAP-8521
    @TestVisible
    private static void setSubscriptionTermChanges(String quoteId, Map<String,Object> termsAndConditionChanges){
        final String FUNC_STR = DEBUG_STR+'setSubscriptionTermChanges: ';
        String subend='';
        String Substat ='';
        String Subordet='';
        System.debug('Terms and conditions size: ' +termsAndConditionChanges.size());
        System.debug('Terms and conditions Term type: ' +termsAndConditionChanges.get('zqu__TermType__c'));
        if (termsAndConditionChanges.isEmpty()){
            return;
        }
        
        zqu__QuoteAmendment__c termsAndConditionsAmendment = new zqu__QuoteAmendment__c();
        String description = '';
        if (termsAndConditionChanges.get('zqu__TermStartDate__c') != null){
            description += 'Changed Term Start Date to ' + termsAndConditionChanges.get('zqu__TermStartDate__c') + '. ';
            termsAndConditionsAmendment.zqu__TermStartDate__c = (Date)termsAndConditionChanges.get('zqu__TermStartDate__c');
        }
        if (termsAndConditionChanges.get('zqu__TermType__c') != null){
            description += 'Changed Term Type to ' + termsAndConditionChanges.get('zqu__TermType__c') + '. ';
            termsAndConditionsAmendment.zqu__TermType__c  = (String)termsAndConditionChanges.get('zqu__TermType__c');  
        }
        if (termsAndConditionChanges.get('zqu__AutoRenew__c') != null){
            description += 'Changed Auto Renew to ' + termsAndConditionChanges.get('zqu__AutoRenew__c') + '. ';
            termsAndConditionsAmendment.zqu__AutoRenew__c  = (String)termsAndConditionChanges.get('zqu__AutoRenew__c');   
        }
        if (termsAndConditionChanges.get('zqu__InitialTerm__c') != null){
            description += 'Changed Initial Term to ' + termsAndConditionChanges.get('zqu__InitialTerm__c') + '. ';
            termsAndConditionsAmendment.zqu__InitialTerm__c  = (Decimal)termsAndConditionChanges.get('zqu__InitialTerm__c');   
        }
        if (termsAndConditionChanges.get('zqu__RenewalSetting__c') != null){
            description += 'Changed Renewal Setting to ' + termsAndConditionChanges.get('zqu__RenewalSetting__c') + '. ';
            termsAndConditionsAmendment.zqu__RenewalSetting__c  = (String)termsAndConditionChanges.get('zqu__RenewalSetting__c');   
        }
        if (termsAndConditionChanges.get('zqu__RenewalTerm__c') != null){
            description += 'Changed Renewal Term to ' + termsAndConditionChanges.get('zqu__RenewalTerm__c') + '. ';
            termsAndConditionsAmendment.zqu__RenewalTerm__c  = (Decimal)termsAndConditionChanges.get('zqu__RenewalTerm__c');   
        }    
        termsAndConditionsAmendment.zqu__Status__c = 'Draft';
        termsAndConditionsAmendment.zqu__Type__c = 'TermsAndConditions';
        termsAndConditionsAmendment.zqu__Quote__c = quoteId;
        termsAndConditionsAmendment.zqu__Description__c = description;
        insert termsAndConditionsAmendment;
    }
    
    public static Map < String, Object > getTermAndConditionChanges(Zuora__Subscription__c originalSub, zqu__Quote__c currentQuote, String price, List<zqu.zChargeGroup> chargeGroups) {
        final String FUNC_STR = DEBUG_STR+'getTermAndConditionChanges: ';
        System.Debug(FUNC_STR+'In getTermAndConditionChanges');
        zqu__Quote__c quote = [SELECT Id, zqu__ExistSubscriptionID__c, zqu__Subscription_Term_Type__c, zqu__InitialTerm__c,
                               zqu__SubscriptionTermStartDate__c, zqu__SubscriptionType__c, zqu__AutoRenew__c, zqu__RenewalTerm__c, Charge_To_Be_Updated__c, Order_Product__r.Subscription_Term__c,
                               Order_Product__r.Extended_Net_Price__c 
                               FROM zqu__Quote__c WHERE Id = :currentQuote.Id];
        // Initialize changes to empty map
        Map<String,Object> changes = new Map<String,Object>();
        // First, add the differences for AutoRenew and RenewalTerm (they are valid for both amendments and renewals)
        if(quote.zqu__Subscription_Term_Type__c != 'EVERGREEN' && originalSub.Zuora__TermSettingType__c != 'EVERGREEN'){
            //// CRM-4123 Zuora must make all bundled RS products as ever green (always Auto Renew)
             if ((Boolean)originalSub.Zuora__AutoRenew__c != quote.zqu__AutoRenew__c) 
            changes.put('zqu__AutoRenew__c', String.valueOf(quote.zqu__AutoRenew__c));
            if (Integer.valueOf(originalSub.Zuora__RenewalTerm__c.split(' ', 2)[0]) != quote.zqu__RenewalTerm__c && quote.zqu__RenewalTerm__c != 0) 
                changes.put('zqu__RenewalTerm__c', quote.zqu__RenewalTerm__c);
        }
        //List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        
        Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
        //Test
        //if(!Test.isRunningTest()){     
        List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Id, Zuora__BillingPeriodStartDay__c, Zuora__Price__c,Zuora__Quantity__c 
                                                             FROM Zuora__SubscriptionProductCharge__c
                                                             WHERE Zuora__Subscription__c = :originalSub.Id AND (Zuora__Type__c = 'Recurring' OR Zuora__Type__c = 'Usage')];
        spc = (spcList.isEmpty()) ? null : spcList[0];
        if(spc != null && String.valueOf(spc.Zuora__Price__c) != price && !Test.isRunningTest()) {
            quote.Charge_To_Be_Updated__c = TRUE;
        }
        //} //else{
        //chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id)no;
        //quote.Charge_To_Be_Updated__c = TRUE;
        //}
        
        System.Debug(FUNC_STR+'chargeGroups.size: ' + chargeGroups.size());
        Boolean oneTime = false;
        if(chargeGroups.size() != 0 && (spc != null && String.valueOf(spc.Zuora__Price__c) != price && !Test.isRunningTest())){
            
            List<zqu.zChargeGroup> listOfUpdateChargeGroups = new List<zqu.zChargeGroup>();
            
            
            for(zqu.zChargeGroup chrgGrp : chargeGroups){
                for(zqu.zCharge zc: chrgGrp.zCharges){
                    System.Debug(FUNC_STR+'Before Price: ' + zc.EFFECTIVE_PRICE);
                    System.Debug(FUNC_STR+'Charge Type: ' + zc.CHARGE_TYPE);
                    if(zc.CHARGE_TYPE != 'One-Time'){
                        if(Test.isRunningTest()){
                            zc.EFFECTIVE_PRICE = '123.0';
                        } else {
                            zc.EFFECTIVE_PRICE = price;
                        }
                    }
                    
                    System.Debug(FUNC_STR+'After Price: ' + zc.EFFECTIVE_PRICE);
                    
                    zqu.zQuoteUtil.calculateChargesOnQuantityChange(chrgGrp.zCharges);
                    zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chrgGrp.zCharges);
                    
                    if(zc.CHARGE_TYPE != 'One-Time')
                        listOfUpdateChargeGroups.add(chrgGrp);
                }
            }
            
            if(listOfUpdateChargeGroups.size() != 0){
                zqu.zQuoteUtil.updateChargeGroups(listOfUpdateChargeGroups);
            }
        }
        System.Debug('Term Type one quote : ' + quote.zqu__Subscription_Term_Type__c);
        //if(quote.zqu__Subscription_Term_Type__c.equalsIgnoreCase('Evergreen')){
        
        // changes.put('zqu__TermType__c', quote.zqu__Subscription_Term_Type__c);
        // System.Debug('Changes1');
        //System.Debug(FUNC_STR+'After Price: ' + zc.EFFECTIVE_PRICE);
        //}
        // If the update version of the quote has a type of Renewal, do not generate differences for the remaining fields (they are not valid for renewal quotes)
        if (quote.zqu__SubscriptionType__c == 'Renew Subscription') 
            return changes;
        // Compare every terms/conditions field of the quote to the original subscription information, adding any discrepancies found
        //if ((String)originalSub.Zuora__TermSettingType__c != quote.zqu__Subscription_Term_Type__c) changes.put('zqu__Subscription_Term_Type__c', quote.zqu__Subscription_Term_Type__c);
        if ((Datetime)originalSub.Zuora__TermStartDate__c != quote.zqu__SubscriptionTermStartDate__c) 
            changes.put('zqu__TermStartDate__c', quote.zqu__SubscriptionTermStartDate__c);
        // Contract Term is not changing on the Subscription after it renewed. aad condtion Current Condition.
        if(quote.zqu__Subscription_Term_Type__c != 'EVERGREEN' && originalSub.Zuora__TermSettingType__c != 'EVERGREEN'){
            if (((Integer.valueOf(originalSub.Zuora__InitialTerm__c.split(' ', 2)[0]) != quote.zqu__InitialTerm__c) || (originalSub.Zuora__CurrentTerm__c != null && Integer.valueOf(originalSub.Zuora__CurrentTerm__c.split(' ', 2)[0]) != quote.zqu__InitialTerm__c))&& quote.zqu__InitialTerm__c != 0 )
                changes.put('zqu__InitialTerm__c', quote.zqu__InitialTerm__c);
        }
        
        return changes;
    }
    
    //@future(callout = true)
    public static void updateCharge(String quoteId) {
        final String FUNC_STR = DEBUG_STR+'updateCharge: ';
        System.debug(FUNC_STR+'In updateCharge method for quoteId: '+quoteId);
        String Chargess = '';
        String Charoldamnt='';
        String Changenewamt ='';
        try{
            zqu__Quote__c quote = [SELECT Id, zqu__ExistSubscriptionID__c, Order_Product__r.Extended_Net_Price__c 
                                   FROM zqu__Quote__c 
                                   WHERE Id = :quoteId];
            System.Debug(FUNC_STR+'quoteId' + quote.Id);
            System.Debug(FUNC_STR+'quote.zqu__ExistSubscriptionID__c: ' + quote.zqu__ExistSubscriptionID__c);
            Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
            List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
            //Test
            //if(!Test.isRunningTest()){
            
            List<Zuora__SubscriptionProductCharge__c> spcList  = [SELECT Id, Zuora__Price__c 
                                                                  FROM Zuora__SubscriptionProductCharge__c 
                                                                  WHERE Zuora__Subscription__r.Zuora__Zuora_Id__c = :quote.zqu__ExistSubscriptionID__c AND (Zuora__Type__c = 'Recurring' OR Zuora__Type__c = 'Usage')];
            spc = (spcList.isEmpty()) ? null : spcList[0];
            if(spc != null && String.valueOf(spc.Zuora__Price__c) != String.valueOf(quote.Order_Product__r.Extended_Net_Price__c)) {
                chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
            }
            //} else {
            // chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
            // }
            
            System.Debug(FUNC_STR+'chargeGroups.size: ' + chargeGroups.size());
            if(chargeGroups.size() != 0) {                              
                for(zqu.zChargeGroup cg : chargeGroups) {
                    for(zqu.zCharge zc : cg.zCharges) {
                        if(zc.CHARGE_TYPE != 'One-Time'){
                            System.Debug(FUNC_STR+'Before Price: ' + zc.EFFECTIVE_PRICE);
                            if(!Test.isRunningTest()){
                                zc.EFFECTIVE_PRICE = String.valueOf(quote.Order_Product__r.Extended_Net_Price__c);
                            }
                            System.Debug(FUNC_STR+'After Price: ' + zc.EFFECTIVE_PRICE);
                            
                            zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(cg.zCharges);
                        }      
                    }
                }
                
                if(!Test.isRunningtest()){
                    zqu.zQuoteUtil.updateChargeGroups(chargeGroups);
                }
            }
            quote.Charge_To_Be_Updated__c = false;
            system_logs__c logs = new system_logs__c();
            logs.Record_ID__c = quote.Id;
            logs.Object_Type__c = 'zqu__Quote__c';
            logs.Message__c = 'OrderDecompController: Charges were updated';
            insert logs;
            update quote;
            List<String> quoteList = new List<String>();
            quoteList.add(quoteId);
        } catch(Exception ex) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to update quote due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
        }
    }
    
    //@future(callout = true)
    public static void amend(Id orderItemId, String quoteId, String assetId, String price, Boolean Isrealsuite){
        final String FUNC_STR = DEBUG_STR+'amend: ';
        System.debug(FUNC_STR+'In amend method');
        String query = getCreatableFieldsSOQL('zqu__Quote__c', 'Id = :quoteId');
        List<zqu__Quote__c> quotesList = Database.query(query);
        System.Debug(FUNC_STR+'Query: ' + query);
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        try{
            //Retry Logic 3x
            try{
                chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
            }catch(Exception ex){
                if (ex.getMessage().containsIgnoreCase('Read timed out')){
                    try{
                        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
                    }catch(Exception ex1){
                        if (ex.getMessage().containsIgnoreCase('Read timed out')){
                            chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
                        }else{
                            throw ex1;
                        }
                    }
                }else{
                    throw ex;
                }
            }
            //CRM-3109 
            if(Isrealsuite){
                
                Account acc = [Select id, Consolidated_Billing_Flag__c, Billing_Preference__c, Party_Id__c from Account where Id = :quotesList[0].zqu__Account__c LIMIT 1];
                OrderItem OI = [Select Id, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c,
                                Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c,Product_Type__c,  
                                Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Market__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c from OrderItem
                                where Id = :orderItemId];
                chargeGroups = OrderDecompUtil.checkBillingPeriod(price, OI.Billing_Period__c, chargeGroups, quotesList[0], acc.Billing_Preference__c, acc.Consolidated_Billing_Flag__c, OI.Part_Number__c, true);      
                //Change the asset id on the Subscription for uograde and downgrade
                if(OI.Asset__c !=null)
                    quotesList[0].AssetId__c = OI.Asset__c;
            }
            
            System.Debug(FUNC_STR+'ChargeGroups@@: ' + chargeGroups);
            prepareTermsAndConditionChanges(assetId, quotesList[0], price, orderItemId, chargeGroups);
            System.Debug(FUNC_STR+'ChargeGroups@@@: ' + chargeGroups);
            //OrderItem OI = [Select Id, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c from OrderItem where Id = :orderItemId];
            system_logs__c logs = new system_logs__c();
            logs.Record_ID__c = quotesList[0].Id;
            logs.Object_Type__c = 'zqu__Quote__c';
            logs.Message__c = 'OrderDecompController: amend Quote was updated';
            insert logs;
            quotesList[0].CustomStatus__c = 'Autosend'; 
            System.debug('@@@@Asset ' +assetId);    
            update quotesList;    
        } catch (Exception ex) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to amend charge on quote due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
            return;
        }
    }
    @future(callout = true)
    public static void renewal(String quoteId, String zBillingAccountId, String assetId, String price, String orderItemId){
        final String FUNC_STR = DEBUG_STR+'renewal: ';
        System.debug(FUNC_STR+'In renew method');
        String Renewalamend ='';
        String query = getCreatableFieldsSOQL('zqu__Quote__c', 'Id = :quoteId');
        List<zqu__Quote__c> quotesList = Database.query(query);
        if (quotesList.size() == 0){
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no Quote returned for ID:' + quoteId);
            return;
        }
        //TCV Code
        List<Zuora__Subscription__c> subs = [Select Id, Zuora__Zuora_Id__c, Zuora__TermSettingType__c, Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__InitialTerm__c, Zuora__RenewalTerm__c, Zuora__AutoRenew__c, AssetID__c from Zuora__Subscription__c where AssetID__c = :assetId order by CreatedDate DESC];
        if (subs.size() == 0){
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no Subscription returned for AssetID:' + assetId);
            return;
        }
        List<zqu__Quote__c> quote = [SELECT zqu__Account__c,zqu__ZuoraAccountID__c,zqu__Status__c,Order_Product__c,Order_Product__r.Id FROM zqu__Quote__c WHERE Id = :quoteId];
        if (quote.size() == 0){
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no Quote returned for ID:' + quoteId);
            return;
        }
        String sfdcAccountId = quote[0].zqu__Account__c;
        Account[] accs = [Select id, Type,Consolidated_Billing_Flag__c, Billing_Preference__c, Party_Id__c from Account where Id = :sfdcAccountId LIMIT 1];
        Account acc;
        if (accs.size() > 0){
            acc = accs[0];
        }else{
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no Account returned for ID:' + sfdcAccountId);
            return;
        }
        OrderItem[] OIs = [Select Id, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c,
                           Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c,Product_Type__c,  
                           Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Market__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c from OrderItem
                           where Id = :orderItemId];
        OrderItem OI;
        if (OIs.size() > 0){
            OI = OIs[0];
        }else{
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no OrderItem returned for ID:' + orderItemId);
            return;
        }
        String tcv;
        String amountWithoutTax;
        String cpqId = OI.Part_Number__c;
        if(OI.Product_Type__c == 'Brand'){
            cpqId = cpqId + 'BRAND';
        }
        
        if(acc.Billing_Preference__c == 'CC-Direct'){
            cpqId = 'PAY' + cpqId;
        } else{
            cpqId = 'INV' + cpqId;
        }
        if(OI.Billing_Period__c != 'Month' && OI.Billing_Period__c != 'Monthly' && OI.Billing_Period__c != null && OI.Billing_Period__c != ''){     
            cpqId = 'CT' + cpqId;       
        } else if(acc.Consolidated_Billing_Flag__c == false){
            cpqId = 'CT' + cpqId;
        }
        //CRM-3305 start commenting for proddeployment
        Set<String> AccTypes = new Set<String>{'Moving Company', 'Moving Corporation', 'Lender Parent','Lender Branch', 'Loan Officer'};

        if(AccTypes.contains(acc.Type) && !Test.isrunningTest()){
            cpqId = OI.Part_Number__c+'RECURRING';
        }
        String prpId = getProductRatePlanId(cpqId);
        System.Debug(FUNC_STR+'prpId: ' + prpId);
        
        List<zqu__ProductRatePlan__c> listofPRPs = [Select Id, zqu__ZuoraId__c from zqu__ProductRatePlan__c 
                                                    where zqu__ZuoraId__c = :prpId AND zqu__Deleted__c = false];
        if (listofPRPs.size() == 0){
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no ProductRatePlans returned for zID:' + prpId);
            return;
        }
        List<String> productRatePlanIds = new List<String>();
        List<String> creditProductRatePlanIds = new List<String>();
        List<zqu__ProductRatePlanCharge__c> listofPRPCs = new List<zqu__ProductRatePlanCharge__c>();
        //Test
        //if(!Test.isRunningTest()){
        productRatePlanIds.add(listofPRPs[0].Id);
        listofPRPCs = [Select Id, zqu__ZuoraId__c from zqu__ProductRatePlanCharge__c 
                       where zqu__ProductRatePlan__c = :listofPRPs[0].Id AND zqu__Deleted__c = false];
        if (listofPRPCs.size() == 0){
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to no ProductRatePlanCharges returned for ProductRatePlanId:' + listofPRPs[0].Id);
            return;
        }
        //}
        
        Decimal initialTerm = (OI.Override_Term__c > 0) ? OI.Override_Term__c : Decimal.valueOf(OI.Contract_Term__c);
        Decimal renewalTerm = initialTerm;
        
        Zuora.zApi zApi = new Zuora.zApi();
        if(!Test.isRunningTest()){
            try {
                zApi = zuoraApiAccess();
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Exception occurred logging into Zuora. Updating orderitem');
                updateOrderItem(orderItemId, true, 'Failed to subscribePreview due to Zuora login failure. Message: '+ex.getMessage()+', Stacktrace: '+ex.getStackTraceString());
                return;
            }      
            zApi.zLogin();
        }
        
        //Subscribe Preview Call
        List<Zuora.zApi.SubscribeResult> subscribePreviewResults = new List<Zuora.zApi.SubscribeResult>();
        try {
            System.Debug(FUNC_STR+'In try');
            OrderDecompUtil.SubscribePreviewResponse response = OrderDecompUtil.performSubscribePreview(zApi, subs[0].Zuora__TermEndDate__c, listofPRPs[0], listofPRPCs[0], price, cpqId, zBillingAccountId, initialTerm, renewalTerm);
            
            if (!Test.isRunningTest()) { 
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            
            tcv = response.totalTcv;
            amountWithoutTax = response.amountWithoutTax;
            
            System.Debug(FUNC_STR+'TCV: ' + tcv);
            System.Debug(FUNC_STR+'amountWithoutTax: ' + amountWithoutTax);
            
            if(Decimal.valueOf(tcv) != Decimal.valueOf(amountWithoutTax)){
                System.Debug(FUNC_STR+'Adding Credit Charge for TCV');
                if(cpqId.indexOf('CREDIT') == -1){         
                    String cpqCredit = cpqId + 'CREDIT';
                    String prpIdCredit = getProductRatePlanId(cpqCredit);
                    List<zqu__ProductRatePlan__c> listofCreditPRPs = [SELECT Id, zqu__ZuoraId__c 
                                                                      FROM zqu__ProductRatePlan__c 
                                                                      WHERE zqu__ZuoraId__c = :prpIdCredit AND zqu__Deleted__c = false];
                    creditProductRatePlanIds = new List<String>();
                    creditProductRatePlanIds.add(listofCreditPRPs[0].Id);
                    List<zqu__ProductRatePlanCharge__c> listofCreditPRPCs = [SELECT Id, zqu__ZuoraId__c 
                                                                             FROM zqu__ProductRatePlanCharge__c 
                                                                             WHERE zqu__ProductRatePlan__c = :listofCreditPRPs[0].Id AND zqu__Deleted__c = false];
                    System.Debug(FUNC_STR+'listofCreditPRPCs: ' + listofCreditPRPCs);
                }                       
            }
        } catch (Exception ex) {
            //errorMessage = FUNC_STR+'Subscribe Preview call failed: '+ex.getMessage();
            if(!Test.isRunningTest()){
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                System.debug(ex.getMessage());
                //errorStatus = true;
                updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
                return;
            }
        } 
                    List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();           
        
        try{

            //Retry 3-Times
            try{
                chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
            }catch(Exception ex){
                if (ex.getMessage().containsIgnoreCase('Read timed out')){
                    try{
                        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
                    }catch(Exception ex1){
                        if (ex1.getMessage().containsIgnoreCase('Read timed out')){
                            chargeGroups = zqu.zQuoteUtil.getChargeGroups(quotesList[0].Id);
                        }   
                        else{
                            throw ex1;
                        }
                    }                   
                }else{
                    throw ex;
                }
            }
            //
            System.Debug(FUNC_STR+'ChargeGroups: ' + chargeGroups);
            
            if(!Test.isRunningTest()){
                zqu.zQuoteUtil.renewQuote(quotesList[0]);
            }
            
            //Checke the billing period
            chargeGroups = OrderDecompUtil.checkBillingPeriod(price, OI.Billing_Period__c, chargeGroups, quotesList[0], acc.Billing_Preference__c, acc.Consolidated_Billing_Flag__c, OI.Part_Number__c);
            
            System.Debug(FUNC_STR+'New ChargeGroups: ' + chargeGroups);
            
            prepareTermsAndConditionChanges(assetId, quotesList[0], price, orderItemId, chargeGroups);
            //Adding Credit Code
            if(creditProductRatePlanIds.size() == 0 && Test.isRunningTest()){
                creditProductRatePlanIds = productRatePlanIds;
            }  
            if(creditProductRatePlanIds.size() > 0){
                List<zqu.zChargeGroup> CreditcGs = new List<zqu.zChargeGroup>();
                try{
                    CreditcGs = zqu.zQuoteUtil.getChargeGroups(quoteId, creditProductRatePlanIds);
                }catch(Exception ex){
                    if (ex.getMessage().containsIgnoreCase('Read timed out')){
                        try{
                            CreditcGs = zqu.zQuoteUtil.getChargeGroups(quoteId, creditProductRatePlanIds);
                        }catch(Exception ex1){
                            if (ex1.getMessage().containsIgnoreCase('Read timed out')){
                                CreditcGs = zqu.zQuoteUtil.getChargeGroups(quoteId, creditProductRatePlanIds);
                            }else {
                                throw ex1;
                            }
                        }
                    }else{
                        throw ex;
                    }   
                }
                
                List<zqu.zCharge> zCreditCharges = new List<zqu.zCharge>();
                for(zqu.zChargeGroup Chargecg : CreditcGs){
                    for(zqu.zCharge Chargezc : Chargecg.zCharges){
                        if(Chargezc.EFFECTIVE_PRICE == '0.00' || Chargezc.EFFECTIVE_PRICE == '0.00' || Chargezc.EFFECTIVE_PRICE == null){
                            Chargezc.EFFECTIVE_PRICE = String.valueOf(Decimal.valueOf(tcv) - Decimal.valueOf(amountWithoutTax));
                        }        
                        Chargezc.QUANTITY = '1';        
                        zCreditCharges.add(Chargezc);
                    }     
                }
                zqu.zQuoteUtil.calculateChargesOnQuantityChange(zCreditCharges);
                zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(zCreditCharges);
                zqu.zQuoteUtil.addChargeGroups(CreditcGs);
            }
            //End Credit Code
        } catch (Exception ex) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to renew quote due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
            return;
        }
        
        List<zqu__QuoteRatePlanCharge__c> qrpcs = [Select Id, zqu__ChargeType__c from zqu__QuoteRatePlanCharge__c 
                                                   where zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId];
        System.Debug(FUNC_STR+'QuoteRatePlanCharges: ' + qrpcs);
        for(zqu__QuoteRatePlanCharge__c qrpc : qrpcs) {
            //Update custom field based on Commerce Group Type.
            //If Commerce Group Type is blank use the qrpc.Id.
            //This is used for Grouping on Invoice Template
            if(OI.Commerce_Group__c == 'Broker Marketing Solution') {
                qrpc.Commerce_Group__c = 'Broker Marketing Solution';
            } else if(OI.Commerce_Group__c == 'Agent Marketing Solution') {
                qrpc.Commerce_Group__c = 'Agent Marketing Solution';
            } else if(qrpc.zqu__ChargeType__c == 'One-Time'){
                qrpc.Commerce_Group__c = (String)qrpc.Id + '-Credit';
            } else{
                qrpc.Commerce_Group__c = (String)qrpc.Id;
            }  
            
            if(OI.Market__c != null){
                qrpc.Market_Description__c = String.valueOf(OrderItem.Market__c);
            } 
            
        }
        String billingPeriod = OI.Billing_Period__c;
        
        if(OI.Billing_Period__c == 'Bi-Annual')
            billingPeriod = 'Semi-Annual';
        else if (OI.Billing_Period__c == 'Quarterly')
            billingPeriod = 'Quarter';
        else if (OI.Billing_Period__c == 'Monthly')
            billingPeriod = 'Month';
        
        List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChrgs = [SELECT Id, zqu__Period__c FROM zqu__QuoteRatePlanCharge__c 
                                                                where zqu__quoterateplan__r.zqu__quote__C =: quoteId 
                                                                and (zqu__ChargeType__c =: 'Recurring' or zqu__ChargeType__c =: 'Usage')];
        System.debug(FUNC_STR + 'Retrieved ' + quoteRatePlanChrgs.size()+' QuoteRatePlanCharges: '+quoteRatePlanChrgs);
        
        for (zqu__QuoteRatePlanCharge__c qrpc : quoteRatePlanChrgs){
            System.debug(FUNC_STR + 'Changing billing period for '+ qrpc.Id + ' from ' + qrpc.zqu__Period__c +' to ' + billingPeriod);
            qrpc.zqu__Period__c = billingPeriod;
            System.debug(FUNC_STR + 'BillingPeriod set to :'+ qrpc.zqu__Period__c);
        }
        
        try{
            if(!quoteRatePlanChrgs.isEmpty()){
                update quoteRatePlanChrgs;
                System.debug(FUNC_STR + 'Updated '+quoteRatePlanChrgs.size()+' QuoteRatePlanCharges: '+quoteRatePlanChrgs);
            } else {
                System.debug(FUNC_STR+'quoteRatePlanChrgs empty, will not update QuoteRatePlanCharges');
            }
        }catch(Exception e){
            System.debug(FUNC_STR+'Exception occurred while updating QuoteRatePlanCharges: ' + e.getMessage());
        }
        
        if(String.isBlank(prpId)) {
            System.debug(FUNC_STR+'No associated Zuora Product found for CPQ ID: '+cpqId);
            errorMessage='No associated Zuora Product found for CPQ ID: '+cpqId;
            errorStatus=true;
            updateOrderItem(OI.Id);
        } 
        if(!quotesList.isempty()){
            system_logs__c logs = new system_logs__c();
            logs.Record_ID__c = quotesList[0].Id;
            logs.Object_Type__c = 'zqu__Quote__c';
            logs.Message__c = 'OrderDecompController: renewal quote updated';
            insert logs;
        }
        //String query = getCreatableFieldsSOQL('zqu__Quote__c', 'Id = :quoteId');
        //prepareTermsAndConditionChanges(assetId, quotesList[0], price, orderItemId);
        if(!Test.isRunningTest()){
            quotesList[0].CustomStatus__c = 'Autosend';    
            update quotesList;
        }
        update qrpcs;
    }
    
    /**
* Creates a cancellation amendment on the specified Quote
* @param  quoteId SFDC Id of Zuora Quote
* @return         [description]
*/
    public static Boolean cancel(String quoteId) {
        final String FUNC_STR = DEBUG_STR+'cancel: ';
        System.debug(FUNC_STR+'In cancel method');
        String canda='';
        String start ='';
        String Amt = '';
        String cam ='';
        //String query = getCreatableFieldsSOQL('zqu__Quote__c', 'Id = :quoteId');
        //List<zqu__Quote__c> quotesList = Database.query(query);
        //zqu.zQuoteUtil.createCancellationAmendment(quotesList[0].Id);
        //quotesList[0].status__c = 'Autosend';
        ///update quotesList;
        if(!Test.isRunningTest()){
            try{                
                zqu.zQuoteUtil.createCancellationAmendment(quoteId);                
            }catch (Exception ex) {
                System.debug(FUNC_STR+'Exception Occured after calling createCancellationAmendment inside the cancel method');
                updateOrderItemWithQuote(quoteId, true, 'Unable to create Cancellation Amendment. Message: ' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString()+'Quote Id: '+quoteId);
                return false;
            }
        }
        system_logs__c logs = new system_logs__c();
        logs.Record_ID__c = quoteId;
        logs.Object_Type__c = 'zqu__Quote__c';
        logs.Message__c = 'OrderDecompController: Zuora Cancel Quote was updated';
        insert logs;
        zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
        quoteToUpdate.Id = quoteId;
        quoteToUpdate.CustomStatus__c = 'Autosend';
        update quoteToUpdate;
        return false;
    }
    
    /**
* Responsible for adding rateplans / credits to an existing New Subscription quote
* @param quoteId           SFDC Id of Zuora Quote
* @param sfdcAccountId     SFDC Id of Sfdc Account
* @param zBillingAccountId Zuora Id of Billing Account in SFDC
* @param cpqId             CPQ ID for finding a ProductRatePlan / ProductRatePlanCharge 
* @param price             Effective price of new charge
* @param billingPeriod     Billing period to override on new charge
* @param quantity          Quantity for new charge
* @param orderItemId       SFDC Id of OrderItem
*/
    @future(callout = true)
    public static void addCharge(String quoteId, String sfdcAccountId, String zBillingAccountId, String cpqId, String price, String billingPeriod, String quantity, String orderItemId) {
        final String FUNC_STR = DEBUG_STR+'addCharge: ';
        System.debug(FUNC_STR+'In addCharge method with params: quoteId: '+quoteId+', sfdcAccountId: '+sfdcAccountId+', zBillingAccountId: '+zBillingAccountId+
                     ', cpqId: '+cpqId+', price: '+price+', billingPeriod: '+billingPeriod+', quantity: '+quantity+', orderItemId: '+orderItemId);
        
        String tcv;
        String amountWithoutTax;
        String amnt;
        String Billingt = '';
        String Productd = '';
        String Pppid = '';
        String Pmidd= '';
        String Pwid = '';
        
        //Retrieve ProductRatePlan ZuoraId for passed in CPQ ID
        if(Test.isRunningTest()) { 
            cpqId = OrderDecompControllerTest.TEST_CPQ_ID;
        }
        String prpId = getProductRatePlanId(cpqId);
        List<zqu__ProductRatePlan__c> listofPRPs = [SELECT Id, zqu__ZuoraId__c 
                                                    FROM zqu__ProductRatePlan__c 
                                                    WHERE zqu__ZuoraId__c = :prpId AND zqu__Deleted__c = false];
        if (listofPRPs.isEmpty()) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to add charge to quote due to no ProductRatePlan returned for CPQId: "' + cpqId + '", zID: "' + prpId+'"');
            return;
        }
        zqu__ProductRatePlan__c prp = listofPRPs[0];
        
        Id prpSfdcId = prp.Id;
        List<String> productRatePlanIds = new List<String>{
            prpSfdcId
                };
                    List<String> creditProductRatePlanIds = new List<String>();
        
        //Retrieve PRPCs for the retrieved PRP
        List<zqu__ProductRatePlanCharge__c> listofPRPCs = new List<zqu__ProductRatePlanCharge__c>();
        listofPRPCs = [SELECT Id, zqu__ZuoraId__c 
                       FROM zqu__ProductRatePlanCharge__c 
                       WHERE zqu__ProductRatePlan__c = :prpSfdcId AND zqu__Deleted__c = false];    
        if (listofPRPCs.isEmpty()) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to add charge to quote due to no ProductRatePlanCharges returned for ProductRatePlan ID: ' + prpSfdcId);
            return;
        }
        zqu__ProductRatePlanCharge__c prpc = listofPRPCs[0];
        
        //Retrieve OrderItem based on passed in orderItemId
        OrderItem orderItem = new OrderItem();
        OrderItem[] orderItemList = [SELECT Id, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c, 
                                     Extended_Net_Price__c, Contract_Term__c,Product_Type__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, 
                                     Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Market__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                                     FROM OrderItem 
                                     WHERE Id = :orderItemId];
        if (!orderItemList.isEmpty()){
            orderItem = orderItemList[0];
        } else {
            updateOrderItemWithQuote(quoteId, true, 'Unable to add charge to quote due to no OrderItem returned for OrderItem ID:' + orderItemId);
            return;
        }
        
        //Set Initial + Renewal Term based on Override Term or Contract Term
        Decimal initialTerm = (orderItem.Override_Term__c > 0) ? orderItem.Override_Term__c : Decimal.valueOf(orderItem.Contract_Term__c);
        Decimal renewalTerm = initialTerm;
        
        //Login to Zuora
        Zuora.zApi zApi = new Zuora.zApi();
        try {
            zApi = zuoraApiAccess();
        } catch (Exception ex) {
            System.debug(FUNC_STR+'Exception occurred logging into Zuora. Updating orderitem');
            updateOrderItem(orderItemId, true, 'Failed to add charge to Quote due to Zuora login failure. Message: '+ex.getMessage()+', Stacktrace: '+ex.getStackTraceString());
            return;
        }
        
        //Subscribe Preview Call
        try {
            System.Debug(FUNC_STR+'In try-block for subscribe preview');
            List<zqu__Quote__c> quoteList = [SELECT Id, zqu__StartDate__c
                                             FROM zqu__Quote__c
                                             WHERE Id =: quoteId];
            
            Date previewDate = null;
            if (quoteList.isEmpty()) {
                throw new CommonException('Failed to find Quote based on Id: '+quoteId);
            } else {
                previewDate = quoteList[0].zqu__StartDate__c;
            }
            OrderDecompUtil.SubscribePreviewResponse response = OrderDecompUtil.performSubscribePreview(zApi, previewDate, prp, prpc, price, cpqId, zBillingAccountId, initialTerm, renewalTerm);
            amountWithoutTax = response.amountWithoutTax;
            tcv = response.totalTcv;
            System.Debug(FUNC_STR+'TCV: ' + tcv);
            System.Debug(FUNC_STR+'amountWithoutTax: ' + amountWithoutTax);
            
            if(Decimal.valueOf(tcv) != Decimal.valueOf(amountWithoutTax)) {
                System.Debug(FUNC_STR+'Adding Credit Charge for TCV');
                if(cpqId.indexOf('CREDIT') == -1) {
                    String cpqCredit = '';
                    cpqCredit = cpqId + 'CREDIT';
                    if(orderItem.Product_Type__c  == 'Brand' || Test.isRunningTest()){
                        if(cpqId.contains('INVADVANTAGEBRAND'))
                            cpqCredit = 'INVADVANTAGECREDITBRAND';
                        else if(cpqId.contains('PAYADVANTAGEBRAND'))
                            cpqCredit = 'PAYADVANTAGECREDITBRAND';
                    }                 
                    String prpIdCredit = getProductRatePlanId(cpqCredit);
                    List<zqu__ProductRatePlan__c> listofCreditPRPs = [SELECT Id, zqu__ZuoraId__c 
                                                                      FROM zqu__ProductRatePlan__c 
                                                                      WHERE zqu__ZuoraId__c = :prpIdCredit AND zqu__Deleted__c = false];
                    if (listofCreditPRPs.isEmpty()) {
                        throw new CommonException('Failed to find Credit ProductRatePlan returned for CPQId: ' + cpqCredit + ' zPRP ID:' + prpIdCredit);
                    }
                    String creditSfdcPrpId = listofCreditPRPs[0].Id;
                    creditProductRatePlanIds = new List<String>{
                        creditSfdcPrpId
                            };
                                
                                List<zqu__ProductRatePlanCharge__c> listofCreditPRPCs = [SELECT Id, zqu__ZuoraId__c 
                                                                                         FROM zqu__ProductRatePlanCharge__c 
                                                                                         WHERE zqu__ProductRatePlan__c = :creditSfdcPrpId AND zqu__Deleted__c = false];
                    if (listofCreditPRPCs.isEmpty()) {
                        throw new CommonException('Failed to find Credit ProductRatePlanCharge returned for ProductRatePlan ID:' + creditSfdcPrpId);
                    }
                    System.Debug(FUNC_STR+'listofCreditPRPCs: ' + listofCreditPRPCs);
                }                              
            }


        } catch (Exception ex) {
            if(!Test.isRunningTest()){
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            System.debug('Exception occurred during subscribe preview section of addCharge(): '+ex.getMessage());
            updateOrderItemWithQuote(quoteId, true, 'Unable to add charge to quote due to error in subsribe preview section:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
            return;
        }
        
       // productRatePlanIds.add(prp.Id);
        //Add regular product / credit product
        try {

            //Regular product add section
            List<zqu.zChargeGroup> cGs = zqu.zQuoteUtil.getChargeGroups(quoteId, productRatePlanIds);
            List<zqu.zCharge> zCharges = new List<zqu.zCharge>();
            
            //Assumes single rateplan + single charge
            for(zqu.zChargeGroup cg : cGs) {
                for(zqu.zCharge zc : cg.zCharges) {
                    if (zc.EFFECTIVE_PRICE == '0.00' || zc.EFFECTIVE_PRICE == '0.00' || zc.EFFECTIVE_PRICE == null) {
                        if (zc.isEffectivePriceEditable) {
                            zc.EFFECTIVE_PRICE = price;
                        } else {
                            throw new CommonException('Modification of price is not allowed for charge: '+zc.Name);
                        }
                    }   
                    
                    if (zc.isQuantityEditable) {
                        zc.QUANTITY = quantity;
                    }    
                    
                    zCharges.add(zc);
                }     
            }
            
            zqu.zQuoteUtil.calculateChargesOnQuantityChange(zCharges);
            zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(zCharges);
            zqu.zQuoteUtil.addChargeGroups(cGs);
            
            //Adding Credit Code
            if(Test.isRunningTest()){
                creditProductRatePlanIds = productRatePlanIds;
                tcv = '987.0';
                amountWithoutTax = '456';
            }
            
            if(creditProductRatePlanIds.size() > 0) {
                List<zqu.zChargeGroup> creditCGs = zqu.zQuoteUtil.getChargeGroups(quoteId, creditProductRatePlanIds);
                List<zqu.zCharge> zCreditCharges = new List<zqu.zCharge>();
                for(zqu.zChargeGroup creditCG : creditCGs){
                    for(zqu.zCharge chargeZc : creditCG.zCharges) {
                        if(chargeZc.EFFECTIVE_PRICE == '0.00' || chargeZc.EFFECTIVE_PRICE == '0.00' || chargeZc.EFFECTIVE_PRICE == null) {
                            if (chargeZc.isEffectivePriceEditable) {
                                chargeZc.EFFECTIVE_PRICE = String.valueOf(Decimal.valueOf(tcv) - Decimal.valueOf(amountWithoutTax));
                            } else {
                                throw new CommonException('Modification of price is not allowed for credit charge: '+chargeZc.NAME);
                            } 
                        }
                        
                        if (chargeZc.isQuantityEditable) {
                            chargeZc.QUANTITY = quantity;
                        }
                        
                        zCreditCharges.add(chargeZc);
                    }     
                }
                
                zqu.zQuoteUtil.calculateChargesOnQuantityChange(zCreditCharges);
                zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(zCreditCharges);
                zqu.zQuoteUtil.addChargeGroups(creditCGs);
            }

            


            //End Credit Code
        } catch (Exception ex) {
            updateOrderItemWithQuote(quoteId, true, 'Unable to add charge to quote during product add step due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
            return;
        }
        
        //Update QC and QRPC section
        try {
            
            //Update Quote Rate Plan Charge fields
            //CRM-1640 Adding billing period changes to the Quote rateplan charge object after WSDL changes  
            List<zqu__QuoteRatePlanCharge__c> qrpcs = [SELECT Id, zqu__ChargeType__c 
                                                       FROM zqu__QuoteRatePlanCharge__c 
                                                       WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId];
            System.Debug(FUNC_STR+'QuoteRatePlanCharges: ' + qrpcs);
            for(zqu__QuoteRatePlanCharge__c qrpc : qrpcs){  
                //Update custom field based on Commerce Group Type.
                //If Commerce Group Type is blank use the qrpc.Id.
                //This is used for Grouping on Invoice Template
                if(orderItem.Commerce_Group__c == 'Broker Marketing Solution') {
                    qrpc.Commerce_Group__c = 'Broker Marketing Solution';
                } else if(orderItem.Commerce_Group__c == 'Agent Marketing Solution') {
                    qrpc.Commerce_Group__c = 'Agent Marketing Solution';
                } else if(qrpc.zqu__ChargeType__c == 'One-Time'){
                    qrpc.Commerce_Group__c = (String)qrpc.Id + '-Credit';
                } else{
                    qrpc.Commerce_Group__c = (String)qrpc.Id;
                }   
                
                if(OrderItem.Market__c != null){
                    qrpc.Market_Description__c = String.valueOf(OrderItem.Market__c);
                }  
                if(orderItem.Quantity != null) {
                    qrpc.qty__c = String.ValueOf(orderItem.Quantity);
                }
                
                if(OrderItem.Market__c != null){
                    qrpc.Market_Description__c = String.valueOf(OrderItem.Market__c);
                }
                
                //COTERM - Update Trigger Event and BCD on charge
                if(orderItem.Line_Type__c == 'Coterm'){
                    qrpc.zqu__TriggerEvent__c = 'ServiceActivation';
                    qrpc.zqu__BillCycleDay__c = 31;
                }
                
                //Update Billing Period on Charge
                if(billingPeriod != null){
                    qrpc.zqu__Period__c = billingPeriod;
                    
                    if(qrpc.zqu__Period__c == 'Annual' || qrpc.zqu__Period__c == 'Annually'){
                        //qrpc.zqu__PeriodNumeric__c = 12;
                        qrpc.zqu__Period__c = 'Annual';
                        qrpc.zqu__BillingPeriodAlignment__c = 'AlignToTermStart';
                    }
                    
                    if(qrpc.zqu__Period__c == 'Quarter' || qrpc.zqu__Period__c == 'Quarterly'){
                        //qrpc.zqu__PeriodNumeric__c = 3;
                        qrpc.zqu__Period__c = 'Quarter';
                        qrpc.zqu__BillingPeriodAlignment__c = 'AlignToTermStart';
                    }
                    
                    if(qrpc.zqu__Period__c == 'Semi-Annual' || qrpc.zqu__Period__c == 'Bi-Annual'){
                        //qrpc.zqu__PeriodNumeric__c = 6;
                        qrpc.zqu__Period__c = 'Semi-Annual';
                        qrpc.zqu__BillingPeriodAlignment__c = 'AlignToTermStart';
                    }
                    
                    if(qrpc.zqu__Period__c == 'Month' || qrpc.zqu__Period__c == 'Monthly'){
                        //qrpc.zqu__PeriodNumeric__c = 1;
                        qrpc.zqu__Period__c = 'Month';
                    }
                }               
            }
            
            /*if (!qcs.isEmpty()) {
update qcs;
}*/
            if (!qrpcs.isEmpty()) {
                update qrpcs;
            } 
        } catch(Exception ex) {
            updateOrderItemWithQuote(quoteId, true, 'Exception occurred when updating Quote Charges or Quote Rate Plan Charges on zuora quote:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString());
            return;
        }
    }
    
    /**
* Returns the Zuora ID of the ProductRatePlan for the ProductRatePlanCharge with specified CPQ ID
* @param  cpqId CPQ ID of ProductRatePlanCharge
* @return       Zuora ID of PRP for PRPC with CPQ ID
*/
    public static String getProductRatePlanId(String cpqId) {
        final String FUNC_STR = DEBUG_STR+'getProductRatePlanId: ';
        System.debug(FUNC_STR+'getProductRatePlanId called for CPQ ID: '+cpqId);
        
        //Holds Zuora ID of ProductRatePlan
        String prpId = '';
        
        //Ensure we have a CPQ Id
        if (String.isBlank(cpqId)) {
            return prpId;
        }
        
        //Search for PRPC based on passed in CPQ ID
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, zqu__ProductRatePlan__r.zqu__ZuoraId__c 
                                                        FROM zqu__ProductRatePlanCharge__c 
                                                        WHERE CPQID__c= :cpqId AND zqu__Deleted__c = false LIMIT 1];
        System.debug(FUNC_STR+'Retrieved '+prpcList.size()+' PRPCs: '+prpcList);
        
        //If failed to retrieve a PRPC, search for a CPQ ID without the first 2 characters
        if (prpcList.isEmpty()) {     
            cpqId = cpqId.substring(2);     
            prpcList = [SELECT Id, zqu__ProductRatePlan__r.zqu__ZuoraId__c 
                        FROM zqu__ProductRatePlanCharge__c 
                        WHERE CPQID__c= :cpqId AND zqu__Deleted__c = false LIMIT 1];          
            System.debug(FUNC_STR+'(attempt 2 with cpq id '+cpqId+') Retrieved '+prpcList.size()+' PRPCs: '+prpcList);
        }       
        
        //If we still do not have a PRPC, return empty string
        if (prpcList.isEmpty()){  
            System.debug(FUNC_STR+'Failed to find any PRPCs, returning empty string');
            return prpId;       
        }
        
        //Retrieve ProductRatePlan's Zuora ID from first PRPC
        zqu__ProductRatePlanCharge__c prpc = prpcList[0];
        if (prpc.zqu__ProductRatePlan__c != null && String.isNotBlank(prpc.zqu__ProductRatePlan__r.zqu__ZuoraId__c)) {
            prpId = prpc.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
        }
        
        System.debug(FUNC_STR+'Returning prpId: '+prpId);
        return prpId;
    }
    
    /**
* To get access to the Zuora Api and login
* CAUTION: consumes 1 callout so it is better to reuse the same zApi object when possible
*/
    public static Zuora.ZApi zuoraApiAccess() {
        final String FUNC_STR = DEBUG_STR+'zuoraApiAccess: ';
        Zuora.ZApi zApi = new Zuora.ZApi();
        
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(FUNC_STR+'Login to Zuora failed with message: '+ex.getMessage());
            throw ex;
        }
        
        return zApi;
    }
    
    /*
* Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
*/
    private static string getCreatableFieldsSOQL(String objectName, String whereClause){
        final String FUNC_STR = DEBUG_STR+'getCreatableFieldsSOQL: ';
        String selects = '';
        if (whereClause == null || whereClause == ''){ return null; }
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            // loop through all field tokens (ft)
            for (Schema.SObjectField ft : fMap.values()){
                // describe each field (fd)
                Schema.DescribeFieldResult fd = ft.getDescribe();
                
                selectFields.add(fd.getName());
                //if(objectName == 'zqu__Quote__c'){
                //selectFields.add('zqu__BillingEntity__r');
                //}
            }
        }
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}    
        }
        //CRM -1219 WSdl changes needs Billing Entity Field needs to be query.
        string billingentityQuery='';
        if(objectName=='zqu__Quote__c'){
            billingentityQuery = ',zqu__BillingEntity__r.id';   
        }
        
        return 'SELECT ' + selects +billingentityQuery +' FROM ' + objectName + ' WHERE ' + whereClause;
        
        //return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
    /**
* Default implementation of createAccountZObject() 
*/
    public static Zuora.ZObject createAccountZObject(String orderId, Account sfdcAccount) {     
        return createAccountZObject(orderId,sfdcAccount,false);     
    }
    
    /**
* Helper method for creating an Account Zuora.ZObject based off a specified SFDC Account.
* Sets new Zuora Account fields based on Billing Preference on SFDC Account
* If Billing Preference is null, assumes "Invoice" use case
* 
* @param sfdcAccount SFDC Account to retrieve information from for new Zuora Account
* @return Zuora.ZObject ZObject representing new Zuora Account
**/
    public static Zuora.ZObject createAccountZObject(String orderId, Account sfdcAccount, Boolean isUpdate) {
        final String FUNC_STR = DEBUG_STR+'createAccountZObject: ';
        if (sfdcAccount == null) {
            System.debug(FUNC_STR+'Salesforce Account passed to createAccountZObject is null');
            errorMessage = 'Salesforce Account passed to createAccountZObject is null';
            errorStatus = true;
            updateOrder(orderId,errorMessage);
            return null;
        }
        
        List<OrderItem> accountOrderItems = [SELECT Id, quantity, Start_Date__c,Asset__c,End_Date__c, 
                                             Term_Start_Date__c, Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, 
                                             Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, 
                                             Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, 
                                             Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                                             FROM OrderItem 
                                             WHERE orderId = :orderId];
        
        List<String> product2Ids = new List<String>();
        Boolean hasTigerLead = false;
        
        for(OrderItem OI1 : accountOrderItems) {
            if(OI1.Pricebookentry.Product2Id != null) {
                product2Ids.add(OI1.Pricebookentry.Product2Id);
            }
        }
        
        List<Product2> orderProduct2s = [SELECT Id, ProductCode, Fulfillment_ID__c FROM Product2 WHERE Id IN :product2Ids];
        System.Debug(FUNC_STR+'orderProduct2s: ' + orderProduct2s);
        
       
        //Find Account information from SFDC Account
        Zuora.ZObject newAccount = new Zuora.ZObject('Account');
        newAccount.setValue('Name', sfdcAccount.Name);
        newAccount.setValue('CrmId', sfdcAccount.Id);
        //LEAP-8525
        if(!isUpdate){
            newAccount.setValue('AccountNumber',sfdcAccount.Party_ID__c);
        }
        newAccount.setValue('Status', 'Draft');
        Boolean broker = false;
        if(sfdcAccount.Type == 'Agent Team' || sfdcAccount.Type == 'Realtor Agent' || sfdcAccount.Type == 'Agent'){
            newAccount.setValue('Account_Type__c', 'Realtor Agent');
        }else{
            newAccount.setValue('Account_Type__c', 'Broker');
            broker = true;
        }
        
        if(orderProduct2s != null) {
            for(Product2 product : orderProduct2s) {
                if(product.Fulfillment_ID__c == 'Tigerleads' ||  
                   ( (product.ProductCode =='SELLERLEADBUNDLE' || product.ProductCode == 'SELLERLEAD') 
                    && sfdcAccount.Consolidated_Billing_Flag__c == true 
                    && sfdcAccount.Billing_Preference__c.equalsIgnoreCase('CC-Direct') 
                    && broker == true)) {
                        hasTigerLead = true;
                    }
            }
        }
        
        
        
        //Read currency from SFDC Account. Throw exception if blank
        if (String.isBlank(sfdcAccount.Currency_Type__c)) {
            System.debug(FUNC_STR+'Currency Type on Salesforce Account is empty');
            errorMessage = 'Currency Type on Salesforce Account is empty';
            errorStatus = true;
            updateOrder(orderId,errorMessage);
            return null;
        } else {
            newAccount.setValue('Currency', sfdcAccount.Currency_Type__c);
        }
        
        if (String.isBlank(sfdcAccount.Billing_Preference__c) || sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-CC')) {
            //Invoice use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Terms')) {
            //Invoice-Terms use case
            newAccount.setValue('PaymentTerm', 'Net 30');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('CC-Direct')) {
            //Credit Card Direct use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch1');
            newAccount.setValue('BillCycleDay',System.today().day());
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Tiger')) {
            //Tiger use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch3');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('arrears-invoice')) {
            //arrears-invoice use case
            newAccount.setValue('PaymentTerm', 'Net 30');
            newAccount.setValue('Batch', 'Batch5');
            newAccount.setValue('BillCycleDay',1);
        }else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('arrears-cc')) {
            //arrears-cc use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch5');
            newAccount.setValue('BillCycleDay',1);
        }else{
            //Else use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
        }
        //CRM-3305 start commenting for proddeployment
       if(sfdcAccount.Type == 'Moving Company' || sfdcAccount.Type == 'Moving Corporation'){            
            newAccount.setValue('Account_Type__c', sfdcAccount.Type);            
            newAccount.setValue('Batch', 'Batch7');
            newAccount.setValue('BillCycleDay',1);          
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');  
            newAccount.setValue('InvoiceTemplateId', System.Label.Z_InvoiceTemplateId);
            if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Check')){
                newAccount.setValue('PaymentTerm', 'Net 30'); 
            }
        }
        // //CRM-5242 Added mortgage accounts types and Zuora account creation logic. 
         Set<String> lenderAcctype = new Set<String>{'Lender Parent','Lender Branch', 'Loan Officer'};
         if(lenderAcctype.contains(sfdcAccount.Type) || test.isrunningtest()){
            newAccount.setValue('Account_Type__c', sfdcAccount.Type);            
            newAccount.setValue('Batch', 'Batch15');
            newAccount.setValue('BillCycleDay',1);          
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');  
            newAccount.setValue('InvoiceTemplateId', System.Label.Z_MRCTemplate);
            if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Check')){
                newAccount.setValue('PaymentTerm', 'Net 30'); 
            }      
        }
        //CRM-3305 end 
        if(isUpdate== true && !test.isRunningtest()){
            Zuora__CustomerAccount__c sfdcBillingAccount = [Select Id,Zuora__Batch__c, Zuora__PaymentTerm__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :sfdcAccount.Id LIMIT 1];
            newAccount.setValue('Batch', sfdcBillingAccount.Zuora__Batch__c); 
            newAccount.setvalue('PaymentTerm', sfdcBillingAccount.Zuora__PaymentTerm__c);
        }
        if(sfdcAccount.Subscription_payment__c == true){
          newAccount.setValue('Subscription_payment__c', 'True');
       }
        if(hasTigerLead == true ) {
            //Tiger use case
            //Removed as we don't set PaymentTerm for TigerLead LEAP-7066
            //newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('BillCycleDay',1);
            
        }
        
        System.Debug(FUNC_STR+'SFDC Billing Pref: ' + sfdcAccount.Billing_Preference__c);
        newAccount.setValue('Billing_Preference__c', sfdcAccount.Billing_Preference__c);
        System.Debug(FUNC_STR+'newAccount: ' + newAccount);
        
        return newAccount;
    }
    
    /**
* Helper method for creating a Bill To Contact Zuora.ZObject
**/
    public static Zuora.ZObject createBillToContactZObject(Account sfdcAccount, String zAccId, Account_Relationship__c rel) {
        return createContactZObject(sfdcAccount, true, zAccId, rel);
    }
    
    /**
* Helper method for creating a Sold To Contact Zuora.ZObject
**/
    public static Zuora.ZObject createSoldToContactZObject(Account sfdcAccount, String zAccId, Account_Relationship__c rel) {
        return createContactZObject(sfdcAccount, false, zAccId, rel);
    }
    
    /**
* Helper method for creating a Contact Zuora.ZObject based on "isBillTo" flag
**/
    public static Zuora.ZObject createContactZObject(Account sfdcAccount, Boolean isBillTo, String zAccId, Account_Relationship__c rel) {
        final String FUNC_STR = DEBUG_STR+'createContactZObject: ';
        String conta='';
        String conn = '';
        String amtcreate ='';
        Zuora.ZObject newContact = new Zuora.ZObject('Contact');
        
        //Assume bill to contact if boolean is null
        isBillTo = (isBillTo == null) ? true : isBillTo;
        
        if (String.isBlank(zAccId) || rel == null || String.isBlank(rel.Contact_to__r.FirstName) || String.isBlank(rel.Contact_to__r.LastName)) {
            System.debug(FUNC_STR+'Zuora Account Id, SFDC Account, SFDC Relationship, or Contact First + Last Name is null');
        } else {
            newContact.setValue('AccountId', zAccId);
        }
        
        if (String.isNotBlank(rel.Contact_to__r.FirstName)) {
            newContact.setValue('FirstName', rel.Contact_to__r.FirstName);
        }
        if (String.isNotBlank(rel.Contact_to__r.LastName)) {
            newContact.setValue('LastName', rel.Contact_to__r.LastName);
        }
        if(String.isNotBlank(rel.Contact_to__r.Email)){
            newContact.setValue('WorkEmail', rel.Contact_To__r.Email);
        }
        if(String.isNotBlank(sfdcAccount.Phone)){
            newContact.setValue('WorkPhone', sfdcAccount.Phone);
        }
        
        if (isBillTo) {
            if (String.isNotBlank(sfdcAccount.BillingStreet)) {
                newContact.setValue('Address1', sfdcAccount.BillingStreet);
            }
            if (String.isNotBlank(sfdcAccount.BillingCity)) {
                newContact.setValue('City', sfdcAccount.BillingCity);
            }
            if (String.isNotBlank(sfdcAccount.BillingCountry)) {
                newContact.setValue('Country', sfdcAccount.BillingCountry);
            }
            if (String.isNotBlank(sfdcAccount.BillingPostalCode)) {
                newContact.setValue('PostalCode', sfdcAccount.BillingPostalCode);
            }
            if (String.isNotBlank(sfdcAccount.BillingState)) {
                newContact.setValue('State', sfdcAccount.BillingState);
            }
        } else {
            //TODO: if these are blank, do we read from billing contact?
            if (String.isNotBlank(sfdcAccount.ShippingStreet)) {
                newContact.setValue('Address1', sfdcAccount.ShippingStreet);
            }
            if (String.isNotBlank(sfdcAccount.ShippingCity)) {
                newContact.setValue('City', sfdcAccount.ShippingCity);
            }
            if (String.isNotBlank(sfdcAccount.ShippingCountry)) {
                newContact.setValue('Country', sfdcAccount.ShippingCountry);
            }
            if (String.isNotBlank(sfdcAccount.ShippingPostalCode)) {
                newContact.setValue('PostalCode', sfdcAccount.ShippingPostalCode);
            }
            if (String.isNotBlank(sfdcAccount.ShippingState)) {
                newContact.setValue('State', sfdcAccount.ShippingState);
            }
        }
        
        return newContact; 
    }
    
    public static List<Zuora.Zobject> queryZBillingAccount(String sfdcAccountId){
        final String FUNC_STR = DEBUG_STR+'queryZBillingAccount: ';
        System.debug(FUNC_STR+'Starting queryZBillingAccount');
        List<Zuora.zObject> lstBillingAccounts = new List<Zuora.zObject> ();
        String zuoraAccountId = '';
        try{
            //Query Zuora
            Zuora.zApi zApi = new Zuora.zApi();
            if(!Test.isRunningTest()){
                zApi.zLogin();
            }
            String strQuery = 'Select Id,BillToId,SoldToId from Account where CRMId =\'' + sfdcAccountId + '\'' ;
            System.debug('strQuery:' + strQuery);
            lstBillingAccounts = (!Test.isRunningTest()) ? zApi.zQuery(strQuery) : new List<Zuora.zObject>();  
            System.debug('Size of lstBillingAccounts:' + lstBillingAccounts.size());
            
            // if(lstBillingAccounts.isEmpty())
            // zuoraAccountId= '';
            // else
            // zuoraAccountId = (String)lstBillingAccounts[0].getValue('Id'); 
            
            // System.debug('zuoraAccountId :' + zuoraAccountId);
            
        }catch(Exception ex){
            System.debug(FUNC_STR+'Error occurred while quering Zuora Account: '+ex.getMessage());
        }
        return lstBillingAccounts;
    }
    
    /**
* Main method for creating an Account in Zuora in the case one doesn't already exist
* Creates an Account in draft status, creates Bill To and Sold To contact, and updates Account to Active
**/
    @future(callout = true)
    public static void createZuoraAccount(String orderId, String sfdcAccountId) {
        final String FUNC_STR = DEBUG_STR+'createZuoraAccount: ';
        System.debug(FUNC_STR+'Starting createZuoraAccount');
        errorStatus = false;
        errorMessage = '';
        String billToId = '';
        String soldToId = '';
        String ZuoraAccountId='';
        Boolean createContactsSuccess = false;
        Boolean createAccountSuccess = true;       
        //Made change for Quebale job error CRM-1414      
        String accId = '';
        List<Zuora.zObject> BillingAccounts = new List<Zuora.zObject> ();           
        Account sfdcAccount = [Select Id,Name,Currency_Type__c,Subscription_payment__c, Consolidated_Billing_Flag__c, Type, Billing_Preference__c,BillingStreet,BillingCity,BillingState, BillingCountry,
                               BillingPostalCode, ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState, Phone, Party_ID__c
                               from Account where Id = :sfdcAccountId LIMIT 1];
        //Retrieve ZObject from helper method. Method throws error if sfdcAccount is null.
        Zuora.ZObject newAcc = createAccountZObject(orderId, sfdcAccount);
        if(newAcc == null)
            return;
        System.debug(FUNC_STR+'Created Account zObject');
        System.debug(FUNC_STR+'Logging in');
        //Create ZApi and login to Zuora. Method thorws error if login is unsuccessful
        Zuora.zApi zApi = zuoraApiAccess();
        System.debug(FUNC_STR+'Logged into Zuora successfully');
        //Create Account in Zuora
        List<Zuora.ZApi.SaveResult> createAccResults = new List<Zuora.ZApi.SaveResult>();
        try {           
            //First Query Zuora //LEAP-8525//CRM-1414
            BillingAccounts = queryZBillingAccount(sfdcAccountId);
            if(!BillingAccounts.isEmpty()){
                if((String)BillingAccounts[0].getValue('SoldToId')!=null &&(String)BillingAccounts[0].getValue('BillToId')!=null){               
                    soldToId = (String)BillingAccounts[0].getValue('SoldToId');
                    billToId = (String)BillingAccounts[0].getValue('BillToId');
                    zuoraAccountId = (String)BillingAccounts[0].getValue('Id');
                    createContactsSuccess = true;
                }else{
                    zuoraAccountId = (String)BillingAccounts[0].getValue('Id');
                }          
            }
            
            if(!Test.isRunningTest()){  
                if (zuoraAccountId != null && zuoraAccountId != ''){
                    System.debug(FUNC_STR+'Zuora Account already exists:' + zuoraAccountId);
                    createAccountSuccess = true;
                    accId = zuoraAccountId;
                    //Made change for Quebale job error
                    //convertOrderLines(orderId, sfdcAccountId, zuoraAccountId);
                    //return;
                }else{
                    createAccResults = zApi.zCreate(new List<Zuora.ZObject>{newAcc});
                    System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                    System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                }
            } else {
                createAccResults = new List<Zuora.ZApi.SaveResult>();
                Zuora.ZApi.SaveResult createAccResult = new Zuora.ZApi.SaveResult();
                createAccResult.Success = true;
                createAccResult.Id = 'testzuoraid0000000001';
                createAccResult.Errors = null;
                createAccResults.add(createAccResult);
            }
            System.debug(FUNC_STR+'Create Account in Zuora results: '+createAccResults);
            //Made change for Quebale job error CRM-1414
            //Boolean createAccountSuccess = false;
            String createAccountError = '';
            // String accId = '';
            if (createAccResults.size() > 0) {
                Zuora.ZApi.SaveResult createAccResult = createAccResults[0];
                createAccountSuccess = (createAccResult.Success != null) ? createAccResult.Success : false;
                accId = (createAccountSuccess && String.isNotBlank(createAccResult.Id)) ? createAccResult.Id : '';
                createAccountError = (createAccResult.Errors != null && createAccResult.Errors.size() > 0 && String.isNotBlank((String)createAccResult.Errors[0].getValue('Message'))) ? (String)createAccResult.Errors[0].getValue('Message') : '';
                
                if(createAccountError!=null && createAccountError!='' && accId ==''){
                    errorMessage = FUNC_STR+'Error occurred creating Draft Account in Zuora: ' +createAccountError;                                                 
                    updateOrder(orderId,errorMessage);
                    return;
                }
            }       
            
        } catch (Exception ex) {
            errorMessage = FUNC_STR+'Draft Account creation failed: '+ex.getMessage();
            System.debug(errorMessage);         
            updateOrder(orderId,errorMessage);
            return;
        }
        
        //Create Contacts in Zuora                                         
        //Retrieve Contact Relationships
        //TODO: confirm criteria for billing / shipping relationship
        List<Account_Relationship__c> contactRelationships = [SELECT Contact_to__r.FirstName, Contact_to__r.LastName, Billing_Contact__c, 
                                                              Zuora_Bill_to_Contact_ID__c, Contact_Role__c, Zuora_Ship_to_Contact_ID__c, Contact_to__r.Email FROM Account_Relationship__c 
                                                              WHERE Parent_Account__c = :sfdcAccount.Id AND Active__c = true AND RecordType.Name IN ('Contact Relationship')];
        System.debug(FUNC_STR+'Retrieved contactRelationships: '+contactRelationships);
        Account_Relationship__c billRel = null;
        Account_Relationship__c soldRel = null;
        
        for (Account_Relationship__c rel : contactRelationships) {
            if (rel.Billing_Contact__c) {
                billRel = rel;
            } 
            if (rel.Contact_Role__c == 'Primary Contact'){
                soldRel = rel;
            }
        }
        if (billRel == null) {
            System.Debug(FUNC_STR+'Failed to find a Billing Contact Relationship');
        }
        if (soldRel == null) {
            System.Debug(FUNC_STR+'Failed to find a Shipping Contact Relationship');
        }                      
        if (createAccountSuccess && String.isNotBlank(accId)&& String.isBlank(soldToId)&& String.isBlank(billToId)){
            try{
                System.debug(FUNC_STR+'Successfully created Draft Account in Zuora. Creating Contacts');
                //TODO: refactor into method
                //Create Account in Zuora
                Zuora.ZObject newBillCon = createBillToContactZObject(sfdcAccount, accId, billRel);
                Zuora.ZObject newSoldCon = createSoldToContactZObject(sfdcAccount, accId, soldRel);
                String BillConSFDCId = billRel.Id;
                String SoldConSFDCId = soldRel.Id;
                List<Zuora.ZApi.SaveResult> createConResults = new List<Zuora.ZApi.SaveResult>();
                try {
                    if(!Test.isRunningTest()){
                        createConResults = zApi.zCreate(new List<Zuora.ZObject>{newBillCon,newSoldCon});
                        System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                        System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                    } else {
                        createConResults =  new List<Zuora.ZApi.SaveResult>();
                        Zuora.ZApi.SaveResult createConResult = new Zuora.ZApi.SaveResult();
                        createConResult.Success = true;
                        createConResult.Id = 'testzuoraid0000000001';
                        createConResults.add(createConResult);
                        
                        Zuora.ZApi.SaveResult createConResult2 = new Zuora.ZApi.SaveResult();
                        createConResult2.Success = true;
                        createConResult2.Id = 'testzuoraid0000000002';
                        createConResults.add(createConResult2);
                        
                    }
                } catch (Exception ex) {
                    System.debug(FUNC_STR+'Error occurred trying to create Contacts in Zuora: '+ex.getMessage());
                }
                
                System.debug(FUNC_STR+'Create Contacts in Zuora results: '+createConResults);
                
                
                string billtoContactMessage='';
                string soldtoContactMessage='';
                
                if (createConResults.size() > 0) {
                    Zuora.ZApi.SaveResult billSaveResult;
                    Zuora.ZApi.SaveResult soldSaveResult;
                    
                    if (createConResults.size() > 1) {
                        billSaveResult = createConResults[0];
                        soldSaveResult = createConResults[1];
                    } else {
                        billSaveResult = createConResults[0];
                        soldSaveResult = createConResults[0];
                    }
                    if(billSaveResult!=null && !billSaveResult.success)
                        billtoContactMessage = String.isNotBlank((string)billSaveResult.Errors[0].getvalue('Message'))? (String)billSaveResult.Errors[0].getValue('Message'):'';
                    if(soldSaveResult!=null && !soldSaveResult.success)
                        soldtoContactMessage = String.isNotBlank((string)soldSaveResult.Errors[0].getvalue('Message'))? (String)soldSaveResult.Errors[1].getValue('Message'):'';
                    
                    createContactsSuccess = (billSaveResult != null && soldSaveResult != null) ? (billSaveResult.Success && soldSaveResult.Success) : false;
                    
                    billToId = (createContactsSuccess) ? billSaveResult.Id : '';
                    soldToId = (createContactsSuccess) ? soldSaveResult.Id : '';
                }
                System.debug(FUNC_STR+'Create Contacts Success: '+createContactsSuccess);
                
                if (createContactsSuccess && String.isNotBlank(billToId) && String.isNotBlank(soldToId)) {
                    List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
                    Zuora.ZObject updatedAccount = new Zuora.ZObject('Account');
                    updatedAccount.setValue('Id', accId);
                    updatedAccount.setValue('BillToId', billToId);
                    updatedAccount.setValue('SoldToId', soldToId);
                    updatedAccount.setValue('CRMSoldToID__c', SoldConSFDCId);
                    updatedAccount.setValue('CRMBillToID__c', BillConSFDCId);
                    updatedAccount.setValue('Status', 'Active');
                    
                    try {
                        if(!Test.isRunningTest()) {
                            updateAccResults = zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount});
                            System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                            System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                        } else { 
                            updateAccResults = new List<Zuora.ZApi.SaveResult>();
                            Zuora.ZApi.SaveResult updateAccResult = new Zuora.ZApi.SaveResult();
                            updateAccResult.Success = true;
                            updateAccResults.add(updateAccResult);
                        }
                    } catch (Exception ex) {
                        System.debug(FUNC_STR+'Error occurred trying to create Account in Zuora: '+ex.getMessage());
                        errorMessage = FUNC_STR+'Error occurred trying to create Account in Zuora: '+ex.getMessage();
                        errorStatus = true;
                        updateOrder(orderId,errorMessage);
                    }
                    System.debug(FUNC_STR+'Update Account in Zuora results: '+updateAccResults);
                    
                    Boolean updateAccountSuccess = false;
                    String updateAccountError = '';
                    if (updateAccResults.size() > 0) {
                        Zuora.ZApi.SaveResult updateAccResult = updateAccResults[0];
                        updateAccountSuccess = (updateAccResult.Success != null) ? updateAccResult.Success : false;
                        updateAccountError = (updateAccResult.Errors != null && updateAccResult.Errors.size() > 0 && String.isNotBlank((String)updateAccResult.Errors[0].getValue('Message'))) ? (String)updateAccResult.Errors[0].getValue('Message') : '';
                    }
                    System.debug(FUNC_STR+'Create Account Success: '+updateAccountSuccess);
                    
                    if (updateAccountSuccess) {
                        
                        //Update SFDC Account with new Zuora Account Id
                        //TODO: refactor to fix the spelling of "Zuora"
                        sfdcAccount.Zoura_Account_id__c = accId;
                        try {
                            if(!Test.isRunningTest())
                                update sfdcAccount;
                        } catch (Exception ex) {
                            System.debug(FUNC_STR+'Error occurred updating SFDC Account with new Zuora Account Id: '+ex.getMessage());
                        }
                        
                        //Update SFDC Relationship with new Contact Ids
                        //TODO: refactor this object to only store one zuora id
                        billRel.Zuora_Bill_to_Contact_ID__c = billToId;
                        soldRel.Zuora_Ship_to_Contact_ID__c = soldToId;
                        
                        try {
                            if(billRel != soldRel){
                                update new List<Account_Relationship__c>{billRel,soldRel};
                                    } else {
                                        update new List<Account_Relationship__c>{billRel};
                                            }
                        } catch (Exception ex) {
                            System.debug(FUNC_STR+'Error occurred updating SFDC Contact Relationship with new Zuora Contact Ids: '+ex.getMessage());
                        }
                        
                        //return accId;
                    } else {
                        System.debug(FUNC_STR+'Error occurred trying to update Account to "Active": '+updateAccountError);
                        Boolean deleteAccountResult = deleteZObjects('Account', new List<String>{accId}, zApi);
                        errorMessage = FUNC_STR+'Activating Account Failed: '+updateAccountError;                       
                        updateOrder(orderId,errorMessage);
                        return;
                    }
                } else {
                    System.debug(FUNC_STR+'Error occurred creating Contacts for new Account in Zuora');
                    Boolean deleteAccountResult = deleteZObjects('Account', new List<String>{accId}, zApi);
                    errorMessage = FUNC_STR+'Error occurred creating Contacts for new Account in Zuora';
                    errorStatus = true;
                    if(billtoContactMessage!=null && billtoContactMessage!='')
                        errorMessage += 'Bill to Contact Error: '+billtoContactMessage;
                    if(soldtoContactMessage!=null && soldtoContactMessage!='')
                        errorMessage +='Sold to Contact Error: '+billtoContactMessage;
                    updateOrder(orderId,errorMessage);
                    return;
                }
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Error occurred after draft account created: '+ex.getMessage()+'. Deleting draft account with id: '+accId);
                Boolean deleteAccountResult = deleteZObjects('Account', new List<String>{accId}, zApi);
                errorMessage = FUNC_STR+'Error occurred after draft account created: '+ex.getMessage()+'. Deleting draft account with id: '+accId;
                errorStatus = true;
                updateOrder(orderId,errorMessage);
                return;
            } 
        } else {          
            errorMessage = FUNC_STR+'Failed to create Draft Account in Zuora';
            errorStatus = true;
            updateOrder(orderId,errorMessage);
            return;
        } 
        if(String.isNotBlank(accId))
            startOrderDecomp(orderId, sfdcAccountId, accId);
        else {
            System.debug(FUNC_STR+'Failed to create Draft Account in Zuora ');
            errorMessage = FUNC_STR+'Failed to create Draft Account in Zuora';
            errorStatus = true;
            updateOrder(orderId,errorMessage);
            return;
        }
        //}
    }
    
    /**
* Helper method for deleting objects from Zuora
*
* @param zObjectType String defining the type of Zuora object to delete
* @param zIdsToDelete List of Strings for Zuora Ids of objects to delete
* @param zApi Zuora.ZApi used for making calls to Zuora. Assumes not null and already logged in
* @return Boolean whether or not objects were deleted successfully
**/
    public static Boolean deleteZObjects(String zObjectType, List<String> zIdsToDelete, Zuora.ZApi zApi) {
        final String FUNC_STR = DEBUG_STR+'deleteZObjects: ';
        
        Boolean zDeleteSuccess = false;
        String zDeleteErrorMessage = '';
        List<Zuora.ZApi.DeleteResult> deleteResults = new List<Zuora.ZApi.DeleteResult>();
        
        if (String.isNotBlank(zObjectType) && zIdsToDelete != null && zIdsToDelete.size() > 0 && zApi != null) {
            try {
                if(!Test.isRunningTest()){
                    deleteResults = zApi.zDelete(zObjectType, zIdsToDelete);
                }else{
                    deleteResults = new List<Zuora.ZApi.DeleteResult>();
                    Zuora.ZApi.DeleteResult deleteResult = new Zuora.ZApi.DeleteResult();
                    deleteResult.Success = true;
                    deleteResult.Errors = null;
                    deleteResults.add(deleteResult);
                }   
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Error occurred trying to delete object in Zuora: '+ex.getMessage());
                zDeleteErrorMessage = ex.getMessage();
                zDeleteSuccess = false;
                return zDeleteSuccess;
            }
            
            if (deleteResults.size() > 0) {
                Zuora.ZApi.DeleteResult deleteResult = deleteResults[0];
                zDeleteSuccess = (deleteResult.Success != null) ? deleteResult.Success : false;
                zDeleteErrorMessage = (deleteResult.Errors != null && deleteResult.Errors.size() > 0 && String.isNotBlank((String)deleteResult.Errors[0].getValue('Message'))) ? (String)deleteResult.Errors[0].getValue('Message') : '';
            } else {
                System.debug(FUNC_STR+'Error occurred trying to delete payment method in Zuora. DeleteResult list is empty');
                zDeleteErrorMessage = (String.isBlank(zDeleteErrorMessage)) ? 'DeleteResult list is empty' : zDeleteErrorMessage;
                zDeleteSuccess = false;
                return zDeleteSuccess;
            }
        } else {
            System.debug(FUNC_STR+'Invalid params. zObjectType: '+zObjectType+', zIdsToDelete: '+zIdsToDelete+', zApi: '+zApi);
        }
        
        System.debug(FUNC_STR+'Delete Status: '+zDeleteSuccess+', Delete error message: '+zDeleteErrorMessage);
        return zDeleteSuccess;
    }
    
    public class CommonException extends Exception {}
    
}