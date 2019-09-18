@isTest(SeeAllData=True)
public class OrderDecompControllerTest {

   public static final String TEST_CPQ_ID = 'testpartnumber';

    private static Account account;
    private static Zuora__CustomerAccount__c billingAccount;
    private static Contact testContact;
    private static Contact testContact2;
    private static Zuora__Subscription__c sub;
    private static Zuora__SubscriptionProductCharge__c subCharge;
    private static Order order;
    private static Asset asset;
    private static List<OrderItem> orderItemList;
    private static PriceBookEntry pe;
    private static Account_Relationship__c billRelationship;
    private static Account_Relationship__c soldRelationship;
    private static Opportunity opp;
    private static zqu__Quote__c quote;
    //public static list<zqu__zProduct__c> prods = [Select Id from zqu__ZProduct__c order by CreatedDate desc];
    //public static zqu__zProduct__c prod = prods[0];
    private static BigMachines__Quote_Product__c quoteProduct;

    //0 = success,
    private static Integer subPreviewResultUseCase;
    
    public static zqu__zProduct__c prod;

    private static void setupData() {
        OrderDecompController.testClassTriggerFlag = true; 
           // SkipOrderTrigger.setSkipTrgTrue();
        if(prod == null || prod.Name == null || prod.Name != 'test product'){
            prod = Z_LegacyTestFactory.prepareProductCatalog();
        }  
        
        account = Z_LegacyTestFactory.makeAccount(); //Create Account
       
        testContact = Z_LegacyTestFactory.makeContact(account, 'eeeee5@email.com'); //Create Contact
 
        testContact2 = Z_LegacyTestFactory.makeContact(account, 'eeeee4@email.com'); //Create Contact
        
        billingAccount = Z_LegacyTestFactory.makeBillingAccount(account);
     
        setupAccountRelationship();

        List<zqu__ProductRatePlanCharge__c> p_charges = [SELECT Id,CPQID__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__r.zqu__ZProduct__c = :prod.Id AND zqu__Deleted__c = false]; 
        p_charges[0].CPQID__c=TEST_CPQ_ID;
        p_charges[1].CPQID__c='INV'+TEST_CPQ_ID;
        p_charges[2].CPQID__c='CT'+TEST_CPQ_ID;
        p_charges[3].CPQID__c='PAY'+TEST_CPQ_ID;
        p_charges[4].CPQID__c=TEST_CPQ_ID+'CREDIT';
        p_charges[5].CPQID__c='INV'+TEST_CPQ_ID+'CREDIT';
        p_charges[6].CPQID__c='CT'+TEST_CPQ_ID+'CREDIT';
        p_charges[7].CPQID__c='PAY'+TEST_CPQ_ID+'CREDIT';
        update p_charges;

        asset = setupAsset(account,testContact);
        sub = Z_LegacyTestFactory.makeSubscription(account, billingAccount);
        sub.AssetID__c = asset.Id;
        sub.zuora__external_id__c = '121212121212121212';
        update sub;

        subCharge = Z_LegacyTestFactory.makeSubProdCharge(sub,'Annual','Test Charge Number');
        subCharge.zuora__type__c = 'Recurring';
        update subCharge;
        pe = setupPriceBookEntry();
        order = setupOrder();
        orderItemList = setupOrderItemList(true);  
        System.debug(orderItemList[0]);

        opp = Z_LegacyTestFactory.makeOpp(account);
        quote = Z_LegacyTestFactory.makeQuote(opp);
        quote.zqu__ExistSubscriptionID__c = '121212121212121212';
        update quote;
        subPreviewResultUseCase = 0;
    }

