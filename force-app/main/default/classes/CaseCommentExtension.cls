// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentExtension
// Description: Contoller Class for CaseComment Related List
//
// 26th March 2015    Ravindra Shekhawat   Original (Task # T-373931)
//21 April 2016 Krishna Bodala LEAP-8453 - To show up the child case comments related list too
public without sharing class CaseCommentExtension {
    public Case caseRec;
    public String parentCaseId {get; set;}
    public list<Id> childCaseIds {get;set;}

    public CaseCommentExtension(ApexPages.StandardController controller) {
        caseRec = (Case)controller.getRecord();
        caseRec = [SELECT Id,ParentId FROM Case WHERE Id=:ApexPages.currentPage().getParameters().get('id')];
        parentCaseId = caseRec.ParentId;

        childCaseIds = new list<Id>();
        //get child case Ids for a parent case
        for(Case childCase : [select Id from Case where ParentId = :caseRec.Id]){
            childCaseIds.add(childCase.Id);
        }

    }
 }