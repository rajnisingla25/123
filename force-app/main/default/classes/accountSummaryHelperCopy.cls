global class accountSummaryHelperCopy {
    public Boolean isOpcityBlaTeamUser {get; set;}        // CRM-6063
    public Integer blaIframeHeight {get; set;}            // CRM-6063
    private final Account acct;
    private Account accountObj;        //CRM-5867                                            
    public List<String> protectedMarkets{get; set;}            // CRM-5389
    public DateTime localTime{get;set;}
    public TimeZone tz{get;set;}
    public String requestLabel;
    public boolean loadDeatils{get;set;}
    public String QQUrl{get;set;} 
    private string endPointUrl;
    Public String acctabactive{get;set;}
    Public String qqtabactive{get;set;}
    Public String transactionId{get;set;}
    public transient string codesString{get;set;}
    public string zipcodes_cpq{get;set;}
    public transient String marketInfoStringJSON{get;set;}
    public Set<string> strzips = new Set<string>();
    private List<Inventory_Account__c> marketInformation ;
    private List<Inventory_Account__c> marketInformationsf ;
    private List<Inventory_Account__c> marketInformationcpq ;
    public transient String responseString{get;set;}
    public transient String partyId{get;set;} 
    private Map<String,String> waitlistItemMap;
    private List<Lead> leadList;
    public transient String waitListMapString{get;set;}
    public transient string nonInvProds {get;set;}
    public transient string primarycontact {get;set;}
    public transient string recaladvprice {get;set;}
    public transient String hexDigest {get;set;}
    public transient Double Monthlyspend {get;set;}
    public transient String leadids {get;set;}
    public transient boolean badEmail {get;set;}
    public boolean LEUser_vf {get;set;}
    public String modifyAddress {get;set;}
    public boolean allMarkets{get;set;}
    public Set<String> leCityNames {get;set;} 
    Public Map<String,LocalExpertCityWrapper> leCityInterestedMarkets {get;set;}
    Public Map<String,List<LocalExpertZipWrapper>> leZipInterestedMarkets {get;set;}
    public Map<String,String> cityToStateMap = new Map<String,String>();
    public Map<string,string> zipToCityStateMap = new Map<string,string>();
    Public Decimal leCitiesPotentialSale{get;set;}
    Public Decimal leZipsPotentialSale{get;set;}
    public string leCityIMQQ{get;set;} 
    public String adjacentZipsToQQ{get;set;}
    public Boolean characterLimitExceeded{get;set;}
    
    public accountSummaryHelperCopy(ApexPages.StandardController stdController){
            system.debug(' *** Base URL is *** '+System.URL.getSalesforceBaseUrl());
            String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
            system.debug(' *** Base URL with VF name *** '+pageName);

        isOpcityBlaTeamUser = OPCityAccountSummaryHelper.isBLAUser();     // CRM-6063
        blaIframeHeight = 280;    // CRM-6063
        loadDeatils=false;
        modifyAddress = 'false';
        acctabactive = 'block';
        qqtabactive = 'none';
        allMarkets = false;
        boolean loadAccount360 = true; 
        leCitiesPotentialSale = 0.00; 
        leZipsPotentialSale = 0.00;
        try{
            System.debug(ApexPages.currentPage().getURL());
            if (ApexPages.currentPage().getParameters().get('editurl') != null) {
                transactionId = ApexPages.currentPage().getParameters().get('editurl');
                System.debug(transactionId+'KKKK');
                acctabactive = 'none';
                qqtabactive = 'block';
                loadDeatils=false;
            }
            acct = (Account)stdController.getRecord();
            for(Account acct:[Select Id,name from Account where Id=:acct.id and skip_Account_360__c=true]){
                loadAccount360 = false;
            }
            if(loadAccount360){
                doControllerInitialization();
            }
            // CRM-6063
            blaIframeHeight = OPCityAccountSummaryHelper.getBLAIframeHeight(acct.Id);
            // CRM-6063
        }
        catch(Exception ex){
            system.debug('@@Exception'+ex);
        } 
    }
    public void loadTheTab(){
        if(!loadDeatils)
            loadDeatils=true;
    }
    
    public void doControllerInitialization(){
        try{
            LEUser_vf = [Select id, LE_User__c from User where id=:UserInfo.getUserId()].LE_User__c;
            leadList = [select Id FROM Lead WHERE (status = 'New' OR status = 'In Progress') and Account__c=:acct.id and OwnerId=:UserInfo.getUserId()]; //CRM-2878 - Removed latest lead selection logic - order by CreatedDate Desc limit 1
            leadids = '';
            if(leadList!=null && leadList.size()>0){
                for(Lead ld :leadList){
                    if(leadids == ''){
                        leadids = '\''+ld.Id+'\'';
                    }
                    else{
                        leadids = leadids+','+'\''+ld.Id+'\'';
                    }
                }
            }
            Account acc=[select id, BLA__c ,Core__C ,Office_Agent_BLA__c, party_Id__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c,Franchise_Type__c,Basic_Optout__c,Credit_Risk__c,Past_Due__c,Phone,Billing_Preference__c,Email_Address__c,Type,ResidentialBrandPPL__c,ResidentialLeadPPL__c,ResidentialAMLC__c,LandAMLC__c,RentalAMLC__c,MLS_Set_Id__c,Advertiserid__c from Account where id=:acct.id limit 1][0];
            badEmail = MoveUtility.isBadEmail(acc.Email_Address__c); // CRM-6284 - Check bad Email on Account
            accountObj = acc;    //CRM-5867                            
            partyId = acc.party_Id__c;
            if(acc.SyncButtonEnableDisable__c && !acc.BrokerAffiliationChanged__c){
                recaladvprice = 'Msg1';
            }
            else if(!acc.SyncButtonEnableDisable__c && acc.BrokerAffiliationChanged__c){
                recaladvprice = 'Msg2';
            }
            else if(acc.SyncButtonEnableDisable__c && acc.BrokerAffiliationChanged__c){
                recaladvprice = '';
            }
            else{
                //do nothing
            }
            system.debug('{!recaladvprice}'+recaladvprice);
            nonInvProds = '';
            Monthlyspend = 0;
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);
            for(Asset asst:[select id,Product2.name,Product2.Inventory__c, Product_code__c, Fulfillment_Status__c,End_Date__c,Billing_Period__c,Extended_Net_Price__c from Asset where  Accountid=:acct.id AND status = 'Active' AND Asset_Type__c = 'Parent']){
                if(asst!=null && asst.Product2.name!=null && !nonInvProds.contains(asst.Product_code__c)&& asst.Fulfillment_Status__c =='Fulfilled'&& asst.Product2.Inventory__c==false){
                    if(nonInvProds==''){
                        nonInvProds=asst.Product_code__c;
                    }
                    else{
                        nonInvProds=nonInvProds+','+asst.Product_code__c;
                    }
                }
                if((asst.End_Date__c >= system.today()||asst.End_Date__c == null) && asst.Billing_Period__c == 'Monthly'&&asst.Fulfillment_Status__c =='Fulfilled'){
                    Monthlyspend = Monthlyspend + asst.Extended_Net_Price__c;
                    system.debug('Monthlyspend&&&&'+Monthlyspend);
                }
            }
            system.debug('nonInvProds&&&&'+nonInvProds);
            marketInformation = new List<Inventory_Account__c>();
            marketInformationcpq = new List<Inventory_Account__c>();
            codesString='';
            leCityIMQQ='';
            adjacentZipsToQQ = '';
            marketInformationsf = [select id,Name,Number_of_Listings__c,waitlist_type_LEC__c,has_assets_LEC__c,SOV10_Available_for_A360_Purpose__c,Purchased_of_SOV10__c,
                                   Having_waitlist__c,Listing__c,Form__c,Buyers_Side__c,Account__r.Type,Account__r.Account_Sub_Type__c,
                                   SOV10__c,SOV10_Price__c,SOV20__c,SOV20_Price__c,SOV30__c,SOV30_Price__c,SOV50__c,SOV50_Price__c,
                                   Office__c,Number_of_Buy_Side_Transactions__c,Waitlist_Type__c,
                                   Inventory_Data__r.name,Inventory_Data__r.Median_Market_Price__c,Inventory_Data__r.Quantity_Tier__c,
                                   Inventory_Data__r.SOV10_Price__c,Inventory_Data__r.SOV20_Price__c,Inventory_Data__r.SOV30_Price__c,Inventory_Data__r.SOV50_Price__c,
                                   Inventory_Data__r.Promotion__c,Inventory_Data__r.City__c,Inventory_Data__r.State__c,
                                   Inventory_Data__r.Promo_Code__c,Inventory_Data__r.Is_available__c,Has_Assets__c, Has_Assets_LE__c, waitlist_product_type__c, Waitlist_Type_LE__c
                                   FROM Inventory_Account__c 
                                   WHERE Account__c =:acct.id
                                   AND (Having_waitlist__c = TRUE OR Listing__c = TRUE OR Form__c = TRUE OR Buyers_Side__c = TRUE OR Office__c = TRUE OR Has_Assets__c = TRUE OR Has_Assets_LE__c = TRUE OR has_assets_LEC__c  = TRUE OR waitlist_product_type__c != null) order by Inventory_Data__r.City__c];
            Set<String> markets = new Set<String>(); // CRM-5389
            leCityNames = new Set<String>();
            leCityInterestedMarkets = new Map<String,LocalExpertCityWrapper>();
            leZipInterestedMarkets = new Map<String,List<LocalExpertZipWrapper>>();
            for(Inventory_Account__c intrestedM : marketInformationsf){
                if(null != intrestedM.Inventory_Data__r.City__c && null != intrestedM.Inventory_Data__r.State__c){
                    if(intrestedM.Inventory_Data__r.name.isNumeric()){
                        strzips.add(intrestedM.Inventory_Data__r.name);
                    }else{
                        strzips.add(intrestedM.Inventory_Data__r.City__c+', '+intrestedM.Inventory_Data__r.State__c);  
                    }
                    zipToCityStateMap.put(intrestedM.Inventory_Data__r.name,intrestedM.Inventory_Data__r.State__c + '-'+intrestedM.Inventory_Data__r.City__c.tolowercase());
                    cityToStateMap.put(intrestedM.Inventory_Data__r.City__c.toLowerCase(),intrestedM.Inventory_Data__r.State__c);  
                    if(leCityIMQQ == ''){
                        leCityIMQQ = intrestedM.Inventory_Data__r.City__c+', '+intrestedM.Inventory_Data__r.State__c;
                    }else{
                        if(!leCityIMQQ.Contains(intrestedM.Inventory_Data__r.City__c+', '+intrestedM.Inventory_Data__r.State__c))
                            leCityIMQQ = leCityIMQQ+ '$$'+(intrestedM.Inventory_Data__r.City__c+', '+intrestedM.Inventory_Data__r.State__c);
                    }
                    
                    String leCityIM = intrestedM.Inventory_Data__r.State__c + '-'+intrestedM.Inventory_Data__r.City__c.tolowercase();
                    if(!intrestedM.Inventory_Data__r.name.isNumeric()){
                        leCityNames.add(leCityIM);
                        leCityInterestedMarkets.put(leCityIM,new LocalExpertCityWrapper('Interested Market',intrestedM,null,accountObj.Type));
                        system.debug(' do we have any Interested market for city '+intrestedM.Inventory_Data__r.name);
                    }else{
                        system.debug(' intrestedM.Inventory_Data__r.name ********** '+intrestedM.Inventory_Data__r.name);
                        if(leZipInterestedMarkets.containsKey(leCityIM)){
                            leZipInterestedMarkets.get(leCityIM).add(new LocalExpertZipWrapper('Interested Market',intrestedM,null,accountObj.Type));
                        }else{
                            List<LocalExpertZipWrapper> leZipWrapList = new List<LocalExpertZipWrapper>();
                            leZipWrapList.add(new LocalExpertZipWrapper('Interested Market',intrestedM,null,accountObj.Type));
                            leZipInterestedMarkets.put(leCityIM,leZipWrapList);
                        }
                        
                        markets.add(intrestedM.Inventory_Data__r.name);  // CRM-5389
                        marketInformation.add(intrestedM);
                        if(intrestedM!=null){
                            if(codesString==''){
                                codesString=intrestedM.Inventory_Data__r.name;
                            }
                            else{
                                codesString=codesString+','+intrestedM.Inventory_Data__r.name;
                            }
                        }
                        zipcodes_cpq = codesString;  
                    }
                }
            }
            
            for(Inventory_Data__c invData: [Select id,name,SOV10__c,SOV20__c,SOV30__c,SOV50__c,SOV10_Price__c,SOV20_Price__c,SOV30_Price__c,SOV50_Price__c,City__c,State__c,Median_Market_Price__c,Quantity_Tier__c  from Inventory_Data__c where City__c =: cityToStateMap.KeySet() AND State__c =: cityToStateMap.Values()]){
                if(invData.name.isNumeric() && !markets.contains(invData.Name) && (invData.SOV20__c || invData.SOV30__c || invData.SOV50__c )){
                    if(adjacentZipsToQQ == ''){
                        adjacentZipsToQQ = invData.Name;
                    }else{
                        adjacentZipsToQQ += ','+invData.Name;
                    }
                }
                String leCityInvData = invData.State__c + '-'+invData.City__c.tolowercase();
                if(cityToStateMap.containsKey(invData.City__c.tolowercase()) && cityToStateMap.get(invData.City__c.tolowercase()).EqualsIgnoreCase(invData.State__c)){
                    if(!invData.name.isNumeric() && !leCityInterestedMarkets.ContainsKey(leCityInvData)){
                        system.debug(' *** city in Inv Data ** '+invData.name);
                        leCityNames.add(leCityInvData);
                        leCityInterestedMarkets.put(leCityInvData,new LocalExpertCityWrapper('Inventory Data',null,invData,accountObj.Type));
                    }
                    if(invData.name.isNumeric() && !markets.contains(invData.name)){
                        system.debug(' *******zip in invdata **** '+invData.name);
                        if(leZipInterestedMarkets.containsKey(leCityInvData)){
                            leZipInterestedMarkets.get(leCityInvData).add(new LocalExpertZipWrapper('Inventory Data',null,invData,accountObj.Type));
                        }else{
                            List<LocalExpertZipWrapper> leZipWrapList1 = new List<LocalExpertZipWrapper>();
                            leZipWrapList1.add(new LocalExpertZipWrapper('Inventory Data',null,invData,accountObj.Type));
                            leZipInterestedMarkets.put(leCityInvData,leZipWrapList1);
                        }
                    } 
                }
            }
            
            for(String str: leZipInterestedMarkets.keySet()){
                Integer citylistings =0;
                Integer cityBST=0;
                for(LocalExpertZipWrapper lezip: leZipInterestedMarkets.get(str)){
                    if(lezip.marketType == 'Interested Market'){
                        citylistings = lezip.listings != null? citylistings + (Integer)lezip.listings:citylistings;
                        cityBST      = lezip.BST      != null? cityBST + (Integer)lezip.BST:cityBST;
                    }
                    if(leCityInterestedMarkets.ContainsKey(lezip.marketState + '-'+lezip.marketcity.tolowercase()) &&
                       leCityInterestedMarkets.get(lezip.marketState + '-'+lezip.marketcity.tolowercase()).marketType == 'Inventory Data'){
                           leCityInterestedMarkets.get(lezip.marketState + '-'+lezip.marketcity.tolowercase()).listings = citylistings;
                           leCityInterestedMarkets.get(lezip.marketState + '-'+lezip.marketcity.tolowercase()).BST = cityBST;
                       } 
                }
            }
            for(LocalExpertCityWrapper lecity: leCityInterestedMarkets.Values()){
                leCitiesPotentialSale = leCitiesPotentialSale + (lecity.sov50Price!= 0 && lecity.sov50Available == true? lecity.sov50Price:lecity.sov40Price!= 0 && lecity.sov40Available == true? lecity.sov40Price:lecity.sov30Price!= 0 && lecity.sov30Available == true? lecity.sov30Price:lecity.sov20Price!= 0 && lecity.sov20Available == true? lecity.sov20Price:lecity.sov10Price!= 0 && lecity.sov10Available == true? lecity.sov10Price:0.00);
            }
            
            for(String str: leZipInterestedMarkets.Keyset()){
                for(LocalExpertZipWrapper lezip: leZipInterestedMarkets.get(str)){
                    leZipsPotentialSale = leZipsPotentialSale + (lezip.sov50Price!=0 && lezip.sov50Available == true? lezip.sov50Price:lezip.sov30Price!=0 && lezip.sov30Available == true? lezip.sov30Price:lezip.sov20Price!=0 && lezip.sov20Available == true? lezip.sov20Price:0.00);
                }
            }
            
            // When City doesn't have zips, make sure the page doesn't break
            for(String str: leCityInterestedMarkets.keySet()){
                if(!leZipInterestedMarkets.containsKey(str)){
                    leCityInterestedMarkets.get(str).hasLeZips = false;                    
                }else{
                    leCityInterestedMarkets.get(str).hasLeZips = true; 
                }
            }
            system.debug(' le cities are ****'+leCityInterestedMarkets.Keyset()+' le zips are ****'+leZipInterestedMarkets.Keyset());
            system.debug(' city to state values **** '+cityToStateMap.keySet()+' *** leCityNames *** '+leCityNames); 
            
            protectedMarkets = InventorySearch.getProtectedMarketList(markets);       // CRM-5389 
            system.debug('@@@zipcodes_cpq***'+zipcodes_cpq+' *** strzips **'+strzips);
            marketInfoStringJSON=JSON.serialize(marketInformation);
            System.debug('marketInfoStringJSON'+marketInfoStringJSON);
            waitlistItemMap=new Map<String,String>();
            for(Waitlist_Item__c wl:[select Id,product__r.productcode, status__c,Total_MAX_Monthly_Pre_Auth_Spend__c,Market__c, State__c from Waitlist_Item__c where Account__c=:acct.id and status__c IN('Active','Expired') and  Market__c in: strzips]){
                system.debug(' ** wl market '+wl.Market__c+' wl status *** '+wl.status__c);
                if(zipToCityStateMap.containsKey(wl.market__c)){
                    if(wl.market__c.isNumeric()){
                        string cityState = zipToCityStateMap.get(wl.market__c);
                        if(leZipInterestedMarkets.containsKey(cityState)){
                            for(LocalExpertZipWrapper lezip: leZipInterestedMarkets.get(cityState)){
                                if(lezip.marketZip == wl.market__c){
                                    if(wl.status__c == 'Active'){
                                        lezip.entryTypePreAuthActive =  wl.product__r.productcode == 'COBROKE'? 'Active Pre-Auth CBC':wl.product__r.productcode == 'LOCALEXPERT'? 'Active Pre-Auth LE Zip':wl.product__r.productcode == 'LOCALEXPERTCITY'? 'Active Pre-Auth LE City':null;
                                        lezip.wltype = 'Active';
                                    }else if(wl.status__c == 'Expired'){
                                        lezip.entryTypePreAuthExpired =  wl.product__r.productcode == 'COBROKE'? 'Prior Pre-Auth CBC':wl.product__r.productcode == 'LOCALEXPERT'? 'Prior Pre-Auth LE Zip':wl.product__r.productcode == 'LOCALEXPERTCITY'? 'Prior Pre-Auth LE City':null;
                                        lezip.wltype = 'Expired';
                                    }
                                }
                            }
                        }
                    }
                }else if(!wl.market__c.isNumeric()){
                    String cityState1 = wl.Market__c != null? wl.State__c+ '-'+wl.Market__c.split(',')[0].tolowercase():'NOTFOUND';
                    if(leCityInterestedMarkets.containsKey(cityState1)){
                        if(wl.status__c == 'Active'){
                            leCityInterestedMarkets.get(cityState1).entryTypePreAuthActive = wl.product__r.productcode == 'COBROKE'? 'Active Pre-Auth CBC':wl.product__r.productcode == 'LOCALEXPERT'? 'Active Pre-Auth LE Zip':wl.product__r.productcode == 'LOCALEXPERTCITY'? 'Active Pre-Auth LE City':null;
                            leCityInterestedMarkets.get(cityState1).wltype = 'Active';
                        }else if(wl.status__c == 'Expired'){
                            leCityInterestedMarkets.get(cityState1).entryTypePreAuthExpired =  wl.product__r.productcode == 'COBROKE'? 'Prior Pre-Auth CBC':wl.product__r.productcode == 'LOCALEXPERT'? 'Prior Pre-Auth LE Zip':wl.product__r.productcode == 'LOCALEXPERTCITY'? 'Prior Pre-Auth LE City':null;
                            leCityInterestedMarkets.get(cityState1).wltype = 'Expired';
                        } 
                    }
                }
                
                if(waitlistItemMap.containsKey(wl.market__c)){
                    String preAuth = waitlistItemMap.get(wl.market__c);
                    if(preAuth.contains('Active')){
                        if(wl.status__c == 'Active'){
                            if(wl.product__r.productcode == 'COBROKE')
                                preAuth = preAuth + '<span style="color:green">, CBC</span>';
                            if(wl.product__r.productcode == 'LOCALEXPERT')
                                preAuth = preAuth + '<span style="color:green">, LE</span>';
                        }else{
                            if(wl.product__r.productcode == 'COBROKE')
                                preAuth = preAuth + ', Prior Pre-Auth CBC';
                            if(wl.product__r.productcode == 'LOCALEXPERT')
                                preAuth = preAuth + ', Prior Pre-Auth LE';
                        }
                        
                    }else{
                        if(wl.status__c == 'Expired'){
                            if(wl.product__r.productcode == 'COBROKE')
                                preAuth = preAuth + ', CBC';
                            if(wl.product__r.productcode == 'LOCALEXPERT')
                                preAuth = preAuth + ', LE';
                        }else{
                            if(wl.product__r.productcode == 'COBROKE')
                                preAuth = preAuth + '<span style="color:green">, Active Pre-Auth CBC</span>';
                            if(wl.product__r.productcode == 'LOCALEXPERT')
                                preAuth = preAuth + '<span style="color:green">, Active Pre-Auth LE</span>';
                        }
                    }
                    
                    waitlistItemMap.put(wl.market__c,preAuth);
                }else{
                    String preAuth = '';
                    
                    if(wl.status__c == 'Active'){
                        if(wl.product__r.productcode == 'COBROKE')
                            preAuth = preAuth + '<span style="color:green">Active Pre-Auth CBC</span>';
                        if(wl.product__r.productcode == 'LOCALEXPERT')
                            preAuth = preAuth + '<span style="color:green">Active Pre-Auth LE</span>';
                    }else{
                        if(wl.product__r.productcode == 'COBROKE')
                            preAuth = preAuth + 'Prior Pre-Auth CBC';
                        if(wl.product__r.productcode == 'LOCALEXPERT')
                            preAuth = preAuth + 'Prior Pre-Auth LE';
                    }
                    waitlistItemMap.put(wl.market__c,preAuth);
                }
            }
            if(waitlistItemMap!=null && !waitlistItemMap.isEmpty())
                waitListMapString=JSON.serialize(waitlistItemMap);
            
            if(codesString!=''){
                //responseString=getInventoryData(partyId,codesString);
            }
            
            for(String cityStateKey: leZipInterestedMarkets.keySet()){
                for(LocalExpertZipWrapper lezip: leZipInterestedMarkets.get(cityStateKey)){
                    if(lezip.marketType == 'Interested Market' && leCityInterestedMarkets.containsKey(cityStateKey) && leCityInterestedMarkets.get(cityStateKey).marketType == 'Inventory Data'){
                        if(lezip.entryTypePreAuthActive != null || lezip.entryTypePreAuthExpired != null)
                            leCityInterestedMarkets.get(cityStateKey).entryTypePreAuthActive = 'Pre-Authorized Zip';
                        if(lezip.entryTypeAssets != null)
                            leCityInterestedMarkets.get(cityStateKey).entryTypeAssets = 'Owns Zip Asset';
                        if(lezip.entryTypeWaitlistCBC != null || lezip.entryTypeWaitlistLEZip != null)
                            leCityInterestedMarkets.get(cityStateKey).entryTypeWaitlist = 'Waitlisted Zip';
                    }
                }
            } 
            
            setQuickQuoteUrl(acc);
            
            if(test.isRunningTest())
                throw new DMLException();
        }
        catch(Exception ex){
            system.debug('@@Exception'+ex);
        } 
    }
    public String getOwnedProductsNames(){
        String stringOfProducts='';
        Set<String> productsSet = new Set<String>();
        for(Asset asst:[select id,Product2.name,Product2.Inventory__c, Product_code__c, Fulfillment_Status__c from Asset where  Accountid=:acct.id AND status = 'Active' AND Asset_Type__c = 'Parent']){
            if(asst.Product2.name!=null){
                if(asst.Product2.name == 'Local Expert'){
                    productsSet.add('Local Expert Zip');
                }else{
                    productsSet.add(asst.Product2.name);
                }
            }
        }
        for(String str: productsSet){
            stringOfProducts+='; '+str;
        }
        // CRM-5867 - Opcity Product
        if ((accountObj.Type == 'Broker' && accountObj.BLA__c == 'Yes') || (accountObj.Type == 'Realtor Agent' && (accountObj.Office_Agent_BLA__c == 'BLA Confirmed' || accountObj.Office_Agent_BLA__c == 'BLA Unconfirmed'))){
            stringOfProducts+='; '+'Opcity-BLA';
        }
        if((accountObj.Type == 'Broker' && accountObj.Core__C == 'Yes') || ((accountObj.Type == 'Realtor Agent' && accountObj.Office_Agent_BLA__c == 'Core'))) {
            stringOfProducts+='; '+'Opcity-Core';
        }
        system.debug(' *** before returning - stringOfProducts '+stringOfProducts+' *** productsSet *** '+productsSet);
        // CRM-5867 - End                         
        if(stringOfProducts!=null && stringOfProducts!=''){
            stringOfProducts=stringOfProducts.substring(1);
            return stringOfProducts;}
        else {return null;}
    }
    public String getConsolidatedBillingDate(){
        String consolidatedBillingDate='';
        for(Zuora__CustomerAccount__c billingAccs:[select id,Zuora__BillCycleDay__c  from Zuora__CustomerAccount__c where Zuora__Account__c=:acct.id]){
            consolidatedBillingDate=billingAccs.Zuora__BillCycleDay__c;
        }
        return consolidatedBillingDate;      
    }
    public static String getInventoryData(String partyId,String codesString){
        String responseStringBody='';
        try{
            string  mProduct = 'COBROKE';
            
            system.debug('codesString#####'+codesString);
            String step1 = codesString.escapeCsv();
            system.debug('step1#####'+step1);
            List<String> lstZips = codesString.split(',');
            List<String> partyIds = partyId.split(',');
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setMethod('POST');
            String endPointUrl=Label.Inventory_Endpoint;//'https://dev-es-is.api.move.com/availableinventory'; 
            req.setEndpoint(endPointUrl);
            req.setHeader('Content-Type', 'application/json'); 
            req.setHeader('Accept', 'application/json');
            req.setHeader('Authorization', 'oAuth');
            req.setHeader('x-api-key', '5lfstIvpWLNSUMt3fZfj9TW2fezQSff33u6C9aq9');
            req.setHeader('Content-Length', '0'); 
            req.setTimeout(120000);
            string account360Products = System.Label.Account360Products.split(',')[0];
            String strbody ='';  
            
            strbody = '{  "part_numbers" :['+account360Products+'], "party_ids" :["' +partyIds+'"] , "postal_codes" :['+codesString+']}'; //Added localexpert
            strbody=strbody.replace('(','').replace(')','');
            req.setBody(strbody);
            system.debug(' strbody **** '+strbody);
            if(lstZips!=null && lstZips.size()>0){
                res=http.send(req);
                system.debug(' *** status code *** '+res.getStatusCode()+' *** res status *** '+res.getStatus());
                if(res.getStatusCode()==200 && res.getStatus()=='OK'){
                    system.debug('response####'+res.getBody());
                    responseStringBody=res.getBody();
                } 
            }
        }
        Catch(CallOUtException cx){
            responseStringBody='SystemCalloutException';
        }
        catch(Exception ex){ 
            responseStringBody='Exception';
            system.debug('@@@@@@@@Exception occurred@@@@@@@@@@@@@@@'+ex.getMessage());
        }
        return responseStringBody;
    } 
    
    @remoteaction
    global static String getInventoryDataRemoteAction(String partyId,String step1){ 
        return getInventoryData(partyId,step1);
    }
    
    public PageReference updateAddress(){
        system.debug('Inside OpenAddressModifier:: '+ acct);
        modifyAddress = 'false';
        update acct;
        return null;
    }
    // CPQ Upgrade oAuth changes to QQ Url
    @Testvisible private void setQuickQuoteUrl(Account accDetails) {
        QQUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/authorize?response_type=code';
        QQUrl = QQUrl + '&client_id='+Label.CPQ_Client_Id;
        QQUrl = QQUrl + '&redirect_uri=https://'+QuickQuote__c.getOrgDefaults().BMInstance__c+'.bigmachines.com/admin/oauth2/salesforce/oauth_callback.jsp&state=/commerce/new_equipment/products/model_configs.jsp?';
        QQUrl = QQUrl + 'segment=realtor%26product_line=inventoryProducts%26model=inventorySearch%26_from_punchin=true%26_variable_name_punchin=true';
        
        String stateUrlParams = '%26priceTier_quickQuote=ANY';
        stateUrlParams = stateUrlParams + '%26productType_text_quickQuote=ANY';
        stateUrlParams = stateUrlParams + '%26partyID_quickQuote='+accDetails.party_id__c;
        stateUrlParams = stateUrlParams + '%26primaryContact_quickQuote='+primarycontact;
        stateUrlParams = stateUrlParams + '%26badEmail_quickQuote='+badEmail;
        stateUrlParams = stateUrlParams + '%26primaryEmail_quickQuote='+accDetails.Email_Address__c;
        stateUrlParams = stateUrlParams + '%26sFDCAccountId_quickQuote='+accDetails.Id;
        //CRM-5913 Added Encoding for Franchise Type
        if (accDetails.Franchise_Type__c != null && accDetails.Franchise_Type__c != '') {
            stateUrlParams = stateUrlParams + '%26franchiseType_quickQuote='+EncodingUtil.urlEncode(accDetails.Franchise_Type__c,'UTF-8');
        }
        if (accDetails.Basic_Optout__c != null && accDetails.Basic_Optout__c != '') {
            stateUrlParams = stateUrlParams + '%26basicOpt_quickQuote='+accDetails.Basic_Optout__c;
        }
        stateUrlParams = stateUrlParams + '%26creditrisk_quickQuote='+accDetails.Credit_Risk__c;
        stateUrlParams = stateUrlParams + '%26pastdue_quickQuote='+accDetails.Past_Due__c;
        stateUrlParams = stateUrlParams + '%26billinfPref_quickQuote='+accDetails.Billing_Preference__c;
        stateUrlParams = stateUrlParams + '%26phone_quickQuote='+EncodingUtil.urlEncode(accDetails.Phone,'UTF-8');
        stateUrlParams = stateUrlParams + '%26accountType_quickQuote='+EncodingUtil.urlEncode(accDetails.Type,'UTF-8');
        if (accDetails.ResidentialBrandPPL__c != null) {
            stateUrlParams = stateUrlParams + '%26cURRENTBRANDPPL_adv_quickQuote='+accDetails.ResidentialBrandPPL__c;
        }
        if (accDetails.ResidentialLeadPPL__c != null) {
            stateUrlParams = stateUrlParams + '%26cURRENTLEADPPL_adv_quickQuote='+accDetails.ResidentialLeadPPL__c;
        }
        if (accDetails.ResidentialAMLC__c != null) {
            stateUrlParams = stateUrlParams + '%26cURRENTRESIDENTIALAMLC_adv_quickQuote='+accDetails.ResidentialAMLC__c;
        }
        if (accDetails.LandAMLC__c != null) {
            stateUrlParams = stateUrlParams + '%26cURRENTLANDAMLC_adv_quickQuote='+accDetails.LandAMLC__c;
        }
        if (accDetails.RentalAMLC__c != null) {
            stateUrlParams = stateUrlParams + '%26cURRENTRENTALAMLC_adv_quickQuote='+accDetails.RentalAMLC__c;
        }
        if (accDetails.MLS_Set_Id__c != null && accDetails.MLS_Set_Id__c != '') {
            stateUrlParams = stateUrlParams + '%26mLSSetID_quickQuote='+accDetails.MLS_Set_Id__c;
        }
        if (accDetails.Advertiserid__c != null && accDetails.Advertiserid__c != '') {
            stateUrlParams = stateUrlParams + '%26advertiserId_quickQuote='+accDetails.Advertiserid__c;
        }
        if (recaladvprice != null && recaladvprice != '') {
            stateUrlParams = stateUrlParams + '%26accActivationFlag_quickQuote='+recaladvprice;
        }
        if (nonInvProds != null && nonInvProds != '') {
            stateUrlParams = stateUrlParams + '%26nonInvPartsList_QuickQuote='+nonInvProds;
        }
        stateUrlParams = stateUrlParams + '%26marketCode_quickQuote=ALL';
        if (leadids != '') {
            stateUrlParams = stateUrlParams + '%26leadId_quickQuote='+leadids;
        }
        stateUrlParams = stateUrlParams + '%26sFDCUsername_quickQuote='+UserInfo.getUserName();
        stateUrlParams = stateUrlParams + '%26isLeUser_quickQuote='+LEUser_vf;
        stateUrlParams = stateUrlParams + '%26siteName_quickQuote='+QuickQuote__c.getOrgDefaults().BMInstance__c;
        stateUrlParams = stateUrlParams + '%26bundleID_quickQuote=NONE';
        //stateUrlParams = stateUrlParams + '%26_parent_window='+_main_child_dlg_106501668;
        if (hexDigest !=null && hexDigest != '') {
            stateUrlParams = stateUrlParams + '%26sessionIdentifier='+hexDigest;
        }
        system.debug('stateUrlParams'+stateUrlParams);
        QQUrl = QQUrl + stateUrlParams;
        
        if(QQUrl.length() + zipcodes_cpq.length() <= 1900){
            QQUrl = QQUrl + '%26zipcode_heatmap_selection_quickQuote='+zipcodes_cpq;
            characterLimitExceeded = false;
        }else{
            characterLimitExceeded = true;
        }
        
        system.debug('quickquoteURL='+QQUrl); 
    }
    
    class LocalExpertCityWrapper{
        public String marketcity{get;set;}
        public String marketState{get;set;}
        public String marketType{get;set;}
        public String accountType{get;set;}
        public Decimal BST{get;set;}
        public Decimal listings{get;set;}
        public Decimal medianMarketPrice{get;set;}
        public Boolean sov10Available{get;set;}
        public Boolean sov20Available{get;set;}
        public Boolean sov30Available{get;set;}
        public Boolean sov40Available{get;set;}
        public Boolean sov50Available{get;set;}
        public Decimal sov10Price{get;set;}
        public Decimal sov20Price{get;set;}
        public Decimal sov30Price{get;set;}
        public Decimal sov40Price{get;set;}
        public Decimal sov50Price{get;set;}
        public Decimal quantity{get;set;}
        public String entryTypeAssets{get;set;}
        public String entryTypeWaitlist{get;set;}
        public String entryTypePreAuthActive{get;set;}
        public String entryTypePreAuthExpired{get;set;}
        public string wltype{get;set;}
        public Boolean hasLeZips{get;set;}
        
        public LocalExpertCityWrapper(String type,Inventory_Account__c interestedMarket,Inventory_Data__c inventoryData,String accType){
            if(type == 'Interested Market' && null != interestedMarket){
                marketType        = type;
                marketcity        = interestedMarket.Inventory_Data__r.City__c;
                marketState       = interestedMarket.Inventory_Data__r.State__c;
                accountType       = accType;
                BST               = interestedMarket.Number_of_Buy_Side_Transactions__c;
                listings          = interestedMarket.Number_of_Listings__c ;
                medianMarketPrice = interestedMarket.Inventory_Data__r.Median_Market_Price__c;
                sov10Available    = interestedMarket.SOV10_Available_for_A360_Purpose__c >=1? true:false;
                sov20Available    = interestedMarket.SOV10_Available_for_A360_Purpose__c >=2? true:false;
                sov30Available    = interestedMarket.SOV10_Available_for_A360_Purpose__c >=3? true:false;
                sov40Available    = interestedMarket.SOV10_Available_for_A360_Purpose__c >=4? true:false;
                sov50Available    = interestedMarket.SOV10_Available_for_A360_Purpose__c >=5? true:false;
                sov10Price        = interestedMarket.Inventory_Data__r.SOV10_Price__c != null?   interestedMarket.Inventory_Data__r.SOV10_Price__c:0;
                sov20Price        = interestedMarket.Inventory_Data__r.SOV10_Price__c != null? 2*interestedMarket.Inventory_Data__r.SOV10_Price__c:0;
                sov30Price        = interestedMarket.Inventory_Data__r.SOV10_Price__c != null? 3*interestedMarket.Inventory_Data__r.SOV10_Price__c:0;
                sov40Price        = interestedMarket.Inventory_Data__r.SOV10_Price__c != null? 4*interestedMarket.Inventory_Data__r.SOV10_Price__c:0;
                sov50Price        = interestedMarket.Inventory_Data__r.SOV10_Price__c != null? 5*interestedMarket.Inventory_Data__r.SOV10_Price__c:0;
                if(interestedMarket.has_assets_LEC__c == true){
                    if(interestedMarket.Purchased_of_SOV10__c == 5){
                        entryTypeAssets =  'Owns LE City 50%';
                    }else if(interestedMarket.Purchased_of_SOV10__c == 4){
                        entryTypeAssets =  'Owns LE City 40%';
                    }else if(interestedMarket.Purchased_of_SOV10__c == 3){
                        entryTypeAssets =  'Owns LE City 30%';
                    }else if(interestedMarket.Purchased_of_SOV10__c == 2){
                        entryTypeAssets =  'Owns LE City 20%';
                    }else if(interestedMarket.Purchased_of_SOV10__c == 1){
                        entryTypeAssets =  'Owns LE City 10%';
                    }
                }else
                    entryTypeAssets = null; 
                entryTypeWaitlist = interestedMarket.waitlist_type_LEC__c != null? 'Waitlisted LE City '+ interestedMarket.waitlist_type_LEC__c:null;                  
            } else if(type == 'Inventory Data' && null != inventoryData){
                if(inventoryData.SOV10__c != null && inventoryData.Quantity_Tier__c != null){
                    quantity         = inventoryData.SOV10__c >=(inventoryData.Quantity_Tier__c/2)? inventoryData.Quantity_Tier__c/2:inventoryData.SOV10__c;
                }else{
                    quantity         = null;
                }
                marketType        = type;
                marketcity        = inventoryData.City__c;
                marketState       = inventoryData.State__c;
                accountType       = accType;
                medianMarketPrice = inventoryData.Median_Market_Price__c;
                // entryTypeAssets   = 'N/A';
                sov10Available    = quantity != null && quantity >=1? true:false;
                sov20Available    = quantity != null && quantity >=2? true:false;
                sov30Available    = quantity != null && quantity >=3? true:false;
                sov40Available    = quantity != null && quantity >=4? true:false;
                sov50Available    = quantity != null && quantity >=5? true:false; 
                sov10Price        = inventoryData.SOV10_Price__c != null?   inventoryData.SOV10_Price__c:0;
                sov20Price        = inventoryData.SOV10_Price__c != null? 2*inventoryData.SOV10_Price__c:0;
                sov30Price        = inventoryData.SOV10_Price__c != null? 3*inventoryData.SOV10_Price__c:0;
                sov40Price        = inventoryData.SOV10_Price__c != null? 4*inventoryData.SOV10_Price__c:0;
                sov50Price        = inventoryData.SOV10_Price__c != null? 5*inventoryData.SOV10_Price__c:0;
            }
        }
    }
    
    class LocalExpertZipWrapper{
        public String marketcity{get;set;}
        public String marketType{get;set;}
        public String marketState{get;set;}
        public String marketZip{get;set;}
        public String accountType{get;set;}
        public Decimal BST{get;set;}
        public Decimal listings{get;set;}
        public Decimal medianMarketPrice{get;set;}
        public String entryTypeAssets{get;set;}
        public String entryTypeWaitlistLEZip{get;set;}
        public String entryTypeWaitlistCBC{get;set;}
        public String entryTypePreAuthActive{get;set;}
        public String entryTypePreAuthExpired{get;set;}
        public Decimal sov20Price{get;set;}
        public Decimal sov30Price{get;set;}
        public Decimal sov50Price{get;set;}
        public Boolean sov20Available{get;set;}
        public Boolean sov30Available{get;set;}
        public Boolean sov50Available{get;set;}
        public string wltype{get;set;}
        
        public LocalExpertZipWrapper(String type,Inventory_Account__c interestedMarket,Inventory_Data__c inventoryData,String accType){
            if(type == 'Interested Market' && null != interestedMarket){
                marketType              = type;
                marketcity              = interestedMarket.Inventory_Data__r.City__c;
                marketState             = interestedMarket.Inventory_Data__r.State__c;
                marketZip               = interestedMarket.Inventory_Data__r.name;
                accountType             = accType;
                BST                     = interestedMarket.Number_of_Buy_Side_Transactions__c;
                listings                = interestedMarket.Number_of_Listings__c ;
                medianMarketPrice       = interestedMarket.Inventory_Data__r.Median_Market_Price__c;
                sov20Available          = interestedMarket.SOV20__c;
                sov30Available          = interestedMarket.SOV30__c;
                sov50Available          = interestedMarket.SOV50__c;
                sov20Price              = interestedMarket.Inventory_Data__r.SOV20_Price__c!= null? interestedMarket.Inventory_Data__r.SOV20_Price__c:0;  
                sov30Price              = interestedMarket.Inventory_Data__r.SOV30_Price__c!= null? interestedMarket.Inventory_Data__r.SOV30_Price__c:0; 
                sov50Price              = interestedMarket.Inventory_Data__r.SOV50_Price__c!= null? interestedMarket.Inventory_Data__r.SOV50_Price__c:0; 
                entryTypeAssets         = interestedMarket.has_assets_LE__c == true? 'Owns LE Zip':null;
                entryTypeAssets         = interestedMarket.Has_Assets__c == true? entryTypeAssets!=null? entryTypeAssets + ', Owns CBC':' Owns CBC ':entryTypeAssets;
                entryTypeWaitlistLEZip  = interestedMarket.waitlist_type_LE__c!= null? 'Waitlisted LE Zip '+ interestedMarket.waitlist_type_LE__c:null; 
                entryTypeWaitlistCBC    = interestedMarket.Waitlist_Type__c !=null? 'CBC Waitlist '+interestedMarket.Waitlist_Type__c:null;
            } else if(type == 'Inventory Data' && null != inventoryData){ 
                marketType        = type;
                marketcity        = inventoryData.City__c;
                marketState       = inventoryData.State__c;
                marketZip         = inventoryData.name;
                accountType       = accType;
                medianMarketPrice = inventoryData.Median_Market_Price__c;
                entryTypeAssets   = 'Adjacent Zip';
                sov20Available    = inventoryData.SOV20__c;
                sov30Available    = inventoryData.SOV30__c;
                sov50Available    = inventoryData.SOV50__c;
                sov20Price        = inventoryData.SOV20_Price__c!= null? inventoryData.SOV20_Price__c:0;   
                sov30Price        = inventoryData.SOV30_Price__c!= null? inventoryData.SOV30_Price__c:0;
                sov50Price        = inventoryData.SOV50_Price__c!= null? inventoryData.SOV50_Price__c:0;
            } 
        }
    }
}