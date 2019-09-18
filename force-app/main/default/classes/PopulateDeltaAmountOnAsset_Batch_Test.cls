@IsTest(seealldata = false)
public class PopulateDeltaAmountOnAsset_Batch_Test{    
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
      	
      	List<Account> theAccounts = new List<Account>();
        List<string> accountIds = new List<string> ();
        
        theAccounts.add(new Account ( name='XYZ',Type = 'Broker'));
       
        insert theAccounts;  
        for(Account acc :  theAccounts){
            accountIds.add(acc.id);
        } 
      
     // Inserting Test Product.
        Product2 theTestProduct         = new Product2(        
          Name                          = 'Connections(SM) for Seller Bundle',
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
        AccountId                       = theAccounts[0].Id,
        Status                          = 'Created',        
        Fulfillment_Status__c           ='Fulfilled',          
        Pricebook2Id                    = thePricebookEntrie.Pricebook2Id));
	  	
        insert orders;  
        List<BigMachines__Quote__c> bquotes = new List<BigMachines__Quote__c >();
        bquotes.add(new BigMachines__Quote__c(
        BigMachines__Account__c             =  theAccounts[0].Id,
        BigMachines__Status__c              = 'Pending',
        BigMachines_Quote_Type__c           = 'Modify'));
     	insert bquotes;
         
         
        List<BigMachines__Quote_Product__c> bquote       = new List<BigMachines__Quote_Product__c>();
        
        bquote.add(new BigMachines__Quote_Product__c(
        BigMachines__Quote__c           = bquotes[0].Id,
        Line_Type__c               		= 'Renew',
        BigMachines__Product__c         = theTestProduct.Id,
        BigMachines__Quantity__c        = 1,
        BigMachines__Sales_Price__c     = 10,
        Contractedimpressions__c        = 10));
        
        insert bquote; 
         // Inserting OLI with Type = Add
        List<OrderItem> oitem =  new list<OrderItem>();
               
        oitem.add(new OrderItem(
        Quantity                        = 1.0,
        PricebookEntryId                = thePricebookEntrie.id,       
        OrderId                         = orders[0].Id,
        Fulfillment_Status__c           ='Fulfilled',            
        Credit_Amount__c                = 10.00, 
        Line_Type__c                    = 'Renew',   
        UnitPrice                       = 100,  
        Quote_Product__c                = bquote[0].Id));
            
        
       insert oitem ;
      
       // Inserting Test Asset. 
       Asset parentAsset = new Asset(
								        Name                         	= 'Test PAsset SL Delta',
								        AccountId                     	= theAccounts[0].Id,       
								        End_Date__c                  	= Date.today().addDays(-2),
								        Status                       	= 'Active',
								        Product2ID                    	= theTestProduct.Id,
								        Line_Type__c                  	= 'Add',                  
								        Asset_Type__c                 	= 'Parent',
								        Fulfillment_Status__c         	= 'Fulfilled',       
								        start_date__c                 	= Date.today().addDays(-182),
								        Credit_Status__c              	= '',
								      	Order_Line_Item__c            	= oitem[0].Id,
								        Renewal_Order_Product__c       	= oitem[0].Id,
								        Renewal_Start_Date__c =  Date.today().addDays(-1) );
        
        Insert parentAsset;
        Asset fulfillToAsset = new Asset(
								        Name                         	= 'Test FTAsset SL Delta',
								        Parent_Asset__c					= parentAsset.id,
								        AccountId                     	= theAccounts[0].Id,       
								        End_Date__c                  	= Date.today().addDays(-2),
								        Status                       	= 'Active',
								        Product2ID                    	= theTestProduct.Id,
								        Line_Type__c                  	= 'Add',                  
								        Asset_Type__c                 	= SellerLeadUtilityClass.assetTypeFulfillTo,
								        Fulfillment_Status__c         	= 'Fulfilled',       
								        start_date__c                 	= Date.today().addDays(-182)
								         );
        
        Insert fulfillToAsset;
        
        
        
    }
    static testMethod void PopulateDeltaAmountOnAsset_Delta_Test(){
    	Asset parentAssetU = [ select (Select Asset_ID_18_Digit__c from Assets__r where	Asset_Type__c = :SellerLeadUtilityClass.assetTypeFulfillTo limit 1), 
    							Status,Line_Type__c,Fulfillment_Status__c,start_date__c,Credit_Status__c 
    							from Asset where Name = 'Test PAsset SL Delta' limit 1];
    	parentAssetU.Name = 'Test PAsset SL Delta';
    	parentAssetU.Status = 'Active';
    	parentAssetU.Line_Type__c = 'Add';
    	parentAssetU.Fulfillment_Status__c = 'Fulfilled';
    	parentAssetU.start_date__c =  Date.today().addDays(-182);
    	parentAssetU.End_Date__c = Date.today().addDays(-2);
    	parentAssetU.Credit_Status__c = '';
    	
    	update parentAssetU;
    	
    	Test.StartTest();
           
            TurboUtilityClass.assetCountForSOA = 1;
            Test.setMock(WebServiceMock.class, new WebServiceMockImple( parentAssetU.Assets__r[0].Asset_ID_18_Digit__c));
            PopulateDeltaAmountOnAsset_Batch batchInst1 = new PopulateDeltaAmountOnAsset_Batch();
            ID batchprocessid = Database.executeBatch(batchInst1, 1);
            
            PopulateDeltaAmountOnAsset_Batch batchInst2 = new PopulateDeltaAmountOnAsset_Batch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, batchInst2);
        Test.StopTest(); 
    
    }
     
    static testMethod  void PopulateDeltaAmountOnAsset_NoDelta_Test(){
    
         
        Asset parentAssetU = [ select (Select Asset_ID_18_Digit__c from Assets__r where	Asset_Type__c = :SellerLeadUtilityClass.assetTypeFulfillTo limit 1), 
        								Status,Line_Type__c,Fulfillment_Status__c,start_date__c,Credit_Status__c,Order_Line_Item__r.Quote_Product__r.Id 
        						from Asset where Name = 'Test PAsset SL Delta' limit 1];
    	parentAssetU.Name = 'Test PAsset SL Delta';
    	parentAssetU.Status = 'Active';
    	parentAssetU.Line_Type__c = 'Add';
    	parentAssetU.Fulfillment_Status__c = 'Fulfilled';
    	parentAssetU.start_date__c =  Date.today().addDays(-182);
    	parentAssetU.End_Date__c = Date.today().addDays(-2);
    	parentAssetU.Credit_Status__c = '';
        
        update parentAssetU;
        
        BigMachines__Quote_Product__c bmqp = [ select Contractedimpressions__c from BigMachines__Quote_Product__c where Id =:parentAssetU.Order_Line_Item__r.Quote_Product__r.Id limit 1];
       	bmqp.Contractedimpressions__c = 4;
       	update bmqp;
        Test.StartTest();
           
            TurboUtilityClass.assetCountForSOA = 1;
            Test.setMock(WebServiceMock.class, new WebServiceMockImple( parentAssetU.Assets__r[0].Asset_ID_18_Digit__c));
            PopulateDeltaAmountOnAsset_Batch batchInst1 = new PopulateDeltaAmountOnAsset_Batch();
            ID batchprocessid = Database.executeBatch(batchInst1, 1);
            
        Test.StopTest(); 
    
    }
    
    static testMethod void PopulateDeltaAmountOnAsset_Failure_Test(){
    	Asset parentAssetU = [ select Name from Asset where Name = 'Test PAsset SL Delta' limit 1];
    	parentAssetU.Name = 'Test Failure';
    	update parentAssetU;
    	
    	Test.StartTest();
           
            TurboUtilityClass.assetCountForSOA = 1;
            PopulateDeltaAmountOnAsset_Batch batchInst1 = new PopulateDeltaAmountOnAsset_Batch();
            ID batchprocessid = Database.executeBatch(batchInst1, 1);
            
        Test.StopTest(); 
    
    }
    
    private class WebServiceMockImple implements WebServiceMock
    {
    	string asset18DigitId;
    	public WebServiceMockImple( string asset18DigitId){
    		this.asset18DigitId = asset18DigitId;
    	}
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            list<SOA_GetAggregateLeads.GetSellerRecordResponse_element> respList = new list<SOA_GetAggregateLeads.GetSellerRecordResponse_element>();
            SOA_GetAggregateLeads.GetSellerRecordResponse_element resp = new SOA_GetAggregateLeads.GetSellerRecordResponse_element();
            resp.FulfillToAssetId = asset18DigitId;
            resp.TotalLeads = 4;
            resp.TotalLeadsForMonth = 1;
            resp.Error = '';
            respList.add( resp);
            
            SOA_GetAggregateLeads.processResponse_element respele = new SOA_GetAggregateLeads.processResponse_element();
            respele.GetSellerRecordResponse = respList;
            if(request instanceof SOA_GetAggregateLeads.process_element)
                response.put('response_x', respele);
            return;
        }
    }  
    
 }