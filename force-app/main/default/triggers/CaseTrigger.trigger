//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: CaseTrigger
// On SObject: Case
// Description: Case Creation Validation.
//
// 24th March 2015    Hemendra Singh Bhati   Original (Task # T-373061)
// 10th April 2014    Ravindra Shekhawat     Modified (Task # T-377170)
// 13th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Added Comments And Code Formatted.
// 14th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Added after insert/update handler call.
// 15th April 2015    Ravindra Shekhawat     Modified (Task # T-377170)  - Added before update handler call.
// 01st May 2015      Hemendra Singh Bhati   Modified (Issue # I-157478) - A user should not be able to close the parent global case
//                                                                       - if there are still child cases that are open.
//                                                                       - Added before update handler call.
// 01st June 2015     Hemendra Singh Bhati   Modified (Task # T-380907)  - Method Called: onAfterUpdate().
// 02nd June 2015     Hemendra Singh Bhati   Modified (Issue # I-165795) - Method Called: onBeforeUpdate().
// 1st  July 2015     Vikram Thallapelli     Modified  - (Task # Leap-1595) -Method Called: onBeforeUpdate().
// 25 April 2016      Krishna Veni Bodala    Modified - (LEAP-8430) - Fixed child cases count mismatch 
// 8th September 2016 Prasad Gunnam          Modified - Line No 150-164

