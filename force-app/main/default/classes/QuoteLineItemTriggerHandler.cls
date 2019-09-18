public class QuoteLineItemTriggerHandler {
    
     public QuoteLineItemTriggerHandler() {
    }

     // After Insert Method of Trigger
    public void onAfterUpdate(Map<Id,BigMachines__Quote_Product__c> QuoteProductMap, Map<Id,BigMachines__Quote_Product__c> QuoteProductoldMap) {
        QuoteLineItemTriggerHandlerManager quoteLineItemHandlerManager = new QuoteLineItemTriggerHandlerManager();
        quoteLineItemHandlerManager.updateAsset(QuoteProductMap, QuoteProductoldMap);
        quoteLineItemHandlerManager.deleteQuoteProduct(QuoteProductMap, QuoteProductoldMap);
        quoteLineItemHandlerManager.approveQuote(QuoteProductMap, QuoteProductoldMap); // CRM-6197, CRM-6063 & CRM-6098 - Auto approve Quote once all Focus Fire Setup is done
        
    }
    
    public void onBeforeDelete(Map<Id,BigMachines__Quote_Product__c> QuoteProductMap, Map<Id,BigMachines__Quote_Product__c> QuoteProductoldMap) {
        QuoteLineItemTriggerHandlerManager quoteLineItemHandlerManager = new QuoteLineItemTriggerHandlerManager();
        quoteLineItemHandlerManager.updateNotRenewAsset(QuoteProductMap, QuoteProductoldMap);
    }
}