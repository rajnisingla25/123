/*****************************************************************************
* Class Name: SelfServiceController
* Author: Shraddha Kabade
* Purpose: To perform various operations for community VF pages.
* JIRA : LCM-294, LCM-295
****************************************************************************/
public class SelfServiceController {
    
public string addCCPageId {set;}
public string sfdcAcctId {get;set;}
public string advertiserId {get;set;}
public boolean displayIframe {get;set;}
public string productsFilename {get;set;}
    
public SelfServiceController(){
    sfdcAcctId = '';
    advertiserId = '';
    displayIframe = false;
    productsFilename = 'customerAccountSummary';
    getloggedInUserAccount();
}

    
/**
 * Method to get user account details
 **/
    public void getloggedInUserAccount(){
        Id currentLoggedInUser = UserInfo.getUserId();
        try{
            Account a = new Account();
            if(!Test.isRunningTest()){
                User u  = [Select id, federationIdentifier
                           from User Where id = :currentLoggedInUser and Profile.name = :Label.CustomerDashboardProfile limit 1];          
                a = [Select id, Advertiserid__c from Account where Advertiserid__c = :u.federationIdentifier];
            } else {
                a = [Select id, Advertiserid__c from Account limit 1];
            }
             sfdcAcctId = a.id;
             advertiserId = a.Advertiserid__c;
             Date dtoday = date.today();
             productsFilename += '_'+advertiserId + '_'+dtoday.month()+'-'+dtoday.day()+'-'+dtoday.year();
        } catch (Exception e){
            System.debug(e);
           
        }
    }
    
/**
 * Method to get user product details
 **/
    @RemoteAction
    public static String getAllProducts(String acctId){
        Map<String, Decimal> prodTCVMap = new Map<String, Decimal>();
        Map<String, Integer> prodAssetCountMap = new Map<String, Integer>();
        Decimal comarPrice = 0;
        List<Asset> finalAssetList =  new List<Asset>();
        Set<String> uniqueProductSet = new Set<String>();
        Set<id> assetIds = new Set<id>();
        Set<String> bmsProducts = new Set<String>();//CRM-5918
        Suppress_in_Customer_Statements_Settings__c custStatementSetting = Suppress_in_Customer_Statements_Settings__c.getInstance('Customer');
        List<String> lstPromoCode = custStatementSetting.Promo_Codes__c.split(';');
        boolean hasBundlePromo = false;
        String bmsBillingPeriod = 'Monthly';
        Decimal bmsPrice = 0;
        Set<String> zipcodeSet = new Set<String>();
        Set<String> nonInvProductsSet = new Set<String>{'TOPCRM','ADVANTAGE','TOPMRKSNP','TOPWEB','FIVESTREET','TOPIDX'};
        Set<STring> hideZeroDollarProduct = new Set<String>{'FIVESTREET','TOPCRM','TOPMRKSNP'};
        Set<String> invProductsSet = new Set<String>{'COBROKE','LOCALEXPERT','LOCALEXPERTCITY'};//CRM-6097
        List<Asset> assetlist =  [select id ,name,Product_Code__c,Quantity__c,Extended_Net_Price__c, Monthly_Price__c, Market_Zip__c,Lead_Type__c,Commerce_Group__c,
                                  Product2.productcode, Product_Type__c,Contract_Term__c,Billing_Period__c,Start_Date__c,End_Date__c, Market__c,Promotion__c, License_Tier__c
                                  from Asset where AccountId =: acctId AND Asset_Type__c = 'Parent' AND Status = 'Active' AND Fulfillment_Status__c != 'Failure'
                                  and product_code__c IN :nonInvProductsSet and (Extended_Net_Price__c > 0 OR (Extended_Net_Price__c = 0 and product_code__c NOT IN :hideZeroDollarProduct)) order by Monthly_Price__c desc];
         // Get 5 active assets for inventory product for pagination
         //LCM-432: Get count and total price for all assets
        for(String invProduct: invProductsSet){
            List<AggregateResult> countCostList = getTotalCountAndCost(acctId, invProduct, false);
            system.debug('countCostList'+countCostList);
            Integer count = integer.valueof(countCostList[0].get('assetCount'));
            Decimal totalCost = (Decimal) countCostList[0].get('totalCost');
            if(count > 0){
                prodTCVMap.put(invProduct, totalCost);
                prodAssetCountMap.put(invProduct, count);
                uniqueProductSet.add(invProduct);
                assetlist.addAll(getInventoryProducts(acctId, 0, 5, invProduct,false,'priceHighToLow'));
            }
            
            // LCM-441: Fetch records for BMS assets
            countCostList = getTotalCountAndCost(acctId, invProduct, true);
            count = integer.valueof(countCostList[0].get('assetCount'));
            totalCost = (Decimal) countCostList[0].get('totalCost');
            system.debug('countCostList'+countCostList);
             if(count > 0){
                prodAssetCountMap.put(invProduct+'BMS', count);
                List<Asset> bmsAssets = getInventoryProducts(acctId, 0, 5, invProduct,true,'endDateAscending');
                assetlist.addAll(bmsAssets);
                uniqueProductSet.add(invProduct);
                bmsProducts.add(invProduct+'BMS');
                    if(prodTCVMap.containsKey('BROKERMARKETING')){
                         prodTCVMap.put('BROKERMARKETING', prodTCVMap.get('BROKERMARKETING') +  totalCost);
                    } else {
                         prodTCVMap.put('BROKERMARKETING', totalCost);
                    }
            }
        }
        system.debug('prodTCVMap'+prodTCVMap);
        
        for(Asset ast: assetlist){
            hasBundlePromo = false;
            // Hide RS bundle products
            if(ast.Promotion__c != null && ast.Promotion__c != ''){
                List<string> assetPromo = ast.Promotion__c.split('---');
                for(String promo: assetPromo){
                    if(lstPromoCode.contains(promo)){
                        hasBundlePromo = true;
                    }
                }
            }
            if(!hasBundlePromo){
                system.debug(ast);
                String prodCode = ast.Product_Code__c;
               
                if(!invProductsSet.contains(ast.Product_Code__c)){
                     //LCM-431
                    if(ast.Commerce_Group__c == 'Broker Marketing Solution'){
                        prodCode = 'BROKERMARKETING';
                        bmsProducts.add(ast.Product_Code__c);
                    }
                    if(prodTCVMap.containsKey(prodCode)){
                        Decimal total = prodTCVMap.get(prodCode);
                        prodTCVMap.put(prodCode, total+ast.Monthly_Price__c);
                    } else {
                        prodTCVMap.put(prodCode, ast.Monthly_Price__c);
                    }
                  
                }
                uniqueProductSet.add(ast.Product_Code__c);
                finalAssetList.add(ast);
                //CRM-6097
                if(invProductsSet.contains(ast.Product_Code__c)){ 
                    assetIds.add(ast.id);
                    zipcodeSet.add(ast.Market__c);
                }
            }
        }
        // LCM-441
        if(prodTCVMap.containsKey('BROKERMARKETING')){
            bmsPrice = prodTCVMap.get('BROKERMARKETING');
            if(bmsBillingPeriod == 'Annual'){
                bmsPrice = bmsPrice * 12;
            } else if(bmsBillingPeriod == 'Bi-Annual'){
                bmsPrice = bmsPrice * 6;
            } else if(bmsBillingPeriod == 'Quarterly'){
                bmsPrice = bmsPrice * 3;
            }
        }
        system.debug('prodTCVMap'+prodTCVMap);
        if(!finalAssetList.isEmpty()){
            if(!assetIds.isEmpty()){
                for(Comarketing_Relationship__c comar: [Select id,Lender_Percentage_Contribution__c,CFCB_Asset__r.Monthly_Price__c from Comarketing_Relationship__c where CFCB_Asset__c IN :assetIds and (status__c = 'Active' or (status__c = 'Pending Activation' and action__c != 'Add') or status__c = 'Pending Cancellation')]){
                  comarPrice += (comar.CFCB_Asset__r.Monthly_Price__c * comar.Lender_Percentage_Contribution__c)/100;
                }
            }
            String finalJson = '{"co-marketing-contribution":'+comarPrice+' ,"bms-price":'+bmsPrice+', "bms-billing-period":"'+bmsBillingPeriod+'" ,"sfdc-account-id":"'+acctId+'" ,"products-size":'+uniqueProductSet.size()+' , "product-count": '+JSON.serialize(prodAssetCountMap)+', "bms-product-codes": '+JSON.serialize(bmsProducts)+', "product-summary": '+JSON.serialize(prodTCVMap)+', "all-products": '+JSON.serialize(finalAssetList)+',"zipcode-set": '+JSON.serialize(zipcodeSet)+'}';
            return finalJson;
        }
        return null;
    }

/**
 * Method to get asset details for Inventory products (Cobroke, localexpert)
 * CRM-5959
 **/
    @RemoteAction
    public static List<Asset> getInventoryProducts(String acctId, Integer offset, Integer recLimit, String productCode, Boolean isBMS, String filter){
     if(acctId != null){
         String query = 'select id ,name,Product_Code__c,Quantity__c,Extended_Net_Price__c, Monthly_Price__c, Market_Zip__c,Lead_Type__c, Commerce_Group__c,Product2.productcode, Product_Type__c,Contract_Term__c,Billing_Period__c,Start_Date__c,End_Date__c, Market__c,Promotion__c from Asset where AccountId =: acctId AND Asset_Type__c = \'Parent\' AND Status = \'Active\' AND Fulfillment_Status__c != \'Failure\'and Product_Code__c = :productCode';
         if(!isBMS){
             query += ' and Commerce_Group__c != \'Broker Marketing Solution\'';
         }else {
             query += ' and Commerce_Group__c = \'Broker Marketing Solution\'';
         }
         if(filter == 'priceHighToLow'){
             query += ' order by Monthly_Price__c desc';
         } else if(filter == 'priceLowToHigh'){
             query += ' order by Monthly_Price__c asc';
         } else if(filter == 'endDateDescending'){
             query += ' order by End_Date__c desc';
         } else if(filter == 'endDateAscending'){
             query += ' order by End_Date__c asc';
         }
         query += ' limit :recLimit offset :offset';
         return Database.query(query);
     }
     return null;
    }
    
/**
 * Method to total cost for Inventory products (Cobroke, localexpert)
 **/
    @RemoteAction
    public static List<AggregateResult> getTotalCountAndCost(String acctId, String productCode, Boolean isBMS){
        system.debug('acctId--'+acctId+productCode+isBMS);
     if(acctId != null){
         if(!isBMS){
             return [select count(id) assetCount, sum(Monthly_Price__c) totalCost from Asset where AccountId =: acctId AND Asset_Type__c = 'Parent' AND Status = 'Active' AND Fulfillment_Status__c != 'Failure'
                    and Product_Code__c = :productCode and Commerce_Group__c != 'Broker Marketing Solution'];
         } else {
              return [select count(id) assetCount, sum(Monthly_Price__c) totalCost from Asset where AccountId =: acctId AND Asset_Type__c = 'Parent' AND Status = 'Active' AND Fulfillment_Status__c != 'Failure'
                    and Product_Code__c = :productCode and Commerce_Group__c = 'Broker Marketing Solution'];
         }
       
     }
     return null;
    }
    
/**
 * Method returns inventory assets to front end for Pagination.
 **/
    @RemoteAction
    public static String getInvPaginationData(String acctId, Integer offset, Integer recLimit, String productCode, Boolean isBMS, String filter){
        if(acctId != null){
            Set<String> zipSet = new Set<String>();
            List<Asset> astList =  getInventoryProducts(acctId, offset, recLimit, productCode, isBMS, filter);
            for(Asset ast: astList){
                zipSet.add(ast.Market__c);
            }
            return '{"all-products": '+JSON.serialize(astList)+', "zipcode-set": '+JSON.serialize(zipSet)+'}';
        }
        return null;
    }
/**
 * Method return YEAR/MONTH for which account has invoice items for Satements page
 **/
    @RemoteAction
    public static List<AggregateResult> getInvoiceItemMonths(String acctId){
        return [SELECT CALENDAR_YEAR(CREATED_DATE__C)Year,CALENDAR_MONTH(CREATED_DATE__C) Month FROM Invoice_Item__c WHERE Billing_Account__r.Zuora__Account__c = :acctId and ( CALENDAR_YEAR(CREATED_DATE__C)>=2018 OR (CALENDAR_YEAR(CREATED_DATE__C) = 2017 AND CALENDAR_MONTH(CREATED_DATE__C)>=8)) GROUP BY CALENDAR_YEAR(CREATED_DATE__C),CALENDAR_MONTH(CREATED_DATE__C), Billing_Account__r.Zuora__Account__c];
    }
 
    
/**
 ** Method to get credit card details 
 **/
    @RemoteAction
    public static List<paymentProfiles__c> getAllCreditCards(String acctId){
        if(acctId != null){
             return [Select id, MaskNumber__c,ExpirationDate__c,CreditCardType__c,CardholderName__c,SplitPercentage__c, Account__r.Advertiserid__c  from paymentProfiles__c where Payment_Method_Type__c = 'CreditCard' and Account__c = :acctId and SplitPercentage__c != 0];
        }
        return null;
    }

/**
 * LCM-350: Method to get credit card details based on particular id 
 **/
    @RemoteAction
    public static Z_PaymentProfileWrapper getCCDetailsById(String ppId){
        if(ppId != null){
            Z_PaymentProfileWrapper ccDetails = new Z_PaymentProfileWrapper();
            paymentProfiles__c pp = [Select id, MaskNumber__c,ExpirationDate__c,CreditCardType__c,SplitPercentage__c, Payment_Method__r.Zuora__CreditCardAddress1__c, Payment_Method__r.Zuora__CreditCardAddress2__c, Payment_Method__r.Zuora__CreditCardState__c,CardholderName__c,
                                     Payment_Method__r.Zuora__CreditCardCity__c,PaymentMethodId__c, Payment_method__c, Payment_Method__r.Zuora__CreditCardCountry__c,Payment_Method__r.Zuora__CreditCardPostalCode__c from paymentProfiles__c where id = :ppId limit 1];
            System.debug('pp--: '+pp);
            ccDetails.ppId = pp.id;
            ccDetails.pmId = pp.Payment_Method__c;
            ccDetails.zPmId = pp.PaymentMethodId__c;
            ccDetails.maskNumber = pp.MaskNumber__c;
            ccDetails.cardholderName = pp.CardholderName__c;
            ccDetails.expirationDate = pp.ExpirationDate__c;
            ccDetails.cardType = pp.CreditCardType__c;
            ccDetails.splitPercent = pp.SplitPercentage__c;
            // Get details from zuora if payment method is not present in SFDC. Mainly this is for newly added CC which doesn't create PM in SFDC
            if(pp != null && (pp.Payment_Method__r.Zuora__CreditCardAddress1__c == null || pp.Payment_Method__r.Zuora__CreditCardAddress1__c == '') && pp.PaymentMethodId__c != null){
                Zuora.ZApi zApi = new Zuora.ZApi();
                //Login to Zuora
                try {
                    Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
                } catch (Exception ex) {
                    System.debug('Error occurred trying to log in to Zuora: '+ex.getMessage());
                }
                System.debug('Logged into Zuora successfully');
                List<Zuora.ZObject> zPaymentMethods = new List<Zuora.ZObject>();
                String paymentMethodQuery = 'Select Id, Type, CreditCardPostalCode, CreditCardCity, CreditCardState, CreditCardCountry, CreditCardAddress1, CreditCardAddress2 From PaymentMethod Where Id = \''+pp.PaymentMethodId__c+'\'';      
                try {
                    // Query Payment methods
                    zPaymentMethods = zApi.zQuery(paymentMethodQuery);
                    if(!zPaymentMethods.isEmpty()){
                        System.debug('zPaymentMethods: '+zPaymentMethods);
                        Zuora.ZObject zPM = zPaymentMethods[0];
                        ccDetails.CCAddress1 = (String)zPM.getValue('CreditCardAddress1');
                        ccDetails.CCAddress2 = (String)zPM.getValue('CreditCardAddress2');
                        ccDetails.CCCity = (String)zPM.getValue('CreditCardCity');
                        ccDetails.CCZipCode = (String)zPM.getValue('CreditCardPostalCode');
                        ccDetails.CCState = (String)zPM.getValue('CreditCardState');
                    }
                } catch (Exception ex) {
                    System.debug('Error occurred retrieving payment methods from Zuora: '+ex.getMessage());
                }
            } else {
                ccDetails.CCAddress1 = pp.Payment_Method__r.Zuora__CreditCardAddress1__c;
                ccDetails.CCAddress2 = pp.Payment_Method__r.Zuora__CreditCardAddress2__c;
                ccDetails.CCCity = pp.Payment_Method__r.Zuora__CreditCardCity__c;
                ccDetails.CCZipCode = pp.Payment_Method__r.Zuora__CreditCardPostalCode__c;
                ccDetails.CCState = pp.Payment_Method__r.Zuora__CreditCardState__c;
            }   
            return ccDetails;
        }
        return null;
    }


/**
 * LCM-429: Method render add CC iframe
 **/
public void updateCCIframeDisplay(){
    displayIframe = true;
}

/**
 * LCM-350 Method to update CC details in SFDC AND ZUORA
 **/
    @RemoteAction
    public static boolean updateCCDetails(String ppId, String pmId, String zPmId, String expirationDate, String cardholderName, String zipCode, String city, String state, String country, String address1, String address2){
        PaymentProfiles__c pp = new PaymentProfiles__c();
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        
        if(ppId != null){
            pp.id = ppId;
            if(pmId != null && pmId != '')
                pm.id = pmId;
            Zuora.zObject zpm = new Zuora.zObject('PaymentMethod');
            zpm.setValue('Id',zPmId);
            if (String.isNotBlank(expirationDate)) {
                pp.ExpirationDate__c = expirationDate;
                String[] expirationSplit;
                expirationSplit = expirationDate.split('/');
                if(expirationSplit.size() == 2){
                    if(expirationSplit[0].length() == 1)
                        zpm.setValue('CreditCardExpirationMonth','0'+expirationSplit[0]);
                    else
                        zpm.setValue('CreditCardExpirationMonth',expirationSplit[0]);
                    zpm.setValue('CreditCardExpirationYear',expirationSplit[1]);
                    pm.Zuora__CreditCardExpirationMonth__c = expirationSplit[0];
                    pm.Zuora__CreditCardExpirationYear__c = expirationSplit[1];
                }
            }
            if(String.isNotBlank(cardholderName)){
                pp.CardholderName__c = cardholderName;
                zpm.setValue('CreditCardHolderName',pp.CardholderName__c);
                pm.Zuora__CreditCardHolderName__c = cardholderName;
            }
            
            if (String.isNotBlank(zipCode)) {
                pm.Zuora__CreditCardPostalCode__c = zipCode;
                zpm.setValue('CreditCardPostalCode',zipCode);
            }
            if(String.isNotBlank(city)){
                pm.Zuora__CreditCardCity__c = city;
                zpm.setValue('CreditCardCity',city);
            }
            if(String.isNotBlank(state)){
                pm.Zuora__CreditCardState__c = state;
                zpm.setValue('CreditCardState',state);
            }
            if(String.isNotBlank(country)){
                pm.Zuora__CreditCardCountry__c = country;
                zpm.setValue('CreditCardCountry',country);
            }
            if(String.isNotBlank(address1)){
                pm.Zuora__CreditCardAddress1__c = address1;
                zpm.setValue('CreditCardAddress1',address1);
            }
            if(String.isNotBlank(address2)){
                pm.Zuora__CreditCardAddress2__c = address2;
                zpm.setValue('CreditCardAddress2',address2);
            }
            
            system.debug('payment profile---'+pp);
            system.debug('payment method---'+pm);
            system.debug('payment method---'+zpm);
            
            List<Zuora.zObject> objs = new List<Zuora.zObject> {zpm};
                Zuora.ZApi zApi = new Zuora.ZApi();
            //Login to Zuora
            try {
                Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
            } catch (Exception ex) {
                System.debug('Error occurred trying to log in to Zuora: '+ex.getMessage());
                return false;
            }
            System.debug('Logged into Zuora successfully');
            
            //Update() Payment Method in zuora
            List<Zuora.ZApi.SaveResult> updateResults = new List<Zuora.ZApi.SaveResult>();
            try {
                if(!Test.isRunningTest()){
                    updateResults = zApi.zUpdate(objs);
                    System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                    System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                    
                }
            } catch (Exception ex) {
                System.debug('Error occurred trying to update payment method in Zuora: '+ex.getMessage());
                return false;
            }
            
            Boolean updatePaymentMethodInZuora = false;
            if (updateResults.size() > 0) {
                Zuora.ZApi.SaveResult updateResult = updateResults[0];
                if(updateResult.Success != null && updateResult.Success==true){
                    updatePaymentMethodInZuora = true;
                }
                else{
                    String updateError = (updateResult.Errors != null && updateResult.Errors.size() > 0 && String.isNotBlank((String)updateResult.Errors[0].getValue('Message'))) ? (String)updateResult.Errors[0].getValue('Message') : '';
                    return false;
                }
            } else {
                System.debug('Error occurred trying to update payment method in Zuora. SaveResult list is empty');
                return false;
            }
            
            if(updatePaymentMethodInZuora==true && !Test.isRunningTest()){
                //Update Payment Profile and Paymnet method in SFDC
                update pp;
                if(pm.id != null)
                    update pm;
            }
        }
        return true;
    }
    
    
/**
 * LCM-391, LCM-428: Method to get city and state based on zipcode using GEO API
 **/
 @RemoteAction
    public static map<String, String> getGeoParserData(List<String> marketSet){
        Map<String, String> marketCityMap = new Map<String, String>();
        for(String m : marketSet){
            // This API takes only 1 market as input so multiple calls (5 calls by default) are needed.
            try{
                Waitlist_Urls__c wlu = Waitlist_Urls__c.getInstance('SelfServiceGEOApi');
                HttpRequest req = new HttpRequest(); 
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                string endPointUrl = wlu.URL__c + '?client_id=sfdc&input='+m;
                req.setMethod('GET');
                req.setEndpoint(endPointUrl);
                req.setHeader('Accept', 'application/json');
                res = http.send(req);
                system.debug('Response --->>'+res.getBody());
                if(res.getStatusCode() == 200){
                    JSONParser parser = JSON.createParser(res.getBody());
                    String state = '';
                    String city = '';
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            system.debug(parser.getText());
                            if(parser.getText() == 'state_code'){
                                parser.nextToken();
                                state = parser.getText();
                            }
                            if(parser.getText() == 'city'){
                                parser.nextToken();
                                city = parser.getText();
                            }
                        }
                    }
                    String cityState = '';
                    if(!String.isBlank(city)){cityState += city;}
                    if(!String.isBlank(state)){cityState += ', '+state;}
                    marketCityMap.put(m,cityState);
                }

            } catch(Exception e){
                system.debug(e);
            }
        }
        return marketCityMap;
    }
 
    
