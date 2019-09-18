//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: TaskTrigger
// On SObject: Task
// Description: If sales rep working on an prospect account and create activity on that (Type = message or call) then populate Sales lock
// user field with the sales rep and pouplate Lock Expiration Date with the 10 days threshold. If while creating activities Sales lock user
// already populated then dont populate again.
//
// 20th March 2015    Hemendra Singh Bhati   Original (Task # T-372157)
//
trigger TaskTrigger on Task (after insert,after update,BEfore insert,Before update,Before delete) {
    
    //Turn Off Trigger for specific user
    
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true. 
    //POS Related logic implemented by Rajamohan  
    if(Dtrg.TaskTrigger__c!=UserInfo.getUserName() && !PointOfSalesInboundEmailHandler.SkipForPOSExecution && !MergeServiceSOAP.SkipTriggerExecution){
   // if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
        TaskTriggerHandler theTaskTriggerHandler = new TaskTriggerHandler(Trigger.isExecuting, Trigger.size);
        String userName = UserInfo.getUserName();
        Boolean NVMprocess = true;
        Boolean ISprocess = true;
        Schedule_Batch_Setting__c nvmp = Schedule_Batch_Setting__c.getValues('NVMTOOL');
        Schedule_Batch_Setting__c nvmcts = Schedule_Batch_Setting__c.getValues('CaseCommentTroubeshoot');
        Schedule_Batch_Setting__c ispp = Schedule_Batch_Setting__c.getValues('ISTOOL');
        if (nvmp != null) {
              NVMprocess = nvmp.Is_Running__c;
          }
        if (ispp != null) {
              ISprocess = ispp.Is_Running__c;
          }
        if(Switch_TaskTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
            if(trigger.isAfter && trigger.isInsert) {
                theTaskTriggerHandler.onAfterInsert(trigger.new);
            }
        }
        if(trigger.isAfter && trigger.isUpdate) {
            theTaskTriggerHandler.closeCaseIfActivityCompleted(trigger.oldMap, trigger.newMap);    // CRM-5848 - Opcity
            theTaskTriggerHandler.onAfterUpdateCaseTLActivities(trigger.new);
            //if(!userName.contains('nvmapiuser@move.com')){
            boolean runleadupdatenew = false;
            boolean runleadupdatenewMoreFields = false;
            boolean runInsideSalesleadupdate = false;
            datetime myDate = datetime.newInstance(2019, 03, 6);
                        for(Task tsk:Trigger.new){
                        Boolean isWHOID= true;
                        if(tsk.WhoId!=null){
                        if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
                        isWHOID = false;
                        }
                        }
                        String sObjectType = '';
                        if(tsk.WhatID!=null){
                        if(tsk.WhatID.getSobjectType()!=null){
                        sObjectType = tsk.WhatID.getSobjectType()+'';
                        }
                        }
                       // System.debug(tsk.NVM_Disposition__c+' KKKKKKKK '+ Trigger.oldMap.get(tsk.id).NVM_Disposition__c+'KK'+tsk.WhatID); // || (Trigger.oldMap.get(tsk.id).NVM_Disposition__c!=' ' && Trigger.oldMap.get(tsk.id).NVM_Disposition__c!='' && tsk.Is_processed__c==false
             if((tsk.NVM_Disposition__c!=null && Trigger.oldMap.get(tsk.id).NVM_Disposition__c==null || (Trigger.oldMap.get(tsk.id).NVM_Disposition__c!=' ' && Trigger.oldMap.get(tsk.id).NVM_Disposition__c!='' && tsk.Is_processed__c==false && isWHOID && Trigger.oldMap.get(tsk.id).CreatedDate>myDate)) && (tsk.NVM_Disposition__c!='Transferred' || Schema.Case.SObjectType+'' == sObjectType)){
             if(tsk.NVM_Disposition__c!=' ' && tsk.NVM_Disposition__c!=''){
             runleadupdatenew=true;
             }
             }
             //System.debug(tsk.WhatID.getSobjectType()+' Case WhatId Type');
             
                       //if(tsk.qbdialer__ImpressionId__c!=null){runInsideSalesleadupdate = true;}
                       if((tsk.NVM_Notes__c!=Trigger.oldMap.get(tsk.id).NVM_Notes__c || tsk.NVM_Callback_DateTime__c!=Trigger.oldMap.get(tsk.id).NVM_Callback_DateTime__c  || tsk.Rejected_Reason__c!=Trigger.oldMap.get(tsk.id).Rejected_Reason__c) && tsk.NVM_Disposition__c!=null && !runleadupdatenew){runleadupdatenewMoreFields=true;  }
                        }
                        if(nvmcts!=null){
                        runleadupdatenew = true;
                       }
                       System.debug('Getting set as True '+runleadupdatenew);
                       // runleadupdatenew = true;
                        if(runleadupdatenew && NVMprocess){
                        //SkipForNVMTrigger.setSkipTrgTrue();
            theTaskTriggerHandler.UpdateLead(Trigger.newMap,Trigger.oldMap);
            }
             if(runleadupdatenewMoreFields && NVMprocess){
             System.debug('Executing this code now');
                        //SkipForNVMTrigger.setSkipTrgTrue();
            TaskTriggerHandler.CopyNotesTo(Trigger.newMap);
            }
            
            System.debug('Working Inside '+runInsideSalesleadupdate);
            if(runInsideSalesleadupdate && ISprocess){
            System.debug('Working Inside '+runInsideSalesleadupdate);
            theTaskTriggerHandler.InsideUpdateLead(Trigger.newMap,Trigger.oldMap);
            }
            //}
             
        }
         if(trigger.isAfter && trigger.isInsert) {
           //Added by Pratik on 15th August 2018
                        if(Trigger.isInsert)
                        {
                            TaskTriggerHandler.handleAfterInsert(Trigger.newMap);
                        }
                        //Ends here
                        boolean runleadupdate = false;
                        boolean runleadcallStatusupdate = false;
                        for(Task tsk:Trigger.new){
                        if(tsk.NVM_Disposition__c!=null && (tsk.NVM_Disposition__c!='Transferred' || Schema.Case.SObjectType == tsk.WhatID.getSobjectType())){runleadupdate=true;}
                        if(UserInfo.getUserName().contains('isadmin@move.com') && tsk.callType=='Inbound' && tsk.outcome__c=='No Answer'){
                        runleadcallStatusupdate = true;
                        }
                        }
          if(runleadupdate && NVMprocess){
          //SkipForNVMTrigger.setSkipTrgTrue();
           theTaskTriggerHandler.UpdateLead(Trigger.newMap,Trigger.oldMap);
           }
           
           if(runleadcallStatusupdate && ISprocess){
           TaskTriggerHandler.InsideSalesUpdateCallStatusLead(Trigger.newMap.keyset());
           }
            }
        
        if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)) {
            theTaskTriggerHandler.onBeforeInsertUpdate(trigger.new);
           // Added by Lloy for Inside Sales -- Start of the Code
            If (trigger.isUpdate  || trigger.isInsert)
            {
            Map<Id,Id> MapAccountId = new Map<Id,Id>(); 
            for(Task tsk:Trigger.new){
            
            if(tsk.WhoId!=null){
            MapAccountId.put(tsk.WhoId,tsk.WhatId);
            MapAccountId.put(tsk.Lead__c,tsk.WhatId);
            }
            if(tsk.whatId!=null){
            if(Schema.Case.SObjectType==tsk.whatId.getSobjectType()){
                   tsk.case__c = tsk.whatId;
               }
               }
            }
            System.debug(MapAccountId+'PPP');
            if(MapAccountId.keyset().size()>0){
            for(Lead led:[Select Id,account__c from Lead where Id=:MapAccountId.keyset() and account__c!=null]){
            System.debug(MapAccountId+'PPP'+led.account__c);
            MapAccountId.put(led.Id,led.account__c);
            }
            }
            for(Task tsk:Trigger.new){
            
            if(tsk.WhoId!=null){
            if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
            if(tsk.Lead__c==null){
            tsk.Lead__c = tsk.WhoId;
            }
            if(tsk.NVM_Disposition__c!=null){
            if((tsk.NVM_Disposition__c=='Spoke to/Disqualified') && (tsk.Rejected_Reason__c==null || tsk.Rejected_Reason__c=='')){tsk.Rejected_Reason__c='Doesn\'t See Need';}
            if((tsk.NVM_Disposition__c=='Bad Phone Number') && (tsk.Rejected_Reason__c==null || tsk.Rejected_Reason__c=='')){tsk.Rejected_Reason__c='Wrong Phone';}
            }
           }
           }
           if(tsk.WhatId==null && tsk.NVM_Disposition__c==null && tsk.Subject!=null && !tsk.Subject.contains(' for the Account - ') && !tsk.Subject.contains('Outbound call to') && !tsk.Subject.contains('Inbound call from')){
            System.debug('****'+tsk.WhoId);
            if(MapAccountId.containskey(tsk.WhoId)){
            if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
            System.debug(MapAccountId.get(tsk.WhoId)+'HHHHG');
            tsk.WhatId = MapAccountId.get(tsk.WhoId);
            tsk.WhoId = null;
            }
            } else
            if(MapAccountId.containskey(tsk.Lead__c)){
            System.debug(MapAccountId.get(tsk.Lead__c)+'HHHHG');
            if(Schema.contact.SObjectType == tsk.WhoId.getSobjectType()){
            tsk.WhatId = MapAccountId.get(tsk.Lead__c);
            }
            }
            }
            
            }
          
            }
                      // Added by Lloy for Inside Sales -- End of the Code
                    }
       
    }
    
    If(Trigger.isbefore && Trigger.isdelete){
        string username = userinfo.getUserName();
        string profileid = userinfo.getProfileId();
        profileid = profileid.substring(0,15); 
        
        Attachmentactivitydeleteaccess__c userdata = Attachmentactivitydeleteaccess__c.getinstance(username);
        Attachmentactivitydeleteaccess__c prfldata = Attachmentactivitydeleteaccess__c.getinstance(profileid);
        
        if(userdata == null && prfldata == null){
            for(Task taskloop : trigger.old){
                if(taskloop.Status == 'Completed'){
                if(!Test.isRunningTest()){
                    taskloop.addError('You don\'t have permission to delete Activity History');
                    }
                }
            }
        }
    }
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
    List<Task> lsttask = new List<Task>();
    for(Task tsk:Trigger.new){
    
    if(tsk.CallObject!=null && tsk.CallObject!=''){
    lsttask.add(tsk);
    }
    }
    if(lsttask.size()>0){
     TaskHelper.processTasks(lsttask);
     }
        //Added by Pratik on 27th September 2018 for CRM-4698
        if(Trigger.isInsert)
            TaskTriggerHandler.handleInsert(Trigger.new);
     }
    
}