public class PreAuthWaitListRenewalExtn {

    public static List<String> errors = new List<String>();
    //option variables
    List<SelectOption> states;
    List<SelectOption> counties;
    List<SelectOption> cities;
    List<SelectOption> cities2;
    List<SelectOption> cities3;
    List<SelectOption> cities4;
    Set<String> allcitiesSet = new Set<String>();
    List<SelectOption> postalCodes;
    List<SelectOption> postalCodes2;
    List<SelectOption> postalCodes3;
    List<SelectOption> postalCodes4;
    List<SelectOption> waitlistProductTypes;
    List<SelectOption> renewalProducts;
    List<SelectOption> preAuthTypes; //CRM-2308
    List<Selectoption> leadRoutes;
        List<Selectoption> productsizes;
    List<WaitListItem> waitListItems;
    Set<String> marketSets;
   
    //input Variables
    Date preauthEffectiveDate;
    String preAuthType;  //CRM-2308
    String waitlistProductType;
    String selproduct;
    String leadRoute;
        String productsize;
    String state;
    String markets;
    String ccLast4Digits;
    List<String> selectedCounties;
    List<String> selectedCities;
    List<String> selectedPostalCodes;
    Decimal totalMaxSpend;

    //rendering variables
    Boolean showCity;
    Boolean showPostalCode;
    Public Boolean showSubmit {get; set;}
   

    //Controller Variable
    private final Account account;
    private final User user;
    private final List<PaymentProfiles__c> paymentProfiles;
    private final List<Account_Relationship__c> accountRelations;
    private final Set<String> cclast4digitsSet;
    private date activeWaitlistExpiryDate;
        
    //Constructor
    public PreAuthWaitListRenewalExtn(ApexPages.StandardController controller) {
        //getting values for standard controller account
        if(!Test.isRunningTest()){
        controller.addFields(new List<String>{
                                 'id', 
                                 'Type',
                                 'BillingState',
                                 'Party_ID__c',
                                 'Account_Sub_Type__c',
                                 'Name', 
                                 'Owner.NT_Login_Id__c',
                                 'Preferred_Phone__c',
                                 'Total_MAX_Monthly_Pre_Auth_Spend__c',
                                 'Current_Monthly_Pre_Auth_Spend__c',
                                 'Billing_Preference__c'});
        }
        account = (Account) controller.getRecord();
        user = PreAuthWaitListRenewalUtil.getUserDetails();
        paymentProfiles = PreAuthWaitListRenewalUtil.getPaymentDetails(account.id);
        accountRelations = PreAuthWaitListRenewalUtil.getAccountRelations(account.id);
        //loading the data
        if(dataValidated()){
            initialize();
            cclast4digitsSet = ccLast4DigitsOnProfiles();
            showSubmit = user.Pre_Auth_User__c;
        }      
    }

    //All Getters for options
    public List<Selectoption> getStates(){ return states; }
    public List<Selectoption> getCounties(){ return counties; }
    public List<Selectoption> getCities(){ return cities; }
    public List<Selectoption> getCities2(){ return cities2; }
    public List<Selectoption> getCities3(){ return cities3; }
    public List<Selectoption> getCities4(){ return cities4; }
    public List<Selectoption> getPostalCodes(){ return postalCodes; }
    public List<Selectoption> getPostalCodes2(){ return postalCodes2; }
    public List<Selectoption> getPostalCodes3(){ return postalCodes3; }
    public List<Selectoption> getPostalCodes4(){ return postalCodes4; }
    public List<Selectoption> getWaitlistProductTypes(){ return waitlistProductTypes; }
    public List<Selectoption> getrenewalproducts(){ return renewalproducts; }

    public List<SelectOption> getPreAuthTypes(){return preAuthTypes;} //CRM-2308
    public List<Selectoption> getLeadRoutes(){ return leadRoutes; }
    public List<Selectoption> getProductSizes(){ return productsizes; }
    public boolean getShowCity(){ return showCity;}
    public boolean getShowPostalCode(){ return showPostalCode; }
    public List<WaitListItem> getWaitListItems() { return waitListItems;}


