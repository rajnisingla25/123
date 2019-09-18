public with sharing class AddNewCard extends zqu.ZCheckoutBaseController{
	
	public Boolean isAutopay {get;set;}
	public Boolean isDefault {get;set;}
	public string id {get;set;}
	public string zId {get;set;}
	public string billId {get;set;}
	public string pmId{get;set;}
	public string accId{get;set;}
	public string displayMessage{get;set;}
	public Zuora__CustomerAccount__c zAccount {get;set;}
	public string hostedPageChange {get;set;}
    
    public BillingAccountManagerSettings__c userSettings {get;set;}
    public string ccPageId {get;set;}
    public string achPageId {get;set;}
    public string paymentPage {get;set;}
	
	/*Zuora API Instance for calling into Zuora directly */
	static Zuora.zApi zapi = new Zuora.zApi();
	
	public AddNewCard() {
		//If test is not running, grab important information from URL and SF database
		if(!Test.isRunningTest()){
			zId = System.currentPageReference().getParameters().get('field_accountId');
			billId = System.currentPageReference().getParameters().get('field_passthrough1');
			accId = System.currentPageReference().getParameters().get('field_passthrough2');
			//Use a random quote from the database since this controller requires one.
			List<zqu__Quote__c> quotes = [select Id from zqu__Quote__c where zqu__ZuoraAccountId__c = :zId];
			if (quotes.size() > 0){id = String.valueOf(quotes.get(0).Id);}
		} else {
			zId='zId';
			billId='billId';
			accId='accId';
			id='quoteId';
		}
        userSettings = BillingAccountManagerSettings__c.getInstance(UserInfo.getProfileId());
        
        if (userSettings.UseNewHPM__c == 'Yes'){
        
            List<zqu__HostedPageLiteSetting__c> paymentPages = [Select Name, zqu__Default__c, zqu__PageId__c, zqu__PaymentMethodType__c From zqu__HostedPageLiteSetting__c];
            for (zqu__HostedPageLiteSetting__c page : paymentPages){
                if (page.Name == userSettings.CCPaymentPageName__c){
                    ccPageId = page.zqu__PageId__c;
                } else if (page.Name == userSettings.ACHPaymentPageName__c){
                    achPageId = page.zqu__PageId__c;
                }
            }
            paymentPage='cc';
        }

        //Set Name of HPM if old HPM is used
        if (userSettings.UseNewHPM__c == 'No')
            this.hostedPageSettingName = 'NewCreditCard';
		//Query Zuora for Account information
		zAccount = queryAccount();
		//Set default values for default and autopay
		this.isDefault = false;
		this.isAutopay = zAccount.Zuora__AutoPay__c;
	}

	public override PageReference getPageRef() {
	    setPageRef(Page.New_Credit_Card);
	    return Page.New_Credit_Card;
    }
    
    public List<SelectOption> getNewTypeOptions(){
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('NewCreditCard','New Credit Card'));
    	//Not necessary immediately
    	options.add(new SelectOption('NewACH','New ACH'));
    	return options;
    }
    
    public PageReference changeType(){
        if (hostedPageChange == 'NewACH'){
            if (userSettings.UseNewHPM__c == 'No')
	    		return new PageReference('/apex/New_ACH?field_passthrough2=' + id + '&field_accountId=' + zId + '&field_passthrough1=' + billId);
        	else
                paymentPage = 'ach';
        }
        else if (hostedPageChange == 'NewCreditCard')
    		paymentPage = 'cc';
    	return null;
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
        'field_passthrough2' => accId,
        'field_accountId' => zId
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
		return new PageReference('/apex/Manage_Billing_Account?&id=' + billId);
	}
	
	/**
		Query for the Zuora account that the card is being added to.
	*/  
  	public Zuora__CustomerAccount__c queryAccount(){
  		List<Zuora.zObject> accounts;
  		Zuora__CustomerAccount__c acc = new Zuora__CustomerAccount__c();
  		if(!Test.isRunningTest()){
			//Login to Zuora
			zapi.zlogin();
  		}
  		
	      	//Create ZOQL query
	    	String zoql = 'SELECT Name, AccountNumber, Id, DefaultPaymentMethodId, AutoPay from Account where Id = \'' + zId + '\'';
	        
        if(!Test.isRunningTest()){   
	    	//Query for payments from Zuora
	    	accounts = zapi.zquery(zoql);				
			//Create the sObject and fills it with data from the zObject
  		} else {
  			//Create values for testing
  			Zuora.zObject testAccount = new Zuora.zObject('Account');
			testAccount.setValue('Name', 'Name');
			testAccount.setValue('AccountNumber', 'AccountNumber');
			testAccount.setValue('Id', 'Id');
			testAccount.setValue('DefaultPaymentMethodId', 'pmId');
			testAccount.setValue('AutoPay', true);
			accounts = new List<Zuora.zObject>();
			accounts.add(testAccount);
  		}
  		
  		//Transfers all values into a SF equivalent SObject for access from the page.
  		acc.put(Zuora__CustomerAccount__c.Name, accounts.get(0).getValue('Name'));
		acc.put(Zuora__CustomerAccount__c.Zuora__AccountNumber__c, accounts.get(0).getValue('AccountNumber'));
		acc.put(Zuora__CustomerAccount__c.Zuora__Zuora_Id__c, accounts.get(0).getValue('Id'));
		acc.put(Zuora__CustomerAccount__c.Zuora__DefaultPaymentMethod__c, accounts.get(0).getValue('DefaultPaymentMethodId'));
		acc.put(Zuora__CustomerAccount__c.Zuora__AutoPay__c, accounts.get(0).getValue('AutoPay'));
  		return acc;
	}
	
	/**
		These actions are performed if the callback is successful.
		
		This function updates the Default Payment Method (if checked) and sets AutoPay to
		true or false based on whether it is checked or not.
	*/
	public PageReference successActions(){
        String refId;
		if(!Test.isRunningTest()){	
			//Retrieve PaymentMethod Id and return message from the callback.
			pmId = ApexPages.currentPage().getParameters().get('pmId');
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
			List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
			if(!Test.isRunningTest()){
				zapi.zlogin();
				results.addAll(zapi.zupdate(listAcc));
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
				}
			}
		} catch(Exception e){
			//Throws error if exception occurs
			displayMessage = displayMessage + ' | ' + e.getMessage();
			return new PageReference('/apex/Manage_Billing_Account?pmid=' + pmid + '&id=' + billId + '&displayMessage=' + displayMessage);
		}
		//return to Billing Account Manager
		return new PageReference('/apex/Manage_Billing_Account?pmid=' + pmid + '&id=' + billId + '&displayMessage=' + displayMessage);
	}
}