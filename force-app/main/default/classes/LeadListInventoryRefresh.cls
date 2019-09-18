public class LeadListInventoryRefresh {
   List<Lead> lstLead = new List<Lead>();
   List<Product2>lstProduct = new List<Product2>();
   List<Account_Listing__c> all = new List<Account_Listing__c>(); 
    List<Account_Listing__c> lstListing = new List<Account_Listing__c>(); 
   
   P2lInventoryRefresh__c PLIUrls= P2lInventoryRefresh__c.getValues('PLI');
    public LeadListInventoryRefresh(ApexPages.StandardSetController controller) {
    if(controller == null) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id,Available_inventory__c,Account__c,Account__r.Party_ID__c,Product__r.BigMachines__Part_Number__c,Product__r.ProductCode,CFCB__c  ,
DAP__c,
FAC_Comp_Qty__c,
FAC_MREC_Qty__c,
FAC_LB_Qty__c,
FH__c,
HandRaiser__c,
Home_Search__c,
Featured_CMA_SM__c
                    
                     FROM Lead limit 200]));
            }
        controller.setPageSize(200);
        controller.next();
            if(controller.getSelected().size()>0){
            lstLead = controller.getSelected();
            } else{
            lstLead = controller.getRecords();
            }
           // return controller;
    }
     
    public PageReference updateInventory(){
        
        decimal totalinventory=0 ;
        integer totalfast =0;
        
    
    //PageReference pr = new PageReference('https://cs17.salesforce.com/00Q?fcf=00Bg00000014Od8');
    PageReference pr = new PageReference('/'+ApexPages.currentPage().getParameters().get('retURL'));
    try{
    
    System.debug('###'+ApexPages.currentPage().getParameters().get('retURL'));
    Map<Id,Account_Listing__c> accountMapIdPostals = new Map<Id,Account_Listing__c >();
    Set<Id> setLeadIds = new Set<Id>();
    Set<Id> setAccountIds = new Set<Id>();
    Set<String> setPostalCodes = new Set<String>();
    Set<String> setProductPartNumber = new Set<String>();
    Set<String> setPartyId = new Set<String>();
    Set<String> setProductCodes = new Set<String>();
    Map<String,available_inventoryitem> lstZCIC = new Map<String,available_inventoryitem>(); 
    Map<String,available_inventoryitem> mapZCIC = new Map<String,available_inventoryitem>(); 
    Map<String,Lead> mapLead = new Map<String,Lead>(); 
    for(Lead led:lstLead){
    setLeadIds.add(led.id); 
    
    }
    lstLead = [SELECT Id,Half_Flex_Available__c,Half_Fast_PreSales_Available__c,Half_Fast_Available__c ,Half_Flex_PreSales_Available__c,Full_Flex_Available__c,Available_inventory__c,AvailableFast__c,AvailablePreSalesFlex__c,AvailablePreSalesFast__c,Account__c,Account__r.Party_ID__c,Product__r.BigMachines__Part_Number__c,Product__r.ProductCode,CFCB__c  ,
DAP__c,
FAC_Comp_Qty__c,
FAC_MREC_Qty__c,
FAC_LB_Qty__c,
FH__c,
HandRaiser__c,
Home_Search__c,
Featured_CMA_SM__c FROM Lead where id=:setLeadIds];
for(Lead ledd:lstLead){
setAccountIds.add(ledd.Account__c);
ledd.Half_Flex_Available__c = null;
ledd.Half_Fast_PreSales_Available__c = null;
ledd.Half_Fast_Available__c =null;
ledd.Half_Flex_PreSales_Available__c = null;
ledd.Full_Flex_Available__c = null;
ledd.Available_inventory__c = null;
ledd.AvailableFast__c = null;
ledd.AvailablePreSalesFlex__c = null;
ledd.AvailablePreSalesFast__c = null;
ledd.CFCB__c = null;
ledd.DAP__c =null;
ledd.FAC_Comp_Qty__c =null;
ledd.FAC_MREC_Qty__c =null;
ledd.FAC_LB_Qty__c =null;
ledd.FH__c =null;
ledd.HandRaiser__c=null;
ledd.Home_Search__c=null;
ledd.Featured_CMA_SM__c = null;
mapLead.put(ledd.Account__r.Party_ID__c,ledd);
}

 lstProduct = [SELECT ProductCode FROM Product2 where Inventory__c=true and IsActive=true ];
    Map<String,Decimal> mapStringAccountListing = new Map<String,Decimal>();
    HttpRequest req = new HttpRequest();
     //req.setEndpoint('http://206.131.186.15:7082/AvailableInventoryService/SearchAvailableInventoryPS?search_type=postal%20code&search_values='+setPostalCodes+'&party_Id='+setPartyId+'&part_numbers='+setProductCodes);
     req.setMethod('POST');
     req.setHeader('Content-Type', 'application/json');
     //req.setEndpoint('http://206.131.186.15:7082/AvailableInventoryService/SearchAvailableInventoryPS');
     //req.setEndpoint(PLIUrls.P2LInvenotorySearchProduct__c);
     req.setEndpoint(PLIUrls.P2lInventoryRefreshUrl__c);
     //req.setEndpoint('https://qa-es-is.api.move.com/availableinventoryaggregate.json');
     //req.setEndpoint('http://requestb.in/rymswwry');
     //req.setEndpoint('soa12c-qa.move.com:7082/AvailableInventoryService/SearchAvailableInventoryPS');
     //String   body ='{"part_numbers" : { "part_number" : "COBROKE" }, "postal_codes" : { "postal_code" : "91302"  }, "party_ids" : { "party_id" : "12321" } }';
     JSONGenerator gen = JSON.createGenerator(true);
     gen.writeStartArray();
     //gen.writeObjectField('part_numbers',setProductCodes);
     for(Account_Listing__c all:[Select Id,Name,Listing_Count__c,Listing_Type__c,Zip__c,Account_Name__c,Parent_Agent_Broker__r.Party_ID__c, CFCB_City_Fast__c,  CFCB_City_Flex__c,  CFCB_City_Half_Fast__c, CFCB_City_Half_Flex__c, CFCB_CITYHALF_TIER__c,  CFCB_CITY_TIER__c,  CFCB_Full_Fast__c,  CFCB_Full_Flex__c,  CFCB_FULL_TIER__c,  CFCB_Half_Fast__c,  CFCB_Half_Flex__c,  CFCB_HALF_TIER__c,  DAP__c, FAC_COMP_Qty__c,    FAC_LB_Qty__c,  FAC_MREC_Qty__c,    FH__c,  Hand_Raiser__c, Featured_CMA_SM__c, Home_Search__c from Account_Listing__c where Parent_Agent_Broker__c=:setAccountIds]){
     System.debug(all.Id+''+all.Zip__c+''+all.Parent_Agent_Broker__r.Party_ID__c);
     if(!mapStringAccountListing.containskey(all.Zip__c+''+all.Parent_Agent_Broker__r.Party_ID__c)){
     gen.writeStartObject();
     mapStringAccountListing.put(all.Zip__c+''+all.Parent_Agent_Broker__r.Party_ID__c,1);
     gen.writeStringField('postal_code',all.Zip__c);
     gen.writeStringField('party_id',all.Parent_Agent_Broker__r.Party_ID__c);
     gen.writeEndObject();
     } else {
     Decimal ccount = mapStringAccountListing.get(all.Zip__c+''+all.Parent_Agent_Broker__r.Party_ID__c);
     mapStringAccountListing.put(all.Zip__c+''+all.Parent_Agent_Broker__r.Party_ID__c,(ccount+1));
     }
     }
     gen.writeEndArray();
   


     System.debug('$$$$$$$$$'+gen.getAsString());
     req.setBody(gen.getAsString()); 
   
     // Create a new http object to send the request object
     // A response object is generated as a result of the request  
  
     Http http = new Http();
     HTTPResponse res = http.send(req);
     System.debug('####'+res.getBody());
     String jsonStr = res.getBody();
    // jsonStr = '[   "inventory_available" : [     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ],   "inventory_available" : [     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ] ]';
    // String jsonStr = res.getBody();
List<available_inventoryitem> lstavailinv = new List<available_inventoryitem>();
     //jsonStr = '[   "available_inventories" : [     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ],   "inventory_available" : [     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ] ]';
     // jsonStr =  '{ "available_inventories" : [   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "DIGITALAGENT",     "market_type": "City",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "DIGITALAGENT",     "market_type": "CITY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "FEATCMA",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "FEATHOMES",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "HANDRAISER",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "HOMESRCH",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",    "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "DIGITALAGENT",     "market_type": "City",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "DIGITALAGENT",     "market_type": "CITY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "FEATCMA",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "FEATHOMES",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "HANDRAISER",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "HOMESRCH",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   }  ] }';
       JSONParser parser = JSON.createParser(jsonStr);
       System.debug('######'+parser);
         while (parser.nextToken() != null) {
        // Start at the array of invoices.
        //if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
         if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parser.nextToken() != null) {
                System.debug('$$$$$$'+parser.getText());
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                System.debug('$$$$$$'+parser.getText());
                    available_inventoryitem invcount = (available_inventoryitem)parser.readValueAs(available_inventoryitem.class);
                    lstavailinv.add(invcount);
                }
            }
        }
    }   
    System.debug(lstavailinv+'Pocdie');
    
    for(available_inventoryitem aii:lstavailinv){
    //System.debug('PPPPKKKK'+aii);
    if(mapLead.containskey(aii.party_id) && aii.postal_code!=null){
    //System.debug('PPPP'+aii);
    Decimal totalavailabledap = 0.0;
    Decimal totalavailablehandraiser = 0.0;
    Decimal totalavailablehomesearch = 0.0;
    Decimal totalavailablefeatcma = 0.0;
    Decimal totalavailablefeatdisp = 0.0;
    Decimal totalavailablecfcb = 0.0;
    Lead led = mapLead.get(aii.party_id);
    System.debug('CKKKK'+led + ' ......'+ mapStringAccountListing.get(aii.postal_code+''+aii.party_id));
    
    if(led.DAP__c!=null){totalavailabledap=led.DAP__c;}
     if(aii.total_available!=null && aii.part_number=='DIGITALAGENT'){
    led.DAP__c = totalavailabledap+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    }
    if(led.HandRaiser__c!=null){totalavailablehandraiser=led.HandRaiser__c;}
     if(aii.total_available!=null && aii.part_number=='HANDRAISER'){
    led.HandRaiser__c = totalavailablehandraiser+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    }
    if(led.Home_Search__c!=null){totalavailablehomesearch=led.Home_Search__c;}
     if(aii.total_available!=null && aii.part_number=='HOMESRCH'){
     System.debug(totalavailablehomesearch+'$$$$$$$$$$$$'+aii.total_available+'*'+mapStringAccountListing.get(aii.postal_code+''+aii.party_id));
    led.Home_Search__c = totalavailablehomesearch+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    }
    
    if(led.Featured_CMA_SM__c!=null){totalavailablefeatcma=led.Featured_CMA_SM__c;}
     if(aii.total_available!=null && aii.part_number=='FEATCMA'){
    led.Featured_CMA_SM__c = totalavailablefeatcma+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    }
    if(led.FH__c!=null){totalavailablehandraiser=led.FH__c;}
     if(aii.total_available!=null && aii.part_number=='FEATHOMES'){
    led.FH__c = totalavailablefeatdisp+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    }
   
    if(led.CFCB__c!=null){totalavailablecfcb=led.CFCB__c;}
     if(aii.total_available!=null && aii.part_number=='COBROKE'){
    led.CFCB__c = totalavailablecfcb+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
    System.debug(led.CFCB__c+'= '+aii.total_available+' * '+mapStringAccountListing.get(aii.postal_code+''+aii.party_id)+' (For postal Code '+aii.postal_code+' and party id '+aii.party_id);
    }
   /* if(led.HandRaiser__c!=null){totalavailablehandraiser=led.HandRaiser__c;}
     if(aii.total_available!=null && aii.part_number=='FEATDISP'){
    led.HandRaiser__c = totalavailablehandraiser+aii.total_available;
    }*/
    mapLead.put(aii.party_id,led);
    
   // System.debug('PPPP'+aii);
    }
    }
    update mapLead.values();
    
     
   
   
    } catch(Exception ex){
    
    }
    return pr;
    
    } 

Public Class available_inventoryitem{
public String party_id{get;set;}
public String part_number{get;set;}
public String market_name{get;set;}
public String postal_code{get;set;}
public String market_type{get;set;}
public String product_name{get;set;}
public String product_size{get;set;}
public Decimal available_flex{get;set;}
public Decimal available_fast{get;set;}
Public Decimal total_available{get;set;}
public Decimal available_presale_flex{get;set;}
public Decimal available_presale_fast{get;set;}
public Decimal price_tier  {get;set;}
public Decimal flex_unit_price {get;set;}
public Decimal fast_unit_price {get;set;}


//public Decimal invCount{get;set;}
}    
}