/**
 * Method to get logged in user profile details from Profile API
 **/
    @RemoteAction
    public static String getProfileDetails(String advId){
        if(!String.isBlank(advId)){
             try{
                Waitlist_Urls__c wlu = Waitlist_Urls__c.getInstance('SelfServiceProfileApi');
                HttpRequest req = new HttpRequest(); 
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                string endPointUrl = wlu.URL__c + '?client_id=1&fulfillment_ids='+advId+'&days_back_mls_hist=730';
                req.setMethod('GET');
                req.setEndpoint(endPointUrl);
                req.setHeader('Accept', 'application/json');
                res = http.send(req);
                system.debug('Response --->>'+res.getBody());
                if(res.getStatusCode() == 200){
                    return res.getBody();
                }
                return null;
            } catch(Exception e){
                system.debug(e);
            }
        }
         return null;
    }
    
    /**
 * LCM-403, LCM-376: Method to get logged in user profile details from Profile API
 **/
    @RemoteAction
    public static String verifyPassword(String advId, String password){
        try{
            Waitlist_Urls__c wlu = Waitlist_Urls__c.getInstance('SelfServiceVerifypasswordApi');
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            string endPointUrl = wlu.URL__c + 'fulfillment_id='+advId+'&Password='+password;
            req.setMethod('GET');
            req.setEndpoint(endPointUrl);
            req.setHeader('Accept', 'application/json');
            res = http.send(req);
            system.debug('Response --->>'+res);
            if(res.getStatusCode() != 404){
                return res.getBody();
            }
            return null;
        } catch(Exception e){
            return null;
        }
    }
       
