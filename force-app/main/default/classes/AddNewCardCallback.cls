public with sharing class AddNewCardCallback extends zqu.ZCheckoutBaseCallbackController {
	/**
		Default Callback page.
	*/
	public AddNewCardCallback() {
    	this.hostedPageSettingName = 'NewCreditCard';
	}
	  
	public String refId {get;set;}
	  
	public String objectId {get;set;}
	  
	public override void processCallbackParameters() {
		super.processCallbackParameters();
		this.refId = callbackparameters.get('refId');
		this.objectId = callbackparameters.get('field_passthrough1');
		
	}
	
}