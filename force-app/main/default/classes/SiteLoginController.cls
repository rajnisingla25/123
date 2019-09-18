/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        EmployeeDashboard__c ed = EmployeeDashboard__c.getValues('UsernameSuffix');
        // appending ".ed" to username in Prod as users will be using same email(username) to login into community and standard SFDC
        // CRM-2818
        if(ed.Value__c != null){
            username = username+ed.Value__c;
        }
        return Site.login(username, password, startUrl);
    }
    
     global SiteLoginController () {}
}