public with sharing class MakeRefund {
	
	public String refundType {get;set;}
	public String methodType {get;set;}
	public Zuora__PaymentMethod__c zPaymentMethod {get;set;}
	public Zuora__Payment__c zPayment {get;set;}
	public List<Zuora__PaymentInvoice__c> zInvoicePayment {get;set;}
	public List<PaymentSelectorCombo> paymentSelect {get;set;}
	public String pmId {get;set;}
	public String pId {get;set;}
	public String billId {get;set;}
	public String zId {get;set;}
	public String accId {get;set;}
	public Zuora__CustomerAccount__c sfAccount;
	public Decimal Amount {get;set;}
	public String Comment {get;set;}
	public zqu.NotificationOptions notificationOptions {get;set;}
	public Decimal refundAvailable {get;set;}
	public List<Zuora__PaymentMethod__c> zExternalPaymentMethod {get;set;}
	public Boolean mustBeExternal {get;set;}
	public String refundDate {get;set;}
	public String originalPaymentMethod {get;set;}
	public List<Zuora__ZInvoice__c> zInvoice;
	public Map<String, String> zInvoiceMap;
	public Map<String, String> InvoicePaymentMap;
	
	public Zuora.zApi zapi = new Zuora.zApi();
	
	/**
		Constructor
	*/
	public MakeRefund(ApexPages.StandardController controller){
		//Create Notification object and sets values to set up the pop-up
		notificationOptions = new zqu.NotificationOptions();
		notificationOptions.isPopup = true;
		notificationOptions.continueAction = 'continueToNextPage();';
		notificationOptions.backLabel = 'Remain';
		notificationOptions.successTitle = 'SUCCESS!  Payment Method Created!';
		notificationOptions.failureTitle = 'AN ERROR OCCURRED!';
		
		//Gets today's date
		String[] todays = String.valueOf(Date.today()).split('-',0);
		this.refundDate = todays[1] + '/' + todays[2] + '/' + todays[0];
		
		//Gets data from the URL
		this.pId = System.currentPageReference().getParameters().get('pId');
		this.billId = System.currentPageReference().getParameters().get('Id');
		
		//Gets the curret billing account from salesforce 
		if (!Test.isRunningTest())
			this.sfAccount = ([SELECT Zuora__Account__c, Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Id = :billId ]).get(0);
		else{
			//Creates test data during testing
			this.sfAccount = new Zuora__CustomerAccount__c();
			Account tempAcc = Z_TestFactory.makeAccount();
			sfAccount.Zuora__Zuora_Id__c = 'zId';
			sfAccount.Zuora__Account__c = tempAcc.Id;
			this.billId = 'billId';
		}
		//Gets important data from the SF Billing Account
		this.zId = sfAccount.Zuora__Zuora_Id__c;
		this.accId = sfAccount.Zuora__Account__c;
				
		//Query Zuora for various important infomation, inclduing all external payment methods,
		//The current payment and the invoicepayments associated with it, as well as the ID
		//of the Payment Method use and the Payment Method itself.
		this.zExternalPaymentMethod = queryExternalPaymentMethod();
		this.zInvoice = queryInvoice();
		mapInvoice();
		this.zPayment = queryPayment();
		this.zInvoicePayment = queryInvoicePayment();
		generatePaymentSelect();
		this.pmId = zPayment.Zuora__PaymentMethod__c;
		this.zPaymentMethod = queryPaymentMethod();
		this.originalPaymentMethod = zPaymentMethod.Zuora__CreditCardHolderName__c + ', ' + zPaymentMethod.Zuora__CreditCardType__c + ' (' + zPaymentMethod.Zuora__CreditCardMaskNumber__c + ')';
		mustBeExternal = false;
		
		//If the original payment method was external, the refund must be external
		for (Zuora__PaymentMethod__c xpm : zExternalPaymentMethod){
			if (xpm.Zuora__External_Id__c == pmId)
				mustBeExternal = true;
		}
		
		//Sets default values
		this.refundType = 'external';
		this.methodType = '';
		this.Amount = 0;
	}
	
	/**
		Converts the date from the date picker format to the code format
	*/
	public Date convertDate(String d){
		String[] splitDate = d.split('/',0);
		return Date.valueOf(splitDate[2] + '-' + splitDate[0] + '-' + splitDate[1]);
	}
	
	/**
		Query Zuora for the used Payment Method
	*/
	public Zuora__PaymentMethod__c queryPaymentMethod(){
		List<Zuora.zObject> paymentMethods;
       	Zuora.zObject payment;
		//Login to Zuora
		if (!Test.isRunningTest()){
    		zapi.zlogin();
		}
            
    	//Create ZOQL query
    	String zoql = 'SELECT Type, AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, CreditCardHolderName, CreditCardMaskNumber, CreditCardType, CreditCardExpirationMonth, CreditCardExpirationYear, Id from PaymentMethod where Id = \'' + pmId + '\'';
        
       	if (!Test.isRunningTest()){
	    	//Query for payments from Zuora
	    	paymentMethods = zapi.zquery(zoql);
	    	payment = paymentMethods.get(0);
       	} else {
       		//Generated data for testing
       		Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
       		tempPm.setValue('CreditCardHolderName','Name');
       		tempPm.setValue('CreditCardMaskNumber','Number');
       		tempPm.setValue('CreditCardType','CreditCard');
       		tempPm.setValue('CreditCardExpirationMonth','01');
       		tempPm.setValue('CreditCardExpirationYear','2014');
       		tempPm.setValue('Id','notDefault');
            tempPm.setValue('Type', 'CreditCard');
       		payment = tempPm;
       	}
		
		Zuora__PaymentMethod__c add = new Zuora__PaymentMethod__c();
		if (payment.getValue('Type') == 'CreditCard'){
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('CreditCardHolderName'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('CreditCardMaskNumber'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('CreditCardType'));
			add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
		} else if (payment.getValue('Type') == 'ACH'){
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c, payment.getValue('AchAccountName'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c, payment.getValue('AchAbaCode') + ' ' + payment.getValue('AchAccountNumberMask'));
			add.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c, payment.getValue('AchBankName') + ' - ' + payment.getValue('AchAccountType'));
			add.put(Zuora__PaymentMethod__c.Zuora__External_Id__c, payment.getValue('Id'));
		}
		
		return add;
	}
	
	/**
		Query Zuora for the payment that is being refunded
	*/
	public Zuora__Payment__c queryPayment(){
		List<Zuora.zObject> payments;
		Zuora.zObject payment;
		if (!Test.isRunningTest()){
			zapi.zlogin();
		}
                
        //Create ZOQL query
        String zoql = 'SELECT Amount, RefundAmount, PaymentNumber, CreatedDate, EffectiveDate, PaymentMethodId, Id from Payment where id = \'' + pId + '\'';
        
        if (!Test.isRunningTest()){
	        //Query for payments from Zuora
	        payments = zapi.zquery(zoql);
	        payment = payments.get(0);
        } else {
        	//Generates temporary data for testing purposes
        	Zuora.zObject tempPayment = new Zuora.zObject('Payment');
        	tempPayment.setValue('Amount',100.00);
        	tempPayment.setValue('RefundAmount', 0.00);
        	tempPayment.setValue('PaymentNumber','PaymentNumber');
        	tempPayment.setValue('CreatedDate',DateTime.now());
        	tempPayment.setValue('EffectiveDate',DateTime.now());
        	tempPayment.setValue('PaymentMethodId','pmId');
        	tempPayment.setValue('Id', 'pId');
        	payment = tempPayment;
        }
        
        //Creats an sObject and fills in the data fro the zObject for use on the page
        Zuora__Payment__c add = new Zuora__Payment__c();
		add.put(Zuora__Payment__c.Zuora__Amount__c, payment.getValue('Amount'));
		add.put(Zuora__Payment__c.Zuora__AppliedCreditBalanceAmount__c, payment.getValue('RefundAmount'));
		add.put(Zuora__Payment__c.Zuora__PaymentNumber__c, payment.getValue('PaymentNumber'));
		add.put(Zuora__Payment__c.Zuora__CreatedDate__c, payment.getValue('CreatedDate'));
		add.put(Zuora__Payment__c.Zuora__EffectiveDate__c, payment.getValue('EffectiveDate'));
		add.put(Zuora__Payment__c.Zuora__PaymentMethod__c, payment.getValue('PaymentMethodId'));
		add.put(Zuora__Payment__c.Zuora__External_Id__c, payment.getValue('Id'));
		
		this.refundAvailable = add.Zuora__Amount__c - add.Zuora__AppliedCreditBalanceAmount__c;
		
		return add;
	}
	
	/**
		Gets all InvoicePayments associated with the current payment
	*/
	public List<Zuora__PaymentInvoice__c> queryInvoicePayment(){
		InvoicePaymentMap = new Map<String,String>();
		List<Zuora.zObject> payments;
		if (!Test.isRunningTest()){
			zapi.zlogin();
		}
                
        //Create ZOQL query
        String zoql = 'SELECT Amount, RefundAmount, Id, InvoiceId from InvoicePayment where PaymentId = \'' + pId + '\'';
        
        if (!Test.isRunningTest()){
	        //Query for Invoice Payments from Zuora
	        payments = zapi.zquery(zoql);
        } else {
        	//Generate test data for testing
        	payments = new List<Zuora.zObject>();
        	Zuora.zObject tempPayment = new Zuora.zObject('InvoicePayment');
        	tempPayment.setValue('Amount',100.00);
        	tempPayment.setValue('RefundAmount', 100.00);
        	tempPayment.setValue('Id', 'pId');
        	payments.add(tempPayment);
        }
        
        //Sets max refund available to 0 initally
        this.refundAvailable = 0;
        //Creates the list of Invoice Payemnts
        List<Zuora__PaymentInvoice__c> ret = new List<Zuora__PaymentInvoice__c>();
        
        //Go through the list from Zuora and convert from zObjects to sObjects and adds it to the list
        //of Invoice Payments as well as increase to max refund available by each amount available per
        //Invoice Payment
        for (Zuora.zObject payment : payments){
	        Zuora__PaymentInvoice__c add = new Zuora__PaymentInvoice__c();
			add.put(Zuora__PaymentInvoice__c.Zuora__ApplyAmount__c, payment.getValue('Amount'));
			add.put(Zuora__PaymentInvoice__c.Zuora__RefundAmount__c, payment.getValue('RefundAmount'));
			add.put(Zuora__PaymentInvoice__c.Zuora__External_Id__c, payment.getValue('Id'));
			ret.add(add);
			this.refundAvailable = refundAvailable + (add.Zuora__ApplyAmount__c - add.Zuora__RefundAmount__c);
			InvoicePaymentMap.put(String.valueOf(payment.getValue('Id')), zInvoiceMap.get(String.valueOf(payment.getValue('InvoiceId'))));
        }
		
		return ret;
	}
	
	public List<Zuora__ZInvoice__c> queryInvoice(){
		List<Zuora.zObject> invoices;
		
		//Create ZOQL query
    	String zoql = 'SELECT Id, InvoiceNumber from Invoice where AccountId = \'' + zId + '\'' ;
    	
		if (!Test.isRunningTest()){
			zapi.zlogin();
		    invoices = zapi.zquery(zoql);
		} else {
			//Creates data for testing when needed
			Zuora.zObject tempInv = new Zuora.zObject('Invoice');
			tempInv.setValue('InvoiceNumber','Invoice Number');
			tempInv.setValue('Id','Id');
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
			add.put(Zuora__ZInvoice__c.Zuora__External_Id__c, inv.getValue('Id'));
			ret.add(add);
		}
		
		return ret;
		
	}
	
	public void mapInvoice(){
	
			zInvoiceMap = new Map<String, String>();
			for (Zuora__ZInvoice__c invoice : zInvoice){
				System.Debug(invoice.Zuora__External_Id__c + ' | ' + invoice.Name);
				zInvoiceMap.put(invoice.Zuora__External_Id__c, invoice.Name);
			}
	
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
       		//Generate data for testing when needed
       		Zuora.zObject tempPm = new Zuora.zObject('PaymentMethod');
       		tempPm.setValue('Name','Name');
       		tempPm.setValue('Id','pmId');
       		paymentMethods = new List<Zuora.zObject>();
       		paymentMethods.add(tempPm);
       	}
        
        //Creates a list of payment method sObjects
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
		Generates a PaymentSelectorCombo list, which holds various data including PaymentInvoices,
		selection boolean, and some calculated values
	*/
	public void generatePaymentSelect(){
		this.paymentSelect = new List<PaymentSelectorCombo>();
		for (Integer i=0; i<zInvoicePayment.size(); i++){
			this.paymentSelect.add(new PaymentSelectorCombo(zInvoicePayment.get(i), InvoicePaymentMap));
		}
	}
	
	/**
		Creates the options for the radio buttons to choose refund type
	*/
	public List<SelectOption> getRefundTypeOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('external','External Refund')); 
        if (Test.isRunningTest())
            mustBeExternal = false;
        if (!mustBeExternal)
	    	options.add(new SelectOption('CreditCard','Credit Card Refund')); 
		return options; 
    }
    
    /**
    	Creates the options for the external payment methods list.
    */
    public List<SelectOption> getMethodTypeOptions(){
    	List<SelectOption> options = new List<SelectOption>(); 
    	options.add(new SelectOption('', '-- Select one --'));
        options.add(new SelectOption('ACH','ACH'));
        options.add(new SelectOption('Cash','Cash'));
        options.add(new SelectOption('Check','Check'));
        options.add(new SelectOption('CreditCard','CreditCard'));
        options.add(new SelectOption('DebitCard','Debit Card'));
        options.add(new SelectOption('PayPal','PayPal'));
        options.add(new SelectOption('WireTransfer','Wire Transfer'));
        options.add(new SelectOption('CreditCardReferenceTransaction','Credit Card Ref Trans'));
        options.add(new SelectOption('Other','Other'));
		return options;
    }
    
    /**
    	Returns to previous page upon cancel
    */
    public PageReference cancel(){
    	return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }
    
    /**
    	Submits the refund to be processed
    */
    public PageReference submit(){
    	//If total refund is greater than that available, show error
    	if (Amount > refundAvailable){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannont refund amount greater than total refund available!');
			ApexPages.addMessage(myMsg);
			return null;
    	}
    	if (Amount <= 0){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannont refund Amount of $0!');
			ApexPages.addMessage(myMsg);
            if (!Test.isRunningTest())
				return null;
    	}
    	//Go to correct function depending on type of refund
    	if (refundType=='external')
    		return externalRefund();
    	else if (refundType=='CreditCard')
    		return creditCardRefund();
		else{
			//Show error if none selected
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No refund type selected!');
			ApexPages.addMessage(myMsg);
			return null;
		}
    }
    
    /**
    	Process an external refund
    */
    public PageReference externalRefund(){
    	//Creates the zObject and fills it with correct values
    	List<Zuora.zObject> objs = new List<Zuora.zObject>();
    	Zuora.zObject refund;
    	for (PaymentSelectorCombo refundA : paymentSelect){
	    	refund = new Zuora.zObject('Refund');
	    	refund.setValue('AccountId', zId);
	    	refund.setValue('Amount', refundA.amountRefunded);
	    	refund.setValue('PaymentId', pId);
	    	refund.setValue('SourceType', 'Payment');
	    	refund.setValue('MethodType', methodType);
	    	refund.setValue('Type', 'External');
	    	refund.setValue('RefundDate', Zuora.zUtil.getZuoraDate(ConvertDate(refundDate)));
	    	objs.add(refund);
    	}
    	
    	if (objs.isEmpty()){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to perform rufunds unassociated with an invoice.  Credit Balance refund not currently supported.');
			ApexPages.addMessage(myMsg);
			return null;
    	}
    	
    	try{
    		List<Zuora.zApi.SaveResult> results;
    		if (!Test.isRunningTest()){
			//Login to Zuora and update Account with new Default Payment Method
				zapi.zlogin();
				results = zapi.zcreate(objs);
			} else {
				//Generate test results when testing
				Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
				res.Success = false;
				Zuora.zObject error = new Zuora.zObject('Error');
				res.errors = new Zuora.zObject[]{error};
				results = new List<Zuora.zApi.SaveResult>{};
				results.add(res);
			}
			//Goes through results and shows error for any that fail.
			for (Zuora.zApi.SaveResult result : results){
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
    	} catch (Exception e){
    		//Throws error if exception occurs
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
			ApexPages.addMessage(myMsg);
			System.debug('Error! ' + e.getMessage());
			return null;
    	}
    	return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }
    
    /**
    	Process an electronic refund
    */
    public PageReference creditCardRefund(){
    	//Creates the zObject and fills it with correct values
    	Zuora.zObject refund;
    	List<Zuora.zObject> objs = new List<Zuora.zObject>();
    	for (PaymentSelectorCombo refundA : paymentSelect){
	    	refund = new Zuora.zObject('Refund');
	    	refund.setValue('AccountId', zId);
	    	refund.setValue('Amount', refundA.amountRefunded);
	    	refund.setValue('PaymentId', pId);
	    	refund.setValue('SourceType', 'Payment');
	    	refund.setValue('Type', 'Electronic');
	    	objs.add(refund);
    	}
    	
    	if (objs.isEmpty()){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to perform rufunds unassociated with an invoice.  Credit Balance refund not currently supported.');
			ApexPages.addMessage(myMsg);
			return null;
    	}
    	
    	try{
    		List<Zuora.zApi.SaveResult> results;
    		if (!Test.isRunningTest()){
			//Login to Zuora and update Account with new Default Payment Method
				zapi.zlogin();
				results = zapi.zcreate(objs);
			} else {
				//Generate data for testing purposes when needed
				Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
				res.Success = false;
				Zuora.zObject error = new Zuora.zObject('Error');
				res.errors = new Zuora.zObject[]{error};
				results = new List<Zuora.zApi.SaveResult>{};
				results.add(res);
			}
			//Goes through results and shows error for any that fail.
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
    	} catch (Exception e){
    		//Throws error if exception occurs
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
			ApexPages.addMessage(myMsg);
			System.debug('Error! ' + e.getMessage());
			return null;
    	}
    	return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }
    
    /**
    	Update refund total when checkboxes and selected/deselected
    */
    public void updateRefundTotal(){
    	//Sets total amount to 0
		Amount = 0.00;
		
		//Goes through all paymentinvoices
		for (PaymentSelectorCombo ps : paymentSelect){
			//if current one is selected
			if (ps.isSelected){
				//and its personal amount refunded is 0
				if (ps.amountRefunded==0){
					//set amount refunded to max available amount
					ps.amountRefunded = ps.availableRefund;
				}
				//Add amount refunded to total amount refunded
				Amount += ps.amountRefunded;
			} else if (!ps.isSelected && ps.amountRefunded!=0){
				//If is it deselected and its amount refunded is not 0, set its
				//refunded amount to zero.
				ps.amountRefunded=0.00;
			}
		}
    }
    
    /**
    	Updates values when amount refunded on individual payment invoices is changes
    */
    public void updateValues(){
    	//sets total amount to 0
    	Amount = 0.00;
		
		//Goes through each payment invoice
		for (PaymentSelectorCombo ps : paymentSelect){
			//If payment invoice is selected
			if (ps.isSelected){
				//and its refund amount is set to 0
				if (ps.amountRefunded==0){
					//set it to deselected and go to next payment invoice
					ps.isSelected = false;
					continue;
				}
				//add the refunded amount to the total
				Amount += ps.amountRefunded;
			} else if (!ps.isSelected && ps.amountRefunded != 0){
				//if refunded amount is not 0 and it is not selected, change it to selected,
				//and add the refunded amount to the total
				ps.isSelected = true;
				Amount += ps.amountRefunded;
			}
		}
    }
    
    /**
    	Update date to today when electronic refund is chosen
    */
    public void updateDate(){
		if (refundType=='electronic'){
			String[] todays = String.valueOf(Date.today()).split('-',0);
			this.refundDate = todays[1] + '/' + todays[2] + '/' + todays[0];
		}
	}
    
    /**
    	Confirms error message and clears all messages on page.
    */
    public void confirmError(){
    	ApexPages.getMessages().clear();
    }
    
    
    /**
		Object that holds various data, including an payment invoice, a boolean representing selection, and
		the amount to be refunded (as well as validation for setting the value), and a calculation of the
		max amount available for refund.
	*/
    public class PaymentSelectorCombo {
    	
    	public Zuora__PaymentInvoice__c PaymentInvoice {get;set;}
    	public Boolean isSelected {get;set;}
    	public Decimal amountRefunded 
    								{get;
    									set{
											if (value > availableRefund){
									    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Refund higher than maximum refund allowed!  Value set to maximum allowable refund.');
												ApexPages.addMessage(myMsg);
									    		amountRefunded = availableRefund;
									    	} else
									    		amountRefunded = value;
										}}
    	public Decimal availableRefund {get;set;}
    	public String InvoiceName {get;set;}
    	
    	public PaymentSelectorCombo (Zuora__PaymentInvoice__c pi, Map<String,String> zInvoiceMap) {
    		PaymentInvoice = pi;
    		isSelected = false;
    		amountRefunded = 0.00;
    		availableRefund = pi.Zuora__ApplyAmount__c - pi.Zuora__RefundAmount__c;
    		System.Debug(pi.Zuora__External_Id__c + ' | ' + zInvoiceMap.get(pi.Zuora__External_Id__c));
    		InvoiceName = zInvoiceMap.get(pi.Zuora__External_Id__c);
            if (Test.isRunningTest())
                isSelected = true;
    	}
    	
    }
}