//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: CaseCommentTrigger
// On SObject: CaseComment
// Description: Trigger on CaseComment to count Total Number of Comments on A Case
//
// 16th March 2015    Ravindra Shekhawat   Original (Task # T-370339)
//
// 9th April 2015    Kirti Agarwal   Original (Task # T-377169)
// Purpose           Used to updated Last Worked Field on Case after insert,update of case comment
//
trigger CaseCommentTrigger on CaseComment(after delete, after insert, after update) {

  CaseCommentTriggerHandler theCaseCommentTriggerHandler =
          new CaseCommentTriggerHandler(Trigger.isExecuting, Trigger.size);

  // Turn off trigger if the value of custom setting field is true.
  if (Switch_CaseCommentTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false && !SkipCaseCommentTrigger.skiptrigger) {
    if (trigger.isAfter) {

      if (trigger.isInsert) {
        // Increment Total Case Comment Count
       if(Commissions_TriggerHelperClass.orderItemHandler){ 
        theCaseCommentTriggerHandler.onAfterInsert(trigger.newMap);
       }
       Commissions_TriggerHelperClass.orderItemHandler = false;
      }

      //T-377169  - Added onAfterUpdate and onAfterDelete methods
      if (trigger.isUpdate) {
        theCaseCommentTriggerHandler.onAfterUpdate(trigger.newMap);
      }
      //end - T-377169

      if (trigger.isDelete) {
        if(Commissions_TriggerHelperClass.orderItemHandler){
        theCaseCommentTriggerHandler.onAfterDelete(trigger.oldMap);
        }
        Commissions_TriggerHelperClass.orderItemHandler = false;
      }
    }
  }
}