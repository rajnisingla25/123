/********************************************************************************************
*   @Author :       Vamsi Ch 
*   @Purpose:       To Assign the Attachments to the Cloned EmailMessage 
*   @Class          InsertAttachmentsQueuable
*   @TestClass      InsertAttachmentsQueuable_Test
*   @JIRA           SEP-139
*   @CreatedDate:   July 2nd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
public class InsertAttachmentsQueuable implements Queueable {
    //Variable Declaration
    public list<emailMessage>clonedEmailMessageList{get;set;}
    public set<id> finalEmailMessageIds {get;set;}
    public boolean isOldEmailDelete{get;set;}
    
    /********************************************************************************
    Method Name: Constructor
    Description: Set the Incoming Parameters to the Variables
    Parameters:  Set<Id>,List<EmailMessage>,Boolean
    ReturnType:  None
    ********************************************************************************/
    public InsertAttachmentsQueuable(set<id> finalEmailMessageIds,List<emailMessage> clonedEmailMessageList,boolean isOldEmailDelete){
        system.debug('@@ queuable constructor');
        this.clonedEmailMessageList = clonedEmailMessageList;
        this.finalEmailMessageIds = finalEmailMessageIds ;
        this.isOldEmailDelete = isOldEmailDelete;
    }
    
    /*******************************************************************************
    Method Name: execute
    Description: Used to fetch the Attachments of existing emailMessage and Clone and
                 attach them to the New Clone EmailMessage
    Parameters:  QueueableContext
    ReturnType:  None
    *********************************************************************************/
  
    public void execute(QueueableContext context) {
        try{            
            list<Attachment> AttachmentList = new List<Attachment>();
            AttachmentList = [select id,parentId,name,body from Attachment where parentId in :finalEmailMessageIds];
            system.debug('@@ QueuableAttachmentList'+AttachmentList);            
            list<Attachment> clonedAttachmentList = new list<Attachment>();
            for(Attachment att: AttachmentList){
                for(emailMessage em: clonedEmailMessageList){
                    system.debug('@@ Queuable em.getCloneSourceId()'+em.getCloneSourceId());
                    system.debug('@@ Queuable attachment parentId'+att.parentId);
                    if(att.parentId == em.getCloneSourceId()){
                       attachment clonedAttachment = new attachment();
                       clonedAttachment = att.clone(false,true,true);
                       clonedAttachment.parentId = em.Id;
                       clonedAttachmentList.add(clonedAttachment);
                    }
                }
            }
            system.debug('@@ Queuable clonedAttachmentList'+clonedAttachmentList);
            system.debug('@@ Queuable clonedAttachmentList size'+clonedAttachmentList.size());
            if(clonedAttachmentList.size()>0)
               insert clonedAttachmentList;
            if(isOldEmailDelete){
                delete [select id from EmailMessage where id in:finalEmailMessageIds];
            }
        }
        catch(exception e){
            system.debug('@@ Queuable in exception'+e.getMessage());
        }
    }
    
}