public class FollowUpUpdateController {
    public List<Case> selectedCases {get;set;}
    public Case objCase {get;set;}
    //List<CaseComment> childCom = new List<CaseComment>();
    string strReturnURL;
    //Map<Id,CaseComment> cMap = new Map<Id,CaseComment>();

    public FollowUpUpdateController(ApexPages.StandardSetController controller) {
        selectedCases = controller.getSelected();
        
        strReturnURL = ApexPages.currentPage().getParameters().get('retURL');
        objCase = new Case();
        
    } 
    
    public pagereference updateCases(){
        List<Case> lstCaseUpdate = new List<Case>();
          
        
        if(!selectedCases.isEmpty()){

            for(Case cas: selectedCases){
                cas.Followup_Status__c = objCase.Followup_Status__c;      
                cas.Cancel_Reason__c  = objCase.Cancel_Reason__c ;
                cas.Comments__c  = objCase.Comments__c ;
                
                /*CaseComment newCom = new CaseComment();
                            newCom.CommentBody = objCase.Comments__c ;
                            newCom.IsPublished = TRUE;
                            newCom.ParentId = cas.id;
                            childCom.add(newcom);*/
                   

     if(objCase.Followup_Status__c == 'Cancel' && objCase.Cancel_Reason__c == null ){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Once the Follow Up status on Case is set to \'Cancel\', Case Reason has to be populated.'));              
         
        return null;  
               
       }else{            
                lstCaseUpdate.add(cas);
                //insert childCom; 
               }
            } 

            if(!lstCaseUpdate.isEmpty()){
                update lstCaseUpdate;
                pagereference pr = new pagereference(strReturnURL);
                return pr;
            }
        }
 return null;       
    }
}