/*
CRM-4721 Modify/ Create the pages for manage billing profile/ manage billing account
CRM-4717 Zuora changes for subscription centric payment
CRM-4351 Accept the payment method at the subscription level.
*/
public class Z_ManageSubscripitonPaymentMethods {
    public Boolean renderHPM {get; set;}
    public String ccHpmPageId {get;set;}
    public String Reasoncode {get;set;}  
    public String sfdcAccountId {get; set;}
    public String QuoteId {get; set;}
    Public Integer size{get;set;}
    Public String Ascdesc{get; set;}
    Public String orderByColumn{get; set;}
    Public String statusvalue{get; set;}
    Public String Fieldvalue{get; set;}
    Public String AssetNumber{get; set;}
    Public String FieldvalueMask{get; set;}
    Public String Fieldapi{get; set;}
    public String zuoraAccountId {get; set;}
    public Integer rowIndex{get; set;}
    public Integer rowIndex2{get; set;}
    Map<String, Paymentprofilewrapper> paymentmethods;
    public List<selectOption> status {get;set;} 
    Boolean valuechanged = false; 
    Boolean updatedsubs =false;
    public Boolean hasConfigError {get; set;}
    public Boolean hasSfdcAccount{get; set;}
    public Boolean creatingQuote{get; set;}  
    Public Boolean Selectall{get; set;} 
    public Zuora.zApi zApi;
    Public Set<Id> Authorizedids {get; set;}
    public Set<Id> ErrorSubIdSet;
    public List<SelectOption> paginationSizeOptions {get;set;}
    public List<SelectOption> ReasonCodes {get;set;}
    public List<SelectOption> Fields {get; set;}
    public List <SubscriptionWrapper> SubwrapperRecordList{get;set;}
    public List <CoMarketingRelWrapper> CoMarketingRelWrapperList{get;set;}
    public List<Paymentprofilewrapper> paymentProfiles {get; set;}
    public Account sfdcAccount {get;set;}
    public BigMachines__Quote__c quote {get;set;}    
    public List<Quotelineitemswrapper> Quotelineitems {get; set;} 
    public ApexPages.StandardSetController setCon { get; set;}  
    public Id profileToDelete {get;set;}
    public Id profileToEdit {get;set;}
    Public Set<String> Authorizedpayids;
    /** Credit Card Fields **/
    public String cardType {get;set;}
    public String expirationDate {get;set;}
    public String cardHolderName {get;set;}
    public String cardCVV {get;set;}   
    public String billingAddress {get;set;}
    public String billingCity {get;set;}
    public String billingState {get;set;}
    public String billingPostalCode {get;set;}
    public String billingCountry {get;set;}
    public String paymentMethodType {get;set;}
    public Boolean LenderPage = false;
    public String rId {get; set;}
    public String ActType{get; set;}
    public String SendtoZuora {get;set;}
    public Z_ManageSubscripitonPaymentMethods(){
        Authorizedpayids = new set<String>();
        Authorizedids = new Set<Id>();
        Selectall = false;
        Ascdesc = 'ASC';
        creatingQuote = false;
        statusvalue = 'ALL';
        renderHPM = false;
        String objectId = ApexPages.currentPage().getParameters().get('id');
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?'); 
        system.debug('at constructor');
        // objectId = 'a1R1h000000kR11';
        if (String.isNotBlank(objectId)) {
            if ((!LenderPage && searchForQuote(objectId)) || searchForSfdcAccount(objectId)) {              
                hasConfigError = false;         
            } else {
                appendError('Account not found');
                hasConfigError = true;
            }
        } else {
            appendError('Id not found');
            hasConfigError = true;
        }
        //LenderChanges.
        if(pageName != null && pageName == 'LenderPaymentProfile' || test.isrunningtest()){
            LenderPage = true; 
            this.rId = ApexPages.currentPage().getParameters().get('rId');
            String renderHPM = ApexPages.currentPage().getParameters().get('renderhpm');
            this.ActType = ApexPages.currentPage().getParameters().get('ActType');
            this.SendtoZuora = ApexPages.currentPage().getParameters().get('sendToZuora');
            system.debug('SendtoZuora@1' +SendtoZuora);
            system.debug('ActType '+ActType);
            if(renderhpm !=null && renderhpm == 'true')
            QueryHMPvalues();
        }          
    }
    public void QueryHMPvalues(){
        zqu__HostedPageLiteSetting__c settingList = [SELECT zqu__PageId__c, zqu__PaymentMethodType__c, zqu__ComponentName__c FROM zqu__HostedPageLiteSetting__c WHERE zqu__ComponentName__c = 'ManagePaymentProfile' and zqu__PaymentMethodType__c = 'Credit Card' LIMIT 1];        
        this.renderHPM= true;
        this.paymentMethodType ='CreditCard';
        this.ccHpmPageId = settingList.zqu__PageId__c; 
    }
    public PageReference goBack() {
        
        if(ActType != null && rId !=null){
            String aId = ApexPages.currentPage().getParameters().get('Id');
             List<Account_Relationship__c> Childact = [Select id,Parent_Account__r.Name, Parent_Account__c, Total_comarketing_assets__c ,comarketing_status__c,Child_Account__c, Child_Account__r.Name, Comarketing_Zuora_InProgress__c from Account_Relationship__c where Id =:rId LIMIT 1];  
            
            if(ActType == 'Lender Individual' && Childact.size() >0){
                return new PageReference('/apex/comarketingDetails?rId='+rId+'&id='+aId+'&accounttype=Lender Individual&status='+Childact[0].comarketing_status__c+'&zuoraStatus='+Childact[0].Comarketing_Zuora_InProgress__c+'&name='+Childact[0].Child_Account__r.Name+'&TotalAssets='+Childact[0].Total_comarketing_assets__c);
            }else{
               return new PageReference('/apex/comarketingDetails?rId='+rId+'&id='+Childact[0].Parent_Account__c+'&accounttype=Realtor+Agent&status='+Childact[0].comarketing_status__c+'&zuoraStatus='+Childact[0].Comarketing_Zuora_InProgress__c +'&name='+Childact[0].Parent_Account__r.Name+'&TotalAssets='+Childact[0].Total_comarketing_assets__c);            
            }
        }else{       
        return  new PageReference('/' + sfdcAccountId); 
        }
    }
    public PageReference renderIFrame() {
        if(LenderPage && rId !=null){
        PageReference pr = new PageReference('/apex/LenderPaymentProfile?id='+ApexPages.currentPage().getParameters().get('id')+'&rId='+rId+'&renderhpm=true&ActType='+ActType+'&sendToZuora='+sendtoZuora);
        pr.setRedirect(true);
        return pr;
        }else{
           QueryHMPvalues(); 
        }
        return null;
    }
    public PageReference onLoad() { 
        final String FUNC_STR = 'onload: ';
        if(!hasConfigError){            
            if (hasSfdcAccount) {
                if (searchForSFDCBillingAccount(this.sfdcAccountId)) {
                    System.debug(FUNC_STR+'Found Billing Account in SFDC. No need to create Zuora Account');
                } else {
                    System.debug(FUNC_STR+'Failed to find Billing Account in SFDC. Will search Zuora for crmId "'+this.quote.BigMachines__Account__c+'"');
                    
                    if (searchForZuoraAccount(this.sfdcAccountId)) {
                    } else {
                        System.debug(FUNC_STR+'Failed to find Account in Zuora with crmId "'+this.quote.BigMachines__Account__c+'". Need to create Zuora Account');
                        try {
                            Z_PaymentMethodCaptureUtil Zmeths = new Z_PaymentMethodCaptureUtil();
                            this.zuoraAccountId = Zmeths.createZuoraAccount(this.sfdcAccount);
                        } catch (Exception ex) {
                            appendError('Exception occurred creating new Zuora Account: '+ex.getMessage());
                            this.hasConfigError = true;
                        }
                    }
                }
            } else {
                System.debug(FUNC_STR+'Page is missing Quote or SFDC Account. Will not check for existing / create new Zuora Account');
            }
            getselctoptions();   
            queryPaymentProfiles();
            if(creatingQuote){ queryQuotelineitems();} else{ init(); }
        }
        return null;
    }
   
