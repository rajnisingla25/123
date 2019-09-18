/********************************************************************************************
*   @Author :       Vamsi Ch 
*   @Purpose:       To Assign the emailMessage to the right existing case 
*   @Class          AssociateEmailToCasePageController
*   @TestClass      AssociateEmailToCasePageController_Test
*   @JIRA           SEP-148
*   @CreatedDate:   July 9th, 2018
*********************************************************************************************
   JIRA No      Date            Modified By     Description                                
   CRM-4503     3-Aug-2018     Vamsi Ch        Updated the code to create case comment directly
                                                Instead of using Comments field on case
*********************************************************************************************

*/
public class AssociateEmailToCasePageController{
    //Varaibles declaration
    public EmailMessage emailMsg{get;set;}
    public id recordId{get;set;}
    
    /********************************************************************************
    Method Name: Constructor
    Description: Get the Current EmailMessage record and it's id
    Parameters:  ApexPages.StandardController
    ReturnType:  None
    ********************************************************************************/
    public AssociateEmailToCasePageController(ApexPages.StandardController controller) {
        emailMsg = (EmailMessage)controller.getRecord();
        recordId = controller.getId();
        if(recordId!=null){
            emailMsg = [select id,Internal_Comments__c,parentId,subject,textBody,htmlBody,CcAddress,BccAddress,ToAddress,FromName,FromAddress,IsExternallyVisible,Case__c,Case__r.comments from emailMessage where id=:recordId];
            emailMsg.case__c = null;
            emailMsg.Internal_Comments__c = null;
        }
    }
    
    /*******************************************************************************
    Method Name: Save
    Description: Used to clone the existing EmailMessage and assign it to a new case 
                 and delete the emailMessage
    Parameters:  None
    ReturnType:  None
    *********************************************************************************/
    public pagereference Save(){        
        try{ 
            case c;        
            if(emailMsg.Case__c!=null){
                c = [select comments,Case_Thread_Id__c from case where id =:emailMsg.Case__c];
            }   
            emailMessage newEm = new emailMessage();
            newEm = emailMsg.clone(false,true,true);
            string emailBody = emailMsg.textbody;
            string emailHtmlBody = emailMsg.htmlbody;            
            if(emailBody!=null){   
                string caseThreadId = emailBody.substringBetween('ref');
                system.debug('@@ caseThreadId'+caseThreadId);
                if(caseThreadId!=null ){
                    caseThreadId='ref'+caseThreadId+'ref';
                    newEm.TextBody = emailBody.replace(caseThreadId,c.Case_Thread_Id__c);               
                }
            }
            //CRM-4519 -- Venu Ravilla - Null check for the Text&Html body.
                if(emailHtmlBody!=null){
                    string caseHtmlThreadId = emailHtmlBody.substringBetween('ref');
                    if(caseHtmlThreadId!=null ){
                    caseHtmlThreadId='ref'+caseHtmlThreadId+'ref';
                    newEm.TextBody = emailHtmlBody.replace(caseHtmlThreadId,c.Case_Thread_Id__c);                 
                }
                }
            newEm.subject = emailMsg.subject;
            newEm.parentId = emailMsg.Case__c;
            newEm.ThreadIdentifier = c.Case_Thread_Id__c;
            insert newEm;
                        
            //Create CaseComment Record
            if(emailMsg.Internal_Comments__c!=null){
                CaseComment cc = new CaseComment();
                cc.CommentBody = emailMsg.Internal_Comments__c;
                cc.ParentId = emailMsg.Case__c;
                insert cc ;
            }
            set<id> finalEmailMessageIds = new set<id>();
            list<EmailMessage> clonedEmailMessageList = new list<EmailMessage>();
            finalEmailMessageIds.add(emailMsg.Id);
            clonedEmailMessageList.add(newEm);
            //Invoke Queueable Apex to Insert Attachments related to the cloned Email messages
            System.enqueueJob(new InsertAttachmentsQueuable(finalEmailMessageIds,clonedEmailMessageList,true));       
            return new pagereference('/'+newEm.parentId);
        }
        catch(exception e){
            system.debug('@@ in exception save method'+e.getMessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
            return null;
        }
        
    }
}