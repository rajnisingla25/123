// Test class for RealsuiteWelcomeEmailCompController
@isTest
public class RealsuiteWelcomeEmailCompController_Test {
    
     static testMethod  void RealsuiteWelcomeEmailCompController_Test(){
    
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Type = 'Broker';
        insert newAccount;    
    OrderDecompController.stopCreatingAccount = true;
        // Inserting Test Product.
        Product2 theTestProduct         = new Product2(        
          Name                          = 'Respond',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'RESPOND'
        );
        insert theTestProduct;
        
        
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = theTestProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;
 
        // Inserting Test Orders.
       
        Order ord = new Order();
            ord.EffectiveDate                   = System.today();
            ord.EndDate                   		= System.today();
            ord.AccountId                       = newAccount.Id;
            ord.Status                          = 'Created';        
            ord.Fulfillment_Status__c           ='Fulfilled';          
            ord.Pricebook2Id                    = thePricebookEntrie.Pricebook2Id;//standardPriceBookId         
            ord.products__c = 'RSPOND';
        insert ord;  
         
        
        Asset asst1                         = new Asset();
        asst1.Name                          = 'Test Asset123 - ';
        asst1.AccountId                     = newAccount.Id;        
        asst1.End_Date__c                   = Date.today().addDays(3);
        asst1.Status                        = 'Active';
        asst1.Product2ID                    = theTestProduct.Id;
        asst1.Line_Type__c                  = 'Add';                     
        asst1.Asset_Type__c                 = 'Parent';
        asst1.Fulfillment_Status__c         = 'Fulfilled';        
        asst1.start_date__c                 = system.today();      
        insert asst1;  
        
        // Inserting OLI with Type = Add
        
        OrderItem oitem =  new OrderItem();
            oitem.Quantity                        = 1.0;
            oitem.PricebookEntryId                = thePricebookEntrie.id;        
            oitem.OrderId                         = ord.Id;
            oitem.Fulfillment_Status__c           ='Fulfilled';
            oitem.Asset__c                        = asst1.Id;
            oitem.Credit_Amount__c                = 10.00; 
            oitem.Line_Type__c                    = 'Add';   
            oitem.UnitPrice                       = 100;  
        
         insert oitem ;
        test.starttest();
         RealsuiteWelcomeEmailCompController obj = new RealsuiteWelcomeEmailCompController();
         obj.getOrdId();
         obj.setOrdId(ord.Id);
         obj.getOrderItems(ord.Id);
         test.stoptest();
        
    }

}