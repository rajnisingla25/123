global class Z_scheduleProcessInput  {
  /*  List<String> quoteIdList;
    OrderItem OI;
    String sfdcAccountId;
    String zBillingAccountId;
    String type;
    private static final String FREE_CREDIT_CPQ_ID             = 'CREDIT';
    private static final String BUYOUT_CPQ_ID             = 'CREDIT';
    private static final String COTERM_CPQ_ID             = 'COTERM';
    zqu__Quote__c newQuote;

    public static Map<String, Boolean> hasRuns = new Map<String, Boolean>();
    public static Boolean sent = false;
    public static Boolean sent_ba = false;
    public static Boolean errorStatus;
    public static String errorMessage;
 
    public Z_scheduleProcessInput(OrderItem OI, String sfdcAccountId, String zBillingAccountId, string type) {
        this.OI = OI;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
        this.type = type;
    }

    //Process Each Order Line Item to create Quotes
    global void execute(SchedulableContext sc) {
        System.Debug('processInput for type: '+type+',SFDC AccountId '+sfdcAccountId);
        
        //test
        System.Debug('0');

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
        System.Debug('1');

        String assetId = String.valueOf(OI.Asset__c);
        String price = String.valueOf(OI.Extended_Net_Price__c);
        String billingPeriod = OI.Billing_Period__c;
        String quantity = String.valueOf(OI.quantity);
        zqu__Quote__c newQuote;
        String cpqId;
        Date cancelDate;
        
        Account acc = [Select id, Consolidated_Billing_Flag__c, Billing_Preference__c from Account where Id = :sfdcAccountId LIMIT 1];

        //test
        System.Debug('2');

        //Adding to handle tigerleads
        List<String> Product2Ids;
        Boolean hasTigerLead = false;
        
        if(!Test.isRunningTest()){
        
            List<Product2> OrderProduct2s = [Select Id, Fulfillment_ID__c from Product2 where Id = :OI.Pricebookentry.Product2Id];
        
            //test
            System.Debug('3');

            if(OrderProduct2s != null){
                for(Product2 product : OrderProduct2s){
                    if(product.Fulfillment_ID__c == 'Tigerleads'){
                        hasTigerLead = true;
                    }
                } 
            }

            //test
            System.Debug('4');
        }
        
        //test
        System.Debug('Type == ' + Type);

        if(Type == 'New Subscription'){

            //test
            System.Debug('New Subscription');

            if(OI.Line_Type__c == 'Add TigerLead' || OI.Line_Type__c == 'Add' || OI.Line_Type__c == 'Reinstate' || OI.Line_Type__c == 'Buyout' || OI.Line_Type__c == 'Coterm'){ 

                //Validate Order Line Input before creating Zuora Quote
                if(String.isBlank(billingPeriod)){
                    System.debug('Billing Period is required');
                    errorMessage = 'Billing Period is required';
                    errorStatus = true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }
                if(OI.Line_Type__c == 'Buyout'){
                    if(OI.Buyout_Amount__c==null){
                        System.debug('Buyout Amount is required');
                        errorMessage='Buyout Amount is required';
                        errorStatus=true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }
                    price = String.valueOf(OI.Buyout_Amount__c);
                    cpqId = OI.Part_Number__c + BUYOUT_CPQ_ID;
                }
                else if(OI.Line_Type__c == 'Coterm'){
                    if(OI.Start_Date__c==null){
                        System.debug('Start Date is required');
                        errorMessage='Start Date is required';
                        errorStatus=true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }

                    if(OI.Start_Date__c > Date.today()){
                        System.debug('Start Date cannot be greater than todays date');
                        errorMessage='Start Date cannot be greater than todays date';
                        errorStatus=true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }
                    cpqId = OI.Part_Number__c + COTERM_CPQ_ID;
                }
                else{
                    cpqId = OI.Part_Number__c;
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

                String prpcId = OrderDecompController.getProductRatePlanChargeIds(cpqId);
                if(String.isBlank(prpcId)){
                    System.debug('No associated Zuora Product found for CPQ ID: '+cpqId);
                    errorMessage='No associated Zuora Product found for CPQ ID: '+cpqId;
                    errorStatus=true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }

                //Create Zuora Quote
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }

                OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, cpqId, price, billingPeriod, quantity,OI.Id);
                List<Asset> aList = [Select Id From Asset Where Order_Line_Item__c = :OI.Id and Asset_Type__c = 'Parent' Limit 1];
                if(aList.size() > 0)
                    newQuote.AssetId__c = aList[0].Id;
                update newQuote;
            }
        } else if((Type == 'Cancel Subscription' || Type == 'Renew Subscription' || Type == 'Amend Subscription')) {
        
            //test
            System.Debug('Not New Subscription; OI.Line_Type__c = ' + OI.Line_Type__c + '; Type =' + Type);

            if(Type == 'Cancel Subscription'){
                    
                //test
                System.Debug('Cancel Subscription');

                //Setup Cancellation Date
                if(OI.Line_Type__c == 'Cancel') {
                    if(String.isBlank(billingPeriod)){
                        System.debug('Billing Period is required');
                        errorMessage = 'Billing Period is required';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }

                    System.debug('Billing Preference: ' + acc.Billing_Preference__c);
                    if(acc.Billing_Preference__c != 'CC-Direct' || billingPeriod=='Annual' || billingPeriod=='Annually' || billingPeriod=='Semi-Annual' || billingPeriod=='Bi-Annual' || billingPeriod=='Quarter' || billingPeriod=='Quarterly'){
                        cancelDate = Date.today();
                        System.debug('Cancel Date is today');
                    } else if(billingPeriod == 'Month' || billingPeriod == 'Monthly'){
                        System.debug('Period is Month');
                        //Setup cancellaton date = Next BCD - 1;
                        List<Zuora__CustomerAccount__c> billingAccList = [Select Id, Zuora__Zuora_Id__c,Zuora__BillCycleDay__c from Zuora__CustomerAccount__c where Zuora__Account__c = :sfdcAccountId LIMIT 1];
                        Zuora__CustomerAccount__c billingAcc;

                        if(billingAccList.size() > 0){
                            billingAcc = billingAccList[0];
                        } else{
                            System.debug('No Billing Account associated with the Account');
                            errorMessage = 'No Billing Account associated with the Account';
                            errorStatus = true;
                            OrderDecompController.updateOrderItem(OI.Id);
                            return;
                        }

                        if(billingAcc==null || String.isBlank(billingAcc.Zuora__BillCycleDay__c)){
                            System.debug('Bill Cycle Date is not set on Billing Account');
                            errorMessage = 'Bill Cycle Date is not set on Billing Account';
                            errorStatus = true;
                            OrderDecompController.updateOrderItem(OI.Id);
                            return;
                        }

                        System.debug('Calculating cancel date');
                        cancelDate = OrderDecompController.getCancelDate(billingAcc.Zuora__BillCycleDay__c);
                        List<Zuora__SubscriptionProductCharge__c> spcs = [Select Id, Zuora__BillingPeriodStartDay__c, Zuora__Price__c,Zuora__Quantity__c from Zuora__SubscriptionProductCharge__c where Zuora__RatePlanId__c = :OI.Asset__r.Zoura_Id__c AND Zuora__Type__c = 'Recurring'];
                        if(spcs.size() != 0 && acc.Consolidated_Billing_Flag__c == false) {
                            System.Debug('Inside Invoice Separate Cancel');
                            cancelDate = OrderDecompController.getCancelDate(spcs[0].Zuora__BillingPeriodStartDay__c);
                        }

                        System.debug('Calculated cancel date'+cancelDate);
                        if(cancelDate==null) {
                            System.debug('Error setting Cancel Date');
                            errorMessage = 'Error setting Cancel Date';
                            errorStatus = true;
                            OrderDecompController.updateOrderItem(OI.Id);
                            return;
                        }
                    } else {
                        System.debug('Billing Period is invalid');
                        errorMessage = 'Billing Period is invalid';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }
                }

                if(OI.Line_Type__c == 'Buyout'){
                        cancelDate = Date.today();
                }

                if(OI.Line_Type__c == 'Backout'){
                    if(OI.Cancellation_Date__c == null){
                        System.debug('Cancellation Date is required');
                        errorMessage = 'Cancellation Date is required';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }
                    cancelDate = OI.Cancellation_Date__c;
                }

                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }

                if(OrderDecompController.cancel(newQuote.Id)==true)
                    return;
            } else if(OI.Line_Type__c == 'Renew'){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }
                OrderDecompController.renewal(newQuote.Id, assetId, price,OI.Id);
            } else if(OI.Line_Type__c == 'Amend'){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }
                OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
            } else if(OI.Line_Type__c == 'Paid Extension'){
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }
                OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
            } else if(OI.Line_Type__c == 'Credit') {
                //test
                System.Debug('Line type = Credit');
                System.Debug('OI.Credit_Amount__c = ' + OI.Credit_Amount__c);

                Decimal newPrice = OI.Credit_Amount__c * -1;
                //test
                System.Debug('newPrice = ' + newPrice);

                String newPriceString = String.valueOf(newPrice);
                //test
                System.Debug('newPriceString = ' + newPriceString);

                cpqId = OI.Part_Number__c + FREE_CREDIT_CPQ_ID;
                if(acc.Billing_Preference__c == 'CC-Direct'){
                        cpqId = 'PAY' + cpqId;
                }else{
                        cpqId = 'INV' + cpqId;
                }

                //test
                System.Debug('11');

                String prpcId = OrderDecompController.getProductRatePlanChargeIds(cpqId);
                if(String.isBlank(prpcId)) {
                    System.debug('No product rate plan charge found for CPQ ID: '+cpqId);
                    errorMessage='No product rate plan charge found for CPQ ID: '+cpqId;
                    errorStatus=true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }

                //test
                System.Debug('22');

                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }

                //test
                System.Debug('33');

                //Submit Amendment Quote and add credit (can also add T&C)
                OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
                OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id);
            }

            //test
            System.Debug('test');   
                
            //Cancel with credit:
            //START
            //NOTE (Mikey): Need to add check where this won't create a second Cancellation Quote
            //if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0){
            if(OI.Line_Type__c == 'Cancel' && OI.Credit_Amount__c != 0 && Type != 'Cancel Subscription'){
                //test
                System.Debug('Line type = Credit');
                System.Debug('OI.Credit_Amount__c = ' + OI.Credit_Amount__c);

                Decimal newPrice = OI.Credit_Amount__c * -1;
                //test
                System.Debug('newPrice = ' + newPrice);

                String newPriceString = String.valueOf(newPrice);
                //test
                System.Debug('newPriceString = ' + newPriceString);

                cpqId = OI.Part_Number__c + FREE_CREDIT_CPQ_ID;
                if(acc.Billing_Preference__c == 'CC-Direct'){
                        cpqId = 'PAY' + cpqId;
                } else {
                        cpqId = 'INV' + cpqId;
                }

                //test
                System.Debug('11');

                String prpcId = OrderDecompController.getProductRatePlanChargeIds(cpqId);
                if(String.isBlank(prpcId)) {
                    System.debug('No product rate plan charge found for CPQ ID: '+cpqId);
                    errorMessage='No product rate plan charge found for CPQ ID: '+cpqId;
                    errorStatus=true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }

                //test
                System.Debug('22');

                //START to set cancel date
                if(String.isBlank(billingPeriod)) {
                    System.debug('Billing Period is required');
                    errorMessage = 'Billing Period is required';
                    errorStatus = true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }

                System.debug('Billing Preference: ' + acc.Billing_Preference__c);
                if(acc.Billing_Preference__c != 'CC-Direct' || billingPeriod=='Annual' || billingPeriod=='Annually' || billingPeriod=='Semi-Annual' || billingPeriod=='Bi-Annual' || billingPeriod=='Quarter' || billingPeriod=='Quarterly'){
                    cancelDate = Date.today();
                    System.debug('Cancel Date is today');
                } else if(billingPeriod == 'Month' || billingPeriod == 'Monthly'){
                    System.debug('Period is Month');
                    //Setup cancellaton date = Next BCD - 1;
                    List<Zuora__CustomerAccount__c> billingAccList = [Select Id, Zuora__Zuora_Id__c,Zuora__BillCycleDay__c from Zuora__CustomerAccount__c where Zuora__Account__c = :sfdcAccountId LIMIT 1];
                    Zuora__CustomerAccount__c billingAcc;

                    if(billingAccList.size() > 0){
                        billingAcc = billingAccList[0];
                    } else {
                        System.debug('No Billing Account associated with the Account');
                        errorMessage = 'No Billing Account associated with the Account';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }

                    if(billingAcc==null || String.isBlank(billingAcc.Zuora__BillCycleDay__c)){
                        System.debug('Bill Cycle Date is not set on Billing Account');
                        errorMessage = 'Bill Cycle Date is not set on Billing Account';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }

                    System.debug('Calculating cancel date');
                    cancelDate = OrderDecompController.getCancelDate(billingAcc.Zuora__BillCycleDay__c);
                    List<Zuora__SubscriptionProductCharge__c> spcs = [Select Id, Zuora__BillingPeriodStartDay__c, Zuora__Price__c,Zuora__Quantity__c from Zuora__SubscriptionProductCharge__c where Zuora__RatePlanId__c = :OI.Asset__r.Zoura_Id__c AND Zuora__Type__c = 'Recurring'];
                    if(spcs.size() != 0 && acc.Consolidated_Billing_Flag__c == false) {
                        System.Debug('Inside Invoice Separate Cancel');
                        cancelDate = OrderDecompController.getCancelDate(spcs[0].Zuora__BillingPeriodStartDay__c);
                    }

                    System.debug('Calculated cancel date'+cancelDate);
                    if(cancelDate==null) {
                        System.debug('Error setting Cancel Date');
                        errorMessage = 'Error setting Cancel Date';
                        errorStatus = true;
                        OrderDecompController.updateOrderItem(OI.Id);
                        return;
                    }
                } else {
                    System.debug('Billing Period is invalid');
                    errorMessage = 'Billing Period is invalid';
                    errorStatus = true;
                    OrderDecompController.updateOrderItem(OI.Id);
                    return;
                }

                //END to set cancel date
                
                newQuote = OrderDecompController.createZuoraQuote(OI, sfdcAccountId, zBillingAccountId, type, initialTerm, renewalTerm, assetId,cancelDate);
                if(newQuote==null){
                    System.debug('Error creating Zuora Quote in SFDC');
                    return;
                }

                //test
                System.Debug('33');

                OrderDecompController.amend(OI.Id, newQuote.Id, assetId, price);
                OrderDecompController.addCharge(newQuote.Id, sfdcAccountId, cpqId, newPriceString, billingPeriod, quantity,OI.Id);
            }
            //END
        } else{
            System.debug('Cannot create Quote. Quote Type is invalid');
            errorMessage = 'Cannot create Quote. Quote Type is invalid';
            errorStatus = true;
            return;
        }

        upsert newQuote;
        List<String> quoteIdList = new List<String>();
        quoteIdList.add(newQuote.Id);
        List<String> accIdList = new List<String>();
        accIdList.add(newQuote.zqu__ZuoraAccountID__c);
        //Remove 12-3-2015 Functionality implemented in OrderDecompController
        //OrderDecompController.scheduleSendToZBilling(30,quoteIdList,accIdList);
    }  */
}