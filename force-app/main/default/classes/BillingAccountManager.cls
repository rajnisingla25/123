public with sharing class BillingAccountManager {
    
    public String zId {get;set;}
    public String billId {get;set;}
    public String accId {get;set;}
    public Zuora__CustomerAccount__c sfAccount;
    public Zuora__CustomerAccount__c zAccount {get;set;}
    public List<Zuora__PaymentMethod__c> zPaymentMethods;
    transient public List<Zuora.zObject> payments;
    public List<PaymentSelectorCombo> paymentSelect {get;set;}
    public String paymentFrom {get;set;}
    public String paymentTo {get;set;}
    public Integer index {get;set;}
    public zqu.NotificationOptions notificationOptions {get;set;}
    public String paymentMethodRefundId {get;set;}
    public String paymentRefundId {get;set;}
    public List<Zuora__Payment__c> zPayments;
    public List<Zuora__Payment__c> viewedPayments {get;set;}
    public List<Zuora__PaymentMethod__c> externalPaymentMethods {get;set;}
    public BillingAccountManagerSettings__c userSettings {get;set;}
    
    /*Zuora API Instance for calling into Zuora directly */
    static Zuora.zApi zapi = new Zuora.zApi();
    
    /**
    *  Constructor
    */
    public BillingAccountManager(ApexPages.StandardController controller) {
        //Instantiate and fill out information related to the pop-up notification
        notificationOptions = new zqu.NotificationOptions();
        notificationOptions.isPopup = true;
        notificationOptions.continueAction = 'continueToNextPage();';
        notificationOptions.backLabel = 'Remain';
        notificationOptions.successTitle = 'SUCCESS!  Payment Method Created!';
        notificationOptions.failureTitle = 'AN ERROR OCCURRED!';

        userSettings = BillingAccountManagerSettings__c.getInstance(UserInfo.getProfileId());
        
        //Sets inital index to -1 (View all)
        index = -1;
        //Sets the from and to dates for the payment view.
        String[] oneMonth = String.valueOf(Date.today().addDays(-14)).split('-',0);
        this.paymentFrom = oneMonth[1] + '/' + oneMonth[2] + '/' + oneMonth[0];
        String[] todays = String.valueOf(Date.today()).split('-',0);
        this.paymentTo = todays[1] + '/' + todays[2] + '/' + todays[0];
        //Get Important Ids from url
        this.billId = System.currentPageReference().getParameters().get('id');
       
        //Get Accounts from SalesForce
        if (!Test.isRunningTest())
            this.sfAccount = ([SELECT Name, Zuora__AccountNumber__c, Zuora__Account__c, Zuora__Zuora_Id__c, Zuora__CreditCardNumber__c, Zuora__DefaultPaymentMethod__c from Zuora__CustomerAccount__c where Id = :billId ]).get(0);
        else{
            this.sfAccount = new Zuora__CustomerAccount__c();
            Account tempAcc = Z_TestFactory.makeAccount();
            sfAccount.Zuora__Zuora_Id__c = 'zId';
            sfAccount.Zuora__Account__c = tempAcc.Id;
            this.billId = 'billId';
        }
        //Retrieve important values from the SF account
        this.zId = sfAccount.Zuora__Zuora_Id__c;
        this.accId = sfAccount.Zuora__Account__c;
        //Query for the current billing account
        this.zAccount = queryAccount();
        this.zPaymentMethods = new List<Zuora__PaymentMethod__c>();
        try{
            //Get Payment Methods from Zuora and generates the selector Objects
            this.zPaymentMethods = queryPaymentMethod();
            this.externalPaymentMethods = queryExternalPaymentMethod();
            generatePaymentSelect();
            
        } catch(Exception e){
            //create empty payment list and selector list if error occurs
            this.paymentSelect = new List<PaymentSelectorCombo>();
        }
        //Grab past payments from Zuora Database and converts them to SF versions
        try{
            payments = queryPayment();
            system.debug('payments :' + payments.size());
            convertPayments();
            selectIndex();
        } catch(Exception e) {
            //Throw exception is Zuora error occurs
            throw new zqu.ZQException(e.getMessage());
        }
        
        //If a display message exists from another page, display it upon page load.
        if (System.currentPageReference().getParameters().containsKey('displayMessage')){
            String displayMessage = System.currentPageReference().getParameters().get('displayMessage');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, displayMessage);
            ApexPages.addMessage(myMsg);
        }
    }
    
    /**
        Queries Zuora for the current Billing Account
    */
    public Zuora__CustomerAccount__c queryAccount(){
        List<Zuora.zObject> accounts;
        if (!Test.isRunningTest()){
            //Login to Zuora
            zapi.zlogin();
        }

        //Create ZOQL query
        String zoql =
            'SELECT Name, AccountNumber, Id, DefaultPaymentMethodId FROM Account WHERE Id = \'' + zId + '\'';
        if (!Test.isRunningTest()){
            //Query for payments from Zuora
            accounts = zapi.zquery(zoql);
        } else {
            //Create test data for testing if needed
            accounts = new List<Zuora.zObject>();
            Zuora.zObject testAccount = new Zuora.zObject('Account');
            testAccount.setValue('Name', 'Name');
            testAccount.setValue('AccountNumber', 'AccountNumber');
            testAccount.setValue('Id', 'Id');
            testAccount.setValue('DefaultPaymentMethodId', 'pmId');
            accounts = new List<Zuora.zObject>();
            accounts.add(testAccount);
        }       
       
        //Create the sObject and fills it with data from the zObject
        Zuora__CustomerAccount__c acc = new Zuora__CustomerAccount__c();
        if(accounts.size() > 0)
        {
            acc.put(Zuora__CustomerAccount__c.Name, accounts.get(0).getValue('Name'));
            acc.put(Zuora__CustomerAccount__c.Zuora__AccountNumber__c, accounts.get(0).getValue('AccountNumber'));
            acc.put(Zuora__CustomerAccount__c.Zuora__Zuora_Id__c, accounts.get(0).getValue('Id'));
            acc.put(Zuora__CustomerAccount__c.Zuora__DefaultPaymentMethod__c, accounts.get(0).getValue('DefaultPaymentMethodId'));
        }        
    
        return acc;
    }
    
    /**
        Queries Zuora for all Payment Methods in the current Billing Account that are Credit Cards
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
        //String zoql = 'SELECT AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, CreditCardHolderName, CreditCardMaskNumber, CreditCardType, CreditCardExpirationMonth, CreditCardExpirationYear, Id, CreditCardAddress1, CreditCardAddress2, CreditCardState, CreditCardCountry, CreditCardPostalCode, CreditCardCity, Type from PaymentMethod where AccountId = \'' + zId + '\'';
        
        if (!Test.isRunningTest()){
        //Query for payments from Zuora
        System.Debug('zoql: ' + zoql);
        paymentMethods = zapi.zquery(zoql);
        System.Debug('paymentMethods size: ' + paymentMethods.size());
        System.Debug('paymentMethods: ' + paymentMethods);
        } else {
            //Create test data if needed for testing
            Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
            tempPm.setValue('CreditCardHolderName','Name');
            tempPm.setValue('CreditCardMaskNumber','Number');
            tempPm.setValue('CreditCardType','Type');
            tempPm.setValue('CreditCardExpirationMonth','01');
            tempPm.setValue('CreditCardExpirationYear','2014');
            tempPm.setValue('Id','notDefault');
            tempPm.setValue('CreditCardAddress1','Address');
            tempPm.setValue('CreditCardAddress2','Address');
            tempPm.setValue('CreditCardCity','City');
            tempPm.setValue('CreditCardState','State');
            tempPm.setValue('CreditCardCountry','Country');
            tempPm.setValue('CreditCardPostalCode','PCode');
            tempPm.setValue('Type', 'CreditCard');
            paymentMethods = new List<Zuora.zObject>();
            paymentMethods.add(tempPm);
            paymentMethods.add(tempPm);
        }
        //CRM-2199
        Map<String ,PaymentProfiles__c> Paymentprofilemap =  new Map<String ,PaymentProfiles__c>();
        List<PaymentProfiles__c> Paymentprofiles = [Select Id,PaymentMethodId__c, SplitPercentage__c From  PaymentProfiles__c where Account__c = :accId];
        for(PaymentProfiles__c inloop: Paymentprofiles){
           if(inloop.PaymentMethodId__c!=null)
           Paymentprofilemap.put(inloop.PaymentMethodId__c , inloop);            
        }
        
        //Gets the Default Payment Method Id if one exists.
        String def;
        if (zAccount.Zuora__DefaultPaymentMethod__c != null)
            def = zAccount.Zuora__DefaultPaymentMethod__c; 
        else
            def = '';
        
        //Create the list of payment method sObjects
        List<Zuora__PaymentMethod__c> ret = new List<Zuora__PaymentMethod__c>();                    
    
        for (Integer i=0; i<paymentMethods.size(); i++){
            Zuora.zObject payment = paymentMethods.get(i);
            //Create the sObject and fills it with data from the zObject and then adds it to the list.
            Zuora__PaymentMethod__c add = new Zuora__PaymentMethod__c();
            if (payment.getValue('Type') == 'CreditCard'){
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('CreditCardHolderName'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('CreditCardMaskNumber'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('CreditCardType'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationMonth__c, String.valueOf(payment.getValue('CreditCardExpirationMonth')));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationYear__c, String.valueOf(payment.getValue('CreditCardExpirationYear')));
                add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
                if(Paymentprofilemap.containskey(string.valueof(payment.getValue('Id'))))
                add.put(Zuora__PaymentMethod__c.SplitPercentage__c, Paymentprofilemap.get(string.valueof(payment.getValue('Id'))).SplitPercentage__c);
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardAddress1__c , payment.getValue('CreditCardAddress1'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardAddress2__c , payment.getValue('CreditCardAddress2'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardCity__c , payment.getValue('CreditCardCity'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardState__c , payment.getValue('CreditCardState'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardPostalCode__c , payment.getValue('CreditCardPostalCode'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardCountry__c , payment.getValue('CreditCardCountry'));
                add.put(Zuora__PaymentMethod__c.Zuora__Type__c, payment.getValue('Type'));
            } else if (payment.getValue('Type') == 'ACH'){
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('AchAccountName'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('AchAbaCode') + ' ' + payment.getValue('AchAccountNumberMask'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('AchAccountType'));
                add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
                add.put(Zuora__PaymentMethod__c.Zuora__CreditCardCountry__c , payment.getValue('AchBankName'));
                add.put(Zuora__PaymentMethod__c.Zuora__Type__c, payment.getValue('Type'));
            }
            if (add.Zuora__External_Id__c == def){
                add.put(Zuora__PaymentMethod__c.Zuora__DefaultPaymentMethod__c, true);
            } else {
                add.put(Zuora__PaymentMethod__c.Zuora__DefaultPaymentMethod__c, false);
            }
            ret.add(add);
        }
        
        return ret;
    }
    
    /**
        Queries Zuora for all Payment Methods of the current Zuora tenant that are External Payment Methods
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
            //Fill with testing data when testing
            Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
            tempPm.setValue('Name','Name');
            tempPm.setValue('Id','pmId');
            paymentMethods = new List<Zuora.zObject>();
            paymentMethods.add(tempPm);
        }
        
        //Creates the list of payment method sObjects
        List<Zuora__PaymentMethod__c> ret = new List<Zuora__PaymentMethod__c>();                    
    
        for (Integer i=0; i<paymentMethods.size(); i++){
            Zuora.zObject payment = paymentMethods.get(i);
            //Create the sObject and fills it with data from the zObject and adds it to the list
            Zuora__PaymentMethod__c add = new Zuora__PaymentMethod__c();
            add.put(Zuora__PaymentMethod__c.Zuora__Name__c, payment.getValue('CreditCardHolderName'));
            add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
            ret.add(add);
        }
        
        return ret;
    }
        
    /**
        Queries Zuora for all payments associated with the current Billing Account
    */
    public List<Zuora.zObject> queryPayment(){
        if (!Test.isRunningTest()){
            zapi.zlogin();
        }
       //CRM-3342 - Error on Billing Account Manager when the account has more than 2000 payment records start.
        //Create ZOQL query
      String[] oneMonth = String.valueOf(Date.today().addDays(-180)).split('-',0);
      String eftdate = oneMonth[0] + '-' + oneMonth[1] + '-' + oneMonth[2];
       //String zoql = 'SELECT Amount, Status, RefundAmount, PaymentNumber, CreatedDate, EffectiveDate, PaymentMethodId, Id from Payment where AccountId = \'' + zId + '\'';
        //String eftdate =  '2018-02-15';
     String zoql = 'SELECT Amount, Status, RefundAmount, PaymentNumber, CreatedDate, EffectiveDate, PaymentMethodId, Id from Payment where AccountId = \'' + zId + '\' and EffectiveDate >= \'' + eftdate + '\'';
       // CRM-3342 End Error on Billing Account Manager when the account has more than 2000 payment records.
        if (!Test.isRunningTest()){
            //Query for payments from Zuora          
                   return zapi.zquery(zoql);                     
        } else {
            //Generate temporary data for testing when needed
            List<Zuora.zObject> tempPaymentList = new List<Zuora.zObject>();
            Zuora.zObject tempPayment = new Zuora.zObject('Payment');
            tempPayment.setValue('Amount',100.00);
            tempPayment.setValue('RefundAmount', 0.00);
            tempPayment.setValue('PaymentNumber','PaymentNumber');
            tempPayment.setValue('CreatedDate',DateTime.now());
            tempPayment.setValue('EffectiveDate',DateTime.now());
            tempPayment.setValue('PaymentMethodId','pmId');
            tempPayment.setValue('Id', 'pId');
            tempPayment.setValue('Status', 'Processed');
            tempPaymentList.add(tempPayment);
            return tempPaymentList;
        }
    }
    
    /**
        Genreate the PaymentSelectorObject needed for the page that allows the user to pick
        different options from the UI in terms of payment methods.
    */
    public void generatePaymentSelect(){
        this.paymentSelect = new List<PaymentSelectorCombo>();
        for (Integer i=0; i<zPaymentMethods.size(); i++){
            //Adds in each payment method from the billing account
            this.paymentSelect.add(new PaymentSelectorCombo(zPaymentMethods.get(i), i));
            if (zPaymentMethods.get(i).Zuora__DefaultPaymentMethod__c)
                index = i;
        }
        //Adds in two more "payment methods"
        //One for non-electronic payment methods and one for all payment methods (both electronic and non)
        Zuora__PaymentMethod__c tempPm = new Zuora__PaymentMethod__c();
        tempPm.Zuora__CreditCardHolderName__c = ' View Payments for';
        tempPm.Zuora__CreditCardCountry__c = 'Other Non-Electronic Payment Methods';
        this.paymentSelect.add(new PaymentSelectorCombo(tempPm,-2));
        tempPm.Zuora__CreditCardCountry__c = 'All Payment Methods';
        this.paymentSelect.add(new PaymentSelectorCombo(tempPm,-1));
        
    }
    
    /**
        Getter for the Billing Account
    */
    public Zuora__CustomerAccount__c getBillingAccount(){
        return sfAccount;
    }
    
    /**
        Getter for Payment Methods w/ attached data for radiobutton and index values
    */
    public List<PaymentSelectorCombo> getPaymentMethods(){
        return paymentSelect;
    }
    
    /**
        Navigate to Add Card Page
    */
    public PageReference addCard(){
        PageReference pr = new PageReference('/apex/New_Credit_Card?field_passthrough2=' + accId + '&field_accountId=' + zId + '&field_passthrough1=' + billId);
        return pr;
    }
        
    /**
        Converts Payments from zObject to sObject and adds them to the current list of 
        view payments if they fall between the to and from dates.
    */
    public void convertPayments(){
        //Stores Zuora Created and Effective Date in String
        String strDate;
        
        //Stores the DateTime object created from String value 
        DateTime dtDate;
        Date effectiveDate;
        zPayments = new List<Zuora__Payment__c>();
        viewedPayments = new List<Zuora__Payment__c>();
        
        String zoql = 'SELECT InvoiceId, PaymentId from InvoicePayment where PaymentId = ';
        //Iterate through the list of Payments
        for (Integer i=0; i<payments.size(); i++){
            //Get the current zObject payment iteration
            Zuora.zObject payment = payments.get(i);
            //Create the sObject and fills it with data from the zObject
            Zuora__Payment__c add = new Zuora__Payment__c();
            add.put(Zuora__Payment__c.Zuora__Amount__c, payment.getValue('Amount'));
            add.put(Zuora__Payment__c.Zuora__PaymentNumber__c, payment.getValue('PaymentNumber'));
            
            
            //Convert Created Date from Zuora to String to DateTime 
             strDate = String.valueOf(payment.getValue('CreatedDate'));
             dtDate = DateTime.valueOf(strDate);
             String temp = dtDate.format('yyyy-MM-dd HH:mm:ss','PST'); //Added for CRM-4316
             DateTime ZcreatedDate = DateTime.valueOfGMT(temp); //Added for CRM-4316
             add.put(Zuora__Payment__c.Zuora__CreatedDate__c, ZcreatedDate);
                           
            //add.put(Zuora__Payment__c.Zuora__CreatedDate__c, payment.getValue('CreatedDate'));
            //Convert Effective Date from Zuora to String to DateTime 
            strDate = String.valueOf(payment.getValue('EffectiveDate'));
            effectiveDate = Date.valueOf(strDate);
            add.put(Zuora__Payment__c.Zuora__EffectiveDate__c, effectiveDate);
            //add.put(Zuora__Payment__c.Zuora__EffectiveDate__c, payment.getValue('EffectiveDate'));
            add.put(Zuora__Payment__c.Zuora__PaymentMethod__c, payment.getValue('PaymentMethodId'));
            add.put(Zuora__Payment__c.Zuora__External_Id__c, payment.getValue('Id'));
            add.put(Zuora__Payment__c.Zuora__Status__c, payment.getValue('Status'));
            add.put(Zuora__Payment__c.Zuora__AppliedCreditBalanceAmount__c, payment.getValue('RefundAmount'));
            //Iterate through the Payment Methods to find associated Payment Method
            zPayments.add(add);
            if (Date.valueOf(add.Zuora__EffectiveDate__c) < convertDate(paymentTo).addDays(1) && Date.valueOf(add.Zuora__EffectiveDate__c) >= convertDate(paymentFrom))
                viewedPayments.add(add);
        }
    }
    
    /**
        Converts date from the format created from the date chooser to the one used in code.
    */
    public Date convertDate(String d){
        String[] splitDate = d.split('/',0);
        return Date.valueOf(splitDate[2] + '-' + splitDate[0] + '-' + splitDate[1]);
    }
    
    /**
        Navigate to the Edit Credit Card page
    */
    public PageReference editCards(){
        if (Test.isRunningTest()){
            index=0;
        }
        //If no card is chosen, return error message
        if (index < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No editable Payment Method selected!  Please choose a Payment method that can be edited.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Get Payment method chosen
        Zuora__PaymentMethod__c pm = paymentSelect.get(index).PaymentMethod;
        
        if (pm.Zuora__Type__c == 'ACH'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'ACH cannot be editted.  Please choose a different Payment Method!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        PageReference pr = new PageReference('/apex/Edit_Card?id=' + accId + '&zID=' + zId + '&billId=' + billId + '&pmId=' + pm.Zuora__External_Id__c);
        return pr;
    }
    
    /**
        Deletes the selected Payment Method
    */
    public PageReference deleteCards(){
        if (Test.isRunningTest()){
            //sets value for testing
            index=0;
        }
        //If no card is chosen, return error message
        if (index < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No applicable Payment Method selected!  Please choose a Payment method that can be deleted.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Get Payment method chosen
        Zuora__PaymentMethod__c pm = paymentSelect.get(index).PaymentMethod;
        //If Payment Method chosen is default, return error message
        if(pm.Zuora__DefaultPaymentMethod__c == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot delete default payment method!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Get Zuora Id of the Payment Method being deleted and holds it in an Array
        string obj = String.valueOf(pm.Zuora__External_Id__c);
        string[] toDelete = new string[]{obj};
        List<Zuora.zApi.DeleteResult> results;
        try {
            //Logs into Zuora and deletes the Payment method in Zuora
            if (!Test.isRunningTest()){
                zapi.zlogin();
                results = zapi.zdelete('PaymentMethod', toDelete);
            } else {
                //Create data for testing if needed
                Zuora.zApi.DeleteResult res = new Zuora.zApi.DeleteResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.DeleteResult>{};
                results.add(res);
            }
            //Checks results for failues and displays error if they occurs
            for (Zuora.zApi.DeleteResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '\n';
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to update| \n' + errorText);
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            
            //Delete Payment Method from the list in Code and regenerate list of Payment Methods
            paymentSelect.remove(index);
            
            this.zPaymentMethods = queryPaymentMethod();
            generatePaymentSelect();
            index=-1;
        } catch(Exception e){
            //Throws error message is something fails
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }
        
    /**
        Set Default Payment Method
    */
    public PageReference setDefault(){
        if (Test.isRunningTest()){
            //Set value during testing
            index=0;
        }
        //If no card is chosen, error messege is thrown.
        if (index < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No applicable Payment Method selected!  Please choose a Payment method that can be set as the Default Payment Method!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Get selected Payment Method
        Zuora__PaymentMethod__c pm = paymentSelect.get(index).PaymentMethod;
        //If Payment Method is already Default, return error message
        if(pm.Zuora__DefaultPaymentMethod__c == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Credit Card is already default!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Instatiate and current Default Payment Method
        Zuora__PaymentMethod__c current;
        for (Integer i=0; i<paymentSelect.size(); i++){
            if (paymentSelect.get(i).PaymentMethod.Zuora__DefaultPaymentMethod__c == true){
                current = paymentSelect.get(i).PaymentMethod;
            }
        }
        try {
            //Instatiate Account that needs to be changed and fill in Zuora Account Id and new Default Payment Method Id
            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Id', zId);
            acc.setValue('DefaultPaymentMethodId', pm.Zuora__External_Id__c);
            List<Zuora.zObject> listAcc = new List<Zuora.zObject>();
            listAcc.add(acc);
            List<Zuora.zApi.SaveResult> results;
            if (!Test.isRunningTest()){
            //Login to Zuora and update Account with new Default Payment Method
                zapi.zlogin();
                results = zapi.zupdate(listAcc);
            } else {
                //Create data during testing when needed
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                results.add(res);
            }
            //Goes through the results for failures and displays error when they occur
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    Zuora.zObject[] errors = result.errors;
                    String errorText;
                    for (Zuora.zObject error : errors) {
                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '\n';
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to update| \n' + errorText);
                    ApexPages.addMessage(myMsg);
                    if (!Test.isRunningTest())
                        return null;
                }
            }
            
            //Set the current and new Default payment methods to their new statuses
            if (current != null){
                current.Zuora__DefaultPaymentMethod__c = false;
            }
            pm.Zuora__DefaultPaymentMethod__c = true;
            
            //Re-query for data to get updated data
            zAccount = queryAccount();
            zPaymentMethods = queryPaymentMethod();
            generatePaymentSelect();
            
        } catch(Exception e){
            //Throws error if exception occurs
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }
    
    /**
        Navigates to the Payments page to make a payment
    */
    public PageReference makePayment(){
        if (Test.isRunningTest()){
            //Sets test data
            index=0;
        }
        //If no card is chosen, navigate to page without a chosen card
        if (index < 0){
            return new PageReference('/apex/Make_Payment?field_passthrough2=' + accId + '&field_accountId=' + zId + '&field_passthrough1=' + billId);
        }
        //Gets chosen payment method if applicable
        Zuora__PaymentMethod__c pm = paymentSelect.get(index).PaymentMethod;
        
        //Prevents choosing for expired card
        if (pm.Zuora__Type__c == 'CreditCard'){
            Date expiration = Date.valueOf(pm.Zuora__CreditCardExpirationYear__c + '-' + pm.Zuora__CreditCardExpirationMonth__c + '-1');
            expiration = expiration.addMonths(1);
        
            if (expiration < Date.today()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot use expired card!');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        //If card is chosen, navigate to page with the selection as chosen payment method
        return new PageReference('/apex/Make_Payment?field_passthrough2=' + accId+ '&field_accountId=' + zId + '&field_passthrough1=' + billId + '&pmId=' + pm.Zuora__External_Id__c);
    }
        
    /**
        Updates the index to that of the chosen Payment Method
    */
    public void selectIndex(){
        //clears current viewed payments list and any current messeges
        viewedPayments.clear();
        ApexPages.getMessages().clear();
        System.Debug('Index: ' + index);
        if (index > -1){
            //If index is greater than -1 view all payments between chosen dates for the chosen card
            String pmId = paymentSelect.get(index).PaymentMethod.Zuora__External_Id__c;
            for (Integer i=0; i<zPayments.size(); i++){
                Zuora__Payment__c tempPay = zPayments.get(i);
                if (tempPay.Zuora__PaymentMethod__c == pmId && Date.valueOf(tempPay.Zuora__EffectiveDate__c) < convertDate(paymentTo).addDays(1) && Date.valueOf(tempPay.Zuora__EffectiveDate__c) >= convertDate(paymentFrom))
                    viewedPayments.add(tempPay);
            }
        } else if (index == -1){
            //If index is -1, view all payments between chosen dates for all payment methods
            for (Integer i=0; i<zPayments.size(); i++){
                Zuora__Payment__c tempPay = zPayments.get(i);
                if (Date.valueOf(tempPay.Zuora__EffectiveDate__c) < convertDate(paymentTo).addDays(1) && Date.valueOf(tempPay.Zuora__EffectiveDate__c) >= convertDate(paymentFrom))
                    viewedPayments.add(tempPay);
            }
        } else if (index == -2){
            //If index is -1, view all payments between chosen dates for all external payment methods
            for (Integer i=0; i<zPayments.size(); i++){
                Zuora__Payment__c tempPay = zPayments.get(i);
                if (Date.valueOf(tempPay.Zuora__EffectiveDate__c) < convertDate(paymentTo).addDays(1) && Date.valueOf(tempPay.Zuora__EffectiveDate__c) >= convertDate(paymentFrom))
                    for (Integer j=0; j<externalPaymentMethods.size(); j++){
                        if (tempPay.Zuora__PaymentMethod__c == externalPaymentMethods.get(j).Zuora__External_Id__c) 
                            viewedPayments.add(tempPay);
                    }
            }
        }
    }
    
    /**
        When error is confirmed, messages on page clear.
    */
    public void confirmError(){
        ApexPages.getMessages().clear();
    }
    
    /**
        Navigates to the refund page
    */
    public PageReference makeRefund(){
        return new PageReference('/apex/Make_Refund?id=' + billId + '&pId=' + paymentRefundId);
    }
    
    /**
        Returns to the billing account
    */
    public PageReference cancel(){
        if (userSettings.returnToPage__c == 'Account'){
            return new PageReference('/' + accId);
        }
        return new PageReference('/' + billId);
    }
        
    /**
        Class holding Payment Method, its index, and formatted versions of expiration date
        and address for viewing on page.
    */
    public class PaymentSelectorCombo{
        
        public Zuora__PaymentMethod__c PaymentMethod {get;set;}
        public Integer selectionIndex {get;set;}
        public String address {get;set;}
        public String expirationDate {get;set;}
        
        /**
            Constructor
        */
        public PaymentSelectorCombo(Zuora__PaymentMethod__c pm, Integer s){
            PaymentMethod = pm;
            selectionIndex = s;
            if (s>-1 && pm.Zuora__Type__c =='CreditCard')
                expirationDate = pm.Zuora__CreditCardExpirationMonth__c + '/' + pm.Zuora__CreditCardExpirationYear__c;
            else
                expirationDate = '';
            
            address = '';
            if (pm.Zuora__CreditCardAddress1__c != null){
                address = pm.Zuora__CreditCardAddress1__c;
                if (pm.Zuora__CreditCardAddress2__c != null)
                    address = address + ', ' + pm.Zuora__CreditCardAddress2__c + ',\r\n';
                else
                    address = address + ',\r\n';        
            }
            if (pm.Zuora__CreditCardCity__c != null)
                address = address + pm.Zuora__CreditCardCity__c + ', ';
            if(pm.Zuora__CreditCardState__c != null)
                address = address + pm.Zuora__CreditCardState__c + ', ';
            if (pm.Zuora__CreditCardCountry__c != null)
                address = address + pm.Zuora__CreditCardCountry__c;
            if (pm.Zuora__CreditCardPostalCode__c != null)
                address = address + ' ' + pm.Zuora__CreditCardPostalCode__c;
        }
    }
}