    private Boolean searchForSFDCBillingAccount(String accId) {
        final String FUNC_STR =  'searchForSFDCBillingAccount: ';
        System.debug(FUNC_STR+'Starting searchForSFDCBillingAccount');        
        Boolean foundAccount = false;        
        Zuora__CustomerAccount__c sfdcBillingAccount = Z_PaymentMethodCaptureUtil.searchForSFDCBillingAccount(accId);        
        if (sfdcBillingAccount != null) {
            System.debug(FUNC_STR+'Found Billing Account based on Id: '+accId);
            foundAccount = true;
            this.zuoraAccountId = sfdcBillingAccount.Zuora__Zuora_Id__c;           
        } else {
            System.debug(FUNC_STR+'Failed to find Billing Account based on Id: '+accId);
        }        
        return foundAccount;
    }
    
    public Boolean searchForQuote(String objectId) {
        final String FUNC_STR = 'searchForQuote: ';
        System.debug(FUNC_STR+'Starting searchForQuote with objectId: '+objectId);        
        Boolean foundQuote = false;        
        if (String.isNotBlank(objectId)) {
            System.debug(FUNC_STR+'objectId not blank, searching for CPQ Quotes');            
            List<BigMachines__Quote__c> quotes = [SELECT Id, BigMachines__Account__c,BigMachines_authorization_amount__c, BigMachines_authorization_date__c, BigMachines_authorization_status__c, BigMachines_first_month_payment__c, BigMachines_Quote_Type__c FROM BigMachines__Quote__c WHERE Id = :objectId LIMIT 1];
            if (quotes.size() > 0) {
                System.debug(FUNC_STR+'Retrieved CPQ Quote: '+quotes[0]);
                foundQuote = true;               
                this.quote = quotes[0];
                this.QuoteId = quote.Id;
                           
            } else {
                System.debug(FUNC_STR+'Failed to retrieve CPQ Quotes based on Id: '+objectId);
                foundQuote = false;
            }
        } else {
            System.debug(FUNC_STR+'objectId passed into searchForQuote was blank');
        }        
        if (this.quote != null && this.quote.BigMachines__Account__c != null) {
            System.debug(FUNC_STR+'Searching for SFDC Account based on Account link on Quote: '+quote.BigMachines__Account__c);
            Boolean foundAccount = searchForSfdcAccount(quote.BigMachines__Account__c);
            // System.debug(FUNC_STR+'Found SFDC Account: '+foundAccount);
        }
        this.creatingQuote = foundQuote;        
        return foundQuote;
    }
    public Boolean searchForSfdcAccount(String objectId) {
        final String FUNC_STR = 'searchForSfdcAccount: ';
        System.debug(FUNC_STR+'Starting searchForSfdcAccount with objectId: '+objectId);
        List<Account> accounts = new  List<Account>();
        Boolean foundAccount = false;
        
        if (String.isNotBlank(objectId)) {
            System.debug(FUNC_STR+'objectId not blank, searching for Accounts');
            
            accounts = [SELECT Id,Name,Type,Billing_Preference__c,Subscription_payment__c ,Currency_Type__c,  BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,
                        ShippingStreet,ShippingCity,Bill_To_Parent__c ,ShippingCountry,ShippingPostalCode,ShippingState,
                        Zoura_Account_id__c, Phone, Party_ID__c
                        FROM Account WHERE Id = :objectId LIMIT 1];
            if (accounts.size() > 0) {
                System.debug(FUNC_STR+'Retrieved SFDC Account: '+accounts[0]);
                foundAccount = true;             
                this.sfdcAccount = accounts[0];
                this.sfdcAccountId = sfdcAccount.Id;
                
            } else {
                System.debug(FUNC_STR+'Failed to retrieve SFDC Account based on Id: '+objectId);
                foundAccount = false;
            }
        } else {
            System.debug(FUNC_STR+'objectId passed into searchForSfdcAccount was blank');
        } 
        this.hasSfdcAccount = foundAccount;      
        return foundAccount;
    }
    public Boolean searchForZuoraAccount(String sAccId) {
        final String FUNC_STR = 'searchForZuoraAccount: ';
        System.debug(FUNC_STR+'Starting searchForZuoraAccount');        
        Boolean foundAccount = false;        
        Zuora.ZObject zuoraAccount = Z_PaymentMethodCaptureUtil.searchForZuoraAccount(sAccId, true);        
        if (zuoraAccount != null) {
            System.debug(FUNC_STR+'Found Account in Zuora based on Id: '+sAccId);
            foundAccount = true;
            this.zuoraAccountId = (String)zuoraAccount.getValue('Id');
        } else {
            System.debug(FUNC_STR+'Failed to find Account in Zuora based on Id: '+sAccId);
        }        
        return foundAccount;
    }
    
    public void queryPaymentProfiles(){
        system.debug('queryPaymentProfiles');
        paymentmethods = new Map<String, Paymentprofilewrapper>();
        paymentProfiles = new List<Paymentprofilewrapper>();
        integer i =0;
        for(PaymentProfiles__c inloop: [SELECT Id, Expiration_Date__c ,CreatedDate,Payment_Method_Type__c, Recently_added__C, Account__c, CardholderName__c, CreditCardType__c, 
                                        ExpirationDate__c, MaskNumber__c, PaymentMethodId__c, SplitPercentage__c, Reason_Code__c,Credit_Card_BIN__c 
                                        From PaymentProfiles__c where  Account__c =:sfdcAccountId order by Expiration_Date__c desc]){                                            
                                            Boolean Expired = false;
                                            If(inloop.Expiration_Date__c != null && inloop.Expiration_Date__c < Date.today())
                                                Expired = true;
                                            Paymentprofilewrapper pp = new Paymentprofilewrapper(inloop, false, i, Expired, LenderPage);
                                            paymentmethods.put(inloop.PaymentMethodId__c, pp);
                                            paymentProfiles.add(pp); 
                                            
                                            i++;
                                        }       
    }
    public void queryQuotelineitems(){
        system.debug('queryQuotelineitems');
        Quotelineitems = new List<Quotelineitemswrapper>();
        integer i =0;
        for(BigMachines__Quote_Product__c inloop: [SELECT Id,Zuora_Payment_Method__c ,BigMachines__Product__r.RealSuite_Family__c,Net_Price__c, Authorization_Status__c, Name ,
                                                   Asset__c,Asset__r.Payment_Profile__r.PaymentMethodId__c, BigMachines__Product__r.ProductCode, Asset__r.Payment_Profile__r.ExpirationDate__c ,Asset__r.Payment_Profile__r.MaskNumber__c, 
                                                   BigMachines__Description__c ,Market__c ,Product_Type__c ,Lead_Type__c ,BigMachines__Quantity__c ,BigMachines__Total_Price__c, DocumentNumber__c
                                                   From BigMachines__Quote_Product__c where BigMachines__Quote__c =:QuoteId order by BigMachines__Total_Price__c Desc]){
                                                       Quotelineitems.add(new Quotelineitemswrapper(inloop, false, i, paymentmethods)); 
                                                       i++;
                                                   } 
    }
    
