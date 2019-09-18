/*
    Trigger: Engagement Activity Type Trigger.
    Purpose: Whenever any update, recalculate score
    Created by: Varun
    Created date : 1/4/2018
*/
trigger SFMC_EngagementActivityTypeTrigger on Engagement_Activity_Type__c (after update) {
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    
    if(Dtrg != null && Dtrg.EngagementActivityTypeTrigger__c != UserInfo.getUserName()){
        if(Trigger.isafter){
            if(Trigger.isupdate){
                system.debug('-->> calling lead score batch');
                SFMC_EngagementActivityTypeTriggerHelper.checkForLeadScoreCalBatch(trigger.oldMap, trigger.newMap);
            }
        }
    }
}