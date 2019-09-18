@isTest(seeAllData =false)
public class ViewAssetValueController_Test{
    public static testMethod void main(){           
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
    
DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;         
    Account newAccount = mtduc.CreateBrokerAccountSingle();
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
        S_No__c = 2,
        Family = 'Realtor'
      ));
    }
    insert theTestProducts;
    
    System.debug('theTestProducts:');

    // Extracting Standard Price Book ID.
    Id theStandardPriceBookId = Test.getStandardPricebookId();

    // Inserting Price Book Entries For The Standard Price Book.
    PricebookEntry thePricebookEntrie = new PricebookEntry();
         
        thePricebookEntrie.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProducts[0].Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;      
    insert thePricebookEntrie;
System.debug('theTestProducts:' + thePricebookEntrie.id);
          
     Order  Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Fulfilled';
        Orders.Status = 'Created';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = theStandardPriceBookId;
        Orders.EffectiveDate = system.today();
        insert Orders;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';        
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.status = 'active';
        assets.Product2Id = theTestProducts[0].id;
        assets.Fulfillment_Status__c = 'Fulfilled';        
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();       
        assets.Auto_Renewal__c  = 'Yes';
        assets.Price = 10.00;
        assets.End_Date__c = system.today().addDays(10);       
        insert assets;
        
       OrderItem theOrderItem = new OrderItem();
           
          theOrderItem.Quantity = 1.00;
          theOrderItem.PricebookEntryId= thePricebookEntrie.Id;
          theOrderItem.OrderId = Orders.Id;
          theOrderItem.UnitPrice = 100.00;
          theOrderItem.Start_Date__c = Date.today();
          theOrderItem.Asset__c = assets.Id;
          theOrderItem.Fulfill_To_Account__c = newAccount.Id;
          theOrderItem.Inactivate_Date__c = Date.today();
          theOrderItem.Line_Type__c  = 'Add';
    try{    
    insert theOrderItem;    
        }catch(exception e){}
        Decimal Price = 10.0;
        Decimal TotalPrice = 50.0;
        boolean isSelected = true;
        PageReference pageRef = Page.ViewAssetValue;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('accId', newAccount.id);
        ViewAssetValueController VAV = new ViewAssetValueController();
        
        ViewAssetValueController.wrapAsset VAV1 = new ViewAssetValueController.wrapAsset(assets,Price,TotalPrice);
        VAV1.assets = assets;
        VAV1.isSelected = true;
        VAV1.Price = 10.0;
        VAV1.TotalPrice = 50.0;
     } 
    public static testMethod void main1(){           
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg; 
     
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    Product2 newProduct = mtduc.CreateProductSingle(); 
           
        Asset assets = new Asset();
         assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';        
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.status = 'active';
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';        
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();       
        assets.Auto_Renewal__c  = 'Yes';
        assets.Price = 10.00;
        assets.End_Date__c = system.today().addDays(10);
          
   insert assets;
        
        Decimal Price = 10.0;
        Decimal TotalPrice = 50.0;
        boolean isSelected = true;
        PageReference pageRef = Page.ViewAssetValue;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('accId', newAccount.id);
        ViewAssetValueController VAV = new ViewAssetValueController();
        ViewAssetValueController.wrapAsset VAV1 = new ViewAssetValueController.wrapAsset(assets,Price,TotalPrice);
     } 
}