    //All getters for input variables
    public Date getPreauthEffectiveDate() { return preauthEffectiveDate; }
    public String getWaitListProductType() { return waitlistProductType; }
    public String getselproduct() { return selproduct; }
    public String getPreAuthType() {return preAuthType;} //CRM-2308
    public String getLeadRoute() { return leadRoute; }
    public String getProductSize() { return productsize; }
    public String getState() { return state; }
    public String getMarkets() { return markets; }
    public String getCcLast4Digits() { return ccLast4Digits; }
    public List<String> getSelectedCounties() { return selectedCounties; }
    public List<String> getSelectedCities() { return selectedCities; }
    public List<String> getSelectedPostalCodes() { return selectedPostalCodes; }
    public Decimal getTotalMaxSpend() { return totalMaxSpend; }

    //All Setters for options
    public Void setStates(List<Selectoption> options){ states = options; }
    public Void setCounties(List<Selectoption> options){ counties = options; }
    public Void setCities(List<Selectoption> options){ cities = options; }
    public Void setCities2(List<Selectoption> options){ cities2 = options; }
    public Void setCities3(List<Selectoption> options){ cities3 = options; }
    public Void setCities4(List<Selectoption> options){ cities4 = options; }
    public Void setPostalCodes(List<Selectoption> options){ postalCodes = options; }
    public Void setPostalCodes2(List<Selectoption> options){ postalCodes2 = options; }
    public Void setPostalCodes3(List<Selectoption> options){ postalCodes3 = options; }
    public Void setPostalCodes4(List<Selectoption> options){ postalCodes4 = options; }
    public Void setWaitlistProductTypes(List<Selectoption> options){ waitlistProductTypes = options; }
    public Void setrenewalproducts(List<Selectoption> options){ renewalproducts = options; }

    public Void setPreAuthTypes(List<Selectoption> options){ preAuthTypes = options; } //CRM-2308

    public Void setLeadRoutes(List<Selectoption> options){ leadRoutes = options; }
    public Void setProductSizes(List<Selectoption> options){ productsizes = options; }
    public void setShowCity(Boolean flag){showCity = flag;}
    public void setShowPostalCode(Boolean flag){showPostalCode = flag;}
    public void setWaitListItems(List<WaitListItem> items) { waitListItems = items;}
    public void setMarketSets(Set<String> markets) { marketSets = markets; }

    //All setters for input variables
    public Void setPreauthEffectiveDate(Date input) { preauthEffectiveDate = input; }
    public Void setWaitListProductType(String input) { waitlistProductType = input; }
    public Void setselproduct(String input) { selproduct = input; }

    public void setPreAuthType(String input){system.debug('this is setter for preauthtype '+input);preAuthType = input;} //CRM-2308
    public Void setLeadRoute(String input) { leadRoute= input; }
    public Void setProductSize(String input) { productsize= input; }
    public Void setState(String input) { state= input; }
    public Void setMarkets(String input) { markets = input; }
    public Void setCcLast4Digits(String input) { ccLast4Digits = input; }
    public Void setSelectedCounties(List<String> input) { selectedCounties = input; }
    public Void setSelectedCities(List<String> input) { selectedCities = input; }
    public Void setSelectedPostalCodes(List<String> input) { selectedPostalCodes = input; }
    public void setTotalMaxSpend(Decimal input) { totalMaxSpend = input; }
    
