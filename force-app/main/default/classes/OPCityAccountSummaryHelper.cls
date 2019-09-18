global class OPCityAccountSummaryHelper {
    public Boolean isOpcityBlaTeamUser {get; set;}        // CRM-6063
    public Boolean isOpcityCoreTeamUser {get; set;}        // CRM-6063
    public Integer blaIframeHeight {get; set;}            // CRM-6063
    private final Account acct;
    private Account accountObj;                                                    
    public List<String> protectedMarkets{get; set;}             
    public DateTime localTime{get;set;}
    public TimeZone tz{get;set;}
    public boolean loadDeatils{get;set;}
    public String OpcityCoreQQURL{get;set;} 
    //public String OpcityBLAQQURL{get;set;} //Ravi POC for Opcity Core Quick Quote
    Public String acctabactive{get;set;}
    Public String qqtabactive{get;set;}
    Public String transactionId{get;set;}
    public transient String marketInfoStringJSON{get;set;}
    public List<string> strzips = new List<string>();
    private List<Inventory_Account__c> marketInformation ;
    private List<Inventory_Account__c> marketInformationsf ;
    public transient String partyId{get;set;}
    private Map<String,String> waitlistItemMap;
    public transient String waitListMapString{get;set;}
    public transient string recaladvprice {get;set;}
    public transient String hexDigest {get;set;}
    public transient Double Monthlyspend {get;set;}
    public String modifyAddress {get;set;}
    public boolean allMarkets{get;set;}
    
    // CRM-6063 - Start
    private static List<BigMachines__Oracle_User__c> currentUser = [SELECT BigMachines__User_Groups__c FROM BigMachines__Oracle_User__c WHERE BigMachines__Salesforce_User__c =:UserInfo.getUserId() LIMIT 1];
    public static Boolean isBLAUser() {
        if (!currentUser.isEmpty() && currentUser[0].BigMachines__User_Groups__c != null) {
            return currentUser[0].BigMachines__User_Groups__c.split(';').contains('opcityBLA');
        }
        return false;
    }
    
    public static Boolean isCoreUser() {
        if (!currentUser.isEmpty() && currentUser[0].BigMachines__User_Groups__c != null) {
            return currentUser[0].BigMachines__User_Groups__c.split(';').contains('opcityCore');
        }
        return false;
    }
    // CRM-6063 - End
    
    public Static Integer getBLAIframeHeight(Id brokerAccId) {
        Integer height = 1200;
        Integer oneOfficeHeight = Integer.valueOf(Label.Opcity_BLA_Office_Height);
        if (oneOfficeHeight > 0) {
            height = 280;
            Integer officeCount = [SELECT Count() FROM Account WHERE Id IN (SELECT Child_Account__c FROM Account_Relationship__c 
                        WHERE Parent_Account__c = :brokerAccId AND Active__c=true AND Child_Account__r.Type='Realtor Office' AND 
                        Parent_Account__r.Type='Broker')];
             if (officeCount > 0) {
                 height = height + (officeCount * oneOfficeHeight);
             }
         }
         return height;
    }
    public OPCityAccountSummaryHelper(ApexPages.StandardController stdController){
        // CRM-6063 - Start
        isOpcityBlaTeamUser = isBLAUser();
        isOpcityCoreTeamUser = isCoreUser();
        blaIframeHeight = 280;
        // CRM-6063 - End
        
        loadDeatils=false;
        modifyAddress = 'false';
        acctabactive = 'block';
        qqtabactive = 'none';
        allMarkets = false;
        boolean loadAccount360 = true;
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
            blaIframeHeight = getBLAIframeHeight(acct.Id);
       
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
            Account acc=[select id, BLA__c ,Core__C ,Office_Agent_BLA__c, party_Id__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c,Franchise_Type__c,Basic_Optout__c,Credit_Risk__c,Past_Due__c,Phone,Billing_Preference__c,Email_Address__c,Type,ResidentialBrandPPL__c,ResidentialLeadPPL__c,ResidentialAMLC__c,LandAMLC__c,RentalAMLC__c,MLS_Set_Id__c,Advertiserid__c from Account where id=:acct.id limit 1][0];
            accountObj = acc;                               
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
            Monthlyspend = 0;
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);
            marketInformation = new List<Inventory_Account__c>();
            marketInformationsf = [select id,Name,Number_of_Listings__c,
                                   Having_waitlist__c,Listing__c,Form__c,Buyers_Side__c,
                                   Office__c,Number_of_Buy_Side_Transactions__c,Waitlist_Type__c,Inventory_Data__r.Opcity_MSA__c,
                                   Inventory_Data__r.name,Inventory_Data__r.Median_Market_Price__c,
                                   Inventory_Data__r.Promotion__c,Inventory_Data__r.City__c,Inventory_Data__r.State__c,
                                   Inventory_Data__r.Promo_Code__c,Inventory_Data__r.Is_available__c,Has_Assets__c, Has_Assets_LE__c, waitlist_product_type__c, Waitlist_Type_LE__c
                                   FROM Inventory_Account__c 
                                   WHERE Account__c =:acct.id
                                   AND (Having_waitlist__c = TRUE OR Listing__c = TRUE OR Form__c = TRUE OR Buyers_Side__c = TRUE OR Office__c = TRUE OR Has_Assets__c = TRUE OR Has_Assets_LE__c = TRUE OR waitlist_product_type__c != null)];//CRM-3026 - Added This line filter to take only available markets
            Set<String> markets = new Set<String>(); // CRM-5389
            for(Inventory_Account__c intrestedM : marketInformationsf){
                marketInformation.add(intrestedM);
                strzips.add(intrestedM.Inventory_Data__r.name);
            }
            protectedMarkets = InventorySearch.getProtectedMarketList(markets);       
            system.debug('@@@zipcodes_cpq***'+strzips);
            marketInfoStringJSON=JSON.serialize(marketInformation);
            System.debug('marketInfoStringJSON'+marketInfoStringJSON);
            waitlistItemMap=new Map<String,String>();
            for(Waitlist_Item__c wl:[select product__r.productcode, status__c,Total_MAX_Monthly_Pre_Auth_Spend__c,Market__c from Waitlist_Item__c where Account__c=:acct.id and status__c IN('Active','Expired') and  Market__c in: strzips]){
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
        for(Asset asst:[select id,Product2.name,Product2.Inventory__c, Product_code__c, Fulfillment_Status__c from Asset where  Accountid=:acct.id AND status = 'Active' AND Asset_Type__c = 'Parent']){
            if(asst.Product2.name!=null && !stringOfProducts.contains(asst.Product2.name)){
                stringOfProducts+='; '+asst.Product2.name;}
        }
        // CRM-5867 - Opcity Product
        if ((accountObj.Type == 'Broker' && accountObj.BLA__c == 'Yes') || (accountObj.Type == 'Realtor Agent' && (accountObj.Office_Agent_BLA__c == 'BLA Confirmed' || accountObj.Office_Agent_BLA__c == 'BLA Unconfirmed'))){
            stringOfProducts+='; '+'Opcity-BLA';
        }
        if((accountObj.Type == 'Broker' && accountObj.Core__C == 'Yes') || ((accountObj.Type == 'Realtor Agent' && accountObj.Office_Agent_BLA__c == 'Core'))) {
            stringOfProducts+='; '+'Opcity-Core';
        }
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
    
    public PageReference updateAddress(){
        system.debug('Inside OpenAddressModifier:: '+ acct);
        modifyAddress = 'false';
        update acct;
        return null;
    }
    // CPQ Upgrade oAuth changes to QQ Url
    @Testvisible private void setQuickQuoteUrl(Account accDetails) {
        OpcityCoreQQURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/authorize?response_type=code';
        OpcityCoreQQURL = OpcityCoreQQURL + '&client_id='+Label.CPQ_Client_Id;
        OpcityCoreQQURL = OpcityCoreQQURL + '&redirect_uri=https://'+QuickQuote__c.getOrgDefaults().BMInstance__c+'.bigmachines.com/admin/oauth2/salesforce/oauth_callback.jsp&state=/commerce/new_equipment/products/model_configs.jsp?';
        OpcityCoreQQURL = OpcityCoreQQURL + 'segment=realtor%26product_line=nonInventoryProducts%26model=listingEnhancements%26_from_punchin=true%26_variable_name_punchin=true%26nonInvPunchIn_quickQuote=true';
        OpcityCoreQQURL = OpcityCoreQQURL + '%26product=OPCITYCORE';
        OpcityCoreQQURL = OpcityCoreQQURL +  '%26accountType='+EncodingUtil.urlEncode(accDetails.Type,'UTF-8');
        OpcityCoreQQURL = OpcityCoreQQURL +  '%26accountID='+accDetails.Id;
        OpcityCoreQQURL = OpcityCoreQQURL +  '%26relationshipType=Parent/Child';
        /*OpcityBLAQQURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/authorize?response_type=code';
        OpcityBLAQQURL = OpcityBLAQQURL + '&client_id='+Label.CPQ_Client_Id;
        OpcityBLAQQURL = OpcityBLAQQURL + '&redirect_uri=https://'+QuickQuote__c.getOrgDefaults().BMInstance__c+'.bigmachines.com/admin/oauth2/salesforce/oauth_callback.jsp&state=/commerce/new_equipment/products/model_configs.jsp?';
        OpcityBLAQQURL = OpcityBLAQQURL + 'segment=realtor%26product_line=nonInventoryProducts%26model=listingEnhancements%26_from_punchin=true%26_variable_name_punchin=true%26nonInvPunchIn_quickQuote=true';
        OpcityBLAQQURL = OpcityBLAQQURL + '%26product=OPCITYBLA';
        OpcityBLAQQURL = OpcityBLAQQURL +  '%26accountType='+EncodingUtil.urlEncode(accDetails.Type,'UTF-8');
        OpcityBLAQQURL = OpcityBLAQQURL +  '%26accountID='+accDetails.Id;
        OpcityBLAQQURL = OpcityBLAQQURL +  '%26relationshipType=Parent/Child';*/
    }
}