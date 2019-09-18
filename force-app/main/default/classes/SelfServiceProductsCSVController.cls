/*****************************************************************************
* Class Name: SelfServiceProductsCSVController
* Author: Shraddha Kabade
* Purpose: To generate CSV file with product details
* JIRA : LCM-435
****************************************************************************/
public class SelfServiceProductsCSVController {
    
    public List<assetWrapper> assetsWrapperList {get;set;}
    public List<assetWrapper> bmsAssetsWrapperList {get;set;}
    public String csvFileName {get;set;}
    public String bmsHeader {get;set;}
    public String bmsColumns {get;set;}
    public String csvColumnNames {get;set;}
    public Decimal bmsPrice {get;set;}
    
    public SelfServiceProductsCSVController(){
        String acctId  = ApexPages.CurrentPage().getparameters().get('id');
        csvColumnNames = '"Product","Market","Quantity","Lead Type","Product Type","Term","Monthly Payment","Start Date","End Date","Order Number","Item Number"';
        assetsWrapperList = new List<assetWrapper>();
        bmsAssetsWrapperList = new List<assetWrapper>();
        bmsHeader = null;
        bmsColumns = null;
        bmsPrice = 0;
        csvFileName = 'customerAccountSummary';
        Set<String> allProductsSet = new Set<String>{'TOPCRM','ADVANTAGE','TOPMRKSNP','TOPWEB','FIVESTREET','TOPIDX','COBROKE','LOCALEXPERT'};
        Set<STring> hideZeroDollarProduct = new Set<String>{'FIVESTREET','TOPCRM','TOPMRKSNP'};
        Set<String> licenseTierProd = new Set<String>{'REESIO','TOPCRM','TOPMRKSNP','TOPWEB','TOPWEBFEE','FIVESTREET'};
        List<Asset> assetlist =  [select id ,name,Product_Code__c,Quantity__c,Extended_Net_Price__c, Market_Zip__c,Lead_Type__c,Commerce_Group__c,
                                  Product2.productcode, Product_Type__c,Contract_Term__c,Billing_Period__c,Start_Date__c,End_Date__c, Market__c,Promotion__c, 
                                  Order_Line_Item__r.Order.OrderNumber, Asset_Number__c,Product2.name, License_Tier__c, Monthly_Price__c, account.Advertiserid__c
                                  from Asset where AccountId =: acctId AND Asset_Type__c = 'Parent' AND Status = 'Active' AND Fulfillment_Status__c != 'Failure'
                                  and product_code__c IN :allProductsSet and (Extended_Net_Price__c > 0 OR (Extended_Net_Price__c = 0 and product_code__c NOT IN :hideZeroDollarProduct))  order by Monthly_Price__c desc];
                                  system.debug(assetlist);
        if(!assetlist.isEmpty()){
            //csvFileName += '_'+assetlist[0].account.Advertiserid__c + '_'+((Datetime) date.today()).format('MM-dd-YYYY');
            Date dtoday = date.today();
            csvFileName += '_'+assetlist[0].account.Advertiserid__c + '_'+dtoday.month()+'-'+dtoday.day()+'-'+dtoday.year();
            Set<id> assetIdSet = new Set<id>();
            Map<id, String> assetIdOrderNumMap = new Map<id, String>();
            
            for(Asset ast: assetlist){
                if(ast.Id != null) {
                    assetIdSet.add(ast.Id);
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
           
            for(Asset ast: assetlist){
                // Migrated assets will not have any order associated so OrderNumber will be NULL.
                String OrderNumber = '';
                String netPrice = String.valueOf(ast.Monthly_Price__c.setScale(2));
                String market = '';
                String productName = ast.Product2.name;
                Decimal quantity = ast.Quantity__c;
                if(ast.commerce_group__c == 'Broker Marketing Solution'){
                    netPrice = 'Bundle Pricing';
                    bmsPrice += ast.Monthly_Price__c;
                }
                system.debug(ast);
                 // For all other assets (non-migrated) update the OrderNumber.
                if(assetIdOrderNumMap.containsKey(ast.Id)){
                    OrderNumber = assetIdOrderNumMap.get(ast.Id);
                }
                
                if(ast.Market__c != null){
                    market = ast.Market__c.escapeCsv();
                }
                
                if(ast.Product_Code__c == 'COBROKE'){
                    productName = Label.COBROKE_Product_Name2;
                }
                if(licenseTierProd.contains(ast.product_code__c)){
                    quantity = ast.License_Tier__c;
                }
                
                assetWrapper newAsset = new assetWrapper(
                    productName,
                    ast.Lead_Type__c,
                    ast.Product_Type__c,
                    ast.Contract_Term__c,
                    netPrice,
                    ast.Billing_Period__c,
                    ast.Start_Date__c.month()+'/'+ ast.Start_Date__c.day()+'/'+ast.Start_Date__c.year(),//CRM-5980
                    ast.End_Date__c.month()+'/'+ ast.End_Date__c.day()+'/'+ast.End_Date__c.year(),
                    market,
                    quantity,
                    OrderNumber,
                    ast.Asset_Number__c
                );
                if(ast.commerce_group__c == 'Broker Marketing Solution'){
                    bmsAssetsWrapperList.add(newAsset);
                } else {
                    assetsWrapperList.add(newAsset);
                }
                
            }
            if(!bmsAssetsWrapperList.isEmpty()){
                 bmsHeader = '\n Broker Marketing Solution,,,,,,'+String.valueOf(bmsPrice);
                 if(!assetsWrapperList.isEmpty()){ bmsColumns = '\n\n'+csvColumnNames;}
            }
           
        }
    }
    
    public class assetWrapper {
        public string Product_Name {get; set;} 
        public string Lead_Type  {get; set;}
        public string Product_Type  {get; set;}
        public string Contract_Term  {get; set;}
        public String Net_Price  {get; set;}
        public string Billing_Period {get; set;}
        public String Start_Date {get; set;}
        public String End_Date {get; set;}
        public string Market   {get; set;}
        public Decimal Quantity  {get; set;}
        public string OrderNumber {get; set;}
        public string AssetNumber {get; set;}
        
        public assetWrapper (
            string Product_Name_wrap,
            string Lead_Type_wrap,  
            string Product_Type_wrap, 
            string Contract_Term_wrap, 
            String Net_Price_wrap, 
            string Billing_Period_wrap, 
            String Start_Date_wrap,
            String End_Date_wrap,  
            string Market_wrap,   
            Decimal Quantity_wrap,
            string OrderNumber_wrap,
            string AssetNumber_wrap
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
            this.OrderNumber = OrderNumber_wrap;
            this.AssetNumber = AssetNumber_wrap;
        }
    }
  
}