trigger NotesTrigger on Note (before delete) {
    
    If(Trigger.isbefore && Trigger.isdelete){
        string username = userinfo.getUserName();
        string profileid = userinfo.getProfileId();
        profileid = profileid.substring(0,15); 
        
        Attachmentactivitydeleteaccess__c userdata = Attachmentactivitydeleteaccess__c.getinstance(username);
        Attachmentactivitydeleteaccess__c prfldata = Attachmentactivitydeleteaccess__c.getinstance(profileid);
        
        if(userdata == null && prfldata == null){
            for(Note attchloop : trigger.old){
                attchloop.addError('You don\'t have permission to delete Notes');
            }
        }
    }
}