@isTest(seeAllData = false)
Private class ChildCaseCreationUponOrder_Test{
    static testmethod void ChildCaseCreationUponOrderTest(){
    //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg; 
     //Inserting Test Account
    Account brokerAccount = TestDataFactory.createAccount('Broker Account', null, false);
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        brokerAccount.Type = 'Broker';
        brokerAccount.Primary_Email__c = 'brokerAccount@b2b.com';
        insert brokerAccount; 
     
    
     Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();     
   CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;
    //Case testCase = TestDataFactory.createCase('Invalid Rights','New','Retention' ,'Test Description', null,brokerAccount.Id,true); 
             
    //System.debug('theTestCase:' + testCase.Id);

     List<String> theProductNames = new List<String> {
    'Connection(SM) for Co-Brokerage',
    'Digital Ad Package',
    'Market Builder',
    'Top Producer IDX'
  };
      // Inserting Products.
    List<Product2> theTestProducts = new List<Product2>();
    for(String theProductName : theProductNames) {
      theTestProducts.add(new Product2(
        Name = theProductName,
        S_No__c = 2
       // Family = 'Realtor'
      ));
    }
    insert theTestProducts;
    
    System.debug('theTestProducts:');


    // Extracting Standard Price Book ID.
   Id theStandardPriceBookId = Test.getStandardPricebookId();
   
 
    // Inserting Price Book Entries For The Standard Price Book.
    PricebookEntry thePricebookEntrie1 = new PricebookEntry();
         
        thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie1.Product2Id = theTestProducts[0].Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;
      
    insert thePricebookEntrie1;
System.debug('theTestProducts:' + thePricebookEntrie1.id);
   
    // Inserting Test Orders.
    List<Order> Orders = new List<Order>();
    Order theTestOrder = new Order();  
      
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
       // theTestOrder.Case__c = testCase.Id;
        theTestOrder.AccountId = brokerAccount.Id;
        theTestOrder.Pricebook2Id = theStandardPriceBookId;
        theTestOrder.Is_OLI_Creation_Complete__c = false;
        //theTestOrder.ContractId = c.id;
        theTestOrder.Fulfillment_Status__c ='Fulfilled';
        
      Orders.add(theTestOrder);
    insert Orders;
    System.debug('theTestOrders:' + theTestOrder.id );

    // Inserting Order Line Items.
    
   OrderItem theOrderItem = new OrderItem();
           
          theOrderItem.Quantity = 1.00;         
         theOrderItem.PricebookEntryId = thePricebookEntrie1.id;
          theOrderItem.OrderId = theTestOrder.Id;
          theOrderItem.UnitPrice = 1000;
          theOrderItem.Start_Date__c = Date.today();
          theOrderItem.Inactivate_Date__c = Date.today();             
          theOrderItem.Line_Type__c  = 'Add';
        
    insert theOrderItem;    
  System.debug('theOrderItems:' + theOrderItem.id );
  
     // Inserting Test Assets.
    Asset theTestAsset = new Asset();
    
      theTestAsset.Name = 'The Test Asset';
        theTestAsset.Status = 'Active';
        theTestAsset.AccountId = brokerAccount.Id;
        theTestAsset.At_Risk__c = false;
        theTestAsset.Fulfillment_Status__c = 'Fulfilled';
        theTestAsset.Asset_Type__c = 'Parent';
        theTestAsset.Order_Line_Item__c = theOrderItem.Id;
    insert theTestAsset;
    
  System.debug('theTestAsset:' + theTestAsset.Id);              
                                
                  theTestOrder.Status = 'Complete';            
                    Update theTestOrder;                    
              //System.debug('theTestOrder:' + theOrderItem.id);                  
                      theOrderItem.Line_Type__c  = 'Credit';                            
                   Update theOrderItem;                   
         Test.startTest();       
        //System.debug('theOrderItem:' + theOrderItem.id);
         ChildCaseCreationUponOrder  IP = new ChildCaseCreationUponOrder();
         IP.ChildCaseCreationUponOrderUpdate(Orders);           
          Test.stopTest();
          
            
    }
}