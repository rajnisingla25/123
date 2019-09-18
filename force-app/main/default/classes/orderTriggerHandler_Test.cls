@isTest(seeAllData=false)
private class orderTriggerHandler_Test {
private static final Integer COUNTER = 5;
     private static testMethod void orderTriggerHandler_Test() {
     OrderDecompController.stopCreatingAccount = true;
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
       Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
     
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;      
        
    // Inserting Test Account.
    Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
    newAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert newAccount;
        
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
        map<ID,Order> newMap = new map<ID,Order>();        
        map<ID,Order> oldMap = new map<ID,Order>(); 
        
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
        
        
     Asset asst1 = new Asset();
            asst1.Name = 'Test Asset - ';
            asst1.AccountId = theTestOrders[0].AccountId;
            asst1.Price = 10;
            asst1.End_Date__c = Date.today().addDays(3);
            asst1.Status = 'Active';
            asst1.Product2ID= theTestProduct.Id;
            asst1.Line_Type__c = 'Add';                     
            asst1.Asset_Type__c = 'Parent';
            asst1.Fulfillment_Status__c = 'Fulfilled';           
            asst1.Daily_Rate_on_Asset__c = 3.20;
            asst1.Total_Net__c = 50.21;
            asst1.start_date__c = system.today();           
          insert asst1;  
          
        // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = asst1.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
         
     orderTriggerHandler handler = new orderTriggerHandler();
     handler.insertCasesBrk(theTestOrders);
     handler.insertCasesAgnt(theTestOrders);
   }  
 }