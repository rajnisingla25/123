public with sharing class AccountRedirectController {
    
    public String acc{get;set;} 
    public Integer count {get;set;}
    public Boolean displayPopup {get;set;}
    public List<Zuora__CustomerAccount__c> billingAccounts{get;set;}
    public AccountRedirectController(ApexPages.StandardController controller) {
        acc =  ApexPages.currentPage().getParameters().get('id');
        
        //flag = false;
        billingAccounts = [
            SELECT
            Id,name
            FROM
            Zuora__CustomerAccount__c
            WHERE
            Zuora__Account__c = :acc
        LIMIT 5];
        count=billingAccounts.size();
        
    }
    
    //CRM-2442 abailty to select the one billing account from multiple billing accounts
    public pagereference actionController(){
        
        if(count>1) {
            return null;
            
            }else if(billingAccounts.size() == 1){          
            return new PageReference('/apex/Manage_Billing_Account?id=' + billingAccounts[0].Id+ '&retId=' + acc); //showPopup();  
            }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'No Zuora Billing Account Exists for this SFDC Account'));
            return null;
        }
        return null;
        
    }          
    public PageReference redirect(){
        acc =  ApexPages.currentPage().getParameters().get('id');
        return new PageReference('/' + acc);
    }        
}