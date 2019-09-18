/*
Description: This class processes Order Items and generates Zuora Quotes
Depending on the Order Item Type, various OrderDecompController methods are executed
*/
global class Z_queueableProcessInput implements Queueable, Database.AllowsCallouts {
    OrderItem OI;
    String orderId;
    String sfdcAccountId;
    String zBillingAccountId;
    String type;
    //List<OrderItem> orderItems;
    private static final String FREE_CREDIT_CPQ_ID  = 'CREDIT';
    private static final String BUYOUT_CPQ_ID       = 'CREDIT';
    private static final String COTERM_CPQ_ID       = 'COTERM';

    //Quote types to be used for zqu__SubscriptionType__c
    private static final String QUOTE_TYPE_NEW = 'New Subscription';
    private static final String QUOTE_TYPE_AMEND = 'Amend Subscription';
    private static final String QUOTE_TYPE_RENEW = 'Renew Subscription';
    private static final String QUOTE_TYPE_CANCEL = 'Cancel Subscription';
    
    //Line_Type__c values on OrderItem
    private static final String LINE_TYPE_CANCEL = 'Cancel';

    zqu__Quote__c newQuote;

    private boolean amend = false;
    private boolean addNext = false;
    private boolean add = false;
    private boolean Isrealsuite = false;
    Id amendOrderItemId;
    String amendQuoteId;
    String amendAssetId;
    String amendPrice;
    String addCpqId;
    String priceAdd;
    String addQuantity;
    String addOrderId;
    String addBillingPeriod;

    //Used for debugging purposes
    private static final String DEBUG_STR = 'Z_queueableProcessInput: ';

    global Z_queueableProcessInput(String orderId, OrderItem orderItem, String sfdcAccountId, String zBillingAccountId) {
        final String FUNC_STR = DEBUG_STR+'constructor1: ';
        System.debug(FUNC_STR+'Constructor 1 called with orderId: '+orderId+', orderItem: '+orderItem+', sfdcAccountId: '+sfdcAccountId+', zBillingAccountId: '+zBillingAccountId);
        this.OI = orderItem;
        this.orderId = orderId;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
    }

    global Z_queueableProcessInput(Id orderItemId, String quoteId, String assetId, String price, Boolean IsrealsuiteSub){
        final String FUNC_STR = DEBUG_STR+'constructor2: ';
        System.debug(FUNC_STR+'Constructor 2 called with orderItemId: '+orderItemId+', quoteId: '+quoteId+', assetId: '+assetId+', price: '+price);
        this.amend = true;
        this.amendOrderItemId = orderItemId;
        this.amendAssetId = assetId;
        this.amendQuoteId = quoteId;
        this.amendPrice = price;
        this.Isrealsuite = IsrealsuiteSub;

    }

    global Z_queueableProcessInput(Id orderItemId, String quoteId, String assetId, String price, String sfdcAccountId, String zBillingAccountId, String cpqId, String priceAdd, String billingPeriod, String quantity, String OrderId, boolean addCharge){
        final String FUNC_STR = DEBUG_STR+'constructor3: ';
        System.debug(FUNC_STR+'Constructor 3 called with orderItemId: '+orderItemId+', quoteId: '+quoteId+', assetId: '+assetId+', price: '+price+', sfdcAccountId: '+sfdcAccountId+
            ', zBillingAccountId: '+zBillingAccountId+', cpqId: '+cpqId+', priceAdd: '+priceAdd+', billingPeriod: '+billingPeriod+', quantity: '+quantity+
            ', OrderId: '+OrderId+', addCharge: '+addCharge);
        this.amend = true;
        this.amendOrderItemId = orderItemId;
        this.amendAssetId = assetId;
        this.amendQuoteId = quoteId;
        this.amendPrice = price;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
        this.add = addCharge;
        this.addCpqId = cpqId;
        this.priceAdd = priceAdd;
        this.addBillingPeriod = billingPeriod;
        this.addQuantity = quantity;
        this.addOrderId = OrderId;

        addNext = true;
    }

    //Process Order Line Item to create Quotes
    global void execute(QueueableContext sc) {
        final String FUNC_STR = DEBUG_STR+'execute: ';
        System.debug(FUNC_STR+'Starting execute');

        //This class is executed again with add flag true when charges are needed to be added to the Quote
        if (add){
            System.debug(FUNC_STR+'In add block');
            //OrderDecompController.addCharge(amendQuoteId, sfdcAccountId, zBillingAccountId, addCpqId, priceAdd, addBillingPeriod, addQuantity,addOrderId);
            OrderDecompController.addCharge(amendQuoteId, sfdcAccountId, zBillingAccountId, addCpqId, priceAdd, addBillingPeriod, addQuantity,amendOrderItemId);
            System.debug(FUNC_STR+'Updating order item to success and ending');
            //OrderDecompController.updateOrderItem(addOrderId, errorStatus, errorMessage);
            OrderDecompController.updateOrderItemSuccess(amendOrderItemId, '');
            return;
        }

        //This class is executed again with amend flag true when charges are needed to be amended on the Quote
        if (amend){
            System.debug(FUNC_STR+'In amend block');
            OrderDecompController.amend(amendOrderItemId, amendQuoteId, amendAssetId, amendPrice, Isrealsuite);
            
            if (addNext){
                System.debug(FUNC_STR+'In addNext block');
                amend(amendOrderItemId, amendQuoteId, amendAssetId, amendPrice, sfdcAccountId, zBillingAccountId, addCpqId, priceAdd, addBillingPeriod, addQuantity,addOrderId, true);
            }else{
                System.debug(FUNC_STR+'Updating order item to success and ending');
                //OrderDecompController.updateOrderItem(addOrderId, errorStatus, errorMessage);
                OrderDecompController.updateOrderItemSuccess(amendOrderItemId, '');
            }
            return;
        }

        System.debug(FUNC_STR+'Setting Order Item Type');
        setOrderItemType();
        if (type != null){
            System.debug(FUNC_STR+'Creating Quote');
            createQuote();
        }
        System.debug(FUNC_STR+'processInput completed for orderId '+orderId);
    }

    private void setOrderItemType(){
        final String FUNC_STR = DEBUG_STR+'setOrderItemType: ';
        System.debug(FUNC_STR+'Starting setOrderItemType');

        if(OI.Zuora_Status__c == 'Pending Cancellation'){
          type = 'Cancel Subscription';
        } 
        else if(OI.Line_Type__c == 'Add' || OI.Line_Type__c == 'Reinstate'){
          type = 'New Subscription';
        }
        else if(OI.Line_Type__c == 'Add TigerLead'){
          type = 'New Subscription';
        }  
        else if(OI.Line_Type__c == 'Coterm'){
          type = 'New Subscription';
        }    
        else if(OI.Line_Type__c == 'Cancel' && (OI.Credit_Amount__c == 0 || OI.Credit_Amount__c == null)){
          type = 'Cancel Subscription';
        }
        else if(OI.Line_Type__c == 'Amend'){
          type = 'Amend Subscription';
        }
        else if(OI.Line_Type__c == 'Credit'){
          type = 'Amend Subscription';
        }
        else if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0){
          type = 'Amend Subscription'; 
        }
        else if(OI.Line_Type__c == 'Renew'){
          type = 'Renew Subscription';
        } 
        else if(OI.Line_Type__c == 'Backout'){
          type = 'Cancel Subscription';
        }
        else if(OI.Line_Type__c == 'Buyout'){
            System.debug(FUNC_STR+'In buyout, creating new subscription quote');
            //Two quotes need to be created for Buyouts
            type = 'New Subscription';
            createQuote();

            type = 'Cancel Subscription';
        }
        else if(OI.Line_Type__c == 'Paid Extension'){
          type = 'Amend Subscription';
        }
        else if(OI.Line_Type__c == 'Free Extension'){
            System.debug(FUNC_STR+'No action on Zuora');
            OrderDecompController.updateOrderItemSuccess(OI.Id, 'No action on Zuora');
        }
        else{
            System.debug(FUNC_STR+'Invalid Order Line Type');
            OrderDecompController.updateOrderItemError(OI.Id, 'Invalid Order Line Type');
        }

        System.debug(FUNC_STR+'type has been set to: '+type);
    }

    //Create Zuora Quote process from Order Item
    private void createQuote(){
        //CRM-5242 Added mortgage accounts types. 
        Set<String> acctypes = new Set<String>{'Moving Company', 'Moving Corporation', 'Lender Parent','Lender Branch', 'Loan Officer'};
        final String FUNC_STR = DEBUG_STR+'createQuote: ';
        System.debug(FUNC_STR+'processInput for type: '+type+',SFDC AccountId '+sfdcAccountId);
        
        //test
        System.debug(FUNC_STR+'0');

        Decimal initialTerm;
        Decimal renewalTerm;
        if(OI.Override_Term__c > 0){
                initialTerm = OI.Override_Term__c;
                renewalTerm = OI.Override_Term__c;
        } else {
                initialTerm = Decimal.valueOf(OI.Contract_Term__c);
                renewalTerm = Decimal.valueOf(OI.Contract_Term__c);
        }

        //test
        System.debug(FUNC_STR+'1');
        
        String assetId = String.valueOf(OI.Asset__c);
        String price = String.valueOf(OI.Extended_Net_Price__c);
        String billingPeriod = OI.Billing_Period__c;
        String quantity = String.valueOf(OI.quantity);    
        zqu__Quote__c newQuote;
        Isrealsuite = OI.Asset__r.Product2.RealSuite_Family__c;
        //CRM-3109 
       //CRM-3089
       Boolean isrealrsuiteamend = false;
       if(Isrealsuite && (OI.Line_Type__c == 'Add' || OI.Line_Type__c == 'Amend')){
            //get the asset Id of the Parent Subscription
         List<Zuora__Subscription__c> subs = [SELECT Id, AssetID__c
                FROM Zuora__Subscription__c 
                WHERE Zuora__Account__c = :sfdcAccountId and Asset__r.Product2.RealSuite_Family__c = true
                and Zuora__Status__c  = 'Active' ORDER BY CreatedDate DESC LIMIT 1];
           if(subs != null && subs.size()>0){
               assetId = subs[0].AssetID__c;   
               type = 'Amend Subscription'; 
               isrealrsuiteamend =true;
            }
        }
        String cpqId;
        Date cancelDate;
        
        Account acc = [Select id, Consolidated_Billing_Flag__c,Type, Billing_Preference__c from Account where Id = :sfdcAccountId LIMIT 1];

        //test
        System.debug(FUNC_STR+'2');

        //Adding to handle tigerleads
        List<String> Product2Ids;
        Boolean hasTigerLead = false;
        
        if(!Test.isRunningTest()){
        
            List<Product2> OrderProduct2s = [Select Id, Fulfillment_ID__c from Product2 where Id = :OI.Pricebookentry.Product2Id];
        
            //test
            System.debug(FUNC_STR+'3');

            if(OrderProduct2s != null){
                for(Product2 product : OrderProduct2s){
                    if(product.Fulfillment_ID__c == 'Tigerleads'){
                        hasTigerLead = true;
                    }
                } 
            }

            //test
            System.debug(FUNC_STR+'4');
        }
        
        //test
        System.debug(FUNC_STR+'Type == ' + Type);

        if(Type == 'New Subscription'){

            //test
            System.debug(FUNC_STR+'New Subscription');

            if(OI.Line_Type__c == 'Add TigerLead' || OI.Line_Type__c == 'Add' || OI.Line_Type__c == 'Reinstate' || OI.Line_Type__c == 'Buyout' || OI.Line_Type__c == 'Coterm'){ 

                //Validate Order Line Input before creating Zuora Quote
                if(String.isBlank(billingPeriod)){
                    System.debug(FUNC_STR+'Billing Period is required');
                    OrderDecompController.updateOrderItemError(OI.Id, 'Billing Period is required');
                    return;
                }
                if(OI.Line_Type__c == 'Buyout'){
                    if(OI.Buyout_Amount__c==null){
                        System.debug(FUNC_STR+'Buyout Amount is required');
                        OrderDecompController.updateOrderItemError(OI.Id, 'Buyout Amount is required');
                        return;
                    }
                    price = String.valueOf(OI.Buyout_Amount__c);
                    cpqId = OI.Part_Number__c + BUYOUT_CPQ_ID;
                }
                else if(OI.Line_Type__c == 'Coterm'){
                    if(OI.Start_Date__c==null){
                        System.debug(FUNC_STR+'Start Date is required');
                        OrderDecompController.updateOrderItemError(OI.Id, 'Start Date is required');
                        return;
                    }

                    if(OI.Start_Date__c > Date.today()){
                        System.debug(FUNC_STR+'Start Date cannot be greater than todays date');
                        OrderDecompController.updateOrderItemError(OI.Id, 'Start Date cannot be greater than todays date');
                        return;
                    }
                    cpqId = OI.Part_Number__c + COTERM_CPQ_ID;
                }
                else{
                    cpqId = OI.Part_Number__c;
                }
                if(OI.Product_Type__c == 'Brand'){
                    cpqId = cpqId + 'BRAND';
                }

                if(acc.Billing_Preference__c == 'CC-Direct'){
                        cpqId = 'PAY' + cpqId;
                } else{
                        cpqId = 'INV' + cpqId;
                }

                if(OI.Billing_Period__c != 'Month' && OI.Billing_Period__c != 'Monthly' && OI.Billing_Period__c != null && OI.Billing_Period__c != '' && hasTigerLead == false){
                        cpqId = 'CT' + cpqId;
                } else if(acc.Consolidated_Billing_Flag__c == false && hasTigerLead == false){
                        cpqId = 'CT' + cpqId;
                }
                //CRM-3305 start commenting for prod deployment             
               if(acctypes.contains(acc.Type)){
                    cpqId = OI.Part_Number__c+'RECURRING';
                    System.debug('@@' +cpqId);
                }
                //CRM-3305 end
                String prpcId = OrderDecompController.getProductRatePlanId(cpqId);
                if(String.isBlank(prpcId)){
                    System.debug(FUNC_STR+'No associated Zuora Product found for CPQ ID: '+cpqId);
                    OrderDecompController.updateOrderItemError(OI.Id, 'No associated Zuora Product found for CPQ ID: '+cpqId);
                    return;
                }

                //Create Zuora Quote
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }

                OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, zBillingAccountId, cpqId, price, billingPeriod, quantity,OI.Id);
                List<Asset> aList = [Select Id From Asset Where Order_Line_Item__c = :OI.Id and Asset_Type__c = 'Parent' Limit 1];
                if(aList.size() > 0)
                    newQuote.AssetId__c = aList[0].Id;
                update newQuote;
            }
        } else if((Type == 'Cancel Subscription' || Type == 'Renew Subscription' || Type == 'Amend Subscription')) {
        
            //test
            System.debug(FUNC_STR+'Not New Subscription; OI.Line_Type__c = ' + OI.Line_Type__c + '; Type =' + Type);

            if(Type == 'Cancel Subscription'){
                    
                //test
                System.debug(FUNC_STR+'Cancel Subscription');

                //LEAP -8506 Preya Shah - Subscription cancellation date should be Cancellation Effective Date from OrderItem
                if (OI.Cancellation_Effective_Date__c == null){
                    System.debug(FUNC_STR+'Cancellation Effective Date is required');
                    OrderDecompController.updateOrderItemError(OI.Id, 'Cancellation Effective Date is required');
                    return;
                }
                cancelDate = OI.Cancellation_Effective_Date__c;
                System.debug(FUNC_STR+'cancelDate::' + cancelDate);
               

                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }

                OrderDecompController.cancel(newQuote.Id);
            } else if(OI.Line_Type__c == 'Renew'){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }
                //Note(Jeff): Made sync, can be changed to Future if needed
                OrderDecompController.renewal(newQuote.Id, zBillingAccountId, assetId, price,OI.Id);
            } else if(OI.Line_Type__c == 'Amend' || isrealrsuiteamend){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }
                //OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
               // OrderDecompController.amendforremoveandadd(OI, sfdcAccountId, newQuote.Id, assetId, price);
                
                amend(OI.Id, newQuote.Id, assetId, price, Isrealsuite);

                return;//let the queuable method update the order item
            } else if(OI.Line_Type__c == 'Paid Extension'){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }
                //OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
                amend(OI.Id, newQuote.Id, assetId, price, false);
               
                return;//let the queuable method update the order item
            } else if(OI.Line_Type__c == 'Credit') {
                if(OI.Credit_Amount__c == null) {
                    System.debug(FUNC_STR+'No Credit Amount populated for OrderItem ID: '+OI.Id);
                    OrderDecompController.updateOrderItemError(OI.Id, 'No Credit Amount populated for OrderItem ID: '+OI.Id);
                    return;
                }

                //test
                System.debug(FUNC_STR+'Line type = Credit');
                System.debug(FUNC_STR+'OI.Credit_Amount__c = ' + OI.Credit_Amount__c);

                Decimal newPrice = OI.Credit_Amount__c * -1;
                //test
                System.debug(FUNC_STR+'newPrice = ' + newPrice);

                String newPriceString = String.valueOf(newPrice);
                //test
                System.debug(FUNC_STR+'newPriceString = ' + newPriceString);

                cpqId = OI.Part_Number__c + FREE_CREDIT_CPQ_ID;
                if(OI.Product_Type__c == 'Brand'){
                    cpqId = cpqId + 'BRAND';
                }
                if(acc.Billing_Preference__c == 'CC-Direct'){
                        cpqId = 'PAY' + cpqId;
                }else{
                        cpqId = 'INV' + cpqId;
                }                
                  if(acctypes.contains(acc.Type)){
                    cpqId = OI.Part_Number__c+'CREDIT';
                    
                }
                //test
                System.debug(FUNC_STR+'11');

                String prpcId = OrderDecompController.getProductRatePlanId(cpqId);
                if(String.isBlank(prpcId)) {
                    System.debug(FUNC_STR+'No product rate plan charge found for CPQ ID: '+cpqId);
                    OrderDecompController.updateOrderItemError(OI.Id, 'No product rate plan charge found for CPQ ID: '+cpqId);
                    return;
                }

                //test
                System.debug(FUNC_STR+'22');
                
                //LEAP-9119 One time charges for Trubo expirations need to be backdated
                List<Zuora__Subscription__c> subs = [SELECT Zuora__SubscriptionEndDate__c
                    FROM Zuora__Subscription__c WHERE AssetID__c = :assetId ORDER BY CreatedDate DESC];
               
                Date creditAmendDate = System.today();
                creditAmendDate = (creditAmendDate >= subs[0].Zuora__SubscriptionEndDate__c) ? subs[0].Zuora__SubscriptionEndDate__c.addDays(-1) : creditAmendDate;

                //newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate, creditAmendDate);
                
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }

                //test
                System.debug(FUNC_STR+'33');

                //Submit Amendment Quote (can also add T&C)
                //OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
                amend(OI.Id, newQuote.Id, assetId, price, sfdcAccountId, zBillingAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id, false);
                return;
                //Create Cancellation Amendment in Zuora
                //OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, zBillingAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id);
            }

  
                
            //START: Cancel with Credit
            //Note(Jeff) - Added Type != 'Cancel Subscription' beacuse it should not apply to the 2nd quote that is a cancel
            if (type != QUOTE_TYPE_CANCEL && OI.Line_Type__c == LINE_TYPE_CANCEL && OI.Credit_Amount__c != null && OI.Credit_Amount__c != 0) {
                System.debug(FUNC_STR+'Cancel with credit use case. Line type: '+LINE_TYPE_CANCEL+', Credit Amount: '+OI.Credit_Amount__c);

                //Flip value of credit amount
                Decimal newPrice = OI.Credit_Amount__c * -1;
                String newPriceString = String.valueOf(newPrice);
                System.debug(FUNC_STR+'newPriceString: ' + newPriceString);

                cpqId = OI.Part_Number__c + FREE_CREDIT_CPQ_ID;
                if(OI.Product_Type__c == 'Brand'){
                    cpqId = cpqId + 'BRAND';
                }
                
                if (acc.Billing_Preference__c == 'CC-Direct') {
                    cpqId = 'PAY' + cpqId;
                } else {
                    cpqId = 'INV' + cpqId;
                }
                System.debug(FUNC_STR+'cpqId: '+cpqId);

                String prpcId = OrderDecompController.getProductRatePlanId(cpqId);
                if(String.isBlank(prpcId)) {
                    System.debug(FUNC_STR+'No product rate plan charge found for CPQ ID: '+cpqId);
                    OrderDecompController.updateOrderItemError(OI.Id, 'No product rate plan charge found for CPQ ID: '+cpqId);
                    return;
                }
                System.debug(FUNC_STR+'prpcId: '+prpcId);

                //START to set cancel date
                if(String.isBlank(billingPeriod)) {
                    System.debug(FUNC_STR+'Billing Period is required');
                    OrderDecompController.updateOrderItemError(OI.Id, 'Billing Period is required');
                    return;
                }

                //Note(Mikey): we do not need to calculate cancel date anymore, since this is always a non-cancel Quote at this point
                cancelDate = null;

              
                
                //Note(Mikey) LEAP-8811: Make sure to backdate the amend credit if it falls on same date as to-be-created cancellation quote
                Date amendDate = System.today();
                Date oiCancelDate = OI.Cancellation_Effective_Date__c;
                amendDate = (oiCancelDate==null || oiCancelDate>amendDate) ? amendDate : oiCancelDate.addDays(-1);

                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId, cancelDate, amendDate);
                if(newQuote==null){
                    System.debug(FUNC_STR+'Error creating Zuora Quote in SFDC');
                    return;
                }
                System.debug(FUNC_STR+'Successfully created Quote, will now call amend()');

                //OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
                amend(OI.Id, newQuote.Id, assetId, price, sfdcAccountId, zBillingAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id, false);
                return;
                //OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, zBillingAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id);
            }
            //END
        } else{
            System.debug(FUNC_STR+'Cannot create Quote. Quote Type is invalid');
            OrderDecompController.updateOrderItemError(OI.Id, 'Cannot create Quote. Quote Type is invalid');
            return;
        }
        system_logs__c logs = new system_logs__c();
        logs.Record_ID__c = newQuote.Id;
        logs.Object_Type__c = 'zqu__Quote__c';
        logs.Message__c = 'Zuora Quote was created in Salesforce';
        insert logs;
        
        upsert newQuote;
        OrderDecompController.updateOrderItemSuccess(OI.Id,'');
    }

    @future(callout=true)
    public static void amend(Id orderItemId, String quoteId, String assetId, String price, String sfdcAccountId, String zBillingAccountId, String cpqId, String priceAdd, String billingPeriod, String quantity, String OrderId, boolean addCharge){
        final String FUNC_STR = DEBUG_STR+'amend 1: ';
        System.debug(FUNC_STR+'Queueing up Z_queueableProcessInput with params orderItemId: '+orderItemId+
            +', quoteId: '+quoteId+', assetId: '+assetId+', orderItemId: '+orderItemId+', quoteId: '+quoteId+', assetId: '+assetId);
        String scheduledJobId = System.enqueueJob(new Z_queueableProcessInput(orderItemId, quoteId, assetId, price, sfdcAccountId, zBillingAccountId, cpqId, priceAdd, billingPeriod, quantity, OrderId, addCharge));
    }

    @future(callout=true)
    public static void amend(Id orderItemId, String quoteId, String assetId, String price, Boolean isrealsuite){
        final String FUNC_STR = DEBUG_STR+'amend 2: ';
        System.debug(FUNC_STR+'Queueing up Z_queueableProcessInput with params orderItemId: '+orderItemId+
            ', quoteId: '+quoteId+', assetId: '+assetId+', price: '+price);
        String scheduledJobId = System.enqueueJob(new Z_queueableProcessInput(orderItemId, quoteId, assetId, price, isrealsuite));
    }

}