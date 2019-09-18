public with sharing class MakePaymentACH  extends zqu.ZCheckoutBaseController {
	
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
	public string preset {get;set;}
	
	/**
		Constructor
	*/
	public MakePaymentACH(){
		//Generate notification object and fills in information
		notificationOptions = new zqu.NotificationOptions();
		notificationOptions.isPopup = true;
		notificationOptions.continueAction = 'continueToNextPage();';
		notificationOptions.backLabel = 'Remain';
		notificationOptions.successTitle = 'SUCCESS! Payment method created!';
		notificationOptions.failureTitle = 'AN ERROR OCCURRED!';
		paymentType='external';
		
		//Get today's date
		String[] todays = String.valueOf(Date.today()).split('-',0);
		this.paymentDate = todays[1] + '/' + todays[2] + '/' + todays[0];
		
		//Retrieve Payment Method Id if one exists
		if (System.currentPageReference().getParameters().containsKey('pmId')){
			this.pmId = System.currentPageReference().getParameters().get('pmId');
		} else {
			this.pmId = 'none';
		}
		//If test is runing, set test data, otherwise, grab information from the URL
		if (System.currentPageReference().getParameters().containsKey('preset')){
			this.preset = System.currentPageReference().getParameters().get('preset');
			pmId='newACH';
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
		//Get name of HPM for page.
		this.hostedPageSettingName = 'NewACH';
		//Set various inital values.
		invoiceTotal=0;
		paymentAmount=0;
		invoiceAmount=0;
		remainingAmount=0;
		isAutopay = zAccount.Zuora__AutoPay__c;
		isDefault = false;
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
    	String zoql = 'SELECT Name, AccountNumber, Id, DefaultPaymentMethodId, AutoPay from Account where Id = \'' + zId + '\'';
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
        	options.add(new SelectOption(paymentMethod.Zuora__External_Id__c,paymentMethod.Zuora__CreditCardHolderName__c + ', ' + paymentMethod.Zuora__CreditCardType__c + ' (' + paymentMethod.Zuora__CreditCardMaskNumber__c + ')')); 
		}
			options.add(new SelectOption('newCard','-- Add New Card --'));
			options.add(new SelectOption('newACH','-- Add New ACH --'));
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
    
    public PageReference toCC(){
    	if (pmId=='newACH')
    		return new PageReference('/apex/Make_Payment?field_passthrough2=' + accId + '&field_accountId=' + zId + '&field_passthrough1=' + billId + '&preset=true');
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
    	String zoql = 'SELECT CreditCardHolderName, CreditCardMaskNumber, CreditCardType, Id from PaymentMethod where AccountId = \'' + zId + '\'';
       	
       	if (!Test.isRunningTest()){
    	//Query for payments from Zuora
    	paymentMethods = zapi.zquery(zoql);
       	} else {
       		//Generate test data for testing when needed
       		Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
       		tempPm.setValue('CreditCardHolderName','Name');
       		tempPm.setValue('CreditCardMaskNumber','Number');
       		tempPm.setValue('CreditCardType', 'Type');
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
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('CreditCardHolderName'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('CreditCardMaskNumber'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('CreditCardType'));
			add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
			
			ret.add(add);
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
        List<Zuora__ZInvoice__c> ret = new List<Zuora__ZInvoice__c>();
        
        for (Integer i=0; i<invoices.size(); i++){
			Zuora.zObject inv = invoices.get(i);
			//Create the sObject and fills it with data from the zObject and places it into the list
			Zuora__ZInvoice__c add = new Zuora__ZInvoice__c();
			add.put(Zuora__Zinvoice__c.Name, inv.getValue('InvoiceNumber'));
			add.put(Zuora__ZInvoice__c.Zuora__TotalAmount__c, inv.getValue('Amount'));
			add.put(Zuora__ZInvoice__c.Zuora__Balance2__c, inv.getValue('Balance'));
			add.put(Zuora__ZInvoice__c.Zuora__External_Id__c, inv.getValue('Id'));
			DateTime dt = DateTime.valueOf(inv.getValue('InvoiceDate'));
			add.put(Zuora__ZInvoice__c.Zuora__InvoiceDate__c, dt.date());
			DateTime dt2 = DateTime.valueOf(inv.getValue('DueDate'));
			add.put(Zuora__ZInvoice__c.Zuora__DueDate__c, dt2.date());
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
        options.add(new SelectOption('external','External Payment')); 
        options.add(new SelectOption('electronic','Electronic Payment')); 
		return options; 
    }
	
	/**
		Makes the Payment.
	*/	
	public PageReference makePaymentNow(){
		Zuora.zObject payment = new Zuora.zObject('Payment');
		System.debug('paymentAmount: ' + paymentAmount);
		if (paymentType == 'electronic'){
			payment.setValue('AccountId', zId);
			payment.setValue('Amount', paymentAmount);
			payment.setValue('AppliedCreditBalanceAmount', remainingAmount);
			payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(convertDate(paymentDate)));
			payment.setValue('PaymentMethodId', pmId);
			payment.setValue('Type', 'Electronic');
			payment.setValue('Status', 'Draft');
		} else if (paymentType == 'external'){
			payment.setValue('AccountId', zId);
			payment.setValue('Amount', paymentAmount);
			payment.setValue('AppliedCreditBalanceAmount', remainingAmount);
			payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(convertDate(paymentDate)));
			payment.setValue('PaymentMethodId', xpmId);
			payment.setValue('Type', 'External');
			payment.setValue('Status', 'Draft');
		} else {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Payment Type selected!  Please specify a payment type.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		
		List<Zuora.zObject> objs = new List<Zuora.zObject>{payment};
		try{
			List<Zuora.zApi.SaveResult> results;
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
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment |' + errorText);
					ApexPages.addMessage(myMsg);
					return null;
				} else {
					pId = result.Id;
				}
			}
			
			List<Zuora.zObject> invoicePayments = new List<Zuora.zObject>();
			Zuora.zObject ip;
			for (InvoiceSelectorCombo isc : invoiceSelect){
				if (isc.isSelected){
					ip = new Zuora.zObject('InvoicePayment');
					ip.setValue('Amount', isc.appliedAmount);
					ip.setValue('InvoiceId', isc.Invoice.Zuora__External_Id__c);
					ip.setValue('PaymentId', pId);
					invoicePayments.add(ip);
				}
			}
			if ( !invoicePayments.isEmpty()){
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
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment |' + errorText);
						ApexPages.addMessage(myMsg);
						return null;
					}
				}
			}
			
			Zuora.zObject paymentUpdate = new Zuora.zObject('Payment');
			paymentUpdate.setValue('Id', pId);
			paymentUpdate.setValue('Status', 'Processed');
		
			List<Zuora.zObject> obj = new List<Zuora.zObject>{paymentUpdate};
			if (!Test.isRunningTest()){
				results = zapi.zupdate(obj);
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
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to create Payment |' + errorText);
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
	    setPageRef(Page.Make_Payment_ACH);
	    return Page.Make_Payment_ACH;
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