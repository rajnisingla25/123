@IsTest(seealldata = false)
public class SellerLeadUtilityClass_test {

    
    static testMethod  void SellerLeadUtilityClass_Test(){
        SkipAccountTrigger.skiptrigger = true;
    	DisabledTrigger__c Dtrg = new DisabledTrigger__c();
      	Dtrg.Name = 'Disabled';
      	Dtrg.TaskTrigger__c = UserInfo.getUserName();
      	Dtrg.AssetTrigger__c = UserInfo.getUserName();
      	Dtrg.AccountTrigger__c= UserInfo.getUserName();
      	insert Dtrg;
        // Inserting Test Account.
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Type = 'Broker';
        insert newAccount;  
        list<string> accountIdList = new list<string>();
        accountIdList.add(newAccount.Id);
       // Inserting Test Product.
        Product2 theTestProduct         = new Product2(        
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = SellerLeadUtilityClass.sellerLeadProductCode
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
       
        Orders.add(new Order(
        EffectiveDate                   = System.today(),
            AccountId                       = newAccount.Id,
            Status                          = 'Created',        
            Fulfillment_Status__c           ='Fulfilled',          
            Pricebook2Id                    = thePricebookEntrie.Pricebook2Id//standardPriceBookId         
       ));
      	
      	
        insert orders; 
         
        List<BigMachines__Quote__c> bquotes = new List<BigMachines__Quote__c >();
        
        bquotes.add(new BigMachines__Quote__c(
                    BigMachines__Account__c             = newAccount.Id,       
                    BigMachines__Status__c              = 'Pending',
                    BigMachines_Quote_Type__c           = 'New'));
        
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
        for(Integer index = 0; index < 1; index++){        
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
       List<Asset> pAssets = new List<Asset>();
      
       pAssets.add(new Asset(
	        Name                         = 'Test Asset123 - ',
	        AccountId                     = accountIdList[0],       
	        End_Date__c                  = Date.today().addDays(3),
	        Status                       = 'Active',
	        Product2ID                    = theTestProduct.Id,
	        Line_Type__c                  = 'Add',                  
	        Asset_Type__c                 = 'Parent',
	        Fulfillment_Status__c         = 'Fulfilled',       
	        start_date__c                 = system.today(),   
	        Credit_Status__c              = '',
	        CampaignId__c                 = '12345',
	        Order_Line_Item__c            = oitem[0].Id
          ));
        
       Insert pAssets;
       
       List<Asset> fAssets = new List<Asset>();
        
       fAssets.add(new Asset(
	        Name                         = 'Test Asset345 - ',
	        AccountId                     = accountIdList[0],       
	        End_Date__c                  = Date.today().addDays(3),
	        Status                       = 'Active',
	        Product2ID                    = theTestProduct.Id,
	        Line_Type__c                  = 'Add',                  
	        Asset_Type__c                 = 'Parent',
	        Fulfillment_Status__c         = 'Fulfill To',       
	        start_date__c                 = system.today(),   
	        Credit_Status__c              = '',
	        CampaignId__c                 = '12345',
	        Order_Line_Item__c            = oitem[0].Id,
	        Parent_Asset__c               =pAssets[0].Id
          ));
        
        Insert fAssets;
        
        
        test.starttest();
           Test.setMock(WebServiceMock.class, new WebServiceMockImple());
           SellerLeadUtilityClass.WebService_GetDeliveredLead(pAssets[0].Id);  
           SellerLeadUtilityClass.WebService_GetDeliveredLead(fAssets[0].Id);  
            
        test.stoptest();        
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