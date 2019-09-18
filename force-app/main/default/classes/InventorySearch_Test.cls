@istest(seealldata=false)
public class  InventorySearch_Test {
  public static TestMethod Void InventorySearch_Test(){
    //Insertion  of setting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
    // created and accessing a new Test Account  
          Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
         
          insert testAccount; 
       
          Test.startTest();
          ApexPages.currentPage().getParameters().put('id',testAccount.id);
             
           InventorySearch inv = new InventorySearch();
           List<InventorySearch.WLJson> Json = new List<InventorySearch.WLJson>();
           List<InventorySearch.Invlist> Invlist = new List<InventorySearch.Invlist>();
         
           InventorySearch.WLJson WLJsonVar = new InventorySearch.WLJson();
             WLJsonVar.area='area';
      WLJsonVar.area_type='area_type';
      WLJsonVar.part_number='part_number';
      WLJsonVar.product_name='product_name';
      WLJsonVar.market_type='market_type';
      WLJsonVar.product_size='product_size';
      WLJsonVar.lead_routing='lead_routing';
      
      WLJsonVar.quantity=1;
      WLJsonVar.allocated='allocated';
      WLJsonVar.secondary_cities   = '';
      //WLJsonVar.forecast_lead   = '';
      WLJsonVar.available=2;
      
      WLJsonVar.available_presale=1;
      WLJsonVar.presale='presale';
      WLJsonVar.clc='clc';
      WLJsonVar.reserved_presale='reserved_presale';
      WLJsonVar.sold='sold';
      WLJsonVar.party_available='party_avialble';
      WLJsonVar.party_presale='party_presale';
      WLJsonVar.party_reserved='party_reserved';
      WLJsonVar.party_reserved_presale='party_reserved_presale';
      WLJsonVar.customer_min_quantity='customer_min_quantity';
      WLJsonVar.party_sold='party_sold';
      WLJsonVar.market_name='market_name';
      WLJsonVar.city='city';
      WLJsonVar.county='city';
      WLJsonVar.state_id='state_id';
      
      WLJsonVar.price_tier=2;
      WLJsonVar.inventory_market_status='inventory_market_status';
      WLJsonVar.cost_per_action='cost_per_action';
      WLJsonVar.market_key='market_key';
      WLJsonVar.distance='distance';
      WLJsonVar.flex_unit_price='flex_unit_price';
      WLJsonVar.fast_unit_price='fast_unit_price';
      WLJsonVar.item_details = new list<InventorySearch.BundleZipDetails>();
      
   //declaration of class variables
    
    Inv.MyUserProfileManagerId = 'test string';
    Inv.MyUserTimezone = 'test string';
    Inv.MyTransactionId = 'test string';
    Inv.MyLineItemId = 'test string';
    Inv.MyProductName = 'test string';
    Inv.MyProductType = 'test string';
    Inv.MyProductSize = 'test string';
    Inv.MyInventoryPool = 'test string';
    Inv.MyMarketName = 'test string';
    Inv.MyPartyId = 'test string';
    Inv.MyLeadType = 'test string';
    Inv.MyMarketState = 'test string';
    Inv.MyReservedQty = 'test string';
    Inv.MyMarketId = 'test string';
    Inv.MyLockReleaseDate = 'test string';
    Inv.MyInventorystatus = 'test string';
    Inv.MyCreatedDate = 'test string';
    Inv.MyUpdatedDate = 'test string';
    Inv.MyReservedBy = 'test string';
    Inv.MyUserFullName = 'test String';  
    Inv.MyUserProfileId = 'test string';
    Inv.MyUserLocale = 'test string';
    Inv.stateUrl = 'test string';
    Inv.MyValue1 =  'test string';
    Inv.inputText1 = 'test string';
    Inv.mFilterType='Zip Code';
    //WLJSONList.a  
      
    //Inv.mMyPostalCode = 'test postal code';
  //  InventorySearch.WLJson();
    Inv.StoreMainParameters();
    Inv.setPhone('7828473645');
    Inv.getPhone();
    Inv.setReservation('TestReservationId');
    Inv.getReservation();
    Inv.setMyMethod('TestMethod');
    Inv.getMyMethod();
    Inv.setToken('TestToken');
    Inv.getToken();
    Inv.setDegree('TestDegree');
    Inv.getDegree();
    Inv.setSlotSize('8');
    Inv.getSlotSize();
    Inv.setLeadRoutingType('Test Lead Routing Type');
    Inv.getLeadRoutingType();
    Inv.setStatus('Test Status');
    Inv.getStatus();
    Inv.setJSON('Test JSON');
    Inv.getJSON();
    Inv.setAccountId('Test Account Id');
    Inv.getAccountId();
    Inv.setNotes('Test Notes');
    Inv.getNotes();
    Inv.setqtyinterested('Test Quantity Interested');
    Inv.getqtyinterested();
    Inv.setOperation('Test Operation');
    Inv.getOperation();
    Inv.setMyOrderBy('Test Order By');
    Inv.getMyOrderBy();
    Inv.setMyFilter('Test Filter');
    Inv.getMyFilter();
    Inv.getFilterList();
    Inv.setFilterType('Test Filter Type');
    Inv.getWaitlistStatusItems();
    Inv.setMyLimit('Test Limit');
    Inv.getMyLimit();
    Inv.getWaitlistStatus();
    Inv.getAccountName();
    Inv.setWaitlistStatus('Test Wait List Status');
    Inv.AssignFilterValue('Test Assign Filter Value');
    Inv.getStates();
    Inv.getProducts();
    Inv.getTableFilterList();
    Inv.getFilterType();
    Inv.setFilterType('Country');
    Inv.getInputList();
    Inv.getInputType();
    Inv.getInputValue();
    Inv.setInputType('Test');
    Inv.getInputValue();
    Inv.getProduct();
    Inv.getCounty();
    Inv.getState();
    Inv.SetState('Test');
    Inv.SetProduct('Test');
    Inv.SetCounty(' County');
    Inv.setInputValue('Test');
    Inv.submit();
    Inv.SetPageSize();
     Inv.getLeadRoutingType(); 
    inv.setLeadRoutingType('Test');
    //Inv.Invlist();
    //Inv.setMyInvList();
  String mMyPool='city';
      
           Inv.mFilterType=null;
      Inv.mProduct=null;
       Inv.GetWaitlistfromWebService();
     Inv.mFilterType='city';
    Inv.GetWaitlistfromWebService();
           Inv.mFilterType='state';
    Inv.GetWaitlistfromWebService();
    Inv.mFilterType='county';
    Inv.GetWaitlistfromWebService();
    Inv.mFilterType='postal_code';
    Inv.GetWaitlistfromWebService();
      Inv.mFilterType = 'Waitlist Status';
      Inv.AssignFilterValue('string');
       Inv.mFilterType = 'Waitlist Type';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'No of Records';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'Inventory Pool';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'Page No';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'Zip Code';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'City';
      Inv.AssignFilterValue('string');
         Inv.mFilterType = 'County';
      Inv.AssignFilterValue('string');
    
      
      
      Account acct_temp;
       string mParty_Id;

        acct_temp = [SELECT Id, Name, Site ,Party_ID__c,Phone FROM Account
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        mParty_Id = acct_temp.Party_ID__c;
  
        inv.getCounty();
        inv.SetCounty('test county');
        inv.getState();
        inv.SetState('test state');
        inv.SetProduct('test product'); 
        inv.getWaitlistStatus();
        inv.setWaitlistStatus('test waitlist status');
        inv.getWaitlistStatusItems();
        inv.makeSOACallforGet();
        inv.submit();
        inv.setPageSize();   
        inv.StoreMainParameters(); 
        inv.getTableFilterList();
        inv.getStateVal();
        inv.getItems();
        inv.getStatus();
        
        inv.setStatus('test status');
        
        InventorySearch.InvList invListVar = new InventorySearch.InvList();
        invListVar.area = 'Test Area';   
        invListVar.area_type  = 'Test Area Type'; 
        invListVar.part_number  = 'Test part_number'; 
        invListVar.product_name  = 'Test product_name'; 
        invListVar.market_type  = 'Test market_type'; 
        invListVar.product_size  = 'Test product_size'; 
        invListVar.lead_routing  = 'Test lead_routing'; 
        invListVar.allocated  = 'Test allocated'; 
        invListVar.presale  = 'Test presale'; 
        invListVar.clc  = 'Test Clc'; 
        invListVar.reserved_presale  = 'Test reserved_presale'; 
        invListVar.sold  = 'Test sold'; 
        invListVar.party_available  = 'Test party_available'; 
        invListVar.party_presale  = 'Test party_presale'; 
        invListVar.party_reserved  = 'Test party_reserved'; 
        invListVar.customer_min_quantity  = 'Test customer_min_quantity'; 
        invListVar.party_reserved_presale  = 'Test party_reserved_presale'; 
        invListVar.party_sold  = 'Test party_sold'; 
        invListVar.market_name  = 'Test market_name'; 
        invListVar.city  = 'Test city'; 
        invListVar.county  = 'Test county'; 
        invListVar.state_id  = 'Test state_id'; 
        invListVar.inventory_market_status  = 'Test inventory_market_status'; 
        invListVar.market_key  = 'Test market_key'; 
        invListVar.distance  = 'Test distance'; 
        invListVar.secondary_cities  = 'Test secondary_cities'; 
        invListVar.state_id  = 'Test state_id'; 
        invListVar.available = 999;
        invListVar.available_presale = 999;
        invListVar.price_tier = 999;
        invListVar.cost_per_action = 999;
        invListVar.totalassets = 999;
        invListVar.totalcustomers = 999;
        invListVar.totalprospects = 999;
        invListVar.flex_unit_price = 999;
        invListVar.fast_unit_price = 999;
        invListVar.home_search_mkt_budget = 999;
        invListVar.total_home_search_price = 999;
        invListVar.TL_license_price  = 999;
        invListVar.Total_flex_price = 999;
        invListVar.Total_fast_price = 999;
        invListVar.quantity = 999; 
        //invListVar.forecast_lead = 4;
        invListVar.item_details_serialize = '';
        Inv.setFilterType('Waitlist Status');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Waitlist Type');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Inventory Available Flex');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Inventory Available Fast');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Presales Available Flex');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Presales Available Fast');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Product');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Assigned AE');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Input AE');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('No of Records');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Inventory Pool');
        Inv.getWaitlistStatusItems();
        Inv.setFilterType('Page No');
        Inv.getWaitlistStatusItems();
       
    List<InventorySearch.WLJson> WLJSONList = new List<InventorySearch.WLJson>();
    InventorySearch.WLMaster WLMasterVar = new InventorySearch.WLMaster('reservation_id',WLJSONList,'lock_release_date');
  
  ApexPages.currentPage().getParameters().put('commaSepratedBundleZip','00001,');
  string itemDetJson = '{"bundleZipWrapperVar":[{"market_type":"Postal Code","market_name":"00001","Forecast_lead":null}]}';
  ApexPages.currentPage().getParameters().put('itemDetailsJson',itemDetJson);
  inv.populateBundleZips();
  
  inv.accountwaitlist = null;
  list<InventorySearch.Invlist> getaccountwaitlist = inv.accountwaitlist;
  InventorySearch.BundleZipWrapper bzw = new InventorySearch.BundleZipWrapper();
  InventorySearch.BundleZipDetails bzd = new InventorySearch.BundleZipDetails();
     /*Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      string status;
        HttpRequest request = new HttpRequest();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());
        //mock.setStaticResource('GoogleMapsAPI');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.respond(request);
        HttpResponse response = new HttpResponse();*/
       
     Test.stopTest();
 
  }  
  private class WebServiceMockImplementation1 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response_map_x,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
           DocuSignAPI.CreateAndSendEnvelopeResponse_element respElement = 
          new DocuSignAPI.CreateAndSendEnvelopeResponse_element ();
     DocuSignAPI.EnvelopeStatus SendEnvelopeResult  = new DocuSignAPI.EnvelopeStatus();
     SendEnvelopeResult.Status = 'Success';            
               SendEnvelopeResult.EnvelopeID = '12345';
       response_map_x.put('response_x', respElement);      
        
        }
     }

}