/*    Copyright (c) 2014 Zuora, Inc.
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy of 
*   this software and associated documentation files (the "Software"), to use copy, 
*   modify, merge, publish the Software and to distribute, and sublicense copies of 
*   the Software, provided no fee is charged for the Software.  In addition the
*   rights specified above are conditioned upon the following:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
*   or promote products derived from this Software without specific prior written
*   permission from Zuora, Inc.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
*   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
*   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
*   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
*   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
*   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
*   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
*
*   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
*
*   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
*/
public without sharing class Z_PaymentProfileManagerController {
    
    private static final String DEBUG_STR = 'Z_PaymentProfileManagerController: ';
    
    private final String MISSING_ID_ERROR        = 'Must specify id parameter in URL.';
    private final String OBJECT_LOOKUP_ERROR     = 'Failed to find CPQ Quote or SFDC Account based on Id in URL.';
    private final String HPM_CONFIG_ERROR        = 'An occurred setting up the proper HPM page.';
    private final String AUTH_SUCCESS_TEXT       = 'Success';
    private final String AUTH_ERROR_TEXT         = 'Error';
    private final String AUTH_FAILURE_TEXT       = 'Error';
    private final String CC_PM_TYPE              = 'CreditCard';
    private final String CC_PAYMENT_SETTING_TYPE = 'Credit Card';
    private final String ACH_PM_TYPE             = 'ACH';
    public Zuora.zApi zapi = new Zuora.zApi();
    
    public String paymentPageComponentName {get;set;}
    
    //CPQ Quote object in Salesforce
    public Id quoteId {get;set;}
    public BigMachines__Quote__c quote {get;set;}
    public Boolean hasQuote {
        get {
            if (quoteId != null && quote != null) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    //SFDC "Account" object in SFDC
    public Id sfdcAccountId {get;set;}
    public Account sfdcAccount {get;set;}
    public Boolean hasSfdcAccount {
        get {
            if (sfdcAccountId != null && sfdcAccount != null) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    //Zuora "Billing Account" object in SFDC
    public Id sfdcBillingAccountId {get;set;}
    public Zuora__CustomerAccount__c sfdcBillingAccount {get;set;}
    public Boolean hasSfdcBillingAccount {
        get {
            if (sfdcBillingAccountId != null && sfdcBillingAccount != null) {
                return true;
            } else {
                return false;
            }
        }
    }
    public String paymentDate {get;set;}
    
    //Zuora "Account" object in Zuora
    public String zuoraAccountId {get;set;}
    public Zuora.ZObject zuoraAccount {get;set;}
    public Boolean hasZuoraAccount {
        get {
            if (String.isNotBlank(zuoraAccountId) && zuoraAccount != null) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    //List of wrappers containing payment profile information, displayed on VF page
    public List<Z_PaymentProfileWrapper> paymentProfileList     {get;set;}
    
    public List<Z_PaymentProfileWrapper> ccPaymentProfileList {
        get {
            List<Z_PaymentProfileWrapper> wrappers = new List<Z_PaymentProfileWrapper>();
            
            if (paymentProfileList != null) {
                for (Z_PaymentProfileWrapper wrapper : paymentProfileList) {
                    if (String.isNotBlank(wrapper.pmType) && wrapper.pmType.equalsIgnoreCase('CreditCard')) {
                        wrappers.add(wrapper);
                    }
                }
            }
            
            return wrappers;
        }
    }
    
    public List<Z_PaymentProfileWrapper> achPaymentProfileList {
        get {
            List<Z_PaymentProfileWrapper> wrappers = new List<Z_PaymentProfileWrapper>();
            
            if (paymentProfileList != null) {
                for (Z_PaymentProfileWrapper wrapper : paymentProfileList) {
                    if (String.isNotBlank(wrapper.pmType) && wrapper.pmType.equalsIgnoreCase('ACH')) {
                        wrappers.add(wrapper);
                    }
                }
            }
            
            return wrappers;
        }
    }
    
    //Used for showing / hiding IFrame for capturing payment methods
    public Boolean renderHPM {get;set;}
    
    //Used for determining if page is setup properly
    public Boolean hasConfigError {get;set;}
    
    //Holds page id of HPM 2.0 page
    public String ccHpmPageId {get;set;}
    public String achHpmPageId {get;set;}
    
    //Holds Id of Payment Profile we will delete
    public Id profileToDelete {get;set;}
    
    //Holds Id of Payment Profile we will edit
    public Id profileToEdit {get;set;}
    
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
    
    /** ACH Fields **/ 
    public String achAbaCode {get;set;}
    public String achAccountName {get;set;}
    public String achAccountType {get;set;}
    public String achBankName {get;set;}
    
    public List<ProfileSelectorcombo> Profileselect {get;set;}
    
    //Holds type of payment method selected for rendering IFrame
    public String paymentMethodType {get;set;}
    
    //Holds list of new payment method options for IFrame
    public List<SelectOption> getPaymentMethodOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CreditCard', 'Credit Card'));
        options.add(new SelectOption('ACH', 'ACH'));
        return options;
    }
    public Boolean collectpayment {get;set;}
     public Boolean Parentaccountnotfound {get;set;}
    public Integer Selectindex {get;set;}
   // public Decimal Existingpmttotal {get;set;}
    public Boolean ShowReload {get;set;}
   
    public Z_PaymentProfileManagerController() {
        final String FUNC_STR = DEBUG_STR + 'Z_PaymentProfileManagerController: ';
        String objectId = ApexPages.currentPage().getParameters().get('id');
        //objectId = '001j000000beLs3AAE';
        System.debug(objectId + 'Page ID@@');
        this.hasConfigError = true;
        this.renderHPM = false;
        this.paymentMethodType = 'CreditCard';
        this.paymentPageComponentName = 'ManagePaymentProfile';
        this.collectpayment = false;
        this.Parentaccountnotfound = false;
        //Check to make sure there is a valid Id param in URL
        if (String.isNotBlank(objectId)) {
            if (searchForQuote(objectId) || searchForSfdcAccount(objectId)) {
                System.debug(FUNC_STR+'Successfully found CPQ Quote or SFDC Account');
                system.debug('Parentaccountnotfound@' +Parentaccountnotfound);
               hasConfigError = false;         
            } else {
                appendError(OBJECT_LOOKUP_ERROR);
                hasConfigError = true;
            }
        } else {
            appendError(MISSING_ID_ERROR);
            hasConfigError = true;
        }
        //Attempt to retrieve ids for each HPM form
        setHpmPageIds();
        if (String.isBlank(this.ccHpmPageId) || String.isBlank(this.achHpmPageId)) {
            appendError(HPM_CONFIG_ERROR);
            hasConfigError = true;
        }
    }
       
  //Method called on page load. Retrieves existing Payment Profiles and constucts wrappers for VF Page. If Zuora Account does not already exist, creates new one

    public PageReference onLoad() {
        final String FUNC_STR = DEBUG_STR + 'onload: ';
        System.debug(FUNC_STR+'Starting method');
        this.Selectindex = 1000; 
        this.paymentProfileList = retrieveExistingWrappers();
        generateProfileSelect();
        refreshAuthAmounts();
           
       // updateprofileamount();
        //this.Selectindex = 0; 
        System.debug(FUNC_STR+'Retrieved '+paymentProfileList.size()+' existing wrappers');
        //Create Account in Zuora if it doesn't exist
        if (hasQuote && hasSfdcAccount) {
            
            if (searchForSFDCBillingAccount(this.sfdcAccountId)) {
                System.debug(FUNC_STR+'Found Billing Account in SFDC. No need to create Zuora Account');
                this.zuoraAccountId = this.sfdcBillingAccount.Zuora__Zuora_Id__c;
            } else {
                System.debug(FUNC_STR+'Failed to find Billing Account in SFDC. Will search Zuora for crmId "'+this.quote.BigMachines__Account__c+'"');
                
                if (searchForZuoraAccount(this.quote.BigMachines__Account__c)) {
                    System.debug(FUNC_STR+'Found Account in Zuora: '+(String)this.zuoraAccount.getValue('Id')+'. No need to create Zuora Account');
                } else {
                    System.debug(FUNC_STR+'Failed to find Account in Zuora with crmId "'+this.quote.BigMachines__Account__c+'". Need to create Zuora Account');
                    try {
                        Z_PaymentMethodCaptureUtil Zmeths = new Z_PaymentMethodCaptureUtil();
                        this.zuoraAccountId = Zmeths.createZuoraAccount(this.sfdcAccount);
                    } catch (Z_MPPException ex) {
                        appendError('Exception occurred creating new Zuora Account: '+ex.getMessage());
                        this.hasConfigError = true;
                    }
                }
            }
        } else {
            System.debug(FUNC_STR+'Page is missing Quote or SFDC Account. Will not check for existing / create new Zuora Account');
        }
        // CRM-3969 skip this method for realtor.com customers.
        if(collectpayment)
         updateprofileamount();  
        this.Selectindex = 0;      
        return null;
    }
    //CRM-3305 Moving: Update Zuora payment screen to accommodate PPC and Invoice Customers.Start.
    public void generateProfileSelect(){
        
        this.Profileselect = new List<ProfileSelectorcombo>();
        system.debug('Payemnt profile list' + paymentProfileList.size());
        for (Integer i=0; i<paymentProfileList.size(); i++){
            if (String.isNotBlank(paymentProfileList.get(i).pmType) && paymentProfileList.get(i).pmType.equalsIgnoreCase('CreditCard'))
                this.Profileselect.add(new ProfileSelectorcombo(paymentProfileList.get(i), i));
        }
    }
    public class ProfileSelectorcombo{
        public Z_PaymentProfileWrapper paymentProfile {get;set;}
        public Boolean isSelected {get;set;}
        public Integer selectionIndex {get;set;}
        public ProfileSelectorcombo(Z_PaymentProfileWrapper i, Integer s){
            paymentProfile = i;
            if(i.percentSplit == 100){
                isSelected = true;
            }
            else {
                isSelected = false;   
            }
            selectionIndex = s;
            // appliedAmount=0;
            if(Test.isRunningTest())
                isSelected = true;
        }
    }
    
    public void updateprofileamount(){
        //clears any current messeges
        ApexPages.getMessages().clear();
        // Decimal PaymentTotal = (this.quote.BigMachines_first_month_payment__c != null) ? this.quote.BigMachines_first_month_payment__c : 0;
        for (ProfileSelectorcombo inloop : Profileselect){ 
            String newPaymentstatus = '';
            Decimal newPaymentamount = 0;
            Decimal PaymentTotal  =  inloop.paymentProfile.Paymentamount != null ?  inloop.paymentProfile.Paymentamount : 0;
            Decimal ExistingprofileAmount =inloop.paymentProfile.existingPaymentTotal != null ? inloop.paymentProfile.existingPaymentTotal : 0;
            System.debug( ' inloop.paymentProfile.percentSplit ' +  inloop.paymentProfile.percentSplit  + ' inloop.isSelected: ' + inloop.isSelected  + ' PaymentTotal: ' + PaymentTotal + ' Selectindex: ' + Selectindex + ' inloop.selectionIndex: ' + inloop.selectionIndex  + ' ExistingprofileAmount: '+ExistingprofileAmount);
            if((inloop.isSelected && (Selectindex == inloop.selectionIndex || Selectindex == 1000)) || (Selectindex == inloop.selectionIndex && PaymentTotal > 0)){     
                System.debug('inside@');
                if(Selectindex == 1000){
                    if (ExistingprofileAmount != null && ExistingprofileAmount > 0) {              
                        newPaymentstatus = 'Processed';
                        newPaymentamount = ExistingprofileAmount;                      
                    }                
                }else{
                    if(ExistingprofileAmount != null && ExistingprofileAmount > 0 && PaymentTotal == 0){
                        newPaymentstatus = 'Processed';
                        newPaymentamount = ExistingprofileAmount;
                    }else{
                        newPaymentamount = PaymentTotal;
                    }
                }            
                inloop.paymentProfile.percentSplit = 100;
                inloop.isSelected =true;
            }else {
                //If something is de-selected and its value is not 0, it's value gets set to 0
                if(ExistingprofileAmount != null && ExistingprofileAmount > 0){
                    newPaymentamount = ExistingprofileAmount;
                    newPaymentstatus = 'Processed';
                }     
                inloop.isSelected = false;
                inloop.paymentProfile.percentSplit = 0;
            }
            inloop.paymentProfile.Paymentstatus = newPaymentstatus;
            inloop.paymentProfile.Paymentamount = newPaymentamount;
        }
    }
    public void updatedefaultmethod(){
        //clears any current messeges
        ApexPages.getMessages().clear();
        for (ProfileSelectorcombo inloop : Profileselect){ 
            if(inloop.isSelected && (Selectindex == inloop.selectionIndex || Selectindex == 1000)){  
                inloop.paymentProfile.percentSplit = 100;
            }else{
                inloop.paymentProfile.percentSplit = 0;
            }
        }
   }
    public PageReference MakePayment() {
        final String FUNC_STR = DEBUG_STR + 'CreatePayments: ';
        System.debug(FUNC_STR+'Starting CreatePayments');
	     for(Z_PaymentProfileWrapper currwrap : ccPaymentProfileList) {           
            string[] expArray = currwrap.expirationDate.split('/');
            Integer expMonth = integer.valueOf(expArray[0]);
            Integer expYear = integer.valueOf(expArray[1]);
            if (((expYear == integer.valueOf(system.today().year()) && expMonth <=Integer.valueOf(system.today().month()))
                 || (expYear < integer.valueOf(system.today().year())))&&(currwrap.percentSplit > 0)) 
            {
                appendError('Payment Failure: The expiration date on this credit card has passed or the card is expiring this month. Please use a valid credit card.');
                return null;
            }
        } 
        //Check success of validations
        if (validatePaymentProfiles()) {
            System.debug(FUNC_STR+'Cards passed validation');           
            
            if (!hasQuote || perfromapayements()) {
                System.debug(FUNC_STR+'Cards passed CreatePayments');               
              
                if(updatePaymentProfileSplits()) {
                    if(hasQuote){
                    appendSuccess('Payment Success: Quote and Payment Profiles updated with new Payment information');
                    updateQuoteWithpaymentSuccess();
                    }else{
                      appendSuccess('Default Payment method updated Successfully');  
                    }
                } else {
                    appendError('Payment Failure: Quote Update failed');
                    updateQuoteWithAuthFailure();
                }
            } else {
                appendError('Payment Failure: Card Payment was not processed');
                updateQuoteWithAuthFailure();
            }
        } else {
            appendError('Payment Failure: Cards did not pass validation');
            updateQuoteWithAuthFailure();
        }
        
        return null;
    }
    public Boolean perfromapayements() {
        final String FUNC_STR = DEBUG_STR + 'Create Payment: ';
        System.debug(FUNC_STR+'Starting performPaymentCallouts');        
        Boolean PaymentSucces = true;
       List<ProfilePayment__c> newPayementRecords = new List<ProfilePayment__c>();       
        for (Z_PaymentProfileWrapper profWrapper : paymentProfileList) { 
            
            if (profWrapper.percentSplit != null && profWrapper.percentSplit > 0) {
                
               if (profWrapper.Paymentstatus != 'Processed' && profWrapper.pmType == 'CreditCard') {
                   
                    if (profWrapper.Paymentamount != null && profWrapper.Paymentamount > 0) {
                        
                        String Result = Performpayment(profWrapper.pmId, profWrapper.Paymentamount, this.zuoraAccountId, profWrapper.paymentProfile);
                        
                        if (Result != 'Error' && profWrapper.Paymentamount != null && profWrapper.Paymentamount > 0){  
                            
                            String Response  = QueryPayment(Result);
                            if(Response == 'Processed' || Response == 'Processing'){          
                                profWrapper.Paymentstatus = Response;
                                if(Response == 'Processed') {
                                    PaymentSucces = true;
                                    system.debug( 'Profile wrpaper '+profWrapper.Paymentamount);                                    
                                    profWrapper.existingPaymentTotal +=profWrapper.Paymentamount;
                                    ProfilePayment__c PayementRecord = CreatePayementRecord(Response, Result, profWrapper.Paymentamount, Datetime.now(), profWrapper.paymentProfile, quote, false);                       
                                    this.quote.BigMachines_authorization_amount__c = profWrapper.Paymentamount;
                                    if (PayementRecord != null)                       
                                        newPayementRecords.add(PayementRecord);
                                }else{
                                    this.ShowReload = true;
                                }
                            }else{
                                profWrapper.Paymentstatus = 'Not Processed';
                                appendError('Gate way Response : '+ Response);
                                  PaymentSucces = false;
                            }
                        } else {
                            profWrapper.Paymentstatus = 'Not Processed';
                            System.debug(FUNC_STR+'Error has occurred during Payement. Breaking loop from further Payments');
                            PaymentSucces = false;
                            break;
                        }
                    } else {
                        //Ff no amount to authorize, auto-approve
                       appendError('Payment Amount should be more then $0 ');
                        PaymentSucces = false;
                    }
               } else {
                    System.debug(FUNC_STR+'Profile '+profWrapper.paymentProfile+' already PaymentProcessed for amount '+profWrapper.Paymentamount);
                }
            } else {
                System.debug(FUNC_STR+'Percent Split for wrapper is not greater than 0. No need to Payment');
            }
        }
         if (newPayementRecords.size() > 0) {
            insert newPayementRecords;
        }
        return PaymentSucces;
    } 
    
    
    public String Performpayment(String paymentMethodId, Decimal paymentAmount, String zAccId, PaymentProfiles__c paymentProf) {
        final String FUNC_STR = DEBUG_STR + 'CreatePayment: ';
        String[] todays = String.valueOf(Date.today()).split('-',0);
        this.paymentDate = todays[1] + '/' + todays[2] + '/' + todays[0];
        //Validate params        
        if (String.isNotBlank(paymentMethodId) && String.isNotBlank(zAccId) && paymentAmount != null && paymentAmount > 0 && paymentProf != null) {
            Zuora.zObject payment = new Zuora.zObject('Payment');
            payment.setValue('AccountId', zAccId);
            //payment.setValue('Amount', paymentAmount);
            payment.setValue('Comment', 'Create prePayment for Moving or MRC');
            payment.setValue('AppliedCreditBalanceAmount', paymentAmount);
            payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateonly(convertDate(paymentDate)));
            payment.setValue('PaymentMethodId', paymentMethodId);
            payment.setValue('ZPaymentMethodId__c', paymentMethodId);
            payment.setValue('Type', 'Electronic');
            payment.setValue('Status', 'Processed');
            payment.setValue('OneTimePayment__c', 'True');          
            List<Zuora.zApi.SaveResult> results;            
            List<Zuora.zObject> objs = new List<Zuora.zObject>{payment};
                if (!Test.isRunningTest()){                  
                    zapi = getZApi();
                    results = zapi.zcreate(objs);
                } else {
                    Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                    res.Success = false;
                    Zuora.zObject error = new Zuora.zObject('Error');
                    res.errors = new Zuora.zObject[]{error};
                    results = new List<Zuora.zApi.SaveResult>{};
                    results.add(res);
                }
            String Resultss ='';
            system.debug('results@ :' + results);
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText = '';
                    if (Test.isRunningTest())
                        break;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';
                    }
                    Resultss = 'Error';
                    appendError('Payment Failed : '+ errorText);
                    
                } else{             
                    Resultss = result.Id;
                }
            }            
            return Resultss;            
        } else {
            String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
             appendError('Invalid parameters passed to Payment call for card '+pmInfo);
            return '';
        } 
    }
    public String QueryPayment(String PayementId){
        List<Zuora.zObject> Payment;
        //Create ZOQL query
        String zoql = 'SELECT Id, GatewayResponse, Status from Payment where Id = \'' + PayementId + '\'';
        if (!Test.isRunningTest()){
            //Query for payments from Zuora
            Payment = zapi.zquery(zoql);
        }else{  
            Zuora.zObject tempPm = new Zuora.zObject('Payment');
            tempPm.setValue('Status','Processed');
            tempPm.setValue('Id','23234234234');
            Payment = new List<Zuora.zObject>();
            Payment.add(tempPm);
        }
        String Response = '';
        String Status = String.valueof(Payment.get(0).getValue('Status'));
        If(Status == 'Error'){
            Response = String.valueof(Payment.get(0).getValue('GatewayResponse'));
        }else if(Status == 'Processed' || Status == 'Processing'){
            Response = Status;
        }else {
            Response = 'Payment cancelled or voided'; 
        }
       return Response;
    }
    //CRM-3305 Moving: Update Zuora payment screen to accommodate PPC and Invoice Customers end.
    
   
 //Retrieve Payment Pages Settings for component and sets them as cc or ach page id to use

    public void setHpmPageIds() {
        final String FUNC_STR = DEBUG_STR + 'setHpmPageIds: ';
        
        // Query for settings
        List < zqu__HostedPageLiteSetting__c > settingList = [SELECT zqu__PageId__c, zqu__PaymentMethodType__c, zqu__ComponentName__c FROM zqu__HostedPageLiteSetting__c WHERE zqu__ComponentName__c = :paymentPageComponentName];
        
        if(settingList != null && !settingList.isEmpty()) {
            System.debug(FUNC_STR+'Retrieved settings: '+settingList);
            
            for (zqu__HostedPageLiteSetting__c pageSetting : settingList) {
                if (CC_PAYMENT_SETTING_TYPE.equalsIgnoreCase(pageSetting.zqu__PaymentMethodType__c)) {
                    System.debug(FUNC_STR+'Found CC Payment Page Setting: '+pageSetting);
                    this.ccHpmPageId = pageSetting.zqu__PageId__c;
                } else if (ACH_PM_TYPE.equalsIgnoreCase(pageSetting.zqu__PaymentMethodType__c)) {
                    System.debug(FUNC_STR+'Found ACH Payment Page Setting: '+pageSetting);
                    this.achHpmPageId = pageSetting.zqu__PageId__c;
                } else {
                    System.debug(FUNC_STR+'Page Setting did not match CC or ACH types: '+pageSetting);
                }
            }
        } else {
            System.debug(FUNC_STR+'Failed to retrieve PaymentPage settings');
        }
    }
    
    
    public void editProfile() {
        final String FUNC_STR = DEBUG_STR + 'editProfile: ';
        System.debug(FUNC_STR+'Starting editProfile for Profile:' + profileToEdit);
        
        if (String.isNotBlank(profileToEdit)) {
            
            List<Z_PaymentProfileWrapper> newWrapperList = new List<Z_PaymentProfileWrapper>();
            PaymentProfiles__c profToEdit = null;
            
            for (Z_PaymentProfileWrapper wrapper : this.paymentProfileList) {
                if (wrapper.profileId == profileToEdit) {
                    System.debug(FUNC_STR+'Found matching payment profile. Will edit');
                    profToEdit = wrapper.paymentProfile;
                    
                    //Update Payment Profile object in SFDC
                    /** Credit Card Fields **/
                    if (String.isNotBlank(cardType)) {
                        profToEdit.CreditCardType__c = cardType;
                        wrapper.cardType = cardType;
                    }
                    if (String.isNotBlank(expirationDate)) {
                        profToEdit.ExpirationDate__c = expirationDate;
                        wrapper.expirationDate = expirationDate;
                    }
                    if (String.isNotBlank(cardHolderName)) {
                        profToEdit.CardholderName__c = cardHolderName;
                        wrapper.cardHolderName = cardHolderName;
                    }
                    
                    /** ACH Fields **/ 
                    if (String.isNotBlank(achAbaCode)) {
                        profToEdit.ACH_ABA_Code__c = achAbaCode;
                        wrapper.achAbaCode = achAbaCode;
                    }
                    if (String.isNotBlank(achAccountName)) {
                        profToEdit.ACH_Account_Name__c = achAccountName;
                        wrapper.achAccountName = achAccountName;
                    }
                    if (String.isNotBlank(achAccountType)) {
                        profToEdit.ACH_Account_Type__c = achAccountType;
                        wrapper.achAccountType = achAccountType;
                    }
                    if (String.isNotBlank(achBankName)) {
                        profToEdit.ACH_Bank_Name__c = achBankName;
                        wrapper.achBankName = achBankName;
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
                if(profToEdit.Payment_Method_Type__c == 'ACH'){
                    System.debug('ACH Payment Method ID: '+profToEdit.PaymentMethodId__c);
                    pm.setValue('Id',profToEdit.PaymentMethodId__c);
                    pm.setValue('AchAbaCode',profToEdit.ACH_ABA_Code__c);
                    pm.setValue('AchAccountName',profToEdit.ACH_Account_Name__c);
                    pm.setValue('AchAccountType',profToEdit.ACH_Account_Type__c);
                    pm.setValue('AchBankName',profToEdit.ACH_Bank_Name__c);
                    fieldsSet = true;
                }
                List<Zuora.zObject> objs = new List<Zuora.zObject> {pm};
                    
                    if(fieldsSet==false)
                {
                    appendError('Could not set fields to update');
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
                System.debug(FUNC_STR+'Logged into Zuora successfully');
                
                //Update() Payment Method
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
    
    public void deleteProfile() {
        final String FUNC_STR = DEBUG_STR + 'deleteProfile: ';
        System.debug(FUNC_STR+'Starting deleteProfile');
        
        if (String.isNotBlank(profileToDelete)) {
            System.debug(FUNC_STR+'profiletoDelete not empty: '+profileToDelete);
            List<Z_PaymentProfileWrapper> newWrapperList = new List<Z_PaymentProfileWrapper>();
            
            PaymentProfiles__c profToDelete = null;
            
            for (Z_PaymentProfileWrapper wrapper : this.paymentProfileList) {
                if (wrapper.profileId == profileToDelete) {
                    System.debug(FUNC_STR+'Found matching payment profile. Will delete');
                    profToDelete = wrapper.paymentProfile;
                } else {
                    newWrapperList.add(wrapper);
                }
            }
            
            this.paymentProfileList = newWrapperList;
            
            if (profToDelete != null && String.isNotBlank(profToDelete.PaymentMethodId__c)) {
                //Remove payment method from Zuora
                Set<String> pmIdsToDelete = new Set<String>{profToDelete.PaymentMethodId__c};
                    
                    Zuora.ZApi zApi = new Zuora.ZApi();
                
                //Login to Zuora
                try {
                    Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
                } catch (Exception ex) {
                    appendError('Error occurred trying to log in to Zuora: '+ex.getMessage());
                    return;
                }
                System.debug(FUNC_STR+'Logged into Zuora successfully');
                
                //Delete() Payment Method
                List<Zuora.ZApi.DeleteResult> deleteResults = new List<Zuora.ZApi.DeleteResult>();
                try {
                    deleteResults = (!Test.isRunningTest()) ? zApi.zDelete('PaymentMethod', new List<String>(pmIdsToDelete)) : new List<Zuora.ZApi.DeleteResult>{Z_TestFactory.createTestDeleteResult(true)};
                        } catch (Exception ex) {
                            appendError('Error occurred trying to delete payment method in Zuora: '+ex.getMessage());
                            return;
                        }
                
                Boolean deletedPaymentMethodInZuora = false;
                if (deleteResults.size() > 0) {
                    Zuora.ZApi.DeleteResult deleteResult = deleteResults[0];
                    deletedPaymentMethodInZuora = (deleteResult.Success != null) ? deleteResult.Success : false;
                } else {
                    appendError('Error occurred trying to delete payment method in Zuora. DeleteResult list is empty');
                    return;
                }
                
                //Remove Payment Profile from SFDC
                delete profToDelete;
                
                if (hasQuote) {
                    System.debug(FUNC_STR+'Updating Quote with failed authorization');
                    this.quote.BigMachines_authorization_amount__c = 0;
                    this.quote.BigMachines_authorization_date__c = Datetime.now();
                    this.quote.BigMachines_authorization_status__c = AUTH_FAILURE_TEXT;
                    try {
                        update this.quote;
                    } catch (Exception ex) {
                        appendError('Error occurred updating Quote with failed authorization details: '+ex.getMessage());
                    }
                    
                }
            }
        } else {
            System.debug(FUNC_STR+'profileToDelete was empty, will not delete any profiles');
        }
    }
    
    
    /**
* Method called when the IFrame submission is successful (payment method created)
**/
    public void callbackSuccess() {
        this.renderHPM = false;
    }
    
    
    /**
* Method called when the IFrame submission results in failure (payment method not created)
**/
    public void callbackFailure() { 
        //TODO: implement this
    }
    
    
    /**
* Used for rendering IFrame section of page
**/
    public void renderIFrame() {
        if (!hasConfigError) {
            this.renderHPM = true;
        }
    }
    
    
    /**
* Main method used for the returning to the account
**/
    public PageReference returnToAccount() {
        final String FUNC_STR = DEBUG_STR + 'returnToAccount: ';
        System.debug(FUNC_STR+'Starting returnToAccount');
        
        PageReference returnUrl = new PageReference('/' + sfdcAccountId);
        
        return returnUrl;
    }
    
    /**
* Main method used for the authorization process
* Checks that profiles are valid (splits sum to 100 and BINs match), authorizes payment methods with auth amounts, update Payment Profiles and Quote with new auth information
**/
    public PageReference authorizeCards() {
        final String FUNC_STR = DEBUG_STR + 'authorizeCards: ';
        System.debug(FUNC_STR+'Starting authorizeCards');
        System.debug('zuoraAccountId@@ ' +zuoraAccountId);
        system.debug('sfdcAccountIdId@@ ' + sfdcAccountId);
         system.debug('quoteId@@ ' + quoteId);
        for(Z_PaymentProfileWrapper currwrap : ccPaymentProfileList) {           
            string[] expArray = currwrap.expirationDate.split('/');
            Integer expMonth = integer.valueOf(expArray[0]);
            Integer expYear = integer.valueOf(expArray[1]);
            if (((expYear == integer.valueOf(system.today().year()) && expMonth <=Integer.valueOf(system.today().month()))
                 || (expYear < integer.valueOf(system.today().year())))&&(currwrap.percentSplit > 0)) 
            {
                appendError('Authorization Failure: The expiration date on this credit card has passed or the card is expiring this month. Please use a valid credit card.');
                return null;
            }
        } 
        
        //Check success of validations
        if (validatePaymentProfiles()) {
            System.debug(FUNC_STR+'Cards passed validation');
            
            //Check success of authorizations
            if (!hasQuote || performAuthCallouts()) {
                System.debug(FUNC_STR+'Cards passed authorization');
                
                //Update payment profiles with new split percentages
                if(updatePaymentProfileSplits()) {
                    if(hasQuote){
                    appendSuccess('Authorization Success: Quote and Payment Profiles updated with new authorization information');
                    updateQuoteWithAuthSuccess();
                    }else{
                      appendSuccess('Payment Profiles updated with new Payment Splits');                          
                    }
                } else {
                    appendError('Authorization Failure: Quote Update failed');
                    updateQuoteWithAuthFailure();
                }
            } else {
                appendError('Authorization Failure: Cards did not pass authorization');
                updateQuoteWithAuthFailure();
            }
        } else {
            appendError('Authorization Failure: Cards did not pass validation');
            updateQuoteWithAuthFailure();
        }
        
        return null;
    }
    
    
    /**
* Validates the Payment Profiles are setup correctly
* Checks to make sure the split percentages across the Payment Profiles sum to 100%, and that the BIN is correct for each Payment Profile with a split greater than 0
* @return Boolean True if percent splits sum to 100 and BIN is correct for each Payment Profile with a split greater than 0
**/
    public Boolean validatePaymentProfiles() {
        final String FUNC_STR = DEBUG_STR + 'validatePaymentProfiles: ';
        System.debug(FUNC_STR+'Starting validatePaymentProfiles');
        
        if (this.paymentProfileList != null && paymentProfileList.size() > 0) {
            Decimal total = 0.0;
            
            Boolean binError = false;
            Boolean splitError = false;
            
            for (Z_PaymentProfileWrapper wrapper : paymentProfileList) {
                if (wrapper.percentSplit == null) {
                    wrapper.percentSplit = 0.0;
                    wrapper.exampleAmount = 0.0;
                }
                
                total += wrapper.percentSplit;
                
                if (this.hasQuote) {
                    String normalizedCardBin = (wrapper.cardBIN != null && wrapper.cardBIN.length() > 4) ? wrapper.cardBIN.substring(0,4) : wrapper.cardBIN; 
                    if (!wrapper.isNew && wrapper.percentSplit > 0 && wrapper.userBIN != normalizedCardBin && wrapper.authStatus != 'Authorized') { 
                        binError = true;
                        appendError('Card BIN incorrect for '+wrapper.cardHolderName+' '+wrapper.maskNumber);
                    }
                }
                system.debug('wrapper.percentSplit@@'+wrapper.percentSplit+''+wrapper.reason_code+'wrapper.reason_code'+wrapper.recently_added+'wrapper.recently_added');
                if(wrapper.percentSplit>0&&(wrapper.reason_code==''||wrapper.reason_code==null)&&wrapper.recently_added){
                    system.debug('test@@@');
                    appendError('Please Select Reason Code');
                    return false;
                }
            }
            
            splitError = (total == 100) ? false : true;
            
            if (!splitError && !binError) {
                return true;
            } else {
                if (splitError) {
                    //CRM-3610
                    if(!collectpayment){
                    appendError('Percent Splits must sum to 100');
                    }else{
                      appendError('Please select the Default Payment Method');   
                    }
                }
                
                return false;
            }
        } else {
            appendError('Payment Profile List is empty. Cannot authorize cards');
            return false;
        }
    }
    
    
    /**
* Updates split percentages on all Payment Profiles where the value has changed
* Assumes payment profiles are already validated via validatePaymentProfiles()
* @return Boolean True if 0 or more payment profiles are updated successfully
**/
    public Boolean updatePaymentProfileSplits() {
        final String FUNC_STR = DEBUG_STR + 'updatePaymentProfileSplits: ';
        System.debug(FUNC_STR+'Starting updatePaymentProfileSplits');
        
        Boolean updateSuccess = false;
        
        List<PaymentProfiles__c> profilesToUpdate = new List<PaymentProfiles__c>();
        
        //Retrieve all Payment Profiles where split percentages needs to be updated
        for (Z_PaymentProfileWrapper wrapper : paymentProfileList){
            system.debug(wrapper +'wrapper@@@');
            if (wrapper.percentSplit != wrapper.paymentProfile.SplitPercentage__c) {
                wrapper.paymentProfile.SplitPercentage__c = wrapper.percentSplit;
                wrapper.paymentProfile.Reason_Code__c = wrapper.reason_code;
                if(wrapper.reason_code!=null&&wrapper.reason_code!='')
                    wrapper.paymentProfile.Recently_Added__c=false;
                system.debug(wrapper.paymentProfile+'@@wrapper.paymentProfile@@');
                profilesToUpdate.add(wrapper.paymentProfile);
                system.debug(profilesToUpdate+'@@profilesToUpdate@@');
            }
        }
        
        if (profilesToUpdate.size() > 0) {
            System.debug(FUNC_STR+'Updating '+profilesToUpdate.size()+' payment profiles with new percent split');
            try {
                update profilesToUpdate;
                updateSuccess = true;
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Exception occurred updating Profiles with new split info: '+ex.getMessage());
                updateSuccess = false;
            }
        } else {
            System.debug(FUNC_STR+'No Payment Profiles to update');
            updateSuccess = true;
        } 
        
        return updateSuccess;
    } 
    
    
    public Boolean performAuthCallouts() {
        final String FUNC_STR = DEBUG_STR + 'performAuthCallouts: ';
        System.debug(FUNC_STR+'Starting performAuthCallouts');
        
        Boolean authSuccess = true;
        
        //Login to Zuora and retrieve session
        Zuora.ZApi zApi = new Zuora.ZApi();
        String session = '';
        try {
            session = (!Test.isRunningTest()) ? zApi.zLogin().Session : Z_TestFactory.createTestSession();
        } catch (Exception ex) {
            appendError('Exception occurred logging into Zuora: '+ex.getMessage());
            System.debug(FUNC_STR+'Exception occurred logging into Zuora: '+ex.getMessage());
            return false;
        }
        
        //Change endpoint based on Zuora Config
        Map<String,Object> zConfig = zqu.zQuoteUtil.getZuoraConfigInformation();
        String envEndpoint = (String)zConfig.get('apiurl__c');
        Boolean isProduction = (String.isBlank(envEndpoint) || envEndpoint.contains('apisandbox')) ? false : true;
        System.debug(FUNC_STR+'Environment: '+envEndpoint+', isProduction: '+isProduction+', Session: '+session);
        
        //List<ProfilePayment__c> newAuthRecords = new List<ProfilePayment__c>();
        
        //Cycle through wrappers and auth each necessary payment method
        for (Z_PaymentProfileWrapper profWrapper : paymentProfileList) { 
            
            if (profWrapper.percentSplit != null && profWrapper.percentSplit > 0) {
                
                //Only auth if no existing auth
                if (profWrapper.authStatus != 'Authorized' && profWrapper.pmType == 'CreditCard') {
                    //CRM-1898 Default the authorization amount to 1$
                    //Check auth amount is 0 and auto-approve
                    if (profWrapper.authAmount != null && profWrapper.authAmount > 0) {
                        //Figure out delta auth amount needed for call
                        //Decimal existingAuth = (profWrapper.existingAuthTotal != null) ? profWrapper.existingAuthTotal : 0;
                        Decimal deltaAuth = profWrapper.authAmount;
                        
                        String authToken = performAuthCallout(isProduction, session, profWrapper.pmId, deltaAuth, this.zuoraAccountId, profWrapper.paymentProfile);
                        
                        if (String.isNotBlank(authToken) && deltaAuth != null && deltaAuth > 0){    
                            profWrapper.authStatus = 'Authorized';
                            
                        } else {
                            System.debug(FUNC_STR+'Error has occurred during authorization. Breaking loop from further auths');
                            //Auth Record failed to create for some reason
                            authSuccess = false;
                            //Break for-loop to prevent further authorizations after failure
                            break;
                        }
                    } else {
                        //no amount to authorize, auto-approve
                        profWrapper.authStatus = 'Authorized';
                    }
                    
                } else {
                    System.debug(FUNC_STR+'Profile '+profWrapper.paymentProfile+' already authorized for amount '+profWrapper.authAmount);
                }
                
            } else {
                System.debug(FUNC_STR+'Percent Split for wrapper is not greater than 0. No need to auth');
            }
            
        }
        
        //if (newAuthRecords.size() > 0) {
        //   insert newAuthRecords;
        //}
        
        return authSuccess;
    } 
    
    public String performAuthCallout(Boolean isProduction, String session, String paymentMethodId, Decimal authAmount, String zAccId, PaymentProfiles__c paymentProf) {
        final String FUNC_STR = DEBUG_STR + 'performAuthCallout: ';
        
        String authToken = '';
         System.debug('Perform Auth Callout@  ' + zAccId);        //Validate params
        if (String.isNotBlank(session) && String.isNotBlank(paymentMethodId) && String.isNotBlank(zAccId) && authAmount != null && authAmount > 0 && paymentProf != null) {
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
            String baseUrl;
            //Change endpoint based on Zuora Config
            Map<String,Object> zConfig = zqu.zQuoteUtil.getZuoraConfigInformation();
            String envEndpoint = (String)zConfig.get('apiurl__c');
            System.debug('envEndpoint:' + envEndpoint);
            if(envEndpoint.contains('services455')){
                System.debug('Inside Services');
                baseUrl = 'https://services455.zuora.com/apps/zgw.do?';
            }else if(envEndpoint.contains('services459'))
                baseUrl = 'https://services459.zuora.com/apps/zgw.do?';
            else if (envEndpoint.contains('apisandbox'))
                baseUrl = 'https://apisandbox.zuora.com/apps/zgw.do?';
            else
                baseUrl = 'https://www.zuora.com/apps/zgw.do?';
            System.debug('Auth Amount@' + authAmount);
            String fullEndpoint = baseUrl+'method='+urlMethod+'&AccountId='+zAccId+'&Amount='+authAmount+'&PaymentMethodId='+paymentMethodId;
            
            httpReq.setEndpoint(fullEndpoint);
            httpReq.setMethod(httpMethod);
            
            httpReq.setHeader('Content-Type', 'application/json');
            
            Boolean authCallSuccess = false;
            
            System.debug(FUNC_STR+'HTTP Request: '+httpReq);
            System.debug(FUNC_STR+'Cookie Header: '+httpReq.getHeader('Cookie'));
            try {
                httpResp = (!Test.isRunningTest()) ?  http.send(httpReq) :  Z_PaymentProfileManagerControllerTest.getResponse();
                authCallSuccess = true;
            } catch (Exception ex) {
                String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                appendError('Exception occurred trying to authorize card '+pmInfo+': '+ex.getMessage());
                //updateQuoteWithAuthFailure();
                return '';
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
                            System.debug(FUNC_STR+'Found auth token: '+authToken);
                        } else {
                            String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;                     
                            appendError('Error parsing authorization call response body for card '+pmInfo);
                            //updateQuoteWithAuthFailure();
                            return '';
                        }
                    } else {
                        String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                        appendError('Authorization call failed with response code "'+resultCode+'" and message "'+resultMessage+'" for card '+pmInfo);
                        //updateQuoteWithAuthFailure();
                        return '';
                    }
                    
                } else {
                    String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                    appendError('Error retrieving authorization call response body for card '+pmInfo);
                    //updateQuoteWithAuthFailure();
                    return '';
                }
            } else {
                String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
                appendError('Auth Call Failure for card '+pmInfo+': '+httpResp);
                //updateQuoteWithAuthFailure();
                return '';
            }
            
            return authToken;
        } else {
            String pmInfo = (CC_PM_TYPE.equalsIgnoreCase(paymentProf.Payment_Method_Type__c)) ? ''+paymentProf.MaskNumber__c+' for '+paymentProf.CardholderName__c : ''+paymentProf.ACH_Account_Number_Mask__c+' for '+paymentProf.ACH_Account_Name__c;
            System.debug(FUNC_STR+'Invalid Params passed to performAuthCallout. \nisProduction: '+isProduction+', \nsession: '+session+', \npaymentMethodId: '+paymentMethodId+', \nauthAmount: '+authAmount+', \nzAccId: '+zAccId+', \nPayment Profile: '+paymentProf);
            appendError('Invalid parameters passed to authorization call for card '+pmInfo);
            return '';
        } 
    }
    
    
    public ProfilePayment__c CreatePayementRecord(String Status, String PayId, Decimal PaymentAmount, Datetime authDate, PaymentProfiles__c paymentProf, BigMachines__Quote__c quote, Boolean doInsert) {
        final String FUNC_STR = DEBUG_STR + 'CreatePayementRecord: ';
        
        doInsert = (doInsert != null) ? doInsert : false;
        // authDate = (authDate != null) ? authDate : Datetime.now();
        
        if (String.isNotBlank(PayId) && PaymentAmount != null && PaymentAmount > 0 && paymentProf != null) {
            ProfilePayment__c PaymentRecord = new ProfilePayment__c();
            PaymentRecord.Zuora_Payment_Id__c = PayId;
            PaymentRecord.Payment_Amount__c = PaymentAmount;
            PaymentRecord.Payment_Profile__c = paymentProf.Id;
            PaymentRecord.Status__c = Status;
            if(!doInsert)
                PaymentRecord.Oracle_Quote__c = (quote != null) ? quote.Id : null;
            
            if (doInsert) {
                upsert PaymentRecord Zuora_Payment_Id__c;
            }
            return PaymentRecord;
        } else {
            System.debug(FUNC_STR+'Payment Id or Payment Amount is null. Will not create Payment record');
            return null;
        }
    }
    
    public void updateQuoteWithpaymentSuccess() {
        updateQuoteWithAuth(this.quote.BigMachines_authorization_amount__c, Datetime.now(), AUTH_SUCCESS_TEXT);
    }
    public void updateQuoteWithAuthSuccess() {
        updateQuoteWithAuth(1, Datetime.now(), AUTH_SUCCESS_TEXT);
    }
    
    public void updateQuoteWithAuthFailure() {
        updateQuoteWithAuth(0, Datetime.now(), AUTH_ERROR_TEXT);
    }
    
    public void updateQuoteWithAuth(Decimal authAmount, Datetime authDate, String authStatus) {
        final String FUNC_STR = DEBUG_STR + 'updateQuoteWithAuth: ';
        //commenting for testing praveen
        if (hasQuote) {  
            System.debug(FUNC_STR+'Updating Quote with authorization information. Auth Amount: '+authAmount+', Auth Date: '+authDate+', Auth Status: '+authStatus);
            this.quote.BigMachines_authorization_amount__c = authAmount;
            this.quote.BigMachines_authorization_date__c = authDate; 
            this.quote.BigMachines_authorization_status__c = authStatus;
            try {
                update this.quote;
            } catch (Exception ex) {
                appendError('Error occurred updating Quote with authorization details: '+ex.getMessage());
            }
        }
    }
    
    /**
* Helper method for querying existing Payment Profiles and constucting their wrappers
**/
    public List<Z_PaymentProfileWrapper> retrieveExistingWrappers() {
        final String FUNC_STR = DEBUG_STR + 'retrieveExistingWrappers: ';
        System.debug(FUNC_STR+'Starting method'); 
        List<selectOption> codes = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = PaymentProfiles__c.Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        codes.add(new SelectOption('',''));
        for( Schema.PicklistEntry f : ple)
        {
            codes.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        List<Z_PaymentProfileWrapper> wrappers = new List<Z_PaymentProfileWrapper>();   
        if (String.isNotBlank(this.sfdcAccountId)) {
            List<PaymentProfiles__c> profiles = [SELECT Id, CreatedDate, Recently_added__C,Payment_Method_Type__c, Account__c, CardholderName__c, CreditCardType__c, 
                                                 ExpirationDate__c, MaskNumber__c, PaymentMethodId__c, SplitPercentage__c, ACH_ABA_Code__c, 
                                                 ACH_Account_Name__c, Reason_Code__c,ACH_Account_Number_Mask__c, ACH_Account_Type__c, ACH_Bank_Name__c,Credit_Card_BIN__c,
                                                 (Select Id, Payment_Amount__c, 
                                                  Zuora_Payment_Id__c, Payment_Profile__c , Status__c
                                                  FROM Profile_Payments__r
                                                  WHERE (Status__c = 'Processed' OR Status__c = 'Processing') AND (Oracle_Quote__c = :this.quoteId)) 
                                                 FROM PaymentProfiles__c 
                                                 WHERE Account__c = :this.sfdcAccountId];
            System.debug(FUNC_STR+'Retrieved '+profiles.size()+' existing Payment Profiles');
            
            for (PaymentProfiles__c paymentProf : profiles) {
                
                if (paymentProf.Payment_Method_Type__c == null) {
                    appendError('Payment profile ' + paymentProf.Id + 
                                ' is missing the payment method type.' + 
                                ' Please fix on the payment profile edit page.'); 
                } else if (paymentProf.SplitPercentage__c == null) {
                    appendError('Payment profile ' + paymentProf.Id + 
                                ' is missing the split percentage value.' + 
                                ' Please fix below.'); 
                }
                
                Z_PaymentProfileWrapper wrapper = new Z_PaymentProfileWrapper();
                wrapper.profileId = paymentProf.Id;
                wrapper.pmType = paymentProf.Payment_Method_Type__c;
                wrapper.paymentProfile = paymentProf;
                wrapper.cardType = paymentProf.CreditCardType__c;
                wrapper.expirationDate = paymentProf.ExpirationDate__c;
                wrapper.maskNumber = paymentProf.MaskNumber__c;
                wrapper.percentSplit = paymentProf.SplitPercentage__c;
                wrapper.exampleAmount = (paymentProf.SplitPercentage__c == null) ? 
                    paymentProf.SplitPercentage__c : paymentProf.SplitPercentage__c * 10;
                wrapper.pmId = paymentProf.PaymentMethodId__c;
                wrapper.cardHolderName = paymentProf.CardholderName__c;
                wrapper.achAbaCode = paymentProf.ACH_ABA_Code__c;
                wrapper.achAccountName = paymentProf.ACH_Account_Name__c;
                wrapper.achAccountNumberMask = paymentProf.ACH_Account_Number_Mask__c;
                wrapper.achAccountType = paymentProf.ACH_Account_Type__c;
                wrapper.achBankName = paymentProf.ACH_Bank_Name__c;
                wrapper.cardBIN = paymentProf.Credit_Card_BIN__c;
                wrapper.reason_code = paymentProf.Reason_Code__c;
                wrapper.reason_codes=codes;
                wrapper.Recently_Added = paymentProf.Recently_added__C;
                wrapper.PayemntRecords = (paymentProf.Profile_Payments__r != null) ? paymentProf.Profile_Payments__r : new List<ProfilePayment__c>();
                wrapper.isNew = (paymentProf.CreatedDate.date() == System.today()) ? true : false;
                System.debug(FUNC_STR+'Payment Profile CreatedDate: '+paymentProf.CreatedDate.date()+', Wrapper isNew: '+wrapper.isNew);
                wrapper.existingPaymentTotal = 0;
                wrapper.Paymentamount = 0;
                List<ProfilePayment__c> PayemntRecords = new  List<ProfilePayment__c>();
                for (ProfilePayment__c PaymentRecord : wrapper.PayemntRecords) {
                    if(PaymentRecord.Status__c  == 'Processed'){
                        Decimal PmtAmount = PaymentRecord.Payment_Amount__c != null ? PaymentRecord.Payment_Amount__c : 0;
                        wrapper.existingPaymentTotal += PmtAmount;
                        
                       // this.Existingpmttotal+=PmtAmount;
                    }else if(PaymentRecord.Status__c == 'Processing'){
                        
                        String Response = QueryPayment(PaymentRecord.Zuora_Payment_Id__c);
                        if(Response == 'Processed' ){          
                            wrapper.Paymentstatus = Response;                      
                            ProfilePayment__c newPaymentRecord = CreatePayementRecord(Response, PaymentRecord.Zuora_Payment_Id__c, wrapper.Paymentamount, Datetime.now(), wrapper.paymentProfile, quote, true);                       
                            
                        }else if(Response == 'Processing'){
                            this.ShowReload = true;
                            wrapper.Paymentstatus = Response;   
                        }else{
                            wrapper.Paymentstatus = 'Not Processed';
                        }
                        
                    }
                    
                    System.debug(FUNC_STR+'Retrieved '+wrapper.PayemntRecords.size()+' Payemnt Records for Payment Prof '+paymentProf.Id+': '+wrapper.PayemntRecords);
                    
                    
                }
                wrappers.add(wrapper);
            }
        } else {
            System.debug(FUNC_STR+'Account Id is blank. Will not search for payment profiles');
        }
        
        return wrappers;
    }
    
    
    public PageReference refreshAuthAmounts() {
        final String FUNC_STR = DEBUG_STR + 'refreshAuthAmounts: ';
        
        if (hasQuote) {
            for (Z_PaymentProfileWrapper wrapper : this.paymentProfileList) {
                Decimal newAuthAmount = 0;  
                String newAuthStatus = '';
                if (wrapper.percentSplit != null && wrapper.percentSplit > 0) {   
                    wrapper.authAmount = 1;
                } else{
                    wrapper.authAmount = 0;  
                }   
            }
        }
        
        return null;
    } 
    
    public pageReference refreshPaymentSplits() {
        final String FUNC_STR = DEBUG_STR + 'refreshPaymentSplits: ';
        
        if (hasSFDCAccount) {
            //Use this total for rounding issues
            Decimal exampleAmountTotal = 0;
            Decimal newPaymentSplit = 0;
            
            for (Z_PaymentProfileWrapper wrapper : this.paymentProfileList) {
                exampleAmountTotal = exampleAmountTotal + wrapper.exampleAmount;
            }
            
            for (Z_PaymentProfileWrapper wrapper : this.paymentProfileList) {
                newPaymentSplit = (wrapper.exampleAmount / exampleAmountTotal * 100).setScale(2,System.RoundingMode.HALF_EVEN);
                System.debug('newPaymentSplit: '+newPaymentSplit+', exampleAmountTotal: '+exampleAmountTotal);
                wrapper.percentSplit = newPaymentSplit;
            }
        }     
        return null;     
    }
    
    /**
* Helper method for querying for a Quote based on a passed in Id
**/
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
                this.quoteId = quote.Id;
                
                
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
            System.debug(FUNC_STR+'Found SFDC Account: '+foundAccount);
        }
        
        return foundQuote;
    }
     private Boolean searchForSFDCBillingAccount(String accId) {
        final String FUNC_STR =  'searchForSFDCBillingAccount: ';
        System.debug(FUNC_STR+'Starting searchForSFDCBillingAccount');        
        Boolean foundAccount = false;        
         this.sfdcBillingAccount = Z_PaymentMethodCaptureUtil.searchForSFDCBillingAccount(accId);        
        if (sfdcBillingAccount != null) {
            System.debug(FUNC_STR+'Found Billing Account based on Id: '+accId);
            foundAccount = true;
        this.zuoraAccountId = sfdcBillingAccount.Zuora__Zuora_Id__c;       
            System.debug(FUNC_STR+'Found zuoraAccountId Account based on Id: '+zuoraAccountId);
        } else {
            System.debug(FUNC_STR+'Failed to find Billing Account based on Id: '+accId);
        }        
        return foundAccount;
    }
    
    
    /**
* Helper method for searching for a SFDC Account based on a passed in Id
**/
    public Boolean searchForSfdcAccount(String objectId) {
        final String FUNC_STR = 'searchForSfdcAccount: ';
        System.debug(FUNC_STR+'Starting searchForSfdcAccount with objectId: '+objectId);
         List<Account> accounts = new  List<Account>();
        Boolean foundAccount = false;
        
        if (String.isNotBlank(objectId)) {
            System.debug(FUNC_STR+'objectId not blank, searching for Accounts');
            
            accounts = [SELECT Id,Name,Type,Billing_Preference__c,Subscription_payment__c ,Currency_Type__c,
                                      BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,
                                      ShippingStreet,ShippingCity,Bill_To_Parent__c ,ShippingCountry,ShippingPostalCode,ShippingState,
                                      Zoura_Account_id__c, Phone, Party_ID__c
                                      FROM Account WHERE Id = :objectId LIMIT 1];
            if (accounts.size() > 0) {
                System.debug(FUNC_STR+'Retrieved SFDC Account: '+accounts[0]);
                foundAccount = true;             
                this.sfdcAccount = accounts[0];
                this.sfdcAccountId = sfdcAccount.Id;
                Set<String> acctype = new Set<String>{'Moving Company', 'Moving Corporation', 'Lender Parent','Lender Branch', 'Loan Officer'};
                if(acctype.contains(accounts[0].Type) && (accounts[0].Billing_Preference__c == 'PPC-Auto' || accounts[0].Billing_Preference__c == 'PPC-Manual')){
                    this.collectpayment = true;
                }
                 //parent Account changes
                set<String> childacTypes = new set<String>{'Moving Company','Lender Branch','Loan Officer'};   
                    if(childacTypes.contains(accounts[0].Type) && accounts[0].Bill_To_Parent__c == 'Yes'){
                     foundAccount =  FindtheParentaccount(objectId, childacTypes);                   
                 }
            } else {
                System.debug(FUNC_STR+'Failed to retrieve SFDC Account based on Id: '+objectId);
                foundAccount = false;
            }
        } else {
            System.debug(FUNC_STR+'objectId passed into searchForSfdcAccount was blank');
        }
         system.debug('sfdc@@@@ ' +foundAccount);
       
        system.debug('sfdc@@ ' +foundAccount);
        return foundAccount;
    }
    //parent Account changes
    public Boolean FindtheParentaccount(String objectId, Set<String> childacTypes) {
        
       Boolean foundparentaccount = false;
        List<Account_Relationship__c>  relationact = [Select Id, Parent_Account__c,Parent_Account__r.Type, Child_Account__c From Account_Relationship__c where Child_Account__c = :objectId and Parent_Account__c !=null and Active__c  = true and Relationship_Type__c  = 'Parent/Child' LIMIT 1];
      //set<String> childacTypes = new set<String>{'Moving Company','Lender Branch','Lender Office'};
        if(relationact!=null && relationact.size()>0 && !childacTypes.contains(relationact[0].Parent_Account__r.Type)){
            this.collectpayment = false;
             foundparentaccount =true;
             searchForSfdcAccount(relationact[0].Parent_Account__c);         
        }else{ 
            this.Parentaccountnotfound = true;
             this.sfdcAccountId = null;
             this.sfdcAccount = new Account();
            hasConfigError = true;
            appendError('Bill to parent is Yes and Parent Account Not found. ');               
        }
        return foundparentaccount;
    }
    
    
    /**
* This method searches for an Account in Zuora based on its crmId matching the Id passed into the method (SFDC Account Id)
* If successful, sets this.zuoraAccount and this.zuoraAccountId, and return true. Else returns false
**/
    @TestVisible
    private Boolean searchForZuoraAccount(String sAccId) {
        final String FUNC_STR = DEBUG_STR + 'searchForZuoraAccount: ';
        System.debug(FUNC_STR+'Starting searchForZuoraAccount');
        
        Boolean foundAccount = false;
        
        this.zuoraAccount = Z_PaymentMethodCaptureUtil.searchForZuoraAccount(sAccId, true);
        
        if (zuoraAccount != null) {
            System.debug(FUNC_STR+'Found Account in Zuora based on Id: '+sAccId);
            foundAccount = true;
            this.zuoraAccountId = (String)zuoraAccount.getValue('Id');
        } else {
            System.debug(FUNC_STR+'Failed to find Account in Zuora based on Id: '+sAccId);
        }
        
        return foundAccount;
    }
       
    public Zuora.ZApi getZApi() {
        Zuora.ZApi zApi = new Zuora.ZApi();
        
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            throw new Z_MPPException('Error occurred logging in to Zuora: '+ex.getMessage(), ex);
        }
        
        return zApi;
    }
      
    /**
* Helper method for appending error messages to page messages
**/
    public static void appendError(String Message) {
        appendMessage(ApexPages.Severity.ERROR, message);
    } 
    
    /**
* Helper method for appending success messages to page messages
**/
    public static void appendSuccess(String message) {
        appendMessage(ApexPages.Severity.INFO, message);
    }
    
    /**
* Helper method for appending messages to page messages
**/
    public static void appendMessage(ApexPages.Severity severity, String message) {
        final String FUNC_STR = DEBUG_STR + 'appendMessage: ';
        System.Debug(FUNC_STR+'appendMessage: '+message+', severity: '+severity);
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    
    /**
* Wrapper class for holding important information for the Payment Profile object
* Used for pageBlockTables
**/
    public class Z_PaymentProfileWrapper {
        public PaymentProfiles__c paymentProfile {get;set;}
        public Id profileId {get;set;}
        public String pmId {get;set;}
        public String pmType {get;set;}
        public Decimal percentSplit {get;set;}
        public Boolean isEditMode {get;set;}
        public Boolean hasZuoraPM {get;set;}
        public Boolean isNew {get;set;}
        
        /** Authorization Details **/
        public List<ProfilePayment__c> PayemntRecords {get;set;}
        public Decimal authAmount {get;set;}
        public Decimal exampleAmount {get;set;}
        public String authStatus {get;set;}
        public Decimal existingPaymentTotal {get;set;}
        public List<SelectOption> reason_Codes {get;set;}
        public String Reason_code{get;set;}
        public boolean Recently_Added {get;set;}
        
        /** Credit Card Fields **/
        public String cardType {get;set;}
        public String maskNumber {get;set;}
        public String expirationDate {get;set;}
        public String cardHolderName {get;set;}
        public String cardBIN {get;set;}
        public String userBIN {get;set;}
        
        /** ACH Fields **/ 
        public String achAbaCode {get;set;}
        public String achAccountName {get;set;}
        public String achAccountNumberMask {get;set;}
        public String achAccountType {get;set;}
        public String achBankName {get;set;}
        /*payment fields*/
        public Decimal Paymentamount {get;set;}
        public String Paymentstatus {get;set;}
        public Boolean PaymentSucces {get;set;}
        
    }
    
    
    public Date convertDate(String d){
        String[] splitDate = d.split('/',0);
        return Date.valueOf(splitDate[2] + '-' + splitDate[0] + '-' + splitDate[1]);
    }
    /**
* Custom Exception for throwing errors
**/
    public class Z_MPPException extends Exception {}
    
    /**
* Method used for VF rerendering purposes
**/
    public void doNothing() {
        
    }
}