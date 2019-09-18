trigger AttachmentTrigger on Attachment (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    AttachmentTriggerHandler TriggerHandler = new AttachmentTriggerHandler(trigger.isExecuting,trigger.size);

    if(Trigger.isInsert){
        if(trigger.isAfter){
            TriggerHandler.OnAfterInsert(trigger.newmap);
        }
    }
    
    If(Trigger.isbefore && Trigger.isdelete){
       string username = userinfo.getUserName();
       string profileid = userinfo.getProfileId();
       profileid = profileid.substring(0,15); 
        
       Attachmentactivitydeleteaccess__c userdata = Attachmentactivitydeleteaccess__c.getinstance(username);
       Attachmentactivitydeleteaccess__c prfldata = Attachmentactivitydeleteaccess__c.getinstance(profileid);
        
        if(userdata == null && prfldata == null){
           for(Attachment attchloop : trigger.old){
               attchloop.addError('You don\'t have permission to delete Attachments');
           }
        }
    }
   
}