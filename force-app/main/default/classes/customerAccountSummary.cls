/*****************************************************************************
* Class Name: customerAccountSummary
* Author: Shraddha Kabade
* Purpose: To generate product details pdf 
* Test class :sendCustomerAccSummaryPDFByEmail_Test
****************************************************************************/

public class customerAccountSummary{
    public String currentRecordId {get;set;}
    public String currentDateTimeFormatted {get;set;}
    public Datetime currentDateTime {get;set;}
    public String contactName {get;set;}
    public String partyId {get;set;}
    public boolean marketNotNull {get;set;}
    public boolean monthlyPayNotNull {get;set;}
    public boolean paidInFullNotNull {get;set;}
    public boolean sellerLeadBundleExist {get;set;}
    public List<Asset> assetlist {get;set;}
    public Map<id, String> assetIdOrderNumMap {get;set;}
    public List<assetOrderWrapper> assetOrderList {get;set;}
    public List<assetOrderWrapper> bmsAssetOrderList {get;set;}
    public Set<id> assetIdSet {get;set;}
    public Decimal bmsMonthlyPrice {get;set;}
    public Decimal bmsPaidInFullPrice {get;set;}
    public customerAccountSummary(ApexPages.StandardController controller) {
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        bmsMonthlyPrice = 0;
        bmsPaidInFullPrice = 0;
        assetOrderList = new List<assetOrderWrapper>();
        bmsAssetOrderList = new List<assetOrderWrapper>();
        // Get Primary contact name to display in PDF
        List <Account_Relationship__c> accConRelList = [select id, Parent_Account__r.name, Contact_To__r.email, Contact_To__r.name, Parent_Account__r.Party_ID__c
                                                        from Account_Relationship__c 
                                                        where Relationship_Type__c = 'Contact' and Parent_Account__c =:currentRecordId
                                                        and Contact_Role__c = 'Primary Contact' and Contact_To__r.email != null];
        
        if(!accConRelList.isEmpty()){
            contactName = accConRelList[0].Contact_To__r.name;
            partyId = accConRelList[0].Parent_Account__r.Party_ID__c;
        }
        currentDateTime = DateTime.now();
        currentDateTimeFormatted = currentDateTime.format('MM/dd/yyyy hh:mm:ss a');
        //CRM-4547: Suppress RS bundle assets
        Suppress_in_Customer_Statements_Settings__c custStatementSetting = Suppress_in_Customer_Statements_Settings__c.getInstance('Customer');
        List<String> lstPromoCode = custStatementSetting.Promo_Codes__c.split(';');
        // LCM-440: Display products only from below list
        Set<String> allProductsSet = new Set<String>{'TOPCRM','ADVANTAGE','TOPMRKSNP','TOPWEB','FIVESTREET','TOPIDX','COBROKE','LOCALEXPERT','LOCALEXPERTCITY'}; // CRM-6156
        Set<STring> hideZeroDollarProduct = new Set<String>{'FIVESTREET','TOPCRM','TOPMRKSNP'};
        
        // Get all active assets details
        // CRM-6090: Added order by Extended_Net_Price__c
        assetlist = [select id ,name, Commerce_Group__c,
                     Product2.name,Product_Code__c,
                     Market_Zip__c,Lead_Type__c, Product2.productcode,
                     Product_Type__c,Contract_Term__c,Monthly_Price__c,
                     Original_Payment__c,Billing_Period__c,account.Advertiserid__c,
                     Start_Date__c,End_Date__c,Paid_Amount__c,License_Tier__c,
                     Market__c, Quantity__c, Order_Line_Item__r.OrderId, 
                     Remaining_Amount__c, Total_Net_Price__c, Legacy_Created_Date__c,
                     Legacy_Product__c, Legacy_Created_By__c, Net_Price__c, Extended_Net_Price__c
                     from Asset 
                     where AccountId =: currentRecordId AND Asset_Type__c = 'Parent' AND Promotion__c NOT IN :lstPromoCode
                     AND Status = 'Active' AND Fulfillment_Status__c != 'Failure' and  product_code__c IN :allProductsSet 
                     AND (Extended_Net_Price__c > 0 OR (Extended_Net_Price__c = 0 and product_code__c NOT IN :hideZeroDollarProduct)) Order By Extended_Net_Price__c desc];
        
        system.debug('assetlist'+assetlist);
        assetIdSet = new Set<id>();
        assetIdOrderNumMap = new Map<id, String>();
        
        // These fields are used to hide the columns if values are NULL.
        marketNotNull = false;
        PaidInFullNotNull=false;
        monthlyPayNotNull=false;
        sellerLeadBundleExist = false;
        if(!assetlist.isEmpty()){
            for(Asset asst : assetlist){
                if(asst.Id != null) {
                    assetIdSet.add(asst.Id);
                }
                
                if(asst.Market__c != null){
                    marketNotNull = true;
                }
                
                if(asst.Billing_Period__c == 'Monthly'){
                    monthlyPayNotNull = true;
                } else {
                    paidInFullNotNull = true;
                }
                
            }
            
            // Get orderItems where order type is New or Renew for above assets
            List<OrderItem> oliList = new List<OrderItem>();
            Set<String> orderTypeSet = new Set<String>{'New', 'Renewal'};
           
            oliList = [select id, Order.OrderNumber, Asset__c
                       from OrderItem 
                       where Asset__c IN :assetIdSet And Order.Type IN :orderTypeSet];
            
            
            for(OrderItem oli : oliList){
                assetIdOrderNumMap.put(oli.Asset__c, oli.Order.OrderNumber);
            }
            getassetOrderWrapper(assetlist, assetIdOrderNumMap);
        }
    }
    
