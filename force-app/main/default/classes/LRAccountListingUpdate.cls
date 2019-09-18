public with sharing class LRAccountListingUpdate {
    public string mAccountId; 
    public String jsonStr {get;set;}
    map<string,Account_Listing__c> mapstrandalist = new map<string,Account_Listing__c>();
    public void setAccountId(String newvalue)         
    {
        // do nothing 
        
        mAccountId = newvalue;
        System.debug('AccountId'+ mAccountId);
        //return mToken;
        
    }        
    public string getAccountId()    
    { 
        
        // do nothing 
        
        return  mAccountId ;
        
        
    } 
    List<Lead> lstLead = new List<Lead>();
    List<Account_Listing__c> all = new List<Account_Listing__c>(); 
    List<Account_Listing__c> lstListing = new List<Account_Listing__c>(); 
    list<Account_Listing__c> updatedAcclisting = new list<Account_Listing__c>();
    P2lInventoryRefresh__c PLIUrls= P2lInventoryRefresh__c.getValues('PLI');
    public LRAccountListingUpdate(ApexPages.StandardSetController controller) {
    if(controller == null) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator(
                [Select Id,Name,Listing_Count__c,Listing_Type__c,Zip__c,Account_Name__c,Account_Name__r.Party_ID__c, CFCB_City_Fast__c,  CFCB_City_Flex__c,  CFCB_City_Half_Fast__c, CFCB_City_Half_Flex__c, CFCB_CITYHALF_TIER__c,  CFCB_CITY_TIER__c,  CFCB_Full_Fast__c,  CFCB_Full_Flex__c,  CFCB_FULL_TIER__c,  CFCB_Half_Fast__c,  CFCB_Half_Flex__c,  CFCB_HALF_TIER__c,  DAP__c, FAC_COMP_Qty__c,    FAC_LB_Qty__c,  FAC_MREC_Qty__c,    FH__c,  Hand_Raiser__c, Featured_CMA_SM__c, Home_Search__c from Account_Listing__c ]));
            
        controller.setPageSize(200);
        controller.next();
            if(controller.getSelected().size()>0){
            lstListing = controller.getSelected();
            } else{
            lstListing= controller.getRecords();
            }
           // return controller;
    }
    }
     
    public PageReference updateListings(){
        
        decimal totalinventory=0 ;
        integer totalfast =0;
        
    
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
    Map<String,list<Account_Listing__c>> mapListing = new Map<String,list<Account_Listing__c>>(); 
    
    lstListing =        [Select Id,Name,Listing_Count__c,Listing_Type__c,Zip__c,Account_Name__c,Parent_Agent_Broker__r.Party_ID__c,Account_Name__r.Party_ID__c, CFCB_City_Fast__c,  CFCB_City_Flex__c,  CFCB_City_Half_Fast__c, CFCB_City_Half_Flex__c, CFCB_CITYHALF_TIER__c,  CFCB_CITY_TIER__c,  CFCB_Full_Fast__c,  CFCB_Full_Flex__c,  CFCB_FULL_TIER__c,  CFCB_Half_Fast__c,  CFCB_Half_Flex__c,  CFCB_HALF_TIER__c,  DAP__c, FAC_COMP_Qty__c,    FAC_LB_Qty__c,  FAC_MREC_Qty__c,    FH__c,  Hand_Raiser__c, Featured_CMA_SM__c, Home_Search__c from Account_Listing__c
     where Parent_Agent_Broker__c=:mAccountId and Parent_Agent_Broker__c != null];
     
     System.debug('Listing is '+ mAccountId + 'lstListing'+ lstListing);
  
     //End
for(Account_Listing__c AL:lstListing){


AL.CFCB_City_Fast__c = null;
  AL.CFCB_City_Flex__c= null;
 AL.CFCB_City_Half_Fast__c= null;
  AL.CFCB_City_Half_Flex__c= null;
AL.CFCB_CITYHALF_TIER__c= null;
  AL.CFCB_CITY_TIER__c = null;
 AL.CFCB_Full_Fast__c = null;
AL.CFCB_Full_Flex__c = null;
AL.CFCB_FULL_TIER__c = null;
 AL.CFCB_Half_Fast__c = null;
  AL.CFCB_Half_Flex__c = null;
AL.CFCB_HALF_TIER__c = null;
  AL.DAP__c = null;
  AL.FAC_COMP_Qty__c = null;  
  AL.FAC_LB_Qty__c = null;
  AL.FAC_MREC_Qty__c = null;
  AL.FH__c = null;
   AL.Hand_Raiser__c = null;
   AL.Featured_CMA_SM__c = null;
  AL.Home_Search__c = null;
  
 // This Code is setting Unique combination of Zip + PartyID with Account Listing Object 
 /*
 if(AL.Account_Name__c != null && AL.Zip__c != null && AL.Zip__c != '')
 {
    string strcmp = AL.Account_Name__r.Party_ID__c+'@'+AL.Zip__c;
    if(mapListing.get(strcmp.trim()) == null){
        mapListing.put(strcmp.trim(),new list<Account_Listing__c>());
    }
    mapListing.get(strcmp.trim()).add(AL);
 }
 */
 if(AL.Account_Name__c != null && AL.Zip__c != null && AL.Zip__c != '')
 {
    string strcmp = AL.Parent_Agent_Broker__r.Party_ID__c+'@'+AL.Zip__c;
    if(mapListing.get(strcmp.trim()) == null){
        mapListing.put(strcmp.trim(),new list<Account_Listing__c>());
    }
    mapListing.get(strcmp.trim()).add(AL);
 }
 
 
    
}
    Map<String,Decimal> mapStringAccountListing = new Map<String,Decimal>();
    HttpRequest req = new HttpRequest();
     req.setMethod('POST');
     req.setHeader('Content-Type', 'application/json');
     req.setEndpoint(PLIUrls.P2lInventoryRefreshUrl__c);
     //req.setEndpoint('https://UAT-es-is.api.move.com/availableinventoryaggregate.json');
     //String   body ='{"part_numbers" : { "part_number" : "COBROKE" }, "postal_codes" : { "postal_code" : "91302"  }, "party_ids" : { "party_id" : "12321" } }';
     JSONGenerator gen = JSON.createGenerator(true);
     gen.writeStartArray();
     for(Account_Listing__c all:[Select Id,Name,Listing_Count__c,Listing_Type__c,Zip__c,Account_Name__c,Parent_Agent_Broker__r.Party_ID__c, CFCB_City_Fast__c,  
                         CFCB_City_Flex__c,  CFCB_City_Half_Fast__c, CFCB_City_Half_Flex__c, CFCB_CITYHALF_TIER__c,  CFCB_CITY_TIER__c,  
                         CFCB_Full_Fast__c,  CFCB_Full_Flex__c,  CFCB_FULL_TIER__c,  CFCB_Half_Fast__c,  CFCB_Half_Flex__c,  CFCB_HALF_TIER__c,  
                         DAP__c, FAC_COMP_Qty__c,    FAC_LB_Qty__c,  FAC_MREC_Qty__c,    FH__c,  Hand_Raiser__c, Featured_CMA_SM__c, Home_Search__c 
                         from Account_Listing__c where Parent_Agent_Broker__c=:mAccountId and Parent_Agent_Broker__c != null]){
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
     jsonStr = res.getBody();
    List<available_inventoryitem> lstavailinv = new List<available_inventoryitem>();
     //jsonStr = '[   "available_inventories" : [     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "123456",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ],   "inventory_available" : [     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "CITY",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "FULL",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "COBROKE",       "market_type": "POSTAL CODE",       "product_size": "HALF",       "lead_routing": "FAST",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "City",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "DIGITALAGENT",       "market_type": "CITY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATCMA",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "FEATHOMES",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HANDRAISER",       "market_type": "POSTAL CODE",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     },     {       "postal_code": "93010",       "party_id": "67890",       "part_number": "HOMESRCH",       "market_type": "TERRITORY",       "product_size": "STANDARD",       "lead_routing": "FLEX",       "price_tier": 10,       "available": 1     }   ] ]';
     // jsonStr =  '{ "available_inventories" : [   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "DIGITALAGENT",     "market_type": "City",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "DIGITALAGENT",     "market_type": "CITY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "FEATCMA",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "FEATHOMES",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "HANDRAISER",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "123456",     "part_number": "HOMESRCH",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",    "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "CITY",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "FULL",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "COBROKE",     "market_type": "POSTAL CODE",     "product_size": "HALF",     "lead_routing": "FAST",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "DIGITALAGENT",     "market_type": "City",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "DIGITALAGENT",     "market_type": "CITY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "FEATCMA",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "FEATHOMES",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "HANDRAISER",     "market_type": "POSTAL CODE",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   },   {     "postal_code": "93010",     "party_id": "67890",     "part_number": "HOMESRCH",     "market_type": "TERRITORY",     "product_size": "STANDARD",     "lead_routing": "FLEX",     "price_tier": 10,     "available": 1   }  ] }';
       JSONParser parser = JSON.createParser(jsonStr);
       System.debug('######'+parser);
         while (parser.nextToken() != null) {
        // Start at the array of invoices.
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
    System.debug('PPPPKKKK'+aii);
    
    string strcompares = '';
    if(aii.party_id != null && aii.party_id != '' && aii.postal_code != null && aii.postal_code != '')
    {
        strcompares = aii.party_id+'@'+aii.postal_code.trim();
    }
    
    //System.debug('CK strcompares brfore if '+strcompares);
    //System.debug('CK maplisting brfore if '+mapListing.get(strcompares));
    
    if(strcompares != '' && mapListing.containskey(strcompares) ){
    
    //System.debug('CK strcompares inside If Loop '+strcompares);
    
    Decimal totalavailabledap = 0.0;
    Decimal totalavailablehandraiser = 0.0;
    Decimal totalavailablehomesearch = 0.0;
    Decimal totalavailablefeatcma = 0.0;
    Decimal totalavailablefeatdisp = 0.0;
    if(mapListing.get(strcompares) != null && mapListing.get(strcompares).size() > 0){
        //integer intduplicatevals = mapListing.get(strcompares).size();
    for(Account_Listing__c objlst : mapListing.get(strcompares)){
    string finalcomparing = '';
    finalcomparing = strcompares+'@'+objlst.id;
    if(mapstrandalist.get(finalcomparing) == null){
        mapstrandalist.put(finalcomparing,objlst);
     
    }
        Account_Listing__c lList  = mapstrandalist.get(finalcomparing);
    if(lList.DAP__c!=null){totalavailabledap=lList.DAP__c;}
     if(aii.total_available!=null && aii.part_number=='DIGITALAGENT'){
    //lList.DAP__c = aii.total_available/intduplicatevals;
     //lList.DAP__c = totalavailabledap+aii.total_available * mapStringAccountListing.get(aii.postal_code+''+aii.party_id);
     lList.DAP__c = aii.total_available;
    }
    if(lList.Hand_Raiser__c!=null){totalavailablehandraiser=lList.Hand_Raiser__c;}
     if(aii.total_available!=null && aii.part_number=='HANDRAISER'){
    lList.Hand_Raiser__c = aii.total_available;
    }
    if(lList.Home_Search__c!=null){totalavailablehomesearch=lList.Home_Search__c;}
     if(aii.total_available!=null && aii.part_number=='HOMESRCH'){
    lList.Home_Search__c = aii.total_available;
    }
    if(lList.Featured_CMA_SM__c!=null){totalavailablefeatcma=lList.Featured_CMA_SM__c;}
     if(aii.total_available!=null && aii.part_number=='FEATCMA'){
    lList.Featured_CMA_SM__c = aii.total_available;
    }
    if(lList.FH__c!=null){totalavailablehandraiser=lList.FH__c;}
     if(aii.total_available!=null && aii.part_number=='FEATHOMES'){
    lList.FH__c = aii.total_available;
    }
   
    //added by Sateesh Reddy on 20/11/2015
    if(aii.total_available!=null && aii.market_type == 'Postal Code' && aii.product_size == 'Full' && aii.lead_routing == 'Flex'){
        lList.CFCB_Full_Flex__c = aii.total_available;
        
        System.debug('lList.CFCB_Full_Flex__c'+aii.total_available);
        
    }
    if(aii.total_available!=null && aii.market_type == 'Postal Code' && aii.product_size == 'Full' && aii.lead_routing == 'Fast'){
        lList.CFCB_Full_Fast__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'City' && aii.product_size == 'Full' && aii.lead_routing == 'Flex'){
        lList.CFCB_City_Flex__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'City' && aii.product_size == 'Full' && aii.lead_routing == 'Fast'){
        lList.CFCB_City_Fast__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'Postal Code' && aii.product_size == 'Half' && aii.lead_routing == 'Flex'){
        lList.CFCB_Half_Flex__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'Postal Code' && aii.product_size == 'Half' && aii.lead_routing == 'Fast'){
        lList.CFCB_Half_Fast__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'City' && aii.product_size == 'Half' && aii.lead_routing == 'Flex'){
        lList.CFCB_City_Half_Flex__c = aii.total_available;
    }
    if(aii.total_available!=null && aii.market_type == 'City' && aii.product_size == 'Half' && aii.lead_routing == 'Fast'){
        lList.CFCB_City_Half_Fast__c = aii.total_available;
    }
    if(aii.total_available!=null  && aii.product_size == 'Full' && aii.lead_routing == 'Fast'){
        lList.CFCB_FULL_TIER__c= aii.total_available;
    }
    if(aii.total_available!=null  && aii.product_size == 'Half' && aii.lead_routing == 'Fast'){
        lList.CFCB_HALF_TIER__c= aii.total_available;
    }
    
    //end
    //updatedAcclisting.add(lList);
    mapstrandalist.put(finalcomparing,lList);
    }
    }
    System.debug('PPPP ARUN '+aii);
    }
    }
    System.debug('Updating Table Here'+ mapstrandalist);
    update mapstrandalist.values();
    
      System.debug('Updating Table Here'+ mapListing);
    
     
   
   
    } catch(Exception ex){
    
    }
    return null;
    
    } 

Public Class available_inventoryitem{
public String party_id{get;set;}
public String part_number{get;set;}
public String market_name{get;set;}
public String postal_code{get;set;}
public String market_type{get;set;}
public String product_name{get;set;}
public String product_size{get;set;}
public string lead_routing{get;set;}
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