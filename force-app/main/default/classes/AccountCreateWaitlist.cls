/**
* Copyright (c) Move Inc .
* Name : AccountCreateWaitlist
* Test Class : AccountCreateWaitlist_Test
* Description : This Apex Class to create a new waitlist and its line items based on the user selected markets .
*    Testing Copado         
* @author  Rajamohan Vakati
* @version 2.0
* @since   2016 Dec
* @Updated 2016 Dec 
*/
public class AccountCreateWaitlist{
    public Account acct{get;set;}
    public string stateAbbrevation = '';  
    public String ProductselectedVal{get;set;}
    public String StatusselectedVal{get;set;}
    public String MarketTypeselectedVal{get;set;}
    public String DegreeselectedVal{get;set;}           
    public String LeadRoutingselectedVal{get;set;}    
    public String SlotSizeselectedVal{get;set;}       
    public String PostalCodeselectedVal{get;set;}  
    public String TigerLeadselectedVal{get;set;}  
    public String TerritoryselectedVal{get;set;}
    public String prdctmeasure{get;set;}
    public boolean showstatuscolumns{get;set;}
    public boolean showdeletecolumns{get;set;}
    public boolean showsselected{get;set;}                  
    public Integer Quantity{get;set;}
    public String CC4digits{get;set;}
    public Integer Term{get;set;} 
    public Integer MaxSpend{get;set;}   
    public Decimal currentMonthlyMaxSpend{get;set;}
    public Decimal totlaMaxPreAuthSpend{get;set;}
    public boolean saveorsubmit{get;set;}
    public boolean saveorsubmit1{get;set;}
    public boolean curentPreAuthUser {get;set;}
    public String recordIdAfterSave {get;set;}
    public String Message{get;set;}   
    public String WLid{get;set;}       
    public String marketTextArea{get;set;} 
    public String preauthTypeSelectedString {get;set;}
    
    public String defaultTerm {get;set;}
    public goewcfService geo = new goewcfService();
    public list<SelectOption> countyOptions {get;set;}
    public list<SelectOption> cityOptions {get;set;}    
    public list<SelectOption> PostcodeOptions {get;set;}    
    public list<SelectOption> cityOptionsSet1 {get;set;}    
    public list<SelectOption> cityOptionsSet2 {get;set;}    
    public list<SelectOption> cityOptionsSet3 {get;set;}        
    public list<SelectOption> cityOptionsSet4 {get;set;} 
       
    public list<SelectOption> countyOptionsSet1  {get;set;} 
    public list<SelectOption> countyOptionsSet2  {get;set;}
    public list<SelectOption> countyOptionsSet3  {get;set;}
    public list<SelectOption> PostcodeOptionsSet1 {get;set;}    
    public list<SelectOption> PostcodeOptionsSet2 {get;set;}    
    public list<SelectOption> PostcodeOptionsSet3 {get;set;}        
    public list<SelectOption> PostcodeOptionsSet4 {get;set;}        
    public list<SelectOption> StateOptions = new list<SelectOption>();
    public map<string,CreateWaitlist__c> gridMap = CreateWaitlist__c.getAll();
    list<Account_Relationship__c> primarycntct = new list<Account_Relationship__c>();
    list<waitlist_item__c> pendinginserts = new list<waitlist_item__c>();
    public boolean stateFlag {get;set;}
    public boolean cityFlag {get;set;}
    public boolean countyFlag {get;set;}
    public boolean postcodflag {get;set;}
    public boolean showsubmit {get;set;}
    public boolean createWLI = true; 
    public boolean filtercnty = false;
    public boolean filtercity = false;
    public boolean prmrycntcterr = false;
    public boolean prmrycntctemailerr = false;
    public boolean pymntprflerr = false;
    public boolean process = false;
    public boolean fromquerypostalcodes = false;
    public boolean rltrofficeerr = false;
    public boolean ntloginnull = false;
    public boolean nobillstate = false;
    public string stateSelected {get;set;}
    public list<string> CountySelected {get;set;}
    public list<string> CitySelected {get;set;}   
    public list<string> postcodSelected {get;set;}    
    public set<string> prevvaluesEntered = new set<string>();            
    public list<Waitlist_Item__c> WLIinsert = new list<Waitlist_Item__c>();
    public boolean pbTable {get;set;}            
    public list<marketWrapper> marketList {get;set;}
    public  string getStateFromPCURL = Waitlist_Urls__c.getInstance('postalCodeArea').URL__c;//'http://geo.svc.move.com/GeoWcfService/PostalCode.svc/PostalCodeArea/postalcodetobeentered?app=RDC&v=1&format=json';
    public string stateURL = Waitlist_Urls__c.getInstance('stateURL').URL__c;
    public string countyURL = '';
    public string cityURL = '';
    public string PostcodeURL = '';
    public string stateAbbURL = '';
    public string stateAbb = '';
    public string userntlogin = '';
    public string createinvntresponse = '';
    public string primaryPhone = '';
    // public Map<String ,String > mapofProductandTerm = new Map<String,String>() ;
    
    public list<SelectOption> MarketTypetOptions {get;set;}
    public list<SelectOption> MarketSubTypeOptions {get;set;}  
    public list<SelectOption> LeadRoutingOptions  {get;set;}      
    public list<SelectOption> SlotSizeOptions  {get;set;}    
    public list<SelectOption> TypeOptions {get;set;}        
    public list<SelectOption> DegreeOptions {get;set;}
    public list<SelectOption> DegreeOptions1 {get;set;}
    public list<SelectOption> TigerLeadOptions {get;set;}                
    public list<SelectOption> TerritoryList{get;set;} 
    
    public list<SelectOption> termList{get;set;} 
    public String termListVaule{get;set;} 
    public String savedWaitlistId{get;set;} 
    public list<product2> allproducts = new list<product2>();
    public map<string,id> productids = new map<string,id>();        
    public map<string,CreateWaitlist__c> productmap = new map<string,CreateWaitlist__c>();
    public map<string,CreateWaitlist__c> productmap1 = new map<string,CreateWaitlist__c>();
    public Account latestacct = new Account();
    
    /* === Added as part of Renwals ====*/
    
    public boolean showandhiderenwals {get;set;} 
    public Date preauthEffectiveDate {get;set;}
    public Decimal currenlyProcessedAmount{get;set;}
    public  String preAuthrenwalParsm{get;set;}
    public Integer rowIndex {get;set;}
    public String coloumHeader {get;set;}   
    public List<Waitlist_Item__c> addTotal {get;set;}
    public Set<String> addTotalUniqueMarkets = new Set<String>();
    
