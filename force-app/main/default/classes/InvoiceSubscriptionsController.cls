public with sharing class InvoiceSubscriptionsController {
 	
    Public List < Invoice_Item__c > invoiceItem {get;set;}
    public ID invoiceId;

    public InvoiceSubscriptionsController(ApexPages.StandardController controller) {

        Map < Id, List < Zuora__Subscription__c >> mapZoura = new Map < Id, List < Zuora__Subscription__c >> ();
        Set < Id > setAccountIds = new Set < Id > ();
        invoiceId = ApexPages.CurrentPage().getParameters().get('id');
        invoiceItem = [SELECT ID, name, Quantity__c, Subscription__r.Name, Subscription__r.Zuora__Account__r.Name, Asset__r.Name,
                       Subscription__r.Zuora__SubscriptionStartDate__c, Subscription__r.Zuora__SubscriptionEndDate__c,
                       Subscription__r.Zuora__NextRenewalDate__c FROM Invoice_Item__c WHERE Invoice__c = : invoiceId];

        If(invoiceItem.size()==0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Could not find any Subscriptions'));                
            
        }

    }
}