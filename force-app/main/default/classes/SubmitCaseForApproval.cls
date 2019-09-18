global class SubmitCaseForApproval {

    
   public void SubmitForApproval(){
   }
        
    
    webService static void handleApproval(Id caseID){
        
        
        Case c = [SELECT id FROM CASE WHERE id =: caseId];
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(c.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(Userinfo.getUserId()); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId(null); //'PTO_Request_Process'
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
       
        
    }
    
   }