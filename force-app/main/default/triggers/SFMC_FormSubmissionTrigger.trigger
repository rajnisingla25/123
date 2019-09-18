/*
    Trigger: SFMC_FormSubmissionTrigger.
    Purpose: SMCI-49 and SMCI-160 to create lead and engagement activity when form submission record is created/updated
    Created by: Bupendra
    Created date : 12/01/2018
    Updated by : Varun
    Updated by:  Sarang
*/
trigger SFMC_FormSubmissionTrigger on Form_Submission__c (after insert, after update) {
    
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    
    if(Dtrg != null && Dtrg.FormSubmissionTrigger__c != UserInfo.getUserName()){
        if(!SFMC_FormSubmissionTriggerHandler.fireTrigger){
            return;
        }
        if(Trigger.isAfter){
            SFMC_FormSubmissionTriggerHandler.onAfterInsertOrUpdate(Trigger.isInsert, Trigger.newMap);
        }
    }
        
}