// (c) 2015 Appirio, Inc.  
//
// Class Name: EscalatedCaseController
// Description: Contoller Extensin for Escalating A Case
//
// 21st May 2015    Ravindra Shekhawat   Original (Task # T-397063)
//
public with sharing class EscalatedCaseController {
    
    Case parentCase = null;    
    String caseId;
    public EscalatedCaseController(ApexPages.StandardController controller) {
        parentCase = (Case)controller.getRecord();
    }
    
    
    //Prepare the Escalated Case URL
    public  PageReference prepareEscalatedChildCase() {
        PageReference pageReference = null;
        try {
            caseId = ApexPages.currentPage().getParameters().get('caseId');
            
            /**List<Case> escalatedCase = [SELECT Id FROM Case WHERE ParentId=: caseId AND Status='Escalated'];
            if(escalatedCase != null && escalatedCase.size() > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            'The Case Has Been Escalated Earlier. You Cannot Escalated It Again!'
            ));       
            return null;
            }**/
            
            List<Case> escalatedCase = [SELECT Id,Status,Priority,Origin,Type, ContactId,Area__c,CaseNumber,SubStatus__c,
                                        Sub_Area__c,Subject,Description,AccountId, Contact.Name,Account.Name FROM Case WHERE Id =: caseId];

            if(escalatedCase != null && escalatedCase.size() > 0) {
                parentCase = escalatedCase.get(0);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           'Invalid Case Id. Please Enter Correct Information!'
                                                          ));       
                return null;
            }
            
            Map<String,Custom_Field_Ids_For_Case_Escalation__c> idsMap = Custom_Field_Ids_For_Case_Escalation__c.getAll();
            
            String url = Case.SObjectType.getDescribe().getKeyPrefix() + '/e?';
            
            url += 'retURL='+parentCase.Id;
            url += '&cas28_lkid='+parentCase.Id;
            url += '&cas28='+parentCase.CaseNumber;
            
            url += '&cas7=New';
            if(parentCase.Origin != null) {
                url += '&cas11='+parentCase.Origin;
            }
            if(parentCase.Priority != null) {
                url += '&cas8='+parentCase.Priority;
            }
            if(parentCase.Type != null) {
                url += '&cas5='+parentCase.Type;
            }
            if(parentCase.ContactId != null) {
                url += '&cas3_lkid='+parentCase.ContactId;
                url += '&cas3_lkold='+parentCase.Contact.Name;
            }
            if(parentCase.AccountId != null) {
                url += '&cas4_lkid='+parentCase.AccountId;
                url += '&cas4_lkold='+parentCase.Account.Name;
            } 
            if(parentCase.Subject!= null) {
                //url += '&cas14='+parentCase.Subject;
                url += '&cas14='+EncodingUtil.urlEncode(parentCase.Subject, 'UTF-8');
				//Modified by Ravi as part of Jira ticket CRM-1523 4/24/2017
            }  
            if(parentCase.Description!= null) {
                //url += '&cas15='+parentCase.Description;
                url += '&cas15='+EncodingUtil.urlEncode(parentCase.Description, 'UTF-8');
				//Modified by Ravi as part of Jira ticket CRM-1523 4/24/2017
            }       
            
            Custom_Field_Ids_For_Case_Escalation__c temp;
            //Popuate Area From Custom Setting
            if(parentCase.Area__c != null) {
                if(idsMap != null && idsMap.size() > 0) {
                    temp = idsMap.get('Case.Area__c');
                    if(temp != null) {
                        String id = temp.Id__c;
                        if(id.length() > 15) {
                            id = temp.Id__c.substring(0,15);
                        }else {}
                        url += '&'+id+'='+parentCase.Area__c;
                    }
                }
            }
            // Populate Sub Area From Custom Setting
            if(parentCase.Sub_Area__c != null) {
                if(idsMap != null && idsMap.size() > 0) {
                    temp = idsMap.get('Case.Sub_Area__c');
                    if(temp != null) {
                        String id = temp.Id__c;
                        if(id.length() > 15) {
                            id = temp.Id__c.substring(0,15);
                        }else {}
                        url += '&'+id+'='+parentCase.Sub_Area__c;
                    }
                }
            }
            pageReference = new PageReference('/'+url +'&isdtp=vw');
            System.debug('URL Is :'+url); 

            // Commented as per LEAP-5523
           /* //update Parent case status to Escalated
            if(parentCase.Id != null){
                parentCase.status = 'Escalated';
                if(parentCase.SubStatus__c == null){
                   parentCase.SubStatus__c = 'Back Office'; 
                } 
            } */ 
            update parentCase;

        }catch(Exception e) {
            System.debug('Exception Occured: '+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       Constants.GENERIC_ERROR_MSG));
        }
        return pageReference;
    }
    
    // Redirect User Back to Parent Case
    public PageReference redirectBack() {
        PageReference pageReference = new PageReference('/'+caseId);
        return pageReference;
    }
    
}