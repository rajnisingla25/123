global class BatchProcessQuoteQuickFulfill implements Database.Batchable<sObject>{
global String query;
global Set<Id> QuoteId = new Set<Id>();
global Set<Id> setBMQIds;
global Set<Id> setAccIds;
global Set<Id> theOrderIdsToProcess = new Set<Id>(); 
    global Database.querylocator start(Database.BatchableContext BC){
        
        Query = 'SELECT   Id FROM Account where Id=:setAccIds';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
    
       //QuoteToOrderHelperCls QTOH = new QuoteToOrderHelperCls();
       theOrderIdsToProcess = QuoteToOrderHelperCls.CreateOrderOnApprovalMethod(setBMQIds,setAccIds);
       System.debug('Order Ids'+theOrderIdsToProcess);
    }

    global void finish(Database.BatchableContext BC){
    Set<Id> setIds = new Set<Id>();
    System.debug('Order Ids'+theOrderIdsToProcess);
    List<Order> lstOrder =    [Select Id,Is_OLI_Creation_Complete__c from order where Oracle_Quote__c=:setBMQIds and EffectiveDate<=Today and Is_OLI_Creation_Complete__c=false];
    for(Order ord:lstOrder){
    setIds.add(ord.id);
    ord.Is_OLI_Creation_Complete__c = true;
    }
    update lstOrder;
    
    }
}