    public static void setupAccountRelationship() {
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = testContact.Id;
        ar.Zuora_Ship_to_Contact_ID__c = testContact.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = account.Id;
        insert ar;
        billRelationship = ar;
        testContact2.Type__c = 'Broker';
        testContact2.FirstName = 'firstname2';
        update testContact2;

        Account_Relationship__c ar2 = new Account_Relationship__c();
        ar2.Contact_to__c = testContact2.Id;
        RecordType rt = [SELECT Id,Name from RecordType WHERE Name='Contact Relationship'];
        ar2.RecordTypeId = rt.Id;
        ar2.Billing_Contact__c = false;
        ar2.Contact_Role__c = 'Secondary Contact';
        ar2.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar2.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar2.Relationship_Type__c = 'Contact';
        ar2.Active__c = true;
        ar2.Parent_Account__c = account.Id;
        insert ar2;
        soldRelationship = ar2;

        Account_Relationship__c ar3 = new Account_Relationship__c();
        ar3.Contact_to__c = testContact2.Id;
        ar3.RecordTypeId = rt.Id;
        ar3.Billing_Contact__c = true;
        ar3.Contact_Role__c = 'Secondary Contact';
        ar3.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar3.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar3.Relationship_Type__c = 'Contact';
        ar3.Active__c = true;
        ar3.Parent_Account__c = account.Id;
        insert ar3;

        Account_Relationship__c ar4 = new Account_Relationship__c();
        ar4.Contact_to__c = testContact2.Id;
        ar4.RecordTypeId = rt.Id;
        ar4.Billing_Contact__c = false;
        ar4.Contact_Role__c = 'Primary Contact';
        ar4.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar4.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar4.Relationship_Type__c = 'Contact';
        ar4.Active__c = true;
        ar4.Parent_Account__c = account.Id;
        insert ar4;

    }

    private static Order setupOrder() {
        order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.Today();
        order.Status = 'Created';
        order.Fulfillment_Status__c = 'Pending Fulfillment';
        /*Pricebook2 pb = new Pricebook2();
        pb.Name='test';
        insert pb;*/
        order.Pricebook2Id = Test.getStandardPricebookId();
        insert order;
        return order;
    }
    
  /* public static testMethod void testCancelmethod() {
        Account acc = new Account();
        acc.name = 'test acc';
        insert acc; 
        
         Account acc1 = new Account();
        acc1.name = 'test acc';
        insert acc1; 
        
        Order orderobj = new Order(); 
        orderobj.AccountId = acc.Id;
        orderobj.EffectiveDate = Date.Today();
        orderobj.Status = 'Created';
        orderobj.Fulfillment_Status__c = 'Pending Fulfillment';        
        orderobj.Pricebook2Id = Test.getStandardPricebookId();
        insert orderobj;
        
        OrderDecompController.createZuoraAccount(orderobj.id,acc1.id);
    }*/

    private static Asset setupAsset(Account acc, Contact con) {
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId = acc.Id;
        myAsset.ContactId = con.Id;
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        insert myAsset;
        return myAsset;
    }

    private static List<OrderItem> setupOrderItemList(boolean low) {
        BigMachines__Quote__c bmQuote = new BigMachines__Quote__c();
        insert bmQuote;
        quoteProduct = new BigMachines__Quote_Product__c();
        quoteProduct.BigMachines__Sales_Price__c = 5;
        quoteProduct.BigMachines__Quantity__c = 5;
        quoteProduct.BigMachines__Quote__c = bmQuote.Id;
        quoteProduct.Contractedimpressions__c = 500;
        quoteProduct.PricePerImpressionSold__c = 500;
        insert quoteProduct;
        
        orderItemList = new List<OrderItem>();
        OrderItem oi1 = setupOrderItem('Add');
        OrderItem oi2 = setupOrderItem('Cancel');
        OrderItem oi3 = setupOrderItem('Amend');
        OrderItem oi4 = setupOrderItem('Coterm');
        //OrderItem oi5 = setupOrderItem('Renew');
        OrderItem oi6 = setupOrderItem('Credit');
        OrderItem oi7 = setupOrderItem('Buyout');
        OrderItem oi8 = setupOrderItem('Invalid order line');
        OrderItem oi9 = setupOrderItem('Add TigerLead');
        OrderItem oi10 = setupOrderItem('Backout');
    OrderItem oi11 = setupOrderItem('Amend');
        oi11.Extension_Type__c = 'Unpaid';
        //oi11.Override_Term__c = 0;
        //oi11.Ext_Days__c = 0;
        //update oi11;
        
        orderItemList.add(oi1);
        orderItemList.add(oi2);
        orderItemList.add(oi3);
        orderItemList.add(oi4);
        //orderItemList.add(oi5);
        orderItemList.add(oi6);
        orderItemList.add(oi7);
        orderItemList.add(oi8);
        orderItemList.add(oi9);
        orderItemList.add(oi10);
    orderItemList.add(oi11);
        
        if (!low){
            //Test more than 50
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
            orderItemList.add(oi1.clone());
        }

        insert orderItemList;
        return orderItemList;
    }

