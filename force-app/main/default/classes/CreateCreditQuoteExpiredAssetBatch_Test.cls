@IsTest(seealldata = false)
public class CreateCreditQuoteExpiredAssetBatch_Test{    
    private static final Integer COUNTER = 1;
    @testSetup
    static void dataSetup() {
    	SkipAccountTrigger.skiptrigger = true;
    	DisabledTrigger__c Dtrg = new DisabledTrigger__c();
      	Dtrg.Name = 'Disabled';
      	Dtrg.TaskTrigger__c = UserInfo.getUserName();
      	Dtrg.AssetTrigger__c = UserInfo.getUserName();
      	Dtrg.AccountTrigger__c= UserInfo.getUserName();
      	insert Dtrg;
    }
    static testMethod  void CreateCreditQuoteExpiredAssetBatch_Credit_Test(){
		
		List<Account> theAccounts = new List<Account>();
        List<string> accountIds = new List<string> ();
        for(Integer index = 0;index < COUNTER;index++) {
         	theAccounts.add(new Account (
        		name='XYZ',
        		Type = 'Broker'
        	));
        }
        
        insert theAccounts;  
        for(Account acc :  theAccounts){
            accountIds.add(acc.id);
        } 
        system.debug('accountIds'+accountIds.size());
        
   
     // Inserting Test Product.
        Product2 theTestProduct         = new Product2(        
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'TURBO'
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
       List<Order> orders = new List<order>();
       for(Account acc : theAccounts){
        Orders.add(new Order(
        EffectiveDate                   = System.today(),
            AccountId                       = acc.Id,
            Status                          = 'Created',        
            Fulfillment_Status__c           ='Fulfilled',          
            Pricebook2Id                    = thePricebookEntrie.Pricebook2Id//standardPriceBookId         
      ));
      }
        insert orders;  
        List<BigMachines__Quote__c> bquotes = new List<BigMachines__Quote__c >();
        for(Account acc : theAccounts){
        bquotes.add(new BigMachines__Quote__c(
        BigMachines__Account__c             = acc.Id,       
        BigMachines__Status__c              = 'Pending',
        BigMachines_Quote_Type__c           = 'New'
                 ));
                 }
                 insert bquotes;
         
         
         List<BigMachines__Quote_Product__c> bquote       = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote__c acc : bquotes){
        bquote.add(new BigMachines__Quote_Product__c(
        BigMachines__Quote__c           = acc.Id,
        Line_Type__c               = 'Add',
        BigMachines__Product__c           = theTestProduct.Id,
        BigMachines__Quantity__c         = 1,
        BigMachines__Sales_Price__c         = 10,
        Contractedimpressions__c            =10));
        }
        insert bquote; 
         // Inserting OLI with Type = Add
        List<OrderItem> oitem =  new list<OrderItem>();
        for(Integer index = 0; index < COUNTER; index++){        
            oitem.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,       
            OrderId                         = orders[index].Id,
            Fulfillment_Status__c           ='Fulfilled',            
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Add',   
            UnitPrice                       = 100,  
            Quote_Product__c                = bquote[index].Id));
            }
        
         insert oitem ;
      
       // Inserting Test Asset. 
       List<Asset> Assets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
       Assets.add(new Asset(
         Name                         = 'Test Asset123 - ',
        AccountId                     = theAccounts[index].Id,       
         End_Date__c                  = Date.today().addDays(3),
         Status                       = 'Expired',
        Product2ID                    = theTestProduct.Id,
        Line_Type__c                  = 'Cancel',                  
        Asset_Type__c                 = 'Parent',
        Fulfillment_Status__c         = 'Fulfilled',       
        start_date__c                 = system.today(),   
        Credit_Status__c              = '',
        CampaignId__c                 = '12345',
        Order_Line_Item__c            = oitem[index].Id
          ));
        }
        Insert Assets;
        for( Asset ast :Assets){
            ast.Fulfillment_Status__c = 'Fulfilled';
            
        }
        update Assets;
        
        
        Test.StartTest();
           
            TurboUtilityClass.assetCountForSOA = 1;
            Test.setMock(WebServiceMock.class, new WebServiceMockImple());
            CreateCreaditQuoteForExpiredAssetBatch batchInst1 = new CreateCreaditQuoteForExpiredAssetBatch();
            ID batchprocessid = Database.executeBatch(batchInst1, 1);
            
            CreateCreaditQuoteForExpiredAssetBatch batchInst2 = new CreateCreaditQuoteForExpiredAssetBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, batchInst2);
        Test.StopTest(); 
    
    }
    static testMethod  void CreateCreditQuoteExpiredAssetBatch_NoCredit_Test(){
    	
    	SkipAccountTrigger.skiptrigger = true;
       
    	DisabledTrigger__c Dtrg = new DisabledTrigger__c();
      	Dtrg.Name = 'Disabled';
      	Dtrg.TaskTrigger__c = UserInfo.getUserName();
      	Dtrg.AssetTrigger__c = UserInfo.getUserName();
      	Dtrg.AccountTrigger__c= UserInfo.getUserName();
      	insert Dtrg;
        
        List<Account> theAccounts = new List<Account>();
        List<string> accountIds = new List<string> ();
        for(Integer index = 0;index < COUNTER;index++) {
         	theAccounts.add(new Account (
        	name='XYZ',
        	Type = 'Broker'));
        }
        insert theAccounts;  
        for(Account acc :  theAccounts){
            accountIds.add(acc.id);
        } 
        system.debug('accountIds'+accountIds.size());
        
   
     // Inserting Test Product.
        Product2 theTestProduct         = new Product2(        
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'TURBO'
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
       List<Order> orders = new List<order>();
       for(Account acc : theAccounts){
        Orders.add(new Order(
        EffectiveDate                   = System.today(),
            AccountId                       = acc.Id,
            Status                          = 'Created',        
            Fulfillment_Status__c           ='Fulfilled',          
            Pricebook2Id                    = thePricebookEntrie.Pricebook2Id//standardPriceBookId         
      ));
      }
        insert orders;  
        List<BigMachines__Quote__c> bquotes = new List<BigMachines__Quote__c >();
        for(Account acc : theAccounts){
        bquotes.add(new BigMachines__Quote__c(
        BigMachines__Account__c             = acc.Id,       
        BigMachines__Status__c              = 'Pending',
        BigMachines_Quote_Type__c           = 'New'
                 ));
                 }
                 insert bquotes;
         
         
         List<BigMachines__Quote_Product__c> bquote       = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote__c acc : bquotes){
        bquote.add(new BigMachines__Quote_Product__c(
        BigMachines__Quote__c           = acc.Id,
        Line_Type__c               = 'Add',
        BigMachines__Product__c           = theTestProduct.Id,
        BigMachines__Quantity__c         = 1,
        BigMachines__Sales_Price__c         = 10,
        Contractedimpressions__c            =20));
        }
        insert bquote; 
         // Inserting OLI with Type = Add
        List<OrderItem> oitem =  new list<OrderItem>();
        for(Integer index = 0; index < COUNTER; index++){        
            oitem.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,       
            OrderId                         = orders[index].Id,
            Fulfillment_Status__c           ='Fulfilled',            
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Add',   
            UnitPrice                       = 100,  
            Quote_Product__c                = bquote[index].Id));
            }
        
         insert oitem ;
      
       // Inserting Test Asset. 
       List<Asset> Assets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
       Assets.add(new Asset(
         Name                         = 'Test Asset123 - ',
        AccountId                     = theAccounts[index].Id,       
         End_Date__c                  = Date.today().addDays(3),
         Status                       = 'Expired',
        Product2ID                    = theTestProduct.Id,
        Line_Type__c                  = 'Cancel',                  
        Asset_Type__c                 = 'Parent',
        Fulfillment_Status__c         = 'Fulfilled',       
        start_date__c                 = system.today(),   
        Credit_Status__c              = '',
        CampaignId__c                 = '12345',
        Order_Line_Item__c            = oitem[index].Id
          ));
        }
        Insert Assets;
        for( Asset ast :Assets){
            ast.Fulfillment_Status__c = 'Fulfilled';
            
        }
        update Assets;
        
        
        Test.StartTest();
           
            TurboUtilityClass.assetCountForSOA = 10;
            Test.setMock(WebServiceMock.class, new WebServiceMockImple());
            CreateCreaditQuoteForExpiredAssetBatch batchInst1 = new CreateCreaditQuoteForExpiredAssetBatch();
            ID batchprocessid = Database.executeBatch(batchInst1, 1);
            
        Test.StopTest(); 
    
    }
    private class WebServiceMockImple implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            list<SOA_GetAggregateImpressions.ImpressionRecord_element> respList = new list<SOA_GetAggregateImpressions.ImpressionRecord_element>();
            SOA_GetAggregateImpressions.ImpressionRecord_element resp = new SOA_GetAggregateImpressions.ImpressionRecord_element();
          
            resp.CampaignId = '12345';
            resp.Impressions = 10;
            resp.count = 1;
            resp.eventdate = DateTime.now();
            respList.add( resp);
            
            SOA_GetAggregateImpressions.processResponse_element respele = new SOA_GetAggregateImpressions.processResponse_element();
            respele.ImpressionRecord = respList;
            if(request instanceof SOA_GetAggregateImpressions.process_element)
                response.put('response_x', respele);
            return;
        }
    }  
    
 }