    public Boolean dataValidated(){
        Boolean success = TRUE;
        if(account.Type == 'Realtor Office') { 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Waitlsit can\'t be created for Realtor Office'));
            success=FALSE;
        }
        if(account.billingState != null && State_Abbreviations__c.getInstance(account.billingstate) == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please correct the Bill To Address on the Account to be abbreviated and capitalized.'));
            success=FALSE;
        }
        if(account.billingState == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Account should have billing state ,Please return to the Account and correct this before creating waitlist'));
            success=FALSE;
        }
        if(account.Preferred_Phone__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This Account does not have a Preferred Phone number. Please return to the Account and update the Preferred Phone before Saving/Submitting the Waitlist'));
            success=FALSE;
        }
        if(user.NT_Login_ID__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Current User doesn\'t have NT Log in ID'));
            success=FALSE;
        }
        if(accountRelations.size() > 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'More than one active Primary contact\'s exists for Account "'+account.name+'"'));
            success = FALSE;
        }
        if(accountRelations.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact is required for the account "'+account.Name+'"'));
            success=FALSE;
        }
        if(accountRelations[0].Parent_Account__r.Email_Address__c == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This waitlist cannot be submitted/saved as the Account  '+accountRelations[0].Parent_Account__r.Name+' does not have an email. Please update the email and re-submit the Waitlist.'));
            success=FALSE;
        }
        if(paymentProfiles.size() == 0 && (account.Billing_Preference__c == 'Invoice-CC' || account.Billing_Preference__c == 'Arrears-CC' || account.Billing_Preference__c == 'CC-Direct')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Payment profile is required for the account "'+account.Name+'" to create Pre-Auth waitlist')) ;
            success=FALSE;
        }
        if(paymentProfiles.size() == 0 && (account.Billing_Preference__c == 'Invoice-CC' || account.Billing_Preference__c == 'Arrears-CC' || account.Billing_Preference__c == 'CC-Direct')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Account With Invoice-CC or CC-Direct Should have greater than zero split percentage ')) ;
            success=FALSE;
        }
        return success;
    }

    public Set<String> ccLast4DigitsOnProfiles(){
        Set<String> ccSet = new Set<String>();
        for(PaymentProfiles__c payment : paymentProfiles){
            ccSet.add(payment.MaskNumber__c.right(4));
        }
        return ccSet;
    }

    public boolean checkMaxSpend(){
        Boolean invalid = FALSE;
        if(waitlistitems != null && waitlistitems.size()>0){
            for(WaitListItem item : waitlistitems){
                if(item.maxSpend == null || item.maxSpend == 0){
                    invalid = TRUE;
                    break;
                }
            }
        }
        return invalid;
    }

    public Boolean inputDataValidated(){
        Boolean success = TRUE;
        if(preauthEffectiveDate <SYSTEM.TODAY()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Pre-Auth Effective Date Should not be past date'));
            success = FALSE;
        }
        if(!(preauthEffectiveDate >= SYSTEM.TODAY() && preauthEffectiveDate <= activeWaitlistExpiryDate)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Pre-Auth Effective Date should be before active waitlist expiry date'));
            success = FALSE;
        }
        if((account.Billing_Preference__c == 'Invoice-CC' || account.Billing_Preference__c == 'Arrears-CC' || account.Billing_Preference__c == 'CC-Direct') && cclast4digitsSet != null && !cclast4digitsSet.contains(ccLast4Digits)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The \"Credit Card Last 4 Digits\" does not match the information on the Payment Profile(s). Please check the Payment Profile(s) on the Account and re-enter.'));
            success = FALSE;
        }
        if(account.Total_MAX_Monthly_Pre_Auth_Spend__c < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The Total MAX Monthly Pre-Auth Spend cannot be 0 or less than 0'));
            success = FALSE;
        }
        if(checkMaxSpend()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The Max Spend for the selected market(s) cannot be 0 or less than 0'));
            success = FALSE;
        }
        
        return success;
    }
    
    //Action Buttons Logic
    public pageReference addToList(){
        system.debug('--- inside the add to list button code --> ');
        system.debug('--- selproduct --> '+selproduct);
        system.debug('--- waitlistitems --> '+waitListItems);
        system.debug('---- selectedPostalCodes -->'+selectedPostalCodes);
        system.debug('--- waitlistProductType --> '+waitlistProductType);
        system.debug('---- state -->'+state);
        system.debug('--- leadRoute -->'+ leadRoute);
        system.debug('--- productsize -->'+productsize);
        system.debug('--- marketSets --> '+marketSets);
        system.debug('--- markets --> '+markets);
        system.debug('--- allcitiesSet -->'+allcitiesSet);
        errors.clear();
        if(waitlistProductType == 'PostalCode' || waitlistProductType == 'Postal Code'){
        system.debug('inside the postal code');
        setWaitListItems(PreAuthWaitListRenewalExtnUtil.addMoreItems(selproduct, waitListItems, selectedPostalCodes, waitlistProductType, state, leadRoute, productsize, marketSets, markets, allcitiesSet));
        }
        else if(waitlistProductType == 'City')
        {
        system.debug('inside the city ');
        setWaitListItems(PreAuthWaitListRenewalExtnUtil.addMoreItems(selproduct, waitListItems, selectedCities, waitlistProductType, state, leadRoute, productsize, marketSets, markets, allcitiesSet));
       }
        
        else if(waitlistProductType == 'County'){
        system.debug('inside county ');
        setWaitListItems(PreAuthWaitListRenewalExtnUtil.addMoreItems(selproduct, waitListItems, selectedCounties, waitlistProductType, state, leadRoute, productsize, marketSets, markets, allcitiesSet));
        }
        setMarketSets(PreAuthWaitListRenewalUtil.setMarkets(waitListItems));
        if(!errors.isempty()){
            system.debug('inside errors');
            for(String err : errors){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,err));

            }
        }
        
        return null;
    }

    public pageReference refresh(){
        initialize();
        return null;
    }

    public pageReference submit(){
        if(inputDataValidated() || Test.isRunningTest()){
            showSubmit = false;
            account.Total_MAX_Monthly_Pre_Auth_Spend__c  = totalMaxSpend;
            setWaitListItems(PreAuthWaitListRenewalExtnUtil.submitInventory(waitlistItems, account, user, ccLast4Digits, preauthEffectiveDate, preAuthType)); //CRM-2308
            update account;

        }
        return null;
    }

    
    public void onChangePreAuthType(){ //CRM-2308
        setWaitListItems(PreAuthWaitListRenewalExtnUtil.waitListItems(account.Id, preAuthType)); //CRM-2308
    }
    
    public void onChangeState(){
        setCounties(PreAuthWaitListRenewalExtnUtil.counties(state));
        setSelectedCounties(PreAuthWaitListRenewalExtnUtil.selectedCounties(counties));
        handleCities();
        setSelectedCities(PreAuthWaitListRenewalExtnUtil.selectedCities(cities));
        handlePostalCodes();
    }

    public void onChangeCounty(){
        handleCities();
        setSelectedCities(PreAuthWaitListRenewalExtnUtil.selectedCities(cities));
    }
    
    public void onChangeCity(){
        handlePostalCodes();
    }
    
    public void onChangeWaitListType(){
        if(waitlistProductType == 'County') { showCity = FALSE; showPostalCode = FALSE; } 
        else if(waitlistProductType == 'City') { showCity = TRUE; showPostalCode = FALSE; }
        else if(waitlistProductType == 'Postal Code') { showCity = TRUE; showPostalCode = TRUE; }              
    }
    
    public void onChangeProducts(){
        system.debug('selproduct -->'+selproduct);
        if(selproduct == 'Local Expert Zip' || selproduct == 'Local Expert City'){
            
            setLeadRoutes(PreAuthWaitListRenewalExtnUtil.leadRoutesLE());
            setleadroute('Flex');
            if(selproduct == 'Local Expert City'){
                setproductsizes(PreAuthWaitListRenewalExtnUtil.productsizesLEC());
                setproductsize('SOV10');
                showPostalCode = FALSE;
                
                if(waitlistProductType == 'County'){
                    showCity = true;
                }
                waitlistProductTypes.clear();
                waitlistProductTypes.add(new SelectOption('City', 'City'));
                waitlistProductType = 'City';
            }else{
                setProductSizes(PreAuthWaitListRenewalExtnUtil.productsizesLE());
                setproductsize('Any'); //DAP-314
                setWaitlistProductTypes(PreAuthWaitListRenewalExtnUtil.waitlistProductTypes());
                SetWaitlistProducttype('PostalCode');
            }
        }else{
            setLeadRoutes(PreAuthWaitListRenewalExtnUtil.leadRoutes());
            setleadroute('Any');
            setProductSizes(PreAuthWaitListRenewalExtnUtil.productsizes());
            setproductsize('Any');
            setWaitlistProductTypes(PreAuthWaitListRenewalExtnUtil.waitlistProductTypes());
        }
    }
    
    public void deleteRow(){
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        marketSets.remove((waitListItems.remove(rowIndex)).market);
        setWaitListItems(PreAuthWaitListRenewalUtil.resetRowNumbers(waitListItems));
    }

    public void handleCities(){
        List<SelectOption> allCities = PreAuthWaitListRenewalExtnUtil.cities(state, selectedCounties);
        allcitiesSet = PreAuthWaitListRenewalExtnUtil.citiesSet(state, selectedCounties);
        system.debug('-- allCities.size()-->'+allCities.size());
        List<SelectOption> subSets = new List<SelectOption>();
        integer index = 0;
        if(allCities.size() <1000){
            setCities(allCities);
        }else{            
            while(index<1000) {
              subSets.add(allCities[index++]);
            }
            setCities(subSets);
            index=1000;
            subsets.clear();
            while(index<2000 && index<allcities.size()) {
              subSets.add(allCities[index++]);
            }
            setCities2(subSets);
            index = 2000;
            subsets.clear();
            while(index<3000 && index<allcities.size()) {
              subSets.add(allCities[index++]);
            }
            setCities2(subSets);
            index = 3000;
            subsets.clear();
            while(index<4000 && index<allcities.size()) {
              subSets.add(allCities[index++]);
            }
            setCities4(subSets);
            subSets.clear();
        }
    }

    public void handlePostalCodes(){
        List<SelectOption> allPostalCodes = PreAuthWaitListRenewalExtnUtil.postalCodes(state, selectedCities);
        system.debug('-- allPostalCodes.size()-->'+allPostalCodes.size());
        List<SelectOption> subSets = new List<SelectOption>();
        integer index = 0;
        if(allPostalCodes.size() <1000){
            setPostalCodes(allPostalCodes);
        }else{            
            while(index<1000) {
              subSets.add(allPostalCodes[index++]);
            }
            setPostalCodes(subSets);
            index=1000;
            subsets.clear();
            while(index<2000 && index<allPostalCodes.size()) {
              subSets.add(allPostalCodes[index++]);
            }
            setPostalCodes2(subSets);
            index = 2000;
            subsets.clear();
            while(index<3000 && index<allPostalCodes.size()) {
              subSets.add(allPostalCodes[index++]);
            }
            setPostalCodes3(subSets);
            index = 3000;
            subsets.clear();
            while(index<4000 && index<allPostalCodes.size()) {
              subSets.add(allPostalCodes[index++]);
            }
            setPostalCodes4(subSets);
            subSets.clear();
        }
    }
    
    private void initialize(){

        //loading the default values
        setpreAuthTypes(PreAuthWaitListRenewalExtnUtil.preAuthTypes()); //CRM-2308
        setPreAuthType('Renew'); //CRM-2308
        setWaitlistProductTypes(PreAuthWaitListRenewalExtnUtil.waitlistProductTypes());
        setrenewalProducts(PreAuthWaitListRenewalExtnUtil.renewalproducts());
        waitlistProductType = 'Postal Code';
        selproduct = 'Connection for Co-Brokerage';
        setLeadRoutes(PreAuthWaitListRenewalExtnUtil.leadRoutes());
        leadRoute = 'Any';
        setStates(PreAuthWaitListRenewalExtnUtil.states());
        state = State_Abbreviations__c.getInstance(account.billingState).Full_Name__c;
        setCounties(PreAuthWaitListRenewalExtnUtil.counties(state));
        setSelectedCounties(PreAuthWaitListRenewalExtnUtil.selectedCounties(counties));
        handleCities();
        setSelectedCities(PreAuthWaitListRenewalExtnUtil.selectedCities(cities));
        handlePostalCodes();
        setSelectedPostalCodes(PreAuthWaitListRenewalExtnUtil.selectedPostalCodes(postalCodes));
        preauthEffectiveDate = system.today();
        markets = '';
        setShowCity(true);
        setShowPostalCode(true);
        setWaitListItems(PreAuthWaitListRenewalExtnUtil.waitListItems(account.Id, preAuthType)); //CRM-2308
        setMarketSets(PreAuthWaitListRenewalUtil.setMarkets(waitListItems));
        setTotalMaxSpend(PreAuthWaitListRenewalUtil.setTotalMaxSpend(account.Id));
        activeWaitlistExpiryDate = PreAuthWaitListRenewalUtil.activeWaitlistExpiryDateSet(account.Id).addDays(1);
    }
    
        
    
   
   
}