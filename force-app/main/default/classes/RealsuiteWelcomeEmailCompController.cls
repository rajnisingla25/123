// Name: RealsuiteWelcomeEmailCompController 
// Description(CRM 3140): Controller for 'RealsuiteWelcomeEmailComponent' and 'RealsuiteTrialVersionExpireComp'
// Author: Shraddha Kabade

Global class RealsuiteWelcomeEmailCompController {
    public String ordId;
    public String urltoCP {get;set;}
    public String paidProdNames {get;set;}
    public String trialProdNames {get;set;}
    public String numOfTrialDays {get;set;}
    public String trialPartNum {get;set;}
    public Boolean freeRespond {get;set;}
    public Boolean isRSBundle {get;set;}
    public OrderItem ordItem {get;set;}
    public Integer ord {get;set;}
    public Set<String> orderProducts {get;set;}
    Public boolean containsOnlyCityProd {get;set;}
    
    public string getOrdId(){
        return ordId;
    }
    public void setOrdId(String value){
        ordId = value;   
        getOrderItems(ordId);     
    }
    
    public void getOrderItems(string orderId){
        system.debug('orderId --->'+orderId);
        freeRespond = false;
        containsOnlyCityProd = false;
        orderProducts = new set<String>();
        Set<String> paidProdSet = new Set<String>();
        Set<String> trialProdSet = new Set<String>();
        List<String> prodList = new List<String>();
        Set<String> promoBundle = new Set<String>();
        isRSBundle = false;
        promoBundle.addAll(System.Label.RS_bundle_promo.split(';'));
   
        List<OrderItem> orderItems = [  SELECT Asset__r.Choice_Lead_URL__c, Product2.Name, Order.Account.Parent_Broker__r.Name, Order.products__c, promotion__c,
                                      Order.Account.Name, Order.Account.Parent_Broker__r.EssentialsStatus__c, Order.Account.EssentialsStatus__c,Part_Number__c,
                                      Order.Account.SSO_Email__c, Order.Contact_Name__c, Order.AccountId, Asset__r.Contract_term__c, Trial__c, Asset__r.Line_Type__c
                                      FROM 
                                      OrderItem 
                                      WHERE 
                                      orderId =: orderId
                                      AND
                                      Asset__r.Asset_Type__c   =  :TurboUtilityClass.assetTypeParent 
                                      AND
                                      line_type__c = 'Add'
                                     ];
        system.debug('orderItems ---->'+orderItems);
        orderProducts.addAll(orderItems[0].order.products__c.split(','));
        if(orderProducts.contains('LOCALEXPERTCITY') && !orderproducts.contains('LOCALEXPERT')){
           containsOnlyCityProd = TRUE; 
        }else{
            containsOnlyCityProd = FALSE;
        }
        if( orderItems != null && orderItems.size() > 0 ){
            urltoCP = orderItems[0].Asset__r.Choice_Lead_URL__c;
            ordItem = orderItems[0];
            numOfTrialDays = orderItems[0].Asset__r.Contract_term__c;
            ord = 0;
            for(OrderItem oi: orderItems){
                ord++;

                // CRM-3360: If previous Choice_Lead_URL__c link is null then add link of this asset
                if(urltoCP == null || urltoCP == ''){
                    urltoCP = oi.Asset__r.Choice_Lead_URL__c;
                }
                if(oi.Promotion__c == label.FreeRespondPromoWCEmail){
                    freeRespond = true;
                }
                //CRM-4002 (Standalone RS): Updated if condition to display higher RS Product in Welcome Call
                // RS bundle: Suppress RS details if in bundle (Updated If condition)
                if((oi.Promotion__c == null || (oi.Promotion__c != null && !promoBundle.contains(oi.Promotion__c))) ){
                  
                    if(oi.Part_Number__c != 'RSRESPOND' || (oi.Part_Number__c == 'RSRESPOND' && !orderItems[0].order.products__c.contains('RSCONNECT'))){
                         if(oi.Trial__c && oi.Asset__r.Line_Type__c != 'Cancel'){
                           // CRM-3102: String containing comma seperated part numbers for trial products
                           trialPartNum += oi.Part_Number__c+',';
                           trialProdSet.add(oi.Product2.Name);
                         } else {
                           paidProdSet.add(oi.Product2.Name);    
                         }
                    }
                } else {
                    isRSBundle = true;
                }
                
            }
            // CRM-4941: Added UTM code
            // CRM-6387: Updated UTM codes
            if(ordItem.order.products__c.contains('COBROKE') && ordItem.order.products__c.contains('LOCALEXPERT')){
                Email_templates_UTM__c rec = Email_templates_UTM__c.getInstance();
                urltoCP = urltoCP + rec.Welcome_Email_Cplus_and_lex__c;
            } else if(ordItem.order.products__c.contains('COBROKE')){
                Email_templates_UTM__c rec = Email_templates_UTM__c.getInstance();
                urltoCP = urltoCP + rec.Welcome_email_utm__c;
            } else if( ordItem.order.products__c.contains('LOCALEXPERT')){
                Email_templates_UTM__c rec = Email_templates_UTM__c.getInstance();
                urltoCP = urltoCP + rec.Welcome_Email_lex__c;
            }
        }
        if(!trialProdSet.isEmpty()){
            prodList.addAll(trialProdSet);
            trialProdNames = joinProdNames(prodList);
        } 
        prodList.clear();
        if(!paidProdSet.isEmpty()){
            prodList.addAll(paidProdSet);
            paidProdNames = joinProdNames(prodList);
        }
      
    }
    
    public String joinProdNames(List<String> productList){
        String productNames = '';
        if(productList.size() > 1){
                productNames = String.join(productList, ', ');
                Integer index = productNames.lastIndexOf(',');
                productNames = productNames.substring(0, index) + ' and' +  productNames.substring(index+1, productNames.length());
            } else {
                productNames = productList[0];
            }
        return productNames;
    }
}