@isTest(seeallData=false)
public class Z_scheduleProcessInputTest {
  /*  private static final Integer COUNTER = 5;
    Static testmethod void Z_scheduleProcessInputTest(){
         //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
        // Inserting Test Account.
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c = 'hsingh@appirio.com';
        insert newAccount;
        
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',newAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;            
        
        Asset ast= new Asset(
            Name = 'Test Asset -22 ',
            AccountId = newAccount.Id,
            Price = 10,
            End_Date__c = Date.today().addDays(22),
            Auto_Renewal__c = 'Yes',
            Status = 'Active'
            );      
        // Inserting Test Product.
        Product2 theTestProduct = new Product2(
          Name = 'Connection(SM)',
          Family = 'Hardware',
          S_No__c = 2,
          ProductCode = 'COBROKE'
        );
        insert theTestProduct;
        System.debug('######-TESTING-Product'+ theTestProduct.id);
        // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = theTestProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
        System.debug('######-TESTING-PE= '+ thePricebookEntrie);
        
        // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',  
                     
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
        
         // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',  
            Contract_Term__c = '12',         
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Add', 
            Billing_Period__c = 'Annual',
            Override_Term__c = 2,        
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems; 
         
         Zuora__CustomerAccount__c bacc = new Zuora__CustomerAccount__c();
            bacc.Zuora__Account__c = newAccount.id;
            bacc.Name = 'Test Billing Account';
            bacc.Zuora__Zuora_Id__c = 'Test Insert Bacc';
         insert bacc;
         
         zqu__Quote__c zc = New zqu__Quote__c(
            zqu__Account__c = newAccount.id,
            zqu__BillToContact__c = testContact.id,            
            zqu__ZuoraAccountID__c= '2c92c0f84f2ac59d014f3812491f5a0c',
            zqu__SubscriptionType__c= 'New Subscription',
            Charge_To_Be_Updated__c = false,
            Order_Product__c = theTestOrderItems[0].Id,
            zqu__Status__c = 'New');    
         Insert Zc;
         
         
       test.startTest();        
        Z_scheduleProcessInput sh1 = new Z_scheduleProcessInput(theTestOrderItems[0],newAccount.Id,newAccount.Id,'New Subscription');  
            Z_scheduleProcessInput.errorMessage = 'Billing Period is required';
            Z_scheduleProcessInput.errorStatus = true;
               
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);       
        Test.stopTest();
    } 
    Static testmethod void Z_scheduleProcessInputTest1(){
         //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
        // Inserting Test Account.
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c = 'hsingh@appirio.com';   
        insert newAccount;
        
          Contact testContact = TestDataFactory.createContact('Test Contact','TestL',newAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        
          Asset ast= new Asset(
            Name = 'Test Asset - 15',
            AccountId = newAccount.Id,
            Price = 10,
            End_Date__c = Date.today().addDays(15),
            Auto_Renewal__c = 'Yes',
            Status = 'Active'
            );
            
        // Inserting Test Product.
        Product2 theTestProduct = new Product2(
          Name = 'Connection(SM) for Co-Brokerage',
          Family = 'Hardware',
          S_No__c = 2,
          ProductCode = 'COBROKE'
        );
        insert theTestProduct;
        System.debug('######-TESTING-Product'+ theTestProduct.id);
        // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = theTestProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
        System.debug('######-TESTING-PE= '+ thePricebookEntrie);
        
        // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',  
                     
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
        
         // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',  
            Contract_Term__c = '12',         
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Cancel', 
            Billing_Period__c = 'Annual',
            Buyout_Amount__c = null,      
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems; 
        Zuora__CustomerAccount__c bacc = new Zuora__CustomerAccount__c();
            bacc.Zuora__Account__c = newAccount.id;
            bacc.Name = 'Test Billing Account';
            bacc.Zuora__Zuora_Id__c = 'Test Insert Bacc';
         insert bacc; 
       
        zqu__Quote__c zc = New zqu__Quote__c(
            zqu__Account__c = newAccount.id,
            zqu__BillToContact__c = testContact.id,            
            zqu__ZuoraAccountID__c= '2c92c0f84f2ac59d014f3812491f5a0c',
            zqu__SubscriptionType__c= 'New Subscription',
            Charge_To_Be_Updated__c = false,
            Order_Product__c = theTestOrderItems[0].Id,
            zqu__Status__c = 'New');    
        Insert Zc;
        
           
       test.startTest();                 
            Z_scheduleProcessInput sh1 = new Z_scheduleProcessInput(theTestOrderItems[0],newAccount.Id,newAccount.Id,'Cancel Subscription');            
                Z_scheduleProcessInput.errorMessage='Buyout Amount is required';
                Z_scheduleProcessInput.errorStatus=true; 
                      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
        Test.stopTest();
       }  */
}