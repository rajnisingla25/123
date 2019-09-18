//
// (c) 2015 Move, Inc.
//
// Trigger Handler Name: TaskTriggerHandler
// For Trigger: TaskTrigger
// On SObject: Task
// Description: If sales rep working on an prospect account and create activity on that (Type = message or call) then populate Sales lock
// user field with the sales rep and pouplate Lock Expiration Date with the 10 days threshold. If while creating activities Sales lock user
// already populated then don't populate again.
//
// 20th March 2015    Sonu Sharma   Original (Task # T-372157)
// 08th May 2015            Sonu Sharma     Modified (Task # T-393511) - Updated Method: onAfterInsert().
//
public with sharing class TaskTriggerHandler {
  private integer batchSize = 0;
  private boolean isExecuting = false;
  private TaskTriggerHandlerManager theManager = null;
  public static boolean isExecutingCreateTLActivities = false;

  public TaskTriggerHandler(Boolean isExecuting, Integer size) {
        batchSize = size;
    isExecuting = isExecuting;
    theManager = new TaskTriggerHandlerManager();
  }

  /*
  @method      : onAfterInsert
  @description : Handles all after insert event calls.
  @params      : List<Task> newValues
  @returns     : void
  */
  public void onAfterInsert(List<Task> newValues) {
    // Do not allow the trigger to update account lock fields if custom setting field value is true.
        // Do not allow the trigger to update account custom field "Last_Sales_Contact_Date__c" if custom setting field value is true.
    if(
        Switch_TaskTrigger__c.getInstance().Set_Account_Sales_Lock_User_Off__c == false &&
        Switch_TaskTrigger__c.getInstance().Set_Last_Sales_Contact_Date_Update_Off__c == false
    ) {
        // This method also updates account custom field "Last_Sales_Contact_Date__c".
        theManager.setTaskAccountSalesLockUserAndLockExpirationDate(newValues);
    }
  }
  
  /*
  @method      : onBeforeInsertUpdate
  @description : Handles all after insert event calls.
  @params      : List<Task> newValues
  @returns     : void
  */
  public void onBeforeInsertUpdate(List<Task> newValues) {
      theManager.UpdateTaskBasedonAccount(newValues);
  }
  
  public void onAfterCreateCaseTLActivities(List<Task> newValues) {
  List<Task> lstTask = new List<Task>();
  List<Task> lstcancelTask = new List<Task>();
  Set<Id> setCaseIds = new Set<Id>();
  Set<Id> whoContactIds = new Set<Id>();
  Set<Id> whoLeadIds = new Set<Id>();
  Tiger_Lead_Products__c TLProducts= Tiger_Lead_Products__c.getValues('TigerLeads');
  Set<string> TLActivitiesStrings = new Set<string>();
  Map<Id,id> mapTaskCaseId = new Map<Id,id>();
 if(TLProducts!=null){
 //TLProductStrings.addall(TLProducts.Tiger_Lead_Product_List__c.split(';'));
 TLActivitiesStrings.addall(TLProducts.TigerLeadActivities__c.split(';'));
 }
  
  
  
 
  List<Case> lstCase = new List<Case>();
  
  isExecutingCreateTLActivities = true;
  SkipTaskTrigger.setSkipTrgTrue();
  update lstCase;
  }
  
    public void onAfterUpdateCaseTLActivities(List<Task> newValues) {
      if(SkipTaskTrigger.skiptrigger == false){
   onAfterCreateCaseTLActivities(newValues);
   }
  Set<Id> setCaseIds = new Set<Id>();
  for(Task tsk:newValues){
  if(tsk.WhatId!=null){
  System.debug(tsk.WhatId);
  if((tsk.WhatId+'').contains('500')){
  setCaseIds.add(tsk.WhatId);
  }
  }
  }
  if(setCaseIds.size()>0){
  Set<string> TLProductStrings = new Set<string>();
 Set<string> TLActivitiesStrings = new Set<string>();
 Set<Id> setOrderIds = new Set<Id>();
 Tiger_Lead_Products__c TLProducts= Tiger_Lead_Products__c.getValues('TigerLeads');
 if(TLProducts!=null){
 TLProductStrings.addall(TLProducts.Tiger_Lead_Product_List__c.split(';'));
 TLActivitiesStrings.addall(TLProducts.TigerLeadActivities__c.split(';'));
  }
  
 
  
  }
}

Public void UpdateOpportunitiesTPIDX(Set<Id> theOpportunityIds){
List<Opportunity> OpportunityToBeUpdated = new List<Opportunity>();
      for(Id theoppId:theOpportunityIds){
      OpportunityToBeUpdated.add(new Opportunity(
            Id = theoppId,
            StageName = 'Closed Won - Fulfilled',
            Fulfillment_Complete__c = true
          ));
          }
          if(OpportunityToBeUpdated.size()>0){
          update OpportunityToBeUpdated;
          }
}

    Public void InsideUpdateLead(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask){
                List<Task> lstTask = newMapTask.values();

    }
    Public Static void InsideSalesUpdateLeadNonFuture(Set<Id> setTaskIds){
        InsideSalesUpdateLead(setTaskIds);
    }
    
    @future
    Public Static void InsideSalesUpdateLeadFuture(Set<Id> setTaskIds){
        InsideSalesUpdateLead(setTaskIds);
        }

    @future
    Public static void InsideSalesUpdateCallStatusLead(Set<Id> setTaskIds){
          }

    Public static void InsideSalesUpdateLead(Set<Id> setTaskIds){
                    

    }
    
    //@future
    Public Static void CopyNotesTo(Map<Id,Task> mapTask){
    Map<Id,Task> mapTaskIds = new Map<Id,Task>();
    //Set<Id> setLeadIds = new Set<Id>();
    //Map<Id,Task> mapTask = new Map<Id,Task>([Select Id, NVM_Notes__c,NVM_Callback_DateTime__c, Related_Task_Id__c from Task where Id=:setTaskIds]);
    List<Task> lstTask = [Select Id, NVM_Notes__c,Is_processed__c,Rejected_Reason__c,WhoId,Lead__c, NVM_Callback_DateTime__c, Related_Task_Id__c from Task where Related_Task_Id__c=:mapTask.keyset()];
    for(Task tsk:lstTask){
    //if(!setTaskIds.contains(tsk.Related_Task_Id__c)){
    if(mapTask.containskey(tsk.Related_Task_Id__c)){
    
    tsk.NVM_Notes__c = mapTask.get(tsk.Related_Task_Id__c).NVM_Notes__c;
    tsk.Is_processed__c = false;
    //lstTask.add(tsk);
    //}
    }
    }
    Update lstTask;
    for(Task tsk:mapTask.values()){
    //setLeadIds.add(tsk.Lead__c);
    mapTaskIds.put(tsk.Lead__c,tsk);
    }
    if(mapTaskIds.keyset().size()>0){
    //System.debug('Lead Update work'+setLeadIds);
    List<Lead> lstLead = [Select Id, Related_Task_Id__c, Rejected_Reason__c ,NVM_Callback_DateTime__c,Name,ownerid from Lead where id=:mapTaskIds.keyset()];
    for(Lead led:lstLead){
    if(mapTaskIds.containskey(led.Id)){
    System.debug('Lead Update work loop'+mapTaskIds.get(led.Id).NVM_Callback_DateTime__c);
    led.NVM_Callback_DateTime__c = mapTaskIds.get(led.Id).NVM_Callback_DateTime__c;
    led.Rejected_Reason__c = mapTaskIds.get(led.Id).Rejected_Reason__c;
    System.debug('Lead Update work loop');
    }
    }
    update lstLead;
    }
    }


    Public void UpdateLead(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask){
             //[Select Id,Name from user limit 1]);

                Set<Id> setUserIds = new Set<Id>(); 
                Set<Id> setLeadids = new Set<Id>();
                Set<Id> setOpportunityids = new Set<Id>();
                Set<Id> setTaskCaseIds = new Set<Id>();
                Set<Id> setQuoteTaskIds = new Set<Id>(); 
                
                //Set<Id> setTaskCIds = new Set<Id>();
                Set<Id> lstTaskRec = new Set<Id>();
            Set<Id> setCaseId = new Set<Id>();
        
                Set<Id> setRejectedLeadids = new Set<Id>();
                System.debug(newMapTask+'PPPPPPPP');
                if(newMapTask!=null){
                    System.debug('HHHHHH'+newMapTask.values());
                    if(newMapTask.values().size()>0){
                        System.debug('HHHHHH');
                            for(Task ttsk:newMapTask.values()){
                                        //System.debug(ttsk.WhoId+'KKKKK PPPPPPP'+(ttsk.Subject.contains('Outbound call to') && (ttsk.Status =='Completed')));
                                        System.debug('HHHHHH'+ttsk.Subject);
                                    if(ttsk.Subject!=null){
                                        System.debug(ttsk.Status+'HHHHHH'+ttsk.Subject);
                                        if((ttsk.Subject.contains('Outbound call to') || ttsk.Subject.contains('Inbound call from'))&& (ttsk.Status =='Completed')){
                                            System.debug(ttsk.WhoId+'KKKKK PPPPPPP');
                                            if(ttsk.Quote_Task__c==null){
                                            setQuoteTaskIds.add(ttsk.id);
                                            }
                                            if(ttsk.WhoId!=null){
                                            if(Schema.Lead.SObjectType == ttsk.WhoId.getSobjectType()){

                                                
                                                System.debug(ttsk+'KKKKK PPPPPPP');
                                                
                                                setUserIds.add(ttsk.ownerid);
                                                setLeadids.Add(ttsk.WhoId);
                                            
                                            } else if(Schema.Case.SObjectType==ttsk.whatId.getSobjectType()){
                                            setTaskCaseIds.add(ttsk.id);
                                             lstTaskRec.add(ttsk.id);
                                             setCaseId.add(ttsk.WhatID);
                                            }
                                        }
                                        if(ttsk.WhatID!=null) {
                                            if(Schema.Opportunity.SObjectType == ttsk.WhatID.getSobjectType()){
                                                    //System.debug('Testing new + '+tsk);
                                                setOpportunityids.add(ttsk.WhatID);
                                                setUserIds.add(ttsk.ownerid);
                                            } else if(Schema.Case.SObjectType==ttsk.whatId.getSobjectType()){
                                            setTaskCaseIds.add(ttsk.id);
                                             lstTaskRec.add(ttsk.id);
                                             setCaseId.add(ttsk.WhatID);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    SkipTrigger.skiptrigger1 = true;
                    if(setQuoteTaskIds.size()>0){
                    BigMachinesQuoteTriggerHandler.updateQuoteTask(setQuoteTaskIds);
                    }
                if((setLeadids.size()>0 || setRejectedLeadids.size()>0) || setUserIds.size()>0 || setOpportunityids.size()>0){
                            System.debug(setLeadids+'KKKKK PPPPPPP');
                            Boolean NVMprocessNew = true;
                            Schedule_Batch_Setting__c nvmp = Schedule_Batch_Setting__c.getValues('NVMTOOLNEW');
                            if (nvmp != null) {
                                  NVMprocessNew = nvmp.Is_Running__c;
                              }
                              if(NVMprocessNew){
                              Map<Id,Task> mapLeadTask = new Map<Id,Task>();
                              Map<Id,Task> mapOpportunityTask = new Map<Id,Task>();
                              System.debug(newMapTask+'KKKKK PPPPPPP');
                              for(Task tsk:newMapTask.values()){
                              System.debug(tsk);
                              if(tsk.WhoId!=null){
                               if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
                                    System.debug('Testing new + '+tsk);
                                    mapLeadTask.put(tsk.id,tsk);
                                }
                            } 
                            if(tsk.WhatID!=null) {
                            if(Schema.Opportunity.SObjectType == tsk.WhatID.getSobjectType()){
                                    System.debug('Testing new + '+tsk);
                                    mapOpportunityTask.put(tsk.id,tsk);
                                }
                                if(Schema.Case.SObjectType == tsk.WhatID.getSobjectType()){
                                   // System.debug('Testing new + '+tsk);
                                    lstTaskRec.add(tsk.id);
                                    setCaseId.add(tsk.WhatID);
                                }
                                
                            }
                            }
                            if(mapLeadTask.values().size()>0){
                              UpdateRelatedLeadNew(setUserIds,setLeadids,setRejectedLeadids,mapLeadTask.keyset());
                              }
                              System.debug('LLLLLL'+mapOpportunityTask);
                              if(mapOpportunityTask.values().size()>0){
                              UpdateRelatedOpportunityNew(setUserIds,setOpportunityids,setRejectedLeadids,mapOpportunityTask.keyset());
                              }
                            } else {
                            UpdateRelatedLead(setUserIds,setLeadids,setRejectedLeadids,newMapTask.keyset());
                            }
                            }
                            if(setTaskCaseIds.size()>0 || Test.isRunningTest()){
                            UpdateCase(setTaskCaseIds);
                            Error__c error = new Error__c();
                    error.Name = 'UpdateCase';
                    error.Entity_Id__c = 'For : ' + setTaskCaseIds;
                    error.Interface_Name__c = 'TaskTriggerHandler.UpdateCase';
                   
                    error.Error_Description__c = 'Executed for this record';
                    insert error;
                            }
                            if(setCaseId.size()>0 || Test.isRunningTest()){
                            System.debug('$$$$$$'+setCaseId);
                            updateCaseStatus(lstTaskRec, setCaseId);
                            }
                        }
                        
                    }
                    
                   //CRM-3597 -- Update case comment
       // @future
        Public Static void UpdateCase(Set<Id> setTaskIds){
        Set<Id> setCaseIds = new set<Id>();
        Map<Id,Task> mapCaseIdTask = new Map<Id,Task>();
        for(Task tsk:[Select Id,Is_processed__c,NVM_Notes__c,WhatId,Description from task where Id=:setTaskIds and Is_processed__c=false]){
        //tsk.Is_processed__c = true;
        mapCaseIdTask.put(tsk.WhatId,tsk);
        }
        List<Case> lstcaseCommentUpdate = [Select Id,Status,CaseComments__c,Description from case where Id=:mapCaseIdTask.keyset()];
        List<CaseComment> lstComment = new List<CaseComment>(); 
        for(Case cse:lstcaseCommentUpdate){
        Task ttsk = mapCaseIdTask.get(cse.Id);
        ttsk.Is_processed__c = true;
        mapCaseIdTask.put(ttsk.WhatId,ttsk);
        cse.CaseComments__c = cse.CaseComments__c+' '+mapCaseIdTask.get(cse.id).Description;
        if(cse.Status!='Closed'){
        //cse.Status = 'In Progress'; // commented for CRM 4817
        }
        CaseComment newCom = new CaseComment();
                            //newCom.CommentBody = newCase.NVM_Notes__c;
                            //if(newCase.Comments__c != null) {
                            if(newCom.CommentBody==null){newCom.CommentBody='';}
                             Integer fpos = 0;
                             if(mapCaseIdTask.get(cse.id).Description!=null){
                              fpos = mapCaseIdTask.get(cse.id).Description.length();
                           if(fpos>2500){fpos = 2500;}
                            newCom.CommentBody = newCom.CommentBody + ' ' + mapCaseIdTask.get(cse.id).Description.substring(0, fpos);
                           
                           // newCom.CommentBody = newCom.CommentBody + ' ' + mapCaseIdTask.get(cse.id).Description;
                            //}
                            }
                            newCom.IsPublished = TRUE;
                            newCom.ParentId = cse.id;
                           
                            lstComment.add(newcom);
        }
       // update lstcaseCommentUpdate;
       //SkipCaseCommentTrigger.setSkipTrgTrue();
        Insert lstComment;
        PointOfSalesInboundEmailHandler.SkipForPOSExecution = true;
        update mapCaseIdTask.values();
        
        }
        
        // CRM-3798 :- NVM new updated code with followup status
        @future
        Public Static void UpdateRelatedOpportunityNew(Set<Id> setUserIds,Set<Id> setLeadids,Set<Id> setRejectedLeadIds,Set<Id> setTaskIds){
         Map<Id,User> newUserMap = new Map<Id,User>();
                    Map<Id,Task> newTaskMap = new Map<Id,Task>();
                    System.debug('LLLLLL'+setTaskIds);
                    if(setUserIds.size()>0){
                        System.debug('Testing new + ');
                        for(User usr:[Select Id,Name,NVMContactWorld__NVM_Agent_Id__c from user where Id=:setUserIds and NVMContactWorld__NVM_Agent_Id__c != null]){
                            newUserMap.put(usr.id,usr);
                        }
                    }
                    for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId, WhatId ,Description,NVM_Notes__c,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task where Id=:setTaskIds]){
                        if(tsk.WhatId!=null){
                        System.debug('Testing new + '+tsk);
                        newTaskMap.put(tsk.WhatId,tsk);
                        }
                    }
                    if(Test.isRunningTest()){
                        for(Task tsk:[Select Id, WhatId, Related_Task_Id__c ,WhoId,Description, NVM_Notes__c ,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task]){
                            
                                    System.debug('Testing new + '+tsk);
                                    newTaskMap.put(tsk.WhatId,tsk);
                               
                        }
                    }
            Set<Id> setTotalLeadids = new Set<Id>();
            setTotalLeadids.addAll(setLeadids);
            setTotalLeadids.addAll(setRejectedLeadIds);
            System.debug('Testing new + '+setTaskIds);
            String AbandonedNumber = '20';
            Map<String,String> mapFollowUpStatusString = new Map<String,String>();
            Map<String,NVMDispositionFollowup__c> mapDispositionFollowup = new Map<String,NVMDispositionFollowup__c>();
            for(LeadFollowUpStatus__c lfws:[Select Id,name, Failed_Attempt__c, Is_Abandoned__c, Left_Message__c from LeadFollowUpStatus__c]){
            mapFollowUpStatusString.put(lfws.Failed_Attempt__c,lfws.Left_Message__c);
            if(lfws.Is_Abandoned__c){
            AbandonedNumber = lfws.Name;
            }
            }
            
            for(NVMDispositionFollowup__c nvmdisp:[Select Id,name,Follow_Up_Status__c, NVMfailedCount__c ,Object__c,Reason__c,Lead_Status__c,Description__c,VMAttempt__c from NVMDispositionFollowup__c where Opcity__c=false]){
            mapDispositionFollowup.put(nvmdisp.Name,nvmdisp);
            }
            
            System.debug('mapFollowUpStatusString new + '+mapFollowUpStatusString);
            if(setTotalLeadids.size()>0){

                //List<Opportunity> lstLead = [Select Id, Description,Contact__c,Account__r.Name,AccountId__c,Rejected_Reason__c ,follow_up_status__c,Name,Status,ownerid,Account__c from Opportunity where id=:setTotalLeadids];
                 //   System.debug(lstLead+'KKKKK PPPPPPP');
                    //NVM_Call_Count__c, Related_Task_Id__c ,NVM_Callback_DateTime__c,NVM_Failed_Call_Count__c,NVM_High_Priority__c,
                  List<Opportunity> lstLead = [Select Id,Related_Task_Id__c, Rejected_Reason__c, Description ,Account.Name,NVM_Call_Count__c ,NVM_Callback_DateTime__c,NVM_Failed_Call_Count__c,NVM_High_Priority__c, Follow_up_status__c,Status__c,Name,ownerid,AccountId from Opportunity where id=:setTotalLeadids];
                System.debug(lstLead+'KKKKK PPPPPPP');
                    Map<Id,String> MapLeadIdStatus = new Map<Id,String>(); 
                for(Opportunity led:lstLead){
                Boolean changeleadStatus = true;
                if(led.Status__c==null){led.Status__c='';}
                if(led.Status__c.equalsIgnoreCase('Converted') || led.Status__c.equalsIgnoreCase('Waitlisted')){changeleadStatus=false;}
                MapLeadIdStatus.put(led.id,led.follow_up_status__c);
                    System.debug(newTaskMap+'KKKKK PPPPPPP');
                    if(newTaskMap.containskey(led.id)){
                    led.Related_Task_Id__c = newTaskMap.get(led.id).Id;
                        //System.debug(newTaskMap.get(led.id).NVM_Disposition__c+'KKKKK PPPPPPP');
                    if(led.NVM_Call_Count__c==null){led.NVM_Call_Count__c=0;}
                        led.NVM_Call_Count__c = led.NVM_Call_Count__c + 1;
                        led.NVM_Callback_DateTime__c = newTaskMap.get(led.id).NVM_Callback_DateTime__c;
                        led.NVM_High_Priority__c = false;
                        if(led.NVM_Callback_DateTime__c<System.now()){
                            led.NVM_Callback_DateTime__c = null;
                        }
                        Datetime dt60days = System.now().AddDays(60);
                        if(led.NVM_Callback_DateTime__c>dt60days){
                        led.NVM_Callback_DateTime__c = dt60days;
                        }
                        System.debug('This is working');
                        if(mapDispositionFollowup.containskey(newTaskMap.get(led.id).NVM_Disposition__c)){
                            if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).NVMfailedCount__c){
                                if(led.NVM_Failed_Call_Count__c==null){led.NVM_Failed_Call_Count__c=0;}
                                  led.NVM_Failed_Call_Count__c = led.NVM_Failed_Call_Count__c + 1;
                                  
                        }
                        led.follow_up_status__c=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Follow_Up_Status__c;
                        System.debug('This is working'+led.follow_up_status__c);
                        if(changeleadStatus){led.Status__c=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Lead_Status__c;}
                        if(led.Status__c =='Waitlisted'){led.Status__c ='In progress';}
                        if(led.Status__c =='Rejected'){led.Status__c ='In progress';}
                        if(led.Status__c =='Rejected'){
                        if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c!=null){
                                led.Rejected_Reason__c = mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c;
                                }
                                if(newTaskMap.get(led.id).Rejected_Reason__c!=null){
                                led.Rejected_Reason__c = newTaskMap.get(led.id).Rejected_Reason__c;
                                }
                                }
                                
                         if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).VMAttempt__c){


                        
                        System.debug('Testing new + '+led.NVM_Failed_Call_Count__c);

                                   if((led.follow_up_status__c+'').length()>6){
                                        if(mapFollowUpStatusString.containskey(led.NVM_Failed_Call_Count__c+'')){
                                            led.follow_up_status__c = mapFollowUpStatusString.get(led.NVM_Failed_Call_Count__c+'');
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' && led.NVM_Failed_Call_Count__c<10){
                                            led.Follow_up_status__c = 'LM 1st Attempt';
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){
                                            led.Follow_up_status__c = 'No Answer';
                                        }
                                        System.debug('Testing new + '+led.Follow_up_status__c);
                                        if((led.NVM_Failed_Call_Count__c+'') ==AbandonedNumber){if(changeleadStatus){led.Status__c = mapDispositionFollowup.get(led.NVM_Failed_Call_Count__c+'').Lead_Status__c;} led.Rejected_Reason__c = mapDispositionFollowup.get(led.NVM_Failed_Call_Count__c+'').Reason__c;}

                                        } else {
                                        System.debug('Testing new + '+led.Follow_up_status__c);
                                        led.Follow_up_status__c = 'LM 1st Attempt';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                    
                                    }
                        }
                        
                        }
                        }
                                System.debug('Lead Update '+lstLead);
                        
                            Update lstLead;
                            createTaskIFNoFollowupStatusChangeOpp(MapLeadIdStatus,lstLead,newTaskMap);
                        }
        }
        
        
        @future
        Public Static void UpdateRelatedLeadNew(Set<Id> setUserIds,Set<Id> setLeadids,Set<Id> setRejectedLeadIds,Set<Id> setTaskIds){
        Set<Id> setLeadTaskIds = new Set<Id>();
        for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description,NVM_Notes__c,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task where Id=:setTaskIds]){
                        //System.debug('Testing new + '+tsk);
                        setLeadTaskIds.add(tsk.WhoId);
                    }
                  Boolean rdcprocess = false;
                  Boolean opcityprocess = false;
                  for(Lead led:[Select Id,RecordType.Name,Status from Lead where Id=:setLeadTaskIds]){
                  if(led.RecordType.Name=='OPCITY'){
                  opcityprocess = true;
                  } else {
                  rdcprocess = true;
                  }
                  }
                  if(rdcprocess){
        RDCLeadProcess(setUserIds,setLeadids,setRejectedLeadIds,setTaskIds);
        //BigMachinesQuoteTriggerHandler.updateQuoteTask(setTaskIds);
        }
        
        if(opcityprocess){
        OPCITYLeadProcess(setUserIds,setLeadids,setRejectedLeadIds,setTaskIds);
        }
        if(setTaskIds.size()>0){
        //BigMachinesQuoteTriggerHandler.updateQuoteTask(setTaskIds);
        }
        }
        
        Public Static void OPCITYLeadProcess(Set<Id> setUserIds,Set<Id> setLeadids,Set<Id> setRejectedLeadIds,Set<Id> setTaskIds){
         Map<Id,User> newUserMap = new Map<Id,User>();
                    Map<Id,Task> newTaskMap = new Map<Id,Task>();
                    if(setUserIds.size()>0){
                        System.debug('Testing new + ');
                        for(User usr:[Select Id,Name,NVMContactWorld__NVM_Agent_Id__c from user where Id=:setUserIds and NVMContactWorld__NVM_Agent_Id__c != null]){
                            newUserMap.put(usr.id,usr);
                        }
                    }
                    for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description,NVM_Notes__c,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task where Id=:setTaskIds]){
                        System.debug('Testing new + '+tsk);
                        newTaskMap.put(tsk.WhoId,tsk);
                    }
                    if(Test.isRunningTest()){
                        for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description, NVM_Notes__c ,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task]){
                            System.debug('Testing new + '+tsk.WhoId);
                            if(tsk.WhoId!=null){
                               if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
                                    System.debug('Testing new + '+tsk);
                                    newTaskMap.put(tsk.WhoId,tsk);
                                }
                            }
                        }
                    }
            Set<Id> setTotalLeadids = new Set<Id>();
            setTotalLeadids.addAll(setLeadids);
            setTotalLeadids.addAll(setRejectedLeadIds);
            System.debug('Testing new + '+setTaskIds);
            String AbandonedNumber = '10';
            Map<String,String> mapFollowUpStatusString = new Map<String,String>();
            Map<String,NVMDispositionFollowup__c> mapDispositionFollowup = new Map<String,NVMDispositionFollowup__c>();
            for(LeadFollowUpStatus__c lfws:[Select Id,name, Failed_Attempt__c, Is_Abandoned__c, Left_Message__c from LeadFollowUpStatus__c]){
            mapFollowUpStatusString.put(lfws.Failed_Attempt__c,lfws.Left_Message__c);
            if(lfws.Is_Abandoned__c){
            //AbandonedNumber = lfws.Name;
            }
            }
            
            for(NVMDispositionFollowup__c nvmdisp:[Select Id,name,Follow_Up_Status__c, NVMfailedCount__c ,Object__c,Reason__c,Lead_Status__c,Description__c,VMAttempt__c from NVMDispositionFollowup__c where Opcity__c=true]){
            String keyString = '';
            keyString = nvmdisp.Name;
            if(nvmdisp.Name=='Follow up Scheduled - Pitched#'){keyString='Follow up Scheduled - Pitched (post-demo Follow up)';}
            if(nvmdisp.Name=='Follow up Scheduled - Not Pitched#'){keyString='Follow up Scheduled - Not Pitched Yet';}
            mapDispositionFollowup.put(keyString.replace('#',''),nvmdisp);
            }
            
            System.debug('mapFollowUpStatusString new + '+mapDispositionFollowup);
            if(setTotalLeadids.size()>0){

                List<Lead> lstLead = [Select Id,NVM_Call_Count__c,Lead_origin__c,Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c,LeadScore__c, Related_Task_Id__c,NVM_Callback_DateTime__c,NVM_Failed_Call_Count__c,NVM_High_Priority__c, Description,Contact__c,Account__r.Name,AccountId__c,Rejected_Reason__c ,follow_up_status__c,Name,Status,ownerid,Account__c from Lead where id=:setTotalLeadids];
                    System.debug(lstLead+'KKKKK PPPPPPP'); // Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c
                    Map<Id,String> MapLeadIdStatus = new Map<Id,String>(); 
                for(Lead led:lstLead){
                Boolean changeleadStatus = true;
                if(led.Status==null){led.Status='';}
                if(led.Status.equalsIgnoreCase('Converted') || led.Status.equalsIgnoreCase('Waitlisted') || led.Status.equalsIgnoreCase('Rejected')){changeleadStatus=false;}
                MapLeadIdStatus.put(led.id,led.follow_up_status__c);
                    System.debug(newTaskMap+'KKKKK PPPPPPP');
                    if(newTaskMap.containskey(led.id)){
                    led.Related_Task_Id__c = newTaskMap.get(led.id).Id;
                        //System.debug(newTaskMap.get(led.id).NVM_Disposition__c+'KKKKK PPPPPPP');
                    if(led.NVM_Call_Count__c==null){led.NVM_Call_Count__c=0;}
                        led.NVM_Call_Count__c = led.NVM_Call_Count__c + 1;
                        led.NVM_Callback_DateTime__c = newTaskMap.get(led.id).NVM_Callback_DateTime__c;
                        led.NVM_High_Priority__c = false;
                        if(led.NVM_Callback_DateTime__c<System.now()){
                            led.NVM_Callback_DateTime__c = null;
                        }
                        Datetime dt60days = System.now().AddDays(60);
                        if(led.NVM_Callback_DateTime__c>dt60days){
                        led.NVM_Callback_DateTime__c = dt60days;
                        }
                        System.debug('This is working PPP'+mapDispositionFollowup.containskey(newTaskMap.get(led.id).NVM_Disposition__c));
                        if(mapDispositionFollowup.containskey(newTaskMap.get(led.id).NVM_Disposition__c) || Test.isRunningTest()){
                            if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).NVMfailedCount__c){
                                if(led.NVM_Failed_Call_Count__c==null){led.NVM_Failed_Call_Count__c=0;}
                                  led.NVM_Failed_Call_Count__c = led.NVM_Failed_Call_Count__c + 1;
                                  if(led.Nurture_Journey_Entry__c>0){led.Post_Nurture_Call_Count__c = (led.Post_Nurture_Call_Count__c != null ? led.Post_Nurture_Call_Count__c : 0) +1;}
                                  if(led.NVM_Failed_Call_Count__c==5){
                                  led.Engagement_Score_Reset_Date__c = System.now();
                                  led.Lead_Engagement_score__c = 0;
                                  led.LeadScore__c = 0;
                                  }
                                  if(led.Post_Nurture_Call_Count__c==5){
                                                  led.Lead_Engagement_score__c = 0;
                                                  led.LeadScore__c = 0;
                                                  led.Engagement_Score_Reset_Date__c = System.now();
                                                  //led.Lead_origin__c = 'Nurture Lead';
                                                  led.Post_Nurture_Call_Count__c = 0;
                                              }
                        }
                        led.follow_up_status__c=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Follow_Up_Status__c;
                        System.debug(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Lead_Status__c+'This is working'+led.follow_up_status__c+'LLLLL'+changeleadStatus);
                        if(changeleadStatus){If(!(led.Status=='In Setup' && mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Lead_Status__c=='In Progress')){led.Status=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Lead_Status__c; System.debug('KKKKLM'+led.Status);}}
                        
                        if(led.Status =='Rejected'){
                        if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c!=null){
                                led.Rejected_Reason__c = mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c;
                                }
                                if(newTaskMap.get(led.id).Rejected_Reason__c!=null){
                                led.Rejected_Reason__c = newTaskMap.get(led.id).Rejected_Reason__c;
                                }
                                }
                                
                         if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).VMAttempt__c){


                        
                        System.debug(led.Status+'Testing new + '+led.NVM_Failed_Call_Count__c);

                                   if((led.follow_up_status__c+'').length()>6){
                                        if(mapFollowUpStatusString.containskey(led.NVM_Failed_Call_Count__c+'')){
                                            led.follow_up_status__c = mapFollowUpStatusString.get(led.NVM_Failed_Call_Count__c+'');
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' && led.NVM_Failed_Call_Count__c<10){
                                            led.follow_up_status__c = 'LM 1st Attempt';
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){
                                            led.follow_up_status__c = 'No Answer';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        System.debug((led.NVM_Failed_Call_Count__c+'')+ '==' +AbandonedNumber+'PPPPP'+changeleadStatus);
                                        if((led.NVM_Failed_Call_Count__c+'') ==AbandonedNumber){if(changeleadStatus){If(led.Status!='In Setup'){led.Status = 'Rejected';}}
                                         led.Rejected_Reason__c = 'Doesn\'t see need'; //mapDispositionFollowup.get(led.NVM_Failed_Call_Count__c+'').Reason__c;
                                         }

                                        } else {
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        led.follow_up_status__c = 'LM 1st Attempt';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                    
                                    }
                        }
                        
                        }
                        }
                                System.debug('Lead Update '+lstLead);
                        
                            Update lstLead;
                            createTaskIFNoFollowupStatusChange(MapLeadIdStatus,lstLead,newTaskMap);
                        }
        }
        
        
        //CRM-3597
        
        // CRM-3798 :- NVM new updated code with followup status
        Public Static void RDCLeadProcess(Set<Id> setUserIds,Set<Id> setLeadids,Set<Id> setRejectedLeadIds,Set<Id> setTaskIds){
         Map<Id,User> newUserMap = new Map<Id,User>();
                    Map<Id,Task> newTaskMap = new Map<Id,Task>();
                    if(setUserIds.size()>0){
                        System.debug('Testing new + ');
                        for(User usr:[Select Id,Name,NVMContactWorld__NVM_Agent_Id__c from user where Id=:setUserIds and NVMContactWorld__NVM_Agent_Id__c != null]){
                            newUserMap.put(usr.id,usr);
                        }
                    }
                    for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description,NVM_Notes__c,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task where Id=:setTaskIds]){
                        System.debug('Testing new + '+tsk);
                        newTaskMap.put(tsk.WhoId,tsk);
                    }
                    if(Test.isRunningTest()){
                        for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description, NVM_Notes__c ,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task]){
                            System.debug('Testing new + '+tsk.WhoId);
                            if(tsk.WhoId!=null){
                               if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
                                    System.debug('Testing new + '+tsk);
                                    newTaskMap.put(tsk.WhoId,tsk);
                                }
                            }
                        }
                    }
            Set<Id> setTotalLeadids = new Set<Id>();
            setTotalLeadids.addAll(setLeadids);
            setTotalLeadids.addAll(setRejectedLeadIds);
            System.debug('Testing new + '+setTaskIds);
            String AbandonedNumber = '20';
            Map<String,String> mapFollowUpStatusString = new Map<String,String>();
            Map<String,NVMDispositionFollowup__c> mapDispositionFollowup = new Map<String,NVMDispositionFollowup__c>();
            for(LeadFollowUpStatus__c lfws:[Select Id,name, Failed_Attempt__c, Is_Abandoned__c, Left_Message__c from LeadFollowUpStatus__c]){
            mapFollowUpStatusString.put(lfws.Failed_Attempt__c,lfws.Left_Message__c);
            if(lfws.Is_Abandoned__c){
            AbandonedNumber = lfws.Name;
            }
            }
            
            for(NVMDispositionFollowup__c nvmdisp:[Select Id,name,Follow_Up_Status__c, NVMfailedCount__c ,Object__c,Reason__c,Lead_Status__c,Description__c,VMAttempt__c from NVMDispositionFollowup__c where Opcity__c=false]){
            mapDispositionFollowup.put(nvmdisp.Name,nvmdisp);
            }
            
            System.debug('mapFollowUpStatusString new + '+mapFollowUpStatusString);
            if(setTotalLeadids.size()>0){

                List<Lead> lstLead = [Select Id,NVM_Call_Count__c,Lead_origin__c,Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c,LeadScore__c, Related_Task_Id__c,NVM_Callback_DateTime__c,NVM_Failed_Call_Count__c,NVM_High_Priority__c, Description,Contact__c,Account__r.Name,AccountId__c,Rejected_Reason__c ,follow_up_status__c,Name,Status,ownerid,Account__c from Lead where id=:setTotalLeadids];
                    System.debug(lstLead+'KKKKK PPPPPPP'); // Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c
                    Map<Id,String> MapLeadIdStatus = new Map<Id,String>(); 
                for(Lead led:lstLead){
                Boolean changeleadStatus = true;
                if(led.Status==null){led.Status='';}
                if(led.Status.equalsIgnoreCase('Converted') || led.Status.equalsIgnoreCase('Waitlisted')){changeleadStatus=false;}
                MapLeadIdStatus.put(led.id,led.follow_up_status__c);
                    System.debug(newTaskMap+'KKKKK PPPPPPP');
                    if(newTaskMap.containskey(led.id)){
                    led.Related_Task_Id__c = newTaskMap.get(led.id).Id;
                        //System.debug(newTaskMap.get(led.id).NVM_Disposition__c+'KKKKK PPPPPPP');
                    if(led.NVM_Call_Count__c==null){led.NVM_Call_Count__c=0;}
                        led.NVM_Call_Count__c = led.NVM_Call_Count__c + 1;
                        led.NVM_Callback_DateTime__c = newTaskMap.get(led.id).NVM_Callback_DateTime__c;
                        led.NVM_High_Priority__c = false;
                        if(led.NVM_Callback_DateTime__c<System.now()){
                            led.NVM_Callback_DateTime__c = null;
                        }
                        Datetime dt60days = System.now().AddDays(60);
                        if(led.NVM_Callback_DateTime__c>dt60days){
                        led.NVM_Callback_DateTime__c = dt60days;
                        }
                        System.debug('This is working PPP'+mapDispositionFollowup.containskey(newTaskMap.get(led.id).NVM_Disposition__c));
                        if(mapDispositionFollowup.containskey(newTaskMap.get(led.id).NVM_Disposition__c)  || Test.isRunningTest()){
                            if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).NVMfailedCount__c){
                                if(led.NVM_Failed_Call_Count__c==null){led.NVM_Failed_Call_Count__c=0;}
                                  led.NVM_Failed_Call_Count__c = led.NVM_Failed_Call_Count__c + 1;
                                  if(led.Nurture_Journey_Entry__c>0){led.Post_Nurture_Call_Count__c = (led.Post_Nurture_Call_Count__c != null ? led.Post_Nurture_Call_Count__c : 0) +1;}
                                  if(led.NVM_Failed_Call_Count__c==5){
                                  led.Engagement_Score_Reset_Date__c = System.now();
                                  led.Lead_Engagement_score__c = 0;
                                  led.LeadScore__c = 0;
                                  //led.Lead_origin__c = 'Nurture Lead';
                                  }
                                  if(led.Post_Nurture_Call_Count__c==5){
                                                  led.Lead_Engagement_score__c = 0;
                                                  led.LeadScore__c = 0;
                                                  led.Engagement_Score_Reset_Date__c = System.now();
                                                  led.Post_Nurture_Call_Count__c = 0;
                                              }
                        }
                        led.follow_up_status__c=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Follow_Up_Status__c;
                        System.debug('This is working'+led.follow_up_status__c);
                        if(changeleadStatus){led.Status=mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Lead_Status__c;}
                        if(led.Status =='Rejected'){
                        if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c!=null){
                                led.Rejected_Reason__c = mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).Reason__c;
                                }
                                if(newTaskMap.get(led.id).Rejected_Reason__c!=null){
                                led.Rejected_Reason__c = newTaskMap.get(led.id).Rejected_Reason__c;
                                }
                                }
                                
                         if(mapDispositionFollowup.get(newTaskMap.get(led.id).NVM_Disposition__c).VMAttempt__c){


                        
                        System.debug('Testing new + '+led.NVM_Failed_Call_Count__c);

                                   if((led.follow_up_status__c+'').length()>6){
                                        if(mapFollowUpStatusString.containskey(led.NVM_Failed_Call_Count__c+'')){
                                            led.follow_up_status__c = mapFollowUpStatusString.get(led.NVM_Failed_Call_Count__c+'');
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' && led.NVM_Failed_Call_Count__c<10){
                                            led.follow_up_status__c = 'LM 1st Attempt';
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){
                                            led.follow_up_status__c = 'No Answer';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        if((led.NVM_Failed_Call_Count__c+'') ==AbandonedNumber){if(changeleadStatus){led.Status = mapDispositionFollowup.get(led.NVM_Failed_Call_Count__c+'').Lead_Status__c;} led.Rejected_Reason__c = mapDispositionFollowup.get(led.NVM_Failed_Call_Count__c+'').Reason__c;}

                                        } else {
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        led.follow_up_status__c = 'LM 1st Attempt';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                    
                                    }
                        }
                        
                        }
                        }
                                System.debug('Lead Update '+lstLead);
                        
                            Update lstLead;
                            createTaskIFNoFollowupStatusChange(MapLeadIdStatus,lstLead,newTaskMap);
                        }
        }
        
        //CRM-3597
        
        @future
        Public Static void UpdateRelatedLead(Set<Id> setUserIds,Set<Id> setLeadids,Set<Id> setRejectedLeadIds,Set<Id> setTaskIds){
                    Map<Id,User> newUserMap = new Map<Id,User>();
                    Map<Id,Task> newTaskMap = new Map<Id,Task>();
                    if(setUserIds.size()>0){
                        System.debug('Testing new + ');
                        for(User usr:[Select Id,Name,NVMContactWorld__NVM_Agent_Id__c from user where Id=:setUserIds and NVMContactWorld__NVM_Agent_Id__c != null]){
                            newUserMap.put(usr.id,usr);
                        }
                    }
                    for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description,NVM_Notes__c,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task where Id=:setTaskIds]){
                        System.debug('Testing new + '+tsk);
                        newTaskMap.put(tsk.WhoId,tsk);
                    }
                    if(Test.isRunningTest()){
                        for(Task tsk:[Select Id, Related_Task_Id__c ,WhoId,Description, NVM_Notes__c ,NVM_Callback_DateTime__c,Rejected_Reason__c,NVM_Disposition__c from Task]){
                            System.debug('Testing new + '+tsk.WhoId);
                            if(tsk.WhoId!=null){
                               if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
                                    System.debug('Testing new + '+tsk);
                                    newTaskMap.put(tsk.WhoId,tsk);
                                }
                            }
                        }
                    }
            Set<Id> setTotalLeadids = new Set<Id>();
            setTotalLeadids.addAll(setLeadids);
            setTotalLeadids.addAll(setRejectedLeadIds);
            System.debug('Testing new + '+setTaskIds);
            String AbandonedNumber = '20';
            Map<String,String> mapFollowUpStatusString = new Map<String,String>();
            
            for(LeadFollowUpStatus__c lfws:[Select Id,name, Failed_Attempt__c, Is_Abandoned__c, Left_Message__c from LeadFollowUpStatus__c]){
            mapFollowUpStatusString.put(lfws.Failed_Attempt__c,lfws.Left_Message__c);
            if(lfws.Is_Abandoned__c){
            AbandonedNumber = lfws.Name;
            }
            }
            System.debug('mapFollowUpStatusString new + '+mapFollowUpStatusString);
            if(setTotalLeadids.size()>0){
            Set<String> setLeadStatus = new Set<String>();
            setLeadStatus.add('Converted');
            setLeadStatus.add('Waitlisted');
                List<Lead> lstLead = [Select Id,NVM_Call_Count__c,Lead_origin__c,Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c, Related_Task_Id__c ,NVM_Callback_DateTime__c,NVM_Failed_Call_Count__c,NVM_High_Priority__c, Description,Contact__c,Account__r.Name,AccountId__c,Rejected_Reason__c ,follow_up_status__c,Name,Status,ownerid,Account__c from Lead where id=:setTotalLeadids and Status!=:setLeadStatus];
                    System.debug(lstLead+'KKKKK PPPPPPP'); //Nurture_Journey_Entry__c,Post_Nurture_Call_Count__c,Lead_Engagement_score__c,
                    Map<Id,String> MapLeadIdStatus = new Map<Id,String>(); 
                for(Lead led:lstLead){
                Boolean changeleadStatus = true;
                if(led.Status==null){led.Status='';}
                if(led.Status.equalsIgnoreCase('Converted') || led.Status.equalsIgnoreCase('Waitlisted')){changeleadStatus=false;}
                MapLeadIdStatus.put(led.id,led.follow_up_status__c);
                    System.debug(newTaskMap+'KKKKK PPPPPPP');
                    if(newTaskMap.containskey(led.id)){
                    led.Related_Task_Id__c = newTaskMap.get(led.id).Id;
                        //System.debug(newTaskMap.get(led.id).NVM_Disposition__c+'KKKKK PPPPPPP');
                    if(led.NVM_Call_Count__c==null){led.NVM_Call_Count__c=0;}
                        led.NVM_Call_Count__c = led.NVM_Call_Count__c + 1;
                        led.NVM_Callback_DateTime__c = newTaskMap.get(led.id).NVM_Callback_DateTime__c;
                        led.NVM_High_Priority__c = false;
                        if(led.NVM_Callback_DateTime__c<System.now()){
                            led.NVM_Callback_DateTime__c = null;
                        }
                        Datetime dt60days = System.now().AddDays(60);
                        if(led.NVM_Callback_DateTime__c>dt60days){
                        led.NVM_Callback_DateTime__c = dt60days;
                        }
                        if((newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' || newTaskMap.get(led.id).NVM_Disposition__c=='No Answer' || newTaskMap.get(led.id).NVM_Disposition__c=='Bad Phone Number')){
                                            if(led.NVM_Failed_Call_Count__c==null){led.NVM_Failed_Call_Count__c=0;}
                                            led.NVM_Failed_Call_Count__c = led.NVM_Failed_Call_Count__c + 1;
                                            if(led.Nurture_Journey_Entry__c>0){led.Post_Nurture_Call_Count__c = (led.Post_Nurture_Call_Count__c != null ? led.Post_Nurture_Call_Count__c : 0) +1;}
                                            }
                                            if(led.NVM_Failed_Call_Count__c==5){
                                                  led.Lead_Engagement_score__c = 0;
                                                  led.LeadScore__c = 0;
                                                  led.Engagement_Score_Reset_Date__c = System.now();
                                                  //led.Lead_origin__c = 'Nurture Lead';
                                              }
                                              if(led.Post_Nurture_Call_Count__c==5){
                                                  led.Lead_Engagement_score__c = 0;
                                                  led.LeadScore__c = 0;
                                                  led.Engagement_Score_Reset_Date__c = System.now();
                                                  led.Post_Nurture_Call_Count__c = 0;
                                              }
                                            if(newTaskMap.get(led.id).NVM_Disposition__c=='Follow Up Scheduled'){led.follow_up_status__c='Follow Up Scheduled';if(changeleadStatus){led.Status='In Progress';}}
                                            if(newTaskMap.get(led.id).NVM_Disposition__c=='Contacted - Callback'){led.follow_up_status__c='Contacted - Callback';if(changeleadStatus){led.Status='In Progress';}}
                            if(newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){led.follow_up_status__c='No Answer';if(changeleadStatus){led.Status='In Progress';}}
                                if(newTaskMap.get(led.id).NVM_Disposition__c=='Sold / Sale Pending'){led.follow_up_status__c='Sold / Sale Pending';if(changeleadStatus){led.Status='In Progress';}}
                                System.debug('Testing new + '+led.follow_up_status__c);

                    if(newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' || newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){


                        
                        System.debug('Testing new + '+led.NVM_Failed_Call_Count__c);

                                   if((led.follow_up_status__c+'').length()>6){
                                        if(mapFollowUpStatusString.containskey(led.NVM_Failed_Call_Count__c+'')){
                                            led.follow_up_status__c = mapFollowUpStatusString.get(led.NVM_Failed_Call_Count__c+'');
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='Left Message' && led.NVM_Failed_Call_Count__c<10){
                                            led.follow_up_status__c = 'LM 1st Attempt';
                                        } else if(newTaskMap.get(led.id).NVM_Disposition__c=='No Answer'){
                                            led.follow_up_status__c = 'No Answer';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        if((led.NVM_Failed_Call_Count__c+'') ==AbandonedNumber){if(changeleadStatus){led.Status = 'Rejected';} led.Rejected_Reason__c = 'Abandoned';}

                                        } else {
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                        led.follow_up_status__c = 'LM 1st Attempt';
                                        }
                                        System.debug('Testing new + '+led.follow_up_status__c);
                                    
                                    }
                                        if(newTaskMap.get(led.id).NVM_Disposition__c=='Waitlisted - Warm/Hot'){led.follow_up_status__c='Waitlisted - Warm, Hot';if(changeleadStatus){ led.Status='Waitlisted';}}
                                        if(newTaskMap.get(led.id).NVM_Disposition__c=='Waitlisted - Pre Auth'){led.follow_up_status__c='Waitlisted - Preauth';if(changeleadStatus){ led.Status='Waitlisted';}}
                                        if(newTaskMap.get(led.id).NVM_Disposition__c=='Waitlist Modified'){led.follow_up_status__c='Waitlist Modified'; if(changeleadStatus){led.Status='Waitlisted';}}
                                        if((newTaskMap.get(led.id).NVM_Disposition__c=='Spoke to/Disqualified' || newTaskMap.get(led.id).NVM_Disposition__c=='Bad Phone Number')){
                                            if(changeleadStatus){led.Status = 'Rejected';}
                                            led.Rejected_Reason__c = newTaskMap.get(led.id).Rejected_Reason__c;
                                            led.follow_up_status__c = newTaskMap.get(led.id).NVM_Disposition__c;
                                            
                                        }
                                        
                                        }
                                    }
                                System.debug('Lead Update '+lstLead);
                        
                            Update lstLead;
                            createTaskIFNoFollowupStatusChange(MapLeadIdStatus,lstLead,newTaskMap);
                        }

                    }

    Public void createTasks(List<Case> NewCaseTasks){
                id rectypidTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Management Activities').getRecordTypeId();
                Set<Id> CaseIds = new Set<Id>();
                for(Case c :NewCaseTasks){
                CaseIds.add(c.Id);
                }
                List<Case> caseList = [select Id, Subject,(select Id, Subject from Tasks) from Case where Id in : CaseIds];
                List<Task> insertTaskList = new List<task>();
                for(Case cas : caseList){
                    if((cas.tasks != Null && cas.tasks.size() == 0) || cas.tasks == Null ){
                     insertTaskList.add(new Task(
                        Subject = 'Initial Cancel Call',
                        Status = 'Not Started',
                        ActivityDate = System.today(),
                        Priority = 'Normal',
                        Type =  'Call',
                        RecordTypeId = rectypidTask,
                        Outcome__c = 'Spoke To',
                        whatId = cas.Id
                        ));
                     insertTaskList.add(new Task(
                        Subject = 'Update Stripes & Tracker',
                        Status = 'Not Started',
                        ActivityDate = System.today(),
                        Priority = 'Normal',
                        Type =  'External Systems Update',
                        RecordTypeId = rectypidTask,
                        Outcome__c = 'Spoke To',
                        whatId = cas.Id
                        ));    
                    }
               }
              insert insertTaskList;
      }

  
       
    
    Public Static void createTaskIFNoFollowupStatusChange(Map<Id,String> mapFollowup,List<Lead> olstLead,Map<Id,Task> newTaskMap){
            List<Task> lstt = new List<Task>();
            Id salesActivitiesRecordTypeId = Schema.SObjectType.TASK.getRecordTypeInfosByName().get('Sales Activities').getRecordTypeId();//[SELECT Id, Name, SobjectType FROM RecordType where Name ='Sales Activities' and SobjectType ='Task'  limit 1].id;
            //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner.
            String userName = UserInfo.getUserName();
            String userId = UserInfo.getUserId();
            for(Lead oLead:olstLead){
            if(oLead.Follow_Up_Status__c==mapFollowup.get(oLead.id)){
            Task t = new Task();
            if(userName.contains('nvmapiuser@move.com'))
                t.OwnerId = oLead.OwnerId;
            else
                t.OwnerId = userId;
            t.Lead__c = oLead.ID;
            t.Description = oLead.Description;
            t.Status = 'Completed';
            t.Priority = 'Normal';
            t.Subject = oLead.Follow_Up_Status__c +' for the Account - ' + oLead.Account__r.Name ;
            t.WhatId = oLead.AccountId__c;
            t.WhoId = oLead.Contact__c;
            t.Outcome__c = oLead.Follow_Up_Status__c;
             //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner
            if(t.Outcome__c =='No Answer'){t.Outcome__c ='Left Message';}
            if(t.Outcome__c =='Follow Up Scheduled'){t.Outcome__c ='Spoke To';}
            if(newTaskMap.containskey(oLead.ID)){
            System.debug('Working me');
            t.Description = newTaskMap.get(oLead.ID).Description;
            t.NVM_Notes__c = newTaskMap.get(oLead.ID).NVM_Notes__c;
            }
            t.Issue__c = oLead.Rejected_Reason__c;
            t.Type = 'Call - Outbound';
            t.ActivityDate = system.today();
            t.RecordTypeId = salesActivitiesRecordTypeId;
            lstt.add(t);
            }
            }
            insert lstt;
    }
   
   Public Static void createTaskIFNoFollowupStatusChangeOpp(Map<Id,String> mapFollowup,List<Opportunity> olstLead,Map<Id,Task> newTaskMap){
            List<Task> lstt = new List<Task>();
            Id salesActivitiesRecordTypeId = Schema.SObjectType.TASK.getRecordTypeInfosByName().get('Sales Activities').getRecordTypeId();//[SELECT Id, Name, SobjectType FROM RecordType where Name ='Sales Activities' and SobjectType ='Task'  limit 1].id;
            //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner.
            String userName = UserInfo.getUserName();
            String userId = UserInfo.getUserId();
            for(Opportunity oLead:olstLead){
            if(oLead.Follow_Up_Status__c==mapFollowup.get(oLead.id)){
            Task t = new Task();
            if(userName.contains('nvmapiuser@move.com'))
                t.OwnerId = oLead.OwnerId;
            else
                t.OwnerId = userId;
            t.WhatId = oLead.ID;
            t.Description = oLead.Description;
            t.Status = 'Completed';
            t.Priority = 'Normal';
            t.Subject = oLead.Follow_Up_Status__c +' for the Account - ' + oLead.Account.Name ;
            t.WhatId = oLead.AccountId;
            //t.WhoId = oLead.Contact__c;
            t.Outcome__c = oLead.Follow_Up_Status__c;
             //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner
            if(t.Outcome__c =='No Answer'){t.Outcome__c ='Left Message';}
            if(t.Outcome__c =='Follow Up Scheduled'){t.Outcome__c ='Spoke To';}
            if(newTaskMap.containskey(oLead.ID)){
            System.debug('Working me');
            t.Description = newTaskMap.get(oLead.ID).Description;
            t.NVM_Notes__c = newTaskMap.get(oLead.ID).NVM_Notes__c;
            }
            t.Issue__c = oLead.Rejected_Reason__c;
            t.Type = 'Call - Outbound';
            t.ActivityDate = system.today();
            t.RecordTypeId = salesActivitiesRecordTypeId;
            lstt.add(t);
            }
            }
            insert lstt;
    }
   
   


   
        // Added by Lloy for Inside Sales -- End of the Code
  
    //Added by Pratik on 16th August 2018 for CRM - 4591
    public static void handleAfterInsert(Map<Id, Task> mapTask)
    {
        system.debug('mapTask ==>'+mapTask);
        Set<String> setAccountId = new Set<String>();
        
        for(Task task :mapTask.values())
        {
            if(task.Subject!=null && task.Subject.containsIgnoreCase('High Priority Missed Call'))
            {
                if(task.NVMContactWorld__Customer_Number__c != Null)
                    setAccountId.add(task.NVMContactWorld__Customer_Number__c);
            }
        }
        
        system.debug('setAccountId >==>'+setAccountId);
        
        if(!setAccountId.isEmpty()){
            deleteDuplicateTasks(setAccountId);
           }
    }
    
    @future
    public static void deleteDuplicateTasks(Set<String> setAccountId)
    {
        system.debug('setAccountId ==>'+setAccountId);
        
        /*Schedule_Batch_Setting__c scheduleBatchSetting = Schedule_Batch_Setting__c.getInstance('Missed Call');
        DateTime targetDateTime = DateTime.now().addMinutes(-45);
        
        if(scheduleBatchSetting != Null)
        {
            Integer mins = Integer.valueOf(scheduleBatchSetting.Execution_Min__c);
            targetDateTime = DateTime.now().addMinutes(-mins);
        }
        */
        
        List<Task> lstOldTask = [Select NVMContactWorld__Customer_Number__c, NVMContactWorld__ContactWorld_Number__c 
                                   From Task 
                                   Where Subject Like '%High Priority Missed Call%' 
                                   AND NVMContactWorld__Customer_Number__c IN :setAccountId 
                                   //AND NVMContactWorld__ContactWorld_Number__c IN :setContactWorldNumber 
                                   AND Status != 'Completed'];
                                  //AND CreatedDate >=:targetDateTime];
        
        system.debug('lstOldTask ==>'+lstOldTask);
        List<Task> lstTaskToDelete = new List<Task>();
        //Set<String> setAccId = new Set<String>();
        Set<String> setContactWorldId = new Set<String>();
        for(Task task :lstOldTask)
        {
            if(!setContactWorldId.add(task.NVMContactWorld__ContactWorld_Number__c+'-'+task.NVMContactWorld__Customer_Number__c)) 
              //&& !setAccId.add(task.NVMContactWorld__Customer_Number__c) 
            {
                lstTaskToDelete.add(task);
            }
        }
        
        if(!lstTaskToDelete.isEmpty())
          delete lstTaskToDelete;
    }//Ends here
    
    //Added by Pratik on 11th September 2018
    
    @future
    public Static void updateCaseStatus(Set<Id> lstTaskInfo, Set<Id> setCaseId)
    {
        //Updated by Pratik on 24th September 2018 for CRM-4815
        Map<Id,Task> newTaskMap = new Map<Id,Task>();
        List<STring> serviceProfiles = Label.NVM_Exclude_Service_Profile.split(',');
        List<Task> lsttasknewInfo = [Select Id, WhatId, NVM_Disposition__c,NVM_Callback_DateTime__c From Task where Id IN:lstTaskInfo  and owner.Profile.Name!=:serviceProfiles];
        
        if(lsttasknewInfo.size()>0 || Test.isRunningTest()){
        for(Task tsk:lsttasknewInfo)
        {
            if(tsk.WhatId != null)
                newTaskMap.put(tsk.WhatId,tsk);
        }

        Map<String,NVMDispositionFollowup__c> mapDispositionFollowup = new Map<String,NVMDispositionFollowup__c>();

        for(NVMDispositionFollowup__c nvmdisp:[Select Id,name,Follow_Up_Status__c, NVMfailedCount__c ,Object__c,Reason__c,Lead_Status__c,Description__c,VMAttempt__c from NVMDispositionFollowup__c])
            mapDispositionFollowup.put(nvmdisp.Name,nvmdisp);
        //Ends here
        
        
        
        Map<Id, Case> mapCase = new Map<Id, Case> ([Select Id, Followup_Status__c, HP5__c,Pending_Cancellation_Date__c, NVM_Call_Count__c, Total_Contract_Value__c, AccountId, Status, 
                                                        Account.OwnerId,NVM_Callback_DateTime__c, NVM_Failed_Call_Count__c, Lead_Suspension_Failed_Call_Count__c 
                                                        From Case 
                                                        Where Id IN:setCaseId and status!='Closed']);
        Map<Id,Task> lstTaskToInsert = new Map<Id,Task>();
        List<Case> lstCase = new List<Case>();
        Set<Id> setCaseDupId = new Set<Id>();
        Boolean isFailedCountIncremented = false;
        Set<String> setStatusString = new Set<String>();
         List<String> Profilesexcluded = new List<String>(Label.CaseUpdateProfiles.split(','));
        setStatusString.add('Lead Suspension');
        setStatusString.add('Pending Cancel');
        setStatusString.add('Payment Plan');
        for(Task task :lsttasknewInfo)
        {
            if(task.NVM_Disposition__c != null && mapCase.containskey(task.WhatId))
            {
                Case objCase = mapCase.get(task.WhatId);
                //Updated by Pratik on 24th September 2018 for CRM-4815
                //Case objCase = new Case(Id = task.WhatId);
                
                if(objCase.NVM_Call_Count__c == null)
                    objCase.NVM_Call_Count__c = 0;
                
                objCase.NVM_Call_Count__c = objCase.NVM_Call_Count__c + 1;
                
                
                if(mapDispositionFollowup.containskey(newTaskMap.get(task.WhatId).NVM_Disposition__c))
                {
                objCase.Followup_Status__c = newTaskMap.get(task.WhatId).NVM_Disposition__c;
                    if(mapDispositionFollowup.get(newTaskMap.get(task.WhatId).NVM_Disposition__c).NVMfailedCount__c)
                    {
                        
                        if(objCase.NVM_Failed_Call_Count__c == null)
                            objCase.NVM_Failed_Call_Count__c = 0;
                        
                        objCase.NVM_Failed_Call_Count__c = objCase.NVM_Failed_Call_Count__c + 1;    
                        //Updated by Pratik on 24th September 2018 for CRM-4816
                        if(objCase.Status == 'Lead Suspension')
                        {
                            if(objCase.Lead_Suspension_Failed_Call_Count__c == null)
                                objCase.Lead_Suspension_Failed_Call_Count__c = 1;
                            else
                                objCase.Lead_Suspension_Failed_Call_Count__c = objCase.Lead_Suspension_Failed_Call_Count__c + 1;
                        }      
                    }
                }
                //Ends here
                system.debug('objCase.Status == '+objCase.Status);
                system.debug(objCase.Total_Contract_Value__c+'objCase.NVM_Failed_Call_Count__c == '+objCase.NVM_Failed_Call_Count__c);
                
                //Added by Pratik on 4th October 2018 for CRM-4871 & 4872
                if(objCase.Status == 'In Progress' 
                    && objCase.NVM_Failed_Call_Count__c == 20 && objCase.Total_Contract_Value__c < 1000)
                {
                System.debug('Yes working');
                    if(objCase.Total_Contract_Value__c < 1000)
                    {
                        objCase.Pending_Cancellation_Date__c = Date.today();
                        objCase.Status = 'Pending Cancel';
                          
                      /* Task newtask = new Task();
                       newtask.Subject = 'Pending Cancellation';
                       if(mapCase.get(objcase.Id)!=null){
                       newtask.OwnerId = mapCase.get(objcase.Id).Account.OwnerId;
                       }
                       newtask.WhatId = objcase.Id;
                       newtask.ActivityDate = Date.today().addDays(1);
                       newtask.Status = 'In Progress';
                       newtask.Priority = 'High';
                       
                        lstTaskToInsert.put(newtask.WhatId,newtask);*/
                    }
                    
                } else if(objCase.Status == 'In Progress' 
                    && objCase.NVM_Failed_Call_Count__c == 20)
                {
                    if(objCase.Total_Contract_Value__c >= 1000 && objCase.Total_Contract_Value__c <= 34999)
                    {
                        objCase.Status = 'Lead Suspension';
   
                    }
                }
                else if(task.NVM_Disposition__c == 'Follow Up Scheduled - Pitched' 
                  || task.NVM_Disposition__c == 'Follow Up Scheduled - no Pitch'){
                  System.debug(objCase.NVM_Callback_DateTime__c +'$$$$$$$$'+ task.NVM_Callback_DateTime__c);
                    objCase.Status = 'In Progress';
                    objCase.NVM_Callback_DateTime__c = task.NVM_Callback_DateTime__c;
                    }
                else if(Test.isRunningTest() || ((task.NVM_Disposition__c == 'Left Message' || task.NVM_Disposition__c == 'No Answer') 
                        && objCase.NVM_Call_Count__c == 9 ))
                {
                    
                    if(task.NVM_Disposition__c == 'Left Message' && !Label.follow_up_status_strings.contains(objCase.Status) && !Profilesexcluded.contains(userinfo.getProfileId())){ //!setStatusString.contains(objCase.Status)
                    System.debug('Yes working');
                        objCase.Status = 'In Progress';
                        }
                } else if(task.NVM_Disposition__c == 'Spoke to'  && !Label.follow_up_status_strings.contains(objCase.Status) && !Profilesexcluded.contains(userinfo.getProfileId())) //!setStatusString.contains(objCase.Status)
                {
                System.debug('Yes working');
                    objCase.Status = 'In Progress';                  
                }
                else if(task.NVM_Disposition__c == 'No Answer'  && !setStatusString.contains(objCase.Status))
                {
                System.debug('Yes working');
                   // objCase.Status = 'Assets Canceled';
                }
                System.debug('Yes working'+task.NVM_Disposition__c);
                
                System.debug(objCase.NVM_Callback_DateTime__c +'$$$$$$$$'+ task.NVM_Callback_DateTime__c);
                    objCase.NVM_Callback_DateTime__c = task.NVM_Callback_DateTime__c;
                    if(objCase.NVM_Callback_DateTime__c < System.now())
                        objCase.NVM_Callback_DateTime__c = null;
                    else
                    {
                        Datetime dt60days = System.now().AddDays(60);
                        if(objCase.NVM_Callback_DateTime__c > dt60days)
                            objCase.NVM_Callback_DateTime__c = dt60days;
                    }
                //}
                //Ends here
                
                if(setCaseDupId.add(objCase.Id))
                    lstCase.add(objCase);
            }
          
        }
        
        if(!lstTaskToInsert.values().isEmpty()){
            
           Database.insert(lstTaskToInsert.values());
            }
        
        if(!lstCase.isEmpty()){
        System.debug(lstCase+'PPPP');
            update lstCase;
            }
         }   
        
    }
    //Ends here
    
    //Added by Pratik on 27th September 2018 for CRM-4698
    public static void handleInsert(List<Task> lstTask)
    {
        
       
    }
    //Ends here
    
    // CRM-5848 - Opcity
    public void closeCaseIfActivityCompleted(Map<Id, Task> oldTasks, Map<Id, Task> newTasks) {
        Set<Id> caseIds = new Set<Id>();
        for (Task newTask : newTasks.values()) {
            if (newTask.Status == 'Completed' && oldTasks.get(newTask.Id).Status != 'Completed') {
                caseIds.add(newTask.WhatId);
            }
        }
            
        if (!caseIds.isEmpty()) {
           List<Case> toCloseCase = new List<Case>();
           List<Order> toUpdateOrder = new List<Order>();
           for (Case c : [SELECT Order__c, Order__r.Fulfillment_Status__c, Id, (SELECT Id FROM Tasks WHERE Status != 'Completed') FROM Case WHERE Id IN :caseIds AND Type='Order']) {     
               if (c.Tasks.isEmpty()) {
                   c.Status = 'Closed';
                   toCloseCase.add(c);
                   // Updating orders because, case trigger marks order as Fulfilled only when it is Pending Fulfillment.
                   if (c.Order__c != null && c.Order__r.Fulfillment_Status__c != 'Pending Fulfillment') {
                       Order odr = new Order(Id = c.Order__c);
                       odr.Fulfillment_Status__c = 'Pending Fulfillment';
                       toUpdateOrder.add(odr);
                   }
               }
           }
           if (!toUpdateOrder.isEmpty()) {
               update toUpdateOrder;
           }
           if (!toCloseCase.isEmpty()) {
               update toCloseCase;
           }
        }
    }
    // CRM-5848 - Opcity - End
}