// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentTriggerHandlerManager
// Description: Manager Class for CaseCommentTriggerHandler
//
// 16th March 2015    Ravindra Shekhawat   Original (Task # T-370339)
// 31st March 2015    Ravindra Shekhawat   Modified For ( Task # T-374731)
// 9th April 2015     Kirti Agarwal   Original (Task # T-377169)
// Purpose            Used to updated Last Worked Field on Case after insert,update of case comment
//
public without sharing class CaseCommentTriggerHandlerManager {



    //method to decrement TotalCaseComment when a Comment is Deleted from a Case
    public void decrementTotalCaseCommentCount(List<CaseComment> comments){
        Map<Id,List<CaseComment>> mapCaseToUpdate = getCaseIdsToUpdate(comments);
        List<Case> casesToUpdate = new List<Case>();
        for(Case caseUp: [SELECT Id,Case_Comment_Count__c,Status,ParentId FROM Case  WHERE Id in: mapCaseToUpdate.keySet()]){
            caseUp.Case_Comment_Count__c = caseUp.Case_Comment_Count__c - mapCaseToUpdate.get(caseUp.Id).size();
           if(caseup.ParentID == null)
            casesToUpdate.add(caseUp);
        }
         if(!casesToUpdate.isEmpty())

        update casesToUpdate;
        // Update CaseHistory For Updating the CaseComment Count
        if(Switch_CaseTrigger__c.getInstance().Set_Case_History_Tracking_Off__c == false){
            updateCaseResolutionTracking(comments,true);
        }
    }

    // Method to Incremnt TotalCaseComment when A comment is Added to a Case
    public void incrementTotalCaseCommentCount(List<CaseComment> comments){
        Map<Id,List<CaseComment>> mapCaseToUpdate = getCaseIdsToUpdate(comments);
        List<Case> casesToUpdate = new List<Case>();
        for(Case caseUp: [SELECT Id,Case_Comment_Count__c,Status,ParentId FROM Case  WHERE Id in: mapCaseToUpdate.keySet()]){
            if(caseUp.Case_Comment_Count__c == null){
                caseUp.Case_Comment_Count__c = 0;
            }
            caseUp.Case_Comment_Count__c = caseUp.Case_Comment_Count__c + mapCaseToUpdate.get(caseUp.Id).size();
            if(caseup.ParentID == null)
            casesToUpdate.add(caseUp);
        }
        if(!casesToUpdate.isEmpty())

        update casesToUpdate;
        // Update CaseHistory For Updating the CaseComment Count
        if(Switch_CaseTrigger__c.getInstance().Set_Case_History_Tracking_Off__c == false){
          updateCaseResolutionTracking(comments,false);
        }
        /*
        // Enforce SLA Setting on Case
        if(Switch_CaseTrigger__c.getInstance().Set_SLA_Functionality_Off__c == false) {
          updateSLASettings(comments); 
        }*/

    }

    // Get Case Ids to Update Total Comment Counts
    private  Map<Id,List<CaseComment>> getCaseIdsToUpdate(List<CaseComment> comments){

         Map<Id,List<CaseComment>> mapCaseToUpdate = new Map<Id,List<CaseComment>>();

         for(CaseComment comment : comments){
            if(mapCaseToUpdate.containsKey(comment.ParentId)){
                List<CaseComment> lst = mapCaseToUpdate.get(comment.ParentId);
                lst.add(comment);
                mapCaseToUpdate.put(comment.ParentId,lst);
            }else{
               List<CaseComment> lst = new List<CaseComment>();
               lst.add(comment);
               mapCaseToUpdate.put(comment.ParentId,lst);
            }

        }
        return mapCaseToUpdate;
    }


   // This Method inserts / Deletes A performance Object based on A CaseComment and Status
   public void updatePerformanceRecordsForServiceRep(Map<Id,CaseComment> commentsMap, boolean isDelete) {
    Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID,DeveloperName, Name From RecordType Where sObjectType = 'Case']);
    Map<Id,List<CaseComment>> mapCaseToUpdate = getCaseIdsToUpdate(commentsMap.values());
    List<Case_Performance__c> casePerformances = new List<Case_Performance__c>();
    Map<Id,Case> caseStatus = getCaseDetails(mapCaseToUpdate.keySet());
    boolean createperf = true;
       
       //Collect all comments parent id's
       set<id> cmntparentids = new set<id>();
       for(CaseComment csecmntlp : commentsMap.values()){
           cmntparentids.add(csecmntlp.ParentId);
       }

       //Collect all cases for casecomment parent id's
       map<id,Case> allcases = new Map<id,Case>([select id,ParentId from Case where Id in :cmntparentids]);
       set<id>cmntparentprntids = new set<id>();
       for(Case cselp : allcases.values()){
           cmntparentprntids.add(cselp.ParentId);
       }

       //Collect all comments for parent id's
       list<CaseComment> cseprntcmnts = [select ParentId,CommentBody from CaseComment where ParentId in :cmntparentprntids];
       
       // Check if C ase Comment Was Deleted, If yes Delete the respective Entries of Case_Performances too
       if(isDelete) {
           casePerformances = [SELECT Id,Case_Comment_Id__c FROM Case_Performance__c where Case_Comment_Id__c in : commentsMap.keySet()];
           if(casePerformances !=null && casePerformances.size()<>0) {
               delete casePerformances;
           }
       }   else {
           for(CaseComment comment : commentsMap.values()) {
               if(allcases.get(comment.ParentId).ParentId != null){
                   for(CaseComment csscmnlp : cseprntcmnts){
                       if(allcases.get(comment.ParentId).ParentId == csscmnlp.ParentId &&
                           csscmnlp.CommentBody == comment.CommentBody){
                           createperf = false;
                       }
                   }
                   if(createperf){
                       Case_Performance__c perform = new Case_Performance__c(
                           Case__c = comment.ParentId,
                           Case_Comment_Id__c = comment.Id,
                           Case_Status__c = caseStatus.get(comment.ParentId).Status,
                           Case_Record_Type__c = rt_map.get(caseStatus.get(comment.ParentId).RecordTypeId).DeveloperName,
                           Agent__c = UserInfo.getUserId()
                       );
                       casePerformances.add(perform);
                       createperf = false;
                   }
               }else{
                   Case_Performance__c perform = new Case_Performance__c(
                       Case__c = comment.ParentId,
                       Case_Comment_Id__c = comment.Id,
                       Case_Status__c = caseStatus.get(comment.ParentId).Status,
                       Case_Record_Type__c = rt_map.get(caseStatus.get(comment.ParentId).RecordTypeId).DeveloperName,
                       Agent__c = UserInfo.getUserId()
                   );
                   casePerformances.add(perform);
               }
           }
           insert casePerformances;
       }   // End Of Else
   }

   // This Method fetches the Status Of Case Base on The Case Ids
   // Returns A Map of <CaseID,Case Status>
   private Map<ID,Case> getCaseDetails(Set<Id> caseIds){
        Map<Id,Case> caseStatusMap = new Map<Id,Case>();
        for(Case caseTemp : [SELECT Id,Status,RecordTypeId FROM Case where Id in: caseIds]){
            caseStatusMap.put(caseTemp.Id,caseTemp);
        }
        return caseStatusMap;
   }

   // This Method used to update case and parent case's field Last_Worked__c and Last_Worked_By__c
   // Task : T-377169
   // Created By : Kirti Agarwal
   public void updateLastWorkedFieldsOnCase(List<CaseComment> caseComments) {
       Set<Id> caseIDs = new Set<Id>();
       Set<Id> parentCaseIDs = new Set<Id>();

       //create set of case ids for case comment
       for(CaseComment comment : caseComments) {
         caseIDs.add(comment.ParentId);
       }

       //create case map from all case ids
       Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id,Last_Worked__c,Last_Worked_By__c,ParentId FROM Case
                                                                                             WHERE ID IN : caseIDs]);
      //create parent case Ids from all case ids
      for(Case caseRec : caseMap.values()) {
         if(caseRec.ParentId != null) {
           parentCaseIDs.add(caseRec.ParentId);
         }
      }

      //add parent case to the case map
      for(Case parentCase :  [SELECT Id,Last_Worked__c,Last_Worked_By__c,ParentId FROM Case
                                                               WHERE ID IN : parentCaseIDs]) {
        caseMap.put(parentCase.Id, parentCase);
      }
      
      //populate Last_Worked_By__c and Last_Worked__c field on case
      for(Case cas : caseMap.values()) {
        cas.Last_Worked_By__c = UserInfo.getUserId();
        cas.Last_Worked__c = datetime.now();
      }

      //update all case and parent case
      if(!caseMap.isEmpty()) {
        update caseMap.values();
      }
   }

   // This Method Updates the Comment Count Case Resolution History Records for the Specified Case
   private void updateCaseResolutionTracking(List<CaseComment> caseCommentList,Boolean isDelete){

     Set<String> owners = new Set<String>();
     Set<String> statuses = new Set<String>();

         Map<Id,List<CaseComment>> casesList = getCaseIdsToUpdate(caseCommentList);
         Map<Id,Case_Resolution_Tracking__c> caseResoMap = new Map<Id,Case_Resolution_Tracking__c>();
         List<Case> cases  = [SELECT Id,Owner.Name,Status from Case where Id in: casesList.keySet()];
         List<Case_Resolution_Tracking__c> caseResolutionList = new List<Case_Resolution_Tracking__c>();
        
         // Prepare Set for Case Owner and Status
         for(Case c : cases){
             statuses.add(c.Status);
             owners.add(c.Owner.Name);
         }

        
         // Get the Case Resolution Track Objects for Current Case,Status,Owner Combination
     List<Case_Resolution_Tracking__c> caseResolutionTrackList = [SELECT Id,Comment_Count__c,New_Status__c,Owner_Name__c,Case__c FROM
                                                                             Case_Resolution_Tracking__c  WHERE Case__c in: casesList.keySet() AND New_Status__c in : statuses AND Owner_Name__c in : owners order by  CreatedDate desc];
        
        
        // Prepare Map for CaseID and respective CaseResolution Track Object
        for(Case_Resolution_Tracking__c crt : caseResolutionTrackList){
            if(!caseResoMap.containsKey(crt.Case__c)){
                caseResoMap.put(crt.Case__c,crt);
            }
        }

        // Update the Comment Count for Case Resolution Tracking
        for(Id tempId : casesList.keySet()){
            Case_Resolution_Tracking__c caseResolutionTemp = caseResoMap.get(tempId);
            if( caseResolutionTemp != null ){
                if(isDelete){
                    caseResolutionTemp.Comment_Count__c = caseResolutionTemp.Comment_Count__c - casesList.get(tempId).size();
                }else{
                    caseResolutionTemp.Comment_Count__c = caseResolutionTEmp.Comment_Count__c + casesList.get(tempId).size();
                }
            caseResolutionList.add(caseResolutionTemp);
            }
        }

        //Check If Any Case Resolution to Update
        if(caseResolutionList.size()>0){
            update caseResolutionList;
        }
     
   }
    
   // This Method Updates the case Comment on case object
   Public void updateCaseComments(List<CaseComment> caseCommentList){
       List<Case> casesToUpdate = new List<Case>();
       for(CaseComment tempId : caseCommentList){
           Case tempcase = new Case();
           tempcase.id = tempId.parentid;
           tempcase.CaseComments__C = tempId.CommentBody;
           casesToUpdate.add(tempcase);
       }
       update casesToUpdate;
   }    

}