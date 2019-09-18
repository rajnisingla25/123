trigger MLSTrigger on MLS__c (after insert,after update) {
DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
  // Turn off trigger if the value of custom setting field is true. 
  if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
 

MLSTriggerHandler handler = new MLSTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            handler.onAfterinsertUpdate(trigger.newmap,trigger.oldmap);
        }
    }
  }
}