//
// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentTriggerHandler
// Description: Handler Class for CaseCommentTrigger
//
// 16th March 2015    Ravindra Shekhawat   Original (Task # T-370339)
// 9th April 2015    Kirti Agarwal   Original (Task # T-377169)
// Purpose           Used to updated Last Worked Field on Case after insert,update of case comment
//
public without sharing class CaseCommentTriggerHandler {

  private integer batchSize = 0;
  private boolean isExecuting = false;
  private CaseCommentTriggerHandlerManager commentTriggerManager = null;

  public CaseCommentTriggerHandler(Boolean isExecuting, Integer size) {
    batchSize = size;
    isExecuting = isExecuting;
    commentTriggerManager = new CaseCommentTriggerHandlerManager();
  }

 // After Insert Method of Trigger
  public void onAfterInsert(Map<Id,CaseComment> commentsMap) {
    // Do not allow the trigger to update commentCount Field if CommentCounting is off from Custom Setting
    if(Switch_CaseCommentTrigger__c.getInstance().Set_Case_Comment_Counting_Off__c == false) {
        commentTriggerManager.incrementTotalCaseCommentCount(commentsMap.values());
    }
     if(Switch_CaseCommentTrigger__c.getInstance().Set_Performance_Function_Off__c == false) {
        commentTriggerManager.updatePerformanceRecordsForServiceRep(commentsMap,false);
    }
    if(Switch_CaseCommentTrigger__c.getInstance().Set_Last_Worked_Fields_On_Case_Off__c == false) {
        commentTriggerManager.updateLastWorkedFieldsOnCase(commentsMap.values());
    }
    //this method updates casecomments field on case object
    commentTriggerManager.updateCaseComments(commentsMap.values());
  }

  // @method name : onAfterUpdate
  // @param  : Map<Id,CaseComment>
  // @return  : void
  // @purpose : Used to update case's 'Last worked' fields on case.
  public void onAfterUpdate(Map<Id,CaseComment> commentsMap) {

    if(Switch_CaseCommentTrigger__c.getInstance().Set_Last_Worked_Fields_On_Case_Off__c == false) {
        commentTriggerManager.updateLastWorkedFieldsOnCase(commentsMap.values());
    }
  }

  // After Delete Method of Trigger
  public void onAfterDelete(Map<Id,CaseComment> commentsMap){
    // Do not allow the trigger to update commentCount Field if CommentCounting is off from Custom Setting
    if(Switch_CaseCommentTrigger__c.getInstance().Set_Case_Comment_Counting_Off__c == false) {
            commentTriggerManager.decrementTotalCaseCommentCount(commentsMap.values());
    }
     if(Switch_CaseCommentTrigger__c.getInstance().Set_Performance_Function_Off__c == false) {
            commentTriggerManager.updatePerformanceRecordsForServiceRep(commentsMap,true);
    }
  }


}