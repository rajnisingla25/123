global class InventorySearch {

    /************** Created by Arun Sharma **************************************
     ********   For Move Inc Leapfrog Project ************************************
     *****************  Inventory Controller *****************************
     ********* Created on April 2015 ********************************************* 
     ********** Program calls Wailtist wbservice , returns JSON back to VF WL page****/
    
    public List<String> protectedMarkets {get; set;}        // CRM-5389
    public List<String> transitionMarkets {get; set;}       // CRM-6310
    private final Account acct; 
    public List < Invlist > WLs;
    public List < Invlist > MyInvSetList;
    public string Sendjson {get;set;}
    private String mParty_Id;
    public string mPhone {get;set;}
    public string MyUserid {get;set;}
    public string MyUserName {get;set;}
    public string MyUserName1 {get;set;}
    public string MyUserEmail {get;set;}
    public string MyUserProfileName {get;set;}
    public string MyUserProfileManagerId {get;set;}
    public string MyUserProfileId {get;set;}
    public string MyUserLocale {get;set;}
    public string MyUserTimezone {get;set;}
    public string MyUserFullName {get;set;}
    public integer intWhichPageisCalling = 1; // 1 is Account Waitlist ,2 is My Wailist , 3 is My Team View , 4 is Top10 
    public string mReservationId {get;set;}
    public string mMyMethod {get;set;}
    public string MyTransactionId {get;set;}
    public string MyLineItemId {get;set;}
    public string MyProductName {get;set;}
    public string MyProductType {get;set;}
    public string MyProductSize {get;set;}
    public string MyInventoryPool {get;set;}
    public string MyMarketName {get;set;}
    public string MyPartyId {get;set;}
    public string MyLeadType {get;set;}
    public string MyMarketState {get;set;}
    public string MyReservedQty {get;set;}
    public string MyMarketId {get;set;}
    public string MyLockReleaseDate {get;set;}
    public string MyInventorystatus {get;set;}
    public string MyCreatedDate {get;set;}
    public string MyUpdatedDate {get;set;}
    public string MyReservedBy {get;set;}
    Public String searchURL {get;set;}
    Public string selectedRadius {get;set;}
    public string mInputState;
    public string mState;
    public string mProduct;
    public string mCounty;
    public string stateUrl {get;set;}
    public String MyValue1 {get;set;}
    public String inputText1 {get;set;}
    public String[] urlString;
    
   // public InventorySecurity__c obj = InventorySecurity__c.getvalues('InventorySecurity');
    public list<Invlist> bundleZipList{get;set;}
    
    
    private string mInputValue;
    private string mToken;
    private string mMarket = '94010';
    private string mMarkettype = 'Zip Code';
    private string mAccountId;
    private string mStatus;
    private string mDegree;
    private string mLeadroutingtype;
    private string mSlotsize;
    private string mMarketspend;
    private string mJson;
    private string mnotes;
    private string mqtyinterested;
    private string moperation;
    private string mMyOrderBy = 'OrderByDesc=part_numbers';
    private string mMyFilter = '';
    private string mMyLimit = 'Take=1000';
    private string mMyPageNo = 'Skip=0';
    private string mMyPool = 'postalcodes';
    private string mWaitlistStatus = '';
    public string mFilterType = 'Zip Code';
    private string mAccountName;
    private string mInputType;
    private string mMyPostalCode = '94536';
    
    public void setPhone(String newvalue) {mPhone = newvalue;}
    public string getPhone() {return mPhone;}
    public void setReservation(String newvalue) {mReservationId = newvalue;}
    public string getReservation() {return mReservationId; }
    public void setMyMethod(String newvalue) {mMyMethod = newvalue;}
    public string getMyMethod() {return mMyMethod;}
    public void setToken(String newvalue) {mToken = newvalue;}
    public string getToken() {return mToken;}
    public void setDegree(String newvalue) {mDegree = newvalue;}
    public string getDegree() {return mDegree;}
    public void setSlotSize(String newvalue) {mSlotSize = newvalue;}
    public string getSlotSize() {return mSlotSize;}
    public void setLeadRoutingType(String newvalue) {mLeadRoutingType = newvalue;}
    public string getLeadRoutingType() {return mLeadRoutingType;}
    public void setStatus(String newvalue) {mStatus = newvalue;}
    public string getStatus() {return mStatus;}
    public void setJson(String newvalue) {mJson = newvalue;}
    public string getJson() {return mJson;}
    public void setAccountId(String newvalue) {mAccountId = newvalue;}
    public string getAccountId() {return mAccountId;}
    public void setNotes(String newvalue) {mNotes = newvalue;}
    public string getNotes() {return mNotes;}
    public void setqtyinterested(String newvalue) { mqtyinterested = newvalue;}
    public string getqtyinterested() {return mqtyinterested; }
    public void setoperation(String newvalue) { moperation = newvalue;}
    public string getoperation() {return moperation;}
    public string getMyOrderBy() {return mMyOrderBy;}
    public void setMyOrderBy(String newvalue) { mMyOrderBy = newvalue;}
    public string getMyFilter() { return mMyFilter;}
    public void setMyFilter(String newvalue) {mMyFilter = newvalue;}
    public string getMyLimit() { return mMyLimit;}
    public void setMyLimit(String newvalue) {mMyLimit = newvalue;}
    public String getWaitlistStatus() { return mWaitlistStatus; }
    public String getAccountName() {return mAccountName;}
    
    public decimal listingCount{get;set;}
    public decimal multipleImpressionVal{get;set;}
    
    public List < SelectOption > getFilterList() {
        System.debug('in filterlist'+mproduct);
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('postal_code', 'Zip Code'));
        options.add(new SelectOption('city', 'City'));
        options.add(new SelectOption('county', 'County'));
        options.add(new SelectOption('state', 'State'));
        //if(mproduct == 'LOCALEXPERT'){
        options.add(new SelectOption('neighborhood', 'Neighborhood'));
      //  }
        return options;

    }


    public List < SelectOption > getStates() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('al', 'Alabama'));
        options.add(new SelectOption('ak', 'Alaska'));
        options.add(new SelectOption('az', 'Arizona'));
        options.add(new SelectOption('ar', 'Arkansas'));
        options.add(new SelectOption('ca', 'California'));
        options.add(new SelectOption('co', 'Colorado'));
        options.add(new SelectOption('ct', 'Connecticut'));
        options.add(new SelectOption('de', 'Delaware'));
        options.add(new SelectOption('DC', 'District of Columbia'));
        options.add(new SelectOption('fl', 'Florida'));
        options.add(new SelectOption('ga', 'Georgia'));
                options.add(new SelectOption('gu', 'Guam'));

        options.add(new SelectOption('hi', 'Hawaii'));
        options.add(new SelectOption('id', 'Idaho'));
        options.add(new SelectOption('il', 'Illinois'));
        options.add(new SelectOption('in', 'Indiana'));
        options.add(new SelectOption('ia', 'Iowa'));
        options.add(new SelectOption('ks', 'Kansas'));
        options.add(new SelectOption('ky', 'Kentucky'));
        options.add(new SelectOption('la', 'Louisiana'));
        options.add(new SelectOption('me', 'Maine'));
        options.add(new SelectOption('md', 'Maryland'));
        options.add(new SelectOption('ma', 'Massachusetts'));
        options.add(new SelectOption('mi', 'Michigan'));
        options.add(new SelectOption('mn', 'Minnesota'));
        options.add(new SelectOption('ms', 'Mississippi'));
        options.add(new SelectOption('mo', 'Missouri'));
        options.add(new SelectOption('mt', 'Montana'));
        options.add(new SelectOption('ne', 'Nebraska'));
        options.add(new SelectOption('nv', 'Nevada'));
        options.add(new SelectOption('nh', 'New Hampshire'));
        options.add(new SelectOption('nj', 'New Jersey'));
        options.add(new SelectOption('nm', 'New Mexico'));
        options.add(new SelectOption('ny', 'New York'));
        options.add(new SelectOption('nc', 'North Carolina'));
        options.add(new SelectOption('nd', 'North Dakota'));
        options.add(new SelectOption('oh', 'Ohio'));
        options.add(new SelectOption('ok', 'Oklahoma'));
        options.add(new SelectOption('or', 'Oregon'));
        options.add(new SelectOption('pa', 'Pennsylvania'));
        options.add(new SelectOption('PR', 'Puerto Rico'));
        options.add(new SelectOption('ri', 'Rhode Island'));
        options.add(new SelectOption('sc', 'South Carolina'));
        options.add(new SelectOption('sd', 'South Dakota'));
        options.add(new SelectOption('tn', 'Tennessee'));
        options.add(new SelectOption('tx', 'Texas'));
        options.add(new SelectOption('ut', 'Utah'));
                options.add(new SelectOption('vi', 'Virgin Islands'));

        options.add(new SelectOption('vt', 'Vermont'));
        options.add(new SelectOption('va', 'Virginia'));
        options.add(new SelectOption('wa', 'Washington'));
        options.add(new SelectOption('wv', 'West Virginia'));
        options.add(new SelectOption('wi', 'Wisconsin'));
        options.add(new SelectOption('wy', 'Wyoming'));
        string state = options[0].getValue();
        return options;
    }
    public List < SelectOption > getProducts() {

        List < SelectOption > options = new List < SelectOption > ();
        String account360Products = System.Label.Account360Products;  //Local Expert MRB
        //CRM-5806
        for(InventorySearchProducts__c setting : InventorySearchProducts__c.getAll().values()){
                if(setting.Active__c == true && Setting.name != 'LOCALEXPERT' )
                options.add(new SelectOption(setting.name, setting.InventoryProductName__c)); 
                if(account360Products.contains('localexpert') && setting.Active__c == true && Setting.name == 'LOCALEXPERT')
                { 
                options.add(new SelectOption(setting.name, setting.InventoryProductName__c)); //DAP 2.0 Sprint 1 MRB
                }          
        }
        //options.add(new SelectOption('COBROKE', 'COBROKE'));
        //options.add(new SelectOption('HANDRAISER', 'HANDRAISER'));
        //options.add(new SelectOption('HOMESRCH', 'HOMESRCH'));
        //options.add(new SelectOption('DIGITALAGENT', 'DAP'));
        //options.add(new SelectOption('Turbo', 'TURBO'));
        //options.add(new SelectOption('SELLERLEAD', 'SELLERLEAD'));
        //options.add(new SelectOption('SELLERLEADBUNDLE', 'SELLERLEADBUNDLE'));
        //if(account360Products.contains('localexpert')){ options.add(new SelectOption('LOCALEXPERT','LOCALEXPERT')); }//DAP 2.0 Sprint 1 MRB
        return options;

    }

    public List < SelectOption > getTableFilterList() {

        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('Asset', 'Asset'));
        options.add(new SelectOption('Account Listings', 'Account Listings'));
        options.add(new SelectOption('', ''));
        return options;

    }

    public String getFilterType() {return mFilterType;}
    public void setFilterType(String filtertype) {this.mFilterType = filtertype;}
    public List < SelectOption > getInputList() {

        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        return options;

    }
    public String getInputType() {return mInputType;}
    public void setInputType(String newvalue) {this.mInputType = newvalue;}

    public String getInputValue() {

        if (mInputValue == null) {

            mInputValue = mWaitlistStatus;
        }
        mInputValue = mInputValue.replace('%20', ' ');
        return mInputValue;
    }

    public String getState() {
        mInputState = mState;
        return mInputState;
    }

    public String SetState(String newvalue) {

        this.mState = newvalue;
        System.debug('mState ::' + mState);
        return mState;

    }
    
    public String getProduct() {return mProduct;}
    public String SetProduct(String newvalue) {
        mProduct = newvalue;
        return mProduct;
    }

    public String getCounty() {return mCounty;}
    public String SetCounty(String newvalue) {

        if (newvalue.containsIgnoreCase(' County')) {
            newvalue = newvalue.removeEndIgnoreCase(' County');
        }
        this.mCounty = newvalue;
        System.debug('mCounty ::' + mCounty);
        return mCounty;
    }

    public void setInputValue(String newvalue) {

        this.mInputValue = newvalue;
        System.debug('New Value IS' + newvalue);

        if (newvalue != null) {
            System.debug('Input Value is ' + mInputValue);

            this.mInputValue = AssignFilterValue(mInputValue);
        }

    }
    public List < SelectOption > getStateVal() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('50', '50'));
        return options;
    }

    public List < SelectOption > getItems() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('0', '0'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('15', '15'));
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('25', '25'));
        options.add(new SelectOption('30', '30'));
        options.add(new SelectOption('35', '35'));
        options.add(new SelectOption('40', '40'));
        options.add(new SelectOption('45', '45'));
        options.add(new SelectOption('50', '50'));
        return options;
    }
    
     
    public InventorySearch() {
        Waitlist_Urls__c PLIUrls = Waitlist_Urls__c.getValues('InventorySearchNew');
        
        
        System.Debug('Data Controller Called');
        if (!test.isRunningTest()) {
            searchUrl = PLIUrls.URL__c;
            //searchUrl='https://uat-es-is.api.move.com';

        } else {
            searchUrl = 'https://qa-es-is.api.move.com';
        }

        Account acct_temp;
        string MYId;

        selectedRadius = '0';
        mMyMethod = 'Put';

        StoreMainParameters();
        transitionMarkets = new List<String>();      // CRM-6310
    }

   
    public void StoreMainParameters() {

        try {
            
            listingCount=1;
            multipleImpressionVal=1000;
            
            MyUserid = Userinfo.getUserId();
            MyUserName = Userinfo.getusername();
            MyUserEmail = Userinfo.getuseremail();
            MyUserName1 = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
            MyUserFullName = Userinfo.getName();
            MyUserProfileId = Userinfo.getProfileId();
            MyUserLocale = Userinfo.getLocale();

            Profile p = [select name from Profile where id =: UserInfo.getProfileId()];

            MyUserProfileName = p.name;

            intWhichPageisCalling = 2;
            mMYFilter = 'Owner_name =' + MyUserName;
            
        } catch (exception e) {

            System.debug('error occured in setting user profile data' + e.getMessage());

        } 
 
    }
    
    public List < Invlist > accountwaitlist {

        get {
            if (accountwaitlist == null) {
                try {
                    List < Invlist > WLs;

                    String[] orderBys = new String[] {
                        'token asc'
                    };
                    System.debug('orderbys ' + orderbys);

                    try {
                        integer lock_party_id = 1245;
                        string mydate = '2015-07-18T01:13:28.0000000+00:00';
                        Date lock_release_date = Date.valueOf(mydate);
                        String transaction_id = '106168';
                        String ReservationID = '160';
                        string operation;
                        string message1;

                        system.debug('*****Lock Inventory status Before Reservation Item Init*****');

                        // Removed word xmlns because of big length , start with Oracle

                        system.debug('*****Lock Inventory status Init*****');

                    } catch (Exception e) {

                        System.debug('An exception occurred during Web Service Call  Lock Inventory: ' + e.getMessage());

                    }

                    accountwaitlist = GetWaitlistfromWebService();
                    System.debug('accountwaitlist  array' + accountwaitlist);


                    if (accountwaitlist == null) {

                        System.debug('accountwaitlist Arun SOA FAILED . fetching temp array');

                    }

                    System.debug('accountwaitlist Arun ' + accountwaitlist);
                } catch (exception e) {

                    System.debug('An exception occurred: ' + e.getMessage());

                    // do nothing now , will add 
                    String[] orderBys = new String[] {
                        'token asc'
                    };
                }

            }
            return accountwaitlist;
        }

        set;

    }
   
    public void setWaitlistStatus(String WaitlistStatus) {

        if (WaitlistStatus != null) {

            this.mWaitlistStatus = WaitlistStatus;
            this.mInputValue = WaitlistStatus;

            System.debug('Value before Replace' + mWaitlistStatus);

            this.mWaitlistStatus = mWaitlistStatus.replace(' ', '%20');

            System.debug('Value after Replace' + mWaitlistStatus);

            string retstring = AssignFilterValue(mWaitlistStatus);

        }

    }

    public string AssignFilterValue(String MyValue) {

        if (MyValue != null) {

            MyValue = MyValue.replace(' ', '%20');
            System.debug('mMyFilter in Set is ' + mMyFilter);
            mMyFilter = '';

            if (MyValue != null) {

                System.debug('mParty_Id ' + mParty_Id);
                if (mParty_Id != null) {

                    mMyFilter = 'party_id=' + mParty_Id;

                } else {

                }

                if ('Waitlist Status'.equals(mFilterType)) {

                    mMyFilter = mMyFilter + '&waitlist_status=' + MyValue + '&waitlist_type=Hot';

                } else if ('Waitlist Type'.equals(mFilterType)) {

                    mMyFilter = mMyFilter + '&waitlist_type=' + MyValue;


                } else if (mFilterType == 'No of Records') {

                    mMyLimit = 'Take=' + MyValue;

                } else if (mFilterType == 'Inventory Pool') {

                    mMyPool = MyValue;

                } else if (mFilterType == 'Page No') {

                    mMyPageNo = MyValue;

                    mMyPageNo = 'Skip=' + MyValue;

                } else if (mFilterType == 'Zip Code') {

                    System.debug('mFilterType in SETWaitlist' + mFilterType + ' MyValue' + MyValue);
                    mMyPostalCode = MyValue;
                    mMyPool = 'postalcodes';

                } else if (mFilterType == 'City') {

                    System.debug('mFilterType in SETWaitlist' + mFilterType + ' MyValue' + MyValue);
                    mMyPostalCode = MyValue;
                    mMyPool = 'city';

                } else if (mFilterType == 'County') {

                    System.debug('mFilterType in SETWaitlist' + mFilterType + ' MyValue' + MyValue);
                    mMyPostalCode = MyValue;
                    mMyPool = 'county';

                } else {

                }

            }


            System.debug('MyFilter SetWaitlist Item is = ' + mMyFilter);
        }

        return MyValue;

    }

    public pageReference makeSOACallforGet() {

        try {
          /*  if(obj.expiration_date_time__c == null || system.now() >= obj.expiration_date_time__c.addseconds(-600)){
              InventorySecurityTokenHelper.getSecurityToken();
            } */
            accountwaitlist = GetWaitlistfromWebService();
            this.accountwaitlist = accountwaitlist;

        } catch (exception e) {
            // do nothing now , will add 
            System.debug('An exception occurred: ' + e.getMessage());

        }

        return null;

    }

    public List < SelectOption > getWaitlistStatusItems() {

        List < SelectOption > options = new List < SelectOption > ();

        options.add(new SelectOption('', ''));

        System.debug('mFilterType  in getWaitlistStatusItems' + mFilterType);

        if (mFilterType != '') {

            if ('Waitlist Status'.equals(mFilterType)) {

                options.add(new SelectOption('Pending Configuration', 'Pending Configuration'));
                options.add(new SelectOption('Pending Pre-Auth', 'Pending Pre-Auth'));
                options.add(new SelectOption('Pending Inventory', 'Pending Inventory'));
                options.add(new SelectOption('Fulfilled', 'Fulfilled'));

            } else if ('Waitlist Type'.equals(mFilterType)) {
                options.add(new SelectOption('Hot', 'Hot'));
                options.add(new SelectOption('Warm', 'Warm'));
            } else if ('Inventory Available Flex'.equals(mFilterType)) {
                options.add(new SelectOption('Greater than Zero', 'Greater than Zero'));
                options.add(new SelectOption('Greater than 1', 'Greater than 1'));
                options.add(new SelectOption('Greater than 5', 'Greater than 5'));
                options.add(new SelectOption('Greater than 10', 'Greater than 10'));
                options.add(new SelectOption('Greater than 25', 'Greater than 25'));
                options.add(new SelectOption('Greater than 50', 'Greater than 50'));


            } else if ('Inventory Available Fast'.equals(mFilterType)) {
                options.add(new SelectOption('Greater than Zero', 'Greater than Zero'));
                options.add(new SelectOption('Greater than 1', 'Greater than 1'));
                options.add(new SelectOption('Greater than 5', 'Greater than 5'));
                options.add(new SelectOption('Greater than 10', 'Greater than 10'));
                options.add(new SelectOption('Greater than 25', 'Greater than 25'));
                options.add(new SelectOption('Greater than 50', 'Greater than 50'));


            } else if ('Presales Available Flex'.equals(mFilterType)) {
                options.add(new SelectOption('Greater than Zero', 'Greater than Zero'));
                options.add(new SelectOption('Greater than 1', 'Greater than 1'));
                options.add(new SelectOption('Greater than 5', 'Greater than 5'));
                options.add(new SelectOption('Greater than 10', 'Greater than 10'));
                options.add(new SelectOption('Greater than 25', 'Greater than 25'));
                options.add(new SelectOption('Greater than 50', 'Greater than 50'));


            } else if ('Presales Available Fast'.equals(mFilterType)) {
                options.add(new SelectOption('Greater than Zero', 'Greater than Zero'));
                options.add(new SelectOption('Greater than 1', 'Greater than 1'));
                options.add(new SelectOption('Greater than 5', 'Greater than 5'));
                options.add(new SelectOption('Greater than 10', 'Greater than 10'));
                options.add(new SelectOption('Greater than 25', 'Greater than 25'));
                options.add(new SelectOption('Greater than 50', 'Greater than 50'));

            } else if ('Product'.equals(mFilterType)) {
                options.add(new SelectOption('Connection for Co-Brokerage', 'Connection for Co-Brokerage'));
                options.add(new SelectOption('Feature Home', 'Feature Home'));
                options.add(new SelectOption('FAC', 'FAC'));
                options.add(new SelectOption('DAP', 'DAP'));
                options.add(new SelectOption('Tigerlead', 'Tigerlead'));


            } else if ('Assigned AE'.equals(mFilterType)) {
                options.add(new SelectOption('hriggio', 'hriggio'));
                options.add(new SelectOption('qdinh', 'qdinh'));
                options.add(new SelectOption('blippold', 'blippold'));
                options.add(new SelectOption('runassigned', 'runassigned'));
                options.add(new SelectOption('jmcgough', 'jmcgough'));
                options.add(new SelectOption('khastings', 'khastings'));

            } else if ('Input AE'.equals(mFilterType)) {
                options.add(new SelectOption('hriggio', 'hriggio'));
                options.add(new SelectOption('qdinh', 'qdinh'));
                options.add(new SelectOption('blippold', 'blippold'));
                options.add(new SelectOption('runassigned', 'runassigned'));
                options.add(new SelectOption('jmcgough', 'jmcgough'));
                options.add(new SelectOption('khastings', 'khastings'));



            } else if ('No of Records'.equals(mFilterType)) {
                options.add(new SelectOption('10', '10'));
                options.add(new SelectOption('25', '25'));
                options.add(new SelectOption('50', '50'));
                options.add(new SelectOption('100', '100'));
                options.add(new SelectOption('500', '500'));
                options.add(new SelectOption('1000', '1000'));

            } else if ('Inventory Pool'.equals(mFilterType)) {
                options.add(new SelectOption('GetAllReservations', 'GetAllReservations'));
                options.add(new SelectOption('GetPendingAllocation', 'GetPendingAllocation'));
                options.add(new SelectOption('GetSalesEventPool', 'GetSalesEventPool'));
            } else if ('Page No'.equals(mFilterType)) {
                options.add(new SelectOption('1', '1'));
                options.add(new SelectOption('2', '2'));
                options.add(new SelectOption('3', '3'));
                options.add(new SelectOption('3', '3'));
                options.add(new SelectOption('5', '5'));
                options.add(new SelectOption('6', '6'));
                options.add(new SelectOption('7', '7'));
                options.add(new SelectOption('8', '8'));
                options.add(new SelectOption('9', '9'));
                options.add(new SelectOption('10', '10'));
            }

        }


        return options;

    }

    public pageReference submit() {

        System.debug('Submit Call');
        System.debug('Reached Submit Function' + 'Sendjson' + Sendjson);
        //  GenerateAjax(Sendjson);
        return null;
    }

    public pageReference SetPageSize() {

        mMyLimit = 'Take=10';
        return null;
    }

    public List < Invlist > GetWaitlistfromWebService() {
            String myjson;
            String myUrl;
            
            system.debug('-- mProduct -->'+mProduct);
            system.debug('-- mFilterType -->'+mFilterType);
            
            List < Invlist > InvList1 = new List < Invlist > ();
            List < WLJson > WLJsonlist = new List < WLJson > ();
            List < string > Assetlist = new List < string > ();

            integer i = 0;

            HttpRequest req = new HttpRequest();
            Http http = new Http();
            // set the method
            req.setMethod('GET');

            
            System.debug('mMyPool' + mMyPool + 'mMyPostalCode' + mMyPostalCode);

            // Convert to Lower Case mMyPostalCode

            mMyPostalCode = mMyPostalCode.toLowerCase();

            if (mProduct == null) {

                mProduct = 'COBROKE';
            }

            if (mMyPool == 'postalcodes') {

                myUrl = searchUrl + '/postalcodes/' + mMyPostalCode + '?part_numbers=' + mProduct + '&format=json';

            }

            else {
                myUrl = searchUrl + '/postalcodes?format=json';
                myUrl = searchUrl + '/postalcodes/94536?format=json';

            }

            myUrl = myUrl + '&' + mMyLimit;
            myUrl = myUrl + '&' + mMyOrderBy;
            myUrl = myUrl + '&' + mMyPageNo;

            System.Debug('myUrl' + myUrl);
            req.setEndpoint(myUrl);
            req.setHeader('Accept', 'application/json');

            ///////////////////////////Inventory Search filters changes ///////////////////////////

            if (mFilterType == null) {

                mFilterType = 'postalcodes';

            }

            System.debug('mFilterType' + mFilterType + 'mMyPostalCode' + mInputvalue);

            // Convert to Lower Case mMyPostalCode

            mMyPostalCode = mMyPostalCode.toLowerCase();

            if (mFilterType == 'postal_code') {

                if (mProduct == 'COBROKE') {

                    myUrl = searchUrl + '/postalcodes/' + mInputvalue + '?Radius=+' + selectedRadius + '&format=json';

                } else if(mProduct == 'LOCALEXPERT'){
                    
                    myUrl = searchUrl + '/postalcodes/' + mInputvalue + '?part_numbers=' + mProduct + '&Radius=+' + selectedRadius +'&format=json';

                
                }else {

                    myUrl = searchUrl + '/postalcodes/' + mInputvalue + '?part_numbers=' + mProduct + '&format=json';

                }

            } else if (mFilterType == 'city' ) {

                string county;
                string state;
                string city;
                string[] split = mMyPostalCode.split('/');

                System.debug('Arun' + split + mMyPostalCode);

                try {

                    mCounty = mCounty.toLowerCase();
                    myUrl = searchUrl + '/country/usa/states/';
                    myUrl = myUrl + mState;
                    myUrl = myUrl + '/counties/' + mCounty;
                    myUrl = myUrl + '/cities/' + inputText1 + '?part_numbers=' + mProduct + '&format=json';
                    system.debug('Input text --> '+inputText1);
                    system.debug('MRB myurl --> '+myUrl);

                } catch (exception e) {

                    myUrl = searchUrl + '/country/usa/states/ca/counties/san%20mateo/cities/menlo%20park?format=json';
                }

             } else if (mFilterType == 'neighborhood' ) {

                string county;
                string state;
                string city;
                string[] split = mMyPostalCode.split('/');

                System.debug('Arun' + split + mMyPostalCode);

                try {

                    mCounty = mCounty.toLowerCase();
                    myUrl = searchUrl + '/country/usa/states/';
                    myUrl = myUrl + mState;
                    myUrl = myUrl + '/counties/' + mCounty;
                    myUrl = myUrl + '/cities/' + mInputvalue+'-'+mCounty + '?part_numbers=' + mProduct + '&format=json';
                    system.debug('mInputvalue --> '+mInputvalue);
                    system.debug('MRB myurl --> '+myUrl);

                } catch (exception e) {

                    myUrl = searchUrl + '/country/usa/states/ca/counties/san%20mateo/cities/menlo%20park?format=json';
                }

             }
            else if (mFilterType == 'county') {

                string county;
                string state;
                string city;
                string[] split = mMyPostalCode.split('/');

                try {

                    System.debug(county + state + city);

                    if (mCounty == null) {

                        mCounty = mMyPostalCode;

                    }

                    mCounty = mCounty.toLowerCase();
                    myUrl = searchUrl + '/country/usa/states/';
                    myUrl = myUrl + mState;
                    myUrl = myUrl + '/counties/' + mCounty;
                    myUrl = myUrl + '?part_numbers=' + mProduct + '&format=json';

                } catch (exception e) {

                    myUrl = searchUrl + '/country/usa/states/ca/counties/san%20mateo/?format=json';
                }

            } else if (mFilterType == 'state') {

                string county;
                string state;
                string city;
                string[] split = mMyPostalCode.split('/');

                try {

                    System.debug(county + state + city);

                    if (mState == null) {

                        mState = mMyPostalCode;

                    }

                    mState = mState.toLowerCase();
                    mState = mState.trim();
                    myUrl = searchUrl + '/country/usa/states/';
                    myUrl = myUrl + mState;
                    myUrl = myUrl + '?part_numbers=' + mProduct + '&format=json&include_inventory_items=true';

                } catch (exception e) {

                    myUrl = searchUrl + '/country/usa/states/ca/counties/san%20mateo/?format=json';
                }

            }
            
            myUrl = myUrl.replace(' ', '%20');
          
            req.setEndpoint(myUrl);
            req.setHeader('Accept', 'application/json');

            ////////////////////////////////////Inventory Search filters changes end///////////////////////////////////////////////////////////

            try {

                HTTPResponse resp;
                system.debug('URL --> '+myUrl);
                system.debug('req -->'+req.getbody());
               // req.setHeader('Authorization','Bearer '+obj.access_token__c);
                if (!Test.isRunningTest()) {
                    resp = http.send(req);
                    myjson = resp.getBody();
                    system.debug( '--------------'+myjson);
                } else {

                    myjson = '{"request":{"__type":"eai.inventory.search.api.ServiceModel.RequestDto.GetInventoriesByPostalCodes, eai.inventory.search.api.ServiceModel","postal_codes":["94536"],"radius":0,"part_numbers":["COBROKE"]},"links":[{"href":"' + searchUrl + '/country/usa/states/ca/counties/alameda/cities/sunol?part_numbers=COBROKE","rel":"inventory_by_city","method":"POST"},{"href":"' + searchUrl + '/country/usa/states/ca/counties/alameda?part_numbers=COBROKE","rel":"inventory_by_county","method":"POST"},{"href":"' + searchUrl + '/country/usa/states/ca?part_numbers=COBROKE","rel":"inventory_by_state","method":"POST"},{"href":"' + searchUrl + '/country/usa/states/ca/counties/alameda/cities/fremont?part_numbers=COBROKE","rel":"inventory_by_city","method":"POST"},{"href":"' + searchUrl + '/country/usa/states/ca/counties/alameda/cities/union%20city?part_numbers=COBROKE","rel":"inventory_by_city","method":"POST"},{"href":"' + searchUrl + '/country/usa/states/ca/counties/alameda/cities/newark?part_numbers=COBROKE","rel":"inventory_by_city","method":"POST"}],"inventory_aggregates_by_geoarea":[{"area":"94536","area_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","market_type":"Postal Code","product_size":"Full","lead_routing":"Fast","quantity":100,"allocated":0,"available":0,"presale":0,"reserved":0,"reserved_presale":0,"sold":0,"party_allocated":0,"party_available":0,"party_presale":0,"party_reserved":0,"party_reserved_presale":0,"party_sold":0},{"area":"94536","area_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","market_type":"Postal Code","product_size":"Full","lead_routing":"Flex","quantity":100,"allocated":0,"available":0,"presale":0,"reserved":0,"reserved_presale":0,"sold":0,"party_allocated":0,"party_available":0,"party_presale":0,"party_reserved":0,"party_reserved_presale":0,"party_sold":0},{"area":"94536","area_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","market_type":"Postal Code","product_size":"Half","lead_routing":"Fast","quantity":100,"allocated":0,"available":0,"presale":0,"reserved":0,"reserved_presale":0,"sold":0,"party_allocated":0,"party_available":0,"party_presale":0,"party_reserved":0,"party_reserved_presale":0,"party_sold":0},{"area":"94536","area_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","market_type":"Postal Code","product_size":"Half","lead_routing":"Flex","quantity":100,"allocated":0,"available":0,"presale":0,"reserved":0,"reserved_presale":0,"sold":0,"party_allocated":0,"party_available":0,"party_presale":0,"party_reserved":0,"party_reserved_presale":0,"party_sold":0}],"inventoryitems":[{"market_name":"94536","market_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":23,"flex_unit_price":208.33,"fast_unit_price":107.33,"available":0,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":100,"market_key":"94536|CA|COBROKE|POSTALCODE|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"94536","market_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":3,"flex_unit_price":416.67,"fast_unit_price":214.67,"available":0,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":100,"market_key":"94536|CA|COBROKE|POSTALCODE|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"94536","market_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":23,"flex_unit_price":208.33,"fast_unit_price":107.33,"available":0,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":100,"market_key":"94536|CA|COBROKE|POSTALCODE|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"94536","market_type":"Postal Code","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":3,"flex_unit_price":416.67,"fast_unit_price":214.67,"available":0,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":100,"market_key":"94536|CA|COBROKE|POSTALCODE|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Fremont Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Flex","city":"fremont","county":"alameda","state_id":"ca","price_tier":2,"flex_unit_price":500,"fast_unit_price":257.67,"available":2,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":2,"market_key":"FREMONT|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Fremont Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Fast","city":"fremont","county":"alameda","state_id":"ca","price_tier":2,"flex_unit_price":500,"fast_unit_price":257.67,"available":2,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":2,"market_key":"FREMONT|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Fremont Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Flex","city":"fremont","county":"alameda","state_id":"ca","price_tier":22,"flex_unit_price":250,"fast_unit_price":128.83,"available":22,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":22,"market_key":"FREMONT|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Fremont Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Fast","city":"fremont","county":"alameda","state_id":"ca","price_tier":22,"flex_unit_price":250,"fast_unit_price":128.83,"available":22,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":22,"market_key":"FREMONT|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Newark Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":4,"flex_unit_price":317.53,"fast_unit_price":163.67,"available":4,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":4,"market_key":"NEWARK|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Newark Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":4,"flex_unit_price":317.53,"fast_unit_price":163.67,"available":4,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":4,"market_key":"NEWARK|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Newark Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":24,"flex_unit_price":158.67,"fast_unit_price":81.83,"available":24,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":24,"market_key":"NEWARK|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Newark Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":24,"flex_unit_price":158.67,"fast_unit_price":81.83,"available":24,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":24,"market_key":"NEWARK|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Sunol Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":1,"flex_unit_price":509.17,"fast_unit_price":262.33,"available":1,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":1,"market_key":"SUNOL|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Sunol Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":21,"flex_unit_price":254.5,"fast_unit_price":131.17,"available":21,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":21,"market_key":"SUNOL|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Sunol Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":1,"flex_unit_price":509.17,"fast_unit_price":262.33,"available":1,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":1,"market_key":"SUNOL|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Sunol Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":21,"flex_unit_price":254.5,"fast_unit_price":131.17,"available":21,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":21,"market_key":"SUNOL|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Union City Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":24,"flex_unit_price":158.67,"fast_unit_price":81.83,"available":24,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":24,"market_key":"UNIONCITY|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Union City Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":4,"flex_unit_price":317.53,"fast_unit_price":163.67,"available":4,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":4,"market_key":"UNIONCITY|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Union City Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Full","lead_routing":"Flex","city":"sunol","county":"alameda","state_id":"ca","price_tier":4,"flex_unit_price":317.53,"fast_unit_price":163.67,"available":4,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":4,"market_key":"UNIONCITY|CA|COBROKE|CITY|FULL","distance":0,"secondary_cities":"","has_multiple_mapping":0},{"market_name":"Union City Cluster, CA","market_type":"City","part_number":"COBROKE","product_name":"Connection for Co-Brokerage","product_size":"Half","lead_routing":"Fast","city":"sunol","county":"alameda","state_id":"ca","price_tier":24,"flex_unit_price":158.67,"fast_unit_price":81.83,"available":24,"available_presale":0,"sold":0,"inventory_market_status":"Active","cost_per_action":0,"quantity":24,"market_key":"UNIONCITY|CA|COBROKE|CITY|HALF","distance":0,"secondary_cities":"","has_multiple_mapping":0}],"geo_json":"{\"features\":[{\"geometry\":{\"coordinates\":[[[-121.971,37.559],[-121.976,37.554],[-121.982,37.557],[-121.98,37.559],[-121.982,37.56],[-121.984,37.558],[-121.982,37.556],[-121.987,37.55],[-121.997,37.538],[-121.998,37.54],[-122.001,37.538],[-121.998,37.536],[-122.002,37.53],[-122.016,37.538],[-122.039,37.563],[-122.025,37.579],[-122.018,37.574],[-122.013,37.581],[-122.008,37.58],[-122.006,37.586],[-121.992,37.598],[-121.993,37.601],[-121.989,37.6],[-121.982,37.605],[-121.958,37.59],[-121.952,37.598],[-121.939,37.599],[-121.937,37.593],[-121.934,37.592],[-121.953,37.59],[-121.956,37.589],[-121.962,37.586],[-121.959,37.587],[-121.962,37.58],[-121.955,37.57],[-121.946,37.569],[-121.945,37.566],[-121.952,37.57],[-121.964,37.564],[-121.961,37.561],[-121.961,37.558],[-121.968,37.561],[-121.971,37.559]]],\"type\":\"Polygon\"},\"id\":\"postalcode__94536\",\"properties\":{\"available\":0,\"sold\":0,\"inventory_market_status\":\"Active\",\"state\":\"CA\",\"state_name\":\"California\",\"postal_code\":\"94536\",\"has_market_code\":false,\"centroid\":\"37.569882 -121.992319\"},\"type\":\"Feature\"}],\"type\":\"FeatureCollection\"}"}';
                }

                JSONParser parser = JSON.createParser(myjson);

                while (parser.nextToken() != null) {
                    System.debug('Current token: ' +
                        parser.getCurrentToken() + parser.getCurrentName() + parser.getText());

System.Debug('PPPPPPP'+(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() == 'inventory_aggregates_by_geoarea'));
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() == 'inventory_aggregates_by_geoarea') {
System.debug('PPPPPP10');
                        WLJson sto = (WLJson) parser.readValueAs(WLJson.class);
                        WLJsonlist.add(sto);
                    } else if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
System.debug('PPPPPP11');
                        while (parser.nextToken() != null) {
                        System.debug('PPPPPP222'+parser.getCurrentName());
                            // Check for JSON object starting
                            //  START_OBJECT This token is returned when  is encountered.
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            System.debug('PPPPPP333');
                                // Read entire invoice object, including its array of line items.
                                WLJson sto = (WLJson) parser.readValueAs(WLJson.class);
                                WLJsonList.add(sto);

                            } // if start object

                        } // while loop

                    } // else if end 

                } // parent while

            } // try catch block
            catch (Exception e) {

                System.Debug('Exception myjson' + myjson);
                System.Debug('e' + e);

            }

            try {
                Set<String> markets = new Set<String>();    // CRM-5389
                for (WLJson obj1: WLJsonList) {

                    System.Debug('WlJson Obj: Market Name:: ' + obj1.market_name);

                    if (obj1.market_name != null) {
                        System.Debug('1');
                        if (mCounty != null) {

                            if (!mCounty.EqualsIgnoreCase(obj1.county) && mFilterType == 'county') {

                                continue;
                            }
                        }

                        Invlist WL = new Invlist();
                        System.Debug('Create WL Object');
                        WL.secondary_cities = obj1.secondary_cities;

                        try {

                            WL.area = obj1.area;
                            WL.area_type = obj1.area_type;
                            WL.part_number = obj1.part_number;
                            WL.product_name = obj1.product_name;
                            WL.market_type = obj1.market_type;
                            WL.lead_routing = obj1.lead_routing;
                            WL.quantity = obj1.quantity;
                            WL.allocated = obj1.allocated;
                            WL.available = obj1.available;
                            WL.available_presale = obj1.available_presale;
                            WL.presale = obj1.presale;
                            WL.clc = obj1.clc;
                            WL.reserved_presale = obj1.reserved_presale;
                            WL.sold = obj1.sold;
                            WL.party_available = obj1.party_available;
                            WL.party_presale = obj1.party_presale;
                            WL.party_reserved = obj1.party_reserved;
                            WL.customer_min_quantity = obj1.customer_min_quantity;
                            WL.party_reserved_presale = obj1.party_reserved_presale;
                            WL.party_sold = obj1.party_sold;
                            WL.product_size = obj1.product_size;
                            WL.market_name = obj1.market_name;
                            markets.add(WL.market_name);    // CRM-5389
                            // CRM-6310 - Store transition markets
                            if (obj1.market_code != null && obj1.market_code.equalsIgnoreCase('TRANSITION')) {
                                transitionMarkets.add(WL.market_name);
                            }
                            // CRM-6310 - End
                            WL.city = obj1.city;
                            WL.county = obj1.county;
                            WL.state_id = obj1.state_id;
                            WL.price_tier = obj1.price_tier;
                            WL.inventory_market_status = obj1.inventory_market_status;
                            WL.market_key = obj1.market_key;
                            WL.distance = obj1.distance;
                            WL.flex_unit_price = Decimal.valueOf(obj1.flex_unit_price);
                            WL.fast_unit_price = Decimal.valueOf(obj1.fast_unit_price);
                            WL.cost_per_action = Decimal.valueOf(obj1.cost_per_action);
                            WL.item_details = obj1.item_details;
                            
                            BundleZipWrapper zipWrapperInst = new BundleZipWrapper();
                            zipWrapperInst.bundleZipWrapperVar = WL.item_details;
                            WL.item_details_serialize = JSON.serialize( zipWrapperInst );
                            
                            //WL.forecast     = string.IsBlank( obj1.forecast ) ? 0 : Integer.valueOf( obj1.forecast );
                                                        WL.forecast     = string.IsBlank( obj1.forecast ) ? 0 : Decimal.valueOf( obj1.forecast ); //CRM-4322
                            WL.fast_unit_price = WL.fast_unit_price.setScale(2);
                            WL.flex_unit_price = WL.flex_unit_price.setScale(2);
                            WL.home_search_mkt_budget = WL.home_search_mkt_budget.setScale(2);
                            WL.cost_per_action = WL.cost_per_action.setScale(2);
                            WL.total_home_search_price = WL.total_home_search_price.setScale(2);
                            WL.TL_license_price = WL.TL_license_price.setScale(2);
                            WL.Total_fast_price = WL.Total_fast_price.setScale(2);
                            WL.Total_flex_price = WL.Total_flex_price.setScale(2);
                           

                            if (integer.valueof(obj1.available) > 0) {

                                WL.Total_fast_price = WL.fast_unit_price * (integer.valueof(obj1.available));
                                WL.Total_flex_price = WL.flex_unit_price * (integer.valueof(obj1.available));

                            }

                            WL.totalassets = 0;
                            WL.secondary_cities = obj1.secondary_cities;

                            if ((integer.valueof(obj1.available) > 0) && (obj1.part_number == 'HANDRAISER' || obj1.part_number == 'HOMESRCH')) {

                                if ((integer.valueof(obj1.available) > 1) && obj1.part_number == 'HOMESRCH') {

                                    WL.TL_license_price = WL.flex_unit_price + ((integer.valueof(obj1.available) - 1) * 300);

                                    WL.flex_unit_price = WL.TL_license_price;

                                } else {

                                    WL.TL_license_price = WL.flex_unit_price;
                                    WL.flex_unit_price = WL.TL_license_price;

                                }
                                WL.home_search_mkt_budget = WL.cost_per_action * 50 * (integer.valueof(obj1.available));
                                WL.total_home_search_price = WL.TL_license_price + WL.home_search_mkt_budget;
                                WL.TL_license_price = WL.TL_license_price.setScale(2);
                                WL.home_search_mkt_budget = WL.home_search_mkt_budget.setScale(2);
                                WL.total_home_search_price = WL.total_home_search_price.setScale(2);
                                WL.cost_per_action = WL.cost_per_action.setScale(2);
                                system.debug(' WL.home_search_mkt_budget :-' + WL.home_search_mkt_budget);
                            }

                            If(integer.valueof(obj1.available) <= 0) {

                                WL.available = 0;

                                if (obj1.part_number == 'HANDRAISER' || obj1.part_number == 'HOMESRCH') {

                                    WL.TL_license_price = 0.00;
                                    WL.flex_unit_price = WL.TL_license_price;

                                }

                            }

                            if ((WL.market_key != null) || (WL.market_key != '')) {

                                Assetlist.add(obj1.market_key);

                            }

                        } catch (exception e) {


                        }

                        InvList1.add(WL);

                    } // end of market name check If 

                } // for loop
                protectedMarkets = getProtectedMarketList(markets);       // CRM-5389  
                // Fill the Total Asset Counts
                System.debug(InvList1+'KKKKKK');
                InvList1 = FillAssetValues(InvList1, Assetlist);

            } catch (exception e) {}



            return InvList1;

        } // end of the class

   
     public List < Invlist > FillAssetValues(List < Invlist > AssetList, List < string > MarketKeylist) {

            List < Asset > MyAsset;
            List < Integer > AssetCount;
            integer i = 0;
            integer j = 0;

            try {

                String[] MarketKeylist1 = new String[] {
                    '17066|PA|COBROKE|POSTALCODE|FULL'
                };

                if (MarketKeylist1 != null) {
                    system.debug('--- > MarketKeylist1'+MarketKeylist1);
                    MyAsset = [SELECT market_key__c FROM Asset WHERE market_key__c =: MarketKeylist1];

                }

                for (Invlist MyInvlistObj: AssetList) {
                    system.debug(' ---- > inside asset list '+MyInvlistObj);
                    for (Asset assetC: MYAsset) {
                        system.debug('--- inside my assets '+assetC);
                        if ((MyInvlistObj.market_key == '17066|PA|COBROKE|POSTALCODE|FULL' || (MyInvlistObj.market_key == '17066&#124;PA&#124;COBROKE&#124;POSTALCODE&#124;FULL'))) {
                            system.debug('--- inside cobroke --> ');
                            MyInvlistObj.totalassets = MyInvlistObj.totalassets + 1;

                            AssetList[j] = MyInvlistObj;

                        }

                    }
                    j++;

                } // master for loop   

            } catch (exception e) {

                // error WL field values will be skipped 
                System.debug('Error when retrieveing Account usign Party Id JSON' + e.getMessage() + 'i' + i + 'is' + 'j' + j);

            }
            return AssetList;

        } // end of function
    
    
    public void populateBundleZips(){
        
        String commaSepratedBundleZip = ApexPages.currentPage().getParameters().get('commaSepratedBundleZip');
        String itemDetailsJson = ApexPages.currentPage().getParameters().get('itemDetailsJson');
        bundleZipList = new list<Invlist>();
        list<string> chunkCommaSepratedBundleZipList = new list<string>();
        
        if( !string.isBlank( commaSepratedBundleZip ) ){
            
            if( commaSepratedBundleZip.split(',').size() > 30 ){
                
                commaSepratedBundleZip = commaSepratedBundleZip.replaceAll( '\\s+', '');
                integer counter = 0;
                string chunkCommaSepratedBundleZip = '';
                for( string zipValue : commaSepratedBundleZip.split(',')){
                    
                    counter += 1;
                    chunkCommaSepratedBundleZip += zipValue +',';
                     if( counter >= 30){
                        chunkCommaSepratedBundleZipList.add( chunkCommaSepratedBundleZip );
                        chunkCommaSepratedBundleZip = '';
                     }
                }
            }else{
                commaSepratedBundleZip = commaSepratedBundleZip.replaceAll( '\\s+', '');
                chunkCommaSepratedBundleZipList.add( commaSepratedBundleZip);
            }
            
            for(string chunkCommaSepratedBundle: chunkCommaSepratedBundleZipList){
                
                mFilterType     = 'postal_code';
                mInputvalue     = chunkCommaSepratedBundle;//commaSepratedBundleZip.replaceAll( '\\s+', '');
                mProduct        = 'SELLERLEAD';
                bundleZipList.addAll( GetWaitlistfromWebService() );
            }   
            
            if( !string.isBlank( itemDetailsJson )  ){
                
                BundleZipWrapper zipWrapperInst = (BundleZipWrapper) JSON.deserialize( itemDetailsJson, BundleZipWrapper.class);
                //Map<String,Integer> map_zipToForecastedLeads = new map<string,Integer>(); /CRM-4322
                                Map<String,Decimal> map_zipToForecastedLeads = new map<string,Decimal>(); //CRM-4322
                
                for( BundleZipDetails bundleZipDetailsVar : zipWrapperInst.bundleZipWrapperVar ){
                    
                    if( !string.isBlank(  bundleZipDetailsVar.forecast  ) ){
                        //map_zipToForecastedLeads.put(bundleZipDetailsVar.market_name, Integer.valueOf(bundleZipDetailsVar.forecast));
                                                map_zipToForecastedLeads.put(bundleZipDetailsVar.market_name, Decimal.valueOf(bundleZipDetailsVar.forecast)); //CRM-4322
                    }else{
                        map_zipToForecastedLeads.put(bundleZipDetailsVar.market_name, 0);
                    }
                }
                
                for( Invlist invVar: bundleZipList){
                    if( map_zipToForecastedLeads.containsKey(invVar.market_name) ){
                        invVar.forecast = map_zipToForecastedLeads.get(invVar.market_name);
                    }
                }
            }//end if
            
        }//end if top
    }
    
    
    public class Invlist {
        public string area {get;set;}
        public string area_type {get;set;}
        public string part_number {get;set;}
        public string product_name {get;set;}
        public string market_type {get;set;}
        public string product_size {get;set;}
        public string lead_routing {get;set;}
        transient public string allocated {get;set;}
        public decimal available {get;set;}
        public decimal available_presale {get;set;}
        public string presale {get;set;}
        public string clc {get;set;}
        public string reserved_presale {get;set;}
        public string sold {get;set;}
        public string party_available {get;set;}
        public string party_presale {get;set;}
        public string party_reserved {get;set;}
        public string customer_min_quantity {get;set;}
        public string party_reserved_presale {get;set;}
        public string party_sold {get;set;}
        public string market_name {get;set;}
        public string city {get;set;}
        public string county {get;set;}
        public string state_id {get;set;}
        public Decimal price_tier {get;set;}
        public string inventory_market_status {get;set;}
        transient public Decimal cost_per_action {get;set;}
        transient public string market_key {get;set;}
        public integer totalassets {get;set;}
        public integer totalcustomers {get;set;}
        public integer totalprospects {get;set;}
        public string distance {get;set;}
        public Decimal flex_unit_price {get;set;}
        public Decimal fast_unit_price {get;set;}
        transient public string secondary_cities {get;set;}
        transient public Decimal home_search_mkt_budget {get;set;}
        transient public Decimal total_home_search_price {get;set;}
        transient public Decimal TL_license_price {get;set;}
        public Decimal Total_flex_price {get;set;}
        public Decimal Total_fast_price {get;set;}
        public Decimal quantity {get;set;}
        //public integer forecast {get;set;} //CRM-4322
        transient public Decimal forecast {get;set;}
        transient public list<BundleZipDetails> item_details {get;set;}
        transient public string item_details_serialize {get;set;}
        
        public Invlist(){
            item_details = new list<BundleZipDetails>();
        }
    }
    
    public class BundleZipWrapper{
        public list<BundleZipDetails> bundleZipWrapperVar {get;set;}
        
        public BundleZipWrapper(){
            bundleZipWrapperVar = new list<BundleZipDetails>();
        }
    }
    public class BundleZipDetails{
        public string market_name {get;set;}
        public string market_type {get;set;}
        public string forecast {get;set;}
        
    }
    public class WLMaster {

        public string reservation_id {get;set;}
        public string lock_release_date {get;set;}
        public List < WLJson > reservation_line_items {get;set;}
        public WLMaster(string reservation_id, List < WLJson > reservation_line_items, string lock_release_date) {


            this.reservation_id = reservation_id;
            this.reservation_line_items = reservation_line_items;
            this.lock_release_date = lock_release_date;

        }

    }

    public class WLJson {
        public string market_code {get;set;}    // CRM-6310
        public string area {get;set;}
        public string area_type {get;set;}
        public string part_number {get;set;}
        public string product_name {get;set;}
        public string market_type {get;set;}
        public string product_size {get;set;}
        public string lead_routing {get;set;}
        public decimal quantity {get;set;}
        public string allocated {get;set;}
        public decimal available {get;set;}
        public decimal available_presale {get;set;}
        public string presale {get;set;}
        public string clc {get;set;}
        public string reserved_presale {get;set;}
        public string sold {get;set;}
        public string party_available {get;set;}
        public string party_presale {get;set;}
        public string party_reserved {get;set;}
        public string customer_min_quantity {get;set;}
        public string party_reserved_presale {get;set;}
        public string party_sold {get;set;}
        public string market_name {get;set;}
        public string city {get;set;}
        public string county {get;set;}
        public string state_id {get;set;}
        public Decimal price_tier {get;set;}
        public string inventory_market_status {get;set;}
        public string cost_per_action {get;set;}
        public string market_key {get;set;}
        public string distance {get;set;}
        public string flex_unit_price {get;set;}
        public string fast_unit_price {get;set;}
        public string secondary_cities {get;set;}
        public string forecast {get;set;}
        public list<BundleZipDetails> item_details {get;set;}
        
        public WLJson(){
            item_details = new list<BundleZipDetails>();
        }
      
    } // end of class 
    
    // CRM-5389 - Function to get Protected Markets out of given Set of Markets
    public static List<String> getProtectedMarketList(Set<String> markets) {
        List<String> protectedMarkets = new List<String>();
        if (!markets.isEmpty()) {
            for(Protected_Market__c pMarket : [SELECT Market_Name__c FROM Protected_Market__c WHERE Market_Name__c IN :markets AND Active__c=true]) {
                protectedMarkets.add(pMarket.Market_Name__c);
            }
        }
        return protectedMarkets;
    }
    // CRM-5389 - End
}