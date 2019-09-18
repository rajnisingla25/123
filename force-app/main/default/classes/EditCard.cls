public with sharing class EditCard {
	
	public Zuora__PaymentMethod__c paymentMethod {get;set;}
	public string pmId;
	public string id;
	public string billId;
	public string zId;
	public Zuora.zApi zapi = new Zuora.zApi();
	
	/**
		Constructor
	*/
	public EditCard(ApexPages.standardController controller){
		//Gets values from URL and the current Payment Method
		pmId = System.currentPageReference().getParameters().get('pmId');
		id = System.currentPageReference().getParameters().get('id');
		billId = System.currentPageReference().getParameters().get('billId');
		zId = System.currentPageReference().getParameters().get('zId');
		try{
			paymentMethod = queryPaymentMethod();
		}catch (Exception e){
			throw new zqu.ZQException(e.getMessage());
		}
	}
	
	public Zuora__PaymentMethod__c queryPaymentMethod(){
		List<Zuora.zObject> zPaymentMethods;
		
		//Generates ZOQL statement used to query for Payment method
		String zoql = 'select CreditCardType, CreditCardMaskNumber, CreditCardHolderName, CreditCardExpirationMonth, CreditCardExpirationYear, CreditCardAddress1, CreditCardAddress2, CreditCardState, CreditCardCountry, CreditCardPostalCode, CreditCardCity, Email, Phone from PaymentMethod where Id = \'' + pmId + '\'' ;
		if (!Test.isRunningTest()){
			//Login & Query
			zapi.zlogin();
			zPaymentMethods = zapi.zquery(zoql);
		} else {
			//Creates temporary values for testing
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
       		zPaymentMethods = new List<Zuora.zObject>();
       		zPaymentMethods.add(tempPm);
       		zPaymentMethods.add(tempPm);
		}
		
		//Gets the first payment method from the list and converts it into an sObject.
		Zuora.zObject zPaymentMethod = zPaymentMethods.get(0);
		
		Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardType__c , zPaymentMethod.getValue('CreditCardType'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardMaskNumber__c , zPaymentMethod.getValue('CreditCardMaskNumber'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardHolderName__c , zPaymentMethod.getValue('CreditCardHolderName'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationMonth__c , String.valueOf(zPaymentMethod.getValue('CreditCardExpirationMonth')));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardExpirationYear__c , String.valueOf(zPaymentMethod.getValue('CreditCardExpirationYear')));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardAddress1__c , zPaymentMethod.getValue('CreditCardAddress1'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardAddress2__c , zPaymentMethod.getValue('CreditCardAddress2'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardCity__c , zPaymentMethod.getValue('CreditCardCity'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardState__c , zPaymentMethod.getValue('CreditCardState'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardPostalCode__c , zPaymentMethod.getValue('CreditCardPostalCode'));
		pm.put(Zuora__PaymentMethod__c.Zuora__CreditCardCountry__c , zPaymentMethod.getValue('CreditCardCountry'));
		pm.put(Zuora__PaymentMethod__c.Zuora__Phone__c , zPaymentMethod.getValue('Phone'));
		pm.put(Zuora__PaymentMethod__c.Zuora__Email__c , zPaymentMethod.getValue('Email'));
		
		return pm;
	}
	
	/**
		Updates the Payment Method with new information.
	*/
	public PageReference updateCard(){
		ApexPages.getMessages().clear();
		
		//Creates a zObject with all the information entered on the page.
		Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
		pm.setValue('Id', pmId);
		pm.setValue('CreditCardType', paymentMethod.Zuora__CreditCardType__c);
		pm.setValue('CreditCardHolderName', paymentMethod.Zuora__CreditCardHolderName__c);
		pm.setValue('CreditCardExpirationMonth', paymentMethod.Zuora__CreditCardExpirationMonth__c);
		pm.setValue('CreditCardExpirationYear', paymentMethod.Zuora__CreditCardExpirationYear__c);
		pm.setValue('CreditCardAddress1', paymentMethod.Zuora__CreditCardAddress1__c);
		pm.setValue('CreditCardAddress2', paymentMethod.Zuora__CreditCardAddress2__c);
		pm.setValue('CreditCardCity', paymentMethod.Zuora__CreditCardCity__c);
		pm.setValue('CreditCardState', paymentMethod.Zuora__CreditCardState__c);
		pm.setValue('CreditCardPostalCode', paymentMethod.Zuora__CreditCardPostalCode__c);
		pm.setValue('CreditCardCountry', paymentMethod.Zuora__CreditCardCountry__c);
		pm.setValue('Phone', paymentMethod.Zuora__Phone__c);
		pm.setValue('Email', paymentMethod.Zuora__Email__c);
		
		//Adds to list of objects to be updates.
		List<Zuora.zObject> listpm = new List<Zuora.zObject>();
		listPM.add(pm);
		
		try{
			List<Zuora.zApi.SaveResult> results;
			if (!Test.isRunningTest()){
				//Login and Update
				zapi.zlogin();
				results = zapi.zupdate(listPm);
			} else {
				//Create result for testing when needed
				Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
				res.Success = false;
				Zuora.zObject error = new Zuora.zObject('Error');
				res.errors = new Zuora.zObject[]{error};
				results = new List<Zuora.zApi.SaveResult>{};
				results.add(res);
			}
			//Goes through results for failures and displays error when they occur
			for (Zuora.zApi.SaveResult result : results){
				if (!result.Success){
					Zuora.zObject[] errors = result.errors;
					String errorText = '';
					for (Zuora.zObject error : errors) {
						errorText = errorText + '<br />' + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message');
					}
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failure to update card' + errorText);
					ApexPages.addMessage(myMsg);
					return null;
				}
			}
		}catch (Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
			ApexPages.addMessage(myMsg);
			return null;
		}	
		return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
	}
	
	/**
		Navigate back if efit is cancelled
	*/
	public PageReference cancel(){
    	return new PageReference('/apex/Manage_Billing_Account?id=' + billId);
    }

}