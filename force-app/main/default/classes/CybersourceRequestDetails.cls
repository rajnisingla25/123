public with sharing class CybersourceRequestDetails {
    
    public static Account accountRecord;
    public static List<Account_Relationship__c> billingContact = new List<Account_Relationship__c>();
    public static Map<String,String> accDetailsMap = new Map<String,String>();
    
    
    @AuraEnabled(cacheable=true)
    public static SignatureData getData(String accountId,String pageSource){
        String parameterValues = '';
        SignatureData obj = new SignatureData();
        system.debug(' *** accountId *** '+accountId+' *** pageSource *** '+pageSource);
        String pageParameters = accountId+';'+pageSource;
        accountRecord = [select id,name,Email_Address__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from account where id =: accountId];
        
        billingContact = [SELECT Name,Contact_to__r.FirstName, Contact_to__r.LastName, Billing_Contact__c,Contact_Role__c FROM Account_Relationship__c 
                          WHERE Parent_Account__c = :accountId AND Active__c = true AND Billing_Contact__c = true LIMIT 1];
        
        if(!billingContact.isEmpty() && accountRecord != null){
            accDetailsMap.put('accountId',pageParameters);
            accDetailsMap.put('billToFname',billingContact[0].Contact_to__r.FirstName);
            accDetailsMap.put('billToLname',billingContact[0].Contact_to__r.LastName);
            accDetailsMap.put('billToEmail',accountRecord.Email_Address__c);
            accDetailsMap.put('billToStreet',accountRecord.BillingStreet);
            accDetailsMap.put('billToCity',accountRecord.BillingCity);
            accDetailsMap.put('billToState',accountRecord.BillingState);
            accDetailsMap.put('billToCountry','US');
            accDetailsMap.put('billTozip',accountRecord.BillingPostalCode);
            accDetailsMap.put('billToCurrency','usd');
        }
        
        if(!accDetailsMap.isEmpty()){
            parameterValues = Wallet.CybersourceSignatureDate.acceptaccountdetails(accDetailsMap);
        }      
        system.debug(' *** accountRecord details *** '+accountRecord);
        system.debug(' *** parameter details *** '+parameterValues);
        
        obj.ParametersValues = parameterValues;
        obj.EndPoint = 'https://testsecureacceptance.cybersource.com/embedded/token/create';
        obj.errorMessage = '';
        
        if(billingContact.isEmpty()){     
            obj.errorMessage = ' No Billing Contact found for the Account. ';
        }        
        if(accountRecord.BillingStreet == null || accountRecord.BillingCity == null || accountRecord.BillingState == null || accountRecord.BillingPostalCode == null){
            obj.errorMessage = ' Please verify Billing Address and try adding card again';
        }      
        
        return obj;
    }
    
    public class SignatureData{
        @AuraEnabled
        public string ParametersValues;
        @AuraEnabled
        public String SignedData;
        @AuraEnabled
        public String EndPoint;
        @AuraEnabled
        public String errorMessage;
    }
}