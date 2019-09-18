trigger OrderDecompTrigger on Order (before update) {
    
    for(Order O : Trigger.new){
       // System.Debug('New: ' + O.Fulfillment_Status__c + '  Old: ' +  Trigger.oldMap.get(O.Id).Fulfillment_Status__c);
        if(O.Fulfillment_Status__c == 'Fulfilled' && Trigger.oldMap.get(O.Id).Fulfillment_Status__c != 'Fulfilled'){
    
            System.Debug('New:' + Trigger.New);
            System.Debug('Old: ' + Trigger.Old);  
            Order order = O;
            System.Debug('Order: ' + order);
            System.Debug('Order Account: ' + order.AccountId);

            OrderDecompController controller = new OrderDecompController(order);
    
        }
    }
}