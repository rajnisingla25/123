@isTest
public class orderitemtriggerTests {
    static testMethod void orderiteminsert(){
        OrderDecompController.stopCreatingAccount = true;
        Integer COUNTER = 5;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
         id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
         Account newAccount = new Account();
            newAccount.RecordTypeId = rectypidaccount;
            newAccount.name = 'XYZ';
            newAccount.Phone = '1234567890';
            newAccount.BillingStreet = 'Am Tierpark 16';
            newAccount.BillingCity = 'Cologne';
            newAccount.BillingPostalCode = '54321';
            newAccount.BillingState = 'Nordrhein-Westfalen';
            newAccount.BillingCountry = 'Germany';
            newAccount.Primary_Email__c = 'ra@gmail.com';
            newAccount.Home_Phone__c = '1234567890';
            newAccount.Work_Phone__c = '1234567890';
            newAccount.Mobile1__c = '1234567890';
            newAccount.Mobile2_Other__c = '1245787';
            newAccount.party_id__c = '206084041';
            //newAccount.Ownerid=u.id;
            insert newAccount;
            
            Contract c =new Contract();
            c.Accountid=newAccount.id;
            //c.Status='Draft';
            insert c;

    // Inserting Test Product.
    Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      ProductCode = 'Advantage',
      S_No__c = 2
    );
    insert theTestProduct;
    // Extracting Standard Price Book ID.
    Id StandardPriceBookId = Test.getStandardPricebookId();
    
    // Inserting Price Book Entries For The Standard Price Book.
    PricebookEntry thePricebookEntrie = new PricebookEntry();
         
        thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProduct.Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;        
         insert thePricebookEntrie;
        Product2 theTestProduct1         = new Product2(
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Software',
          S_No__c                       = 1,
          ProductCode                   = 'Showcase'
        );
        insert theTestProduct1;
 
    //PriceBook2 theStandardPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true];    
    //Id standardPriceBookId = theStandardPriceBook.Id;
      

    // Extracting Standard Pricebook Entry.
    PricebookEntry thePricebookEntry = [SELECT Id, Product2Id,product2.ProductCode,Pricebook2Id, UnitPrice FROM PricebookEntry 
                                                            WHERE isActive = true LIMIT 1];//AND Pricebook2Id = :standardPriceBookId 
       
    // Inserting Test Orders.
    List<Order> theTestOrders = new List<Order>();
    for(Integer index = 0;index < COUNTER;index++) {
      theTestOrders.add(new Order(
        EffectiveDate = Date.today(),
        Status = 'Created',
        AccountId = newAccount.Id,
        Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
      ));
    }
    insert theTestOrders;

    // Inserting Test Order Item.
    List<OrderItem> theTestOrderItems = new List<OrderItem>();
    for(Order theTestOrder : theTestOrders) {
      theTestOrderItems.add(new OrderItem(
        Quantity = 1.00,
        PricebookEntryId =thePricebookEntrie.id,// thePricebookEntrie.id,
        OrderId = theTestOrder.Id,
        UnitPrice = 100.00,
        Fulfillment_Status__c = 'Pending Fulfillment'
      ));
    }
      insert theTestOrderItems;
        List<OrderItem> TestOrderItems = new List<OrderItem>();
        for(OrderItem ordi:theTestOrderItems){
            ordi.Fulfillment_Status__c = 'Fulfilled';
            TestOrderItems.add(ordi);
        }
        Update TestOrderItems;
    }
    
}