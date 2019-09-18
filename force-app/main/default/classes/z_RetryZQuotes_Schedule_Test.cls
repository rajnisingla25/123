@isTest(SeeAllData=True)
public class z_RetryZQuotes_Schedule_Test{
public static String CRON_EXP = '0 0 0 * * ?';
Public static testMethod void setupData(){
    
    Account theAccount = new Account();
    theAccount.Name = 'Testaccount';
    theAccount.ShippingStreet = 'Test Street';
    theAccount.ShippingCity = 'City';
    theAccount.ShippingState = 'State';
    theAccount.ShippingPostalCode = '12345';
    insert theAccount;
    
      Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      S_No__c = 2
    );
    insert theTestProduct;
    
    Id StandardPriceBookId = Test.getStandardPricebookId();
    PricebookEntry thePricebookEntrie = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProduct.Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;        
         insert thePricebookEntrie;
         
        Order order = new Order();
        order.AccountId = theAccount.Id;
        order.EffectiveDate = Date.Today();
        order.Status = 'Created';
        order.Fulfillment_Status__c = 'Pending Fulfillment';     
        order.Pricebook2Id = Test.getStandardPricebookId();
        insert order;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = order.Id;     
       oi.UnitPrice=10.00;
        oi.Quantity = 1;
        
        oi.PricebookEntryId = thePricebookEntrie.id;          
        oi.Term_Start_Date__c = Date.today();
        oi.Start_Date__c = Date.today();
        
         oi.Zuora_Status__c = 'Error';
        insert oi;
        zqu__Quote__c testQuote = new zqu__Quote__c();
        testQuote.Name = 'my test quote';
         testQuote.Order_Product__c = oi.Id;
        testQuote.zqu__Currency__c = 'USD';
        testQuote.zqu__ValidUntil__c = System.today();
        testQuote.zqu__SubscriptionTermStartDate__c = System.today();
        testQuote.zqu__Status__c = 'New';
        testQuote.zqu__InitialTerm__c = 12;
        testQuote.zqu__RenewalTerm__c = 12;
        testQuote.zqu__Subscription_Term_Type__c = 'Termed';
        insert testQuote;
        
        List<Order> Sendlist = new List<Order>();
        Sendlist.add(order);
        
        Test.startTest();
        SkipOrderItemTrigger.isSkipTrg();
        System.schedule('Test Check', CRON_EXP, new z_RetryZQuotes_Schedule());      
        z_RetryZQuotes_Schedule.Scheduleremainingorderlist(60, Sendlist);
        
        Test.stopTest();
}
}