    private static List<OrderItem> setupOrderItemList2() {
        orderItemList = new List<OrderItem>();
        OrderItem oi9 = setupOrderItem('Add TigerLead');
        orderItemList.add(oi9);
        return orderItemList;
    }

    private static OrderItem setupOrderItem(String lineType) {
        OrderItem oi = new OrderItem();
        oi.OrderId = order.Id;
        oi.Quantity = 1;
        oi.Asset__c = asset.Id;
        oi.Extended_Net_Price__c = 10.00;
        oi.Contract_Term__c = '12';
        oi.Part_Number__c = 'testpartnumber';
        oi.Subscription_Term__c = '1';
        oi.Override_Term__c = 1;
        oi.Line_Type__c = lineType;
        oi.Billing_Period__c = 'Month';
        oi.Cancellation_Date__c = Date.today();
        oi.Buyout_Amount__c = 100.00;
        oi.Credit_Amount__c = 100.00;
        oi.UnitPrice=10.00;
        oi.Quantity = 1;
        oi.PricebookEntryId = pe.Id;        
        oi.Term_Start_Date__c = Date.today();
        oi.Start_Date__c = Date.today();
        oi.Commerce_Group__c = 'Broker Marketing Solution';
        oi.Quote_Product__r = quoteProduct;
        //insert oi;
        return oi;
    }
    
    
    public static Account_Relationship__c makeRealationship(String acc, Contact con) {
        Account_Relationship__c rel = new Account_Relationship__c();
        rel.Active__c = true;
        rel.Average_Transaction_Amount__c = 100;
        rel.Billing_Contact__c = true;
        rel.Parent_Account__c = acc;
        rel.Zuora_Bill_to_Contact_ID__c = '11111111111111111111111111111111';
        rel.Zuora_Ship_to_Contact_ID__c = '11111111111111111111111111111111';
        rel.Contact_Role__c = 'Primary Contact';
        rel.Contact_To__c = con.id;
        rel.Contact_To__r = con;
        insert rel;
        return rel;
    }
    
    public static PriceBookEntry setupPriceBookEntry() {
        return setupPriceBookEntry(false);
    }
    
    public static PriceBookEntry setupPriceBookEntry(Boolean hasTigerLead) {
        System.debug('hasTigerLead::' + hasTigerLead);
        Product2 p2 = new Product2();
        p2.Name='test prod';
        p2.s_no__c = 2;
        //Preya
        p2.Fulfillment_ID__c = 'Tigerleads';
        if (hasTigerLead) {
            System.debug('This is TigerLead Pricebookentry');
            p2.Fulfillment_ID__c = 'Tigerleads';
        }
        insert p2;
      
        pe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p2.Id, UnitPrice = 1);
        
