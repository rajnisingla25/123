public class CBCPerformanceSearch {
    // the soql without the order and limit
    private static String soql {get;set;}
    
    // the collection of contacts to display
    public List<account> accounts {get;set;}
    public List<AccountAssetInvWrapper> lstwrap {get;set;}
    public boolean fast {get;set;}
    public Account account {get;set;}
    public static String AssetId {get;set;}
    public Id accountId {get;set;}
    public String selectedStatusValue{get;set;}
    
    List<InventoryInformation> InvInfo1     = new List<InventoryInformation>();
   
    public CBCPerformanceSearch(ApexPages.StandardController controller) {
        account         = (Account)controller.getRecord();
        accountid       = ApexPages.currentPage().getParameters().get('whatId');        
        soql            = 'Select a.Type, a.Email_Address__c, a.Phone, a.Name,  a.Broker_NAR_Id__c, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, Party_ID__c, (Select Name, Status, Parent_Asset__r.Quantity, Product_Type__c,Ultimate_Parent_Id_Text__c, Lead_Type__c, Parent_Asset__r.Market__c, Parent_Asset__r.Contract_Term__c, Start_Date__c, End_Date__c, Parent_Asset__r.Total_Net__c, Renewal_Price__c, External_ID__c,Parent_Asset__r.BOP_Code__c From Assets Where Product_Code__c = \'COBROKE\'  AND Asset_Type__c=\'Fulfill To\' AND (NOT External_ID__c like  \'%-PR1%\') Order by Status DESC, End_Date__c ASC) From Account a where a.id =:accountid ';        
        runQuery();   
    }
    
   
 // This method returns the Query string which can be used during filtering   
    public String buildQuery(){
        system.debug('@@ buildQuery - Start @@');
        
        String queryStr     = 'Select Name, Status, Parent_Asset__r.Quantity, Product_Type__c, Ultimate_Parent_Id_Text__c, Lead_Type__c, Parent_Asset__r.Market__c, Parent_Asset__r.Contract_Term__c, Start_Date__c, End_Date__c, Parent_Asset__r.Total_Net__c, Renewal_Price__c, External_ID__c,Parent_Asset__r.BOP_Code__c From Asset Where Product_Code__c = \'COBROKE\' AND Asset_Type__c=\'Fulfill To\' AND (NOT External_ID__c like  \'%-PR1%\')';
        queryStr            += ' AND account.id =: accountid';
        
        if(selectedStatusValue!='' && selectedStatusValue!=Null)
            queryStr        += ' AND Status =: selectedStatusValue';
        
        queryStr            += ' Order by Status,Parent_Asset__r.Market__c DESC';
        
        system.debug('@@ buildQuery - End @@');
        return queryStr;
    }
    
    public List<AccountAssetInvWrapper> relatedAssets {
        //create the accessor code 
        get {
            //create a list of assets to represent the collection objects coming from the wrapper 
            lstwrap = new List<AccountAssetInvWrapper>();
            for (Account a: accounts) {            
                If (!a.assets.isempty()){
                    lstwrap.add(new AccountAssetInvWrapper(a,a.assets,InvInfo1)); 
                }           
            }
            
            system.debug('@@ lstwrap @@'+lstwrap);
            return lstwrap;
        }
        set;
    }
    InventoryAssetDetails__c InvURL= InventoryAssetDetails__c.getValues('invurl');
    List <JSONInput> assetids = new  List <JSONInput>();

    public PageReference fastFlex (){
        fast = true;
        return null;
    }
    public PageReference flexFast (){
        fast = false;
        return null;
    }
    
   
    //public String AssetId = '1-775077551';
    public List<AccountAssetInvWrapper.AssetLeadDetails> getLeadDetails{
        get{
        //AccountAssetInvWrapper wrap = new AccountAssetInvWrapper();
        List<AccountAssetInvWrapper.AssetLeadDetails> LeadList;
        for (AccountAssetInvWrapper a:lstwrap){
            if (a!=null){
                system.debug('@@ a.dwrap @@'+a.dwrap);
                for(AccountAssetInvWrapper.AssetDetails b:a.dwrap){
                    if (AssetId == null){
                    system.debug('@@ a.dwrap @@'+b);
                        AssetId = b.AssetId;
                    }
                    if (b!=null && b.AssetId == AssetId){
                    system.debug('@@ a.dwrap @@'+b);
                        LeadList = a.getLead(AssetId);
                    }
                }
            }
        }
        return LeadList;
        }
        set;
    }
    // init the controller and display some sample data when the page loads
    public CBCPerformanceSearch() {}
    
    
    public class JSONInput{
        public Transient string AssetId1;
        public Transient string FromDate;
        public Transient string ToDate;
        @testvisible
        JSONInput(Asset a){
            
            this.AssetId1 = a.External_ID__c!=null?a.External_ID__c:'';
            this.FromDate = a.Start_Date__c!=null?String.valueof(a.Start_Date__c):'2015-01-01';
            this.ToDate = a.End_Date__c!=null?String.valueof(a.End_Date__c):'2016-12-31';
        }
    }
    // runs the actual query
    public void runQuery() {
        try {
           accounts = Database.query(soql + ' limit 1');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        Transient Boolean JSONArray = false;
        JSONInput obj;
        for (Account acc: accounts) {
            system.debug('@@ acc.assets @@'+acc.assets);            
            If (!acc.assets.isempty()){
                for(Asset a: ((List<Asset>)con.getRecords())){
                    if (acc.assets.size() > 1 && !JSONArray){
                         gen.writeStartArray();
                         JSONArray = true;
                    }
                    If(a!=null){
                        obj = new JSONInput(a);
                        If (obj!=null){
                            gen.writeStartObject();
                            gen.writeStringField('AssetId', obj.AssetId1);
                            gen.writeStringField('FromDate', obj.FromDate);
                            gen.writeStringField('ToDate', obj.ToDate);
                            gen.writeEndObject();
                        }
                        assetids.add(obj);
                    }            
                }
                            
            }  
            break;         
        }
          if (JSONArray){
                    gen.writeEndArray();
                }  
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        
        
        Transient String JSONprettystring = gen.getAsString();
        System.debug('JSONprettystring:'+JSONprettystring);
        //String JSONString = '{ "AssetId"="1-775077551" , "FromDate" : "2015-02-01" , "ToDate" : "2015-06-01" }';
        //String JSONString = '[ { "AssetId"="1-775077551" , "FromDate" : "2015-02-01" , "ToDate" : "2015-06-01" }, {"AssetId" : "1-1041530555",  "FromDate" : "2015-01-01",   "ToDate" : "2015-12-01"   }]';
        // Instantiate a new http object
        Http h = new Http();
        //Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSONprettystring);
        String inputurl = InvURL.InventoryAssetDetailsURL__c;
        inputurl = inputurl + '[]';
          
        req.setEndpoint(inputurl);
        req.setTimeout(60000);
        HttpResponse res = new HttpResponse();
        try{
            // Send the request, and return a response
            system.debug('@@ req @@'+req);
            res= h.send(req);
            string  myjson = res.getBody();
            system.debug('@@ myjson @@'+myjson);
            
            //InvInfo=(InventoryInformation)JSON.deserialize(res.getBody(), InventoryInformation.class);
            InvInfo1=(List<InventoryInformation>)JSON.deserialize(res.getBody(), List<InventoryInformation>.class);
        }
        catch (exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Inventory data is not available. Please retry and if the problem persists, contact SFDC Admin'));
            System.debug('@@ HTTP Response is @@' + e.getMessage())   ;
        }
    }
    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {
        
        get {
            if(con == null) {
                //con = new ApexPages.StandardSetController(Database.getQueryLocator('Select Name, Status, Parent_Asset__r.Quantity, Product_Type__c, Lead_Type__c, Parent_Asset__r.Market__c, Parent_Asset__r.Contract_Term__c, Start_Date__c, End_Date__c, List_Price__c, Renewal_Price__c, External_ID__c,Parent_Asset__r.BOP_Code__c From Asset Where Product_Code__c = \'COBROKE\' AND (NOT External_ID__c like  \'%-PR1%\') AND account.id =: accountid Order by Status,Parent_Asset__r.Market__c DESC'));
                con = new ApexPages.StandardSetController(Database.getQueryLocator(buildQuery()));
                // sets the number of records in each page set
                con.setPageSize(10);
                
            }
            return con;                           
        }
        set;
    }
    
    
     // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns the current page number
    public Integer totalPages {
        get {
            
                return (Integer)Math.CEIL(((Decimal)con.getResultSize())/10);
            }
            
        set;
    }
    
    // returns the first page of records
    public void first() {
        con.first();
        runQuery();
    }

    // returns the last page of records
    public void last() {
        con.last();
        runQuery();
    }

    // returns the previous page of records
    
    public void previous() {
        con.previous();
        runQuery();
    }

    // returns the next page of records
    public void next() {
        con.next();
        runQuery();
    }
    
    
    public PageReference exportToExcel(){
        PageReference pg = new PageReference('/apex/CBCPerformanceExportToExcel?whatId='+accountId+ '&status=' +selectedStatusValue);
        pg.setRedirect(true);
        system.debug('@@ pg @@'+pg);
        return pg;
    }
    
}