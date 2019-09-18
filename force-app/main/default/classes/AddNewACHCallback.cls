public with sharing class AddNewACHCallback extends zqu.ZCheckoutBaseCallbackController {
	/**
		Default Callback page.
	*/
	public AddNewACHCallback() {
    	this.hostedPageSettingName = 'NewACH';
	}
	  
	public String refId {get;set;}
	  
	public String objectId {get;set;}
	  
	public override void processCallbackParameters() {
		super.processCallbackParameters();
		this.refId = callbackparameters.get('refId');
		this.objectId = callbackparameters.get('field_passthrough1');
		
	}
}