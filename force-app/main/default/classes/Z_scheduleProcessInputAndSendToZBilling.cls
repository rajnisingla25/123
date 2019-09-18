/*
Description: This class is scheduled to processing any order items that have not been processed in previous steps, 
then scheduled again to kick off the Zuora Sending process.
This class schedules itself to separate itself from any future methods that need to be first completed.
Each step below is broken up in another schedule
1. Queue up order items 50 at a time that are remaining and reschedule as needed
2. Check Queued jobs are completed and reschedule as needed
3. Updating Order Item's Quotes 40 at a time that need to be 'Updated' and reschedule as needed
4. Quotes are sent to Zuora 20 at a time and rescheduled as needed
5. The Order is updated with the status from the Order Items
*/
global with sharing class Z_scheduleProcessInputAndSendToZBilling implements Schedulable, Database.AllowsCallouts {
    List<String> jobIDList;
    List<OrderItem> orderItems;
    String sfdcAccountId;
    String zBillingAccountId;
    String orderId;
    List<String> quoteIds;
    boolean quotesProcess = false;
    Integer attempt = 0;

    //Used for debugging purposes
    private static final String DEBUG_STR = 'Z_scheduleProcessInputAndSendToZBilling: ';

    public Z_scheduleProcessInputAndSendToZBilling(List<String> jobIDList, String orderId, List<OrderItem> orderItems, String sfdcAccountId, String zBillingAccountId, Integer attempt) {
        final String FUNC_STR = DEBUG_STR+'constructor 1: ';
        System.debug(FUNC_STR+'Starting constructor 1');
        this.jobIDList = jobIDList;
        this.orderItems = orderItems;
        this.orderId = orderId;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
        this.attempt = attempt+1;
    }

    public Z_scheduleProcessInputAndSendToZBilling(String orderId, List<String> quoteIds, String sfdcAccountId, String zBillingAccountId) {
        final String FUNC_STR = DEBUG_STR+'constructor 2: ';
        System.debug(FUNC_STR+'Starting constructor 2');
        this.orderId = orderId;
        this.quoteIds = quoteIds;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
        quotesProcess = true;
    }

    global void execute(SchedulableContext sc) {
        final String FUNC_STR = DEBUG_STR+'execute: ';
        System.debug(FUNC_STR+'Starting execute');
        updateOrderToProcessing();
            

        //Begin Send To Z-Billing steps if QuotesProcess is true
        if (quotesProcess) {
            System.debug(FUNC_STR+'Sending quoteIds: '+quoteIds);
            sendQuotes(quoteIds);
            return;
        }

        //If remaining Order Items to process, queue up to 50 Order Items
        //If more than 50, reschedule this class with the remaining Order Items
        List<OrderItem> remainingOrderItems = new List<OrderItem>();
        System.debug(FUNC_STR+'orderItem.size()::' + orderItems.size());

        if (orderItems.size() > 0) {
            for(Integer a = 0; a < (orderItems.size() > 50 ? 50 : orderItems.size()); a++){
                System.debug(FUNC_STR+'Calling Z_queueableProcessInput');
                jobIDList.add(String.valueOf(System.enqueueJob(new Z_queueableProcessInput(orderId, orderItems[a], sfdcAccountId, zBillingAccountId))));
            }

            //Schedule any remaining Order Items and Send To Z-Billing
            if (orderItems.size() > 50) {
                for(Integer b = 50; b < orderItems.size(); b++){
                    remainingOrderItems.add(orderItems[b]);
                }
            }

            Integer delaySendToZBillingProcess = orderItems.size() > 0 && remainingOrderItems.size() == 0 ? 300 : 30;
            scheduleProcessInputAndSendToZBilling(delaySendToZBillingProcess, jobIDList, orderId, remainingOrderItems, sfdcAccountId, zBillingAccountId);
        //Else, begin remaining processes
        } else {
            //Check Apex jobs are completed and reschedule this class if needed
            List<AsyncApexJob> existingJobInfoList = [SELECT Status,NumberOfErrors 
                    FROM AsyncApexJob 
                    WHERE Id in :jobIDList and Status != 'Aborted' and Status != 'Completed' and Status != 'Failed'];

            if (existingJobInfoList.size() > 0){
                remainingOrderItems = new List<OrderItem>();
                scheduleProcessInputAndSendToZBilling(60, jobIDList, orderId, remainingOrderItems, sfdcAccountId, zBillingAccountId);   
                return;
            }

            List<OrderItem> allOrderItems = [SELECT Id, Zuora_Status__c,Zuora_Payment_Method__c,Promotion__c, Zuora_Comment__c, CampaignID__c, Contractedimpressions__c, PricePerImpressionSold__c, 
                    DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, 
                    Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, 
                    Billing_Period__c, Asset__r.Product2.RealSuite_Family__c, Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, 
                    Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                    FROM OrderItem 
                    WHERE orderId = :orderId];
            System.debug(FUNC_STR+'size of allOrderItems: ' + allOrderItems.size());

            //Check OrderDecompController/Z_queueableProcessInput processes are done and reschedule if needed, up to 3 attempts with 5 minutes delay
            Boolean orderItemsFinished = true;
            for(OrderItem orderItem1 : allOrderItems){
                if (String.isBlank(orderItem1.Zuora_Status__c) || orderItem1.Zuora_Status__c == 'Processing'){
                    orderItemsFinished = false;
                }
            }

            if (!orderItemsFinished && attempt < 3){
                scheduleProcessInputAndSendToZBilling(300, jobIDList, orderId, remainingOrderItems, sfdcAccountId, zBillingAccountId, attempt); 
                return;
            }

            //Update quotes that have pending Quote Charge Metric changes
            List<String> listofQuoteIdsToUpdate = new List<String>();
            List<zqu__Quote__c> quotes = [SELECT Id, Charge_To_Be_Updated__c, zqu__ZuoraAccountId__c, zqu__SubscriptionType__c 
                    FROM zqu__Quote__c 
                    WHERE zqu__Status__c='New' AND Order_Product__c IN :allOrderItems];
            System.debug(FUNC_STR+'size of quotes: ' + quotes.size());
            for(zqu__Quote__c q : quotes) {
                if(q.Charge_To_Be_Updated__c == true && (q.zqu__SubscriptionType__c == 'Renew Subscription' || q.zqu__SubscriptionType__c == 'Amend Subscription')){      
                    listofQuoteIdsToUpdate.add(q.Id);
                }
            }

            //Update only 40 quotes at a time and re-schedule this class if more
            System.debug(FUNC_STR+'size of listOfQuoteIdsToUpdate: ' + listOfQuoteIdsToUpdate.size());
            if(listofQuoteIdsToUpdate.size() > 0) {
                for(Integer a = 0; a < (listofQuoteIdsToUpdate.size() > 40 ? 40 : listofQuoteIdsToUpdate.size()); a++) {
                    System.debug(FUNC_STR+'Updating Charge');
                    OrderDecompController.updateCharge(listofQuoteIdsToUpdate[a]); 
                }
                //Re-Schedule current process to update reminaing charges and start Send To Z-Billing process after update charges completion
                scheduleProcessInputAndSendToZBilling(30, jobIDList, orderId, remainingOrderItems, sfdcAccountId, zBillingAccountId);   
                return;
            }

            //Start Send To Z-Billing process
            //Check order items are success before sending any of them
            Boolean orderItemsSuccess = true;
            Boolean Sendsuccessorderitemstozuora = false;
            Set<String> errorsSet = new Set<String>();
            for(OrderItem orderItem1 : allOrderItems) {
                if (orderItem1.Zuora_Status__c != 'Success'){
                    orderItemsSuccess = false;
                    errorsSet.add(orderItem1.Zuora_Comment__c);
                    //CRM-2621 change the process to send success zquotes.
                }else if(orderItem1.Zuora_Status__c == 'Success'){
                  Sendsuccessorderitemstozuora = true;
                }
                //CRM-2621 - end
            }
            if(!orderItemsSuccess){
                //Mark order as failed with reason
                OrderDecompController.updateOrder(orderId, false, errorsSet);
            }

            if (Sendsuccessorderitemstozuora) {
                //Queue quotes - queueable process will send 20 quotes at a time
                List<zqu__Quote__c> quotesToSend = new List<zqu__Quote__c>([SELECT Id FROM zqu__Quote__c WHERE zqu__Status__c='New' AND Order_Product__r.Zuora_Status__c = 'Success' and Order_Product__c IN :allOrderItems]);
                sendQuotes(new List<String>(new Map<String, zqu__Quote__c>(quotesToSend).keySet()));
            } 

            
        } 
    }

    //Begin Send To Z-Billing process
    private void sendQuotes(List<String> quotesToSendList) {
       List<system_logs__c> system_logs_list = new List<system_logs__c>();
        final String FUNC_STR = DEBUG_STR+'sendQuotes: ';
        List<OrderItem> allOrderItems = [SELECT Id, Zuora_Status__c,Zuora_Payment_Method__c, Promotion__c,Zuora_Comment__c, CampaignID__c, Contractedimpressions__c, PricePerImpressionSold__c, DeliveredImpressions__c, 
                DeliveredImpressionsUpdatedDate__c, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, Subscription_Start_Date__c, Extended_Net_Price__c, 
                Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c, Billing_Period__c, Cancellation_Date__c,Buyout_Amount__c, 
                Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                FROM OrderItem WHERE orderId = :orderId];
        if (quotesToSendList.size() == 0) {
            Z_queueableSendToZBilling.updateOrderStatus(orderId, allOrderItems);
        }

        //Queue up quotes to Send To Z-Billing
        List<String> listofQuoteIdsToSend = new List<String>();
        Integer quoteCount = (quotesToSendList.size() > 20 ? 20 : quotesToSendList.size());
        for(Integer a = 0; a < quoteCount; a++) {
            listofQuoteIdsToSend.add(quotesToSendList[a]);
        }
        for(string quote_id : listofQuoteIdsToSend){
            system_logs__c logs = new system_logs__c();
            logs.Record_ID__c = quote_id;
            logs.Object_Type__c = 'zqu__Quote__c';
            logs.Message__c = 'Quote was submitted for Z-Billing';
            system_logs_list.add(logs);
        }
        
        if(!system_logs_list.isEmpty()){
            insert system_logs_list;
        }
        
        if (!listofQuoteIdsToSend.isEmpty()) {
            String scheduledJobId = System.enqueueJob(new Z_queueableSendToZBilling(orderId, listofQuoteIdsToSend));
            System.debug(FUNC_STR+'Queueing sendToZbilling JobId' + scheduledJobId);
        }

        //If any remaining Quotes to send, reschedule this class with remaining Quotes
        List<String> remainingQuotesToSend = new List<String>();
        if (quotesToSendList.size() > 20){
            for(Integer b = 20; b < quotesToSendList.size(); b++){
                remainingQuotesToSend.add(quotesToSendList[b]);
            }
        }

        Boolean quotesToSend = listofQuoteIdsToSend.size() > 0 ? true : false;
        Boolean additionalQuotesToSend = remainingQuotesToSend.size() > 0 ? true : false;   

        //ReQueue Send To Z-Billing Process, if any remaining
        if(additionalQuotesToSend){
            System.debug(FUNC_STR+'Requeueing quotes to Z-Billing: '+remainingQuotesToSend);
            scheduleProcessInputAndSendToZBilling(1, orderId, remainingQuotesToSend, sfdcAccountId, zBillingAccountId); 
        }

        //If no quotes remaining to process
        //Check for cancellation credit quotes, and reschedule this class to process remaining cancellation quotes
        //Update Order if finished
        if(!additionalQuotesToSend) {
            List<zqu__Quote__c> quotesThatRequireCancellation = [SELECT Id, Order_Product__c, zqu__Account__c, zqu__ZuoraAccountID__c 
                    FROM zqu__Quote__c 
                    WHERE zqu__Status__c='Sent to Z-Billing' AND cancelWithCreditFlag__c = true AND zqu__SubscriptionType__c != 'Cancel Subscription' AND Order_Product__c IN :allOrderItems];
            if(!quotesThatRequireCancellation.isEmpty()) {
                //Pull SFDC and Zuora Account Ids from first quote
                String sfdcAccountId = quotesThatRequireCancellation[0].zqu__Account__c;
                String zBillingAccountId = quotesThatRequireCancellation[0].zqu__ZuoraAccountID__c;

                //Update Quotes to no longer require cancellation
                Z_queueableSendToZBilling.updateQuotesThatRequireCancellation(quotesThatRequireCancellation);
               //CRM-3399
                //Reschedule class in 5 minutes to process cancellations
                List<OrderItem> orderItemsToCreateCancellation = [SELECT Id, Promotion__c,Zuora_Status__c, Zuora_Comment__c, CampaignID__c, Contractedimpressions__c, PricePerImpressionSold__c, 
                        DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c, quantity, Start_Date__c,Asset__c,End_Date__c, Term_Start_Date__c, 
                        Subscription_Start_Date__c, Extended_Net_Price__c, Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, 
                        Line_Type__c, Billing_Period__c,Asset__r.Product2.RealSuite_Family__c, Cancellation_Date__c,Buyout_Amount__c, Commerce_Group__c, Credit_Amount__c, Pricebookentry.Product2Id, 
                        Asset__r.Zoura_Id__c,Cancellation_Effective_Date__c 
                        FROM OrderItem WHERE Zuora_Status__c = 'Pending Cancellation' AND orderId = :orderId];
                Z_scheduleProcessInputAndSendToZBilling.scheduleProcessInputAndSendToZBilling(300, new List<String>(), orderId, orderItemsToCreateCancellation, sfdcAccountId, zBillingAccountId); 
                return;
            }

            //Update Order Status if no quotes recently sent, else delay and update later (due to future methods)
            if (quotesToSend){
                scheduleProcessInputAndSendToZBilling(60, orderId, new List<String>(), sfdcAccountId, zBillingAccountId); 
                return;
            }
        }
    }

    private void updateOrderToProcessing() {
        final String FUNC_STR = DEBUG_STR+'updateOrderToProcessing: ';
        Order orderToUpdate = new Order();
        orderToUpdate.Id = orderId;
        orderToUpdate.Zuora_Status__c = 'Processing';
        update orderToUpdate;
    }

    public static void scheduleProcessInputAndSendToZBilling(Integer seconds, List<String> jobIDList, String orderId, List<OrderItem> orderItemsToProcess, String sfdcAccountId, String zBillingAccountId) {
        final String FUNC_STR = DEBUG_STR+'scheduleProcessInputAndSendToZBilling 1: ';
        scheduleProcessInputAndSendToZBilling(seconds, jobIDList, orderId, orderItemsToProcess, sfdcAccountId, zBillingAccountId, 0);
    }

    public static void scheduleProcessInputAndSendToZBilling(Integer seconds, List<String> jobIDList, String orderId, List<OrderItem> orderItemsToProcess, String sfdcAccountId, String zBillingAccountId, Integer attemptRetryNumber) {
        final String FUNC_STR = DEBUG_STR+'scheduleProcessInputAndSendToZBilling 2: ';
        DateTime now = datetime.now().addSeconds(seconds);
        String scheduledDateTime = '';
        scheduledDateTime += now.second();
        scheduledDateTime += ' ' + now.minute();
        scheduledDateTime += ' ' + now.hour();
        scheduledDateTime += ' ' + now.day();
        scheduledDateTime += ' ' + now.month();
        scheduledDateTime += ' ' + '?';
        scheduledDateTime += ' ' + now.year();

        String scheduledTaskName = 'scheduleProcessInputAndSendToZBilling scheduled on ' + DateTime.now() + System.currentTimeMillis();
        String scheduledJobId = System.schedule(scheduledTaskName, scheduledDateTime, new Z_scheduleProcessInputAndSendToZBilling(jobIDList, orderId, orderItemsToProcess, sfdcAccountId, zBillingAccountId, attemptRetryNumber));
        System.debug(FUNC_STR+'####### INFO: Zuora Send scheduled in ' + seconds + ' seconds');
    }

    public static void scheduleProcessInputAndSendToZBilling(Integer seconds, String orderId, List<String> quoteIds, String sfdcAccountId, String zBillingAccountId) {
        final String FUNC_STR = DEBUG_STR+'scheduleProcessInputAndSendToZBilling 3: ';
        DateTime now = datetime.now().addSeconds(seconds);
        String scheduledDateTime = '';
        scheduledDateTime += now.second();
        scheduledDateTime += ' ' + now.minute();
        scheduledDateTime += ' ' + now.hour();
        scheduledDateTime += ' ' + now.day();
        scheduledDateTime += ' ' + now.month();
        scheduledDateTime += ' ' + '?';
        scheduledDateTime += ' ' + now.year();

        String scheduledTaskName = 'scheduleProcessInputAndSendToZBilling scheduled on ' + DateTime.now() + System.currentTimeMillis();
        String scheduledJobId = System.schedule(scheduledTaskName, scheduledDateTime, new Z_scheduleProcessInputAndSendToZBilling(orderId, quoteIds, sfdcAccountId, zBillingAccountId));
        System.debug(FUNC_STR+'####### INFO: Zuora Send scheduled in ' + seconds + ' seconds');
    }
}