    public void getassetOrderWrapper(List<Asset> assetlist, Map<id, String> assetIdOrderNumMap){
        Set<String> licenseTierProd = new Set<String>{'REESIO','TOPCRM','TOPMRKSNP','TOPWEB','TOPWEBFEE','FIVESTREET'};
        for(Asset asst : assetlist){
            
            // Migrated assets will not have any order associated so OrderNumber will be NULL.
            String OrderNumber = '';
            String ProductName = asst.Product2.name;
            Decimal NetPrice = asst.Extended_Net_Price__c;
            Integer quantity = Integer.valueOf(asst.Quantity__c);
            // For all other assets (non-migrated) update the OrderNumber.
            if(assetIdOrderNumMap.containsKey(asst.Id)){
                OrderNumber = assetIdOrderNumMap.get(asst.Id);
            }
            
            if(asst.Product_code__c == 'SELLERLEADBUNDLE'){
                sellerLeadBundleExist = true;
                ProductName = asst.Product2.name + '*';
            }
            
            // For Migrated assets NetPrice can be NULL, so replace with 0.00. 
            if(!assetIdOrderNumMap.containsKey(asst.Id) && asst.Legacy_Created_Date__c != null && NetPrice == null){
                NetPrice = 0.00;
            }
            if(NetPrice != null){
                NetPrice = NetPrice.setScale(2);
            }
            //LCM-440: BMS
            if(asst.commerce_group__c == 'Broker Marketing Solution'){
                bmsPaidInFullPrice += asst.Extended_Net_Price__c;
                bmsMonthlyPrice += asst.Monthly_Price__c;
            }
            
            if(asst.Product_Code__c == 'COBROKE'){
                ProductName = Label.COBROKE_Product_Name2;
            }
            //CRM-5981
            if(licenseTierProd.contains(asst.product_code__c)){
                quantity = Integer.valueOf(asst.License_Tier__c);
            }
            
            assetOrderWrapper aow = new assetOrderWrapper(
                ProductName,
                asst.Lead_Type__c,
                asst.Product_Type__c,
                asst.Contract_Term__c,
                NetPrice,
                asst.Billing_Period__c,
                asst.Start_Date__c,
                asst.End_Date__c,
                asst.Market__c,
                quantity,
                asst.Paid_Amount__c,
                OrderNumber
            );
            if(asst.commerce_group__c == 'Broker Marketing Solution'){
                bmsAssetOrderList.add(aow);
            } else {
                assetOrderList.add(aow);
            }
        }
       
    }
    
    
    public class assetOrderWrapper {
        public string Product_Name {get; set;} 
        public string Lead_Type  {get; set;}
        public string Product_Type  {get; set;}
        public string Contract_Term  {get; set;}
        public Decimal Net_Price  {get; set;}
        public string Billing_Period {get; set;}
        public Date Start_Date {get; set;}
        public Date End_Date {get; set;}
        public string Market   {get; set;}
        public Integer Quantity  {get; set;}
        public Decimal Paid_Amount   {get; set;}
        public string OrderNumber {get; set;}
        
        
        public assetOrderWrapper (
            string Product_Name_wrap,
            string Lead_Type_wrap,  
            string Product_Type_wrap, 
            string Contract_Term_wrap, 
            Decimal Net_Price_wrap, 
            string Billing_Period_wrap, 
            Date Start_Date_wrap,
            Date End_Date_wrap,  
            string Market_wrap,   
            Integer Quantity_wrap,  
            Decimal Paid_Amount_wrap, 
            string OrderNumber_wrap 
        ) {
            this.Product_Name = Product_Name_wrap;
            this.Lead_Type = Lead_Type_wrap;
            this.Product_Type = Product_Type_wrap;
            this.Contract_Term = Contract_Term_wrap;
            this.Net_Price = Net_Price_wrap;
            this.Billing_Period = Billing_Period_wrap;
            this.Start_Date = Start_Date_wrap;
            this.End_Date = End_Date_wrap;
            this.Market = Market_wrap;
            this.Quantity = Quantity_wrap;
            this.Paid_Amount = Paid_Amount_wrap;
            this.OrderNumber = OrderNumber_wrap;
        }
    }
    
}