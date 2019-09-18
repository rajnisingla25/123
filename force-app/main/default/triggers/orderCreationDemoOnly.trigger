trigger orderCreationDemoOnly on BigMachines__Quote__c (after update) {
    List<Id> quotesInScope = new List<Id>();
    for (BigMachines__Quote__c quote : Trigger.new) {
        BigMachines__Quote__c oldQuote = Trigger.oldMap.get(quote.Id);
        if(oldQuote.BigMachines__Status__c != 'Approved' && 
           quote.BigMachines__Status__c == 'Approved'){
               quotesInScope.add(quote.Id);
        }
    }
    if(!quotesInScope.isEmpty()){
        List<Order> orders = new List<Order>();
        Map<Id, Id> qId2oId = new Map<Id, Id>();
        for (Id qId : quotesInScope){
            Order ord = new Order(
                Pricebook2Id='01sj0000001No5z',
                Oracle_Quote__c=qId,
                AccountId='001g000000Ya1x1',
                ContractId='800g00000021gpD',
                Description='Demo',
                Status='Complete',
                EffectiveDate=Date.today(),
                Is_OLI_Creation_Complete__c=true,
                Fulfillment_Status__c='Fulfilled'
            );
            orders.add(ord);
        }
        insert orders;
        for(Order o: orders){
            qId2oId.put(o.Oracle_Quote__c,o.Id);
        }
        List<OrderItem> items = new List<OrderItem>();
        List<BigMachines__Quote_Product__c> qProducts = [
                    SELECT Id, BigMachines__Quote__c, Name,BigMachines__Product__c, BigMachines__Quantity__c,Extended_Net_Price__c                                      
                     FROM BigMachines__Quote_Product__c 
                     WHERE BigMachines__Quote__c IN :quotesInScope];
        for(BigMachines__Quote_Product__c prod : qProducts){
            Id qId = prod.BigMachines__Quote__c;
            Id oId = qId2oId.get(qId);
            OrderItem oProd = new OrderItem(
                OrderId=oId,
                Quantity=prod.BigMachines__Quantity__c,
                PricebookEntryId='01tg0000002IzKb',
                Product_Account__c='001g000000Ya1x1',
                Part_Number__c='2c92c0f84c74f855014c9079a4e452fa',
                Line_Type__c='Add',
                Billing_Period__c=prod.Billing_Period__c,
                Contract_Term__c='6',
                Subscription_Term__c='Termed'
            );
            items.add(oProd);
        }
        insert items;
    }
}