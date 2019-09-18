trigger WaitlistItemtrigger on Waitlist_Item__c (before update,before insert,after insert, after update) {
     if (Bypass_Rules_and_Triggers__c.getInstance().Disable_WaitlistItem_Trigger__c == false) {    
        WaitlistItemtriggerHandler Handler =new WaitlistItemtriggerHandler();
         
        
         if(trigger.isBefore &&trigger.isUpdate &&!(waitlistitemTriggerHandler.skipbeforeupdaterun)){
            Handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
            Handler.onBeforeUpdateOnDocuSignAmend(trigger.new[0] , trigger.old[0]);
            
        }
         
         
        if(trigger.isAfter &&(trigger.isUpdate) && !(waitlistitemTriggerHandler.skipafterupdaterun)){
 		   Handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
         Handler.onAfterUpdateOnDocuSignAmend(trigger.new[0] ,trigger.old[0] );
            Handler.waitListItemStatusToAccMaxSpend(trigger.new);
        }
       }
 }