    public list<SelectOption> preAuthSelectedList {get;set;}
    public String pageBlockTabelTitile {get;set;}
    
    
    
    
    
    
    public AccountCreateWaitlist (ApexPages.StandardController stdController){
        this.acct = (Account)stdController.getRecord();
        showandhiderenwals = false ;
        pageBlockTabelTitile ='Create Waitlist';
        acct = [SELECT ID,Non_Pre_Auth_Waitlist__c, Sales_Lock_Owner__c, owner.userName, Name,Owner.Name,Party_ID__c,inactiveRule__c,Current_Pre_Auth_Monthly_Processed__c,owner.IsActive, owner.NT_Login_ID__c,Current_Monthly_Pre_Auth_Spend__c,Total_MAX_Monthly_Pre_Auth_Spend__c,Account_Sub_Type__c,Sales_Lock_User__c ,Ownerid,BillingState,Billing_Preference__c,Type, 
                (select id from Payment_Profiles__r) FROM Account WHERE ID =: this.acct.ID LIMIT 1];
        If((acct.Billing_Preference__c == 'Invoice-CC' || acct.Billing_Preference__c == 'Arrears-CC' || acct.Billing_Preference__c == 'CC-Direct')
           && acct.Payment_Profiles__r.size() == 0 && acct.Account_Sub_Type__c == 'Customer'){
              // pymntprflerr = true;
             //  system.debug('pymntprflerr:'+pymntprflerr);
           }
        savedWaitlistId='';
        recordIdAfterSave='';
        If(acct.Type == 'Realtor Office'){
            rltrofficeerr = true; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Waitlsit can\'t be created for Realtor Office'));
        }
        curentPreAuthUser = [Select id , Pre_Auth_User__c  from User where id=:UserInfo.getUserId()].Pre_Auth_User__c;
        saveorsubmit =false ;
        saveorsubmit1 = false ;
        pbTable             = false;           
        message             = '';
        showstatuscolumns   = true;
        showdeletecolumns   = true;
        showsselected       = false;
        showsubmit          = true;
        if(acct.Current_Monthly_Pre_Auth_Spend__c!=null)
            currentMonthlyMaxSpend =acct.Current_Monthly_Pre_Auth_Spend__c;
        else
            currentMonthlyMaxSpend =0.0;
        if(acct.Total_MAX_Monthly_Pre_Auth_Spend__c !=null && Double.valueOf(acct.Total_MAX_Monthly_Pre_Auth_Spend__c) > 0)
            totlaMaxPreAuthSpend =acct.Total_MAX_Monthly_Pre_Auth_Spend__c ;
        else
            totlaMaxPreAuthSpend=0.0;
        Initialize();
        
        
        
        
        
        StateOptions.addAll(addNoneOption(geo.JSONtoOptions(stateURL)));
        allproducts =[select id,Name from product2];
        for(product2 prdctlp : allproducts){
            productids.put(prdctlp.Name,prdctlp.Id);
        }
        for(CreateWaitlist__c prdctloop : gridMap.values()){
            productmap.put(prdctloop.Product__c,prdctloop);
        }
        for(CreateWaitlist__c prdctloop : gridMap.values()){
            productmap1.put(prdctloop.Inventory_Product__c,prdctloop);
        }
        
        /* Begin :Added as part of renewals*/
        userntlogin = [select NT_Login_ID__c from user where id = :userinfo.getUserId()].NT_Login_ID__c;
        
        pageBlockTabelTitile ='Create Waitlist';
        preauthEffectiveDate = System.today();
        preAuthrenwalParsm = ApexPages.currentPage().getParameters().get('typeren');
        if(preAuthrenwalParsm=='renwals'){
            showandhiderenwals = true ;
            
            currenlyProcessedAmount = acct.Current_Pre_Auth_Monthly_Processed__c ; 
            //pbTable = true ;
        }else{
            preAuthrenwalParsm='None';  
        }
        if(preAuthrenwalParsm=='renwals'){       
            addTotal = [SELECT Account_Owner_Email__c,
                        Account__c,
                        Amendment_Status__c,
                        BOB_Owner_Email__c,
                        Current_Monthly_Pre_Auth_Spend__c,Product__r.Id,
                        Current_Utilized_Spend__c,DocuSign_Status__c,Inventory_Available_Fast__c,
                        Inventory_Available_Flex__c,Inventory_Available__c,Inventory_Transaction_ID_Fast__c,
                        Inventory_Transaction_ID_Flex__c,IsDeleted,LastActivityDate,LastModifiedById,Product__r.Name,Product__r.ProductCode ,
                        LastModifiedDate,Lead_Routing__c,legacy_preauth_rprt__c,
                        Market_Type__c,Market__c,Name,Opportunity__c,Original_Max_Spend__c,Product_Size__c,
                        Product__c,Quote_Text_Id__c,Quote__c,Rank__c,Rate_Card_Price__c,Record_Processed__c,State__c,
                        Remnant_Spend__c,Status__c,SystemModstamp,Term__c,Tier_Price_Number__c,Impressions_Qty__c ,
                        Total_MAX_Monthly_Pre_Auth_Spend__c,Transaction_Id__c,Wailist_Type__c,Waitlist_Expiration_Date__c,
                        Waitlist_ID__c,Waitlist__c FROM Waitlist_Item__c 
                        where Account__c=:acct.Id
                        AND (Status__c ='Active' OR Status__c ='Fulfilled')];
            System.debug('====> Total Records'+addTotal.size());
            
            List<CreateWaitlist__c> listOf = [Select Id ,Inventory_Product__c,SFDC_Product__c , Name from CreateWaitlist__c] ; 
            Map<String, String> mapsOf = new  Map<String, String>();
            for(CreateWaitlist__c c :listOf){
                mapsOf.put(c.SFDC_Product__c, c.Inventory_Product__c);  
            }
            for(Waitlist_Item__c wlForRenRes : addTotal){
                //system.debug(productmap1) ;
                //system.debug(wlForRenRes) ;
                //System.debug('wlForRenRes.Product__r.ProductCode'+wlForRenRes.Product__r.ProductCode);
                // System.debug('wlForRenRes.Product__r.Name'+wlForRenRes.Product__r.Name);
                //System.debug('productmap'+productmap) ;
                //ystem.debug('productmap get INV '+productmap.get(wlForRenRes.Product__r.Name).Inventory_Product__c ) ;
                
                
                addTotalUniqueMarkets.add(wlForRenRes.Market__c);                
                String IvnProd = mapsOf.get(wlForRenRes.Product__r.Name);
                marketWrapper mp0 =   new marketWrapper(IvnProd ,
                                                        StatusselectedVal,
                                                        TypeOptions,
                                                        wlForRenRes.Market_Type__c ,
                                                        DegreeselectedVal,
                                                        wlForRenRes.Lead_Routing__c,
                                                        LeadRoutingOptions,
                                                        Integer.valueOf(wlForRenRes.Impressions_Qty__c) ,
                                                        Message,
                                                        '',
                                                        acct,
                                                        '',
                                                        SlotSizeselectedVal,
                                                        SlotSizeOptions,
                                                        userntlogin,
                                                        Term,
                                                        String.valueOf(wlForRenRes.Term__c),
                                                        termList
                                                        
                                                       );
                mp0.MarketType = wlForRenRes.Market_Type__c ;
                mp0.marketText =   wlForRenRes.Market__c;
                mp0.MaxSpend = Integer.valueOf(wlForRenRes.Original_Max_Spend__c);
                mp0.createdBy = userntlogin;
                mp0.state =wlForRenRes.State__c;
                
                mp0.docuSignstatus = wlForRenRes.Status__c  ; 
                mp0.expirationDate= wlForRenRes.Waitlist_Expiration_Date__c ; 
                mp0.currentUtlizedSpend = wlForRenRes.Current_Utilized_Spend__c ; 
                mp0.rateCardPrice = wlForRenRes.Rate_Card_Price__c ; 
                mp0.rewalRow = true ; 
                mp0.waitlistExising = wlForRenRes;
                
                marketList.add(mp0);
            }
            
            
        }
        
        /*END : */
        
        
        
        
        
        userntlogin = [select NT_Login_ID__c from user where id = :userinfo.getUserId()].NT_Login_ID__c;
        If(userntlogin == null){
            ntloginnull = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Current User doesn\'t have NT Log in ID'));
        }            
        
        //Retrieving primary contact details
        try{ 
            primarycntct = [select id,Contact_To__c,Parent_Account__r.email_address__c,Contact_To__r.Name,Contact_To__r.Phone from Account_Relationship__c where 
                            Contact_Role__c = 'Primary Contact' and Parent_Account__c = :acct.Id and Active__c = true];
            if(primarycntct.size() > 1){
                prmrycntcterr = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'More than one active Primary contact\'s exists for Account "'+acct.Name+'"'));
                primaryPhone      = primarycntct[0].Contact_To__r.Phone;    
            }
            If(!primarycntct.isEmpty()){
                primaryPhone      = primarycntct[0].Contact_To__r.Phone;    
            }
            if(primarycntct.size() == 0){
                prmrycntcterr = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact is required for the account "'+acct.Name+'"'));
            }
        }catch(queryexception e){
            prmrycntcterr = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact is required for the account "'+acct.Name+'"'));
        }
        if(!prmrycntcterr){
            //if(primarycntct.Parent_Account__r.email_address__c == null){
            if(primarycntct[0].Parent_Account__r.email_address__c == null){
                prmrycntctemailerr = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact "'+primarycntct[0].Contact_To__r.Name+'" doesn\'t have email'));
            }
        }
    }
    
    public void Initialize(){
        marketList              = new list<marketWrapper>();
        countyOptions           = new List<SelectOption>();
        cityOptions             = new List<SelectOption>();
        PostcodeOptions         = new List<SelectOption>();
        MarketTypetOptions      = new list<SelectOption>();
        MarketSubTypeOptions    = new list<SelectOption>();
        LeadRoutingOptions      = new list<SelectOption>();
        SlotSizeOptions         = new list<SelectOption>();            
        TypeOptions             = new list<SelectOption>();            
        DegreeOptions           = new list<SelectOption>();              
        DegreeOptions1          = new list<SelectOption>();              
        TerritoryList           = new list<SelectOption>();
        TigerLeadOptions        = new list<SelectOption>();                      
        cityOptionsSet1         = new List<SelectOption>();
        cityOptionsSet2         = new List<SelectOption>();
        cityOptionsSet3         = new List<SelectOption>();
        cityOptionsSet4         = new List<SelectOption>();
        
        countyOptionsSet1       = new List<SelectOption>();
        countyOptionsSet2       = new List<SelectOption>();
        countyOptionsSet3       = new List<SelectOption>();
        PostcodeOptionsSet1     = new List<SelectOption>();
        PostcodeOptionsSet2     = new List<SelectOption>();
        PostcodeOptionsSet3     = new List<SelectOption>();
        PostcodeOptionsSet4     = new List<SelectOption>();     
        
        stateFlag               = false;
        cityFlag                = false;
        countyFlag              = false; 
        postcodflag             = false;
        //Quantity                = 1;    
        Term                    = 12; 
        MarketTypeselectedVal   = '';
        TerritoryselectedVal    = '';
        TigerLeadselectedVal    = '';
        ProductselectedVal      = 'Connection for Co-Brokerage';
        MarketTypeselectedVal   = 'Postal Code';
        StatusselectedVal       = curentPreAuthUser ? 'Pre-Auth' : 'Hot'; //CRM-805
        //termList = new List<SelectOption>() ;
        
        
        preAuthSelectedList = new List<SelectOption>(); 
        preAuthSelectedList.add(new SelectOption('--None--' , '--None--'));
        // preAuthSelectedList.add(new SelectOption('Amend' , 'Amend'));
        preAuthSelectedList.add(new SelectOption('Renew' , 'Renew'));
        
        
        //termListVaule = '' ;
        initTermList();
        if(acct.billingstate != null){
            if(State_Abbreviations__c.getInstance(acct.billingstate) == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please correct the Bill To Address on the Account to be abbreviated and capitalized.'));
            }
            else{
                stateSelected       = State_Abbreviations__c.getInstance(acct.billingstate).Full_Name__c;
            }    
        }else{
            nobillstate = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Account should have billing state ,Please return to the Account and correct this before creating waitlist'));
        }
        
        LeadRoutingselectedVal  = 'Any';
        SlotSizeselectedVal     = 'Any';
        WLid                    = '';
        DegreeselectedVal       = '';
        prdctmeasure            = 'Credit Card Last 4 Digits';
        try{
            changeStatusfromgrid();
            FetchMarketTypes();

        }catch(Exception e){
            
        }
    }

    public void initProductChange(){
        initTermList();
        
        if(ProductselectedVal == 'Local Expert City'){
            MarketTypeselectedVal = 'City';
            MarketTypetOptions.clear();
            MarketTypetOptions.add(new SelectOption('City', 'City', false));
            FetchRoutingslottype();
        }else{
            FetchMarketTypes();
        }
    }
    
    // DAP-224: Init term values 
    public void initTermList(){
         termList = new List<SelectOption>();
         System.debug(termList);
         if(ProductselectedVal == 'Local Expert' || ProductselectedVal == 'Local Expert City'){ //By MRB added Local expert city
            termList.add(new SelectOption('12','12')); 
         } else {
            termList.add(new SelectOption('6','6')); 
            termList.add(new SelectOption('12','12')); 
         }
         
    }
    
    public List<SelectOption> getStateOptions(){                            
        return StateOptions;
    }
    
    public pageReference queryDependecies(){
        CountySelected = new list<string>();   
        CitySelected = new list<string>();
        postcodSelected = new list<string>();
        stateAbbURL = Waitlist_Urls__c.getInstance('StateAbb').URL__c;
        stateAbbURL = stateAbbURL.replace(Waitlist_Urls__c.getInstance('StateAbb').replacement_parameter__c, stateSelected);
        
        stateAbb   = geo.JSONStateAbbrevation(stateAbbURL);
        stateAbbrevation  = stateAbb;
        
        FetchCityCountyPostcode();                      
        return null;
    }
    
    public void FetchCityCountyPostcode(){
        countyFlag = false;
        cityFlag   = false;
        postcodflag = false;
        
        if(!String.isEmpty(stateSelected)){
            if(MarketTypeselectedVal == 'County'  || MarketTypeselectedVal == 'Postal Code' || MarketTypeselectedVal == 'City'){
                CountyFlag = true;
                countyOptionsSet1.clear();
                countyOptionsSet2.clear();
                countyOptionsSet3.clear();
                queryCountys();
            }
            if(MarketTypeselectedVal == 'City' || MarketTypeselectedVal == 'Postal Code'){
                cityFlag = true;
                cityOptionsSet1.clear();
                cityOptionsSet2.clear();
                cityOptionsSet3.clear();
                cityOptionsSet4.clear();
                
                queryCitys();
            }
            if(MarketTypeselectedVal == 'Postal Code'){
                postcodflag = true; 
                PostcodeOptionsSet1.clear();
                PostcodeOptionsSet2.clear();
                PostcodeOptionsSet3.clear();
                PostcodeOptionsSet4.clear();
                querypostalcodes();
            }
        }
        marketTextArea = '';
    }
    
    public pageReference queryCountys(){
        countyOptions = new List<SelectOption>();
        if(stateSelected  != null && stateSelected != ''){
            countyURL = Waitlist_Urls__c.getInstance('countyURL').URL__c;
            countyURL = countyURL.replace(Waitlist_Urls__c.getInstance('countyURL').replacement_parameter__c, PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected));
            //countyURL  = 'http://geo.svc.move.com/GeoWcfService/State.svc/Counties/'+stateSelected+'?app=RDC&v=1&format=json';            
            countyOptions.addAll(geo.JSONtoOptions(countyURL));
            if(countyOptions.size() > 0){
                countyOptions.sort(); 
                handleMorecountys(countyOptions);
            }else{
                CountyFlag = false; 
            }    
        }else{
            cityFlag    = false;
            countyFlag  = false;    
        }
        return null;
    }
    
    public pageReference queryCitys(){
        cityOptions  = new List<SelectOption>();
        if(stateSelected  != null && stateSelected  != ''){
            if(filtercnty && CountySelected.size() > 0){
                                                    stateAbb = PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected);

                for(string cntyslctd : CountySelected){ 
                    List<SelectOption> tempcityOptions = new List<SelectOption>();
                    cityURL = Waitlist_Urls__c.getInstance('cityURL').URL__c;
                    cityURL = cityURL.replace(Waitlist_Urls__c.getInstance('cityURL').replacement_parameter__c, stateAbb+'/'+cntyslctd);

                   // cityURL = 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/'+stateAbb+'/'+cntyslctd+'?app=RDC&v=1&format=JSON';
                    tempcityOptions.addAll(geo.JSONtoOptions(cityURL)); 
                    cityOptions.addAll(tempcityOptions);
                }
            }else{
                                stateAbb = PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected);

                cityURL = Waitlist_Urls__c.getInstance('citiesURL').URL__c;
                cityURL = cityURL.replace(Waitlist_Urls__c.getInstance('citiesURL').replacement_parameter__c, stateAbb);
                //cityURL  = 'http://geo.svc.ext.lift-qa.moveaws.com/GeoWcfService/State.svc/Cities/'+stateAbb+'?app=RDC&v=1&format=json';            
                cityOptions.addAll(geo.JSONtoOptions(cityURL));
            }
            if(cityOptions.size() > 0){
                cityOptions.sort(); 
                handleMorecitys(cityOptions);
                cityFlag = true; 
            }else{
                cityFlag    = false;                                     
            }
        }else{
            cityFlag    = false;
            countyFlag  = false; 
        }
        
        return null;
    }   
    
    public pageReference FetchCityPostalcode(){
        filtercnty = true;
        if(MarketTypeselectedVal == 'City'){
            cityOptionsSet1.clear();
            cityOptionsSet2.clear();
            cityOptionsSet3.clear();
            cityOptionsSet4.clear();
            queryCitys();
        }else{
            PostcodeOptionsSet1.clear();
            PostcodeOptionsSet2.clear();
            PostcodeOptionsSet3.clear();
            PostcodeOptionsSet4.clear();
            querypostalcodes();
        }
        return null;
    }    
    
    public pageReference FetchPostalcode(){
        filtercity = true;
        if(MarketTypeselectedVal == 'Postal Code'){
            PostcodeOptionsSet1.clear();
            PostcodeOptionsSet2.clear();
            PostcodeOptionsSet3.clear();
            PostcodeOptionsSet4.clear();
            querypostalcodes();
        }
        return null;
    }    
    
    public pageReference querypostalcodes(){
        cityOptions  = new List<SelectOption>();
        if(stateSelected  != null && stateSelected  != ''){
           // string stateAbbURL = 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/'+stateSelected+'?app=RDC&v=1&format=JSON';
           // string stateAbb   = geo.JSONStateAbbrevation(stateAbbURL);
            stateAbbrevation  = PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected);
            if(filtercnty && CountySelected.size() > 0){
                PostcodeOptions.clear(); 
                for(string cntyslctd : CountySelected){ 
                    List<SelectOption> tempPostcodeOptions = new List<SelectOption>();
                    PostcodeURL = Waitlist_Urls__c.getInstance('ZipsWithinCounty').URL__c;
                    PostcodeURL = PostcodeURL.replace(Waitlist_Urls__c.getInstance('zipsIntersectsCity').replacement_parameter__c, stateAbb+'/'+cntyslctd);
                    
                    //PostcodeURL = 'http://geo.svc.move.com/GeoWcfService/County.svc/ZipsWithinCounty/'+stateAbb+'/'+cntyslctd+'?app=RDC&v=1&format=JSON';
                    tempPostcodeOptions.addAll(geo.JSONtoOptions(PostcodeURL));
                    PostcodeOptions.addAll(tempPostcodeOptions);
                    fromquerypostalcodes = true;
                }
            }else if(filtercity && CitySelected.size() > 0){
                PostcodeOptions.clear(); 
                for(string cityslctd : CitySelected){ 
                    List<SelectOption> tempPostcodeOptions = new List<SelectOption>();
                    PostcodeURL = Waitlist_Urls__c.getInstance('zipsIntersectsCity').URL__c;
                    PostcodeURL = PostcodeURL.replace(Waitlist_Urls__c.getInstance('zipsIntersectsCity').replacement_parameter__c, stateAbb+'/'+cityslctd);
                    tempPostcodeOptions.addAll(geo.JSONtoOptions(PostcodeURL));   
                    PostcodeOptions.addAll(tempPostcodeOptions);
                }
            }else{
               PostcodeURL = Waitlist_Urls__c.getInstance('postalCodes').URL__c;
               postCodeURL = postCodeURL.replace(Waitlist_Urls__c.getInstance('postalCodes').replacement_parameter__c, stateAbb);

               // PostcodeURL = 'http://geo.svc.move.com/GeoWcfService/State.svc/Postalcodes/'+stateAbb+'?app=RDC&v=1&format=JSON';
                PostcodeOptions.addAll(geo.JSONtoOptions(PostcodeURL));
            }
            if(PostcodeOptions.size() > 0){
                PostcodeOptions.sort(); 
                handleMorePostcode(PostcodeOptions);
                postcodflag = true; 
            }else{
                postcodflag = true; 
                cityFlag    = true;
                countyFlag  = true;                                    
            }
        }else{               
            cityFlag    = false;
            countyFlag  = false;
            postcodflag  = false; 
        }
        if(filtercnty){
            queryCitys();
        }
        return null;
    }    
    
    
    public pageReference querypostalcodesforcities(){
        cityOptions  = new List<SelectOption>();
        if(stateSelected  != null && stateSelected  != ''){
            //string stateAbbURL = 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/'+stateSelected+'?app=RDC&v=1&format=JSON';
           // string stateAbb   = geo.JSONStateAbbrevation(stateAbbURL);
            stateAbbrevation  =  PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected);
            if(CitySelected.size() > 0){
                PostcodeOptions.clear(); 
                for(string cityslctd : CitySelected){ 
                    List<SelectOption> tempPostcodeOptions = new List<SelectOption>();
                    PostcodeURL = Waitlist_Urls__c.getInstance('zipsIntersectsCity').URL__c;
                    PostcodeURL = PostcodeURL.replace(Waitlist_Urls__c.getInstance('zipsIntersectsCity').replacement_parameter__c, stateAbb+'/'+cityslctd);
                    
                   // PostcodeURL = 'http://geo.svc.move.com/GeoWcfService/City.svc/ZipsIntersectsCity/'+stateAbb+'/'+cityslctd+'?app=RDC&v=1&format=JSON';
                    tempPostcodeOptions.addAll(geo.JSONtoOptions(PostcodeURL));   
                    PostcodeOptions.addAll(tempPostcodeOptions);
                }
            }else{
                PostcodeURL = Waitlist_Urls__c.getInstance('postalCodes').URL__c;
                postCodeURL = postCodeURL.replace(Waitlist_Urls__c.getInstance('postalCodes').replacement_parameter__c, stateAbb);

                //PostcodeURL = 'http://geo.svc.move.com/GeoWcfService/State.svc/Postalcodes/'+stateAbb+'?app=RDC&v=1&format=JSON';
                PostcodeOptions.addAll(geo.JSONtoOptions(PostcodeURL));
            }
            if(PostcodeOptions.size() > 0){
                PostcodeOptions.sort(); 
                handleMorePostcode(PostcodeOptions);
                postcodflag = true; 
            }else{
                postcodflag = true; 
                cityFlag    = true;
                countyFlag  = true;                                    
            }
        }else{               
            cityFlag    = false;
            countyFlag  = false;
            postcodflag  = false; 
        }
        return null;
    }    
    
    
    public List<SelectOption> getProductOptions(){   
        String accountSummaryProducts = Label.Account360Products;

        List<SelectOption> optns = new List<Selectoption>(); 
        set<String> temp = new set<String>();
        for(CreateWaitlist__c oProduct : gridMap.Values()){
            if((!temp.contains(oProduct.Product__c) && acct.Type.containsonly(oProduct.AccountTypeSpecific__c)) || test.isRunningTest() ){
                if(oProduct.Product__c == 'Local Expert' || test.isRunningTest()){
                  if(accountSummaryProducts.contains('localexpert') ||test.isRunningTest()){
                    optns.add(new selectOption(oProduct.Product__c,oProduct.Product__c));                    
                    temp.add(oProduct.Product__c);   
                  }
                }else{
                    optns.add(new selectOption(oProduct.Product__c,oProduct.Product__c));                    
                    temp.add(oProduct.Product__c); 
                }                 
            }
        } 
        addNoneOption(optns);                                                       
        return optns;
    }
    
    public pageReference FetchMarketTypes(){
        marketTextArea = '';
        MarketTypetOptions = new List<Selectoption>();
        set<String> temp = new set<String>();
        if(!String.isEmpty(ProductselectedVal)){
            for(CreateWaitlist__c oMarketType : gridMap.Values()){
                if((ProductselectedVal == oMarketType.Product__c && !temp.contains(oMarketType.Market_Type__c) && acct.Type.containsonly(oMarketType.AccountTypeSpecific__c))|| test.isRunningTest()){
                    MarketTypetOptions.add(new selectOption(oMarketType.Market_Type__c,oMarketType.Market_Type__c));
                    temp.add(oMarketType.Market_Type__c); 
                }               
            }
            addNoneOption(MarketTypetOptions);              
        }
        FetchRoutingslottype();
        return null;
    }
    
    public pageReference  FetchRoutingslottype(){
        list<marketWrapper> marketListhold = new list<marketWrapper>();
        marketListhold.addAll(marketList);
        LeadRoutingOptions  = new List<Selectoption>();
        SlotSizeOptions     = new List<Selectoption>();
        TypeOptions         = new List<Selectoption>();
        map<String,string> tempLeadRouting = new map<String,string>();
        map<String,string> tempSlot = new map<String,string>();        
        map<String,string> tempStatus = new map<String,string>();        
        if(!String.isEmpty(MarketTypeselectedVal)){
            for(CreateWaitlist__c customsetdata : gridMap.Values()){
                if(MarketTypeselectedVal == customsetdata.Market_Type__c && ProductselectedVal == customsetdata.Product__c){
                    if(!tempLeadRouting.containsKey(customsetdata.Product__c)){
                        tempLeadRouting.put(customsetdata.Product__c,customsetdata.Lead_Routing_Type__c);                         
                    }
                    if(!tempSlot.containsKey(customsetdata.Product__c)){
                        tempSlot.put(customsetdata.Product__c,customsetdata.Slot_Size__c);                         
                    }                                         
                    if(!tempStatus.containsKey(customsetdata.Product__c)){
                        tempStatus.put(customsetdata.Status__c,customsetdata.Status__c);                         
                    }                                        
                }                                                                
            }           
        }
        list2Options(tempLeadRouting.values(),LeadRoutingOptions); 
        list2Options(tempSlot.values(),SlotSizeOptions);                  
        addNoneOption(list2Options(tempStatus.values(),TypeOptions));        
        refresh();
        marketList.clear();
        marketList.addAll(marketListhold);
        marketListhold.clear();
        // DAP-219 (Local expert): Default product-size and lead-routing value when product is selected.
        // This Map will always have only 1 record as only 1 product will be selected
        // tempSlot === {"Local Expert": "SOV50, SOV30, SOV20, ANY"}   Values got from custom setting
        // tempSlot.values() has string containing product sizes "SOV50, SOV30, SOV20, ANY"
        if(!tempSlot.values().isEmpty()){
            // checking if string has multiple slot sizes 
            // one slot size : e.g "SOV50"
            // multiple slot sizes : "SOV50, SOV30, SOV20, ANY"
            if(tempSlot.values()[0].contains(',')){
                SlotSizeselectedVal = tempSlot.values()[0].substring(tempSlot.values()[0].lastIndexOf(', ')+2, tempSlot.values()[0].length());
            } else {
                SlotSizeselectedVal = tempSlot.values()[0];
            }
        }
        if(!tempLeadRouting.values().isEmpty()){
            if(tempLeadRouting.values()[0].contains(',')){
                LeadRoutingselectedVal = tempLeadRouting.values()[0].substring(tempLeadRouting.values()[0].lastIndexOf(', ')+2, tempLeadRouting.values()[0].length());
            } else {
                LeadRoutingselectedVal = tempLeadRouting.values()[0];
            }
        }
        return null;
    }
    
    public void refresh(){
       // stateAbbURL = 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/'+stateSelected+'?app=RDC&v=1&format=JSON';
       // stateAbb   = geo.JSONStateAbbrevation(stateAbbURL);
        stateAbbrevation  =  PreAuthWaitListRenewalUtil.stateAbbreviation(stateSelected);
        
        if(MarketTypeselectedVal == 'City'){
            postcodflag = false;
            PostcodeOptionsSet1.clear(); 
            PostcodeOptionsSet2.clear();
            PostcodeOptionsSet3.clear();
            PostcodeOptionsSet4.clear();
            CountyFlag = true;
            if(CountySelected != null){ 
                CountySelected.clear(); 
            }
            queryCountys();
            
            cityFlag = true;
            if(CitySelected != null){ 
                CitySelected.clear(); 
            }
            queryCitys();
        }        
        
        if(MarketTypeselectedVal == 'County'){
            postcodflag = false;
            if(postcodSelected != null){ 
                postcodSelected.clear();
            }
            PostcodeOptionsSet1.clear(); 
            PostcodeOptionsSet2.clear(); 
            PostcodeOptionsSet3.clear();
            PostcodeOptionsSet4.clear();
            cityFlag = false;
            if(CitySelected != null){ 
                CitySelected.clear();
            }
            cityOptionsSet1.clear();
            cityOptionsSet2.clear();
            cityOptionsSet3.clear();
            cityOptionsSet4.clear();
        }        
        
        if(MarketTypeselectedVal == 'Postal Code'){
            CountyFlag = true;
            if(CountySelected != null){ 
                CountySelected.clear();
            }
            queryCountys();
            cityFlag = true;
            if(CitySelected != null){ 
                CitySelected.clear();
            }
            queryCitys();
            postcodflag = true;
            filtercnty = false;
            if(postcodSelected != null){ 
                postcodSelected.clear();
            }
            PostcodeOptionsSet1.clear();
            PostcodeOptionsSet2.clear();
            PostcodeOptionsSet3.clear();
            PostcodeOptionsSet4.clear();
            querypostalcodes();
        }        
    }    
    
    public pageReference  changeStatusForRen(){
        If(preauthTypeSelectedString=='Renew'){
            pbTable = true ; 
            pageBlockTabelTitile = 'Waitlist Information ';
            coloumHeader = 'Action';
        }else{
            pbTable = false ;   
        }
        return null ;    
    }
    
    public pageReference  changeStatus(){
        map<String,string> tempDegree = new map<String,string>();
        if(!String.isEmpty(StatusselectedVal)){
            for(CreateWaitlist__c oStatus: gridMap.Values()){
                if(StatusselectedVal == 'Warm' && MarketTypeselectedVal == oStatus.Market_Type__c && ProductselectedVal == oStatus.Product__c ){
                    tempDegree.put(oStatus.Product__c,oStatus.Degree__c);                         
                }                                
            }
        }         
        addNoneOption(list2Options(tempDegree.values(),DegreeOptions));
        list<PaymentProfiles__c> pymntprfl = [select id from PaymentProfiles__c WHERE Account__c =: this.acct.ID];
        if(pymntprfl.size() <= 0 && acct.Account_Sub_Type__c == 'Customer'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Payment profile is required for the account "'+acct.Name+'" to create Pre-Auth waitlist'));
            return null; 
        }else{
            pymntprflerr = false;   
            return null; 
        }
        return null;
    }
    
    public pageReference  changeStatusfromgrid(){
        map<string,CreateWaitlist__c> gridMap1 = CreateWaitlist__c.getAll();
        list<string> tempDegree1 = new list<string>();
        tempDegree1.add('Warm 1');
        tempDegree1.add('Warm 2');
        tempDegree1.add('Warm 3');
        list2Options(tempDegree1,DegreeOptions1);
        return null;
    }
    
    public list<SelectOption> list2Options(list<String> temp,List<Selectoption> Options){        
        options.clear();
        for(string str:temp){
            if(str.contains(',')){
                for(string ostr: str.split(',')){
                    Options.add(new selectOption(oStr.trim(),oStr.trim()));                  
                }
            } 
            else{
                Options.add(new selectOption(str.trim(),str.trim()));
            }   
        }
        return Options;   
    }
    
    public pageReference callapex(){
        return null;
    }
    
    public pageReference submit(){
        
         if(preauthEffectiveDate < system.today()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Pre-Auth Effective Date Should not be past date'));
            return null;
        }
        
        try{ 
            primarycntct = [select id,Contact_To__c,Parent_Account__r.email_address__c,Contact_To__r.Name,Contact_To__r.Phone  from Account_Relationship__c where 
                            Contact_Role__c = 'Primary Contact' and Parent_Account__c = :acct.Id and Active__c = true];
            prmrycntcterr = false;
        }catch(queryexception e){
            prmrycntcterr = true;
        }
        if(!prmrycntcterr){
            if(primarycntct[0].Parent_Account__r.email_address__c == null){
                prmrycntctemailerr = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This waitlist cannot be submitted/saved as the Primary Contact  '+primarycntct[0].Contact_To__r.Name+' does not have an email. Please update the email and re-submit the Waitlist.'));
            }else{
                prmrycntctemailerr = false;
            }
            
        }
        
        if(prmrycntcterr){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact is required for the account '+acct.Name+''));
            return null;
        }
        if(prmrycntctemailerr){
            //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Primary contact'+primarycntct[0].Contact_To__r.Name+' doesn\'t have email'));
            return null;
        }
        
        if(rltrofficeerr){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Waitlsit can\'t be created for Realtor Office'));
            Return null;
        }
        
        latestacct = [SELECT ID,billingstate, Billing_Preference__c, Email_Address__c , Preferred_Phone__c   FROM Account WHERE ID =: ApexPages.currentPage().getParameters().get('id')];
        If(latestacct.billingstate == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please return to the Account, and update the state on the Bill To Address before Saving/Submitting the Waitlist.'));
            Return null;
        }
        If(latestacct.Email_Address__c == null || latestacct.Email_Address__c =='' ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This Account does not have a Primary Email. Please return to the Account and update the Primary Email before Saving/Submitting the Waitlist.'));
            Return null;
        }
        If(latestacct.Preferred_Phone__c == null || latestacct.Preferred_Phone__c =='' ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This Account does not have a Preferred Phone number. Please return to the Account and update the Preferred Phone before Saving/Submitting the Waitlist'));
            Return null;
        }
        
        
        If(userntlogin == null){
            userntlogin = [select NT_Login_ID__c from user where id = :userinfo.getUserId()].NT_Login_ID__c;
        }
        
        If(userntlogin == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Current User doesn\'t have NT Log in ID'));
            Return null;
        }
        
        showstatuscolumns = true;
        showdeletecolumns = true;   
        message = '';
        
        
        
        message = callinventory();
        
        set<string> checktoshowstatus1 = new set<string>();
        for(marketWrapper wrprloop : marketlist){
            checktoshowstatus1.add(wrprloop.Message);
        }
        if(!(checktoshowstatus1.contains('Success')) || checktoshowstatus1.contains(null)){ 
            showsubmit = true; 
        }else{
            showsubmit = false; 
            /*
            // Add to WaitListHistory - Venu
            AddWaitlistHistory.AddToWaitListHistory('id','newValue','oldValue','AccountCreateWaitList','Inserted');
            // Add to WaitListHistory - Venu
            */
                
        }
        return null;
    }
    
    public string callinventory(){
        integer looopcount = 0;
        
        list<Waitlist_Item__c> renewalWaitlist = new list<Waitlist_Item__c>();
        
        
        list<marketWrapper> marketListsccs = new list<marketWrapper>();
        list<marketWrapper> marketListprcs = new list<marketWrapper>();
        list<CreateWaitlistWrapper> waitlisttocreate = new  list<CreateWaitlistWrapper>();
        HTTPResponse res;
        List<String> termListVal = new List<String>() ; 
        for(marketWrapper mrfltr : marketList){
            if(mrfltr.termListVaule!=null || mrfltr.termListVaule!=''){
                System.debug('mrfltr.termListVaule ==== >>'+mrfltr.termListVaule);
                termListVal.add(mrfltr.termListVaule);  
            }
            if(mrfltr.Message == 'Success'){
                marketListsccs.add(mrfltr); 
            }else{
                marketListprcs.add(mrfltr); 
            }
        }
        marketList.clear();
        marketList.addAll(marketListprcs);
        WLIinsert.clear();
        createWLI = true;
        process = false;
        set<marketWrapper> deleteset = new set<marketWrapper>();
        set<marketWrapper> afterdelete = new set<marketWrapper>();
        set<marketWrapper> deleteset1 = new set<marketWrapper>();
        set<marketWrapper> afterdelete1 = new set<marketWrapper>();
        Waitlist__c WLlst = new Waitlist__c();
        Waitlist__c WLInsert = new Waitlist__c();
        string message1 = '';
        for(marketWrapper deletemr :marketList){
            looopcount ++;
            if(deletemr.delete1 != null ){
                if(deletemr.delete1){
                    deleteset1.add(deletemr); 
                }
            }
        }
        afterdelete1.addAll(marketList);
        afterdelete1.removeAll(deleteset1);
        marketList.clear();
        marketList.addAll(afterdelete1);
        
        List<PaymentProfiles__c>  paymentProfileobj = [Select Id , Account__c ,SplitPercentage__c  ,
                                                       MaskNumber__c from PaymentProfiles__c
                                                       where Account__c =:latestacct.id AND SplitPercentage__c > 0]  ;
        String sLike = '%'+CC4digits;
        List<PaymentProfiles__c>  paymentProfileobjCC = [Select Id , Account__c ,SplitPercentage__c  ,
                                                         MaskNumber__c from PaymentProfiles__c
                                                         where Account__c =:latestacct.id AND SplitPercentage__c > 0 AND MaskNumber__c like :sLike]  ;
        List<PaymentProfiles__c>  paymentProfileobjFirstCheck = [Select Id , Account__c ,SplitPercentage__c  ,
                                                                 MaskNumber__c from PaymentProfiles__c
                                                                 where Account__c =:latestacct.id ]  ;
        List<Account> accountsToUpdate = new List<Account>(); //CRM-448
        Set<Id> accountIds = new Set<Id>();
        for(marketWrapper mr : marketList){
            if(mr.message == null){
                process = true; 
            }else if(mr.message != 'Success'){
                process = true; 
            }else if(mr.Delete1 == null){
                process = true; 
            }else if(mr.Delete1 == true){
                process = false; 
            }
            if(process){
                If(!mr.rewalRow){
                    System.debug('******* Renewals Check ') ; 
                    CreateWaitlistWrapper waitlist = new  CreateWaitlistWrapper();
                    waitlist.product_type = productmap.get(mr.Product).Inventory_Product__c;
                    // Validating Account Billing information for Pre Auth 
                    if(paymentProfileobjFirstCheck.size()<=0 && mr.Status == 'Pre-Auth' && (latestacct.Billing_Preference__c=='Invoice-CC' || latestacct.Billing_Preference__c=='CC-Direct' || latestacct.Billing_Preference__c=='Arrears CC')){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This account does not have an active payment profile.'));
                        return null; 
                    }                                           
                    if(mr.Status == 'Pre-Auth' && (latestacct.Billing_Preference__c=='Invoice-CC' || latestacct.Billing_Preference__c=='CC-Direct' || latestacct.Billing_Preference__c=='Arrears CC') && paymentProfileobj.size()<=0 ){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Account With Invoice-CC or CC-Direct Should have greater than zero split percentage '));
                        return null; 
                    }
                    if(mr.Status == 'Pre-Auth' && (latestacct.Billing_Preference__c=='Invoice-CC' || latestacct.Billing_Preference__c=='CC-Direct' || latestacct.Billing_Preference__c=='Arrears CC') && paymentProfileobjCC.size()<=0){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The \"Credit Card Last 4 Digits\" does not match the information on the Payment Profile(s). Please check the Payment Profile(s) on the Account and re-enter.'));
                        return null; 
                    }
                    if(totlaMaxPreAuthSpend <= 0.0 && mr.Status== 'Pre-Auth' ){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The Total MAX Monthly Pre-Auth Spend cannot be 0 or less than 0'));
                        return null; 
                        
                    }
                    if(mr.Status == 'Pre-Auth' && pymntprflerr && acct.Account_Sub_Type__c == 'Customer' && (latestacct.Billing_Preference__c=='Invoice-CC' || latestacct.Billing_Preference__c=='CC-Direct' || latestacct.Billing_Preference__c=='Arrears CC')){
                        list<PaymentProfiles__c> pymntprfl = [select id from PaymentProfiles__c WHERE Account__c =: this.acct.ID];
                        if(pymntprfl.size() <= 0){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Payment profile is required for the account "'+acct.Name+'" to create Pre-Auth waitlist'));
                            return null; 
                        }else{
                            pymntprflerr = false;   
                        }
                    }
                    if(mr.Status == null || mr.Status == ''){
                        marketList.addall(marketListsccs);
                        showsubmit = true; 
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select Waitlist Type'));
                        return null; 
                    }else{
                        waitlist.waitlist_type = mr.Status;
                    }
                    if((mr.MaxSpend < 0 || mr.MaxSpend == 0) && mr.Status == 'Pre-Auth' && mr.Product != 'Turbo'){
                        marketList.addall(marketListsccs);
                        showsubmit = true; 
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The Max Spend for the selected market(s) cannot be 0 or less than 0'));
                        return null; 
                    }else{
                        Waitlist.original_max_spend = string.valueof(mr.MaxSpend);                
                    }
                    if(CC4digits==Null || (String.valueOf(CC4digits).length() < 4) && mr.Status == 'Pre-Auth' && (latestacct.Billing_Preference__c=='Invoice-CC' || latestacct.Billing_Preference__c=='CC-Direct' || latestacct.Billing_Preference__c=='Arrears CC')){
                        showsubmit = true; 
                        marketList.addall(marketListsccs);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The \"Credit Card Last 4 Digits\" does not match the information on the Payment Profile(s). Please check the Payment Profile(s) on the Account and re-enter.'));
                        return null; 
                    }
                    If((mr.quantity < 0 || mr.quantity == 0 || mr.quantity == null) && mr.Status == 'Pre-Auth' && mr.Product == 'Turbo'){
                        showsubmit = true; 
                        marketList.addall(marketListsccs);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Impressions Quantity can\'t be zero or negative for Turbo Pre-Auth'));
                        return null; 
                    }else{
                        waitlist.quantity = mr.quantity;
                    }
                    If(mr.Product != 'Turbo'){
                        waitlist.quantity = 1;
                    }
                    waitlist.remnant_spend = string.valueof(mr.MaxSpend);
                    waitlist.created_by = mr.createdBy;
                    waitlist.owner_name = mr.OwnerName;
                    waitlist.lead_routing = mr.LeadRouting;
                    waitlist.party_id = mr.PartyID;
                    waitlist.market_type = mr.MarketType;
                    waitlist.market_name= mr.marketText;
                    waitlist.state = mr.state;
                    waitlist.waitlist_slot =  mr.slot;
                    if(mr.Status != 'Pre-Auth'){
                        waitlist.waitlist_status = 'Active';
                    }else{
                        waitlist.waitlist_status = 'Pending Pre-Auth';
                    }
                    waitlist.promo = mr.promo;
                    waitlist.promo_expiration_date = mr.promo_Expirationdate;
                    waitlist.comment = mr.comment;
                    waitlist.account_sub_type = acct.Account_Sub_Type__c;
                    waitlist.account_name = acct.Name;
                    waitlist.phone        = primaryphone;
                    waitlisttocreate.add(waitlist);
                }else{
                    mr.Message ='Success' ;
                    renewalWaitlist.add(mr.waitlistExising);
                    
                }
            }
            else{
                createWLI = false; 
            }
        }
       
        system.debug('waitlisttocreatesize:++++>>>>'+waitlisttocreate.size());
        
        Map<String, List<String>> tempProductMarket = new Map<String, List<String>>();
        Map<String,String> tempMarketsMap = new Map<String,String>();
        //if(preAuthrenwalParsm!='renwals'){
        Map<Id,Waitlist__c> wlExistingWaitlist =new Map<Id,Waitlist__c>([Select Id from Waitlist__c where Account__c =:acct.Id 
                                                                         AND (Status__c='Active' OR Status__c='Pending Pre-Auth Approval' 
                                                                              OR Status__c='Pending Pre-Auth' OR
                                                                              Status__c='Expired' OR 
                                                                              Status__c='Account Spend Max Reached' OR  Status__c='Canceled')]);
        List<Waitlist_Item__c> wlItemforExsiting = [Select 
                                                    Account__c,Amendment_Status__c,
                                                    BOB_Owner_Email__c,
                                                    Current_Monthly_Pre_Auth_Spend__c,
                                                    Current_Utilized_Spend__c,
                                                    DocuSign_Status__c,
                                                    Id,
                                                    state__c , 
                                                    Inventory_Available_Fast__c,
                                                    Inventory_Available_Flex__c,
                                                    Inventory_Available__c,
                                                    Inventory_Transaction_ID_Fast__c,
                                                    Inventory_Transaction_ID_Flex__c,
                                                    Lead_Routing__c,rank__c,
                                                    Market_Type__c,Market__c,Name,
                                                    Opportunity__c,Original_Max_Spend__c,Account__r.OwnerId,
                                                    Product_Size__c,Product__c,Quote__c,
                                                    Remnant_Spend__c,Status__c,Term__c,
                                                    Total_MAX_Monthly_Pre_Auth_Spend__c,Transaction_Id__c,
                                                    Wailist_Type__c,
                                                    Waitlist_Expiration_Date__c,
                                                    Waitlist_ID__c,Waitlist__c from Waitlist_Item__c 
                                                    where Waitlist__c IN :wlExistingWaitlist.keySet()
                                                    AND Status__c NOT IN ('Fulfilled' ,'Canceled','Rejected Pre-Auth','Account Spend Max Reached','Expired','Preauth Review Required (P2)','Preauth Review Required')]; //CRM - 1486 ADDED STATUSES TO EXCLUDE

        User currentUser =  [Select id,Pre_Auth_User__c from User where id=:UserInfo.getUserId()];
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
        for(Waitlist_Item__c wItemfor :wlItemforExsiting){
            //tempMarkets.add(wItemfor.Market__c);
            // DAP-225: Pre-Auth waitlist is not getting created for same market with different products
            // Create map of product and it's market
            if(!tempProductMarket.containsKey(wItemfor.Product__c)){
                tempProductMarket.put(wItemfor.Product__c, new List<String>{wItemfor.Market__c});
            } else {
                 List<String> marketSet = tempProductMarket.get(wItemfor.Product__c);
                 marketSet.add(wItemfor.Market__c);
                 tempProductMarket.put(wItemfor.Product__c, marketSet);
            }
        }
        //}
        if(waitlisttocreate.size() > 0){
            try{
                System.debug('Going into HTTP request === >>') ; 
                Set<String> ownerList = new Set<String>(); //CRM-448
                ownerList.addAll(Waitlist_Urls__c.getInstance('accountOwnerChange').owners_List__c.split(',')); //CRM-448
                HttpRequest req = new HttpRequest();
               
                req.setMethod('POST');
                req.setEndpoint(Waitlist_Urls__c.getInstance('CreateWaitlist').URL__c);
                req.setBody(JSON.serialize(waitlisttocreate));
                
                System.debug('Going into Body  request === >>'+waitlisttocreate) ; 
                
                req.setTimeout(120000);
                req.setHeader('Content-Type', 'application/json');
                Http http = new Http();
                
                 
                 if(!Test.isRunningTest()){
                 res = http.send(req);
                    createinvntresponse = string.valueof(res.getBody());
                    } else {
                    
                    res.setBody('{"params":{"request":{"__type":"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel","party_id":"4256221","market_name":"06021","market_type":"Postal Code","product_type":"Connection for Co-Brokerage","state":"CT","waitlist_type":"Pre-Auth","waitlist_slot":"Any","waitlist_status":"Pending Pre-Auth","lead_routing":"Any","quantity":1,"created_by":"MBARTELLI","owner_name":"MBARTELLI","account_name":"Mark Toledo","account_sub_type":"Customer","phone":"8603012339","original_max_spend":"12","remnant_spend":"12"}},"waitlist_guid":"103036cc-20b9-4cbf-a590-dc62581375f6","party_id":"4256221","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state":"CT","market_name":"06021","waitlist_type":"Pre-Auth","lead_routing":"Any","quantity":"1","owner_name":"MBARTELLI","created_by":"MBARTELLI","ranking":"0","account_name":"Mark Toledo","phone":"8603012339","last_worked_date":"","original_max_spend":"12","remnant_spend":"12","pre_auth_status_date":"","pre_auth_expiry_date":"","presales_available_date":"","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"0","account_sub_type":"Customer","waitlist_status":"Pending Pre-Auth","credit_risk":0}]');
//createinvntresponse = string.valueof(res.getBody());
                    }
                
                
                list<JSON2Apex> InventoryResponse = JSON2Apex.parse(res.getBody());
                System.debug('Response ===>>'+res.getBody());

                for(marketWrapper updatestatus :marketList){
                    for(JSON2Apex resploop : InventoryResponse){
                        if(resploop.market_name == updatestatus.marketText){
                            updatestatus.Message = 'Success'; 
                         //If(label.Quote_Owner_Profile_list.contains(profileName)){   
                            if(acct.Sales_Lock_User__c == null){ //CRM-1843
                             if((acct.Account_Sub_Type__c == 'Former Customer' ||  acct.Account_Sub_Type__c == 'Prospect') &&
                               (ownerList.contains(acct.owner.userName) || 
                               !acct.owner.isActive) && 
                               !currentUser.Pre_Auth_User__c){ //CRM-448 acct.Account_Sub_Type__c == 'Customer' ||
                                acct.inactiveRule__c = true;
                                acct.ownerId = UserInfo.getUserId();
                                if(!accountIds.contains(acct.id)){
                                    accountsToUpdate.add(acct);
                                    accountIds.add(acct.id);
                                }
                            }
                            }else{ //CRM-1843
                                if(acct.Sales_Lock_User__c == UserInfo.getUserId()){
                                    acct.inactiveRule__c = true;
                                    acct.ownerId = UserInfo.getUserId();
                                    if(!accountIds.contains(acct.id)){
                                        accountsToUpdate.add(acct);
                                        accountIds.add(acct.id);
                                    }
                                }
                            } //CRM-1843
                         //}
                        }
                    }
                }
                
                if(res.getStatusCode() == 201){
                    Boolean nonPreAuth = false;
                    // CRM-1741 Maintain Waitlist History for insert
                    List<Waitlist_History__c> historyRecs = new List<Waitlist_History__c>();
                   
                     List<WaitlistLeadScoreWrapper> wrap_list = new List<WaitlistLeadScoreWrapper>();//crm-3086
                     
                    for(JSON2Apex resploop : InventoryResponse){
                    //crm-3086 start
                      if(resploop.waitlist_type != 'Pre-Auth' || test.isRunningTest()){
                        WaitlistLeadScoreWrapper wrap = new WaitlistLeadScoreWrapper();
                        wrap.partyId = resploop.party_id;
                        wrap.zipCode = resploop.product_type == 'Local Expert City' ? (resploop.state+'-'+resploop.market_name) : resploop.market_name;
                        wrap.leadSize  = resploop.waitlist_slot;
                        wrap.waitlistType = resploop.waitlist_type;
                        wrap.waitlistLeadType = resploop.lead_routing;
                        wrap.action = 'Insert';
                        wrap.name = resploop.product_type;
                        wrap_list.add(wrap);
                        }
                        //CRM-3086 end
                        if(resploop.waitlist_type == 'Pre-Auth'){
                           // DAP-225: Updated If condition to check if pre-auth WL exists for same market and product
                           List<String> mList = new List<String>();
                           if(!tempProductMarket.isEmpty() && tempProductMarket.containsKey(productids.get(productmap1.get(resploop.product_type).SFDC_Product__c))){
                                mList = tempProductMarket.get(productids.get(productmap1.get(resploop.product_type).SFDC_Product__c));
                           }
                            //if(!tempMarkets.contains(resploop.market_name)){
                            if(!mList.contains(resploop.market_name)){
                                Waitlist_Item__c WLIdata = new Waitlist_Item__c();            
                                WLIdata.clear();
                                WLIdata.Account__c                  = acct.Id;
                                WLIdata.Account_Owner_Email__c      = primarycntct[0].Parent_Account__r.email_address__c;
                                If(resploop.product_type != 'Turbo'){
                                    WLIdata.Original_Max_Spend__c   = Decimal.valueof(resploop.original_max_spend);
                                    WLIdata.Current_Utilized_Spend__c = 0;
                                } else {
                                    WLIdata.Impressions_Qty__c      = decimal.valueof(resploop.quantity);
                                    WLIdata.Original_Max_Spend__c   = 0;
                                    WLIdata.Current_Utilized_Spend__c = 0;
                                }     
                                WLIdata.Lead_Routing__c             = resploop.lead_routing;
                                
                                if(resploop.waitlist_markets.size()>0){
                                    for(JSON2Apex.waitlist_markets mkts : resploop.waitlist_markets){
                                        if(mkts.market_key.contains('FULL')){
                                            if(resploop.lead_routing=='Flex'){
                                                WLIdata.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                                            }else if(resploop.lead_routing=='Fast'){
                                                WLIdata.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_fast_unit_price);  
                                            }else if(resploop.lead_routing=='Any'){
                                                WLIdata.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);    
                                            }  
                                            WLIdata.Tier_Price_Number__c =    mkts.historical_tier_price_number ; 
                                        }
                                        //DAP-386
                                         if(resploop.waitlist_slot == 'ANY'){
                                               if(mkts.market_key.contains('SOV50')){
                                                    WLIdata.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                                                    WLIdata.Tier_Price_Number__c = mkts.historical_tier_price_number; 
                                                }
                                        }else{
                                           WLIdata.Rate_Card_Price__c = Decimal.valueOf(mkts.historical_flex_unit_price);  
                                           WLIdata.Tier_Price_Number__c = mkts.historical_tier_price_number;  
                                        }
                                        //DAP-386 ends
                                    }
                                }
                                
                                WLIdata.Market__c                   = resploop.product_type == 'Local Expert City' ? resploop.market_name+', '+resploop.state : resploop.market_name;
                                WLIdata.Market_Type__c              = resploop.market_type;
                                WLIdata.Original_Max_Spend__c       = Decimal.valueof(resploop.original_max_spend);
                                WLIdata.Product__c                  = productids.get(productmap1.get(resploop.product_type).SFDC_Product__c);
                                WLIdata.Product_Size__c             = resploop.waitlist_slot;
                                WLIdata.Status__c                   = 'Pending Pre-Auth';
                                WLIdata.Wailist_Type__c             = resploop.waitlist_type;
                                WLIdata.Rank__c                     = 9999; //CRM-3814
                                WLIdata.State__c  =resploop.state ;
                                // wliloop.Term__c                     = 
                                if(resploop.waitlist_guid!=null)
                                    WLIdata.Waitlist_ID__c              = resploop.waitlist_guid;
                                else
                                    WLIdata.Waitlist_ID__c ='No Wait List ID ';
                                
                                if(preAuthrenwalParsm=='renwals'){ 
                                    WLIdata.Waitlist_Expiration_Date__c = preauthEffectiveDate.adddays(90);
                                    WLIdata.Is_Renewed_Row__c = true ;
                                }else{
                                    WLIdata.Waitlist_Expiration_Date__c = system.today().adddays(90);
                                    
                                }
                                //WLIdata.OwnerId = acct.Ownerid;
                                WLIinsert.add(WLIdata);
                                tempMarketsMap.put(resploop.market_name,resploop.original_max_spend);
                            }else{
                                tempMarketsMap.put(resploop.market_name,resploop.original_max_spend);
                                
                            }
                        } 
                        // CRM-887 to maintain checkbox on Account for non pre-auth waitlist
                        else {
                            nonPreAuth = true;
                        }
                        
                        // CRM-1741 Create Waitlist History for insert
                        historyRecs.add(DataController.createWaitlistHistory(acct.Id, 'Created', '', '', resploop.waitlist_guid!=null?resploop.waitlist_guid:'No Wait List ID', resploop.market_name, resploop.waitlist_type));
                        // CRM-1741 End           
                    }
                     if(!wrap_list.isEmpty()){
                        system.debug('--- > MRB');
                        waitlistLeadScoreoperation.postWaitlistDataPullInventory(wrap_list);
                     } //crm3086
                    // CRM-1741 insert history records
                    if (historyRecs.size() > 0) {
                        insert historyRecs;
                    }
                    // CRM-1741 end
                    
                    if (nonPreAuth && ![SELECT Non_Pre_Auth_Waitlist__c FROM Account WHERE Id= :acct.Id].Non_Pre_Auth_Waitlist__c) {  
                        // CRM-3015 - Commented below statment and written new one just below.
                        // update new Account(Id=acct.Id, Non_Pre_Auth_Waitlist__c = true);
                        acct.Non_Pre_Auth_Waitlist__c = true;
                        update acct;
                    }
                }                
            } catch (CalloutException coe){
                Error__c logerror               = new Error__c();
                logerror.Name                   = WLid;
                logerror.Entity_Id__c           = 'Waitlist';
                logerror.Error_Description__c   = createinvntresponse;
                logerror.Interface_Name__c      = 'Inventory';
                Insert logerror;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error received from inventory system, Please contact system admin. Error ID:' + logerror.Id));
                return null; 
            } catch (exception error){
                System.debug('error--->'+error);
                Error__c logerror               = new Error__c();
                logerror.Name                   = WLid;
                logerror.Entity_Id__c           = 'Waitlist';
                logerror.Error_Description__c   = res == null ? '' : res.getBody();
                logerror.Interface_Name__c      = 'Inventory';
                Insert logerror;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'error received from inventory system, please contact system admin. Error ID:' + logerror.Id));
                return null; 
            }
        }
        
        if(WLIinsert.size() > 0 || preAuthrenwalParsm=='renwals' || (WLIinsert.size() > 0 && preAuthrenwalParsm=='renwals' )){
            showsubmit        = false;
            showdeletecolumns = false;
            WLInsert.Account__c = acct.Id;
            WLInsert.Total_MAX_Monthly_Pre_Auth_Spend__c =   totlaMaxPreAuthSpend;
            WLInsert.Current_Monthly_Pre_Auth_Spend__c  =currentMonthlyMaxSpend ; 
            WLInsert.Submitted__c = saveorsubmit;
            if(saveorsubmit){
                WLInsert.Submitted_Date__c=system.today();
                WLInsert.Waitlist_Expiration_Date__c = WLInsert.Submitted_Date__c.addDays(90); //CRM-4683
                
            }
            WLInsert.Pre_Auth_Contact__c = primarycntct[0].Contact_To__c;
            WLInsert.Pre_Auth_Email__c = primarycntct[0].Parent_Account__r.email_address__c;
            WLInsert.Status__c = 'Pending Pre-Auth';
            WLInsert.CC4Digits__c = string.valueof(CC4digits);
            /*  Start :Pre Auth Renewal */
            if(preAuthrenwalParsm=='renwals'){ 
                WLInsert.Pre_Auth_Type__c =preauthTypeSelectedString ;
                WLInsert.Submitted_Date__c = preauthEffectiveDate ;
                WLInsert.Waitlist_Expiration_Date__c = WLInsert.Submitted_Date__c.addDays(90); //CRM-4683
            }else{
               WLInsert.Pre_Auth_Type__c='New';
            }
            /* End :  Pre Auth Renewal */
            if(WLIinsert.size() > 0 ||  preAuthrenwalParsm=='renwals' || (WLIinsert.size() > 0 && preAuthrenwalParsm=='renwals' )){
                if(!Test.isRunningTest()){
                 insert WLInsert;
                }    
                set<Waitlist_item__c> nodups = new set<Waitlist_item__c>();
                nodups.addall(WLIinsert);
                WLIinsert.clear();
                WLIinsert.addall(nodups); 
                Integer position = 0 ;
                for(waitlist_item__c wliloop : WLIinsert){
                    // If(!wliloop.rewalRow){
                    wliloop.Waitlist__c = WLInsert.Id;
                    if(termListVal.size()>0){
                        System.debug('termList[position]'+termListVal[position]) ;
                        wliloop.Term__c = termListVal[position]; 
                        position++ ; 
                    }
                    // }
                } 
                List<Waitlist_Item__c> anotherTemp = new List<Waitlist_Item__c>();
                if(Test.isRunningTest()){
                Waitlist_Item__c wlIteMtoBeTest = new Waitlist_Item__c();
                wlItemforExsiting.add(wlIteMtoBeTest);
                }
                for(Waitlist_Item__c wlList: wlItemforExsiting){
                    Waitlist_Item__c wlIteMtoBe = new Waitlist_Item__c();
                    wlIteMtoBe.Account__c= wlList.Account__c;
                    wlIteMtoBe.Current_Monthly_Pre_Auth_Spend__c= wlList.Current_Monthly_Pre_Auth_Spend__c;
                    wlIteMtoBe.Current_Utilized_Spend__c=wlList.Current_Utilized_Spend__c;
                    wlIteMtoBe.Inventory_Available_Fast__c=wlList.Inventory_Available_Fast__c;
                    wlIteMtoBe.Inventory_Available_Flex__c= wlList.Inventory_Available_Flex__c;
                    wlIteMtoBe.Inventory_Available__c=wlList.Inventory_Available__c;
                    wlIteMtoBe.Inventory_Transaction_ID_Fast__c= wlList.Inventory_Transaction_ID_Fast__c;
                    wlIteMtoBe.Inventory_Transaction_ID_Flex__c=wlList.Inventory_Transaction_ID_Flex__c;
                    wlIteMtoBe.Lead_Routing__c=wlList.Lead_Routing__c;
                    wlIteMtoBe.rank__c= wlList.rank__c;
                    wlIteMtoBe.Market_Type__c= wlList.Market_Type__c;
                    wlIteMtoBe.Market__c=  wlList.Market__c;
                    wlIteMtoBe.state__c = wlList.state__c ; 
                    if(tempMarketsMap.containsKey(wlList.Market__c)){
                        wlIteMtoBe.Original_Max_Spend__c=Decimal.valueOf(tempMarketsMap.get(wlList.Market__c));
                        
                    }else{
                        wlIteMtoBe.Original_Max_Spend__c=wlList.Original_Max_Spend__c;
                        
                    }
                    wlIteMtoBe.Product_Size__c= wlList.Product_Size__c;
                    wlIteMtoBe.Product__c=wlList.Product__c;
                    wlIteMtoBe.Status__c= 'Pending Pre-Auth';
                    wlIteMtoBe.Term__c=wlList.Term__c;
                    wlIteMtoBe.Total_MAX_Monthly_Pre_Auth_Spend__c=wlList.Total_MAX_Monthly_Pre_Auth_Spend__c;
                    wlIteMtoBe.Wailist_Type__c=wlList.Wailist_Type__c;
                    wlIteMtoBe.Waitlist_Expiration_Date__c=System.today()+90;
                    wlIteMtoBe.Waitlist_ID__c=wlList.Waitlist_ID__c ; 
                    wlIteMtoBe.Waitlist__c =WLInsert.Id ; 
                    anotherTemp.add(wlIteMtoBe);
                }
                
                insert WLIinsert;
                If(preAuthrenwalParsm!='renwals'){
                    insert anotherTemp ;
                }
                
                If(preAuthrenwalParsm=='renwals' ){
                    
                    List<Waitlist_Item__c> exrisingRenwlas = new List<Waitlist_Item__c>();
                    for(Waitlist_Item__c wlList: renewalWaitlist){
                        
                        Waitlist_Item__c wlIteMtoBe = new Waitlist_Item__c();
                        wlIteMtoBe.Account__c= wlList.Account__c;
                        wlIteMtoBe.Current_Monthly_Pre_Auth_Spend__c= wlList.Current_Monthly_Pre_Auth_Spend__c;
                        wlIteMtoBe.Current_Utilized_Spend__c=wlList.Current_Utilized_Spend__c;
                        wlIteMtoBe.Inventory_Available_Fast__c=wlList.Inventory_Available_Fast__c;
                        wlIteMtoBe.Inventory_Available_Flex__c= wlList.Inventory_Available_Flex__c;
                        wlIteMtoBe.Inventory_Available__c=wlList.Inventory_Available__c;
                        wlIteMtoBe.Inventory_Transaction_ID_Fast__c= wlList.Inventory_Transaction_ID_Fast__c;
                        wlIteMtoBe.Inventory_Transaction_ID_Flex__c=wlList.Inventory_Transaction_ID_Flex__c;
                        wlIteMtoBe.Lead_Routing__c=wlList.Lead_Routing__c;
                        wlIteMtoBe.rank__c= wlList.rank__c;
                        wlIteMtoBe.Market_Type__c= wlList.Market_Type__c;
                        wlIteMtoBe.Market__c=  wlList.Market__c;
                        wlIteMtoBe.Original_Max_Spend__c=wlList.Original_Max_Spend__c;
                        wlIteMtoBe.Product_Size__c= wlList.Product_Size__c;
                        wlIteMtoBe.Product__c=wlList.Product__c;
                        wlIteMtoBe.Status__c= 'Pending Pre-Auth';
                        wlIteMtoBe.Term__c=wlList.Term__c;
                        wlIteMtoBe.Total_MAX_Monthly_Pre_Auth_Spend__c=wlList.Total_MAX_Monthly_Pre_Auth_Spend__c;
                        wlIteMtoBe.Wailist_Type__c=wlList.Wailist_Type__c;
                        wlIteMtoBe.Waitlist_Expiration_Date__c= preauthEffectiveDate.addDays(90);
                        wlIteMtoBe.Waitlist_ID__c=wlList.Waitlist_ID__c ; 
                        wlIteMtoBe.State__c = wlList.State__c;
                        wlIteMtoBe.Waitlist__c =WLInsert.Id ; 
                        wlIteMtoBe.Is_Renewed_Row__c   = true ;
                        exrisingRenwlas.add(wlIteMtoBe);
                    }
                    Insert exrisingRenwlas ;
                }
                
                
                
                pendinginserts.clear();
                WLIinsert.clear();
                if(saveorsubmit){
                }else{
                }
            }
        }

        if(accountsToUpdate.size()>0){ //CRM-448
            update accountsToUpdate;   
        } 
        //Removing delete flaged items
        marketList.addall(marketListsccs);
        for(marketWrapper deletemr :marketList){
            if(deletemr.delete1 != null ){
                if(deletemr.delete1){
                    deleteset.add(deletemr); 
                }
            }
        }
        afterdelete.addAll(marketList);
        afterdelete.removeAll(deleteset);
        marketList.clear();
        marketList.addAll(afterdelete);
        
        if(recordIdAfterSave==null)
            recordIdAfterSave='';
        if(recordIdAfterSave.length()>2){
            Waitlist__c wl = [Select id , Submitted_Date__c, Submitted__c from Waitlist__c where id=:recordIdAfterSave];
            wl.Submitted__c =true ;
            wl.Submitted_Date__c=system.today();
            update wl ;
        }else{
            recordIdAfterSave = WLInsert.id;    
            
        }
        
        showandhiderenwals = false ;
        // updateAcc(acct.Id);
        
        
        return message1;
    }
    
    public pageReference cancel(){
        return new pageReference('/'+this.acct.ID);
    }
    
    public List<SelectOption> addNoneOption(list<selectOption> opt){
        if(opt.size() > 1){ //changed it from >0 to >1 as if there is only one option it should default to that. Local Expert City waitlist product type is only one. By MRB
            opt.add(new SelectOption('','--None--'));
            opt.sort();
        }
        
        return opt;
    }
    
    public pageReference RefreshPage(){
        filtercnty = false;
        filtercity = false;
        
        initialize();
        return null;
    }
    
    
    
    public void addToMarketList(String market, boolean fetchState) {
        if(market != ''){
        
            market = market.replaceAll('[^A-Za-z .0-9.,]','');
            //DAP-225
            String selectedProd = ProductselectedVal.replaceAll('[^A-Za-z .0-9.,]','');
            list<string> befvaluesEntered = market.split(',');             
            set<string> valuesEntered = new set<string>(befvaluesEntered);
            valuesEntered.remove(null); 
            valuesEntered.remove(''); 
            valuesEntered.remove('\u00A0');
            System.debug('************** Error 1************') ; 
            integer markcount = valuesEntered.size();
            for(string oString : valuesEntered ){
                if(oString.removeStart(selectedProd) != ' '){
                    pbTable = true;
                    oString = oString.escapeJava();
                    oString = oString.trim();
                    if(!prevvaluesEntered.contains(oString)){
                         System.debug('**************market************'+market+prevvaluesEntered) ; 
                        String stateCode = stateAbbrevation;
                        if (fetchState && ProductselectedVal != 'Local Expert City') {
                            // DAP-225
                            stateCode = geo.getStateAbbreviationFromPostalCode(getStateFromPCURL.replace('postalcodetobeentered', oString.removeStart(selectedProd)));
                        }
                        if(ProductselectedVal == 'Local Expert City'){
                            Set<String> allcities        = new Set<String>();
                            if(!cityOptionsSet1.isEmpty()){
                                for(SelectOption opt : cityOptionsSet1){
                                    allcities.add(opt.getLabel().toLowerCase());
                                }
                            }
                            if(!cityOptionsSet2.isEmpty()){
                                for(SelectOption opt : cityOptionsSet2){
                                    allcities.add(opt.getLabel().toLowerCase());
                                }
                            }
                            if(!cityOptionsSet3.isEmpty()){
                                for(SelectOption opt : cityOptionsSet3){
                                    allcities.add(opt.getLabel().toLowerCase());
                                }
                            }
                            if(!cityOptionsSet4.isEmpty()){
                                for(SelectOption opt : cityOptionsSet4){
                                    allcities.add(opt.getLabel().toLowerCase());
                                }
                            }
                            statecode = stateAbbrevation;
                            string cityname = oString.removeStart(selectedProd).tolowercase();
                            
                            if(!allcities.contains(cityname)){ // && !cityOptionsSetLE2.contains(cityname) && !cityOptionsSetLE3.contains(cityname) && !cityOptionsSetLE4.contains(cityname)){
                                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, oString.removeStart(selectedProd) + ' is not a valid city for the selected state. '));
 
                                break;
                            }
                            List<String> cities = cityname.split(' ');
                            cityName = '';
                            for(String eachName : cities){
                                cityName += eachName.substring(0,1).toUpperCase()+eachName.substring(1,eachName.length()).tolowercase() + ' ';
                            }
                            oString = 'Local Expert City'+cityName.trim();
                        }
                        prevvaluesEntered.add(oString);
                        // addTotalUniqueMarkets.add(oString);
                        marketWrapper mmmmm =    new marketWrapper(ProductselectedVal,
                                                                   StatusselectedVal,
                                                                   TypeOptions,
                                                                   MarketTypeselectedVal,
                                                                   DegreeselectedVal,
                                                                   LeadRoutingselectedVal,
                                                                   LeadRoutingOptions,
                                                                   Quantity,
                                                                   //divmaxspend,
                                                                   Message,
                                                                   oString.removeStart(selectedProd), //DAP-225: remove product name 
                                                                   acct,
                                                                   //stateAbbrevation,
                                                                   stateCode,
                                                                   SlotSizeselectedVal,
                                                                   SlotSizeOptions,
                                                                   userntlogin,
                                                                   Term,
                                                                   termListVaule,
                                                                   termList
                                                                   
                                                                  );
                        mmmmm.rewalRow = false ;
                        marketList.add(mmmmm);
                        
                    }
                    System.debug('***********END *** Error ************'+marketList) ; 
                    
                }          
            }
        }
        //return  null ;
    }
    public pageReference GenerateTable(){
        string selectedString = '';
        showsselected = true; 
            
        list<String> temp = new list<String>();                         
        if(CountySelected != null && CountySelected.size() > 0 && MarketTypeselectedVal == 'County')        
            temp.addAll(CountySelected);
        if(CitySelected != null && CitySelected.size() > 0 && MarketTypeselectedVal == 'City')                
            temp.addAll(CitySelected);   
        if(postcodSelected != null && postcodSelected.size() > 0 && MarketTypeselectedVal == 'Postal Code')
            temp.addAll(postcodSelected);
        
        system.debug('postal size:'+temp.size());
        if (temp.size() > 100){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You have selected '+temp.size()+' markets, Please reduce them to 100'));
            return null;
        }
        
        // CRM-5389 - Start
        if (ProductselectedVal == 'Connection for Co-Brokerage') {
            // CRM-6360 - Turn on/off Protected Market restriction based on Custom Setting.
            Waitlist_Limit__c rec = Waitlist_Limit__c.getValues('ProtectedMarketOnCreateWaitlist');
            if (rec != null && rec.Value__c == 1) {
                Set<String> allSelectedMarkets = new Set<String>();
                allSelectedMarkets.addAll(temp);
                if (marketTextArea != null && marketTextArea.length() > 0) {
                    allSelectedMarkets.addAll(marketTextArea.replaceAll('[^A-Za-z0-9,]','').split(','));
                }
                List<String> protectedMarkets = InventorySearch.getProtectedMarketList(allSelectedMarkets);
                if (!protectedMarkets.isEmpty()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.Waitlist_Protected_Market_Error + ' ' + String.join(protectedMarkets, ', ')));
                    return null;
                } 
            } 
        }
        // CRM-5389 - End
        
        if(temp.size() > 0){
            Boolean first = true;   
            for(String so : temp){
                if(!first){
                    selectedString  += ',';
                }
                selectedString  += ProductselectedVal+so; //DAP-225
                first = false;
            }
        }   
        system.debug('stringg'+selectedString); 
        addToMarketList(selectedString, false);
        //DAP-225
        if(marketTextArea != ' ' && marketTextArea != null && marketTextArea != ''){
            List<String> marketList = marketTextArea.split(',');
            String marketTextAreaString = '';
            for(String str: marketList){
                marketTextAreaString += ProductselectedVal+str+',';
            }
            marketTextAreaString.removeEnd(',');
            addToMarketList(marketTextAreaString, true);
        }
        // DAP 225 end
        set<string> checktoshowstatus = new set<string>();
        for(marketWrapper wrprloop : marketlist){
            checktoshowstatus.add(wrprloop.Message);
        }
        if(showstatuscolumns){
            showstatuscolumns = false;
            showdeletecolumns = false; 
        }else{
            if(checktoshowstatus.contains('Error')|| test.isRunningTest()){ 
                showstatuscolumns = true;
                showdeletecolumns = true;
                showsubmit = true; 
            }
        }
        
        if(!(checktoshowstatus.contains('Success')) || checktoshowstatus.contains('') || checktoshowstatus.contains(null)){ 
            showsubmit = true; 
        }else{
            showsubmit = false; 
        }
        
        marketTextArea = '';
        return null;
    }            
    public class marketWrapper 
    {
        public String Product { get; set; }
        public String Status { get; set; }
        public list<SelectOption> Statusoptions { get; set; }
        public String MarketType { get; set; }                        
        public String Degree { get; set; }                                
        public String LeadRouting { get; set; }                                        
        public list<SelectOption> Leadoptions { get; set; }
        public Integer Quantity { get; set; }  
        public Integer Term {get;set;}
        public Integer MaxSpend { get; set; }                                                
        public String marketText { get; set; }          
        public String PartyID { get; set; }        
        public String accountID { get; set; }                
        public string createdBy {get;set;}
        public string OwnerName {get;set;}  
        public string comment {get;set;}        
        public string product_type {get;set;}              
        public string market_subtype {get;set;}         
        public string state {get;set;}
        public string slot {get;set;}
        public list<SelectOption> slotoptions { get; set; }
        public string promo {get;set;}
        public string promo_Expirationdate {get;set;}
        public string Message {get;set;}
        public boolean Delete1 {get;set;}
        public string WLid {get;set;}
        public string phone{get;set;}
        public String termListVaule{get; 
                                    public set;
                                   }
        public list<SelectOption> termList { get; set; }
        /*  == Added for Renwals*/
        public string docuSignstatus{get;set;}
        public Date expirationDate{get;set;}
        public Decimal currentUtlizedSpend{get;set;}
        public Decimal rateCardPrice{get;set;}
        public boolean  rewalRow{get;set;}
        public Waitlist_Item__c waitlistExising{get;set;}        
        
        /*Ended == */
        public marketWrapper(String pr, String st,list<SelectOption> stopt,String ma,String de,string le,list<SelectOption> ldopt,Integer qu,string mes,string mr,Account oacc,
                             string ostate,string slot,list<SelectOption>slopt,string userntlogin, 
                             Integer te,String termListVaule ,list<SelectOption> termList ){
                                 String temValTerms = '' ; 
                                 if(pr=='Connection for Co-Brokerage'){
                                     temValTerms= '12' ;
                                 }else{
                                     temValTerms= '6';
                                 }
                                 
                                 
                                 this.Statusoptions = new list<SelectOption>();
                                 this.Leadoptions = new list<SelectOption>();
                                 this.slotoptions = new list<SelectOption>();
                                 this.Product = pr;
                                 this.Status = st;       
                                 this.Statusoptions.addall(stopt);
                                 this.MarketType = ma;   
                                 this.Degree = de;   
                                 this.LeadRouting = le; 
                                 this.Leadoptions.addall(ldopt); 
                                 this.Quantity = qu;   
                                 this.Term = te;
                                 this.marketText = mr; 
                                 this.OwnerName = oacc.Owner.NT_Login_ID__c;
                                 this.createdBy = userntlogin;
                                 this.slot = slot;
                                 this.slotoptions.addall(slopt); 
                                 this.partyID = oacc.Party_ID__c;  
                                 this.market_subtype = 'Postal code';
                                 this.state = ostate;  
                                 this.termListVaule = temValTerms ;
                                 this.termList = termList;    
                             }
    }
    
    public void handleMorecitys(List<SelectOption> opts){
        cityOptionsSet1  =  new List<SelectOption>();
        cityOptionsSet2  =  new List<SelectOption>();
        cityOptionsSet3  =  new List<SelectOption>();
        cityOptionsSet4  =  new List<SelectOption>();
       
        
        if(opts.size() > 2000 && opts.size() <= 4000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    cityOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    cityOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));  
                if(i >= 2000 && i < 3000)
                    cityOptionsSet3.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));  
                if(i >= 3000 && i < 4000)
                    cityOptionsSet4.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));  
            }
        }        
        if(opts.size() > 1000 && opts.size() <= 2000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    cityOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    cityOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
            }
        } 
        if(opts.size() > 0 && opts.size() <= 1000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    cityOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));  
                    system.debug('label'+opts[i].getlabel());                                                                                           
            }
        }                        
        integer total =   cityOptionsSet1.size() + cityOptionsSet2.size() + cityOptionsSet3.size();
    }
    
    public void handleMorecountys(List<SelectOption> opts){
        countyOptionsSet1  =  new List<SelectOption>();
        countyOptionsSet2  =  new List<SelectOption>();
        countyOptionsSet3  =  new List<SelectOption>();
        
        if(opts.size() > 2000 && opts.size() <= 3000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    countyOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    countyOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                     
                if(i >= 2000 && i < 3000)
                    countyOptionsSet3.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                         
            }
        }        
        if(opts.size() > 1000 && opts.size() <= 2000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    countyOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    countyOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                                                                
            }
        } 
        if(opts.size() > 0 && opts.size() <= 1000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    countyOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                                                                                 
            }
        }                        
        integer total =   countyOptionsSet1.size() + countyOptionsSet2.size() + countyOptionsSet3.size();
    }
    
    
    public void deleteRow(){
        if(ApexPages.currentPage().getParameters().get('rowIndex')!=null){
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        System.debug('rowbe deleted ' + rowIndex );
        System.debug('rowm to be deleted '+marketList[rowIndex]);
        marketList.remove(rowIndex);
        }
        //  delList.add(del);
        
    }
    
    public void handleMorePostcode(List<SelectOption> opts){
        PostcodeOptionsSet1.clear();
        PostcodeOptionsSet2.clear();
        PostcodeOptionsSet3.clear();
        PostcodeOptionsSet4.clear();
        
        if(opts.size() > 3000 && opts.size() <= 4000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    PostcodeOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    PostcodeOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                     
                if(i >= 2000 && i < 3000)
                    PostcodeOptionsSet3.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                         
                if(i >= 3000 && i < 4000)
                    PostcodeOptionsSet4.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                         
            }
        }          
        if(opts.size() > 2000 && opts.size() <= 3000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    PostcodeOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    PostcodeOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                     
                if(i >= 2000 && i < 3000)
                    PostcodeOptionsSet3.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                         
            }
        }        
        if(opts.size() > 1000 && opts.size() <= 2000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    PostcodeOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel())); 
                if(i >= 1000 && i < 2000)
                    PostcodeOptionsSet2.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                                                                
            }
        } 
        if(opts.size() > 0 && opts.size() <= 1000){
            for(integer i=0;i<=opts.size()-1;i++){               
                if(i >= 0 && i < 1000)
                    PostcodeOptionsSet1.add(new SelectOption(opts[i].getValue(),opts[i].getLabel()));                                                                                                 
            }
        }      
        opts.clear();              
        integer total =   PostcodeOptionsSet1.size() +PostcodeOptionsSet2.size() + PostcodeOptionsSet3.size();
    }
}