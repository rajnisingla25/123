global Class ProductInformationController{
    
    public String orderType {get;set;}
    public String bmsOrderType {get;set;}
    public Boolean isBMS {get;set;}
    public Boolean renewOrder {get;set;}
    public Boolean sellerBundle {get;set;}
    public Boolean nonAutoRenew {get;set;}
    public Boolean displayRSModifyTable {get;set;}
    Public Boolean isStdPSBundleModify {get;set;}
    public Id ordId;
    public String sellerLeadProductCode  {get;set;}
    public boolean isDisplayLeadVolumeText {get; set;}
    public boolean hasMonthToMonth {get; set;}
    public Order thisOrder {get; set;}

    public string getOrdId(){
        return ordId;
    }
    public String teststr {get;set;}
    public void setOrdId(String value){
        ordId = value;
        system.debug('orderId --->'+ordId);
        String bigQuote = 'BigMachines__Quote__c';
        String ord = 'Order';
        String objName = ordId.getSObjectType().getDescribe().getName();
        if(objName == ord){ //for orders
            items = getBundledProducts(getProductInformationMap(getOrderItems(OrdId))); 
        }else if(objName == bigQuote){ //for quotes
            items = getBundledProducts(getProductInformationMap(getBundledOrderItems(OrdId))); 
        }
        
        /*
if(ordId.startsWith('801')){ //for orders
items = getBundledProducts(getProductInformationMap(getOrderItems(OrdId))); 
}else if(ordId.startsWith('a10')){ //for quotes
items = getBundledProducts(getProductInformationMap(getBundledOrderItems(OrdId))); 
}
*/
        //CRM-3081 -- Venu Modified to display the text for SELLERLEADBUNDLE and COBROKE
        for (BundledProduct i: items) {
            if (i.productCode == 'SELLERLEADBUNDLE' || i.productCode == 'COBROKE') {
                isDisplayLeadVolumeText = true;
            }
        }
        
        system.debug('items -->'+items);
    }
    public List<BundledProduct> items {get;set;}
    public List<BundledProduct> rsBundleModifyItems {get;set;}
    public ProductInformationController(){
        sellerLeadProductCode = SellerLeadUtilityClass.sellerLeadProductCode;
        isBMS = false;
    }
    public List<Orderitem> getBundledOrderItems(string quoteId){
        isBMS = true;
        List<Order> bundledOrders = [SELECT id FROM Order WHERE Oracle_Quote__c =: quoteId AND Is_BMS__c = true];
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order ord: bundledOrders){
            orderItems.addAll(getOrderItems(ord.id));
        }
        return orderItems;
    }
    
    public List<OrderItem> getOrderItems(string orderId){
        system.debug('orderId --->'+orderId);
        // CRM-2839 - Added field Lead_Type__c in below SOQL
        List<OrderItem> orderItems = [SELECT id,(select Fulfilled_Zip_List__c from Assets__r where Asset_Type__c = 'Fulfill To' limit 1), order.products__c, Trial__c, order.Oracle_Quote__r.BigMachines__Transaction_Id__c,
                                      Product_Type__c, Lead_Type__c, order.Oracle_Quote__r.BigMachines__Account__r.Auto_Renewal__c, pricebookentry.product2.productcode, No_Term_Sale__c, order.TotalAmount,
                                      pricebookentry.product2.DefaultRenewalTerm__c, order.Oracle_Quote__r.BigMachines_Quote_Type__c, order.SellerLeadBundleCount__c, Promotion__c, Asset__c, order.Suppress_Order_Confirmation__c,
                                      PricePerImpressionSold__c,order.Type, Contractedimpressions__c,License_Tier__c,License__c, order.Non_Renewal_count__c, Extended_Net_Price__c, order.Order_First_Month_Total__c,
                                      Part_Number__c, Delta_Price__c, order.orderNumber, amend_type__c, line_type__c, Asset__r.Asset_Number__c, PricebookEntry.Product2.Name, order.IsMonthToMonth__c,
                                      Contract_Term__c, Market__c, Quantity, Billing_Period__c, Total_Net_Price__c, Total_Net__c, order.EffectiveDate, Start_Date__c, End_Date__c, Asset__r.No_Term_Sale__c,
                                      order.EndDate, Commerce_Group__c FROM OrderItem WHERE orderId =: orderId AND Line_Type__c != 'Cancel' AND Line_Type__c != 'Credit' AND Line_type__c != 'Buyout'];
        system.debug('orderItems ---->'+orderItems);
         // CRM-4002 (Standalone RS): Hide Respond if connect is present 
        List<OrderItem> orderItemsNew = new List<OrderItem>();
        displayRSModifyTable = false;
        isStdPSBundleModify = false;
        Set<String> promoBundle = new Set<String>();
        hasMonthToMonth = false;
        promoBundle.addAll(System.Label.RS_bundle_email_suppress_promo.split(';'));
        Boolean hasBundlePromo = false;
        
        // RS bundling: Hide order items with bundle promo codes
        if(!orderItems.isEmpty()){
          
            for(OrderItem oi: orderItems){
                boolean hasPromoProdLevel = false;
                if(oi.Part_Number__c != 'RSRESPOND' || (oi.Part_Number__c == 'RSRESPOND' && !orderItems[0].order.products__c.contains('RSCONNECT'))){
                    if(oi.Promotion__c == null){
                        orderItemsNew.add(oi);
                    } else {
                        //CRM-5271
                        List<string> assetPromo = oi.Promotion__c.split('---');
                        for(String promo: assetPromo){
                            if(promoBundle.contains(promo)){
                                hasBundlePromo = true;
                                hasPromoProdLevel = true;
                            }
                        }
                        if(!hasPromoProdLevel){
                            orderItemsNew.add(oi);
                        }
                    }
                }
            }
            // If order contains cobroke then add all other amend products from same quote
            if(orderItems[0].order.products__c.contains('COBROKE')){
                getModifyOrderItems(orderItemsNew[0].order.Oracle_Quote__c);
            }
        }
        // End RS bundling
        // CRM-5197 Added else condition. This will pick prosoft products with bundle promo
        if(!orderItemsNew.isEmpty()){ 
            orderType = orderItemsNew[0].order.type; 
            renewOrder = orderItemsNew[0].order.Non_Renewal_count__c == 0 ? true: false; 
            sellerBundle = orderItemsNew[0].order.SellerLeadBundleCount__c == 0 ? false: true; 
            nonAutoRenew = orderItemsNew[0].Part_Number__c == 'MEDIABUY' ? true: false;
            thisOrder = orderItemsNew[0].order;
        } else if(orderItems[0].order.Type == 'Modify' && hasBundlePromo){
             isStdPSBundleModify = true;
             rsBundleModifyItems = getBundledProducts(getProductInformationMap(orderItems)); 
             displayRSModifyTable = true;
        }
        return orderItemsNew;
    }
    
    // RS bundle: Method to get all amend order products from same quote.
    public void getModifyOrderItems(string quoteId){
        if(quoteId != null && quoteId != ''){
             List<Order> bundledOrders = [SELECT id FROM Order WHERE Suppress_Order_Confirmation__c = true and Oracle_Quote__c =: quoteId];
            
            if(!bundledOrders.isEmpty()){
                List<OrderItem> orderItems = [SELECT id,(select Fulfilled_Zip_List__c from Assets__r where Asset_Type__c = 'Fulfill To' limit 1), order.products__c, Trial__c,Asset__c, order.Order_First_Month_Total__c,
                                              Product_Type__c, Lead_Type__c, order.Oracle_Quote__r.BigMachines__Account__r.Auto_Renewal__c, pricebookentry.product2.productcode, No_Term_Sale__c,
                                              pricebookentry.product2.DefaultRenewalTerm__c, order.Oracle_Quote__r.BigMachines_Quote_Type__c, order.SellerLeadBundleCount__c, Promotion__c,order.TotalAmount,
                                              PricePerImpressionSold__c,order.Type, Contractedimpressions__c,License_Tier__c,License__c, order.Non_Renewal_count__c, Extended_Net_Price__c, 
                                              Part_Number__c, Delta_Price__c, order.orderNumber, amend_type__c, line_type__c, Asset__r.Asset_Number__c, PricebookEntry.Product2.Name, Asset__r.No_Term_Sale__c,
                                              Contract_Term__c, Market__c, Quantity, Billing_Period__c, Total_Net_Price__c, Total_Net__c, order.EffectiveDate, Start_Date__c, End_Date__c, 
                                              order.EndDate, Commerce_Group__c FROM OrderItem WHERE orderId IN : bundledOrders AND Line_Type__c = 'amend'];
         
                // CRM-4684: Check if customer already owns free product and remove it
                if(!orderItems.isEmpty()){
                    Set<Id> assetIds = new Set<Id>();
                    List<orderItem> finalOrderItems = new List<orderItem>();
                    for(orderItem oitem: orderItems){
                        assetIds.add(oitem.Asset__c);
                    }
                    List<orderItem> suppressItem = [SELECT id,Asset__c from OrderItem where Line_Type__c = 'add' and Asset__c IN :assetIds and (Total_Net__c = 0.00 OR Total_Net__c = null)];
                    
                    if(!suppressItem.isEmpty()){
                        assetIds.clear();
                        for(orderItem op: suppressItem){  
                          assetIds.add(op.asset__c);
                      }
                        // If $0 product then do not add to the final list
                        for(orderItem oitem: orderItems){
                            if(!assetIds.contains(oitem.Asset__c)){
                                finalOrderItems.add(oitem);
                            }
                        }
                    } else {
                        finalOrderItems.addAll(orderItems);
                    }
                    
                    displayRSModifyTable = true;    
                    // List used to populate details in modification table
                    rsBundleModifyItems = getBundledProducts(getProductInformationMap(finalOrderItems)); 
                    if(rsBundleModifyItems.isEmpty()){
                        displayRSModifyTable = false;
                    }
                }
        
            }
        }
       
            
    }
    
    public Map<String,List<orderItem>> getProductInformationMap(List<OrderItem> orderItems){
        Map<String,List<OrderItem>> productInformationMap = new Map<String,List<orderItem>>();
        for(OrderItem oi: orderItems){
            
            if(productInformationMap.containsKey(oi.Commerce_Group__c)){             
                productInformationMap.get(oi.Commerce_Group__c).add(oi);
            }else{
                productInformationMap.put(oi.Commerce_Group__c, new List<OrderItem>{oi});               
            }
        }
        system.debug('productInformationMap ---->'+productInformationMap);
        return productInformationMap;
    }
    
    public List<BundledProduct> getBundledProducts(Map<String,List<OrderItem>> infoMap){
        List<BundledProduct> products = new List<BundledProduct>();
        string fulfilledZipList = '';
        //CRM-4303: Using License Tier field value for quantity
        Set<String> licenseTierProd = new Set<String>{'REESIO','TOPCRM','TOPMRKSNP','TOPWEB','TOPWEBFEE','FIVESTREET'};
            for(String bundle: infoMap.keySet()){
                system.debug('--- bundle '+bundle);
               
                if(bundle != 'Broker Marketing Solution' && bundle != 'Agent Marketing Solution'){
                    for(OrderItem oi: infoMap.get(bundle)){
                        string lineType = oi.line_type__c == 'Renew' || oi.Line_type__c == 'Add' ? oi.line_type__c : oi.amend_Type__c;
                        //boolean showLicenseTier = (oi.order.type == 'Modify' && (oi.Part_Number__c == 'FIVESTREET' || oi.Part_Number__c == 'TOPCRM')) ? true: false;
                        Decimal quantity;
                        String Percentage;
                        Decimal Total_Net_Price = 0.00;
                        String productType;
                        Date endDate;
                        String leadType;
                        String defaultRenewalTerm = oi.order.Oracle_Quote__r.BigMachines__Account__r.Auto_Renewal__c == true ? (oi.pricebookentry.product2.DefaultRenewalTerm__c == null ? 'N/A' : (oi.pricebookentry.product2.productCode == 'RSRESPOND' && oi.Contract_Term__c == '1' ? 'N/A' : oi.pricebookentry.product2.DefaultRenewalTerm__c)) : 'N/A';                                      
                        String name = oi.Product_Type__c == 'Brand' ? 'Advantage - Branding' : oi.PricebookEntry.Product2.Name ;
                        String terms = oi.Contract_Term__c;
                        endDate = oi.End_Date__c;  
                        boolean noTermSale = false;
                        // CRM-4718 :updated terms to "1"
                        // CRM-4825 :updated if condition to check Asset field if order is not New order
                        if((oi.order.type == 'New' && oi.No_Term_Sale__c) || (oi.Asset__c != null && oi.Asset__r.No_Term_Sale__c)){
                            terms = '1';
                            noTermSale = true; //CRM-5053
                            hasMonthToMonth = true;
                            endDate = oi.Start_Date__c.addMonths(1).addDays(-1);
                        }
                        //CRM-4303: Using License Tier field value for quantity
                        if(licenseTierProd.contains(oi.Part_Number__c)){
                            quantity = oi.License_Tier__c;
                        } else if( oi.Part_Number__c == 'TURBO' ){
                            quantity = oi.Contractedimpressions__c;
                        } else {
                            quantity = oi.Quantity; 
                        }
                        if(oi.Part_Number__c == 'LOCALEXPERT' || oi.Part_Number__c == 'LOCALEXPERTCITY'){
                            percentage = oi.Part_Number__c == 'LOCALEXPERT' ? oi.Product_Type__c.remove('SOV')+'%' : string.valueOf(oi.quantity*10).remove('.00')+'%';     
                            //CRM-5011
                            productType = 'Share of Market';
                            leadType = '';            
                            
                        }else if(oi.Trial__c){
                            // CRM-4212: Added for trial RS products
                            productType = 'Free trial';
                        } else {
                            productType = oi.Product_Type__c;
                            leadType = oi.Lead_Type__c;
                        }
                        if(oi.Billing_Period__c == 'Monthly'){ //CRM-1439
                            Total_Net_Price = oi.Total_Net_Price__c;
                        }
                        if( oi != null && oi.Assets__r != null && oi.Assets__r.size() > 0 ){
                            fulfilledZipList =  oi.Assets__r[0].Fulfilled_Zip_List__c;
                        }else{
                            fulfilledZipList = '';
                        }
                       
                        products.add(new BundledProduct(
                            oi.Asset__r.Asset_Number__c, 
                            name, 
                            oi.Start_Date__c, 
                            terms, 
                            endDate, 
                            quantity, 
                            percentage,
                            oi.Billing_Period__c, 
                            Total_Net_Price, 
                            oi.Total_Net__c,
                            linetype,
                            oi.Extended_Net_Price__c,
                            oi.delta_price__c, 
                            oi.Market__c,
                            oi.License__c,
                            oi.License_Tier__c,
                            oi.Part_Number__c,
                            oi.PricePerImpressionSold__c,
                            fulfilledZipList,
                            defaultRenewalTerm,
                            // CRM-2839 - Pass two new parameters Product_Type__c & Lead_Type__c
                            productType,
                            leadType,
                            displayRSModifyTable,
                            noTermSale //CRM-5053
                        ));
                    }
                }else
                {
                    String contractNumber = '';
                    String description = '';
                    Date startDate;
                    String terms;
                    Date endDate;
                    Decimal quantity;
                    String percentage;
                    String billingPeriod;
                    Decimal monthlyPayment = 0.00;
                    Decimal totalProductCost = 0.00;    
                    String lineType = '';   
                    Decimal extendedPrice = 0.00;
                    Decimal deltaPrice = 0.00;   
                    String market = '';
                    Decimal license;
                    Decimal licenseTier;
                    Decimal cpl;
                    string productCode;    
                    string defaultRenewalTerm;
                    Boolean notermSale;
                    // CRM-2839 - Declare two new variables productType & leadType
                    string productType;
                    string leadType;
                    
                    bmsOrderType = infoMap.get(bundle)[0].order.Oracle_Quote__r.BigMachines_Quote_Type__c;
                    Set<String> frequencies = new Set<String>(); //CRM 1439
                    for(OrderItem oi : infoMap.get(bundle)){
                        
                        contractNumber = oi.order.orderNumber;
                        description = oi.Product_Type__c == 'Brand' ? 'Advantage - Branding' : oi.Commerce_Group__c;
                        if(description == 'Local Expert'){
                            description = 'Local Expert Zip Ad';
                        }
                        if(description == 'Local Expert City'){
                            description = 'Local Expert City Ad';
                        }
                        startDate = oi.Start_Date__c;
                        terms = oi.Contract_Term__c;    
                        //CRM-4718  CRM-4825
                        endDate = oi.End_Date__c; 
                        if((oi.order.type == 'New' && oi.No_Term_Sale__c) || (oi.Asset__c != null && oi.Asset__r.No_Term_Sale__c)){
                            terms = '1';
                            hasMonthToMonth = true;
                            notermSale = true;// CRM-5053         
                            endDate = oi.Start_Date__c.addMonths(1).addDays(-1);
                        }
                        //CRM-4718 :END
                        
                        //CRM-4303: Using License Tier field value for quantity
                        if(licenseTierProd.contains(oi.Part_Number__c)){
                            quantity = oi.License_Tier__c;
                        } else if( oi.Part_Number__c == 'TURBO' ){
                            quantity = oi.Contractedimpressions__c;
                        } else {
                            quantity = oi.Quantity; 
                        }
                        if(oi.Part_Number__c == 'LOCALEXPERT' || oi.Part_Number__c == 'LOCALEXPERTCITY'){
                           percentage = oi.Part_Number__c == 'LOCALEXPERT' ? oi.Product_Type__c.remove('SOV')+'%' : string.valueOf(oi.quantity*10).remove('.00') +'%';     

                        }
                        productCode = oi.Part_Number__c;
                        if( oi != null && oi.Assets__r != null && oi.Assets__r.size() > 0 ){
                            fulfilledZipList =  oi.Assets__r[0].Fulfilled_Zip_List__c;
                        }else{
                            fulfilledZipList = '';
                        }
                        cpl = oi.PricePerImpressionSold__c;
                        frequencies.add(oi.Billing_Period__c); //crm-1439
                        if(frequencies.contains('Monthly')){ //crm-1439
                            billingPeriod = 'Monthly';
                        }else if(frequencies.contains('Annual')){
                            billingPeriod = 'Annual';
                        }else if(frequencies.contains('Bi-Annual')){
                            billingPeriod = 'Bi-Annual'; 
                        }else{
                            billingPeriod = oi.Billing_Period__c;
                        }
                        
                        if(oi.Billing_Period__c == 'Monthly'){ //CRM-1439
                            monthlyPayment  = monthlyPayment + (oi.Total_Net_Price__c == null ? 0.00 : oi.Total_Net_Price__c);
                        }
                        totalProductCost = totalProductCost + (oi.Total_Net__c == null ? 0.00 : oi.Total_Net__c);
                        lineType = oi.line_type__c == 'Renew' || oi.Line_type__c == 'Add' ? oi.line_type__c : oi.amend_Type__c;
                        extendedPrice = extendedPrice + (oi.Extended_Net_Price__c == null ? 0.00 : oi.Extended_Net_Price__c);
                        deltaPrice = deltaPrice + (oi.Delta_Price__c == null ? 0.00 : oi.Delta_Price__c);
                        market = oi.Market__c;
                        license = oi.License__c;
                        licenseTier = oi.License_Tier__c;
                        // CRM-4303: not needed
                        //showLicenseTier = (oi.order.type == 'Modify' && (oi.Part_Number__c == 'FIVESTREET' || oi.Part_Number__c == 'TOPCRM')) ? true : false ;
                        defaultRenewalTerm = oi.order.Oracle_Quote__r.BigMachines__Account__r.Auto_Renewal__c == true ? (oi.pricebookentry.product2.DefaultRenewalTerm__c == null ? 'N/A' : (oi.pricebookentry.product2.productCode == 'RSRESPOND' && oi.Contract_Term__c == '1' ? 'N/A' : oi.pricebookentry.product2.DefaultRenewalTerm__c)) : 'N/A';
                        
                        // CRM-2839 - Assign variables value for productType & leadType
                        if(oi.Part_Number__c == 'LOCALEXPERT' || oi.Part_Number__c == 'LOCALEXPERTCITY'){
                            //CRM-5011
                            //productType = 'Share of Voice';
                            productType = 'Share of Market';
                        }else{
                            productType = oi.Product_Type__c;
                        }
                        if(oi.Part_Number__c == 'LOCALEXPERT' || oi.Part_Number__c == 'LOCALEXPERTCITY'){
                            leadType = '';
                        }else{
                            leadType = oi.Lead_Type__c;                                      
                        }     
                        productType = oi.Product_Type__c;
                        leadType = oi.Lead_Type__c;              
                        
                    }
                    products.add(new BundledProduct(
                        contractNumber, 
                        description, 
                        startDate, 
                        terms, 
                        endDate, 
                        quantity, 
                        percentage,
                        billingPeriod, 
                        monthlyPayment, 
                        totalProductCost,
                        linetype,
                        extendedPrice,
                        deltaPrice,
                        market,
                        license,
                        licenseTier, 
                        productCode,
                        cpl ,
                        fulfilledZipList,
                        defaultRenewalTerm,
                        // CRM-2839 - Pass two new parameters productType & LeadType
                        productType,
                        leadType,
                        displayRSModifyTable,
                        notermSale
                    ));
                }
            }
        System.debug('products ---->'+products);
        return products;
    }
    
    public Class BundledProduct{
        public string contractNum {get;set;}
        public string description {get;set;}
        public date startDate {get;set;}
        public string terms {get;set;}
        public date endDate {get;set;}
        public decimal quantity {get;set;}
        public string percentage {get;set;} //local expert
        public string billingFrequency {get;set;}
        public decimal monthlyPayment {get;set;}
        public decimal totalProductCost {get;set;}
        public string lineType {get;set;}
        public decimal extendedPrice {get;set;}
        public decimal deltaPrice {get;set;}
        public string market {get;set;}
        public decimal license {get;set;}
        public decimal licenseTier {get;set;}
        public decimal costPerLead {get;set;}
        public string productCode {get;set;}
        public string fulfilledZipList {get;set;}
        public string defaultRenewalTerm {get;set;}
        public boolean displayRSModifyTable {get;set;}
        public boolean noTermSale {get;set;}
        
        // CRM-2839 - Added below two attributes productType & leadType
        public string productType {get;set;}
        public string leadType {get;set;}        
        public BundledProduct(string wrap_contractNum, 
                              string wrap_description, 
                              date wrap_startDate, 
                              string wrap_terms, 
                              date wrap_endDate, 
                              decimal wrap_quantity, 
                              string wrap_percentage,
                              string wrap_billingFrequency, 
                              decimal wrap_monthlyPayment, 
                              decimal wrap_totalProductCost, 
                              string wrap_lineType,
                              decimal wrap_extendedPrice, 
                              decimal wrap_deltaPrice, 
                              string wrap_market,
                              decimal wrap_license,
                              decimal wrap_licenseTier,
                              string wrap_productCode,
                              decimal wrap_costPerLead,
                              string wrap_fulfilledZipList,
                              string wrap_defaultRenewalTerm,
                              // CRM-2839 - Pass two new parameters wrap_productType & wrap_leadType
                              string wrap_productType,
                              string wrap_leadType,
                              boolean wrap_displayRSModifyTable,
                              boolean wrap_noTermSale
                             ){
                                 Date myDate = Date.newInstance(2026, 12, 31);
                                 this.contractNum = wrap_contractNum;
                                 this.description = wrap_description;
                                 if(this.description == 'Local Expert'){
                                     this.description = 'Local Expert Zip Ad';
                                 }
                                 if(this.description == 'Local Expert City'){
                                     this.description = 'Local Expert City Ad';
                                 }
                                
                                 //CRM-5053: Check month-to-month flag instead of checking contract term in VF component
                                 this.noTermSale = wrap_noTermSale;
                                 // CRM-4840: C+ renaming
                                 Date GADate = Date.valueOf(Label.Connections_Plus_GA_date);
                                 if(GADate <= date.today() && wrap_productCode == 'COBROKE'){
                                      this.description = label.COBROKE_Product_Name;
                                 }
                                 this.startDate = wrap_startDate;
                                 this.terms = wrap_terms;
                                 if(myDate>wrap_endDate || wrap_displayRSModifyTable){
                                     this.endDate = wrap_endDate;
                                 } else {
                                     this.endDate = null;
                                 }
                                 this.quantity = wrap_quantity;
                                 this.percentage = wrap_percentage;
                                 this.billingFrequency = wrap_billingFrequency;
                                 this.monthlyPayment = wrap_monthlyPayment;
                                 this.totalProductCost = wrap_totalProductCost;
                                 this.lineType = wrap_linetype;
                                 this.extendedPrice = wrap_extendedPrice;
                                 this.deltaPrice = wrap_deltaPrice;
                                 this.market = wrap_market;
                                 this.license = wrap_license;
                                 this.licenseTier = wrap_licenseTier;
                                 this.productCode = wrap_productCode;
                                
                                 if( wrap_productCode == SellerLeadUtilityClass.sellerLeadProductCode ){
                                     this.costPerLead = wrap_costPerLead;
                                 }else{
                                     this.costPerLead = null;
                                 }
                                 this.fulfilledZipList = wrap_fulfilledZipList;
                                 this.defaultRenewalTerm = wrap_defaultRenewalTerm;
                                 
                                 // CRM-2839 - Assign two new parameters to class attributes productType & leadType
                                 this.productType = wrap_productType;
                                 this.leadType = wrap_leadType;
                             }
        
        
    }
}