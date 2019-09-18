//****************************************************************************************
//Name          : OrderItemTrigger
//Date          : 16-DEC-2015
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : This Trigger is the place holder for all Order Product (Order Item) events
//               
// *****************************************************************************************

trigger OrderItemTrigger on OrderItem (after insert, after update) {
    if(!SkipOrderItemTrigger.skiptrigger){
        if(OrderDecompController.testClassTriggerFlag == true && test.isRunningTest()){
            
        }  else if(Commissions_TriggerHelperClass.orderItemHandler){
            If(Trigger.isAfter && Trigger.isUpdate){
                //CRM-5460- Moved the method to Future Handler.
                set<Id>orderitemids = new set<Id>();
                for(OrderItem ordi:Trigger.new){
                    If(ordi.Fulfillment_Status__c == 'Fulfilled'){
                        orderitemids =Trigger.newmap.keyset();
                    }
                } 
                System.debug('Number of Orderitems coming Here are' +orderitemids.size());
                if(!orderitemids.isempty() || test.isRunningTest()){
                    if(system.isFuture() || system.isBatch()){
                        OrderItemTriggerHandler.updateCaseAssetRelationshipInNonFuture(orderitemids);   
                    }
                    else{
                        OrderItemTriggerHandler.updateCaseAssetRelationshipInFuture(orderitemids);   
                    }
                    
                    // CRM-3192 - Commented below line to run the trigger each time.
                    //Commissions_TriggerHelperClass.orderItemHandler = false;
                }
            }
        }
        
        //Added by Pratik on 13th December 2018 for CRM-3405
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            /*if(Trigger.isInsert)
{
OrderItemTriggerHandler.handleAfterInsert(Trigger.new);
}*/
            //if(Trigger.isUpdate && !OrderItemTriggerHandler.IsOrderTgrExecuted)
          //  if(Trigger.isUpdate) {
                for(OrderItem item:Trigger.new){
                    If(item.Fulfillment_Status__c == 'Fulfilled' && trigger.oldmap.get(item.id).Fulfillment_Status__c != 'Fulfilled'){
                        System.debug('The value coming here*Ra#v##ill#a#'+item.Account_Type__c);
                    
                            OrderItemTriggerHandler.handleAfterInsert(Trigger.new);                                                                                                                                                                                                                                                           
                    }
                }
            //}
            //Ends here
        }
    }
}