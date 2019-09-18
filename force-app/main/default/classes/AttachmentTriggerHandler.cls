public class AttachmentTriggerHandler{
 

  private integer batchSize = 0;
  private boolean isExecuting = false;
  private AttachmentTriggerHandlerManager theManager = null;
  public AttachmentTriggerHandlerManager  attachmentManager = new AttachmentTriggerHandlerManager();
  
  
  public AttachmentTriggerHandler(Boolean isExecuting, Integer size) {
    batchSize = size;
    isExecuting = isExecuting;
    theManager = new AttachmentTriggerHandlerManager();
  
    }
    
   
    
  public void OnAfterInsert(map<Id,Attachment> triggernew) {
      attachmentManager.oppSendtoDocusign(triggernew);
  
  }
 
  
  
  
    
    
}