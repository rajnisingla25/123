trigger Z_II_Trigger on Invoice_Item__c (before insert, after insert) {
//trigger Z_II_Trigger on Invoice_Item__c (before insert, before update) {

    Z_II_TriggerHandler handler = new Z_II_TriggerHandler();
    
    if (Trigger.isInsert && Trigger.isBefore) {
    //if (Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isInsert && Trigger.isafter) {
        handler.onafterInsert(Trigger.new);
    }

}