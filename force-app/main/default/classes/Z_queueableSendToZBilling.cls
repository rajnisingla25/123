/*
 * Description: This class is executed from the Z_scheduleProcessInputAndSendToZBilling and sends Zuora Quotes to Zuora
 * The status from Zuora is recorded on the Order Item, for success or failures
 */
global class Z_queueableSendToZBilling implements Queueable, Database.AllowsCallouts {
    String orderId;
    Set<OrderItem> orderItems;
    List<zqu__Quote__c> quotes;
    List<String> quoteIds;

    //Error message used when Quote is missing charges / amendments
    private static final String ERR_INVALID = 'Empty quote created due to no changes found or Zuora Quote creation process failed. ';

    //Used for debugging purposes
    private static final String DEBUG_STR = 'Z_queueableSendToZBilling ';
 
    /**
     * Constructor - Gathers all Zuora Quotes under specified Order Id
     * @param  orderId Id of Order to grab Quotes for
     */
    public Z_queueableSendToZBilling(String orderId) {
        final String FUNC_STR = DEBUG_STR+'constructor 1: ';
        System.debug(FUNC_STR+'Starting constructor 1');

        this.orderId = orderId;

        //Retrieve Order Items for later retrieval of Quotes
        this.orderItems = new Set<OrderItem>([SELECT Id 
                FROM OrderItem 
                WHERE orderId = :orderId]);

        //Retrieve Quotes from OIs
        this.quotes = [SELECT Id, Charge_To_Be_Updated__c, zqu__ZuoraAccountId__c, zqu__SubscriptionType__c 
                FROM zqu__Quote__c 
                WHERE zqu__Status__c='New' AND Order_Product__c IN :orderItems];
    }

    /**
     * Constructor - Gathers all Zuora Quotes from Id list
     * @param  orderId         Id of Order
     * @param  quotesToProcess List of Zuora Quote Ids
     */
    public Z_queueableSendToZBilling(String orderId, List<String> quotesToProcess) {
        final String FUNC_STR = DEBUG_STR+'constructor 2: ';
        System.debug(FUNC_STR+'Starting constructor 2');

        this.orderId = orderId;

        //Retrieve Quotes
        this.quoteIds = quotesToProcess;
        this.quotes = [SELECT Id, Charge_To_Be_Updated__c, zqu__ZuoraAccountId__c, zqu__SubscriptionType__c 
                FROM zqu__Quote__c 
                WHERE zqu__Status__c='New' AND Id IN :quotesToProcess];
    }

    /**
     * Main execution method - Submits quotes to zbilling
     * @param  qc QueueableContext
     */
    global void execute(QueueableContext qc) { 
        final String FUNC_STR = DEBUG_STR+'execute: ';
        System.debug(FUNC_STR+'Sending quotes to Z-Billing: '+quoteIds.size());
       // sendtoZbilling(quoteIds);
       try{
        sendtoZbilling(quoteIds);
        }catch(Exception e){
            for(string quoteId:quoteIds){
                OrderDecompController.UpdateOrderItemswithmultipleQuoteIdsfailure(quoteIds,e.getMessage());
            }
        }
    }

    /**
     * Updates Order Status with Success or all error messages from Order Items
     * @param orderId       Id of Order to update
     * @param allOrderItems List of OrderItems to check for errors against
     */
    public static void updateOrderStatus(String orderId, List<OrderItem> allOrderItems) {
        final String FUNC_STR = DEBUG_STR+'updateOrderStatus: ';
        System.debug(FUNC_STR+'Starting updateOrderStatus with orderId: '+orderId+', allOrderItems: '+allOrderItems);

        Boolean orderItemsSuccess = true;
        Set<String> errorsSet = new Set<String>();

        //Add all errors to errorsSet and set success
        for(OrderItem orderItem1 : allOrderItems) {
            if (orderItem1.Zuora_Comment__c != 'Sent to Z-Billing') {
                orderItemsSuccess = false;
                errorsSet.add(orderItem1.Zuora_Comment__c);
            }
        }

        OrderDecompController.updateOrder(orderId, orderItemsSuccess, errorsSet);
    }

    /**
     * Update Credit Quotes that require cancellation to not be picked up again and update Order Item to create Cancellation Quote
     * @param quotesThatRequireCancellation List of Zuora Quotes that previouslu required a cancellation quote to be created
     */
    public static void updateQuotesThatRequireCancellation(List<zqu__Quote__c> quotesThatRequireCancellation) {
        final String FUNC_STR = DEBUG_STR+'updateQuotesThatRequireCancellation: ';
        System.debug(FUNC_STR+'Starting updateQuotesThatRequireCancellation with quotes: '+quotesThatRequireCancellation);

        Set<OrderItem> orderItemsToUpdateThatRequireCancellation = new Set<OrderItem>();
        for (zqu__Quote__c quoteThatRequireCancellation : quotesThatRequireCancellation) {
            //Change chancel with credit flag so quote isn't picked up again
            quoteThatRequireCancellation.cancelWithCreditFlag__c = false;

            //Update Order Item so it knows to be picked up for cancellation
            OrderItem orderItemToUpdate = new OrderItem();
            orderItemToUpdate.Id = quoteThatRequireCancellation.Order_Product__c;
            orderItemToUpdate.Zuora_Status__c = 'Pending Cancellation';
            orderItemsToUpdateThatRequireCancellation.add(orderItemToUpdate);
        }

        if (!orderItemsToUpdateThatRequireCancellation.isEmpty()) {
            System.debug(FUNC_STR+'Updating '+orderItemsToUpdateThatRequireCancellation.size()+' Order Items');
            update new List<OrderItem>(orderItemsToUpdateThatRequireCancellation);
        }
        if (!quotesThatRequireCancellation.isEmpty()) {
            System.debug(FUNC_STR+'Updating '+quotesThatRequireCancellation.size()+' Quotes');
            update quotesThatRequireCancellation;
        }
    }

    /**
     * Send To Z-Billing Process with Quotes. Updates the related Order Item with errors, if any.
     * @param quoteIds List of Zuora Quotes to submit to ZBilling
     */
    public static void sendtoZbilling(List<String> quoteIds) {
        final String FUNC_STR = DEBUG_STR+'sendtoZbilling: ';
        System.Debug(FUNC_STR+'In sendtoZbilling method with quoteIds: '+quoteIds);

        List<zqu__Quote__c> quotesList = [SELECT zqu__Account__c,zqu__ZuoraAccountID__c,zqu__Status__c,Order_Product__c,Order_Product__r.Id,Order_Product__r.OrderId 
                FROM zqu__Quote__c 
                WHERE Id IN :quoteIds];
        Map<Id,zqu__Quote__c> quotesMap = new Map<Id,zqu__Quote__c>(quotesList);
/*
        String sfdcAccountId = quotesList[0].zqu__Account__c;
        String zBillingAccountId = quotesList[0].zqu__ZuoraAccountID__c;
        System.debug(FUNC_STR+'Retrieve sfdcAccountId: '+sfdcAccountId+', zBillingAccountId: '+zBillingAccountId);

        //Create Quote requests
        List<zqu.zQuoteUtil.ZbillingQuoteCollection> quotestoSend = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();   
        for(String qId : quoteIds) {
            zqu.zQuoteUtil.ZbillingQuoteCollection QOS = new zqu.zQuoteUtil.ZBillingQuoteCollection();
            zqu.ZQuoteUtil.ZBillingQuoteRequest billingRequest = new zqu.ZQuoteUtil.ZBillingQuoteRequest();
                
            billingRequest.effectiveDate = Date.Today();
            billingRequest.sfdcQuoteId = qId;
            billingRequest.enableAccountAutoPay = false;
            billingRequest.generateInvoice = false;
                
            QOS.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();   
            QOS.quoteRequests.add(billingRequest);    
            QOS.sfdcAccountId = sfdcAccountId;
            QOS.zAccountId = zBillingAccountId;
                
            quotestoSend.add(QOS);
        }
*/

        //Create Quote requests
        List<zqu.zQuoteUtil.ZbillingQuoteCollection> quotestoSend = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();   
        for(zqu__Quote__c zQuote : quotesList) {
            zqu.zQuoteUtil.ZbillingQuoteCollection QOS = new zqu.zQuoteUtil.ZBillingQuoteCollection();
            zqu.ZQuoteUtil.ZBillingQuoteRequest billingRequest = new zqu.ZQuoteUtil.ZBillingQuoteRequest();
                
            billingRequest.effectiveDate = Date.Today();
            billingRequest.sfdcQuoteId = zQuote.Id;
            billingRequest.enableAccountAutoPay = false;
            billingRequest.generateInvoice = false;
                
            QOS.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();   
            QOS.quoteRequests.add(billingRequest);   
            System.debug(FUNC_STR+'Retrieve sfdcAccountId: '+zQuote.zqu__Account__c+', zBillingAccountId: '+zQuote.zqu__ZuoraAccountID__c); 
            QOS.sfdcAccountId = zQuote.zqu__Account__c;
            QOS.zAccountId = zQuote.zqu__ZuoraAccountID__c;
                
            quotestoSend.add(QOS);
        }
        System.debug(FUNC_STR+'Created '+quotestoSend.size()+' quote requests: '+quotestoSend);
            
        //Submit quote requests to Zuora and retrieve results
        List<zqu.zQuoteUtil.zBillingResult> results;
        if(!Test.isRunningTest()) {
            //Retry Logic 3x
            try {
                System.debug(FUNC_STR+'Submitting quotes to Zuora, attempt 1');
                results = zqu.zQuoteUtil.sendToZBilling(quotestoSend);
            } catch(Exception ex) {
                System.debug(FUNC_STR+'Exception occurred during submission 1: '+ex.getMessage());
                if (ex.getMessage().containsIgnoreCase('Read timed out')) {
                    try {
                        System.debug(FUNC_STR+'Submitting quotes to Zuora, attempt 2');
                        results = zqu.zQuoteUtil.sendToZBilling(quotestoSend);
                    } catch(Exception ex1) {
                        System.debug(FUNC_STR+'Exception occurred during submission 2: '+ex.getMessage());
                        if (ex.getMessage().containsIgnoreCase('Read timed out')) {
                            System.debug(FUNC_STR+'Submitting quotes to Zuora, attempt 3');
                            results = zqu.zQuoteUtil.sendToZBilling(quotestoSend);
                        } else {
                            throw ex1;
                        }
                    }
                } else {
                    throw ex;
                }
            }
        } else {
            results = new List<zqu.zQuoteUtil.zBillingResult>();

            //Add a quote request
            zqu.zQuoteUtil.zBillingResult result = new zqu.zQuoteUtil.zBillingResult();
            result.sfdcQuoteId = quoteIds[0];
            result.success = true;
            result.message = '';
            results.add(result);

            //Add a bad request
            zqu.zQuoteUtil.zBillingResult result2 = new zqu.zQuoteUtil.zBillingResult();
            result2.sfdcQuoteId = quoteIds[0];
            result2.success = false;
            result2.message = 'lock competition';
            results.add(result2);
        }

        //Update Quote and OrderItem Status
        List<String> quoteIdsToUpdate = new List<String>();
        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        List<OrderItem> oiListToUpdate = new List<OrderItem>();
        List<OrderItem> oiListToUpdate_final = new List<OrderItem>();
        list<string> lockedQuoteIdsList = new list<string>();
        set<id> orderItemIds = new set<id>(); 
        List<system_logs__c> system_logs_list = new List<system_logs__c>();
        for (zqu.zQuoteUtil.zBillingResult result : results) {
            System.debug(FUNC_STR+'Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message );
            
            if (result.success == true) {
                Boolean errorStatus = false;
                String errorMessage = 'Sent to Z-Billing';
               
                //Update Quote status
                quoteIdsToUpdate.add(result.sfdcQuoteId);
                zqu__Quote__c relQuote = quotesMap.get(result.sfdcQuoteId);
                if (relQuote != null) {
                    relQuote.zqu__Status__c = 'Sent to Z-Billing';
                    quotesToUpdate.add(relQuote);

                    //Set Zuora Comment and Zuora Status on OI without performing the actual update (performed later)
                    OrderItem oiToUpdate = OrderDecompController.updateOrderItem(relQuote.Order_Product__c, errorStatus, errorMessage, false);
                    if (oiToUpdate != null) {
                        oiListToUpdate.add(oiToUpdate);
                    } 
                }
            } 
            else if(result.message.contains('lock competition')){
                // prepare locked quotes list-->  process - 276
                lockedQuoteIdsList.add(result.sfdcQuoteId);
                Boolean errorStatus = false;
                string errorMessage = 'Order will be reprocessed in 5 minuts';
                zqu__Quote__c relQuot = quotesMap.get(result.sfdcQuoteId);
                 if (relQuot!= null) {
                    //Set Zuora Comment and Zuora Status on OI without performing the actual update (performed later)
                    OrderItem oiToUpdate = OrderDecompController.updateOrderItem(relQuot.Order_Product__c, errorStatus, errorMessage, false);
                    if (oiToUpdate != null) {
                        oiListToUpdate.add(oiToUpdate);
                    } 
                }
            }
            else {
                Boolean errorStatus = true;
                String errorMessage = (result.message == null) ? '' : result.message;
                errorMessage = errorMessage.contains('is not valid') ? ERR_INVALID + errorMessage : errorMessage;
                errorMessage = 'Unable to Process Z-Billing '+ errorMessage;

                //Update Quote's OrderItem to failure
                zqu__Quote__c relQuote = quotesMap.get(result.sfdcQuoteId);
                if (relQuote != null) {
                        OrderDecompController.updateOrderItem(relQuote.Order_Product__c, errorStatus, errorMessage);
                }
            }  
            
            string errormessage_log='';
            errormessage_log = result.success ? 'Success' : 'failed';
            system_logs__c logs = new system_logs__c();
            logs.Record_ID__c = result.sfdcQuoteId;
            logs.Object_Type__c = 'zqu__Quote__c';
            logs.Message__c = 'Sent to Z-Billing result was '+errormessage_log;
            system_logs_list.add(logs);
        }
        
        if(!system_logs_list.isempty()){
            insert system_logs_list;
        }
        if(lockedQuoteIdsList != null && lockedQuoteIdsList.size() > 0){
            
            //scheduleErrorQuoteScheduler(integer seconds, list<string> lockedQuotesList, string sfdcAccountId, string zBillingAccountId){
            if(quotesList != null && quotesList.size() > 0)
            Z_ErrorQuoteScheduler.scheduleErrorQuoteScheduler(180, lockedQuoteIdsList, quotesList[0].Order_Product__r.OrderId, quotesList[0].zqu__Account__c , quotesList[0].zqu__ZuoraAccountID__c ); 
            
        }
        
        if (!quotesToUpdate.isEmpty()) {
        System.debug(FUNC_STR+'Updating '+quotesToUpdate.size()+' Quotes: '+quotesToUpdate);
        // update quotesToUpdate;
            try{
            update quotesToUpdate; 
            }catch(Exception ex) { 
                system_logs_list.clear();
                for(zqu__Quote__c quote : quotesToUpdate){
                    system_logs__c logs = new system_logs__c();
                    logs.Record_ID__c = quote.Id;
                    logs.Object_Type__c = 'zqu__Quote__c';
                    logs.Message__c = 'Unable to update quote due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString();
                    system_logs_list.add(logs);
                }   
                if(!system_logs_list.isempty()){
                    insert system_logs_list;
                }           
                
            }  
        }
        if (!oiListToUpdate.isEmpty()) {
            System.debug(FUNC_STR+'Updating '+oiListToUpdate.size()+' Order Items: '+oiListToUpdate);
            for(OrderItem oi:oiListToUpdate){
                if(!orderItemIds.contains(oi.id)){
                    oiListToUpdate_final.add(oi);
                    orderItemIds.add(oi.id);
                    if(Test.isRunningTest()){
                       oiListToUpdate_final.add(oi);               
                    }
                }
            }
            
             try{
            update oiListToUpdate_final;
           }catch(Exception ex) { 
                system_logs_list.clear();
                for(OrderItem inloop : oiListToUpdate_final){
                    system_logs__c logs = new system_logs__c();
                    logs.Record_ID__c = inloop.Id;
                    logs.Object_Type__c = 'OrderItem';
                    logs.Message__c = 'Unable to update OrderItem due to error:' + ex.getMessage() + ' . Stacktrace: ' + ex.getStackTraceString();
                    system_logs_list.add(logs);
                }
               if(!system_logs_list.isempty()){
                    insert system_logs_list;
                }  
                    
        }//If ending
               
    }
 }
}