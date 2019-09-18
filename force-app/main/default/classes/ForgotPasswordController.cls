/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
        EmployeeDashboard__c ed = EmployeeDashboard__c.getValues('UsernameSuffix');
        // appending ".ed" to username in Prod as users will be using same email(username) to login into community and standard SFDC
        // CRM-2818
        if(ed.Value__c != null){
            username = username+ed.Value__c;
        }
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.EmployeeForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
}