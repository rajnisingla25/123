public with sharing class MakePayment extends zqu.ZCheckoutBaseController{
    
    public List<Zuora__ZInvoice__c> zInvoices {get;set;}
    public List<InvoiceSelectorCombo> invoiceSelect {get;set;}
    public List<Zuora__PaymentMethod__c> zPaymentMethods {get;set;}
    public List<Zuora__PaymentMethod__c> zExternalPaymentMethods {get;set;}
    public Zuora__CustomerAccount__c zAccount {get;set;}
    public String zId {get;set;}
    public String billId {get;set;}
    public String accId {get;set;}
    public String pmId {get;set;}
    public String xpmId {get;set;}
    public String id {get;set;}
    public Decimal paymentAmount {get;set;}
    public Decimal invoiceAmount {get;set;}
    public Decimal remainingAmount {get;set;}
    public Zuora__CustomerAccount__c sfAccount;
    public Zuora.zApi zapi = new Zuora.zApi();
    public zqu.NotificationOptions notificationOptions {get;set;}
    public String paymentType {get;set;}
    public String paymentDate {get;set;}
    public Decimal invoiceTotal {get;set;}
    public Boolean isAutopay {get;set;}
    public Boolean isDefault {get;set;}
    public String displayMessage {get;set;}
    public String preset {get;set;}
    public BillingAccountManagerSettings__c userSettings {get;set;}
    public Boolean validate {get; set;}
    public String validateMonth {get;set;}
    public String validateYear {get;set;}

    
    public String ccPageId {get;set;}
    public String achPageId {get;set;}
    public String paymentPage {get;set;}
    
    public String strBIN {get;set;}
    public Boolean validateBIN {get;set;}
    public String pmBIN {get;set;}
      public Boolean isSelectAll {get;set;}
      public Boolean ismoving {get;set;}
    
    /**
        Constructor
    */
    public MakePayment(){
        //Generate notification object and fills in information
        notificationOptions = new zqu.NotificationOptions();
        notificationOptions.isPopup = true;
        notificationOptions.continueAction = 'continueToNextPage();';
        notificationOptions.backLabel = 'Remain';
        notificationOptions.successTitle = 'SUCCESS! Payment method created!';
        
        notificationOptions.failureTitle = 'AN ERROR OCCURRED!';
        paymentType='electronic';

        userSettings = BillingAccountManagerSettings__c.getInstance(UserInfo.getProfileId());
        validate = false;
                
        //Get today's date
        String[] todays = String.valueOf(Date.today()).split('-',0);
        this.paymentDate = todays[1] + '/' + todays[2] + '/' + todays[0];
        System.debug('Today: ' + todays);
        
        //Retrieve Payment Method Id if one exists
        if (System.currentPageReference().getParameters().containsKey('pmId')){
            this.pmId = System.currentPageReference().getParameters().get('pmId');
        } else {
            this.pmId = 'none';
        }
        
        this.validateBIN = false;
        
        //If test is runing, set test data, otherwise, grab information from the URL
        if (System.currentPageReference().getParameters().containsKey('preset')){
            this.preset = System.currentPageReference().getParameters().get('preset');
            pmId='newCard';
            paymentType='electronic';
        }
        else
            this.preset='false';
        if(!Test.isRunningTest()){
            zId = System.currentPageReference().getParameters().get('field_accountId');
            billId = System.currentPageReference().getParameters().get('field_passthrough1');
            accId = System.currentPageReference().getParameters().get('field_passthrough2');
            //Gets random quote from account as one is needed in this object to create a payment method
            List<zqu__Quote__c> quotes = [select Id from zqu__Quote__c where zqu__ZuoraAccountId__c = :zId];
            if (quotes.size() > 0){id = String.valueOf(quotes.get(0).Id);}
        } else {
            zId='zId';
            billId='billId';
            accId='accId';
            id='quoteId';
            pmId='pmId';
            preset='false';
        }
        //Get payment methods, external payment methods, invoice, and current account.
        //Also generated the selector object for the Invoices
        try {
            zPaymentMethods = queryPaymentMethod();
            zExternalPaymentMethods = queryExternalPaymentMethod();
            zInvoices = queryInvoice();
            zAccount = queryAccount();
            generateInvoiceSelect();
          


        } catch(Exception e){
            throw new zqu.ZQException(e.getMessage());
        }
        
        //If display Message exists, display it.
        if (System.currentPageReference().getParameters().containsKey('displayMessage')){
            String displayMessage = System.currentPageReference().getParameters().get('displayMessage');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, displayMessage);
            ApexPages.addMessage(myMsg);
        }

        if (userSettings.UseNewHPM__c == 'Yes'){
        
            List<zqu__HostedPageLiteSetting__c> paymentPages = [Select Name, zqu__Default__c, zqu__PageId__c, zqu__PaymentMethodType__c From zqu__HostedPageLiteSetting__c];
            for (zqu__HostedPageLiteSetting__c page : paymentPages){
                if (page.Name == userSettings.CCPaymentPageName__c){
                    ccPageId = page.zqu__PageId__c;
                } else if (page.Name == userSettings.ACHPaymentPageName__c){
                    achPageId = page.zqu__PageId__c;
                }
            }
            
            paymentPage = 'cc';
        }

        //Set Name of HPM if old HPM is used
        if (userSettings.UseNewHPM__c == 'No')
            this.hostedPageSettingName = 'NewCreditCard';
        //Set various inital values.
        invoiceTotal=0;
        paymentAmount=0;
        invoiceAmount=0;
        remainingAmount=0;
        isAutopay = zAccount.Zuora__AutoPay__c;
        isDefault = false;
        //moving changes
     if(ismoving && accId!=null)
     popultaremainingamount();

    }
     public void popultaremainingamount(){
      List<Case> cases = [SELECT AccountId, Top_Up_Amount__c FROM Case WHERE Type = 'Moving'  AND AccountId = :accId AND Status != 'Closed' AND Top_Up_Amount__c > 0];
        if(cases.size() == 1){
            remainingAmount = cases[0].Top_Up_Amount__c;
        }
   }
  /**
        Query for current Billing Account
    */
    public Zuora__CustomerAccount__c queryAccount(){
        List<Zuora.zObject> accounts;
        if (!Test.isRunningTest()){
            //Login to Zuora
            zapi.zlogin();
        }

        //Create ZOQL query
        String zoql = 'SELECT Name, Account_Type__c, AccountNumber, Id, DefaultPaymentMethodId, AutoPay from Account where Id = \'' + zId + '\'';
        if (!Test.isRunningTest()){
            //Query for payments from Zuora
            accounts = zapi.zquery(zoql);
        } else {
            //Creates test data when needed
            accounts = new List<Zuora.zObject>();
            Zuora.zObject testAccount = new Zuora.zObject('Account');
            testAccount.setValue('Name', 'Name');
            testAccount.setValue('AccountNumber', 'AccountNumber');
            testAccount.setValue('Id', 'Id');
            testAccount.setValue('DefaultPaymentMethodId', 'pmId');
            testAccount.setValue('AutoPay', true);
            accounts = new List<Zuora.zObject>();
            accounts.add(testAccount);
        }       
        
        //Create the sObject and fills it with data from the zObject
        Zuora__CustomerAccount__c acc = new Zuora__CustomerAccount__c();
        acc.put(Zuora__CustomerAccount__c.Name, accounts.get(0).getValue('Name'));
        acc.put(Zuora__CustomerAccount__c.Zuora__AccountNumber__c, accounts.get(0).getValue('AccountNumber'));
        acc.put(Zuora__CustomerAccount__c.Zuora__Zuora_Id__c, accounts.get(0).getValue('Id'));
        acc.put(Zuora__CustomerAccount__c.Zuora__DefaultPaymentMethod__c, accounts.get(0).getValue('DefaultPaymentMethodId'));
        acc.put(Zuora__CustomerAccount__c.Zuora__AutoPay__c, accounts.get(0).getValue('AutoPay'));
        ismoving = false;
       if(String.valueOf(accounts.get(0).getValue('Account_Type__c')) == 'Moving')
        this.ismoving = true;
    
        return acc;
    }
    
    /**
        Converts date from date picker format to code format
    */
    public Date convertDate(String d){
        String[] splitDate = d.split('/',0);
        return Date.valueOf(splitDate[2] + '-' + splitDate[0] + '-' + splitDate[1]);
    }
    
    /**
        Getter for the Options of Payment Methods used by the page in a list
    */
    public List<SelectOption> getPaymentMethodOptions() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('none','-- Select one --'));
        for (Zuora__PaymentMethod__c paymentMethod : zPaymentMethods){
            if(paymentMethod.Zuora__Type__c == 'CreditCard'){
            options.add(new SelectOption(paymentMethod.Zuora__External_Id__c,paymentMethod.Zuora__CreditCardHolderName__c + ', ' + paymentMethod.Zuora__CreditCardType__c + ' (' + paymentMethod.Zuora__CreditCardMaskNumber__c + ')')); 
            }
            if(paymentMethod.Zuora__Type__c == 'ACH'){
            options.add(new SelectOption(paymentMethod.Zuora__External_Id__c,paymentMethod.Zuora__AchAccountName__c + ', ' + paymentMethod.Zuora__AchAccountType__c + ' (' + paymentMethod.Zuora__AchAccountNumberMask__c + '-ACH' + ')')); 
            }
        }
            if (userSettings.AllowCreatePaymentMethodforPayment__c){
            options.add(new SelectOption('newCard','-- Add New Card --'));
            options.add(new SelectOption('newACH','-- Add New ACH --'));
        }
        return options; 
    }
    
    /**
        Getter for the Options of External Payment Methods used by the page in a list
    */
    public List<SelectOption> getExternalPaymentMethodOptions() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('none','-- Select one --'));
        for (Zuora__PaymentMethod__c paymentMethod : zExternalPaymentMethods){
            options.add(new SelectOption(paymentMethod.Zuora__External_Id__c,paymentMethod.Zuora__Name__c)); 
        }
        return options; 
    }

    /**
        Getter for the Options of Payment Methods used by the page in a list
    */
    public List<SelectOption> getValidateMonthOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', 'January (1)')); 
        options.add(new SelectOption('2', 'February (2)')); 
        options.add(new SelectOption('3', 'March (3)')); 
        options.add(new SelectOption('4', 'April (4)')); 
        options.add(new SelectOption('5', 'May (5)')); 
        options.add(new SelectOption('6', 'June (6)')); 
        options.add(new SelectOption('7', 'July (7)')); 
        options.add(new SelectOption('8', 'August (8)')); 
        options.add(new SelectOption('9', 'September (9)')); 
        options.add(new SelectOption('10', 'October (10)')); 
        options.add(new SelectOption('11', 'November (11)')); 
        options.add(new SelectOption('12', 'December (12)')); 
        return options; 
    }

    /**
        Getter for the Options of Payment Methods used by the page in a list
    */
    public List<SelectOption> getValidateYearOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Integer year = System.Today().year();
        for (Integer i=year; i<=(year+10); i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
        }
        return options; 
    }
    
    public PageReference toACH(){
        if (pmId=='newACH')
            if (userSettings.UseNewHPM__c == 'No')
                return new PageReference('/apex/Make_Payment_ACH?field_passthrough2=' + accId + '&field_accountId=' + zId + '&field_passthrough1=' + billId + '&preset=true');
            else
                paymentPage = 'ach';
        else if (pmId=='newCC')
            if (userSettings.UseNewHPM__c == 'Yes')
                paymentPage = 'cc';
        return null;
    }
    
    /**
        Queries Zuora for all Payment Methods for current billing Account
    */
    public List<Zuora__PaymentMethod__c> queryPaymentMethod(){
        List<Zuora.zObject> paymentMethods;
        //Login to Zuora
        if (!Test.isRunningTest()){
            zapi.zlogin();
        }
            
        //Create ZOQL query
        String DeviceSessionId = 'Excluded';
        String zoql = 'SELECT AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, CreditCardHolderName, CreditCardMaskNumber, CreditCardType, CreditCardExpirationMonth, CreditCardExpirationYear, Id, CreditCardAddress1, CreditCardAddress2, CreditCardState, CreditCardCountry, CreditCardPostalCode, CreditCardCity, Type from PaymentMethod where AccountId = \'' + zId + '\' AND DeviceSessionId != \'' + DeviceSessionId + '\' OR AccountId = \'' + zId + '\' AND DeviceSessionId = null';
        
        if (!Test.isRunningTest()){
        //Query for payments from Zuora
        paymentMethods = zapi.zquery(zoql);
        } else {
            //Generate test data for testing when needed
            Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
            tempPm.setValue('CreditCardHolderName','Name');
            tempPm.setValue('CreditCardMaskNumber','Number');
            tempPm.setValue('CreditCardType', 'Type');
            tempPm.setValue('CreditCardExpirationMonth', '1');
            tempPm.setValue('CreditCardExpirationYear', '2020');
            tempPm.setValue('Id','notDefault');
            paymentMethods = new List<Zuora.zObject>();
            paymentMethods.add(tempPm);
            paymentMethods.add(tempPm);
        }
        
        //Creates list of payment method sObjects
        List<Zuora__PaymentMethod__c> ret = new List<Zuora__PaymentMethod__c>();                    
    
        for (Integer i=0; i<paymentMethods.size(); i++){
            Zuora.zObject payment = paymentMethods.get(i);
            //Create the sObject and fills it with data from the zObject and places it into the list
            Zuora__PaymentMethod__c add = new Zuora__PaymentMethod__c();
            add.put(Zuora__PaymentMethod__c.Zuora__Type__c, payment.getValue('Type'));
            add.put(Zuora__PaymentMethod__c.Zuora__AchAccountType__c, payment.getValue('AchAccountType'));
            add.put(Zuora__PaymentMethod__c.Zuora__AchAccountName__c, payment.getValue('AchAccountName'));
            add.put(Zuora__PaymentMethod__c.Zuora__AchAccountNumberMask__c, payment.getValue('AchAccountNumberMask'));
            add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('CreditCardHolderName'));
            add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('CreditCardMaskNumber'));
            add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('CreditCardType'));
            add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
            add.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationMonth__c, String.valueOf(payment.getValue('CreditCardExpirationMonth')));
            add.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationYear__c, String.valueOf(payment.getValue('CreditCardExpirationYear')));
            
            if(payment.getValue('CreditCardExpirationYear') != null && payment.getValue('CreditCardExpirationMonth') != null){
            
            System.Debug('ExpirationMonth: ' + payment.getValue('CreditCardExpirationMonth'));
            
            Date expiration = Date.valueOf(payment.getValue('CreditCardExpirationYear') + '-' + payment.getValue('CreditCardExpirationMonth') + '-1');
            
            expiration = expiration.addMonths(1);
            
            if (expiration < Date.today()){ 
                System.Debug('Not Adding Expired Card To List');
            } else {    
                ret.add(add);
            }
            
            } else {
                ret.add(add);
            }
        }
        
        return ret;
    }
    
    /**
        Queries Zuora for all External Payment Methods on the current tenant.
    */
    public List<Zuora__PaymentMethod__c> queryExternalPaymentMethod(){
        List<Zuora.zObject> paymentMethods;
        //Login to Zuora
        if (!Test.isRunningTest()){
            zapi.zlogin();
        }
            
        //Create ZOQL query
        String zoql = 'SELECT Name, Id from PaymentMethod where name != null';
        
        if (!Test.isRunningTest()){
            //Query for payments from Zuora
            paymentMethods = zapi.zquery(zoql);
        } else {
            //Creates data for testing when needed
            Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
            tempPm.setValue('Name','Name');
            tempPm.setValue('Id','pmId');
            paymentMethods = new List<Zuora.zObject>();
            paymentMethods.add(tempPm);
        }
        
        //Creates list of payment method sObjects
        List<Zuora__PaymentMethod__c> ret = new List<Zuora__PaymentMethod__c>();                    
    
        for (Integer i=0; i<paymentMethods.size(); i++){
            Zuora.zObject payment = paymentMethods.get(i);
            //Create the sObject and fills it with data from the zObject and adds it to the list
            Zuora__PaymentMethod__c add = new Zuora__PaymentMethod__c();
            add.put(Zuora__PaymentMethod__c.Zuora__Name__c, payment.getValue('Name'));
            add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
            ret.add(add);
        }
        
        return ret;
    }
    
    /**
        Queries Zuora for all posted Invoices that still have an open balance (>0)
    */
    public List<Zuora__ZInvoice__c> queryInvoice(){
         //Stores Zuora Created and Effective Date in String
        String strDate;
        
        //Stores the DateTime object created from String value 
        Date dtDate;
        
        List<Zuora.zObject> invoices;
        
        //Create ZOQL query
        String zoql = 'SELECT Amount, Balance, Id, InvoiceDate, InvoiceNumber, DueDate from Invoice where AccountId = \'' + zId + '\' and Balance > 0 and Status = \'Posted\'' ;
        
        if (!Test.isRunningTest()){
            zapi.zlogin();
            invoices = zapi.zquery(zoql);
        } else {
            //Creates data for testing when needed
            Zuora.zObject tempInv = new Zuora.zObject('Invoice');
            tempInv.setValue('InvoiceNumber','Invoice Number');
            tempInv.setValue('Amount',100.00);
            tempInv.setValue('Balance',100.00);
            tempInv.setValue('Id','Id');
            tempInv.setValue('InvoiceDate', DateTime.now());
            tempInv.setValue('DueDate',DateTime.now());
            invoices = new List<Zuora.zObject>();
            invoices.add(tempInv);
        }
        
        //Creates list of invoice sObjects
        // CRM-1964 Limit the number of invoices in Make a Payment to 990
        List<Zuora__ZInvoice__c> ret = new List<Zuora__ZInvoice__c>();
        Integer InvoiceCount = (invoices.size() > 990 ? 990 : invoices.size());
        if(InvoiceCount == 990){
         ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.INFO, 'The page is only displaying the most recent 990 invoices ');
            ApexPages.addMessage(msginfo);
            notificationOptions.successTitle = 'Info';
            }
        for (Integer i=0; i<InvoiceCount; i++){
            Zuora.zObject inv = invoices.get(i);
            //Create the sObject and fills it with data from the zObject and places it into the list
            Zuora__ZInvoice__c add = new Zuora__ZInvoice__c();
            add.put(Zuora__Zinvoice__c.Name, inv.getValue('InvoiceNumber'));
            add.put(Zuora__ZInvoice__c.Zuora__TotalAmount__c, inv.getValue('Amount'));
            add.put(Zuora__ZInvoice__c.Zuora__Balance2__c, inv.getValue('Balance'));
            add.put(Zuora__ZInvoice__c.Zuora__External_Id__c, inv.getValue('Id'));
            
            strDate = String.valueOf(inv.getValue('InvoiceDate'));
            dtDate = Date.valueOf(strDate);
            add.put(Zuora__ZInvoice__c.Zuora__InvoiceDate__c, dtDate);
            //Convert DueDate from Zuora to String to Date
            strDate = String.valueOf(inv.getValue('DueDate'));
            dtDate = Date.valueOf(strDate);
            add.put(Zuora__ZInvoice__c.Zuora__DueDate__c, dtDate);
            ret.add(add);
        }
        
        return ret;
    }
    
    /**
        Generates a InvoiceSelectorCombo list, which holds various data including Invoices,
        selection boolean, and computed values used on the page.
    */
    public void generateInvoiceSelect(){
        this.invoiceSelect = new List<InvoiceSelectorCombo>();
        for (Integer i=0; i<zInvoices.size(); i++){
            this.invoiceSelect.add(new InvoiceSelectorCombo(zInvoices.get(i), i));
        }
    }
    
    /**
        Creates the two options for the payment type (External/Electronic)
    */
    public List<SelectOption> getPaymentTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        //Removing external payment option based on LEAP 5637 
        //options.add(new SelectOption('external','External Payment')); 
        options.add(new SelectOption('electronic','Electronic Payment')); 
        return options; 
    }
    
    /**
        Makes the Payment.
    */  
    public PageReference makePaymentNow(){
        Zuora.zObject payment = new Zuora.zObject('Payment');
        
        List<Case> cases = [SELECT
                                AccountId,
                                CaseNumber,
                                OwnerId
                            FROM
                                Case
                            WHERE
                                Type = 'Collections'
                            AND
                                AccountId = :accId
                            AND
                                Status != 'Closed'
                            AND
                                Status != 'New'];
        if(cases.size() == 1){
            List<User> usrs = [Select Username From User Where Id=:cases[0].OwnerId];
            if (!usrs.isEmpty())
                payment.setValue('SalesforceCollectionsCaseOwner__c', usrs[0].Username);
            else {
                List<Group> queues = [Select Name From Group Where Id=:cases[0].OwnerId];
                if (!queues.isEmpty())
                    payment.setValue('SalesforceCollectionsCaseOwner__c', queues[0].Name);
            }
            payment.setValue('SalesforceCollectionsCaseNumber__c', cases[0].CaseNumber);
        } else if (cases.size() > 1){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'More than 1 Open or Escalated Case has been found.  Only 1 open or escalated collections case can be on an account at any time.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        payment.setValue('SalesforceCollectionsRepUsername__c', UserInfo.getUserName());
        
        System.debug('paymentAmount: ' + paymentAmount + ' | remainingAmount: ' + remainingAmount);
        if (paymentType == 'electronic'){
            payment.setValue('AccountId', zId);
            payment.setValue('Amount', paymentAmount);
            payment.setValue('Comment', 'Create Payment using Invoice Payment Data');
            payment.setValue('AppliedCreditBalanceAmount', remainingAmount);
            payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateonly(convertDate(paymentDate)));
            payment.setValue('PaymentMethodId', pmId);
            payment.setValue('ZPaymentMethodId__c', pmId);
            payment.setValue('Type', 'Electronic');
        } else if (paymentType == 'external'){
            payment.setValue('AccountId', zId);
            payment.setValue('Amount', paymentAmount);
            payment.setValue('Comment', 'Create Payment using Invoice Payment Data');
            payment.setValue('AppliedCreditBalanceAmount', remainingAmount);
            payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateonly(convertDate(paymentDate)));
            payment.setValue('PaymentMethodId', xpmId);
            payment.setValue('Type', 'External');
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Payment Type selected!  Please specify a payment type.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        payment.setValue('Status', 'Processed');
        payment.setValue('OneTimePayment__c', 'True');
            
        try{
            
            List<Zuora.zApi.SaveResult> results;
            /*
            if (!Test.isRunningTest()){
                zapi.zlogin();
                results = zapi.zcreate(objs);
            } else {
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                results.add(res);
            }
            String pId;
            
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText;
                    if (Test.isRunningTest())
                        break;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment | ' + errorText);
                    ApexPages.addMessage(myMsg);
                    return null;
                } else {
                    pId = result.Id;
                }
            }
            */
            
            List<Zuora.zObject> invoicePayments = new List<Zuora.zObject>();
            Zuora.zObject ip;
            for (InvoiceSelectorCombo isc : invoiceSelect){
                system.debug('[TP]=========> Selected: ' + isc.isSelected + ', Amount applied: ' + isc.appliedAmount);
                if (isc.isSelected){
                    ip = new Zuora.zObject('InvoicePayment');
                    ip.setValue('Amount', isc.appliedAmount);
                    ip.setValue('InvoiceId', isc.Invoice.Zuora__External_Id__c);
                    //ip.setValue('PaymentId', pId);
                    invoicePayments.add(ip);
                }
            }
            if ( !invoicePayments.isEmpty()){
                /*
                if (!Test.isRunningTest()){
                    results = zapi.zcreate(invoicePayments);
                } else {
                    Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                    res.Success = false;
                    Zuora.zObject error = new Zuora.zObject('Error');
                    res.errors = new Zuora.zObject[]{error};
                    results = new List<Zuora.zApi.SaveResult>{};
                    results.add(res);
                }
                for (Zuora.zApi.SaveResult result : results){
                    if (!result.Success){
                        Zuora.zObject[] errors = result.errors;
                        String errorText;
                        if (Test.isRunningTest())
                            break;
                        for (Zuora.zObject error : errors) {
                            errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';
                        }
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment | ' + errorText);
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                */
                system.debug('[TP]============> Invoice Payments: ' + invoicePayments);
                Zuora.zObject invoicePaymentData = new Zuora.zObject('InvoicePaymentData');
                invoicePaymentData.setValue('InvoicePayment', invoicePayments);
                payment.setValue('InvoicePaymentData', invoicePaymentData);
            }
            
            List<Zuora.zObject> objs = new List<Zuora.zObject>{payment};
        
            System.debug('[TP]==========> Payments list: ' + objs);
            /*
            Zuora.zObject paymentUpdate = new Zuora.zObject('Payment');
            paymentUpdate.setValue('Id', pId);
            paymentUpdate.setValue('Status', 'Processed');
        
            List<Zuora.zObject> obj = new List<Zuora.zObject>{paymentUpdate};
            */
            if (!Test.isRunningTest()){
                //results = zapi.zupdate(obj);
                results = zapi.zcreate(objs);
            } else {
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                results.add(res);
            }
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText = '';
                    if (Test.isRunningTest())
                        break;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment | ' + errorText);
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
        } catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }

    public void openValidation(){
        validate = true;
    }
    /**
     * This method finds out whether BIN validation is required for selected payment method
     * if BIN validation is required then it sets validateBIN flag to true
     */
    public PageReference openBINValidation(){
        this.pmBIN = '';
        this.strBIN = '';
        System.debug('>>PaymentMethodID::' + pmId);
        if(this.pmId != 'none'){
            List<Zuora__PaymentMethod__c> payMethod = [SELECT Zuora__BankIdentificationNumber__c 
                FROM Zuora__PaymentMethod__c WHERE Zuora__External_Id__c =:pmId];
            if(!payMethod.isEmpty()){
                System.debug('Payment Method Found');
                this.pmBIN = payMethod.get(0).Zuora__BankIdentificationNumber__c;
                System.debug('pmBIN::' + pmBIN);
                List<PaymentProfiles__c> payProfiles = [SELECT SplitPercentage__c FROM PaymentProfiles__c
                    WHERE PaymentMethodId__c =:pmId];
                if (!payProfiles.isEmpty()){
                    System.debug('Payment Profile Found, split%::' + payProfiles.get(0).SplitPercentage__c );
                    if(payProfiles.get(0).SplitPercentage__c == 0){
                        this.validateBIN = true;
                        System.debug('BIN Validation required');
                    }else{
                        this.validateBIN = false;
                        System.debug('BIN Validation not required');
                        return makePaymentNow();
                    }
                }else{
                    System.debug('BIN Validation required');
                    this.validateBIN = true;
                }
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Payment Type selected!  Please specify a payment type.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }
    /**
     * This method cancels the BIN validation
     */
    public void cancelBINValidation(){
        this.validateBIN = false;
    }

    public void cancelValidation(){
        validate = false;
    }

    public PageReference validateInfo(){
        Zuora__PaymentMethod__c selectedPM;
        for (Zuora__PaymentMethod__c pm : zPaymentMethods){
            if (pm.Zuora__External_Id__c == pmId){
                selectedPm = pm;
                break;
            }
        }
        if (!Test.isRunningTest() && (validateMonth != selectedPm.Zuora__CreditCardExpirationMonth__c || validateYear != selectedPm.Zuora__CreditCardExpirationYear__c)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error!  Incorrect Expiration Date.  Please enter the correct expiration Date.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return makePaymentNow();
    }
    /**
     * This method compares the entered BIN value with the BIN value on PaymentMethod
     */
    public PageReference validatePmBIN(){
  
        System.debug('Inside validatePmBIN pmBIN::' + pmBIN);
        System.debug('Inside validatePmBIN strBIN::' + strBIN);

        if(strBIN != '' && (strBIN.compareTo(pmBIN.substring(0,4))) == 0){
            System.debug('BIN Validation is successful');
            validateBIN = false;
            return makePaymentNow();
        }
        else{
            System.debug('BIN Validation failed');
            strBIN = '';
            validateBIN = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error!  Incorrect BIN.  Please enter the correct BIN.');
            ApexPages.addMessage(myMsg);
            return null;
        }
   
    }
    
    /**
        These actions are performed if the callback is successful.
        
        This function updates the Default Payment Method (if checked) and sets AutoPay to
        true or false based on whether it is checked or not.
    */
    public PageReference successActions(){
        if(!Test.isRunningTest()){  
            //Retrieve PaymentMethod Id and return message from the callback.
            displayMessage = ApexPages.currentPage().getParameters().get('displayMessage');
        }
        
        //Created and sets the values for the Account that gets updated.
        Zuora.zObject acc = new Zuora.zObject('Account');
        acc.setValue('Id', zId);
        //If isDefault is checked, it changes the Account's Default Payment Method
        if (isDefault){
            acc.setValue('DefaultPaymentMethodId', pmId);
        }
        //Sets the Account's AutoPay value to that of isAutoPay
        acc.setValue('AutoPay', isAutopay);
        try {
            List<Zuora.zObject> listAcc = new List<Zuora.zObject>{acc};
            //Login to Zuora and update Account with new Default Payment Method
            List<Zuora.zApi.SaveResult> results;
            if(!Test.isRunningTest()){
                zapi.zlogin();
                results = zapi.zupdate(listAcc);
            } else {
                //Create sample result for testing
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                results.add(res);
            }
            //Catches results and parses through for errors
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + String.valueOf(error.getValue('Code')) + ': ' + String.valueOf(error.getValue('Message')) + '\n';
                    }
                    displayMessage = displayMessage + ' | ' + errorText;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment |' + displayMessage);
                    ApexPages.addMessage(myMsg);
                }
            }
        } catch(Exception e){
            //Throws error if exception occurs
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        return makePaymentNow();
    }
     /* This method calls when user click on Select All button */
     
     public void SelectAll()
     {
        isSelectAll = true;
        updateInvoiceTotal();
        isSelectAll = false;
     }  
    /**
        Update invoice total when checks/unchecks occur
    */
    public void updateInvoiceTotal(){
        //clears any current messeges
        ApexPages.getMessages().clear();
        
        //resets invoice total to 0
        invoiceTotal = 0.00;
        
        //Goes through all invoices
        for (InvoiceSelectorCombo is : invoiceSelect){
        
         // Added if condition when user click on Select All button
          if(isSelectAll == true)
          {
             is.isSelected = true;
          }
            //If invoice is selected
            if (is.isSelected){
                //and amount applied is 0
                if (is.appliedAmount==0){
                    //sets applied amount remaining balance on invoice
                    is.appliedAmount = is.Invoice.Zuora__Balance2__c;
                }
                //Adds this value to invoice total and payment amount
                invoiceTotal += is.appliedAmount;
                paymentAmount += is.appliedAmount;
            } else if (!is.isSelected && is.appliedAmount!=0){
                //If something is de-selected and its value is not 0, it's value gets set to 0
                //and that value is removed from the payment amount.
                paymentAmount -= is.appliedAmount;
                is.appliedAmount=0.00;
            }
        }
        
        //Updates remaing values depending on external or electronic
        if (paymentType=='external'){
            updateRemaining();
        } else if (paymentType=='electronic'){
            updateTotal();
        }
    }
    
    /**
        Update values when applied invoice amounts are changed.
    */
    public void updateValues(){
        //Resets invoice total to 0.
        invoiceTotal = 0.00;
        
        //Goes through each invoice
        for (InvoiceSelectorCombo is : invoiceSelect){
            //if it is selected
            if (is.isSelected){
                //and it's value is changed to 0
                if (is.appliedAmount==0){
                    //de-select and continue to next invoice
                    is.isSelected = false;
                    continue;
                }
                //Add the value of invoice to invoice total
                invoiceTotal += is.appliedAmount;
            } else if (!is.isSelected && is.appliedAmount != 0){
                //If it is not selected and it's value was set to a non-0 value select it
                //and update invoice total and payment amount.
                is.isSelected = true;
                paymentAmount+=is.appliedAmount;
                invoiceTotal += is.appliedAmount;
            }
        }
        //If the total value of invoices is greater than total payment amount, set
        //the payment amount to the invoice total
        if (invoiceTotal > paymentAmount)
            paymentAmount = invoiceTotal;
        
        //Updates remaing values depending on external or electronic
        if (paymentType=='external'){
            updateRemaining();
        } else if (paymentType=='electronic'){
            updateTotal();
        }
    }
    
    /**
        Confirm error and clears error messages.
    */
    public void confirmError(){
        ApexPages.getMessages().clear();
    }
    
    /**
        Update remaining amount value (to be applied to credit balance)
    */
    public void updateRemaining(){
        if (paymentAmount > invoiceTotal){
            invoiceAmount = invoiceTotal;
        } else {
            invoiceAmount = paymentAmount;
        }
        remainingAmount = paymentAmount-invoiceAmount;
    }
    
    /**
        Update Total payment Amount
    */
    public void updateTotal(){
        invoiceAmount = invoiceTotal;
        paymentAmount = invoiceAmount + remainingAmount;
    }
    
    /**
        Update date to today is electronic payment option is selected.
        Selected pmId is also reset to none
    */
    public void updateDate(){
        if (paymentType=='electronic'){
            String[] todays = String.valueOf(Date.today()).split('-',0);
            this.paymentDate = todays[1] + '/' + todays[2] + '/' + todays[0];
        }
        pmId = 'none';
    }
    
    /**
        default method for extended class
    */
    public override PageReference getPageRef() {
        setPageRef(Page.Make_Payment);
        return Page.Make_Payment;
    }
        
    /**
        Set inital values for certain values, including a few passthrough values
        one that specifies value retention.
    */ 
    public override Map<String, String> getExtraParameters() {
        return new Map<String,String> {
        'field_useDefaultRetryRule' => 'true',
        'field_accountId' => zId,
        'retainValues' => 'true',
        'field_passthrough1' => billId,
        'field_passthrough2' => accId
      };
    }
    
    /**
        Two required overrides as the page does not work without them.
    */
    public override string getBackURL(){
        return '';
    }
      
    public override string getNextURL(){
        return '';
    }
    
    /**
        Cancel button to navigate back
    */
    public override PageReference navigateBack(){
        return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }
    
    public PageReference cancel(){
        return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }
    
    /**
        Object that holds various data, including an invoice, a boolean representing selection, and
        the applied amount for the invoice (and setter validation preventing over-setting the value)
    */
    public class InvoiceSelectorCombo{
        public Zuora__ZInvoice__c Invoice {get;set;}
        public Boolean isSelected {get;set;}
        public Decimal appliedAmount 
                                    {get;
                                        set{
                                            if (value > Invoice.Zuora__Balance2__c){
                                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Payment Amount higher than Balance!  Value set to current remaining balance.');
                                                ApexPages.addMessage(myMsg);
                                                appliedAmount = Invoice.Zuora__Balance2__c;
                                            } else
                                                appliedAmount = value;
                                        }
                                    }
        
        public InvoiceSelectorCombo(Zuora__ZInvoice__c i, Integer s){
            Invoice = i;
            isSelected = false;
            appliedAmount=0;
            if (Test.isRunningTest())
                isSelected = true;
        }
    }
}