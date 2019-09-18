@isTest(seealldata=false)
public  class UpdateTCVCustomerTypeBatchable_Test{

@testSetup static void DataSetUpClass() {
OrderDecompController.stopCreatingAccount = true;
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Product_flag_mapping__c pfm = new Product_flag_mapping__c(Name='Own_Co_Broke__c',Field_API_name__c='Own_Co_Broke__c',Product_Code__c='COBROKE');
        insert pfm;
           List<Account> acclist = new List<Account>(); 
          Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmail1@test.com';  
        theTestAccount.Account_Sub_Type__c ='Prospect';     
        insert theTestAccount;     
        acclist.add(theTestAccount);
                // Inserting Test Product.
        Product2 theTestProduct         = new Product2(Name = 'Connection(SM) for Co-Brokerage',ProductCode='COBROKE',S_No__c= 2);
        insert theTestProduct;   
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = theTestProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;
          // Inserting Test Orders.
        Order theTestOrders = new Order(EffectiveDate = System.today()+10, Status= 'Created',AccountId = theTestAccount.Id,Fulfillment_Status__c='Fulfilled',Pricebook2Id = thePricebookEntrie.Pricebook2Id);
           insert theTestOrders; 
           
        OrderItem oliAmendList= new OrderItem(Quantity = 1.0,PricebookEntryId = thePricebookEntrie.id,OrderId= theTestOrders.Id, Fulfillment_Status__c ='Fulfilled', UnitPrice= 100.00);
          insert oliAmendList;  
               Asset assets = new Asset();        
            assets.Name = 'test';           
            assets.Fulfillment_Status__c ='Fulfilled' ;
            assets.AccountId = theTestAccount.id;
            assets.Product2Id =theTestProduct.Id;
            assets.Asset_Type__c = 'Parent';
            assets.TCV_Processed__c = '90Days';
            assets.Expired_Date__c = System.Today().addDays(-92);
            assets.Status = 'Expired';
            assets.Total_net__c = 100;   
            assets.Cancellation_Date__c = System.Today();
            assets.Renewal_Start_Date__c = System.Today().AddDays(5);
            assets.order_line_item__c = oliAmendList.Id;         
            insert assets;   
            
           
                 
            theTestOrders.Status='Complete';
            theTestOrders.Fulfillment_Status__c='Fulfilled';
            update theTestOrders;
           // update Assets;  
}

    public static testMethod void mainMethod1(){   
         List<Account> acclist = [Select Id,Name,Primary_Email__c from Account]; 
        test.startTest();
         Database.BatchableContext bc;
        UpdateTCVCustomerTypeBatchable bt = new UpdateTCVCustomerTypeBatchable();
        bt.execute(bc,acclist);
        Database.executeBatch(bt);
        test.stopTest();

  }
  public static testMethod void mainMethod2(){   
         List<Account> acclist = [Select Id,Name,Primary_Email__c from Account]; 
         
          Asset assets1 = new Asset();        
            assets1.Name = 'test';           
            assets1.Fulfillment_Status__c ='Fulfilled' ;
            assets1.AccountId = acclist[0].id;
            assets1.Product2Id =[Select Id,Name from Product2].Id;
            assets1.Asset_Type__c = 'Parent';
            assets1.TCV_Processed__c = 'false';
            assets1.Expired_Date__c = System.Today().addDays(92);
            assets1.Status = 'Active';
            assets1.Total_net__c = 100;   
            assets1.Renewal_Start_Date__c = System.Today().AddDays(5);
            assets1.order_line_item__c = [Select Id from OrderItem].Id;         
            insert assets1;   
        test.startTest();
         Database.BatchableContext bc;
        UpdateTCVCustomerTypeBatchable bt = new UpdateTCVCustomerTypeBatchable();
        bt.execute(bc,acclist);
        Database.executeBatch(bt);
        test.stopTest();

  }
   
}