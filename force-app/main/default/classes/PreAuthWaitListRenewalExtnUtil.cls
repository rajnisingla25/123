public class PreAuthWaitListRenewalExtnUtil{
    
   
    //setter functionality for list of wait list product types
    public static List<SelectOption> waitlistProductTypes(){
        List<SelectOption> waitlistProductTypes = new List<SelectOption>();
        waitlistProductTypes.add(new SelectOption('City', 'City'));
        waitlistProductTypes.add(new SelectOption('County', 'County'));
        waitlistProductTypes.add(new SelectOption('Postal Code', 'Postal Code'));
        return waitlistProductTypes;
    }
    
    //setter functionality for list of renewal products
    public static List<SelectOption> renewalproducts(){
        String account360Products = Label.Account360Products;
        List<SelectOption> renewalproducts = new List<SelectOption>();
        renewalproducts.add(new SelectOption('Connection for Co-Brokerage', 'Connection for Co-Brokerage'));
        if(account360Products.contains('localexpert')){
            renewalproducts.add(new SelectOption('Local Expert', 'Local Expert Zip'));
        }
        renewalproducts.add(new SelectOption('Local Expert City', 'Local Expert City'));
        return renewalproducts;
    }
    
    //CRM-2308
    public static List<SelectOption> preAuthTypes(){
        List<SelectOption> preAuthTypes = new List<SelectOption>();
        preAuthTypes.add(new SelectOption('Renew', 'Renew'));
        preAuthTypes.add(new SelectOption('Amend', 'Amend'));
        return preAuthTypes;
    }
    //setter functionality for list of lead routes
    public static List<SelectOption> leadRoutes(){
        List<SelectOption> leadRoutes = new List<SelectOption>();
        leadRoutes.add(new SelectOption('Fast', 'Fast'));
        leadRoutes.add(new SelectOption('Flex', 'Flex'));
        leadRoutes.add(new SelectOption('Any', 'Any'));
        return leadRoutes;
    }
    
    //setter functionality for list of lead routes for local expert
    public static List<SelectOption> leadRoutesLE(){
        List<SelectOption> leadRoutes = new List<SelectOption>();
        
        leadRoutes.add(new SelectOption('Flex', 'Flex'));
        return leadRoutes;
    }
    
    //setter functionality for list of product size options
    public static List<SelectOption> productsizes(){
        List<SelectOption> sizes = new List<SelectOption>();
        sizes.add(new SelectOption('Half', 'Half'));
        sizes.add(new SelectOption('Full', 'Full'));
        sizes.add(new SelectOption('Any', 'Any'));
        return sizes;
    }
    //setter functionality for list of product size options for local expert
    public static List<SelectOption> productsizesLE(){
        List<SelectOption> sizes = new List<SelectOption>();
        sizes.add(new SelectOption('SOV50', 'SOV50'));
        sizes.add(new SelectOption('SOV30', 'SOV30'));
        sizes.add(new SelectOption('SOV20', 'SOV20'));
        sizes.add(new SelectOption('Any', 'Any'));
        return sizes;
    }
    
    //setter functionality for list of product size options for local expert city
    public static List<SelectOption> productsizesLEC(){
        List<SelectOption> sizes = new List<SelectOption>();
        sizes.add(new SelectOption('SOV10', 'SOV10'));
       
        return sizes;
    }
    //setter functionality for list of states
    public static List<SelectOption> states(){
        List<SelectOption> states = new List<SelectOption>();
        GoewcfService geo = new GoewcfService();
        String stateURL = Waitlist_Urls__c.getInstance('stateURL').URL__c;
        if(!Test.isRunningTest()){
            states.addAll(geo.JSONtoOptions(stateURL));
        }else{
            states.add(new SelectOption('MO','MO'));
            states.add(new SelectOption('CA','CA'));
        }
        states.sort();
        return states;
    }
   
    //setter functionality for list of counties
    public static List<SelectOption> counties(String state){
        List<SelectOption> counties = new List<SelectOption>();
        GoewcfService geo = new GoewcfService();
        String countyURL = Waitlist_Urls__c.getInstance('countyURL').URL__c;
        countyURL = countyURL.replace(Waitlist_Urls__c.getInstance('countyURL').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(state));
        if(!Test.isRunningTest()){
            counties.addAll(geo.JSONtoOptions(countyURL));
        }else{
            counties.add(new selectoption('Atlantic','Atlantic'));
        }
        counties.sort();
        return counties;
    }
    
    //setter functionality for selected counties
    public static List<String> selectedCounties(List<SelectOption> counties){
        List<String> selectedCounties = new List<String>();
        if(counties != null && counties.size()>0) selectedCounties.add(counties.get(0).getValue());
        return selectedCounties;
    }
    

    //setter functionality for list of cities
    public static List<SelectOption> cities(String state, 
                                            List<String> selectedCounties){
        List<SelectOption> cities = new List<SelectOption>();
        GoewcfService geo = new GoewcfService();
        String cityURL = Waitlist_Urls__c.getInstance('cityURL').URL__c;
        if(!Test.isRunningTest()){ 
           // citySet.clear();                                 
            for(String county: selectedCounties){ 
                String replacedURL = cityURL.replace(Waitlist_Urls__c.getInstance('cityURL').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(state)+'/'+county);
                cities.addAll(geo.JSONtoOptions(replacedURL));
                
            }
        }else{
            cities.add(new selectoption('San Jose', 'San Jose'));
            for(Integer i = 0; i<3500; i++){
                cities.add(new selectOption('Test City '+i,'Test City '+i));
            }

        }
        cities.sort();
        return cities;
    }
    
    //setter functionality for list of cities
    public static Set<String> citiesSet(String state, 
                                            List<String> selectedCounties){
         Set<string> cities = new Set<String>();
        GoewcfService geo = new GoewcfService();
        String cityURL = Waitlist_Urls__c.getInstance('cityURL').URL__c;
        if(!Test.isRunningTest()){ 
           // citySet.clear();                                 
            for(String county: selectedCounties){ 
                String replacedURL = cityURL.replace(Waitlist_Urls__c.getInstance('cityURL').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(state)+'/'+county);
                cities.addAll(geo.JSONtoSet(replacedURL));
                
            }
        }else{
            cities.add('San Jose');
            for(Integer i = 0; i<3500; i++){
                cities.add('Test City '+i);
            }

        }
        return cities;
    }

    //setter functionality for selected cities
    public static List<String> selectedCities(List<SelectOption> cities){
        system.debug(cities.size());
        List<String> selectedCities = new List<String>();
        if(cities != null && cities.size()>0) selectedCities.add(cities.get(0).getValue());
        return selectedCities;
    }
      
      
    //setter functionality for list of postal codes using state and selected cities
    public static List<SelectOption> postalCodes(String state, 
                                                  List<String> selectedCities){
        List<SelectOption> postalCodes = new List<SelectOption>();
        GoewcfService geo = new GoewcfService();
        String postalCodeURL = Waitlist_Urls__c.getInstance('zipsIntersectsCity').URL__c;
        if(!Test.isRunningTest()){                                              
            for(String city: selectedCities){
                String replacedURL = postalCodeURL.replace(Waitlist_Urls__c.getInstance('zipsIntersectsCity').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(state)+'/'+city);
                postalCodes.addAll(geo.JSONtoOptions(replacedURL));
            }
        }else{
            for(Integer i = 0; i<3500; i++){
                postalCodes.add(new selectOption('9513'+i,'9513'+i));
            }        
        }
                                                      
        postalCodes.sort();
        return postalCodes; 
    }
    
/*
    //setter functionality for list of postal codes using only state
    public static List<SelectOption> postalCodes(String state){        
        List<SelectOption> postalCodes = new List<SelectOption>();
        GoewcfService geo = new GoewcfService();
        String postalCodeURL = Waitlist_Urls__c.getInstance('postalCodes').URL__c;
        if(!Test.isRunningTest()){
            postalCodeURL = postalCodeURL.replace(Waitlist_Urls__c.getInstance('postalCodes').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(state));
            postalCodes.addAll(geo.JSONtoOptions(postalCodeURL));    
        }else{
            for(Integer i = 0; i<3500; i++){
                postalCodes.add(new selectOption('9513'+i,'9513'+i));
            }  
        }
        postalCodes.sort();
        return postalCodes;
    }
*/
    //setter functionality for selected postal codes
    public static List<String> selectedPostalCodes(List<Selectoption> postalCodes){
        List<String> selectedPostalCodes = new List<String>();
        return selectedPostalCodes;
    }

    //setter functionality for waitlistItems //CRM-2308 adding pre-AuthType 
    public static List<WaitListItem> waitListItems(Id accountId, String preAuthType){
        System.Debug('--- PreAuthType --> '+preAuthType);
        List<WaitListItem> items = new List<WaitListItem>();
        List<SelectOption> leadOptions = leadRoutes();
        List<SelectOption> productsizeOptions = productSizes();
        List<SelectOption> itemTerms = new List<SelectOption>();
        String productName = '';
        Integer index = 0;
        for(Waitlist_Item__c waitListItem : PreAuthWaitListRenewalUtil.getWaitListItems(accountId)){ 
            Decimal rank = waitlistItem.status__c == 'Active' ? waitlistItem.rank__c : 9999; //CRM-3814
            if(waitListItem.Product__r.Name == 'LOCAL EXPERT' || waitlistitem.product__r.name == 'LOCAL EXPERT CITY'){
                leadOptions = leadRoutesLE();
                productsizeOptions = waitlistitem.product__r.name == 'LOCAL EXPERT CITY' ? productsizesLEC() : productsizesLE();
                itemTerms= PreAuthWaitListRenewalUtil.terms(waitListItem.Product__r.Name);
            }else{
                leadOptions = leadRoutes();
                productsizeOptions = productsizes();
                itemTerms=PreAuthWaitListRenewalUtil.terms(waitListItem.Product__r.Name);
            }
           
            if(waitListItem.Product__r.Name.contains('Connection')){
               productName = waitListItem.Product__r.Name.remove('(SM)');
            }else{
               productName = waitListItem.Product__r.Name;
            }
            
            WaitListItem item = new WaitListItem(index,
                                                 productName, 
                                                 waitListItem.Market_Type__c,
                                                 waitListItem.Market__c,
                                                 waitListItem.State__c,
                                                 waitListItem.Wailist_Type__c,
                                                 leadOptions,
                                                 productsizeOptions,
                                                 waitListItem.Lead_Routing__c,
                                                 waitListItem.product_size__c,
                                                 waitListItem.Status__c,
                                                 waitListItem.Waitlist_Expiration_Date__c,
                                                 itemTerms,
                                                 waitListItem.term__c,
                                                 waitListItem.Original_Max_Spend__c,
                                                 '',
                                                 waitListItem.Current_Utilized_Spend__c,
                                                 false,
                                                 waitListItem.Rate_Card_Price__c,
                                                 rank,
                                                 preAuthType);
            item.parentId = waitListItem.id; //CRM-1587
            items.add(item);
            index++;
        }
        return items;
    }
    
    //ADD TO LIST button coding
    public static List<WaitListItem> addMoreItems(String selectedProduct, 
                                                  List<WaitListItem> items, 
                                                  List<String> selectedPostalCodes, 
                                                  String waitlistProductType, 
                                                  String state, 
                                                  String leadRoute,
                                                  String productsize, 
                                                  Set<String> marketSet, 
                                                  String markets,
                                                  Set<String> allcities){
        system.debug('inside the add more items -->');                                          
        List<SelectOption> leadOptions = new List<SelectOption>();
        List<SelectOption> productsizeOptions = new List<SelectOption>();
        if(selectedproduct == 'LOCAL EXPERT' || selectedproduct == 'LOCAL EXPERT CITY'){
        system.debug('inside the local expert or city part');
                leadOptions = leadRoutesLE();
                productsizeOptions = selectedproduct == 'LOCAL EXPERT CITY' ? productsizesLEC() : productsizesLE();
        }else{
        system.debug('inside the else part');
                leadOptions = leadRoutes();
                productsizeOptions = productsizes();
                productsize = 'Any';
        }
        
        List<SelectOption> itemTerms = PreAuthWaitListRenewalUtil.terms(selectedproduct);
        Integer index = (items == null || items.size() == null) ? 0 : items.size();
        for(String market: selectedpostalCodes){
            if(selectedproduct == 'LOCAL EXPERT CITY'){
                market = market+', '+PreAuthWaitListRenewalUtil.stateAbbreviation(state);
            }
            system.debug('inside the selected postal codes part -->');
            system.debug('---- market -->'+market);
            system.debug('--- marketset -->'+marketset);
            system.debug('--- key-->'+selectedproduct+'-'+market);
            if(marketSet != null && !marketSet.contains(selectedproduct+'-'+market)){
                    system.debug('inside marketset -->');
                    WaitListItem item = new WaitListItem(index,
                                                selectedproduct, 
                                                 waitlistProductType,
                                                 market,
                                                 PreAuthWaitListRenewalUtil.stateAbbreviation(state),
                                                 'Pre-Auth',
                                                 leadOptions,
                                                 productsizeOptions,
                                                 leadRoute,
                                                 productsize,
                                                 'New',
                                                 null,
                                                 itemTerms,
                                                 '12',
                                                 0,
                                                 '',
                                                 null,
                                                 true,
                                                 null,
                                                 null,
                                                 'New');
            items.add(item);
            index++;
            
            // CRM-2882 - Add above added market to set to avoid adding it again
            marketSet.add(selectedproduct+'-'+market);
           // system.debug('--- market -->'+selectedproduct+'-'+market);
            }
        }
        if(markets != null && markets != ''){
         system.debug('inside markets --> ');
            for(String market: markets.split(',')){
                market = market.trim();
                if(selectedproduct == 'Local Expert City'){
                    List<String> marketNameSplit = market.split(' ');
                    market = '';
                    for(String eachName : marketNameSplit){
                        market += eachName.substring(0,1).toUpperCase()+eachName.substring(1,eachName.length()).tolowercase() + ' ';
                    }
                    market= market.trim();
                    if(!allcities.contains(market)){
                       system.debug('--- inside the loop --> ');
                       PreAuthWaitListRenewalExtn.errors.add(market+' is not a valid city for the selected state.');
                       break;
                    }
                    
                }
                if(marketSet != null && !marketSet.contains(selectedproduct+'-'+market)){
                        WaitListItem item = new WaitListItem(index,selectedproduct,  waitlistProductType, market, PreAuthWaitListRenewalUtil.stateCodeFromZip(market),'Pre-Auth',leadOptions,productsizeOptions,
                                                     leadRoute,
                                                     productsize,'New',null,itemTerms,'12', 0,'',null,true, null,null,
                                                     'New');
                 if(selectedproduct == 'Local Expert City'){
                     item.state = PreAuthWaitListRenewalUtil.stateAbbreviation(state);
                 
                      item.market = item.market+', '+item.state;
            
                 }                                    
                items.add(item);
                index++;
            
                }
            }
        }

        
        return items;
    }

    //CRM-1587
    public static void updateParentItems(List<WaitlistItem> items){
      List<Waitlist_Item__c> itemsToUpdate = new List<Waitlist_Item__c>();
          for(WaitlistItem item : items){
              if(item.parentId != null && item.parentId != ''){ //CRM-1957 //CRM-1951
                 Waitlist_Item__c oldItem = new Waitlist_item__c();
                 oldItem.id = item.parentId;
                 oldItem.has_Renewal__c = true;
                 itemsToUpdate.add(oldItem);
              }
          }
      
          if(itemsToUpdate.size()>0){
            update itemsToUpdate;
          }
      
    }
    

    //SUBMIT button coding
    public static List<WaitListItem> submitInventory(List<WaitListItem> items,
                                          Account account,
                                          User user,
                                          String ccLast4Digits, 
                                          Date preAuthEffectiveDate, 
                                          String preAuthType){ //CRM-2308
        system.debug('--- items --> '+items); 
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setMethod('POST');
        req.setEndpoint(Waitlist_Urls__c.getInstance('CreateWaitlist').URL__c);
        req.setBody(PreAuthWaitListRenewalUtil.createJSONRequest(items, account, user));
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        system.debug('---- >'+req);
        if(!Test.isRunningTest()){
            res = http.send(req);
        }else{
             String json = '['+'{'+
    '  \"params\": {'+
    '    \"request\": {'+
    '      \"__type\": \"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel\",'+
    '      \"party_id\": \"3098165\",'+
    '      \"market_name\": \"00043\",'+
    '      \"market_type\": \"Postal Code\",'+
    '      \"product_type\": \"Connection for Co-Brokerage\",'+
    '      \"state\": \"FL\",'+
    '      \"waitlist_type\": \"Warm\",'+
    '      \"waitlist_slot\": \"Any\",'+
    '      \"original_max_spend\": \"100\",'+
    '      \"waitlist_status\": \"Active\",'+
    '      \"lead_routing\": \"Any\",'+
    '      \"quantity\": 1,'+
    '      \"created_by\": \"vvall\",'+
    '      \"owner_name\": \"sshar\",'+
    '      \"account_sub_type\": \"Prospect\",'+
    '      \"remnant_spend\": \"0\"'+
    '    }'+
    '  },'+
    '  \"waitlist_guid\": \"f8adc76d-99ce-4c0a-aff4-120e014376db\",'+
    '  \"party_id\": \"3098165\",'+
    '  \"product_type\": \"Connection for Co-Brokerage\",'+
    '  \"market_type\": \"Postal Code\",'+
    '  \"waitlist_slot\": \"Any\",'+
    '  \"original_max_spend\": \"100\",'+
    '  \"state\": \"FL\",'+
    '  \"market_name\": \"00043\",'+
    '  \"waitlist_type\": \"Warm\",'+
    '  \"lead_routing\": \"Any\",'+
    '  \"quantity\": \"1\",'+
    '  \"owner_name\": \"sshar\",'+
    '  \"created_by\": \"vvall\",'+
    '  \"ranking\": \"0\",'+
    '  \"last_worked_date\": \"\",'+
    '  \"remnant_spend\": \"0\",'+
    '  \"pre_auth_status_date\": \"\",'+
    '  \"pre_auth_expiry_date\": \"\",'+
    '  \"presales_available_date\": \"\",'+
    '  \"inventory_available_flex\": \"0\",'+
    '  \"presales_available_flex\": \"0\",'+
    '  \"inventory_available_fast\": \"0\",'+
    '  \"presales_available_fast\": \"0\",'+
    '  \"total_available_flex\": \"0\",'+
    '  \"total_available_fast\": \"0\",'+
    '  \"account_sub_type\": \"Prospect\",'+
    '  \"waitlist_status\": \"Active\"'+
    '}'+']';
            res.setBody(json);
        }
        try{
           PreAuthWaitListRenewalUtil.createRecords(JSON2Apex.parse(res.getBody()), account, ccLast4Digits, preAuthEffectiveDate, items, preAuthType ); //CRM-2308
           if(preAuthType == 'Renew'){updateParentItems(items);}//CRM-1587 //CRM-2308 added preAuthType
           return PreAuthWaitListRenewalUtil.updateItems(items);

        }catch (CalloutException coe){
                Error__c logerror               = new Error__c();
                logerror.Name                   = '';
                logerror.Entity_Id__c           = 'Waitlist';
                logerror.Error_Description__c   = String.valueOf(res.getBody());
                logerror.Interface_Name__c      = 'Inventory';
                Insert logerror;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error received from inventory system, Please contact system admin. Error ID:' + logerror.Id));
                return items; 
        } catch (exception error){
                Error__c logerror               = new Error__c();
                logerror.Name                   = '';
                logerror.Entity_Id__c           = 'Waitlist';
                logerror.Error_Description__c   = res.getBody();
                logerror.Interface_Name__c      = 'Inventory';
                Insert logerror;
                system.debug('Error -->'+error.getcause()+error.getLineNumber());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'error received from inventory system, please contact system admin. Error ID:' + logerror.Id));
                return items; 
         }
    }   


}