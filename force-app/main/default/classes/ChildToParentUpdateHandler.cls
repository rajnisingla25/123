//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : ChildToParentUpdateHandler
// This Class is Used to Upadate Parent case to closed, when all the child cases are closed. 
//
// Created 29th june 2015   Author Name:-  Vikram Thallapelli     Original
// Modified 29th june 2015   Author Name:-  Vikram Thallapelli     Modified
//**************************************************//
Public class ChildToParentUpdateHandler{
    public void onBeforeUpdate(Map<Id,Case> newitems, Map<Id,Case> olditems) {
        Set<Id> parentCaseIds =  new Set<Id>();
        for(Case C : newitems.values()){
            // ParId.add(C.Id);              
            if (c.ParentId!=null) {
                parentCaseIds.add(c.ParentId);
            }     
        }
        if (parentCaseIds.size()>0) {
            List<Case> parentCases = [Select c.IsClosed,(Select IsClosed From Cases) From Case c Where  c.Id in :parentCaseIds];                                                 
            List<Case> parentCasesToUpdate = new List<Case>();           
            for (Case parent:parentCases) {
                Boolean allChildrenClosed = true;
                //Look through each of the children if they're all closed, 
                //then close the parent, otherwise keep it open
                for (Case childCase:parent.Cases) {
                    //If any child case is not closed, allChildrenClosed will flip to false
                    //and stay that way.
                    allChildrenClosed = allChildrenClosed && childCase.IsClosed;
                }
                
                //If the parent's closed status doesn't match its children's then change it
                if (parent.IsClosed!=allChildrenClosed) {
                    parent.Status = allChildrenClosed?'Closed':'New';
                    parentCasesToUpdate.add(parent);    
                }
            }
            
            //bulk update
            if (parentCasesToUpdate.size()>0) {
                update parentCasesToUpdate;
            }
        }                           
    }
}