/**
 * Method to get page ID for ADD CC Iframe
 **/
    public String getAddCCPageId() {
        // Query for settings
        List < zqu__HostedPageLiteSetting__c > settingList = [SELECT zqu__PageId__c, zqu__PaymentMethodType__c, zqu__ComponentName__c FROM zqu__HostedPageLiteSetting__c WHERE zqu__ComponentName__c = 'SelfService'];
        if(settingList != null && !settingList.isEmpty()) {
            System.debug('Retrieved settings: '+settingList);
            for (zqu__HostedPageLiteSetting__c pageSetting : settingList) {
                if (pageSetting.zqu__PaymentMethodType__c.equalsIgnoreCase('Credit Card')) {
                    system.debug('pageSetting.zqu__PageId__c'+pageSetting.zqu__PageId__c);
                    return pageSetting.zqu__PageId__c;
                }
            }
        }
        return null;
    }
    
    public class Z_PaymentProfileWrapper {
        public String ppId {get;set;}
        public String pmId {get;set;}
        public String zPmId {get;set;}
        public Decimal splitPercent {get;set;}
        public String cardType {get;set;}
        public String maskNumber {get;set;}
        public String expirationDate {get;set;}
        public String cardHolderName {get;set;}
        public String CCAddress1 {get;set;}
        public String CCCity {get;set;}
        public String CCState {get;set;}
        public String CCCountry {get;set;}
        public String CCAddress2 {get;set;}
        public String CCZipCode{get;set;}
    }

}