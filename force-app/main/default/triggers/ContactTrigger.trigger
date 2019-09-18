//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: ContactTrigger
// On SObject: Contact
// Description: Trigger on contact to prevent inactivating a contact when contact is primary on any account in account relationship object.
//
// 13th March 2015    Hemendra Singh Bhati   Original (Task # T-369907)
// 23rd March 2015    Hemendra Singh Bhati   Modified (Task # T-372662) - Complete Code Re-factored.
// 6th April 2015    Kirti Agarwal   Original (Task # T-376542)
//
trigger ContactTrigger on Contact (before update, after update, after insert) {
  // Instantiating Contact Trigger Handler.
  DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
  // Turn off trigger if the value of custom setting field is true. 
  if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
  ContactTriggerHandler theHandler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);

  // Turn off trigger if the value of custom setting field is true.
  if(Switch_ContactTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
    if(trigger.isBefore && trigger.isUpdate) {
      theHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    }

    if(trigger.isAfter) {
      if(trigger.isUpdate) {
        theHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
      }

      if(trigger.isInsert) {
        theHandler.onAfterInsert(trigger.newMap);
      }
    }
   } 
  }
}