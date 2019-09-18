public with sharing class TaskHelper {
    public static final string DIVIDER = '--------Save your notes above this line--------';
    private static Map<String, String> allNotes = new Map<String, String>();
    private static Map<String, User> allUsers = new Map<String, User>();
      
    public static void createUsersLookup (List<Task> newTasks) {
        Set<Id> setProfileIds = new Set<Id>();
        for(Profile prf:[SELECT Id,UserLicense.Name FROM Profile where UserLicense.Name = 'Salesforce']){
        setProfileIds.add(prf.Id);
        }
        List<User> users = [Select ID, FirstName, LastName, Name from User where ProfileId=:setProfileIds];    
        for (User a : users) {
            allUsers.put(a.ID, a);
        }
        System.debug('Size of allUsers is ' + allUsers.size());
    }
      
    public static void createInteractionEventNotesLookup (List<Task> newTasks) {
      
        //Build parent and child list of all Interaction Events and Interaction Notes
        List <NVMContactWorld__InteractionEventNote__c> conList = New List<NVMContactWorld__InteractionEventNote__c>();
        String combinedNote;
        String guid;
        String newGuid;
        String oldGuid;
      
        List<String> TaskCallGuids = new List<String> ();
        for (Task ss : newTasks) {
            TaskCallGuids .Add (ss.CallObject);
        }
        Boolean runCommentAdd = true;
        for(NVMContactWorld__InteractionEvent__c event:
            [Select id, name, NVMContactWorld__Agent__c,
            NVMContactWorld__IndexedCallObjectIdentifier__c,
            (SELECT Name,  CreatedDate, NVMContactWorld__Detail__c
            FROM NVMContactWorld__Interaction_Event_Notes__r)
            From NVMContactWorld__InteractionEvent__c
            WHERE NVMContactWorld__IndexedCallObjectIdentifier__c IN :TaskCallGuids
            ORDER BY NVMContactWorld__TimeStamp__c ASC NULLS FIRST]){
            //System.debug('Outside of loop ' + event.NVMContactWorld__IndexedCallObjectIdentifier__c);
            combinedNote = Null;
           // Boolean allInteractionNull = true;
            
            //Loop through child records
            for(NVMContactWorld__InteractionEventNote__c note:event.NVMContactWorld__Interaction_Event_Notes__r){
                //Change ID for real name
                
                //if (note.NVMContactWorld__Detail__c != Null && event.NVMContactWorld__Interaction_Event_Notes__r.size()==1) {noteDetail = 'This agent saved no notes';}
                if (note.NVMContactWorld__Detail__c != Null) {
                User createdByName = allUsers.get(event.NVMContactWorld__Agent__c);
                newGuid = event.NVMContactWorld__IndexedCallObjectIdentifier__c;
                //System.debug('Debug element ' + note);
                //We need to merge single records into 1
                String noteDetail;
                if (note.NVMContactWorld__Detail__c != Null) {
                    //System.debug('This agent saved no notes');
                    noteDetail = note.NVMContactWorld__Detail__c;
                }
                else {
                    noteDetail = 'This agent saved no notes';
                }
                conList.add(note);
                //Create the actual string
                if(createdByName==null){combinedNote = noteDetail + '\r\n';}else{
                if(runCommentAdd){combinedNote = createdByName.Name + ' | on ' + note.CreatedDate + ' | ' + noteDetail + '\r\n';
                runCommentAdd = false;
                } else{
                combinedNote = noteDetail + '\r\n';
                }
                }
                
                guid = event.NVMContactWorld__IndexedCallObjectIdentifier__c;
                if (allNotes.get(event.NVMContactWorld__IndexedCallObjectIdentifier__c) == Null) {
                    //System.debug('Map not created - create it');
                    allNotes.put(guid, combinedNote);
                }
                else {
                    //System.debug('Map already created - update it');
                    String oldNotes = allNotes.get(event.NVMContactWorld__IndexedCallObjectIdentifier__c);
                    //System.debug('oldNotes is ' + oldNotes);
                    String extraCreatedInfo = '';
                    if(!oldNotes.contains(createdByName.Name)){
                    extraCreatedInfo = createdByName.Name + ' | on ' + note.CreatedDate + ' | ';
                    }
                    allNotes.put(event.NVMContactWorld__IndexedCallObjectIdentifier__c, oldNotes + ' \r\n' + extraCreatedInfo+  combinedNote);
                    //System.debug('allNotes is ' + allNotes.values());
                }
                } else{
                User createdByName = allUsers.get(event.NVMContactWorld__Agent__c);
                if(runCommentAdd && createdByName!=null){
                allNotes.put(event.NVMContactWorld__IndexedCallObjectIdentifier__c, createdByName.Name+' | '+note.CreatedDate + ' | ');
                runCommentAdd = false;
                }
                }
            } //end outer for
        }
    }
    public static void processTasks(List<Task> newTasks) {
       
        createUsersLookup (newTasks);
        createInteractionEventNotesLookup (newTasks);
        System.debug('Starting class');
        //Loop through Task records and get GUIDs to query Interaction Events - checking that it is only NVM Tasks
        for (Task ss : newTasks) {
            if (ss.CallType == Null || ss.CallObject == Null) continue;
            //Final call to the built map to populate description
            String oldValue = ss.Description;
            If (ss.Description == Null) {
             if(ss.whatId!=null && Schema.Case.SObjectType==ss.whatId.getSobjectType()){
                ss.Description = '\r\n' +ss.NVM_Disposition__c+' | ' + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
               } else {
               ss.Description = '\r\n' + DIVIDER + '\r\n' + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
               }
                if(ss.Description.length()<255){
                ss.NVM_Notes__c = ss.Description;
                } else {
                //ss.NVM_Notes__c = ss.Description.substring((ss.Description.length()-250), ss.Description.length());
                ss.NVM_Notes__c = ss.Description.substring(0, 250);
                } 
            }
            else if (oldValue.contains(DIVIDER)) {
                Integer thingsToRemove = oldValue.indexOf(DIVIDER);
                System.debug('Remove string after position ' + thingsToRemove);
                System.debug('Previous call notes found');
                if(ss.whatId!=null && Schema.Case.SObjectType==ss.whatId.getSobjectType()){
                ss.Description = oldValue.left(thingsToRemove) + '\r\n' +ss.NVM_Disposition__c+' | '  + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
                } else {
                ss.Description = oldValue.left(thingsToRemove) + '\r\n' + DIVIDER + '\r\n'  + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
                }
                if(ss.Description.length()<255){
                ss.NVM_Notes__c = ss.Description;
                } else {
                //ss.NVM_Notes__c = ss.Description.substring((ss.Description.length()-250), ss.Description.length());
                ss.NVM_Notes__c = ss.Description.substring(0, 250);
                }
            }
            else {
                String newValue =oldValue;
                if(ss.whatId!=null && Schema.Case.SObjectType==ss.whatId.getSobjectType()){
                 newValue = '\r\n' +ss.NVM_Disposition__c+' | ' + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
               } else {
                newValue = oldValue + '\r\n' + DIVIDER + '\r\n' +ss.NVM_Disposition__c+' | ' + (allNotes.get(ss.CallObject) != null ? allNotes.get(ss.CallObject) : '');
               }
                ss.Description = newValue;
                if(newValue.length()<255){
                ss.NVM_Notes__c = newValue;
                } else {
                //ss.NVM_Notes__c = newValue.substring((newValue.length()-250), newValue.length());
                ss.NVM_Notes__c = ss.Description.substring(0, 250);
                }
            }
            ss.NVM_Notes__c.replaceAll(' null','');
        } //end for
    } //end method
} //end class