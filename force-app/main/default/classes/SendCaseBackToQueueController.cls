//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : SendCaseBackToQueueController
// This Class is Used to send the  case to return to Queue based on the Assignment rules. 
//
// Created  - 5th  Aug  2015   Author Name:-  Kalyan Meda     Original
// Modified - 26th Aug  2015   Author Name:-  Kalyan Meda     Modified
// Modified - 10th Sept 2015   Author Name:-  Kalyan Meda     Modified
// Modified - 14th Oct  2015   Author Name:-  Kalyan Meda     Modified - LEAP-5489
//**************************************************//


Global with sharing class SendCaseBackToQueueController {
   
    //public Case selectedCase  {get;set;}
    //Global PageReference pRef {get;set;}
    
    
    Webservice Static String triggerAssignmentRules(ID caseID_pKey){
        PageReference pRef ;
        Id caseId = caseID_pKey ;
        String result ;
        //ApexPages.currentPage().getParameters().get('caseId');
        Profile p = [select name from Profile where id =:UserInfo.getProfileId()];
        
        if([SELECT Ownership_Type__c from Case WHERE id=:caseId].Ownership_Type__c == 'Queue'){
            result = 'Queue';
            return result ; 
        }
        else{
            result =  reassignCaseWithActiveRule(caseId);
            return result ;
        }    
           
    }
    
    
    public static String  reassignCaseWithActiveRule(ID myCaseId) {
        
        String errorMessage = 'success' ;
        //fetching the desired assignment rules on Case...
        AssignmentRule AR = new AssignmentRule();
        AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT  1];
        
        //recreating the DMLOptions setting for "Assign using active assignment rules" checkbox on Case object...
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        //get current instance of sObject (Case)...
        Case myCase = [SELECT Id FROM Case WHERE Id =: myCaseId LIMIT 1];
        
        //set DMLOptions on this record so it will be processed using assignment rules...
        myCase.setOptions(dmlOpts);
      //myCase.description += 'processed w/ @future on '+ dateTime.now();
        
        try{
             update myCase; 
                  //if(Test.isRunningTest())//Added to cover the Exception in Test class
                  //  integer intTest =1/0; 
 
        }catch(DMLException e){
           system.debug('TRACE: Return to queue failure : '+ e.getMessage()); 
           errorMessage = e.getDmlMessage(0);
        }
        return errorMessage;
    
    }   
}