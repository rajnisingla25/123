/**
* Copyright (c) Move Inc .
* Name : AccountCreateWaitlist
* Test Class : AccountCreateWaitlist_Test
* Description : This Apex Class to show data to My Waitlist and Account Waitlist Pages 
* @author  Rajamohan Vakati
* @version 2.0
* @since   2016 Dec
* @Updated 2016 Dec 
*/

global class DataController {
    private final Account acct;
    public List < Waitlist > WLs;
    public string Sendjson {
        get;
        set;
    }
    private string mParty_Id {
        get;
        set;
    }
    public string mPhone {
        get;
        set;
    }
    public string MyUserid {
        get;
        set;
    }
    public string MyUserName {
        get;
        set;
    }
    
    public string MyUserNamePROFILE {
        get;
        set;
    }
    
    public string CPQLoginDetails {
        get;
        set;
    }
    
    public string CPQLogiURL {
        get;
        set;
    }
    
    public string MyUserNameLoginId {
        get;
        set;
    }
    
    
    public string MyUserName1;
    public boolean GlobalWaitlist = false;
    public string MyUserEmail {
        get;
        set;
    }
    public string MyUserProfileName {
        get;
        set;
    }
    public string MyUserProfileManagerId {
        get;
        set;
    }
    public string MyUserProfileId {
        get;
        set;
    }
    public string MyUserLocale {
        get;
        set;
    }
    public string MyUserTimezone {
        get;
        set;
    }
    public string MyUserFullName {
        get;
        set;
    }
    public integer intWhichPageisCalling = 1; // 1 is Account Waitlist ,2 is My Wailist , 3 is My Team View , 4 is Top10 
    public string MyGroupName {
        get;
        set;
    }
    public string mBOB_Territory {
        get;
        set;
    }
    public string mMyTimeZone {
        get;
        set;
    }
    public string mAreaCode {
        get;
        set;
    }
    public string mDesignatedUserId;
    public string mDesignatedUser;
    public List < User > userlist;
    public string mCustomerName;
    public string mSetting_CPQURL {
        get;
        set;
    }
    public string mSetting_CPQFULLURL {
        get;
        set;
    }
    public string mSetting_CPQUSER {
        get;
        set;
    }
    public string mSetting_CPQPASSWORD {
        get;
        set;
    }
    public string MYId {
        get;
        set;
    }
    public string opptId {
        get;
        set;
    }
    public boolean createtask = false;
    public set < Task > taskdata = new set < Task > ();
    public string rank {
        get;
        set;
    }
    public string filtervalue;
    public boolean showall {
        get;
        set;
    }
    
    public boolean active { //CRM-498 added new checkbox on page
        get;
        set;
    }
    
    public boolean showallactive { //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        get;
        set;
    }
    
    boolean bMyWaitList = false;
    public string getMyUserName1() // added a comment
    {
        if (mParty_id == null || mParty_id == '') {
            if (MyGroupName == null) {
                return MyUserName1;
            } else {
                return MyUserName1;
            }
        } else {
            return MyUserName1;
        }
    }
    public void setPhone(String newvalue) {
        mPhone = newvalue;
    }
    public string getPhone() {
        return mPhone;
    }
    public string getBOB() {
        return mBOB_Territory;
    }
    public void setBOB(String newvalue) {
        mBOB_Territory = newvalue;
    }
    public string getTZ() {
        return mMyTimeZone;
    }
    public void setTZ(String newvalue) {
        mMyTimeZone = newvalue;
    }
    public boolean showcancel {get;set;} 
    public boolean showfulfilled {get;set;} 
    public boolean showexpired {get;set;} 
    
    private String allWaitlistGetURL;
    
    public DataController(ApexPages.StandardController stdController) {
        Account acct_temp;
        showcancel = false ; 
        showfulfilled = false ;
        showexpired = false ;
        showall = false ;
        active = true; //CRM -498
        showallactive = false; //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        try {
            this.acct = (Account) stdController.getRecord();
            MYID = acct.id;
            Waitlist_Urls__c CPQURL = Waitlist_Urls__c.getInstance('CPQURL');
            Waitlist_Urls__c CPQFULLURL = Waitlist_Urls__c.getInstance('CPQFULLURL');
            String CPQUSER = BigMachineUrls__c.getInstance('WLBM').DefaultUserName__c;
            String CPQPASSWORD = BigMachineUrls__c.getInstance('WLBM').DefaultPassword__c;
            mSetting_CPQURL = CPQURL.url__c;
            mSetting_CPQFULLURL = CPQFULLURL.url__c;
            mSetting_CPQUSER = CPQUSER;
            mSetting_CPQPASSWORD = CPQPASSWORD;
            MYID = acct.id;
            if (MYID != null) {
                acct_temp = [SELECT Id, Name, Phone, Party_ID__c, (select description, WaitlistGUIID__c from Tasks) FROM Account
                             WHERE Id = : ApexPages.currentPage().getParameters().get('id')
                            ];
                mParty_Id = acct_temp.Party_ID__c;
                mPhone = acct_temp.Phone;
                mBOB_Territory = '';
                mCustomerName = acct_temp.Name;
                taskdata.addall(acct_temp.Tasks);
            }
            StoreMainParameters();
        } catch (exception e) {
            StoreMainParameters();
            try {
                mPhone = acct.Phone;
            } catch (exception e1) {
            }
        }
    }
    public DataController() {}
    public void StoreMainParameters() {
        try {
            MyUserid = Userinfo.getUserId();
            try {
                User u = [SELECT Id, Alias, NT_Login_ID__c, team__c, Global_Waitlist__c FROM User WHERE Id = : MyUserid LIMIT 1]; // Get the user you want to update
                MyUserName1 = u.NT_Login_ID__c;
                MyGroupName = u.team__c;
                GlobalWaitlist = u.Global_Waitlist__c;
            } catch (exception e) {
                MyUserName1 = Userinfo.getfirstname().substring(0, 1) + Userinfo.getlastname();
            }
            MyUserName = Userinfo.getusername();
            MyUserEmail = Userinfo.getuseremail();
            MyUserFullName = Userinfo.getName();
            MyUserProfileId = Userinfo.getProfileId();
            MyUserLocale = Userinfo.getLocale();
            mDesignatedUserId = MyUserid; // set this as default and then change when you assign to a different user used by group 
            mDesignatedUser = MyUserName1;
            try {
                Profile p = [select name from Profile where id = : UserInfo.getProfileId()];
                MyUserProfileName = p.name;
            } catch (exception e) {
            }
            if (mParty_Id != null) {
                intWhichPageisCalling = 1;
                mMYFilter = 'party_id=' + mParty_Id;
            } else { // No account Id exists , assume My Waitlist 
                intWhichPageisCalling = 2;
                // CRM-4559 - Commented passing paramter OrAccountSubTypeCreatedByOwner, added owner_name instead
                //mMyFilter = 'OrAccountSubTypeCreatedByOwner=' + 'Prospect' + ',' + mDesignatedUser + ',' + mDesignatedUser;
                if (mDesignatedUser == null) // only when null
                {
                }
                //mMyFilter = 'OrAccountSubTypeCreatedByOwner=' + 'Prospect' + ',' + mDesignatedUser + ',' + mDesignatedUser;
                mMyFilter = 'owner_name=' + mDesignatedUser;
            }
            try {
                if (mPhone != null) {
                    String myString1 = mPhone;
                    String myString2 = '(';
                    Integer result = myString1.indexOf(myString2, 0) + 1;
                    String areacode = mPhone.substring(result, 4);
                    mAreacode = areacode;
                    MoveGeoArea__c MoveGeo = [select areacode__c, timezone__c from MoveGeoArea__c where areacode__c = : areacode Limit 1];
                    mMyTimeZone = MoveGeo.timezone__c;
                }
            } catch (exception e) {
                mMyTimeZone = 'Pacific' + mAreaCode;
            }
        } catch (exception e) {
            System.debug('error occured in setting user profile data' + e.getMessage());
        }
    }
    
    // CRM-1848 - Sonali Bhardwaj - Defined below variables as transient to avoid view state size limit.
    // Replaced all occurence of accountwaitlist with accountwaitlist1 in this class
    public transient List < Waitlist > accountwaitlist1;
    
    public List < Waitlist > accountwaitlist {
        get {
            if (accountwaitlist1 == null) {
                try {
                    System.debug('==== Stage 0====');
                    List < Waitlist > WLs= new List<Waitlist>();
                    String[] orderBys = new String[] {
                        'token asc'
                            };
                                accountwaitlist1 = new List < Waitlist >();
                    System.debug('==== Stage 1 ====');
                    accountwaitlist1 = GetWaitlistfromWebService();
                    System.debug('==== Stage 2 ====');
                    if (accountwaitlist1 == null) {
                        //     accountwaitlist1 = new List < Waitlist >();
                    }
                } catch (exception e) {
                }
            }
            return accountwaitlist1;
        }
        set;
    }
    public List < Waitlist > WLsAjax;
    public List < Waitlist > getWLsAjax() {
        return WLsAjax;
    }
    private string mInputValue;
    private string mToken;
    //private string mMarket = '94010';
    public string mMarket {get; set;}
    private string mMarkettype = 'Postal Code';
    private string mAccountId;
    private string mStatus;
    private string mDegree;
    private string mLeadroutingtype;
    private string mSlotsize;
    private string mMarketspend;
    private string mutilspend;
    private string mremnantspend;
    private string mJson;
    private string mnotes;
    private string mqtyinterested;
    private string mproduct;
    private string moperation;
    private string mMyOrderBy = 'OrderByDesc=totalavailableflex,totalavailablefast';
    private string mMyFilter = '';
    private string mMyLimit = 'Take='+Waitlist_Urls__c.getInstance('waitlistLimit').replacement_parameter__c; //crm-1311
    private string mMyPageNo = 'Skip=0';
    private string mWaitlistStatus = '';
    public string mFilterType = null;
    private string mAccountName;
    private string mInputType;
    public void setToken(String newvalue) {
        mToken = newvalue;
    }
    public string getProduct() {
        return mProduct;
    }
    public void setProduct(String newvalue) {
        mProduct = newvalue;
    }
    public string getToken() {
        return mToken;
    }
    public void setDegree(String newvalue) {
        mDegree = newvalue;
    }
    public string getDegree() {
        return mDegree;
    }
    public void setSlotSize(String newvalue) {
        mSlotSize = newvalue;
    }
    public string getSlotSize() {
        return mSlotSize;
    }
    public void setLeadRoutingType(String newvalue) {
        mLeadRoutingType = newvalue;
    }
    public string getLeadRoutingType() {
        return mLeadRoutingType;
    }
    public void setStatus(String newvalue) {
        mStatus = newvalue;
    }
    public string getStatus() {
        return mStatus;
    }
    public void setJson(String newvalue) {
        mJson = newvalue;
    }
    public string getJson() {
        return mJson;
    }
    public void setAccountId(String newvalue) {
        mAccountId = newvalue;
    }
    public string getAccountId() {
        return mAccountId;
    }
    public void setNotes(String newvalue) {
        mNotes = newvalue;
    }
    public string getNotes() {
        return mNotes;
    }
    public void setqtyinterested(String newvalue) {
        mqtyinterested = newvalue;
    }
    public string getqtyinterested() {
        return mqtyinterested;
    }
    public void setoperation(String newvalue) {
        moperation = newvalue;
    }
    public string getoperation() {
        return moperation;
    }
    public string getMyOrderBy() {
        return mMyOrderBy;
    }
    public void setMyOrderBy(String newvalue) {
        mMyOrderBy = newvalue;
    }
    public string getMyFilter() {
        return mMyFilter;
    }
    public void setMyFilter(String newvalue) {
        mMyFilter = newvalue;
    }
    public string getMyLimit() {
        return mMyLimit;
    }
    public void setMyLimit(String newvalue) {
        mMyLimit = newvalue;
    }
    public String getWaitlistStatus() {
        return mWaitlistStatus;
    }
    public String getAccountName() {
        return mAccountName;
    }
    public void setWaitlistStatus(String WaitlistStatus) {
        if (WaitlistStatus != null) {
            this.mWaitlistStatus = WaitlistStatus;
            this.mInputValue = WaitlistStatus;
            this.mWaitlistStatus = mWaitlistStatus.replace(' ', '%20');
            string retstring = AssignFilterValue(mWaitlistStatus);
        }
    }
    public pageReference RefreshPage() {
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
    public pageReference makeSOACallforGet() {
        try {
            System.debug('== > Check ing -->');
            accountwaitlist1 = GetWaitlistfromWebService();
            this.accountwaitlist1 = accountwaitlist;
        } catch (exception e) {
            System.debug('An exception occurred GetWaitlistfromWebService: ' + e.getMessage());
        }
        return null;
    }
    public List < SelectOption > getWaitlistStatusItems() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        if (mFilterType != '') {
            if ('Pre-Auth status'.equals(mFilterType)) {
                options.add(new SelectOption('Pending Pre-Auth', 'Pending Pre-Auth'));
                options.add(new SelectOption('Pending Pre-Auth Approval', 'Pending Pre-Auth Approval'));
                options.add(new SelectOption('Fulfilled', 'Fulfilled'));
                options.add(new SelectOption('Active', 'Active'));
                options.add(new SelectOption('Created', 'Created'));
            } else if ('Waitlist Type'.equals(mFilterType)) {
                options.add(new SelectOption('Pre-Auth', 'Pre-Auth'));
                options.add(new SelectOption('Hot', 'Hot'));
                options.add(new SelectOption('Warm', 'Warm'));
                options.add(new SelectOption('Pipeline', 'Pipeline'));
            } else if ('Product'.equals(mFilterType)) {
                List < CreateWaitlist__c > cWaitListValues = CreateWaitlist__c.getall().values();
                set < string > uniqueProductName = new set < string > ();
                for (CreateWaitlist__c cwInst: cWaitListValues) {
                    if (uniqueProductName.add(cwInst.Inventory_Product__c)) {
                        options.add(new SelectOption(cwInst.Inventory_Product__c, cwInst.Product__c));
                    }
                }
            } else if ('Owner'.equals(mFilterType)) {
                options.add(new SelectOption('Please type user NT Login ID in right cell', 'Please type user NT Login ID in right cell'));
            } else if ('Created By'.equals(mFilterType)) {
                options.add(new SelectOption('Please type user NT Login ID', 'Please type user NT Login ID in right cell'));
            } else if ('No of Records'.equals(mFilterType)) {
                options.add(new SelectOption('500', '500'));
                options.add(new SelectOption('1000', '1000'));
                options.add(new SelectOption('1500', '1500'));
                options.add(new SelectOption('2000', '2000'));
            } else if ('Market'.equals(mFilterType)) {
                options.add(new SelectOption('Please type market value', 'Please type market value in right cell'));
            } else if ('Customer'.equals(mFilterType)) {
                options.add(new SelectOption('Please type customer name', 'Please type customer name in right cell'));
            } else if ('Customer ID'.equals(mFilterType)) {
                options.add(new SelectOption('Please type customerCustomer Id', 'Please type customerCustomer Id in right cell'));
            } // end of If check
        }
        return options;
    }
    public List < SelectOption > getFilterList() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        if (ApexPages.currentPage().getUrl().contains('MyWaitlist') && GlobalWaitlist) {
            options.add(new SelectOption('Owner', 'Owner'));
            options.add(new SelectOption('Created By', 'Created By'));
        }
        options.add(new SelectOption('Waitlist Type', 'Waitlist Type'));
        options.add(new SelectOption('Pre-Auth status', 'Pre-Auth status'));
        options.add(new SelectOption('Product', 'Product'));
        options.add(new SelectOption('Market', 'Market'));
        options.add(new SelectOption('Inventory Available Flex', 'Inventory Available Flex'));
        options.add(new SelectOption('Inventory Available Fast', 'Inventory Available Fast'));
        options.add(new SelectOption('Presales Available Flex', 'Presales Available Flex'));
        options.add(new SelectOption('Presales Available Fast', 'Presales Available Fast'));
        if (ApexPages.currentPage().getUrl().contains('MyWaitlist')) {
            options.add(new SelectOption('Customer', 'Customer'));
            options.add(new SelectOption('Customer ID', 'Customer ID'));
        }
        return options;
    }
    public String getFilterType() {
        return mFilterType;
    }
    public void setFilterType(String filtertype) {
        this.mFilterType = filtertype;
    }
    public List < SelectOption > getInputList() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Assigned AE', 'Assigned AE'));
        options.add(new SelectOption('Input AE', 'Input AE'));
        options.add(new SelectOption('Customer ID', 'Customer ID'));
        options.add(new SelectOption('Token', 'Token'));
        return options;
    }
    public String getInputType() {
        return mInputType;
    }
    public void setInputType(String newvalue) {
        this.mInputType = newvalue;
    }
    public String getInputValue() {
        if (mInputValue == null) {
            mInputValue = mWaitlistStatus;
        }
        return mInputValue;
    }
    public void setInputValue(String newvalue) {
        this.mInputValue = newvalue;
        if (newvalue != null) {
            this.mInputValue = AssignFilterValue(mInputValue);
        }
    }
    public string AssignFilterValue(String MyValue) {
        if (MyValue != null) {
            mMyFilter = '';
            MyValue = MyValue.replace(' ', '%20');
            filtervalue = MyValue.replace(' ', '%20');
            //System.debug('mParty_Id ' + mParty_Id );
            if (mParty_Id != null) {
                mMyFilter = 'party_id=' + mParty_Id;
            } else {
                if (mDesignatedUser == null) {
                    mDesignatedUser = MyUserName1;
                }
                // CRM-4559 - Commented passing paramter OrAccountSubTypeCreatedByOwner, added owner_name instead
                //mMyFilter = 'OrAccountSubTypeCreatedByOwner=' + 'Prospect' + ',' + mDesignatedUser + ',' + mDesignatedUser;
                mMyFilter = 'owner_name=' + mDesignatedUser;
                bMyWaitList = true;
            }
            if ('Pre-Auth status'.equals(mFilterType)) {
                mMyFilter = mMyFilter + '&waitlist_status=' + MyValue;
            } else if ('Waitlist Type'.equals(mFilterType)) {
                mMyFilter = mMyFilter + '&waitlist_type=' + MyValue;
            } else if ('Inventory Available Flex'.equals(mFilterType)) {
                if ('Greater%20than%20Zero'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '0';
                } else if ('Greater%20than%201'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '1';
                } else if ('Greater%20than%205'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '5';
                } else if ('Greater%20than%2010'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '10';
                } else if ('Greater%20than%2050'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '50';
                } else if ('Greater%20than%2025'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_flex=' + '25';
                }
            } else if (mFilterType == 'Inventory Available Fast') {
                if ('Greater%20than%20Zero'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '0';
                } else if ('Greater%20than%201'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '1';
                } else if ('Greater%20than%205'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '5';
                } else if ('Greater%20than%2010'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '10';
                } else if ('Greater%20than%2050'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '50';
                } else if ('Greater%20than%2025'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '25';
                }
            } else if (mFilterType == 'Presales Available Fast') {
                if ('Greater%20than%20Zero'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailablefast=' + '0';
                } else if ('Greater%20than%201'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailablefast=' + '1';
                } else if ('Greater%20than%205'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3EInventory_available_fast=' + '5';
                } else if ('Greater%20than%2010'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailablefast=' + '10';
                } else if ('Greater%20than%2050'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailablefast=' + '50';
                } else if ('Greater%20than%2025'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailablefast=' + '25';
                }
            } else if (mFilterType == 'Presales Available Flex') {
                if ('Greater%20than%20Zero'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '0';
                } else if ('Greater%20than%201'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '1';
                } else if ('Greater%20than%205'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '5';
                } else if ('Greater%20than%2010'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '10';
                } else if ('Greater%20than%2050'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '50';
                } else if ('Greater%20than%2025'.equals(MyValue)) {
                    mMyFilter = mMyFilter + '&%3Epresalestotalavailableflex=' + '25';
                }
            } else if (mFilterType == 'Product') {
                mMyFilter = mMyFilter + '&Product_type=' + MyValue;
            } else if (mFilterType == 'Assigned AE') {
                if (bMyWaitList == false) {
                    mMyFilter = mMyFilter + '&Owner_name=' + MyValue;
                    mDesignatedUser = MyValue;
                } else {
                    if (MyGroupName == 'Hybrid Inbound Team' || MyGroupName == 'Retention Team' || MyGroupName == 'Hybrid Territory Team' || MyGroupName == 'Hybrid Agent Team') {
                        if (mParty_Id == null) {
                            // CRM-4559 - Commented passing paramter OrAccountSubTypeCreatedByOwner, added owner_name instead
                            //mMyFilter = 'OrAccountSubTypeCreatedByOwner=' + 'Prospect' + ',' + MyValue + ',' + MyValue;
                            mMyFilter = 'owner_name=' + MyValue;
                            mDesignatedUser = MyValue;
                            try {
                                User usr = [select name, id, firstname, lastname, alias, NT_Login_ID__c from user where alias = : MyValue Limit 1];
                                mDesignatedUserId = usr.id;
                                mDesignatedUser = usr.NT_Login_ID__c;
                            } catch (exception e) {
                                mDesignatedUserId = MyUserId;
                                mDesignatedUser = MyUserName1;
                            }
                        }
                    } else {
                        if (mParty_Id == null) {
                        }
                    }
                }
            } else if (mFilterType == 'Input AE') {
                mMyFilter = mMyFilter + '&Created_by=' + MyValue;
            } else if (mFilterType == 'No of Records') {
                mMyLimit = 'Take=' + Waitlist_Urls__c.getInstance('waitlistLimit').replacement_parameter__c; //CRM-1311
            }
            else if (mFilterType == 'Market') {
                mMyFilter = mMyFilter + '&market_name=' + MyValue;
            } else if (mFilterType == 'Customer') {
                mMyFilter = mMyFilter + '&account_name=' + MyValue;
            } else if (mFilterType == 'Customer ID') {
                mMyFilter = mMyFilter + '&party_id=' + MyValue;
            } else if (mFilterType == 'Token') // waitlist guid or waitlist id
            {
                mMyFilter = mMyFilter + '&waitlist_guid=' + MyValue;
            } else {
            }
        }
        return MyValue;
    }
    public void GenerateWLforSOACall(string token, string market, string markettype, string accountid, string status, string degree, string leadroutingtype, string slotsize, string marketspend, string notes, string qtyinterested, string json, string operation, string product) {
        System.debug('market - ' + market);
        System.debug('status - ' + status);
        System.Debug('product - '+product);
        System.debug('JSON --> '+json);
        string message1 = '';
        
        // CRM-3006 Commented below query to handle scenario where no rows are returned.
        //Account Acctid = [select id from Account where party_ID__C = : accountid limit 1];
        // CRM-3006 Written below query to get records in a list
        Account Acctid = null;
        if (accountid != null && accountid != '') {
            List<Account> accounts = [select id from Account where party_ID__C = : accountid limit 1];
            if (accounts.size() > 0) {
                Acctid = accounts[0];
            }
        }
        // CRM-3006 End
        
        wwwMoveCom.waitlist waitlist = new wwwMoveCom.waitlist();
        waitlist.created_by = MyUserName;
        waitlist.owner_name = MyUserName;
        waitlist.lead_routing = leadroutingtype;
        try {
            // CRM-3015 Added condition to check if mParty_Id is not null
            if (mParty_Id != null && mParty_Id != '') {
                waitlist.party_id = Integer.ValueOf(mParty_Id);
            }
            // CRM-3015 Else assign accountid to the request
            else {
                waitlist.party_id = Integer.ValueOf(accountid);
            }
        } catch (exception e) {}
        if (product == 'CBC')
        {
            waitlist.product_type = 'Connection for Co-Brokerage';
        }
        else if (product == 'Local Expert Zip')
        {
            waitlist.product_type = 'Local Expert';
        }
        else
        {
            waitlist.product_type = product; //'Connection for Co-Brokerage';   
        }
        waitlist.market_type = markettype;
        waitlist.market_name = market;
        waitlist.market_subtype = markettype;
        waitlist.state = '';
        waitlist.rank = rank;
        waitlist.last_modified_by_id = MyUserName;
        waitlist.waitListId = token;
        waitlist.Operation = operation;
        waitlist.waitlist_degree = degree;
        waitlist.waitlist_slot = slotsize;
        waitlist.waitlist_status = '';
        waitlist.promo = '';
        waitlist.promo_expiration_date = '';
        waitlist.comment = notes;
        waitlist.waitlist_type = status;
        try {
            waitlist.quantity = Integer.ValueOf(qtyinterested);
        } catch (Exception e) {
            waitlist.quantity = 0;
        }
        try {
            OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt stub = new OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt();
            //stub.endpoint_x = 'http://soa12c-uat.move.com:7080/soa-infra/services/INV/SyncWaitListInventory/syncwaitlistinventoryservice_ep';
            stub.endpoint_x = Waitlist_Urls__c.getInstance('SOACUD').url__c;
            stub.timeout_x = 120000;
            wwwMoveCom.SyncWaitListRes_element result = new wwwMoveCom.SyncWaitListRes_element();
            if(!Test.isRunningTest()){
              result = stub.process(waitlist);
            }
            
            // CRM-3006 Perform further steps only of Acctid is not null
            if (Acctid != null) {
                // CRM-887 START -- to maintain checkbox on Account for non pre-auth waitlist
                if (operation == 'Delete') {
                    
                    Id accId = null;    // CRM-2318 use variable to pass to future method for DMLs.
                    // CRM-2134 Start - clear flag Non_Pre_Auth_Waitlist__c if there is no Non-PreAuth waitlist on given Account.
                    // CRM-5206 - For error handling
                    Boolean hasNonPreAuthWL = hasNonPreAuthWaitList(accountid);
                    if(hasNonPreAuthWL != null && !hasNonPreAuthWL) {
                        // CRM-2318 Can't perform DML here, as its a Read Only VF.
                        //update new Account(id = Acctid.Id, Non_Pre_Auth_Waitlist__c = false);
                        accId = Acctid.Id;
                    }
                    // CRM-2134 End 
                    
                    // CRM-1741 Maintain waitlist history for delete
                    Waitlist_History__c history = createWaitlistHistory(Acctid.Id, 'Deleted', '', '', token, market, status);
                    // CRM-2318 Can't perform DML here, as its a Read Only VF.
                    //insert history;
                    
                    // CRM-2318 Call future method to perform all DMLs on Delete
                    DataController.DMLsonWaitListDelete(accId, System.JSON.serialize(history));
                    
                    // CRM-1741 End
                }
                // CRM-887 END
                
                message1 = '' + result.status;
                if (notes != null) {
                    createtask = false;
                    if (taskdata.size() > 0) {
                        for (task taskloop: taskdata) {
                            createtask = true;
                            if (taskloop.description == notes && taskloop.WaitlistGUIID__c == token) {
                                createtask = false;
                            }
                        }
                    } else {
                        createtasksforwaitlist.inserttask(Acctid.id, notes, token);
                    }
                }
                if (createtask) {
                    createtasksforwaitlist.inserttask(Acctid.id, notes, token);
                }
            }
        } catch (Exception e) {
            System.debug('An exception occurred during Web Service Call  Create/Update: ' + e.getMessage() + waitlist.waitListId);
        }
    }
    public pageReference makeSOACall() {
        try {
            GenerateWLforSOACall(mToken, mMarket, mMarkettype, mAccountId, mStatus, mDegree, mLeadroutingtype, mSlotSize, mMarketSpend, mNotes, mqtyinterested, mJson, moperation, mproduct);
            /*
            // Add to WaitListHistory - Venu
            if (moperation == 'Delete')
                AddWaitlistHistory.AddToWaitListHistory(mToken,'newValue','OldValue','AccountWaitList-DataController','Deleted');
            // Add to WaitListHistory - Venu
            */
        } catch (exception e) {
            System.debug('An exception occurred during Web Service Call  Create/Update: ' + e.getMessage());
        }
        return null;
    }
    public pageReference submit() {
        return null;
    }
    public pageReference SetPageSize() {
        mMyLimit = 'Take=10';
        return null;
    }
    global class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        public Waitlist[] aaData;
        public Response(Integer echo, Integer total, Waitlist[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }
    }
    private class Params {
        Map < String, Object > m = new Map < String, Object > ();
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        Integer[] sortColumns;
        String[] sortDirections;
        Params(List < Map < String, Object >> request) {
            for (Map < String, Object > r: request) {
                m.put((String) r.get('name'), r.get('value'));
            }
            echo = integer('sEcho');
            start = integer('iDisplayStart');
            length = integer('iDisplayLength');
            columns = stringArray('mDataProp');
            sortColumns = integerArray('iSortCol');
            sortDirections = stringArray('sSortDir');
        }
        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
                for (Object o: array(prefix)) {
                    strings.add(o != null ? esc(String.valueOf(o)) : null);
                }
            return strings;
        }
        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
                for (Object o: array(prefix)) {
                    integers.add(o != null ? Integer.valueOf(o) : null);
                }
            return integers;
        }
        Object[] array(String prefix) {
            Object[] objects = new Object[] {};
                for (Integer i = 0; true; i++) {
                    Object o = m.get(prefix + '_' + i);
                    if (o != null) {
                        objects.add(o);
                    } else {
                        break;
                    }
                }
            return objects;
        }
        Integer integer(String name) {
            Object o = m.get(name);
            if (o instanceof Decimal) {
                return ((Decimal) o).intValue();
            } else if (o instanceof Integer) {
                return (Integer) o;
            } else {
                return null;
            }
        }
        // Guard against SOQL injection
        String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }
    public class Waitlist {
        public string token {
            get;
            set;
        } // WL Id 
        public string product {
            get;
            set;
        } // product 
        public string geo {
            get;
            set;
        } // Market 
        public string status {
            get;
            set;
        } // Hot or Warm 
        public string geotype {
            get;
            set;
        } // Market Type 
        public string geosubtype {
            get;
            set;
        } // Market Sub Type
        public string leadroutingtype {
            get;
            set;
        } // Fast Flex 
        public string qtyinterested {
            get;
            set;
        } 
        
        public string degree {
            get;
            set;
        }
        public string notes {
            get;
            set;
        } // WL Notes 
        public string rank {
            get;
            set;
        } // WL Ranking from SFDC 
        public string invtotalavailable {
            get;
            set;
        } // Total Available 
        public string invtotalavailableflex {
            get;
            set;
        } // Total Available Flex
        public string invtotalavailablefast {
            get;
            set;
        } // Total Available Fast
        public string presalesavailable {
            get;
            set;
        } // Pre Sales Available 
        public string presalestotalavailable {
            get;
            set;
        } // Total Presales
        public string presalestotalavailableflex {
            get;
            set;
        } // Total Presales
        public string presalestotalavailablefast {
            get;
            set;
        } // Total Presales
        public string presalesavailabledate {
            get;
            set;
        } // Presales Available Date 
        public string preauthstatus {
            get;
            set;
        } // Pending , Completed 
        public string preauthstatusdate {
            get;
            set;
        } // Pending , Completed 
        public string createddate {
            get;
            set;
        } // date time 
        public string lastupdated {
            get;
            set;
        } // data time when last updated by user
        public string account_party_id {
            get;
            set;
        } // CDH Customer ID 
        public string sfdc_account_id {
            get;
            set;
        } // SFDC account id 
        public string accountname {
            get;
            set;
        } // Account Name
        public string slotsize {
            get;
            set;
        } // Half , Full , Any
        public string utilspend {
            get;
            set;
        }
        public string remnantspend {
            get;
            set;
        }
        public string marketspend {
            get;
            set;
        }
        public string waitlist_type {
            get;
            set;
        }
        public string phone {
            get;
            set;
        }
        public string createdby {
            get;
            set;
        }
        public string ownername {
            get;
            set;
        }
        public string bob {
            get;
            set;
        }
        public string accountsubtype {
            get;
            set;
        }
        public String rateCardPrice {
            get;
            set;
        }
        public String state{
            get;
            set;
        }
        public Waitlist() {}
    }
    @RemoteAction
    global static Response waitlists(List < Map < String, Object >> request) {
        Waitlist[] WLs;
        WaitlistWrapper[] WLW = new List < WaitlistWrapper > ();
        Response objResponse;
        Params p = new Params(request);
        String soql = '' + ' select ' + String.join(p.columns, ', ') + ' from Contact' + ' order by ' + String.join(orderBys(p), ', ') + ' limit :length' + ' offset :start';
        //System.debug('>>> soql=' + soql);
        Integer start = p.start;
        Integer length = p.length;
        if (WLs == null) {
            Integer i = 0;
            for (DataController.Waitlist obj: WLs) {
                WaitlistWrapper WLWObj = new WaitlistWrapper(obj, 'token', 'desc', String.join(orderBys(p), ' '));
                WLWObj.WL = obj;
                WLW.add(WLWObj);
                i++;
            }
            WLW.sort();
            i = 0;
            for (WaitlistWrapper obj1: WLW) {
                WLs[i] = (obj1.WL);
                i++;
            }
            objResponse = new Response(p.echo, WLs.size(),
                                       //    Database.query(soql)
                                       WLs);
            if (objResponse != null) {
                return objResponse;
            }
            return objResponse;
        } else {
            return objResponse;
        }
        //    System.debug('json =' + json); 
    }
    private static String[] orderBys(Params p) {
        Map < String, String > soqlDirections = new Map < String, String > {
            'asc' => 'asc',
                'desc' => 'desc'
                };
                    String[] orderBys = new String[] {};
                        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
        for (Integer i = 0; i < min; i++) {
            orderBys.add('' + p.columns[p.sortColumns[i]] + ' ' + soqlDirections.get(p.sortDirections[i]));
        }
        return orderBys;
    }
  
    // CRM-2134 returns true/false if given account has non-preauth waitlist.
    private Boolean hasNonPreAuthWaitList(String accountid) {
        Boolean hasNonPreAuthWL = null;
        // CRM-5206 - Added more filters to end point.
        String endPoint = allWaitlistGetURL + 'party_id=' + accountid + '&take=0&waitlist_status=active&waitlist_type!=Pre-Auth';
        System.debug('hasNonPreAuthWaitList - End Point - ' + endPoint);
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setHeader('Accept', 'application/json');
        try {
            HTTPResponse resp = http.send(req);
            String myjson = resp.getBody();
            System.debug('Response -- ' + myjson);
            JSONParser parser = JSON.createParser(myjson);
            while (parser.nextToken() != null) {
                 // CRM-5206 - Changed parsing logic as per new URL
                if(parser.getCurrentName()=='total' && parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                    Integer total = Integer.valueOf(parser.getText());
                    System.debug('Total Count -- ' + total);
                    if (total > 0) {
                        hasNonPreAuthWL = true;
                    }
                    else {
                        hasNonPreAuthWL = false;
                    }
                    break;
                }
            }
        }
        catch (Exception e) {
            System.Debug('e' + e);
        }
        
        return hasNonPreAuthWL;
    }
    // CRM-2134 End
    
    public List < Waitlist > GetWaitlistfromWebService() {
        System.debug('== >>Setep 1 ');
        //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        if (Test.isRunningTest()){
            showallactive = true;
        }
            
        String myjson;
        String myUrl;
        List < WLMaster > deserializedWL = new List < WLMaster > ();
        List < WLJson > WLJsonlist = new List < WLJson > ();
        transient List < Waitlist > AccountWL = new List<Waitlist>();
        Set < string > Partylist = new Set < string > ();
        integer i = 0;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        // set the method
        req.setMethod('GET');
        myUrl = 'http://dev-es-wls.api.move.com/search?';
        Waitlist_Urls__c InventoryReadURL = Waitlist_Urls__c.getInstance('Inventory Read');
        if (InventoryReadURL.url__c != null) {
            myUrl = InventoryReadURL.url__c;
        } else {
            myUrl = 'http://dev-es-wls.api.move.com/search?';
        }
        // CRM-2134 Maintain base URL to fecth account's all waitlists
        allWaitlistGetURL = myUrl;
        system.debug('---- my url -->'+myurl);
        myUrl = myUrl + mMyFilter;
        myUrl = myUrl + '&' + mMyLimit;
        myUrl = myUrl + '&' + mMyOrderBy;
        myUrl = myUrl + '&' + mMyPageNo;
        if (ApexPages.currentPage().getUrl().contains('MyWaitlist') && GlobalWaitlist) {
            if (mFilterType == null) {
                myUrl = InventoryReadURL.url__c + 'created_by=' + MyUserName1 + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Owner') {
                myUrl = InventoryReadURL.url__c + 'owner_name=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Created By') {
                myUrl = InventoryReadURL.url__c + 'created_by=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Product') {
                myUrl = InventoryReadURL.url__c + 'product_type=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Market') {
                myUrl = InventoryReadURL.url__c + 'market_name=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Waitlist Type') {
                myUrl = InventoryReadURL.url__c + 'waitlist_type=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Pre-Auth status') {
                myUrl = InventoryReadURL.url__c + 'waitlist_status=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Inventory Available Flex') {
                myUrl = InventoryReadURL.url__c + 'Inventory_Available_Flex=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Inventory Available Fast') {
                myUrl = InventoryReadURL.url__c + 'Inventory_Available_Fast=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Presales Available Flex') {
                myUrl = InventoryReadURL.url__c + 'Presales_Available_Flex=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Presales Available Fast') {
                myUrl = InventoryReadURL.url__c + 'Presales_Available_Fast=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Customer') {
                myUrl = InventoryReadURL.url__c + 'Account_name=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            } else if (mFilterType == 'Customer ID') {
                myUrl = InventoryReadURL.url__c + 'Party_id=' + filtervalue + '&' + mMyLimit + '&OrderByDesc=totalavailableflex,totalavailablefast&Skip=0';
            }
        }
        System.Debug('myUrl:' + myUrl);
        system.debug('showall1:==>>>>' + showall);
        system.debug('showcancel:==>>>>' + showcancel);
        system.debug('showfulfilled:==>>>>' + showfulfilled);
        system.debug('showexpired:==>>>>' + showexpired);
        system.debug('active: ==>>>'+ active); //CRM -498
        system.debug('showallactive: ==>>>'+ showallactive); //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        if(showall ){
            showcancel = false ; 
            showfulfilled = false ;
          showexpired = false ;  
          active = false; //CRM-498
          showallactive = false; //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        }
        //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
         if(showallactive){ 
            showcancel = false ; 
            showfulfilled = false ;
          showexpired = false ;  
          active = false; 
        }
        String myUrltemp ='&Waitlist_Status_In='; 
        boolean addto = false ;
        if(showcancel){
            myUrltemp= myUrltemp+'Canceled,';
            addto = true ;
           // showall = false ;
        }
        if(active){ //CRM-498
            myUrltemp= myUrltemp+'Active,';
            addto = true ; 
        } 
        //Added by Ravi CRM-1849 Show Active WAitlist with 0 Inventory
        if (showallactive){
            myUrltemp= myUrltemp+'Active,';
            addto = true ; 
        }
        if(showfulfilled){
            myUrltemp= myUrltemp+'Fulfilled,';
            addto = true ;
            //showall = false ;
        }
        if(showexpired){
            myUrltemp= myUrltemp+'Expired,';
            addto = true ;
            //showall = false ;
        }
        myUrltemp = myUrltemp.substring(0,myUrltemp.length()-1);
        System.debug('myUrltemp==>'+myUrltemp);
        //CRM-1711 Ravi added active condition in below If
        if((active==true || addto!=true) && showall != true && !ApexPages.currentPage().getUrl().contains('AccountWaitlist')) {
            myUrl = myUrl + '&OrFlexFastAvailable=0,0';
        }
        if(addto){
          myUrl= myUrl+myUrltemp ;  
        }
       
        
        System.Debug('myUrl1:===>>>' + myUrl);
        req.setTimeout(120000);
        req.setEndpoint(myUrl);
        req.setHeader('Accept', 'application/json');
        try {
            HTTPResponse resp = http.send(req);
            myjson = resp.getBody();
       
            //CRM-1848 - Sonali Bhardwaj - Clear local variables to avoid Apex Heap Size limits
            resp = null;
            
            System.debug('myjson=========== <<<'+myjson);
            JSONParser parser = JSON.createParser(myjson);
            
            //CRM-1848 - Sonali Bhardwaj - Clear local variables to avoid Apex Heap Size limits
            myjson = null;
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() == 'results') {
                    WLJson sto = (WLJson) parser.readValueAs(WLJson.class);
                    System.debug('stostostosto===>>>'+sto);
                    WLJsonlist.add(sto);
                }
                else if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'results') {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            WLJson sto = (WLJson) parser.readValueAs(WLJson.class);
                            WLJsonlist.add(sto);
                        }  
                    }  
                }  
            }
            
            //CRM-1848 - Sonali Bhardwaj - Clear local variables to avoid Apex Heap Size limits
            parser = null;  
        } 
        catch (Exception e) {
            System.Debug('e' + e);
        }
        try {
            //Added by Ravi CRM-1848 Waitlist Max Size limit
            //Integer maxrecords = Integer.valueof(Waitlist_Limit__c.getInstance('Max Number of Records').Value__c);
            
            system.debug('response size:==>>>>' + WLJsonlist.size() + WLJsonlist);
            for (WLJson obj1: WLJsonlist) {
                //Added by Ravi CRM-1848 Waitlist Max Size limit
                /*if (i==maxrecords)
                {
                    string message = 'There are too many rows. Displaying first '+maxrecords+' waitlist.';                      
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,message));
                    break;
                }*/
                
                system.debug('obj11:' + obj1);
                System.Debug('obj1.waitlist_guid ===>>>' + obj1.waitlist_guid);
                if (obj1.waitlist_guid != null || Test.isRunningTest()) {
                    Waitlist WL = new Waitlist();
                    WL.token = obj1.waitlist_guid;
                    if (obj1.product_type == 'Connection for Co-Brokerage') {
                        WL.product = 'CBC';
                    }else if(obj1.product_type == 'Local Expert'){
                       WL.product = 'Local Expert Zip'; 
                    }else {
                        
                        WL.product = obj1.product_type;
                    }
                    WL.geo = obj1.market_name;
                    WL.status = obj1.waitlist_status;
                    WL.geotype = obj1.market_type;
                    WL.geosubtype = obj1.market_subtype;
                    WL.leadroutingtype = obj1.lead_routing;
                    WL.slotsize = obj1.waitlist_slot;
                    WL.qtyinterested = obj1.quantity;
                    WL.degree = obj1.waitlist_degree;
                    //WL.createddate = obj1.created_date; // need to convert date time
                    WL.notes = obj1.comment;
                    WL.rank = obj1.ranking;
                    WL.invtotalavailable = obj1.inventory_available_flex; // + obj1.presalestotalavailableflex;
                    WL.invtotalavailableflex = obj1.inventory_available_flex;
                    WL.invtotalavailablefast = obj1.inventory_available_fast;
                    WL.presalestotalavailableflex = obj1.presales_available_flex;
                    WL.presalestotalavailablefast = obj1.presales_available_fast;
                    WL.account_party_id = obj1.party_id;
                    Partylist.add(obj1.party_id);
                    WL.marketspend = obj1.original_max_spend;
                    WL.utilspend = obj1.current_utilized_spend;
                    WL.remnantspend = obj1.remnant_spend;
                    System.debug('======>>>>>>>');
                    System.debug('===>'+obj1.waitlist_type);
                    WL.waitlist_type = obj1.waitlist_type;
                    WL.state = obj1.state_id;
                    WL.ownername = obj1.owner_name;
                    WL.createdby = obj1.created_by;
                    if(obj1.markets!=null){
                        if(obj1.markets.size()>0){
                            System.debug('resploop ===  Stage 1 >>'+obj1.markets);
                            for(WLJson.markets mkts : obj1.markets){
                                System.debug('Stage 2 ====>'+mkts);
                                // DAP-274: Updated if condition to populate rate card price for local expert
                                if(mkts.market_key.contains('FULL') || (obj1.product_type == 'Local Expert' && (obj1.waitlist_slot == 'Any' && mkts.market_key.contains('SOV50')) || (obj1.waitlist_slot != 'Any')) ){
                                    System.debug('Stage 3 ====>'+mkts);
                                    if(obj1.lead_routing=='Flex'){
                                        WL.rateCardPrice = mkts.historical_flex_unit_price;  
                                    }else if(obj1.lead_routing=='Fast'){
                                        WL.rateCardPrice = mkts.historical_fast_unit_price;  
                                    }else if(obj1.lead_routing=='Any'){
                                        WL.rateCardPrice = mkts.historical_flex_unit_price;    
                                        
                                    }  
                                    //  WL.Tier_Price_Number__c =    mkts.historical_tier_price_number ; 
                                }
                                
                            }
                        }else{
                            WL.rateCardPrice='';  
                        }
                    }else{
                        
                    }
                    
                    
                    try {
                        string dttm = obj1.created_date;
                        string dttm2 = dttm.replace('T', ' ');
                        Integer indx = dttm2.indexOf('.');
                        string newstr = dttm2.substring(0, indx);
                        datetime objdt = datetime.valueof(newstr);
                        String formattedDt = objdt.format('MM-dd-yyyy');
                        WL.createddate = formattedDt;
                    } catch (exception e) {
                       List <String> stringParts = obj1.created_date.split(' ');
                       List <String> timeParts = stringParts[1].split(':');
                       List <String> dateParts = stringParts[0].split('/');
                       if(stringParts[2] == 'PM') {timeparts[0] = string.valueOf(Integer.valueOf(timeparts[0])+12);}
                       else if (stringParts[2] == 'AM' && timeparts[0] == '12') { timeparts[0] = '00';} // CRM-2657 handle 12 AM for 24 hours format
                       Datetime dtObj = datetime.newInstanceGMT(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(timeParts[0]), Integer.valueOf(timeparts[1]), Integer.valueOf(timeParts[2]) );
                       String strConvertedDate = dtObj.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString());
                        WL.createddate = strConvertedDate;
                    }
                    if (AccountWL == null) {
                        AccountWL = new List < Waitlist > ();
                    }
                    AccountWL.add(WL);
                    //System.debug('AccountWL[i]' + AccountWL); 
                    i++;
                }
                //System.debug('Arun : Reached Array Completion ' + AccountWL);
            }
            
             //CRM-1848 - Sonali Bhardwaj - Clear local variables to avoid Apex Heap Size limits
            WLJsonlist = null; 
            
            //}
            //  System.debug('GW' + deserializedWL);
        } catch (Exception e) {
            //System.debug('Excption Occured during DeSearialiation' + e);
            return null;
        }
        if (AccountWL != null) {
            try {
                AccountWL = FillAccountValues(AccountWL, Partylist);
            } catch (exception e) {
            }
        } // account wl is not null
        return AccountWL;
    } // end of the class
    public class WLMaster {
        string offset {
            get;
            set;
        }
        string total {
            get;
            set;
        }
        List < WLJson > results {
            get;
            set;
        }
        Hotlist hotitem {
            get;
            set;
        }
        public WLMaster(string offset, string total, List < WLJson > results, Hotlist hotitem) {
            //System.debug('Arun : Entered Constructor WLMaster');
            this.offset = offset;
            this.total = total;
            this.results = results;
            this.hotitem = hotitem;
        }
    }
    public class Hotlist {
        string authorization_status {
            get;
            set;
        }
        string authorization_date {
            get;
            set;
        }
        string authorization_expiration {
            get;
            set;
        }
        string remnant_spend_per_month {
            get;
            set;
        }
        string waitlist_status_change_date {
            get;
            set;
        }
        string last_call_status {
            get;
            set;
        }
        string last_worked_date {
            get;
            set;
        }
        string pre_auth_status {
            get;
            set;
        }
        string pre_auth_status_date {
            get;
            set;
        }
        string pre_auth_expiry_date {
            get;
            set;
        }
        string original_max_spend {
            get;
            set;
        }
        string remnant_spend {
            get;
            set;
        }
        string current_utilized_spend {
            get;
            set;
        }
        string phone {
            get;
            set;
        }
        string monthly_spend_original {
            get;
            set;
        }
        string monthly_spend_current {
            get;
            set;
        }
        string monthly_spend_remaining {
            get;
            set;
        }
        string promotion {
            get;
            set;
        }
        string promotion_expiration_date {
            get;
            set;
        }
        public Hotlist(string authorization_status, string authorization_date, string authorization_expiration, string promotion, string promotion_expiration_date, string original_max_spend, string remnant_spend, string current_utilized_spend, string phone, string remnant_spend_per_month, string waitlist_status_change_date, string last_call_status, string last_worked_date, string pre_auth_status, string pre_auth_status_date, string pre_auth_expiry_date, string monthly_spend_original, string monthly_spend_current, string monthly_spend_remaining) {
            this.promotion = promotion;
            this.promotion_expiration_date = promotion_expiration_date;
            this.original_max_spend = original_max_spend;
            this.current_utilized_spend = current_utilized_spend;
            this.remnant_spend = remnant_spend;
            //this.utilized_spend_per_month =utilized_spend_per_month;
            this.phone = phone;
            this.remnant_spend_per_month = remnant_spend_per_month;
            this.waitlist_status_change_date = waitlist_status_change_date;
            this.last_call_status = last_call_status;
            this.last_worked_date = last_worked_date;
            this.pre_auth_status = pre_auth_status;
            this.pre_auth_status_date = pre_auth_status_date;
            this.pre_auth_expiry_date = pre_auth_expiry_date;
            this.monthly_spend_original = monthly_spend_original;
            this.monthly_spend_current = monthly_spend_current;
            this.monthly_spend_remaining = monthly_spend_remaining;
            this.authorization_status = authorization_status;
            this.authorization_date = authorization_date;
            this.authorization_expiration = authorization_expiration;
        }
    }
    
    
    
    
    public List < Waitlist > FillAccountValues(List < Waitlist > AccountWL, Set < string > Partylist) {
        List < Account > MyAcc;
        map < string, Account > acctmap = new map < string, Account > ();
        integer i = 0;
        integer j = 0;
        try {
            if (Partylist != null) {
                MYAcc = [SELECT Id, Name, Site, Party_ID__c, Phone, Territories__c, Account_Sub_Type__c FROM Account
                         WHERE Party_ID__c = : Partylist
                        ];
                for (Account acctloop: MYAcc) {
                    acctmap.put(acctloop.Party_ID__c, acctloop);
                }
            }
            for (Waitlist MyWaitlist: AccountWL) {
                if (MyWaitlist.account_party_id != null) {
                    if (acctmap.containskey(MyWaitlist.account_party_id)) {
                        MyWaitlist.phone = acctmap.get(MyWaitlist.account_party_id).Phone;
                        MyWaitlist.bob = acctmap.get(MyWaitlist.account_party_id).Territories__c;
                        MYWaitlist.sfdc_account_id = acctmap.get(MyWaitlist.account_party_id).Id;
                        MYWaitlist.accountname = acctmap.get(MyWaitlist.account_party_id).name;
                        MYWaitlist.accountsubtype = acctmap.get(MyWaitlist.account_party_id).Account_Sub_Type__c;
                        AccountWL[j] = MyWaitlist;
                    }
                }
                j++;
            } // master for loop   
        } catch (exception e) {
            // error WL field values will be skipped 
            System.debug('Error when retrieveing Account usign Customer ID JSON' + e.getMessage() + 'i' + i + 'is' + 'j' + j);
        }
        return AccountWL;
    } // end of function
    global class GUidclass {
        global string token{get;set;}
    }
    @RemoteAction
    Global static pageReference CancelPreAuth(List < GUidclass > WLGUid) {
        system.debug('WLGUid1:' + WLGUid);
        PageReference retrunref;
        set < String > GUIIds = New set < String > ();
        for (GUidclass GUIloop: WLGUid) {
            GUIIds.add(GUIloop.token);
        }
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = : profileId].Name;
        List < string > allowedprofiles = label.Profile_Names.split(',');
        Set < String > profilenames = New set < String > (allowedprofiles);
        If(!profilenames.contains(profileName)) {
            List < Waitlist_Item__c > WLIData = [select id, Status__c, Account__r.ownerid from Waitlist_Item__c where Waitlist_ID__c in : GUIIds];
            for (Waitlist_Item__c WLItem: WLIData) {
                If(WLItem.Account__r.ownerid != userinfo.getuserid()) {
                    retrunref = new PageReference('NotOwner');
                    retrunref.setRedirect(true);
                    return retrunref;
                } else {
                    datacontroller.ProcessCancelPreAuth(GUIIds);
                    retrunref = new PageReference('Success');
                    retrunref.setRedirect(true);
                    return retrunref;
                }
            }
        } else {
            datacontroller.ProcessCancelPreAuth(GUIIds);
            retrunref = new PageReference('Success');
            retrunref.setRedirect(true);
            return retrunref;
        }
        retrunref = new PageReference('Success');
        retrunref.setRedirect(true);
        return retrunref;
    }
    @future
    public static void ProcessCancelPreAuth(set < String > WLGUid) {
        system.debug('WLGUid2:' + WLGUid);
        try {
            List < Waitlist_Item__c > WLIData = [select id, Status__c from Waitlist_Item__c where Waitlist_ID__c in : WLGUid];
            for (Waitlist_Item__c WLItem: WLIData) {
                WLItem.Status__c = 'Canceled';
            }
            Update WLIData;
        } catch (Exception ex) {
            /*
Error__c error = new Error__c();
error.Name = 'Class - Datacontroller';
error.Entity_Id__c = 'Method - ProcessCancelPreAuth';
error.Interface_Name__c = 'While updating Waitlist_Item__c Object';
error.Error_Description__c = 'Message:' + ex.getMessage() + '$$$' + 'Stack trace:' + ex.getStackTraceString() + '$$$' + 'Failed Record Ids:';
Integer numErrors = ex.getNumDml();
for (Integer i = 0; i < numErrors; i++) {
error.Error_Description__c += ex.getDmlFieldNames(i);
}
insert error;
*/
        }
    }
    @RemoteAction
    Global static pageReference VoidEnvelope(List < GUidclass > WLGUid) {
        String envelopeId;
        String Reason;
        DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
        String accountId = DocSignCredentials.AccountId__c;
        String userId = DocSignCredentials.UserId__c;
        String password = DocSignCredentials.Password__c;
        String integratorsKey = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl = DocSignCredentials.WebServiceUrl__c;
        set < string > GUidset = new set < string > ();
        List < Waitlist_Item__c > WLIData = new List < Waitlist_Item__c > ();
        list < dsfs__DocuSign_Status__c > DocStatus = new list < dsfs__DocuSign_Status__c > ();
        PageReference retrunref;
        DocuSignAPI30.APIServiceSoap dsApiSend = new DocuSignAPI30.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.timeout_x = 120000;
        String auth = '<DocuSignCredentials><Username>' + userId + '</Username><Password>' + password + '</Password><IntegratorKey>' + integratorsKey + '</IntegratorKey></DocuSignCredentials>';
        dsApiSend.inputHttpHeaders_x = new Map < String, String > ();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = 'Pre-Auth Cancellation';
        envelope.EmailBlurb = 'Please find the Pre-Auth cancelling products in the form';
        envelope.AccountId = accountId;
        try {
            for (GUidclass GUIloop: WLGUid) {
                GUidset.add(GUIloop.Token);
            }
            WLIData = [select Waitlist__c from Waitlist_Item__c where Waitlist_ID__c in : GUidset];
            set < id > waitlistitem = new set < id > ();
            for (Waitlist_Item__c WLItem: WLIData) {
                waitlistitem.add(WLItem.Waitlist__c);
            }
            DocStatus = [select dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c
                         where Waitlist__c IN: waitlistitem
                        ];
            if (DocStatus.size() == 0) {
                retrunref = new PageReference('No envelope id found for this request');
                retrunref.setRedirect(true);
                return retrunref;
            }
        } catch (QueryException error) {
            retrunref = new PageReference(error.getMessage());
            retrunref.setRedirect(true);
            return retrunref;
        } catch (Exception error) {
            retrunref = new PageReference(error.getMessage());
            retrunref.setRedirect(true);
            return retrunref;
        }
        try {
            for (dsfs__DocuSign_Status__c DSloop: DocStatus) {
                EnvelopeID = DSloop.dsfs__DocuSign_Envelope_ID__c;
                Reason = 'Cancelling the Pre-Auth as no response received from long time';
                DocusignApi30.VoidEnvelopeStatus VoidStatus = dsApiSend.VoidEnvelope(EnvelopeID, Reason);
            }
        } catch (CalloutException DSerror) {
            Error__c logerror = new Error__c();
            logerror.Name = EnvelopeID;
            logerror.Entity_Id__c = 'Waitlist Void';
            logerror.Error_Description__c = string.valueof(DSerror);
            logerror.Interface_Name__c = 'DocuSign';
            Insert logerror;
            retrunref = new PageReference(DSerror.getMessage());
            retrunref.setRedirect(true);
            return retrunref;
        }
        retrunref = new PageReference('Success');
        retrunref.setRedirect(true);
        return retrunref;
    }
    
    // CRM-1741 to maintain waitlist history
    public static Waitlist_History__c createWaitListHistory(String accountId, String fieldEvent, String oldValue, String newValue, String waitlistId, String marketCode, String type) {
        
        return new Waitlist_History__c( Account__c = accountId,
                                        Edit_Date__c = System.now(),
                                        Edited_By__c = userInfo.getUserId(),
                                        Field_Event__c = fieldEvent,
                                        New_Value__c = newValue,
                                        Old_Value__c = oldValue,
                                        Page_Reference__c = ApexPages.CurrentPage().getUrl().split('apex/')[1].split('\\?')[0],
                                        WaitList_ID__c = waitlistId,
                                        Market_Code__c = marketCode,
                                        Type__c = type
                                      );
                                        
    }
    
    // CRM-1741 End
    
    // CRM-2318 - Perform DML in future method to make VF readonly=true
    @future
    private static void DMLsonWaitListDelete(Id accountId, String waitListHistoryJson) {
        // To update Non_Pre_Auth_Waitlist__c to false if it was last Non-Preauth waitlist deleted.
        if (accountId != null) {
            update new Account(id = accountId, Non_Pre_Auth_Waitlist__c = false);
        }
        
        // Insert waitlist history record for delete
        Waitlist_History__c history = (Waitlist_History__c)JSON.deserialize(waitListHistoryJson, Waitlist_History__c.class);
        insert history;
        
    }
    // CRM-2318 End
}