        insert pe;
        return pe;
    }

   
    public static testMethod void test1_BadBillingAccount() {
        setupData();
        
        OrderItem oi = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];

        Test.startTest();
        order.AccountId = null;
        OrderDecompController oc = new OrderDecompController(order);
    }
    public static testMethod void test9_coverage() {
        setupData();
        setupOrderItemList(true);

        Test.startTest();
        quote.Order_Product__c = orderItemList[0].Id;
        update quote;
        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        quotes.add(quote);
        Z_queueableSendToZBilling.updateQuotesThatRequireCancellation(quotes);
        orderItemList[0].Zuora_Comment__c = 'blah';
        Z_queueableSendToZBilling.updateOrderStatus(order.Id, orderItemList);

        OrderDecompController oc = new OrderDecompController(order);

        OrderDecompController.convertOrderLines(order.Id, null, null);
        OrderDecompController.errorStatus = true;
        OrderDecompController.updateOrderItem(orderItemList[0].Id);
        OrderDecompController.errorStatus = false;
        OrderDecompController.updateOrderItem(orderItemList[0].Id);
        
        //OrderItem blah = [select ContractedImpressions__c,PricePerImpressionSold__c from OrderItem where Id = :orderItemList[0].Id];
        //orderItemList[0].Line_Type__c = 'Add';
        //orderItemList[0].Quote_Product__r.PricePerImpressionSold__c = 500;
        //orderItemList[0].Quote_Product__r.Contractedimpressions__c = 500;
        //update orderItemList[0];
        orderItemList[0].Line_Type__c = 'Coterm';
        update orderItemList[0];
        OrderDecompController.createZuoraQuote(orderItemList[0], account.Id, billingAccount.Zuora__Zuora_Id__c, 'New Subscription', 12, 12, String.valueOf(asset.Id), Date.today());
        orderItemList[0].Line_Type__c = 'Cancel';
        orderItemList[0].Credit_Amount__c = 1;
        update orderItemList[0];
        OrderDecompController.createZuoraQuote(orderItemList[0], account.Id, billingAccount.Zuora__Zuora_Id__c, 'New Subscription', 12, 12, String.valueOf(asset.Id), Date.today());
        OrderDecompController.createZuoraQuote(orderItemList[0], account.Id, billingAccount.Zuora__Zuora_Id__c, 'Renew Subscription', 12, 12, null, Date.today());  
        OrderDecompController.createZuoraQuote(orderItemList[0], account.Id, billingAccount.Zuora__Zuora_Id__c, 'Renew Subscription', 12, 12, '12345', Date.today());  
        OrderDecompController.getCancelDate('EOM');
        OrderDecompController.createZuoraQuote(orderItemList[0], account.Id, billingAccount.Zuora__Zuora_Id__c, 'Cancel Subscription', 12, 12, '12345', Date.today());

        OrderDecompController.updateOrderItemWithQuote(quote.Id, true, 'test');

        List<zqu__ProductRatePlan__c> p_plans = [SELECT Id FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c = :prod.Id AND zqu__Deleted__c = false];
        List<String> productRatePlanIds = new List<String>(new Map<String, zqu__ProductRatePlan__c>(p_plans).keySet());
        
        List<zqu.zChargeGroup> cGs = zqu.zQuoteUtil.getChargeGroups(quote.Id, productRatePlanIds);
        System.Debug('cGs@@'+ cGs);
        //try {
        //zqu.zQuoteUtil.addChargeGroups(cGs);
         //}catch(Exception ex){
           //System.debug('Exception at CGS: ' + ex.getMessage());
      // }
        //system.debug('charge group size:' + cGs.size());
        OrderDecompController.prepareTermsAndConditionChanges(asset.Id, quote, '123', orderItemList[0].Id, cGs);
          
         //Preya
        Map<String,Object> testTC = new Map<String,Object>();
        testTC.put('zqu__TermType__c','Termed');
        testTc.put('zqu__AutoRenew__c','True');
        testTC.put('zqu__RenewalSetting__c', '');
        testTc.put('zqu__TermStartDate__c', Date.newInstance(2016, 2, 17));
        OrderDecompController.setSubscriptionTermChanges(quote.id, testTC);
        List<zqu.zChargeGroup> cGss = OrderDecompUtil.checkBillingPeriod('30','Bi-Annual', cGs, quotes[0],'CC-Direct', true, 'ADVANTAGE');
        Test.stopTest();
    }
    
     public static testMethod void test1_SuccessScenario() {
        setupData();
        
        OrderItem oi = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        OrderDecompController.addCharge(quote.Id, account.Id, billingAccount.Zuora__Zuora_Id__c,'testpartnumber', '123', 'month', '1', oi.Id);
        OrderDecompController.updateCharge(quote.Id);
        oi.Billing_Period__c = 'Monthly';
        update oi;
         
         
        /* zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
         qa.zqu__Quote__c = quote.Id;
         insert qa;
         
         zqu__QuoteRatePlan__c qr = new zqu__QuoteRatePlan__c();
         qr.zqu__Quote__c = quote.Id;
         qr.zqu__QuoteAmendment__c = qa.Id;
         insert qr;
         
         zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
         qrpc.zqu__QuoteRatePlan__c  = qr.Id;
         insert qrpc;*/
         
         
        OrderDecompController.renewal(quote.Id, billingAccount.Zuora__Zuora_Id__c, asset.Id, '123', oi.Id);
        OrderDecompController.renewal('3456', billingAccount.Zuora__Zuora_Id__c, '8976', '123', oi.Id);
        OrderDecompController.renewal(quote.Id, billingAccount.Zuora__Zuora_Id__c, 'hkjhhkjlk', '123', oi.Id);
        OrderDecompController.renewal('eessss', billingAccount.Zuora__Zuora_Id__c, asset.Id, '123', oi.Id);
        oi.Line_Type__c = 'New';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Override_Term__c = 0;
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Renew';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Amend';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'New';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Cancel';
        oi.Credit_Amount__c = 0;
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Backout';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Paid Extension';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        oi.Line_Type__c = 'Free Extension';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));
        
        //OrderDecompController.processInput(oi, account.Id, billingAccount.Id, 'New Subscription');
        //OrderDecompController.processInput(oi, account.Id, billingAccount.Id, 'Renew Subscription');
        //OrderDecompController.processInput(oi, account.Id, billingAccount.Id, 'Amend Subscription');
        //OrderDecompController.processInput(oi, account.Id, billingAccount.Id, 'New Subscription');

        oi.Commerce_Group__c = 'Agent Marketing Solution';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));

        oi.Commerce_Group__c = 'Test123';
        update oi;
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi, account.Id, billingAccount.Id));



        OrderDecompController.startOrderDecomp(order.Id, account.Id, billingAccount.Id);

        OrderDecompController.createContactZObject(account, True, billingAccount.Id, billRelationship);
        OrderDecompController.createContactZObject(account, False, billingAccount.Id, soldRelationship);
        
        OrderItem oi2 = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Credit_Amount__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Cancel' AND OrderId = :order.Id LIMIT 1];

        //OrderDecompController.processInput(oi2, account.Id, billingAccount.Id, 'Cancel Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi2, account.Id, billingAccount.Id));
        
        oi2.Billing_Period__c = null;
        update oi2;
        
        //OrderDecompController.processInput(oi2, account.Id, billingAccount.Id, 'Cancel Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi2, account.Id, billingAccount.Id));
        
        oi2.Billing_Period__c = 'Monthly';
        account.Account_Sub_Type__c = 'Former Customer';
        account.Billing_Preference__c = 'CC-Direct';
        billingAccount.Zuora__BillCycleDay__c = null;
        update oi2;
        update account;
        update billingAccount;
        
        //OrderDecompController.processInput(oi2, account.Id, billingAccount.Id, 'Cancel Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi2, account.Id, billingAccount.Id));

        oi2.Cancellation_Date__c = null; 
        update oi2;
        
        //OrderDecompController.processInput(oi2, account.Id, billingAccount.Id, 'Cancel Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi2, account.Id, billingAccount.Id));
        
        OrderItem oi3 = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Credit_Amount__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c  FROM OrderItem WHERE Line_Type__c='Amend' AND OrderId = :order.Id LIMIT 1];
        
        //OrderDecompController.processInput(oi3, account.Id, billingAccount.Id, 'Amend Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi3, account.Id, billingAccount.Id));
        
        OrderItem oi4 = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Credit_Amount__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Credit' AND OrderId = :order.Id LIMIT 1];
        
        //OrderDecompController.processInput(oi4, account.Id, billingAccount.Id, 'Amend Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi4, account.Id, billingAccount.Id));
        
        OrderItem oi5 = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Credit_Amount__c, Start_Date__c, Zuora_Status__c, Zuora_Comment__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Buyout' AND OrderId = :order.Id LIMIT 1];
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'Amend Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));
        
        oi5.Buyout_Amount__c = null;
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));

        oi5.Buyout_Amount__c = 0;
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));

        oi5.Billing_Period__c = null;
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));
        
        oi5.Billing_Period__c = 'Annual';
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));
        
        oi5.Billing_Period__c = 'Bi-Annual';
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));
        
        oi5.Billing_Period__c = 'Quarterly';
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));

        oi5.Zuora_Status__c = 'Cancel Subscription';
        update oi5;
        
        //OrderDecompController.processInput(oi5, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi5, account.Id, billingAccount.Id));
        
        account.Billing_Preference__c = 'Invoice-CC';
        update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        
        account.Billing_Preference__c = 'Invoice-Terms';
        update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);      
        
        //Preya   
        account.Billing_Preference__c = 'arrears-invoice';
        update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        
        account.Billing_Preference__c = 'arrears-cc';
        update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        //ends
        
        account.Billing_Preference__c = 'Tiger';
        update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        
        //account.Type = 'Agent';
        //account.Currency_Type__c = null;
        //update account;
        
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        
        OrderItem oi6 = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Credit_Amount__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Coterm' AND OrderId = :order.Id LIMIT 1];
        
        //OrderDecompController.processInput(oi6, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi6, account.Id, billingAccount.Id));
        
        oi6.Start_Date__c = null;
        update oi6;
        
        //OrderDecompController.processInput(oi6, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi6, account.Id, billingAccount.Id));
        
        oi6.Start_Date__c = Date.today() + 5;
        update oi6;
        
        //OrderDecompController.processInput(oi6, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi6, account.Id, billingAccount.Id));
        
        account.Billing_Preference__c = 'CC-Direct';
        update account;
        
        //OrderDecompController.processInput(oi6, account.Id, billingAccount.Id, 'New Subscription');
        System.enqueueJob(new Z_queueableProcessInput(order.Id, oi6, account.Id, billingAccount.Id));

        System.enqueueJob(new Z_queueableProcessInput(oi6.Id, quote.Id, asset.Id, '123', account.Id, billingAccount.Id, 'testcpq', '123', 'Monthly', '5', order.Id, true));
        
        List<String> quoteIds= new List<String>();
        quoteIds.add(quote.Id);
        quote.Order_Product__c =oi6.id;
        update quote;
        Z_queueableSendToZBilling.sendtoZbilling(quoteIds);
        Zuora.ZApi zapi = OrderDecompController.zuoraApiAccess();
        OrderDecompController.deleteZObjects('Account', new List<String>{account.Id}, null);
        OrderDecompController.deleteZObjects('Account', new List<String>{account.Id}, zapi);
        OrderDecompController.errorStatus = false;
        String Message = 'Order Error';
       // OrderDecompController.updateOrder(order.Id);
        
        account = null;
       OrderDecompcontroller.UpdateOrderItemswithmultipleQuoteIdsfailure(quoteIds,'test');
        OrderDecompcontroller.cancel(quote.Id);
        OrderDecompController.createAccountZObject((String)Order.Id, Account);
        
        Test.stopTest();
    }

    //No Billing Account exists
   public static testMethod void test2_NoBillingAccountInvoice() {

        OrderDecompController.testClassTriggerFlag = true; 
        
        account = Z_LegacyTestFactory.makeAccount(); //Create Account
        testContact = Z_LegacyTestFactory.makeContact(account, 'eeeee2@email.com'); //Create Contact
        testContact2 = Z_LegacyTestFactory.makeContact(account, 'eeeee1@email.com'); //Create Contact
        setupAccountRelationship();

        //Z_LegacyTestFactory.prepareProductCatalog();
        /*sub = Z_LegacyTestFactory.makeSubscription(account, billingAccount);
        subCharge = Z_LegacyTestFactory.makeSubProdCharge(sub,'Month');*/
        asset = setupAsset(account,testContact);
        pe = setupPriceBookEntry();
        order = setupOrder();   
        //orderItemList = setupOrderItemList();  
        //System.debug(orderItemList[0]);


        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        System.debug('Running test1');
        Test.stopTest();
    }
     public static testMethod void queryZBillingAccount() {
        setupData();
        
        OrderDecompController.queryZBillingAccount(account.Id);
       
    }

    //No Billing Account exists
    public static testMethod void test2_NoBillingAccountCCDirect() {
       
        OrderDecompController.testClassTriggerFlag = true; 
    
        account = Z_LegacyTestFactory.makeAccount(); //Create Account
        testContact = Z_LegacyTestFactory.makeContact(account , 'eeeee@email.com'); //Create Contact
        testContact2 = Z_LegacyTestFactory.makeContact(account, 'eeee@email.com'); //Create Contact
        setupAccountRelationship();
        account.Billing_Preference__c = 'CC-Direct';
        update account;

        /*sub = Z_LegacyTestFactory.makeSubscription(account, billingAccount);
        subCharge = Z_LegacyTestFactory.makeSubProdCharge(sub,'Month');*/
        asset = setupAsset(account,testContact);
        pe = setupPriceBookEntry();
        order = setupOrder();
        //orderItemList = setupOrderItemList();  
        //System.debug(orderItemList[0]);


        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        System.debug('Running test1');
        Test.stopTest();
    }

    public static testMethod void test3_CancellationDateNull() {
        setupData();

        OrderItem oi = [SELECT Id,Cancellation_Date__c,Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];
        oi.Cancellation_Date__c = null;
        update oi;

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        Test.stopTest();
    }

    public static testMethod void test5_BillingPeriodNull() {
        setupData();

        OrderItem oi = [SELECT Id,Billing_Period__c,Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];
        oi.Billing_Period__c = '';
        update oi;

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        Test.stopTest();
    }

    public static testMethod void test6_BuyoutAmountNull() {
        setupData();

        OrderItem oi = [SELECT Id,Buyout_Amount__c,Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];
        oi.Buyout_Amount__c = null;
        update oi;

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        Test.stopTest();
    }

    public static testMethod void test7_CPQIdInvalid() {
        setupData();

        OrderItem oi = [SELECT Id,Part_Number__c,Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];
        oi.Part_Number__c = 'test';
        update oi;

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        Test.stopTest();
    }



    public static testMethod void test4_TigerLeads() {
        OrderDecompController.testClassTriggerFlag = true; 
        
        if(prod == null || prod.Name == null || prod.Name != 'test product'){
            prod = Z_LegacyTestFactory.prepareProductCatalog();
        }  
    
        account = Z_LegacyTestFactory.makeAccount(); //Create Account
        testContact = Z_LegacyTestFactory.makeContact(account , 'email11@email.com'); //Create Contact
        testContact2 = Z_LegacyTestFactory.makeContact(account,'email12@email.com'); //Create Contact
        billingAccount = Z_LegacyTestFactory.makeBillingAccount(account);
        setupAccountRelationship();

        List<zqu__ProductRatePlanCharge__c> p_charges = [SELECT Id,CPQID__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__r.zqu__ZProduct__c = :prod.Id]; 
        p_charges[0].CPQID__c='testpartnumber';
        update p_charges[0];

        asset = setupAsset(account,testContact);
        sub = Z_LegacyTestFactory.makeSubscription(account, billingAccount);
        sub.AssetID__c = asset.Id;
        update sub;

        subCharge = Z_LegacyTestFactory.makeSubProdCharge(sub,'Month', 'Test Charge Number');
        //Create pricebookentry with Tigerlead Product2
        pe = setupPriceBookEntry(true);
        order = setupOrder();
        
        
        
        orderItemList = setupOrderItemList2();  
        System.debug(orderItemList[0]);

        /*OrderItem oi = [SELECT Id,Cancellation_Date__c, Zuora_Status__c FROM OrderItem WHERE OrderId = :order.Id LIMIT 1];
        oi.Cancellation_Date__c = null;
        update oi;*/

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);
        Test.stopTest();
    }
   

    public static testMethod void updateorderTest() {
        account = Z_LegacyTestFactory.makeAccount();
        order o =setupOrder();
        o.Fulfillment_Status__c = 'Fulfilled';
        update o;
    }
    
    public static testMethod void miscMethodsTest() {
        Test.startTest();
        OrderDecompController.getCancelDate('1st of the Month');
        OrderDecompController.getCancelDate('30th of the Month');
        Test.stopTest();
    }

    public static testMethod void test8_LargeOrder() {
        setupData();
        setupOrderItemList(false);

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        quotes.add(makeQuote(opp));
        insert quotes;

        List<String> quoteIds = new List<String>(new Map<String, zqu__Quote__c>(quotes).keySet());

        Z_queueableSendToZBilling sendToZuora = new Z_queueableSendToZBilling(order.Id, quoteIds);
        Z_queueableSendToZBilling sendToZuora1 = new Z_queueableSendToZBilling(order.Id);

        Z_scheduleProcessInputAndSendToZBilling.scheduleProcessInputAndSendToZBilling(30, order.Id, quoteIds, account.Id, billingAccount.Zuora__Zuora_Id__c);
        Test.stopTest();
    }
    
     public static testMethod void test1_badaccount_1() {
        try{
        setupData();
        account.Currency_Type__c='';
        update account;
        OrderItem oi = [SELECT Id, OrderId, Quantity, Asset__c, Extended_Net_Price__c, 
        Contract_Term__c, Override_Term__c, Part_Number__c, Subscription_Term__c, Line_Type__c,
        Billing_Period__c, Cancellation_Date__c, Buyout_Amount__c, UnitPrice,
        PriceBookEntryID, Pricebookentry.Product2Id, Term_Start_Date__c, Start_Date__c, Zuora_Status__c, DeliveredImpressions__c, DeliveredImpressionsUpdatedDate__c FROM OrderItem WHERE Line_Type__c='Add' AND OrderId = :order.Id LIMIT 1];

        Test.startTest();
        OrderDecompController oc = new OrderDecompController(order);   
        Test.stoptest();
        }catch(exception ex){}
      }

    

    public static zqu__Quote__c makeQuote(Opportunity testOpp) {

        zqu__Quote__c testQuote = new zqu__Quote__c();

        testQuote.Name = 'my test quote';
        testQuote.zqu__Opportunity__c = testOpp.Id;
        testQuote.zqu__Currency__c = 'USD';
        testQuote.zqu__ValidUntil__c = System.today();
        testQuote.zqu__SubscriptionTermStartDate__c = System.today();
        testQuote.zqu__Status__c = 'New';
        testQuote.zqu__InitialTerm__c = 12;
        testQuote.zqu__RenewalTerm__c = 12;
        testQuote.zqu__Subscription_Term_Type__c = 'Termed';

        return testQuote;
    }

    public static List<Zuora.zApi.SubscribeResult> createTestSubPreviewResult() {
        Zuora.zApi.SubscribeResult subscribePreviewResult = new Zuora.zApi.SubscribeResult();

        if (subPreviewResultUseCase == null || subPreviewResultUseCase == 0) {
            subscribePreviewResult.Success = true;
            subscribePreviewResult.Errors = null;
            subscribePreviewResult.totalTcv = 123.0;
            
            Zuora.zObject inv = new Zuora.zObject('Invoice');
            inv.setValue('AmountWithoutTax',99.0);

            Zuora.zObject invData = new Zuora.zObject('InvoiceData');
            invData.setValue('Invoice', inv);

            subscribePreviewResult.InvoiceDatas = new List<Zuora.zObject>{invData};
        } else {
            subscribePreviewResult.Success = false;

            Zuora.zObject testErr = new Zuora.zObject('Error');
            testErr.setValue('Message', 'Test Error Message');

            subscribePreviewResult.Errors = new List<Zuora.zObject>{testErr};
        }

        return new List<Zuora.zApi.SubscribeResult>{subscribePreviewResult};
    }
  
}