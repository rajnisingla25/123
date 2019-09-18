public class CBCMarketPerfSearch {
    
    // the soql without the order and limit
    private static String soql {get;set;}
    // the collection of contacts to display
    public List<asset> assets {get;set;}
    public List<AssetMarketInvWrapper> lstwrap {get;set;}
    List<InventoryInformationAssets> InvInfo=new List<InventoryInformationAssets>();
    public transient Double TotalAverageListingPriceWebLead = 0;
    public transient Double TotalAverageListingPriceMobileLead = 0;
    public transient Double TotalAverageListingPriceAllLead = 0;
    public transient Integer TotalWebLead = 0;
    public transient Integer TotalMobileLead = 0;
    public transient Integer TotalPaidLead = 0;
    public transient Integer TotalCourtesyLead = 0;
    public transient Integer TotalTotalLeads = 0;
    public List<AssetMarketInvWrapper> relatedAssets {
    	
        //create the accessor code 
        get {
            system.debug('@@ relatedAssets - start @@'+assets);
            //create a list of assets to represent the collection objects coming from the wrapper 
            lstwrap = new List<AssetMarketInvWrapper>();
            for (Asset a: assets) {            
                If (a!=null){
                    Transient Integer j = InvInfo.size();
                    system.debug('@@ j @@'+j);
                    system.debug('@@ InvInfo @@'+InvInfo);
                    for(Integer i=0;i < j;i++){
                    	system.debug('@@ InvInfo.get(i) @@'+InvInfo.get(i));
                    	system.debug('@@ a.External_ID__c @@'+a.External_ID__c);
                    	system.debug('@@ InvInfo.get(i).AssetId @@'+InvInfo.get(i).AssetId);
                    	
                        if(InvInfo.get(i)!=null && a.External_ID__c == InvInfo.get(i).AssetId){
                    		lstwrap.add(new AssetMarketInvWrapper(a,InvInfo.get(i)));
                		}           
            		}
                }
            }
          
            for (AssetMarketInvWrapper b: lstwrap){
                TotalAverageListingPriceWebLead += b.AverageListingPriceWebLead;
                TotalAverageListingPriceMobileLead += b.AverageListingPriceMobileLead;
                TotalAverageListingPriceAllLead += b.AverageListingPriceAllLead;
                TotalWebLead += b.WebLead;
                TotalMobileLead += b.MobileLead;
                TotalPaidLead += b.PaidLead;
                TotalCourtesyLead += b.CourtesyLead;
                TotalTotalLeads += b.TotalLeads;
            }
            Transient Integer agg = lstwrap.size();
            if (agg > 0){
                AssetMarketInvWrapper totalRecord = new AssetMarketInvWrapper();
                totalRecord.AverageListingPriceWebLead = TotalAverageListingPriceWebLead/agg;
                totalRecord.AverageListingPriceMobileLead = TotalAverageListingPriceMobileLead/agg;
                totalRecord.AverageListingPriceAllLead = TotalAverageListingPriceAllLead/agg;
                totalRecord.WebLead = TotalWebLead;
                totalRecord.MobileLead = TotalMobileLead;
                totalRecord.PaidLead = TotalPaidLead;
                totalRecord.CourtesyLead = TotalCourtesyLead;
                totalRecord.TotalLeads = TotalTotalLeads;
                totalRecord.AssetId = 'Total'; 
                totalRecord.i = 100;     
                lstwrap.add(totalRecord);        
            }
            return lstwrap;
        }
        set;
    }
    InventoryAssetDetails__c InvURL= InventoryAssetDetails__c.getValues('invurl');
    List <JSONInput> assetids = new  List <JSONInput>();
    public static String market;
    
    public string productname = 'Connection for Co-Brokerage';
    
    Transient String AssetType = 'Fulfill To';
    // init the controller and display some sample data when the page loads
    public CBCMarketPerfSearch() {
        //total_size = [select count() from asset where Market__c =:market]; //set the total size in the constructor
        market = ApexPages.currentPage().getParameters().get('marketid');
        soql = 'Select Status, Parent_Asset__r.Quantity, Product_Type__c, Lead_Type__c, Parent_Asset__r.Market__c, Parent_Asset__r.Contract_Term__c, Start_Date__c, End_Date__c, External_ID__c, Account_Name__c,a.Account.id  From Asset a where a.Account.id!=null and Asset_Type__c =:AssetType  and Parent_Asset__r.Market__c =:market' ;        
        runQuery();
    }
    
    public class JSONInput{
        public Transient string AssetId;
        public Transient string FromDate;
        public Transient string ToDate;
        JSONInput(Asset a){
            this.AssetId = a.External_ID__c!=null?a.External_ID__c:'';
            this.FromDate = a.Start_Date__c!=null?String.valueof(a.Start_Date__c):'1900-01-01';
            this.ToDate = a.End_Date__c!=null?String.valueof(a.End_Date__c):'2999-12-31';
        }
    }
    // runs the actual query
    public void runQuery() {
        try {
            assets = Database.query(soql);//limit :list_size offset :counter
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }
        
       	JSONGenerator gen = JSON.createGenerator(true);
       	Transient Boolean JSONArray = false;
        JSONInput obj;

                for(Asset a: assets){
                    if (assets.size()>1 && !JSONArray){
                         gen.writeStartArray();
                         JSONArray = true;
                    }
                    If(a!=null){
                        obj = new JSONInput(a);
                        If (obj!=null){
                            gen.writeStartObject();
                            gen.writeStringField('AssetId', obj.AssetId);
                            gen.writeStringField('FromDate', obj.FromDate);
                            gen.writeStringField('ToDate', obj.ToDate);
                        	gen.writeEndObject();
                        }
                        assetids.add(obj);
            		}            
        		}
                            

          if (JSONArray){
                    gen.writeEndArray();
                }  
	    // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
		

		String JSONprettystring = gen.getAsString();
		System.debug('JSONprettystring:'+JSONprettystring);
        //String JSONString = '{ "AssetId" : "1-1041530555" , "FromDate" : "2015-01-01" , "ToDate" : "2015-12-01" }';
        //String JSONString = '[ { "AssetId"="1-775077551" , "FromDate" : "2015-02-01" , "ToDate" : "2015-06-01" }, { "AssetId"="1-903792172" , "FromDate" : "2015-08-01" , "ToDate" : "2015-09-01" } ]';
        // Instantiate a new http object
        string  myjson;
       
        Http h = new Http();
        //Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSONprettystring);
        String inputurl = InvURL.InventoryAssetDetailsURL__c;
        //if (JSONArray){
            inputurl = inputurl + '[]';
        //}  
        req.setEndpoint(inputurl);
        HttpResponse res = new HttpResponse();
        try{
            // Send the request, and return a response
            
            res= h.send(req);
             myjson = res.getBody();
                System.debug('HTTP Response is ' + myjson)  ;        
            
            InvInfo=(List<InventoryInformationAssets>)JSON.deserialize(res.getBody(), List<InventoryInformationAssets>.class);
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Inventory data is not available. Please retry and if the problem persists, contact SFDC Admin'));
            System.debug('HTTP Response is ' + e.getMessage())   ;
        }
   
        
    }
      
}