trigger Z_IIA_Trigger on Invoice_Item_Adjustment__c (before insert
	, before update) {

	Z_IIA_TriggerHandler handler = new Z_IIA_TriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.onBeforeInsert(Trigger.new);
  }  
  
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.onBeforeUpdate(Trigger.new);
  }

}