trigger CaseTrigger on Case(after insert, after update, before update, before insert, After Delete) { 
    DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true. 
    private static boolean run = true;
    if (Dtrg.TaskTrigger__c != UserInfo.getUserName() && !MergeServiceSOAP.SkipTriggerExecution) {
        
        // Instantiating Case Trigger Handler.
        CaseTriggerHandler theHandler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
        ChildToParentUpdateHandler Handler = new ChildToParentUpdateHandler();
        // Boolean to stop recursive Update on cases
        
        /*
         * Added by: Sarang D
         * Description: Helper class call to execute triggered send callout .
        */
        if(trigger.isAfter && SFMC_CaseTriggerHandler.triggeredSendExecutedOnce != true){
            try{
                SFMC_CaseTriggerHandler.triggeredSendExecutedOnce = true;
                SFMC_CaseTriggerHandler.prepareTriggeredSendRequest(trigger.isInsert, trigger.isUpdate, trigger.newMap.keySet(), trigger.OldMap);    
            }
            catch(Exception ex){
                system.debug('Triggered Send Exception stack trace string: ' + ex.getStackTraceString());
                system.debug('Triggered Send Exception message: ' + ex.getMessage());
                system.debug('Triggered Send Exception cause: ' + ex.getCause());
                Error__c logError = new Error__c(Entity_Id__c ='Case Triggered Send', Interface_Name__c = 'SFMC_CaseTriggerHandler', Error_Description__c = ex.getMessage());
                insert logError;
            }
        } 
        
        // Turn off trigger if the value of custom setting field is true.
        if (Switch_CaseTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
            // Trigger Event - After Insert.
            if (trigger.isAfter && trigger.isInsert) {
                theHandler.onAfterInsert(trigger.new);
            }
            
            // Trigger Event - After Update.
            if (trigger.isAfter && trigger.isUpdate) {
                theHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
                theHandler.TigerLeadOrderUpdateUponCompletion(trigger.new);
                set < Case > setCaseIds = new set < Case > ();
                ProductCase__c ppcase = ProductCase__c.getValues('DIGITIALAGENT');
                for (Case cas: trigger.new) {
                    if ((cas.Type != null) && (cas.Area__c != null) && (cas.Sub_Area__c != null) && (cas.Status == 'Closed')) {
                        if ((cas.Oracle_Quote__c != null) && (cas.Type == ppcase.Case_Type__c) && (cas.Area__c == ppcase.Case_Area__c) && (cas.Sub_Area__c == ppcase.Case_Sub_Area__c)) {
                            System.debug('PPPPPPPP');
                            setCaseIds.add(cas);
                        }
                    }
                }
                if (setCaseIds.size() > 0) {
                    System.debug('PPPPPPPP' + setCaseIds);
                    theHandler.DAPCloseCase(setCaseIds);
                    
                }
            }
            
            // Added For Issue # I-154954.
            // CODE STARTS.
            // Trigger Event - After Insert/Update.
            if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
                theHandler.onAfterInsertUpdate(trigger.newMap, trigger.oldMap, trigger.isInsert);
            }
            // CRM-5924 Update Case Assignment for Broker Support Cases- Start
            if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate) && !CaseTriggerHandler.recursiveexecution) {
                theHandler.BrokerSupportCaseBeforeInsertUpdate(trigger.new, trigger.oldMap, trigger.isInsert,trigger.isUpdate);
            }
            // CRM-5924 Update Case Assignment for Broker Support Cases- End
            
            if (trigger.isAfter && trigger.isUpdate) {
                for (Case cas: trigger.new) {
                    system.debug('record type-----> '+ CaseRecordTypes__c.getValues('Retention').Record_Type_Id__c);
                    if (cas.Status == 'Closed'&& Trigger.oldMap.get(cas.Id).Status!= 'Closed' && cas.RecordTypeId == CaseRecordTypes__c.getValues('Retention').Record_Type_Id__c){
                        theHandler.updateClearsaveonAfterUpdate(trigger.new);
                    }
                }  
            }
            // CODE ENDS.
            
            // Added for Task # T-377170.
            // Trigger Event - Before Update.
            // CODE STARTS.
            if (trigger.isBefore && trigger.isUpdate) {
                theHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
            }
            
            // CODE ENDS.
            
            // Added for (Task # T-380067)
            // Trigger Event - Before Update.
            // CODE STARTS.
            if (trigger.isBefore && trigger.isInsert) {
                System.debug('Calling Before Insert');
                theHandler.onBeforeInsert(trigger.new);                
            }
            // CODE ENDS.
            //CRM-3448: Updating Case Owner's Manager for Service Request Record Type Cases.
            if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
                theHandler.onBeforeInsertUpdate(trigger.new, trigger.oldMap, trigger.isInsert);
            }
            
            /* COmmented for Service Leap
// CreatedBy: Vikram Thallapelli.
//Usage:  Used to Upadate Parent case status to  close, when all child cases are closed.
// Created Date:29 june
if(trigger.isBefore &&trigger.isUpdate ){
Handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
}
*/
        }
        
        // Commented for Service Leap 
        /*
//Validation Rule for Case closer.
CaseCloserValidation caseClosehandler = new CaseCloserValidation();
if(trigger.isBefore &&trigger.isUpdate ){
if(checkRecursive.runOnce()){
caseClosehandler.ErrorMsg(trigger.newMap, trigger.oldMap);
} 
}
*/
        //count number of child cases to a parent case
        CountRelatedchildCases CRCS = new CountRelatedchildCases();
        // Krishna Veni Bodala - 04/25/2016 - LEAP-8430 - Run the code only on after insert. This will allow Parent cases to be counted accurately.
        if (Trigger.isInsert && Trigger.isAfter) {
            CRCS.countRelatedcases(Trigger.new, True);
        }
        // Krishna Veni Bodala - 04/25/2016 - LEAP-8430 - Run the code only on after update. This will allow Parent cases to be counted accurately.
        if (trigger.isUpdate && Trigger.isAfter) {
            // if(checkRecursive.runOnce()){
            system.debug('>>>>>>');
            CRCS.updateCases(Trigger.newMap, Trigger.oldMap, True);
            // }
            
        }
        if (Trigger.isDelete) {
            CRCS.deleteCases(Trigger.oldMap, True);
        }
        
    }
    /*  private boolean runOnce() {
if (run) {
run = false;
return true;
} else {
return run;
}
} */
    //Added By Srinivas Pendli on 12.02.2015
    //creating retention commissions to the case owners
    
    /*  if (Trigger.isAfter) {
if (Trigger.isUpdate) {
if (Commissions_TriggerHelperClass.CaseTriggerRun == false) {
system.debug('Commission Loop 3 : ');
Commissions_TriggerHelperClass.CaseTriggerRun = true;
Commissions_CreateRetentionCommsClass CRC = new Commissions_CreateRetentionCommsClass();
//Added  By Prasad Gunnam on 08-09-2016
Map < Id, Case > caseRecords = new Map < Id, Case > ();
List<Id> cases = new List<Id>();
for (Case cs: trigger.New) {
cases.add(cs.Id);
}
Map<Id, List<Commission__c>> caseMap = new Map<Id, List<Commission__c>>();
for(Commission__c comm: [Select Id, Case_Asset_Relationship__r.Case__c from Commission__c where Case_Asset_Relationship__r.Case__c IN: cases]){
If(caseMap.containsKey( comm.Case_Asset_Relationship__r.Case__c )){
List<Commission__c> commissions = caseMap.get(comm.Case_Asset_Relationship__r.Case__c);
commissions.add(comm);
caseMap.put(comm.Case_Asset_Relationship__r.Case__c, commissions);
} else {
caseMap.put(comm.Case_Asset_Relationship__r.Case__c, new List<Commission__c> { comm });
}                  
}
//Modified By Prasad Gunnam on 08-09-2016
for (Case cs: trigger.New) {
Integer commisionSize = 0 ;
If( caseMap.containsKey(cs.Id) ){
commisionSize = caseMap.get(cs.Id).size();
}
if (commisionSize == 0 && cs.Status == 'Closed' && cs.type != 'Collections') {
caseRecords.put(cs.id, cs);
}
}
system.debug('Commission Loop >> : ' + caseRecords.size());
if (caseRecords.size() > 0) {
CRC.CaseCommission(caseRecords);
}
}
}
}*/
    
    //Added by Srinivas Vadla on 07/26/2016
    //JIRA - LEAP-9016
    id rectypidcase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
    if ((Trigger.isInsert|| trigger.isUpdate) && Trigger.isAfter) {
        system.debug('Insidetaskcreation');
        TaskTriggerHandler tt = new TaskTriggerHandler(Trigger.isExecuting, Trigger.size);
        List < Case > caseRecordsToCreateTasks = new List < Case > ();
        for (Case cst: trigger.New) {
            if(cst.RecordTypeId == rectypidcase && cst.Type == 'Tiger Retention'){
                caseRecordsToCreateTasks.add(cst); 
            }
        }
        system.debug('Case-Task loop'+caseRecordsToCreateTasks.size());
        if(caseRecordsToCreateTasks.size() > 0){
            system.debug('Calling handler to create tasks');
            tt.createTasks(caseRecordsToCreateTasks);
        }
        /*if(Trigger.isInsert) {
//Automatically submitting Service Request Case to Approval Process
Id csrectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();        
for (case caselop: trigger.New) {
if (caselop.recordtypeid == csrectypeid) {
// Create an approval request for the account
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Automatic submit.');
req1.setObjectId(caselop.id);                
// Submit the approval request for the account
Approval.ProcessResult result = Approval.process(req1);
}
}
}*/
    }
    
    
    //CRM-1925-Venu Ravilla- start-Did changes to update the status after updating the followup status
    private final string RetentionRecordTypeName = 'Retention';
    private final string CollectionRecordTypeName = 'Collections';
    Id rententionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
    Id collectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collections').getRecordTypeId();
    //Id RecordType rententionRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
    //Id RecordType collectionRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
    
    List<case> updateCaseStatusList = new List<Case>();
    if (trigger.isUpdate && Trigger.isBefore) {            
        for (Case cas: trigger.New) {
            If ((cas.RecordTypeId == rententionRecordTypeId) || (cas.RecordTypeId == collectionRecordTypeId)) {
                
                
                If (String.Isblank(Trigger.oldMap.get(cas.Id).Followup_Status__c) && string.IsNotBlank(cas.Followup_Status__c) && Trigger.oldMap.get(cas.Id).Status == 'New')
                {
                    if(cas.status!='Lead Suspension'){ cas.Status = 'In Progress';}
                    updateCaseStatusList.add(cas);
                }                    
            }
        }
    }
    // Update updateCaseStatusList;
    //CRM-1925-Venu Ravilla- End-Did changes to update the status after updating the followup status
}