    Public map<Id, Zuora__Subscription__c> QuerySubs(){ 
        map<Id, Zuora__Subscription__c> submap = new map<Id, Zuora__Subscription__c>();
        for(Zuora__Subscription__c inloop: [SELECT Id,Name ,CMRelationship__r.payment_profile__r.PaymentMethodId__c , CMRelationship__c, Status__c,PaymentMethodId__C , Zuora__Account__c  ,Zuora__Status__c ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c Where Zuora__Account__c = :sfdcAccountId]){
            submap.put(inloop.CMRelationship__c, inloop);               
        } 
        return submap;
    } 
    public string getLenderQry(){
        string qry = 'SELECT Start_Date__c, relationship__c, payment_profile__r.PaymentMethodId__c, CFCB_Asset__r.asset_number__c, Agent_Asset_Monthly_Contribution__c, Lender_Asset_Monthly_Contribution__c, agent_account__r.Name,payment_profile__c, payment_profile__r.MaskNumber__c from comarketing_relationship__c ';
        String whrecalues = getwhereClauseforLender();            
        if(whrecalues!=null && !String.isEmpty(whrecalues)){
            qry =  qry + whrecalues;
        }
        return qry;
    }
    public string getqry(){
        String qry = 'SELECT Id,Name ,Status__c,PaymentMethodId__c,Asset__r.Product2.ProductCode,Asset__r.Product2.RealSuite_Family__c, Asset__r.Total_Net__c ,Asset__r.Product_Type__c ,Asset__r.Lead_Type__c , Asset__r.End_Date__c ,Asset__r.Asset_Number__c , Asset__r.ProductCode ,Asset__r.Market_Zip__c,Asset__r.Quantity__c , Asset__r.Payment_Profile__r.PaymentMethodId__c, Asset__r.Payment_Profile__r.ExpirationDate__c ,Asset__r.Payment_Profile__r.MaskNumber__c , Zuora__Account__r.name,Zuora__TermSettingType__c , Zuora__Account__c ,Asset__c ,Zuora__Status__c  ,Zuora_Comment__c ,Zuora__CustomerAccount__c  ,Zuora__TermEndDate__c  ,Zuora__TermStartDate__c  ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c  ' ;
        String whrecalues = getwherecluase();            
        if(whrecalues!=null && !String.isEmpty(whrecalues)){
            qry =  qry + whrecalues;
        }
        return qry;
    }
    public void init() {
        if(!LenderPage){
            String qry = getqry();        
            SubwrapperRecordList = new List<SubscriptionWrapper>();
            system.debug('Subscription Query : ' +qry);
            if(!creatingQuote && (setCon==null || valuechanged) || Test.isrunningtest()){          
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qry));              
                setCon.setPageSize(size); 
                valuechanged =false;
            }        
            for (Zuora__Subscription__c cont : (List<Zuora__Subscription__c>)setCon.getRecords()) { 
                string status ='';
                if(updatedsubs && ErrorSubIdSet.contains(cont.Id)){                
                    status = 'Error';                
                }else if(String.isNotBlank(cont.Asset__r.Payment_Profile__r.PaymentMethodId__c) && !cont.Asset__r.Payment_Profile__r.PaymentMethodId__c.equals(cont.PaymentMethodId__c)){
                    status = 'pending';  
                }
                SubwrapperRecordList.add(new SubscriptionWrapper(cont, Selectall,status ));    
            }
        }else{           
            String qry = getLenderQry();                 
            CoMarketingRelWrapperList = new List<CoMarketingRelWrapper>();
            system.debug('Subscription Query : ' +qry);
            if((setCon==null || valuechanged) || Test.isrunningtest()){          
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qry));              
                setCon.setPageSize(size); 
                valuechanged =false;
            }        
            for (comarketing_relationship__c cont : (List<comarketing_relationship__c>)setCon.getRecords()) { 
                CoMarketingRelWrapperList.add(new CoMarketingRelWrapper(cont, Selectall,'pending' ,Authorizedids));    
            }           
        }
    } 
    public PageReference UpdateRelationships(){       
        final String FUNC_STR = 'UpdateQuotelineitems: ';
        boolean activateRelationship = true;
        if(paymentProfiles.size()>rowIndex2){
            PaymentProfiles__c payprofiletoupdate = paymentProfiles[rowIndex2].Paymentprofile;
            String payId =  payprofiletoupdate.PaymentMethodId__c; 
            paymentProfiles[rowIndex2].BINerror  = false;
            if(!validatePaymentProfile(paymentProfiles[rowIndex2])){                
                return null;
            }
            if(!BINValidation(paymentProfiles[rowIndex2])){
                system.debug('BIN@@' + paymentProfiles[rowIndex2].userBIN);
                paymentProfiles[rowIndex2].BINerror = true;                   
                return null;
            }
            paymentProfiles[rowIndex2].userBIN= '';
            Set<Id> CoMarketingIds = new Set<Id>();          
            if(performAuthCallout(payId, paymentProfiles[rowIndex2].Paymentprofile)){
                Id idd = paymentProfiles[rowIndex2].Paymentprofile.Id;
                String Zid = paymentProfiles[rowIndex2].Paymentprofile.PaymentMethodId__c;
                List<comarketing_relationship__c> relationsToUpdate = new List<comarketing_relationship__c>();
                ErrorSubIdSet = new Set<Id>();           
                List<Zuora.ZObject> ZsubObjects = new  List<Zuora.ZObject>();
                map<String, Id> Zidsubmap = new map<String, Id>();           
                Set<String> OldPayIds = new Set<String>();
                List<Account_Relationship__c> arList = new List<Account_Relationship__c>();
                map<id,account_relationship__c> arMap = new map<id,account_relationship__c>();
                Set<ID> relationIDs = new Set<Id>();
                map<Id, Zuora__Subscription__c> submap = QuerySubs();
                for(CoMarketingRelWrapper inloop: CoMarketingRelWrapperList){                    
                    if(inloop.isSelected || test.isrunningtest()){
                        Authorizedids.add( inloop.CoMarketingRel.Id);
                        CoMarketingIds.add(idd);
                        comarketing_relationship__c cr = inloop.CoMarketingRel;
                        cr.payment_profile__c = idd;
                        //cr.status__c = 'Active';                       
                        cr.Start_Date__c = cr.Start_Date__c == null ? System.today() : cr.Start_Date__c;
                        if(cr.Lender_Asset_Monthly_Contribution__c != null && cr.Lender_Asset_Monthly_Contribution__c >0){
                            cr.Agent_Zuora_Status__c = 'Pending Update';
                            cr.Lender_Zuora_Status__c = 'Pending Update';
                            activateRelationship = false;
                        }else{
                            cr.Agent_Zuora_Status__c = 'Success';
                            cr.Agent_Zuora_Comment__c = 'No subscription created since zero dollars value';
                            cr.Lender_Zuora_Status__c = 'Success';
                            cr.Lender_Zuora_Comment__c = 'No subscription created since zero dollars value';
                            cr.status__c = 'Active';
                        }
                        if(SendtoZuora == 'false'){
                            cr.Agent_Zuora_Status__c = 'Success';
                            cr.Lender_Zuora_Status__c = 'Success';
                            cr.status__c = 'Active';
                            activateRelationship = true;
                        }
                        relationsToUpdate.add(cr);  
                        if(armap.containskey(cr.relationship__c)){
                            Account_Relationship__c  ar = armap.get(cr.relationship__c);
                            ar.id = cr.relationship__c;
                            if(activateRelationship){
                               ar.comarketing_status__c = 'Active';
                               ar.Comarketing_Zuora_InProgress__c  = false;   
                            }else{ 
                                ar.Comarketing_Zuora_InProgress__c  = true;  
                                ar.comarketing_status__c = 'Pending Activation';
                            }                       //LCM-174       
                            ar.Comarketing_start_date__c  = ar.Comarketing_start_date__c  == null ? System.today() : ar.Comarketing_start_date__c;//LCM-285
                            armap.put(ar.id,ar); 
                            //relationIDs.add(cr.relationship__c);
                        } else{
                            Account_Relationship__c  ar = new Account_Relationship__c();
                            ar.id = cr.relationship__c;
                            if(activateRelationship){
                               ar.comarketing_status__c = 'Active'; 
                                ar.Comarketing_Zuora_InProgress__c  = false;  
                            }else{ 
                                ar.Comarketing_Zuora_InProgress__c  = true;
                                ar.comarketing_status__c = 'Pending Activation';  
                            }                       //LCM-174       
                            ar.Comarketing_start_date__c  = ar.Comarketing_start_date__c  == null ? System.today() : ar.Comarketing_start_date__c;//LCM-285
                            armap.put(ar.id,ar); 
                        }
                        
                        
                        if(submap.containskey(cr.Id) && (submap.get(cr.Id).PaymentMethodId__C == null || submap.get(cr.Id).PaymentMethodId__C != Zid)){
                            Zuora.ZObject updatesubscription = new Zuora.ZObject('Subscription');
                            updatesubscription.setValue('Id', submap.get(cr.Id).Zuora__Zuora_Id__c);
                            updatesubscription.setValue('PaymentMethodId__c', Zid);
                            updatesubscription.setValue('AutoPay__c', 'On'); 
                            ZsubObjects.add(updatesubscription);             
                            if(submap.get(cr.Id).PaymentMethodId__C != null)
                                OldPayIds.add(submap.get(cr.Id).PaymentMethodId__C);                          
                        }
                    }                   
                }   
                if(relationsToUpdate.isEmpty()){                    
                    appendError('Please select the Relationships'); 
                    return null;
                }else{
                    if(ZsubObjects.Size()>0)
                        SendSublistToZuora(ZsubObjects, OldPayIds);
                    system.debug('SendtoZuora@2' + SendtoZuora);
                    if(!Test.isRunningTest()){
                      //  if(SendtoZuora == 'true'){
                        update relationsToUpdate; 
                        update armap.values();
                       
                     //   }
                        update payprofiletoupdate;
                    }
                }
                appendInfo( 'Payment Profile Successfully Authorized and Updated' );              
            }
        }else{
            appendError('Please select the Payment profile'); 
        }        
        valuechanged =true;
        init();
         
        return null;
    }
    
    public pagereference AuthorizeExistingLenderProfiles(){
        QuerySubs();
        Set<String> FailPayId = new Set<String>(); 
        Boolean isselected = false;
        Boolean validated = true;
        boolean activateRelationship = true;
        map<id,account_relationship__c> arMap = new map<id,account_relationship__c>();

        for(CoMarketingRelWrapper inloop: CoMarketingRelWrapperList){
            if(inloop.isSelected){
                if(inloop.CoMarketingRel.payment_profile__r.PaymentMethodId__C != null){
                    for(Paymentprofilewrapper innerlloop : paymentProfiles){
                        if(innerlloop.Paymentprofile.PaymentMethodId__c == inloop.CoMarketingRel.payment_profile__r.PaymentMethodId__C){                    
                            if(!validatePaymentProfile(innerlloop)){
                                validated = false;
                            }
                            if (!BINValidation(innerlloop)) {                                               
                                innerlloop.BINerror = true;
                                validated = false;                                                  
                            }                        
                        }
                    }                    
                }else{
                    appendError('There is no Payment Profile Associated with CoMarketing Record: '+ inloop.CoMarketingRel.CFCB_Asset__r.asset_number__c);  
                }
            }
        }
        List<comarketing_relationship__c> updateCm = new List<comarketing_relationship__c>();
        if(validated){
            for(CoMarketingRelWrapper inloop: CoMarketingRelWrapperList){
                if(inloop.isSelected && inloop.CoMarketingRel.payment_profile__r != null && paymentmethods.containskey(inloop.CoMarketingRel.payment_profile__r.PaymentMethodId__C)){
                    isselected = true;
                    String Payid = inloop.CoMarketingRel.payment_profile__r.PaymentMethodId__C;
                    if(Authorizedpayids.contains(Payid) || (!FailPayId.contains(Payid) && performAuthCallout(Payid, paymentmethods.get(Payid).Paymentprofile))){                                       
                        inloop.AuthStatus = 'Authorized'; 
                        
                        comarketing_relationship__c cr = inloop.CoMarketingRel;
                        if(cr.Lender_Asset_Monthly_Contribution__c != null && cr.Lender_Asset_Monthly_Contribution__c >0){
                            cr.Agent_Zuora_Status__c = 'Pending Update';
                            cr.Lender_Zuora_Status__c = 'Pending Update';
                            activateRelationship = false;
                        }else{
                            cr.Agent_Zuora_Status__c = 'Success';
                            cr.Agent_Zuora_Comment__c = 'No subscription created since zero dollars value';
                            cr.Lender_Zuora_Status__c = 'Success';
                            cr.Lender_Zuora_Comment__c = 'No subscription created since zero dollars value';
                            cr.status__c = 'Active';
                        }
                        if(SendtoZuora == 'false'){
                            cr.Agent_Zuora_Status__c = 'Success';
                            cr.Lender_Zuora_Status__c = 'Success';
                            cr.status__c = 'Active';
                            activateRelationship = true;
                        }
                        updateCm.Add(cr);                       
                        if(armap.containskey(cr.relationship__c)){
                            Account_Relationship__c  ar = armap.get(cr.relationship__c);
                            ar.id = cr.relationship__c;
                            if(activateRelationship){
                               ar.comarketing_status__c = 'Active';
                               ar.Comarketing_Zuora_InProgress__c  = false;   
                            }else{ 
                                ar.Comarketing_Zuora_InProgress__c  = true;  
                                ar.comarketing_status__c = 'Pending Activation'; 
                            }                       //LCM-174       
                            
                               
                            armap.put(ar.id,ar); 
                            //relationIDs.add(cr.relationship__c);
                        } else{
                            Account_Relationship__c  ar = new Account_Relationship__c();
                            ar.id = cr.relationship__c;
                            if(activateRelationship){
                               ar.comarketing_status__c = 'Active'; 
                               ar.Comarketing_Zuora_InProgress__c  = true;  
                            }else{ 
                                ar.Comarketing_Zuora_InProgress__c  = false;  
                                ar.comarketing_status__c = 'Pending Activation'; 
                            }                       //LCM-174                    
                            armap.put(ar.id,ar); 
                        }
                        
                    } else{
                        inloop.AuthStatus = 'Not Authorized'; 
                        FailPayId.add(Payid);
                    }
                }              
            }
            if(!isselected){
                appendInfo('Please Select Assets to Authorize associated Profiles');   
            } else if(!(FailPayId.size()>0)){
                appendInfo('Authorization Success'); 
            }else{
                appendInfo('Authorization Failed'); 
            }
            try{
               // if(SendtoZuora == 'true'){   
                    update updateCm;
                    update armap.values();
               // }
            }catch(exception ex){}
        }
        return null; 
    }
    
    public void SendSublistToZuora(List<Zuora.ZObject> ZsubObjects, set<String> OldPayIds){
        List<Zuora.ZApi.SaveResult> results = new List<Zuora.ZApi.SaveResult>(); 
        List<Zuora.zObject> sentozuoralist = new List<Zuora.zObject>();
        Zuora.zApi zApi = zuoraApiAccess();                              
        Integer qCount = ZsubObjects.size();
        for(Integer a = 0; a<qCount; a++){
            sentozuoralist.add(ZsubObjects[0]);
            ZsubObjects.remove(0); 
            if(ZsubObjects.size() == 0 || sentozuoralist.size() == 50){                     
                results.addall(SendToZuora(sentozuoralist)); 
                sentozuoralist = new List<Zuora.zObject>();  
                system.debug( 'results '+ results);
            }
        }
        String ErrorMessage = '';
        Boolean errorstatus = false;                                                
        integer failure = 0;
        integer Success = 0;
        for (Zuora.zApi.SaveResult result : results){
            if(!result.Success){                            
                Zuora.zObject[] errors = result.errors;
                System.debug( 'Results arrey Errors :' + errors);                   
                String errorText = '';                   
                for (Zuora.zObject error : errors) {
                    if(!test.isrunningtest())
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';                                                
                }
                errorstatus=true;
                ErrorMessage += errorText + '$';
                System.debug('Results :' + ErrorMessage); 
                failure++;
            }else if(result.Success){
                Success++;
                
                System.debug('Results arrey Success :' + result.Id);    
            }
        }                                      
        if(errorstatus == true){
            appendError('Number of Subscriptions Successfully Updated: ' + Success +  '     Number of Subscriptions Failed to update: '+failure); 
            appendError(ErrorMessage);
        }
        
        Integer Result =  [SELECT count() From  Zuora__PaymentInvoice__c where Zuora__Invoice__r.Zuora__Account__c  =:sfdcAccountId and Zuora__Invoice__r.Zuora__Balance2__c > 1 and Status__c = 'Processed' and Zuora__Payment__r.ZPaymentMethodId__c IN:OldPayIds];
        if(Result > 1){
            system.debug(' Updating Invoices to stop retry '+ Result);
            Z_UpdateInvoicetostopretry.UpdateInoivceflagfrompage(sfdcAccountId, OldPayIds); 
        }       
    }  
    // added  comarketing status filter LCM-265.
    public String getwhereClauseforLender() {        
        system.debug('Fieldvalue@ ' +sfdcAccountId);         
        String Filter = '';        
        if((sfdcAccountId !=null &&!String.isEmpty(sfdcAccountId))){          
            Filter += 'Where ';
            if(sfdcAccountId != null && !String.isEmpty(sfdcAccountId)){
                Filter += 'Lender_Account__c = \'' +  sfdcAccountId.trim() + '\'';
                String status = 'Active';
                String comarketingstatus = 'Cancelled';
                Filter += ' and CFCB_Asset__r.status = \''+status+ '\' and Status__c != \''+comarketingstatus+ '\'';
            }
            if( Fieldvalue !=null && !String.isEmpty( Fieldvalue)){
                Filter += ' and agent_account__r.Name';
                Filter += ' Like \'%'+ Fieldvalue +'%\'';  
                FieldvalueMask = null;
                AssetNumber = null;
            }
            if(AssetNumber !=null && !String.isEmpty(AssetNumber)){
                Filter += ' and CFCB_Asset__r.asset_number__c';
                Filter += ' Like \'%'+ AssetNumber +'%\'';  
                FieldvalueMask = null;
            }
            
            if(FieldvalueMask !=null && !String.isEmpty(FieldvalueMask)){
                Filter += ' and payment_profile__r.MaskNumber__c';
                Filter += ' Like \'%'+ FieldvalueMask +'%\'';   
            }
            
        }
        System.debug('orderByColumn '+orderByColumn);
        if(orderByColumn!=null && !String.isEmpty(orderByColumn)){
            if(Ascdesc == 'ASC') {              
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;
                Ascdesc = 'DESC';                   
            }else{
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;
                Ascdesc = 'ASC';
            }
            orderByColumn=null;
        }else{
          Filter += ' Order By Payment_Profile__r.MaskNumber__c ASC';
        }  
        Filter += ' LIMIT 9900';
        return Filter;
    }
    
    public String getwherecluase() {        
        system.debug('Fieldvalue@ ' +sfdcAccountId);
        String Filter = '';        
        if((sfdcAccountId !=null &&!String.isEmpty(sfdcAccountId)) || (statusvalue!=null && statusvalue!= 'All')){          
            Filter += 'Where ';
            if(sfdcAccountId != null && !String.isEmpty(sfdcAccountId)){
                Filter += 'Zuora__Account__c = \'' +  sfdcAccountId.trim() + '\'';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' and Zuora__Status__c = \'' + statusvalue + '\'';    
                }
            }
            if(Fieldvalue !=null && !String.isEmpty(Fieldvalue)){
                Filter += ' and Asset__r.Name';
                Filter += ' Like \'%'+ Fieldvalue +'%\'';  
                FieldvalueMask = null;
            }
            if(FieldvalueMask !=null && !String.isEmpty(FieldvalueMask)){
                Filter += ' and Asset__r.Payment_Profile__r.MaskNumber__c ';
                Filter += ' Like \'%'+ FieldvalueMask +'%\'';   
            }
            
        }
        if(orderByColumn!=null && !String.isEmpty(orderByColumn)){
            if(Ascdesc == 'ASC') {              
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;                                  
                Ascdesc = 'DESC';                   
            }else{
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;
                Ascdesc = 'ASC';
            }
            orderByColumn=null;
        }  
        Filter += ' LIMIT 9900';
        return Filter;
    }
    
    public PageReference UpdateQuotelineitems(){
        final String FUNC_STR = 'UpdateQuotelineitems: ';
        System.debug(FUNC_STR+'Starting UpdateQuotelineitems: '); 
        if(paymentProfiles.size()>rowIndex2){
            String payId =  paymentProfiles[rowIndex2].Paymentprofile.PaymentMethodId__c;   
            PaymentProfiles__c payprofiletoupdate = paymentProfiles[rowIndex2].Paymentprofile;
            paymentProfiles[rowIndex2].BINerror  = false;
            if(!validatePaymentProfile(paymentProfiles[rowIndex2])){                
                return null;
            }
            if(!BINValidation(paymentProfiles[rowIndex2])){
                system.debug('BIN@@' + paymentProfiles[rowIndex2].userBIN);
                paymentProfiles[rowIndex2].BINerror = true;                   
                return null;
            }
            paymentProfiles[rowIndex2].userBIN= '';
            if(performAuthCallout(payId, paymentProfiles[rowIndex2].Paymentprofile)){
                List<Asset> updateassetlist = new List<Asset>();
                List<BigMachines__Quote_Product__c> updateQuotelineitems = new List<BigMachines__Quote_Product__c>(); 
                
                for(Quotelineitemswrapper inloop: Quotelineitems){                            
                    if(inloop.isSelected){                 
                        BigMachines__Quote_Product__c nn = new BigMachines__Quote_Product__c(Id = inloop.Quotelineitem.Id, Zuora_Payment_Method__c = payId, Authorization_Status__c  = 'Authorized');
                        updateQuotelineitems.add(nn);
                    }                               
                }
                if(updateQuotelineitems.size()>0){                 
                    update updateQuotelineitems;
                    update payprofiletoupdate;
                    queryQuotelineitems();
                    appendInfo('Payment profile Authorized and Quote Line items successfully updated with Payment methods');
                }else {
                    appendError('Please select the Quote Line items');        
                }
            }
        }else{
            appendError('Please select the payment profile'); 
        }
        return null;      
    }
    public PageReference Updatesubscriptions(){
        final String FUNC_STR = 'UpdateQuotelineitems: ';
        System.debug('Starting Updatesubscriptions: '); 
        if(paymentProfiles.size()>rowIndex2){
            paymentProfiles[rowIndex2].isSelected  = true;
            String payId =  paymentProfiles[rowIndex2].Paymentprofile.PaymentMethodId__c; 
            PaymentProfiles__c payprofiletoupdate = paymentProfiles[rowIndex2].Paymentprofile;
            if(!validatePaymentProfile(paymentProfiles[rowIndex2])){                
                return null;
            }
            
            if(performAuthCallout(payId, paymentProfiles[rowIndex2].Paymentprofile)){
                Id idd = paymentProfiles[rowIndex2].Paymentprofile.Id;
                List<Zuora.ZApi.SaveResult> updatesubResults = new List<Zuora.ZApi.SaveResult>(); 
                List<Zuora.ZObject> ZsubObjects = new  List<Zuora.ZObject>();
                ErrorSubIdSet = new Set<Id>();           
                map<String, Id> Zidsubmap = new map<String, Id>();           
                List<Asset> assetlist = new List<Asset>();
                String status = statusvalue!=null && statusvalue != 'ALL' ? statusvalue : 'NONE';
                Set<String> OldPayIds = new Set<String>();
                for(SubscriptionWrapper inloop: SubwrapperRecordList){                    
                    if(inloop.isSelected&&(status =='NONE' || inloop.Subscription.Zuora__Status__c == status)){                  
                        Zuora.ZObject updatesubscription = new Zuora.ZObject('Subscription');
                        updatesubscription.setValue('Id', inloop.Subscription.Zuora__Zuora_Id__c);
                        updatesubscription.setValue('PaymentMethodId__c', payId);
                        updatesubscription.setValue('AutoPay__c', 'On'); 
                        ZsubObjects.add(updatesubscription);                        
                        ZIdsubmap.put(inloop.Subscription.Zuora__Zuora_Id__c, inloop.Subscription.Id);
                        inloop.Subscription.PaymentMethodId__c = payId;                       
                        Asset nn = new Asset(Id = inloop.Subscription.Asset__c,Payment_Profile__c = idd);                                        
                        assetlist.add(nn);
                        if(inloop.Subscription.PaymentMethodId__c != null)
                            OldPayIds.add(inloop.Subscription.PaymentMethodId__c);
                    }                               
                }   
                system.debug(FUNC_STR + 'ZsubObjects '+ ZsubObjects.size());
                if(ZsubObjects.size()>0){
                    List<Zuora.ZApi.SaveResult> results = new List<Zuora.ZApi.SaveResult>(); 
                    List<Zuora.zObject> sentozuoralist = new List<Zuora.zObject>();
                    Zuora.zApi zApi = zuoraApiAccess();                              
                    Integer qCount = ZsubObjects.size();
                    for(Integer a = 0; a<qCount; a++){
                        sentozuoralist.add(ZsubObjects[0]);
                        ZsubObjects.remove(0); 
                        if(ZsubObjects.size() == 0 || sentozuoralist.size() == 50){                     
                            results.addall(SendToZuora(sentozuoralist)); 
                            sentozuoralist = new List<Zuora.zObject>();  
                            system.debug(FUNC_STR + 'results '+ results);
                        }
                    }
                    String ErrorMessage = '';
                    Boolean errorstatus = false;                                                
                    integer failure = 0;
                    integer Success = 0;
                    for (Zuora.zApi.SaveResult result : results){
                        if(!result.Success){                            
                            Zuora.zObject[] errors = result.errors;
                            System.debug(FUNC_STR + 'Results arrey Errors :' + errors);                   
                            String errorText = '';                   
                            for (Zuora.zObject error : errors) {
                                if(!test.isrunningtest())
                                    errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';                                                
                            }
                            errorstatus=true;
                            ErrorMessage += errorText + '$';
                            System.debug(FUNC_STR +'Results :' + ErrorMessage); 
                            failure++;
                        }else if(result.Success){
                            Success++;
                            if(ZIdsubmap.containskey(result.Id))
                                ZIdsubmap.remove(result.Id);                                                              
                            System.debug('Results arrey Success :' + result.Id);    
                        }
                    }                  
                    
                    if(ZIdsubmap != null && !ZIdsubmap.isEmpty()){
                        ErrorSubIdSet.addall(ZIdsubmap.values()); 
                        updatedsubs = true;
                    }                
                    if(errorstatus == true){
                        appendError('Number of Subscriptions Successfully Updated: ' + Success +  '     Number of Subscriptions Failed to update: '+failure); 
                        appendError(ErrorMessage);
                    } else{
                        appendInfo('Subscriptions are Successfully updated with Selected Payment Method');
                    }               
                    update assetlist;
                    Integer Result =  [SELECT count() From  Zuora__PaymentInvoice__c where Zuora__Invoice__r.Zuora__Account__c  =:sfdcAccountId and Zuora__Invoice__r.Zuora__Balance2__c > 1 and Status__c = 'Processed' and Zuora__Payment__r.ZPaymentMethodId__c IN:OldPayIds];
                    if(Result > 1){
                        system.debug(FUNC_STR +' Updating Invoices to stop retry '+ Result);
                        Z_UpdateInvoicetostopretry.UpdateInoivceflagfrompage(sfdcAccountId, OldPayIds); 
                    }
                }else{
                    appendError('Please select the Assets'); 
                }
            }
        }else{
            appendError('Please select the payment profile'); 
        }        
        valuechanged =true;
        init();
        return null;
    }
    
    public PageReference AuthorizeQuotelineitems(){
        Set<String> FailPayId = new Set<String>();  
        Boolean validated = true;
        Map<String , Set<Integer>>  payBMQ = new Map<String, Set<Integer>>();
        List<BigMachines__Quote_Product__c> updateQuotelineitems = new List<BigMachines__Quote_Product__c>();
        for(Quotelineitemswrapper inloop: Quotelineitems){
            if(inloop.isSelected){
                if(inloop.Quotelineitem.Zuora_Payment_Method__c != null){
                    for(Paymentprofilewrapper innerlloop : paymentProfiles){
                        if(inloop.Quotelineitem.Zuora_Payment_Method__c != null && innerlloop.Paymentprofile.PaymentMethodId__c == inloop.Quotelineitem.Zuora_Payment_Method__c){                    
                            if(!validatePaymentProfile(innerlloop)){
                                validated = false;
                            }
                            if (!BINValidation(innerlloop)) {                                               
                                innerlloop.BINerror = true;
                                validated = false;                                                  
                            }                        
                        }
                    }                    
                }else{
                    appendError('There is no Payment Profile Associated with Quote: ' + inloop.Quotelineitem.Name + ' Market '+inloop.Quotelineitem.Market__c);  
                }
            }
        }
        
        if(validated){
            for(Quotelineitemswrapper inloop: Quotelineitems){       
                if(inloop.Quotelineitem.Zuora_Payment_Method__c != null && paymentmethods.containskey(inloop.Quotelineitem.Zuora_Payment_Method__c) && (inloop.isSelected)){                        
                    String Payid = inloop.Quotelineitem.Zuora_Payment_Method__c;
                    if(Authorizedpayids.contains(Payid) || (!FailPayId.contains(Payid) && performAuthCallout(Payid, paymentmethods.get(Payid).Paymentprofile))){                   
                        BigMachines__Quote_Product__c nn = new BigMachines__Quote_Product__c(Id = inloop.Quotelineitem.Id, Zuora_Payment_Method__c = Payid, Authorization_Status__c  = 'Authorized');
                        updateQuotelineitems.add(nn);
                        Set<Integer> temppay = new Set<Integer>();
                        if(payBMQ.containskey(Payid)){
                            temppay = payBMQ.get(Payid);
                        }else{
                            temppay = new Set<Integer>();
                        }
                        temppay.add(Integer.valueOf(inloop.Quotelineitem.DocumentNumber__c));   
                        
                    }else{
                        FailPayId.add(Payid);
                        BigMachines__Quote_Product__c nn = new BigMachines__Quote_Product__c(Id = inloop.Quotelineitem.Id, Authorization_Status__c  = 'Error');
                        updateQuotelineitems.add(nn);
                    }
                }                               
            }
            
            if(updateQuotelineitems.size()>0){  
                update updateQuotelineitems;                   
                if(!(FailPayId.size()>0))
                    appendInfo('Authorization Success and Quote Line items successfully updated with Payment methods');                    
                queryQuotelineitems();
            }else {
                appendError('Please select the Quote Line items');        
            }
        }
        return null;      
    }
    public Boolean BINValidation(Paymentprofilewrapper payProfile){
        PaymentProfiles__c payprofiletoupdate = payProfile.Paymentprofile;
        if (!payProfile.isNew) {                    
            String normalizedCardBin = (payprofiletoupdate.Credit_Card_BIN__c != null && payprofiletoupdate.Credit_Card_BIN__c.length() > 4) ? payprofiletoupdate.Credit_Card_BIN__c.substring(0,4) : payprofiletoupdate.Credit_Card_BIN__c; 
            system.debug('BIN@@' + normalizedCardBin +'  '+payProfile.userBIN);
            if (payProfile.userBIN == null || payProfile.userBIN != normalizedCardBin) { 
                appendError('Card BIN incorrect for '+payprofiletoupdate.CardholderName__c+' '+payprofiletoupdate.MaskNumber__c);
                return false;  
            }
        }
        return true;
    }
    Public Boolean validatePaymentProfile(Paymentprofilewrapper payProfile){        
        PaymentProfiles__c payprofiletoupdate = payProfile.Paymentprofile;
        string[] expArray = payprofiletoupdate.ExpirationDate__c.split('/');
        Integer expMonth = integer.valueOf(expArray[0]);
        Integer expYear = integer.valueOf(expArray[1]);
        if ((expYear == integer.valueOf(system.today().year()) && expMonth <=Integer.valueOf(system.today().month())) || (expYear < integer.valueOf(system.today().year()))) 
        {
            appendError('Authorization Failure: The expiration date on this '+payprofiletoupdate.CardholderName__c+' '+payprofiletoupdate.MaskNumber__c +' '+'credit card has passed or the card is expiring this month. Please use a valid credit card.');                                              
            return false;
        }
        
        if(payprofiletoupdate.Recently_Added__c){
            if(payprofiletoupdate.Reason_Code__c !=null && payprofiletoupdate.Reason_Code__c !='') {
                payprofiletoupdate.Recently_Added__c=false; 
            }                              
            else{
                appendError('Please select the Reason Code'); 
                return false;  
            }                 
        }        
        return true;
    }
    
    public Boolean performAuthCallout(String paymentMethodId, PaymentProfiles__c paymentProf) {
        final String FUNC_STR =  'performAuthCallout: ';
        String CC_PM_TYPE = 'CreditCard';
        String authToken = '';
        Decimal authAmount = 1;
        if (String.isNotBlank(paymentMethodId) && paymentProf != null) {
            Http http = new Http();
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpResp = new HttpResponse();
            String httpMethod = 'POST';
            String urlMethod = 'auth';
            Zuora.ZApi zApi = new Zuora.ZApi();
            if(!Test.isRunningTest()){
                Zuora.ZApi.LoginResult loginResult = zApi.zLogin();
                String cookieVal = 'ZSession='+EncodingUtil.urlEncode(loginResult.Session,'UTF-8');
                httpReq.setHeader('Cookie', cookieVal);
            }
            //String baseUrl = (!isProduction) ? 'https://apisandbox.zuora.com/apps/zgw.do?' : 'https://www.zuora.com/apps/zgw.do?';
            String baseUrl = '';
            if(System.Label.Zuora_Auth_Url != null)
                baseUrl = System.Label.Zuora_Auth_Url;
            String fullEndpoint = baseUrl+'method='+urlMethod+'&AccountId='+zuoraAccountId+'&Amount='+authAmount+'&PaymentMethodId='+paymentMethodId;
            httpReq.setEndpoint(fullEndpoint);
            httpReq.setMethod(httpMethod);
            httpReq.setHeader('Content-Type', 'application/json');
            
            Boolean authCallSuccess = false;
            
            System.debug(FUNC_STR+'HTTP Request: '+httpReq);
            System.debug(FUNC_STR+'Cookie Header: '+httpReq.getHeader('Cookie'));
            try {
                httpResp = (!Test.isRunningTest()) ?  http.send(httpReq) :  Z_PaymentProfileManagerControllerTest.getResponse();
                
            } catch (Exception ex) {
                String pmInfo = 'CreditCard' + ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c;
                appendError('Exception occurred trying to authorize card '+pmInfo+': '+ex.getMessage());
                //updateQuoteWithAuthFailure();
                return false;
            }
            System.debug(FUNC_STR+'HTTP Response: '+httpResp);
            System.debug(FUNC_STR+'HTTP Response Body: '+httpResp.getBody());
            if (httpResp != null && httpResp.getStatusCode() == 200) {
                if (String.isNotBlank(httpResp.getBody())) {
                    List<String> stringParts = httpResp.getBody().split('&');
                    
                    String resultCode = '';
                    String resultMessage = '';
                    
                    for (String stringPart : stringParts) {
                        System.debug(FUNC_STR+'Working with string part: '+stringPart);
                        
                        if (stringPart.startsWithIgnoreCase('ResultCode')) {
                            Integer codeLocation = stringPart.indexOf('=');
                            if (codeLocation >= 0 && stringPart.length() > codeLocation + 1) {
                                resultCode = stringPart.substring(codeLocation + 1);
                                System.debug(FUNC_STR+'Found result code: '+resultCode);
                            }
                            
                        }
                        
                        if (stringPart.startsWithIgnoreCase('ResultMsg')) {
                            Integer codeLocation = stringPart.indexOf('=');
                            if (codeLocation >= 0 && stringPart.length() > codeLocation + 1) {
                                resultMessage = stringPart.substring(codeLocation + 1);
                                System.debug(FUNC_STR+'Found result message: '+resultMessage);
                            }
                        }
                        
                        
                        if (stringPart.startsWithIgnoreCase('TransactionId')) {
                            Integer authLocation = stringPart.indexOf('=');
                            if (authLocation >= 0 && stringPart.length() > authLocation + 1) {
                                authToken = stringPart.substring(authLocation + 1);
                                System.debug(FUNC_STR+'Found auth token: '+authToken);
                            } 
                        }
                        
                    }
                    
                    if (resultCode == '0') {
                        if (authToken != '') {
                            Authorizedpayids.add(paymentMethodId);
                            authCallSuccess = true;
                            System.debug(FUNC_STR+'Found auth token: '+authToken);                            
                        } else {
                            String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;                     
                            appendError('Error parsing authorization call response body for card '+pmInfo);
                            //updateQuoteWithAuthFailure();
                            return false;
                        }
                    } else {
                        String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                        appendError('Authorization call failed with response code "'+resultCode+'" and message "'+resultMessage+'" for card '+pmInfo);
                        //updateQuoteWithAuthFailure();
                        return false;
                    }
                    
                } else {
                    String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                    appendError('Error retrieving authorization call response body for card '+pmInfo);
                    //updateQuoteWithAuthFailure();
                    return false;
                }
            } else {
                String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                appendError('Auth Call Failure for card '+pmInfo+': '+httpResp);
                //updateQuoteWithAuthFailure();
                return false;
            }
            
            return authCallSuccess;
        } else {
            String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
            appendError('Invalid parameters passed to authorization call for card '+pmInfo);
            return false;
        } 
        
    }
    public  List<Zuora.ZApi.SaveResult> SendToZuora(List<Zuora.ZObject> sendlist){        
        List<Zuora.ZApi.SaveResult> results = new List<Zuora.ZApi.SaveResult>(); 
        try{
            system.debug('Request : ' +sendlist);
            if(!Test.isRunningTest()){
                results.addall(zApi.zUpdate(sendlist));                   
                system.debug('Response : ' +results);
            } else {                    
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                    results = new List<Zuora.zApi.SaveResult>{};
                        results.add(res);
            }                
            
        } catch(Exception e){
            String ErrorMessage ='Exception Occured While making payments Exception Message: '+e.getMessage()+' Stacktrace: '+e.getStackTraceString();             
            Boolean ErrorStatus = true;             
            // updateSystemLogs(ErrorStatus,ErrorMessage);
            return results;
        }
        return results;              
        
    }
    
    
    
    public Zuora.ZApi zuoraApiAccess(){
        system.debug('Login');      
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
    
    public void callbackSuccess() {
        system.debug('Processcallback');
        this.renderHPM = false;
    }
     public PageReference Search() {
        system.debug('at Search');           
        valuechanged = true;
        if(orderByColumn==null)
            statusvalue = 'ALL';
        init();              
        return null;
    } 
    
    public class Quotelineitemswrapper {
        public String MaskNumber {get; set;}
        public Boolean isSelected {get;set;}
        public String Expiration {get; set;}
        public Boolean Disable {get; set;}
        public BigMachines__Quote_Product__c Quotelineitem {get;set;}
        public integer index {get;set;}
        public Quotelineitemswrapper(BigMachines__Quote_Product__c Quote, Boolean isSelected, integer i, Map<String, Paymentprofilewrapper> paymentprof) {
            if(Quote.Net_Price__c == 0 &&( Quote.BigMachines__Product__r.RealSuite_Family__c ||  Quote.BigMachines__Product__r.ProductCode == 'RSTRANSACT')){
                this.Disable =true;               
            }          
            if(Quote.Zuora_Payment_Method__c != null && paymentprof.containskey(Quote.Zuora_Payment_Method__c)){
                this.MaskNumber = paymentprof.get(Quote.Zuora_Payment_Method__c).Paymentprofile.MaskNumber__c;
                this.Expiration= paymentprof.get(Quote.Zuora_Payment_Method__c).Paymentprofile.ExpirationDate__c;
            }else if(Quote.Asset__c !=null){
                this.MaskNumber = Quote.Asset__r.Payment_Profile__r.MaskNumber__c;
                this.Expiration= Quote.Asset__r.Payment_Profile__r.ExpirationDate__c;                  
            }
            this.Quotelineitem = Quote;
            this.isSelected = isSelected;
            this.index = i;
        }
    } 
    public class SubscriptionWrapper {
        public Boolean isSelected {get;set;}
        public Zuora__Subscription__c Subscription {get;set;}
        public string status{get; set;}
        public Boolean Disable {get; set;}       
        public SubscriptionWrapper(Zuora__Subscription__c Sub, Boolean isSelected, String status) {
            this.Subscription = Sub;
            this.isSelected = isSelected;
            this.status = status;
            if(Sub.Asset__r.Total_Net__c == 0 && (Sub.Asset__r.Product2.ProductCode  == 'RSTRANSACT'|| Sub.Asset__r.Product2.RealSuite_Family__c)){
                Disable = true;
            }
        }
    }
    public class CoMarketingRelWrapper {
        public Boolean isSelected {get;set;}
        public comarketing_relationship__c CoMarketingRel {get;set;}
        public string status{get; set;}
        public Boolean Disable {get; set;}
        public String AuthStatus{get; set;}
        public CoMarketingRelWrapper(comarketing_relationship__c Sub, Boolean isSelected, String status, Set<Id> Authorizedids) {
            this.CoMarketingRel = Sub;
            this.isSelected = isSelected;
            this.status = status;
            this.disable = false;
            if(Authorizedids.contains(Sub.Id))
            this.AuthStatus = 'Authorized';
        }
    }
    
    public class Paymentprofilewrapper {
        public Boolean isSelected {get;set;}
        public PaymentProfiles__c Paymentprofile {get;set;}
        public Boolean isNew {get;set;}
        public integer index {get;set;}
        public Boolean BINerror {get;set;}
        public Boolean Expired {get; set;}
        public String userBIN{get; set;}
        public Paymentprofilewrapper(PaymentProfiles__c pay, Boolean isSelected, integer i, Boolean Expired, Boolean LenderPage) {
            this.Paymentprofile = pay;
            this.isSelected = isSelected;
            this.index = i;
            this.BINerror = false;
            if(LenderPage)
            this.isNew = pay.CreatedDate < System.now().addhours(-1) ? false : true;
            else
            this.isNew = pay.CreatedDate.date() == System.today() ? true : false;
            this.Expired = Expired;
        }
    } 
    
    public static void appendinfo(String Message) {
        appendMessage(ApexPages.Severity.confirm, message);
    }
    public static void appendError(String Message) {
        appendMessage(ApexPages.Severity.ERROR, message);
    } 
    public static void appendMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    public PageReference refreshPageSize() {
        valuechanged = true;        
        init();      
        return null;
    }      
    public PageReference getthevalues() {
        system.debug('at get the values '+ orderByColumn);
        valuechanged = true;
        init();        
        return null;
    } 
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }  
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
   
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    } 
    public PageReference returnToAccount() {
        PageReference returnUrl = new PageReference('/' + sfdcAccountId);        
        return returnUrl;
    }
    public PageReference returntoprofilepage() { 
        renderHPM =false;
        return null;
    }
    public void first() { 
        
        setCon.first();
        init();
    }
    public void last() {   
        
        setCon.last();
        init();
    }
    public void save() {
        setCon.save();
        init();
    }
    
    public void previous() {
        setCon.previous();
        init();
    }
    
    public void next() {
        setCon.next();
        init();
    }
    
    public pagereference nothing() {       
        rowIndex2 = rowIndex;
        return null;
    } 
    public class Z_MPPException extends Exception {}
    public void getselctoptions (){
        
        Fields = new List<SelectOption>();        
        Fields.add(new SelectOption('Asset__r.Name',' Product Name '));    
        Fields.add(new SelectOption('Asset__r.Market_Zip__c',' Market ')); 
        
        Schema.DescribeFieldResult fieldResult = PaymentProfiles__c.Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        ReasonCodes = new List<selectOption>();
        
        List<selectOption> stat = new List<SelectOption>();
        //stat.add(new SelectOption('Select Reason', 'Select Reason'));
        stat.add(new SelectOption('', ''));
        for(Schema.PicklistEntry f : ple)
        {
            stat.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        this.ReasonCodes.addall(stat);
        
        status = new List<SelectOption>();
        status.add(new SelectOption('All',' ALL ')); 
        status.add(new SelectOption('Active',' Active '));
        status.add(new SelectOption('Cancelled',' Cancelled '));
        // status.add(new SelectOption('Suspended',' Suspended '));
        if(size == null)
            this.size=999;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('100','100'));
        paginationSizeOptions.add(new SelectOption('200','200'));
        paginationSizeOptions.add(new SelectOption('300','300'));
        paginationSizeOptions.add(new SelectOption('500','500'));
        paginationSizeOptions.add(new SelectOption('999','1000')); 
    }  
    public void editProfile() {
        System.debug('edit paymentmethod called');        
        //  System.debug(FUNC_STR+'Starting editProfile for Profile:' + profileToEdit);        
        if (String.isNotBlank(profileToEdit)) {
            
            List<Paymentprofilewrapper> newWrapperList = new List<Paymentprofilewrapper>();
            PaymentProfiles__c profToEdit = null;
            
            for (Paymentprofilewrapper wrapper : paymentProfiles) {
                PaymentProfiles__c updatepayment = wrapper.paymentProfile;
                if (updatepayment.Id == profileToEdit) {
                    System.debug('Found matching payment profile. Will edit');
                    profToEdit = wrapper.paymentProfile;
                    if (String.isNotBlank(cardType)) {
                        profToEdit.CreditCardType__c = cardType;
                        updatepayment.CreditCardType__c = cardType;
                    }
                    if (String.isNotBlank(expirationDate)) {
                        profToEdit.ExpirationDate__c = expirationDate;
                        updatepayment.ExpirationDate__c = expirationDate;
                    }
                    if (String.isNotBlank(cardHolderName)) {
                        profToEdit.CardholderName__c = cardHolderName;
                        updatepayment.CardholderName__c = cardHolderName;
                    }
                    break;
                } else {
                    newWrapperList.add(wrapper);
                }
            }
            try{
                
            }
            catch(Exception e)
            {
                System.debug('Could not update Payment Profile in SFDC');
                return;
            }            
            if (profToEdit != null && String.isNotBlank(profToEdit.PaymentMethodId__c)) {                
                Boolean fieldsSet = false;
                Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
                System.debug('Payment Method Type: '+ profToEdit.Payment_Method_Type__c);
                if(profToEdit.Payment_Method_Type__c == 'CreditCard'){
                    System.debug('CC Payment Method ID: '+profToEdit.PaymentMethodId__c);
                    pm.setValue('Id',profToEdit.PaymentMethodId__c);
                    pm.setValue('CreditCardType',profToEdit.CreditCardType__c);
                    String[] expirationSplit;
                    expirationSplit = profToEdit.ExpirationDate__c.split('/');
                    if(expirationSplit.size() == 2)
                    {
                        if(expirationSplit[0].length() == 1)
                            pm.setValue('CreditCardExpirationMonth','0'+expirationSplit[0]);
                        else
                            pm.setValue('CreditCardExpirationMonth',expirationSplit[0]);
                        pm.setValue('CreditCardExpirationYear',expirationSplit[1]);
                        
                    }
                    pm.setValue('CreditCardHolderName',profToEdit.CardholderName__c);
                    if (String.isNotBlank(cardCVV)) {
                        pm.setValue('CreditCardSecurityCode',cardCVV);
                        cardCVV = '';
                    }
                    if (String.isNotBlank(billingAddress)) {
                        pm.setValue('CreditCardAddress1',billingAddress);
                        billingAddress = '';
                    }
                    if (String.isNotBlank(billingCity)) {
                        pm.setValue('CreditCardCity',billingCity);
                        billingCity = '';
                    }
                    if (String.isNotBlank(billingState)) {
                        pm.setValue('CreditCardState',billingState);
                        billingState = '';
                    }
                    if (String.isNotBlank(billingPostalCode)) {
                        pm.setValue('CreditCardPostalCode',billingPostalCode);
                        billingPostalCode = '';
                    }
                    if (String.isNotBlank(billingCountry)) {
                        pm.setValue('CreditCardCountry',billingCountry);
                        billingCountry = '';
                    }
                    
                    fieldsSet = true;
                }
                List<Zuora.zObject> objs = new List<Zuora.zObject> {pm};
                    
                    if(fieldsSet==false)
                {
                    return;
                }
                
                Zuora.ZApi zApi = new Zuora.ZApi();
                //Login to Zuora
                try {
                    Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
                } catch (Exception ex) {
                    appendError('Error occurred trying to log in to Zuora: '+ex.getMessage());
                    return;
                }
                List<Zuora.ZApi.SaveResult> updateResults = new List<Zuora.ZApi.SaveResult>();
                try {
                    if(!Test.isRunningTest()){
                        updateResults = zApi.zUpdate(objs);
                        System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                        System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
                        
                    }
                } catch (Exception ex) {
                    appendError('Error occurred trying to update payment method in Zuora: '+ex.getMessage());
                    return;
                }               
                Boolean updatePaymentMethodInZuora = false;
                if (updateResults.size() > 0) {
                    Zuora.ZApi.SaveResult updateResult = updateResults[0];
                    if(updateResult.Success != null && updateResult.Success==true)
                    {
                        updatePaymentMethodInZuora = true;
                    }
                    else
                    {
                        String updateError = (updateResult.Errors != null && updateResult.Errors.size() > 0 && String.isNotBlank((String)updateResult.Errors[0].getValue('Message'))) ? (String)updateResult.Errors[0].getValue('Message') : '';
                        appendError(updateError);
                        return;                       
                    }
                } else {
                    appendError('Error occurred trying to update payment method in Zuora. SaveResult list is empty');
                    return;
                }                
                if(updatePaymentMethodInZuora==true){
                    //Remove Payment Profile from SFDC
                    update profToEdit;
                }
            }
            
        }
        else
        {
            System.debug('profileToEdit was blank or NULL');
        }
    }
}