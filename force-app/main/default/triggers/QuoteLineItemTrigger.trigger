trigger QuoteLineItemTrigger on BigMachines__Quote_Product__c (Before Delete, After Update) {
    
    QuoteLineItemTriggerHandler QuoteLineItemHandler = new QuoteLineItemTriggerHandler();
    
    if(Trigger.isAfter) {
        
        QuoteLineItemHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
       QuoteLineItemHandler.onBeforeDelete(Trigger.newMap,Trigger.oldMap);
    }
}