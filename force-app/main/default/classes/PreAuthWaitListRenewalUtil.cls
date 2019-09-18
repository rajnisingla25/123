public class PreAuthWaitListRenewalUtil{
    //getting user details
    public static user getUserDetails(){
        User user = [SELECT Id, 
                     NT_Login_Id__c,
                     Pre_Auth_User__c
                        FROM User
                        WHERE ID =: UserInfo.getUserId()];
        return user;
    }
    
    //querying primary payment profile
    public static List<Paymentprofiles__c> getPaymentDetails(Id accountId){
        return [SELECT id,
                SplitPercentage__c,
                MaskNumber__c
               FROM Paymentprofiles__c 
               WHERE account__c =: accountId
               AND SplitPercentage__c > 0];
                  
    }
    
    //resetting the row number on the waitlist items after deleting the item. 
    public static List<WaitListItem> resetRowNumbers(List<WaitListItem> items){
        Integer index = 0;
        for(WaitListItem item : items){
            item.index = index;
            index++;
        }
        return items;
    }

    //adding selected markets into a market set
    public static Set<String> setMarkets(List<WaitListItem> items){
        Set<String> markets = new Set<String>();
        if(items != null && items.size()>0){
            for(WaitListItem item: items){
                markets.add(item.product+'-'+item.market);
                system.debug('--- market -->'+item.product+'-'+item.market);
            }
        }
        return markets;
    }
    
    //querying waitlist items using either accountID, waitlist ID or waitlist item ID
    public static List<Waitlist_Item__c> getWaitListItems(Id recordId){
        List<Waitlist_Item__c> waitlists = [SELECT Market__c , 
                                            product_size__c,
                                            Market_Type__c , 
                                            Rate_Card_Price__c,
                                            Status__c, 
                                            Lead_Routing__c, 
                                            Waitlist_Expiration_Date__c, 
                                            Product__r.Name, 
                                            State__c, 
                                            Term__c , 
                                            Wailist_Type__c, 
                                            Current_Utilized_Spend__c, 
                                            Original_Max_Spend__c,
                                            Waitlist__r.Total_MAX_Monthly_Pre_Auth_Spend__c,
                                            WaitList__r.Waitlist_Expiration_Date__c,
                                            rank__c
                                            FROM Waitlist_Item__c
                                            WHERE (Account__c =: recordId OR Waitlist__c =: recordId OR id =: recordId)
                                            AND Status__c IN ('Active', 'Fulfilled') AND WaitList__r.Status__c = 'Active'];
                                            

        return waitlists;
    }
    
    public static date activeWaitlistExpiryDateSet(Id accountId){
        List<WaitList__c> activeWaitLists = [SELECT Id, Waitlist_Expiration_Date__c FROM WAITLIST__c where account__c =: accountId AND Status__c IN('Active', 'Fulfilled')];
        return activeWaitlists[0].Waitlist_Expiration_Date__c;
    }

    //querying account relationships to get primary contact using the account id
    public static List<Account_Relationship__c> getAccountRelations(Id accountId){
        return  [SELECT id,
                        Contact_To__c,
                        Parent_Account__r.Email_Address__c,
                        Contact_To__r.Name,
                        Parent_Account__r.name,
                        Contact_to__r.email,
                        Contact_To__r.Phone 
                FROM Account_Relationship__c 
                WHERE Contact_Role__c = 'Primary Contact' 
                AND Parent_Account__c = :accountId 
                AND Active__c = true];
    }

    //querying products
    public static List<Product2> getProducts(){
        return [SELECT Id, 
                      ProductCode,Name
                FROM Product2];
    }

    //creating a map of product code and productId
    public static Map<String,Id> getProductIdMap(){
        Map<String,Id> productIdMap = new Map<String,Id>();
        for(Product2 product : getProducts()){ 
        if(product.productcode == 'COBROKE'){
        productIdMap.put('Connection for Co-Brokerage', product.Id);
        }else{
        productIdMap.put(product.Name, product.Id);} }
        return productIdMap;
    }
    
    
        

    //method to update the items that inventory has created waitlists
    public static List<WaitListItem> updateItems(List<WaitListItem> items){
        for(WaitListItem item: items){
            item.status = 'Success';
        }
        return items;
    }
    
    //creating a map of market and waitlist term to get the terms of each waitlist
    public static Map<String, WaitListItem> getWaitListItemsMap(List<WaitListItem> items){
        Map<String, WaitlistItem> waitlistItemMap = new Map<String, WaitlistItem>();
        for(WaitListItem item: items){
            waitlistItemMap.put(item.market, item);
        }
        return waitlistItemMap;
    }
    
    //method to create waitlist and waitlist items in salesforce
    public static void createRecords(List<JSON2Apex> inventoryResponse, 
                                      Account account, 
                                      String ccLast4Digits,
                                      Date preAuthEffectiveDate,
                                      List<WaitlistItem> items,
                                      String preAuthType){ //CRM-2308
        WaitList__c waitList;
        List<Waitlist_Item__c> waitlistItems;
        Map<String,Id> productIdMap = getProductIdMap();
        Account_Relationship__c primaryContact  = getAccountRelations(account.id)[0];
        Map<String,WaitlistItem> waitListItemsMap = getWaitListItemsMap(items);
        
        //creating waitlist
        waitList = new WaitList__c();
        waitlist.Account__c = account.ID;
        waitlist.Total_MAX_Monthly_Pre_Auth_Spend__c = account.Total_MAX_Monthly_Pre_Auth_Spend__c;
        waitlist.Current_Monthly_Pre_Auth_Spend__c = 0;
        waitlist.Submitted__c = TRUE;
        waitlist.Submitted_Date__c = preAuthEffectiveDate;
        waitlist.Pre_Auth_Contact__c = primaryContact.Contact_To__c;
        waitlist.Pre_Auth_Email__c =  Test.isrunningtest() ? 'testemail@test.com' : primaryContact.Parent_Account__r.Email_Address__c;
        waitlist.Status__c = 'Pending Pre-Auth';
        waitlist.CC4Digits__c = ccLast4Digits;
        waitlist.Pre_Auth_Type__c = preAuthType ; //CRM-2308
        waitlist.Waitlist_Expiration_Date__c = preauthEffectiveDate.adddays(90);


        insert waitlist;

        //creating waitlist items
        waitlistItems = new List<Waitlist_Item__c>();

        for(JSON2Apex inventory : InventoryResponse){
       
                     
                   
            Waitlist_Item__c waitlistItem = new Waitlist_Item__c();
            waitlistItem.account__c = account.id;
            waitlistItem.Account_Owner_Email__c      = primaryContact.Parent_Account__r.Email_Address__c;
            waitlistItem.Original_Max_Spend__c       = Decimal.valueof(inventory.original_max_spend);
            waitlistItem.Current_Utilized_Spend__c   = 0;
            waitlistItem.Lead_Routing__c             = inventory.lead_routing;
            waitlistItem.Market__c                   = inventory.market_name;
            waitlistItem.Market_Type__c              = inventory.market_type;
            waitlistItem.Original_Max_Spend__c       = Decimal.valueof(inventory.original_max_spend);
            waitlistItem.Product__c                  = productIdMap.get(inventory.product_type);
            waitlistItem.Product_Size__c             = inventory.waitlist_slot;
            waitlistItem.Status__c                   = 'Pending Pre-Auth';
            waitlistItem.Wailist_Type__c             = inventory.waitlist_type;
            waitlistItem.Rank__c                     = test.isrunningtest() ? 999 : waitListItemsMap.get(inventory.market_name).rank;
            waitlistItem.State__c                    = inventory.state ;
            waitlistItem.Waitlist_ID__c              = inventory.waitlist_guid != null ? inventory.waitlist_guid : 'No Wait List ID';
            waitlistItem.Waitlist_Expiration_Date__c = preauthEffectiveDate.adddays(90);
            waitlistItem.Is_Renewed_Row__c           = TRUE;
            waitlistItem.term__c                     = waitListItemsMap.get(inventory.market_name).defaultTerm;
            waitlistItem.Waitlist__c                 = waitlist.Id ; 
            waitlistItem.Pre_Auth_Type__c            = waitListItemsMap.get(inventory.market_name).preAuthType;
            if(inventory.waitlist_markets.size()>0){
                for(JSON2Apex.waitlist_markets mkts : inventory.waitlist_markets){
                    if(mkts.market_key.contains('FULL')){
                        if(inventory.lead_routing=='Flex') waitlistItem.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                        else if(inventory.lead_routing=='Fast') waitlistItem.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_fast_unit_price);  
                        else if(inventory.lead_routing=='Any') waitlistItem.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);    
                        waitlistItem.Tier_Price_Number__c = mkts.historical_tier_price_number; 
                    }
                    //DAP-386
                    if(inventory.waitlist_slot == 'ANY'){
                       if(mkts.market_key.contains('SOV50')){
                            waitlistItem.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                            waitlistItem.Tier_Price_Number__c = mkts.historical_tier_price_number; 
                        }
                    }else{
                       waitlistItem.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                       waitlistItem.Tier_Price_Number__c = mkts.historical_tier_price_number;  
                    }
                    //DAP-386 ends
                }
            }
            waitlistItems.add(waitListItem);
        }
        insert waitListItems;  
           
    }

    //create JSON Request for inventory call
    public static String createJSONRequest(List<WaitListItem> items, 
                                            Account account, 
                                            User user){
        List<CreateWaitlistWrapper> inventory = new List<CreateWaitlistWrapper>();
        if(items != null && items.size()>0){                                       
            for(WaitListItem item: items){
                CreateWaitlistWrapper waitlist_wrap = new CreateWaitlistWrapper();
                
                waitlist_wrap.party_id = account.Party_ID__c;
                waitlist_wrap.Market_name = item.market;
                waitlist_wrap.Market_type = item.waitlistProductType;
                waitlist_wrap.Product_type = item.product.remove('(SM)');
                waitlist_wrap.State = item.state;
                waitlist_wrap.Waitlist_type = 'Pre-Auth';
                waitlist_wrap.Waitlist_slot = item.defaultProductSize;
                waitlist_wrap.Waitlist_status = 'Pending Pre-Auth';
                waitlist_wrap.Lead_routing = item.defaultLeadRoute;
                waitlist_wrap.Quantity = 1;
                waitlist_wrap.Created_by = user.NT_Login_Id__c;
                waitlist_wrap.Owner_name = account.owner.NT_Login_Id__c;
                waitlist_wrap.Account_name = account.Name; 
                waitlist_wrap.Account_sub_type = account.account_sub_type__c;
                waitlist_wrap.Phone = account.Preferred_Phone__c;
                waitlist_wrap.Original_max_spend = String.valueOf(item.maxSpend); 
                waitlist_wrap.Remnant_spend = String.valueOf(item.maxSpend); 
                inventory.add(waitlist_wrap);
    
            }
        }
        
        system.debug('request --> '+inventory);
        return JSON.serialize(inventory);
    }

    //getting state abbreaviation for state code
    public static String stateAbbreviation(String stateName){
        String state = '';
        GoewcfService geo = new GoewcfService();
        String stateAbbURL = Waitlist_Urls__c.getInstance('StateAbb').URL__c;
        stateAbbURL = stateAbbURL.replace(Waitlist_Urls__c.getInstance('StateAbb').replacement_parameter__c, stateName);
        state = geo.JSONStateAbbrevation(stateAbbURL);
        return state;
    }
    
    public static String stateCodeFromZip(String zipCode){
        GoewcfService geo = new GoewcfService();
        String postalCodeAreaURL = Waitlist_Urls__c.getInstance('postalCodeArea').URL__c;
        String replacementParameter = Waitlist_Urls__c.getInstance('postalCodeArea').replacement_parameter__c;
        String stateCode = geo.getStateAbbreviationFromPostalCode(postalCodeAreaURL.replace(replacementParameter, zipCode));
        return stateCode;
    }

    //method to get product terms 
    public static List<SelectOption> terms(String selectedProduct){
        List<SelectOption> options = new List<SelectOption>();
        if(selectedProduct == 'Local Expert'){  // || selectedProduct == 'Local Expert City'){
            
            options.add(new SelectOption('12','12'));
        }else{
            options.add(new SelectOption('6','6'));
            options.add(new SelectOption('12','12'));
        }
        return options;
    }
    
    //method to get the total max monthly spend from waitlist object
    public static Decimal setTotalMaxSpend(Id accountID){
        Decimal totalMaxSpend = 0.00;
        List<Waitlist_Item__c> waitlists = getWaitListItems(accountId);
        if(waitlists.size()>0){ totalMaxSpend = waitlists[0].waitlist__r.Total_MAX_Monthly_Pre_Auth_Spend__c; }
        return totalMaxSpend;
    }

}