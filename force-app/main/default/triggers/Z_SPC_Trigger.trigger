trigger Z_SPC_Trigger on Zuora__SubscriptionProductCharge__c (before insert, after insert) {

    //if(Test.isRunningTest() && OrderDecompController.testClassTriggerFlag == true){

    //} else {
        
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');  

    // Turn off trigger if the value of custom setting field is true. 
    if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()) {

        Z_SPC_TriggerHandler handler = new Z_SPC_TriggerHandler();

        //Set custom charge number field on insert
        if (Trigger.isBefore && Trigger.isInsert) {
            for(Zuora__SubscriptionProductCharge__c spc : Trigger.New) {
                spc.Z_Charge_Number__c = spc.Zuora__ChargeNumber__c;
            }
        }

        //Update Invoice Items to link to new SPC
        if (Trigger.isAfter && Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        }

        //Update Subscriptions to trigger updates to Assets with new Zuora information
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            handler.updateRelatedSubs(Trigger.new);
        }
    }
    //}
}