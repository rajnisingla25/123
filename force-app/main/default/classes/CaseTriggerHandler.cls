//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler: CaseTriggerHandler
// Trigger Name: CaseTrigger
// On SObject: Case
// Description: Case Creation Validation.
//
// 24th March 2015    Hemendra Singh Bhati   Original (Task # T-373061)
// 10th April 2014    Ravindra Shekhawat     Modified (Task # T-377170)
// 13th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Added Comments, Formatted Code, Updated Method: onAfterUpdate().
// 14th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Added Method: onAfterInsertUpdate().
// 15th April 2015    Ravindra Shekhawat     Modified (Task # T-377170)  - Added Method: onBeforeUpdate().
// 01st May 2015      Hemendra Singh Bhati   Modified (Issue # I-157478) - Updated Method: onBeforeUpdate().
// 06th May 2015      Ravindra Shekhawat     Modified (Task # T-380067)  - Updated Method: onAfterInsert(),onAfterUpdate()
// 25th May 2015      Manish Soni            Modified (Issue # I-164322) - Updated Method: onBeforeInsert(),onBeforeUpdate()
// 01st June 2015     Hemendra Singh Bhati   Modified (Task # T-380907)  - Updated Method: onAfterUpdate().
// 02nd June 2015     Hemendra Singh Bhati   Modified (Issue # I-165795) - Updated Method: onBeforeUpdate().
// 23rd June 2015     Kalyan Meda            Modified ( Leap 1585)       - Updated Method: onBeforeInsert,added- assignCaseToRetentionRepOnAccount().
// 24th May 2016      Venkataramana Cheedara Modified ( Leap 8497)       - Updated Method: onBeforeUpdate,added Condition in assignCaseToRetentionRepOnAccount() to fire only when the Retention case is closed. 
// 24th May 2016      Venkataramana Cheedara Modified ( Leap 8497)       - Updated Method: onAfterInsertUpdate,added Condition in validateCasesInsertionUpdation() mehod.
// 24th May 2016      Krishna Veni Bodala    Modified (Leap 8262)        - Added Method:fullFillOrderProductsForTigerLeadAmendmentOrders
// 12th Jul 2018      Vamsi Chinnam          Modified Sep-153            - Updated Method : onBeforeInsert,onBeforeUpdate added oldMap as parameter for assignCaseToRetentionRepOnAccount
public without sharing class CaseTriggerHandler {
    public static boolean recursiveexecution = False;
    public static boolean isExecuted = false;
    private integer batchSize = 0;
    private boolean isExecuting = false;
    private CaseTriggerHandlerManager theManager = null;
    private static set<Id> toBeUpdatedCARs = new set<Id>();
    public CaseTriggerHandler(Boolean isExecuting, Integer size) {
        batchSize = size;
        isExecuting = isExecuting;
        theManager = new CaseTriggerHandlerManager();
    }
    
    /*
@method      : onAfterInsert
@description : Gets called on after insert trigger event. 
@params      : trigger.new
@returns     : void 
*/
    public void onAfterInsert(List < Case > newValues) {
        // Toggle case history tracking.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_History_Tracking_Off__c == false) {
            theManager.insertCaseResolutionTracking(newValues);
        }
    }
    
    /*
@method      : onBeforeInsert
@description : Gets called on before insert trigger event.
@params      : trigger.new
@returns     : void
*/
    public void onBeforeInsert(List < Case > newValues) {
        
        // Set SLA Enforcments on Case
        system.debug('newvalue----->>>' + newValues);
        if (Switch_CaseTrigger__c.getInstance().Set_SLA_Functionality_Off__c == false) {
            theManager.setSLAFields(newValues);
        }
        
        // Turn on/off account population from selected contact relationship on case.
        if (Switch_CaseTrigger__c.getInstance().Set_Account_Population_Off__c == false) {
            theManager.updateCaseAccountFromRelationship(false, newValues, null);
        }
        
        // Turn on/off Contact population from selected Account relationship on case.
        if (Switch_CaseTrigger__c.getInstance().Set_Contact_Population_Off__c == false) {
            theManager.updateCaseContactFromRelationship(false, newValues, null);
        }
        
        // Turn on/Off Auto assign retention cases to the rep on the account team.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_Auto_Assign_To_Rep_Off__c == false) {
            Id rectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
            Boolean executeAssign = false;
            for (case caselop: newValues) {
                if (caselop.recordtypeid == rectypeid) {
                    executeAssign = true;
                    
                }
            }
            if (executeAssign) {
                theManager.assignCaseToRetentionRepOnAccount(newValues,null);
            }
        }    
        
        // the following method is added as part of ACP project to populate phone fields - venkat arisa
        theManager.populateCasePhoneFields(newValues);
        
    }
    
    /*
@method      : onAfterUpdate
@description : Gets called on after update trigger event.
@params      : trigger.newMap, trigger.oldMap
@returns     : void
*/
    public void onAfterUpdate(Map < Id, Case > newCaseValuesMap, Map < Id, Case > oldCaseValuesMap) {
        //Added by Pratik on 4th October 2018 for CRM-4871
        Map<Id, Case> mapCase = new Map<Id, Case>([Select Account.OwnerId, Account.Name 
                                                   From Case 
                                                   Where Id IN:newCaseValuesMap.keySet()]);
        
        Map<Id,Task> lstTask = new Map<Id,Task>();
        
        Id salesActivitiesRecordTypeId = Schema.SObjectType.TASK.getRecordTypeInfosByName().get('Sales Activities').getRecordTypeId();
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        
        for(Case newCase :newCaseValuesMap.values())
        {
            //Added by Pratik on 05th Oct 2018 for CRM-4884
            if(newCase.Followup_Status__c != Null 
               && (newCase.Followup_Status__c != oldCaseValuesMap.get(newCase.Id).Followup_Status__c))
            {
                Task task = new Task();
                
                if(userName.contains('nvmapiuser@move.com')){
                    task.OwnerId = newCase.OwnerId;
                }
                else
                    task.OwnerId = userId;
                task.Case__c = newCase.Id;
                task.Description = newCase.Description;
                task.Status = 'Completed';
                task.Priority = 'Normal';
                task.Subject = newCase.Followup_Status__c +' for the Account - ' + mapCase.get(newCase.Id).Account.Name ;
                task.WhatId = newCase.Id;
                //task.AccountId = mapCase.get(newCase.Id).Account.Id;
                task.WhoId = newCase.ContactId;
                task.Outcome__c = newCase.Followup_Status__c;
                if(task.Outcome__c == 'No Answer')
                    task.Outcome__c = 'Left Message';
                if(task.Outcome__c == 'Follow Up Scheduled')
                    task.Outcome__c ='Spoke to';
                //task.Issue__c = newCase.Rejected_Reason__c;
                task.Type = 'Call - Outbound';
                if(oldCaseValuesMap.containskey(task.Id))
                {
                    task.Description = oldCaseValuesMap.get(task.Id).Description;
                    //task.NVM_Notes__c = oldCaseValuesMap.get(task.Id).NVM_Notes__c;
                }
                
                task.ActivityDate = system.today();
                task.RecordTypeId = salesActivitiesRecordTypeId;
                lstTask.put(newCase.Id,task);
                //Ends here
            }
        }
        //Ends here
        
        System.debug(lstTask.values()+'KKKKKKKKKCaseTrigger');
        if(!lstTask.values().isEmpty()){
            //insert lstTask.values();
        }
        Integer limit1 =0;
        
        limit1 = Limits.getQueries();
        System.debug('Current limit  :'+limit1);
        if(limit1<94){
            System.debug('fullFillOrderProductsForTigerLeadAmendmentOrders');
            fullFillOrderProductsForTigerLeadAmendmentOrders(newCaseValuesMap.values(), oldCaseValuesMap);
        }
        // Toggle case history tracking.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_History_Tracking_Off__c == false) {
            limit1 = Limits.getQueries();
            if(limit1<94){
                System.debug('upsertCaseResolutionTracking');
                theManager.upsertCaseResolutionTracking(newCaseValuesMap, oldCaseValuesMap);
            }
        }
        
        // Turn on/off asset at risk flag updation process if a case is updated.
        // The mapping of assets and cases are maintained in a junction object named "Case_Asset_Relationship__c".
        if (Switch_CaseAssetRelationshipTrigger__c.getInstance().Set_Asset_Risk_Updation_Off__c == false) {
            Boolean executeAssign = false;
            limit1 = Limits.getQueries();
            if(limit1<94){
                System.debug('updateAssetAtRiskFlagOnCaseUpdate');
                for (case caselop: newCaseValuesMap.values()) {                 
                    if (caselop.type != null && caselop.type == 'Retention') {
                        executeAssign = true;
                        
                    }
                }
                if (executeAssign) {
                    theManager.updateAssetAtRiskFlagOnCaseUpdate(newCaseValuesMap, oldCaseValuesMap);
                }
            }
        }
        limit1 = Limits.getQueries();
        Boolean executeAssigns = false;
        if(limit1<94){
            System.debug('updateCaseRelationshipStatus');
            for (case caselop: newCaseValuesMap.values()) {                 
                if (caselop.status == 'Closed') {
                    executeAssigns = true;
                    
                }
            }
            if (executeAssigns) {
                theManager.updateCaseRelationshipStatus(newCaseValuesMap, oldCaseValuesMap);
            } 
        }
        
        // Adds the rep who closes a retention case or as Retention Rep on the Account Team.
        if (Switch_CaseTrigger__c.getInstance().Set_Retention_Rep_to_Account_Team_off__c == false) {
            set<id> closedcaseset = new set<id>();
            Boolean executeAssign = false;
            for (case caselop: newCaseValuesMap.values()) {
                System.debug('addRepToAccountTeamOnCaseClosure'+ caselop.Owner.Profile.Name);
                if (caselop.status == 'Closed' && (caselop.type == 'Retention' || caselop.type == 'Collections')) {
                    executeAssign = true;
                    
                }
            }
            if (executeAssign) {
                limit1 = Limits.getQueries();
                //if(limit1<94){
                System.debug('addRepToAccountTeamOnCaseClosure');
                theManager.addRepToAccountTeamOnCaseClosure(newCaseValuesMap, oldCaseValuesMap);
                //       }
            }
        }
        
        if (CaseTriggerHandlerManager.parentCaseUpdateFlag == false){
            limit1 = Limits.getQueries();
            //if(limit1<94){
            System.debug('updateParentCaseStatus');
            Boolean executeAssign = false;
            for (case caselop: newCaseValuesMap.values()) {      
                System.debug('caselop.parentid---->' +caselop.parentid);
                if (caselop.status == 'Closed' && caselop.ParentId != null) {
                    executeAssign = true;
                    
                }
            }
            if (executeAssign) {
                theManager.updateParentCaseStatus(newCaseValuesMap, oldCaseValuesMap);
            }
        }
        //Invoke Case Assignment rules upon update
        theManager.invokeCaseAssignmentRules(newCaseValuesMap, oldCaseValuesMap);
        theManager.updateFulfillmentStatusAfterCaseClosed(newCaseValuesMap, oldCaseValuesMap);
        theManager.updateFulfillmentStatusAfterCaseClosedForIDXProduct(newCaseValuesMap, oldCaseValuesMap);
        // Create Case Comment when Follow up Status is Updated
        /*if (Switch_CaseTrigger__c.getInstance().Set_Case_Followup_Comment_Creation_Off__c == false) {
Boolean executeAssign = false;

for (case caselop: newCaseValuesMap.values()) {                
if (caselop.Type == 'Collections' || caselop.Type == 'Retentions') {
executeAssign = true;

}
}
if (executeAssign) {
theManager.CreateCaseCommOnFollowup(newCaseValuesMap, oldCaseValuesMap);
}  
}   */
        isExecuted = true;
    }
    
    /*
@method      : onAfterInsertUpdate
@description : Gets called on after insert/update trigger event.
@params      : trigger.newMap, trigger.oldMap, trigger.isInsert
@returns     : void
*/
    public void onAfterInsertUpdate(Map < Id, Case > newMap, Map < Id, Case > oldMap, Boolean isInsert) {
        // Turn on/off case creation validation logics.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_Creation_Validation_Off__c == false) {
            Boolean executeAssign = false;
            for (
                case caselop:
                newMap.values()) {
                    if (caselop.Type == 'Collections' || caselop.type == 'MLS Support' || caselop.type == 'Resolution') {
                        executeAssign = true;
                        
                    }
                }
            if (executeAssign) {
                Integer limit1 =0;
                limit1 = Limits.getQueries();
                if(limit1<94){
                    theManager.validateCasesInsertionUpdation(newMap, oldMap, isInsert);
                }
            }
        }
        
        // CRM-3191 - Prevent inserting/updating new case if there is already an open case on the account 
        theManager.validateRetentionCaseType(newMap, oldMap, isInsert); 
        // CRM-3191 - End
    }
    
    /*
@method      : onBeforeUpdate
@description : Gets called on before update trigger event.
@params      : trigger.newMap, trigger.oldMap
@returns     : void
*/
    public void onBeforeUpdate(Map < Id, Case > newMap, Map < Id, Case > oldMap) {
        // Turn on/off case creation validation logics.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_History_Tracking_Off__c == false) {
            theManager.updateCaseDurationForClosedCases(newMap, oldMap);
        }
        
        
        
        // Turn on/off parent case status validation logics when a user is trying to close a parent case and its child cases are not closed.
        if (Switch_CaseTrigger__c.getInstance().Set_Parent_Case_Validation_Off__c == false) {
            Id rectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collections').getRecordTypeId();
            Boolean executeAssign = false;
            for (case caselop:newMap.values()) {
                if (caselop.recordtypeid != rectypeid) {
                    executeAssign = true;
                    
                }
            }
            if (executeAssign) {
                theManager.validateParentCaseStatusClosed(newMap, oldMap);
            }  
        }
        
        //MRB added this part of code. Setting Account and contact using email address and phone.  
        /*if(Switch_CaseTrigger__c.getInstance().Set_LiveAgent_Account_Population_Off__c == false){
theManager.setLiveAgentAccountPopulation(newMap); 
}*/
        // Set SLA Enforcments on Case
        if (Switch_CaseTrigger__c.getInstance().Set_SLA_Functionality_Off__c == false) {
            theManager.updateSLAFields(newMap, oldMap);
        }
        
        // Create Case Comment when Follow up Status is Updated
        if (Switch_CaseTrigger__c.getInstance().Set_Case_Followup_Comment_Creation_Off__c == false) {
            theManager.CreateCaseCommOnFollowup(newMap, oldMap);
        }  
        
        // Set TL activities on Case
        if (Switch_CaseTrigger__c.getInstance().Set_SLA_Functionality_Off__c == false) {
            theManager.updateTLactivitiesOwner(newMap, oldMap);
        }
        
        if (Switch_CaseTrigger__c.getInstance().Set_Update_Survey_Details_Function_Off__c == false) {
            theManager.updateLastSurveyDetails(newMap, oldMap);
        }
        
        // Turn on/off account population from selected contact relationship on case
        if (Switch_CaseTrigger__c.getInstance().Set_Account_Population_Off__c == false) {
            theManager.updateCaseAccountFromRelationship(true, newMap.values(), oldMap);
        }
        
        // Turn on/off Contact population from selected Account relationship on case
        if (Switch_CaseTrigger__c.getInstance().Set_Contact_Population_Off__c == false) {
            theManager.updateCaseContactFromRelationship(true, newMap.values(), oldMap);
        }
        
        // Turn on/Off Auto assign retention cases to the rep on the account team.
        if (Switch_CaseTrigger__c.getInstance().Set_Case_Auto_Assign_To_Rep_Off__c == false) {
            //id rectypeid = [select id from recordtype where developername = 'Retention'].id;
            Id rectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
            Boolean executeAssign = false;
            for (
                case caselop:
                oldMap.values()) {
                    //Added condition for change in Case type
                    if (caselop.recordtypeid != rectypeid || caselop.Type!=newMap.get(caselop.id).Type) {
                        executeAssign = true;
                        
                    }
                }
            if (executeAssign) {
                theManager.assignCaseToRetentionRepOnAccount(newMap.values(),oldMap);
            }
        }
        // CRM-2092 Added by Venu- to update the last modified by field
        //Update case last worked by for collectionCases
        theManager.updateCaseLastWorkedByForCollectionCases(newMap, oldMap);
        //theManager.populateOpcityResearchFields(newMap.values(),oldMap);//CRM-6223
        // CRM-2092 Added by Venu- to update the last modified by field
    }
    //CRM- 3448: Updating Case Owner's Manager for Service Request Record Type Cases.
    public void onBeforeInsertUpdate(List<Case> newList, Map<Id,Case> oldMap, Boolean isInsert) {
        List<Case> newCSList = new List<Case> ();
        System.debug('newList:'+newList);
        Boolean executeAssign = false;
        if(!newList.isEmpty()) {
            System.debug('newList:'+newList);
            Id rectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            for(Case newCase: newList) {
                if(newCase.Status != 'Closed' && newCase.OwnerId != null && newCase.recordtypeid == rectypeid)
                    newCSList.add(newCase);
                executeAssign = true;
            }
            if (executeAssign){
                theManager.UpdateCaseManagers(newCSList, oldMap, isInsert);
            }
            theManager.UpdatePhoneNumberManager(newList, oldMap, true);
            theManager.UpdateSFMCSyncFlag(newList, oldMap, true);
        }
    }
    
    public void TigerLeadOrderUpdateUponCompletion(List < Case > lstCases) {
        List < Order > lstOrder = new List < Order > ();
        Set < Id > setOrderIds = new Set < Id > ();
        Set<String> ManualPartNumbers = new Set<String>();
        Set<id> ordIdSetNonTL = new Set<id>();
        ManualPartNumbers.add('REESIO');
        ManualPartNumbers.add('MEDIABUY');
        ManualPartNumbers.add('LISTHUBPRO');
        ManualPartNumbers.add('DOMAINNAME');
        
        // As part of CRM-2341,CRM-2329 added DOMAINNAME and LISTHUBPRO
        for (Case cas: lstCases) {
            if (cas.order__c != null && cas.Status == 'Closed') {
                setOrderIds.add(cas.order__c);
            }
        }
        
        // CRM-1423 Moved below SOQL under already written if.
        /*for(OrderItem ordItm:[Select id, OrderId from orderItem where OrderId IN :setOrderIds and Part_Number__c IN :ManualPartNumbers]){
ordIdSetNonTL.add(ordItm.OrderId);
}*/
        
        if (setOrderIds.size() > 0)
            // CRM-1423 Moved above SOQL under already written if.
            for(OrderItem ordItm:[Select id, OrderId from orderItem where OrderId IN :setOrderIds and Part_Number__c IN :ManualPartNumbers]){
                ordIdSetNonTL.add(ordItm.OrderId);
            }
        
        lstOrder = [Select Id, name, tigerLeadProductExists__c from order where id =: setOrderIds and id Not IN :ordIdSetNonTL and Status != 'Complete'
                    and tigerLeadProductExists__c = false
                   ];
        for (order odr: lstOrder) {
            odr.tigerLeadProductExists__c = true;
        }
        if (lstOrder.size() > 0) {
            update lstOrder;
        }
    }
    
    
    Public void DAPCloseCase(Set < Case > setCase) {
        Set < Id > setQuoteDapIds = new Set < Id > ();
        
        for (Case cas: setCase) {
            setQuoteDapIds.add(cas.Oracle_Quote__c);
        }
        if (setQuoteDapIds.size() > 0) {
            DAPAssetFulfill(setQuoteDapIds);
        }
    }
    
    @Future
    Public Static void DAPAssetFulfill(Set < Id > setQuoteDapIds) {
        System.debug('PPPPPPPP');
        List < Asset > lstAsset = [Select AccountId, Line_type__c, Fulfillment_Status__c, order_line_item__r.order.Oracle_Quote__c from Asset where(Fulfillment_Status__c != 'Fulfilled') and Product_Code__c = 'DIGITALAGENT'
                                   and order_line_item__r.order.Oracle_Quote__c =: setQuoteDapIds
                                  ];
        Integer rcount = lstAsset.size();
        System.debug('PPPPPPPP' + rcount);
        if (rcount > 0) {
            System.debug('PPPPPPPP' + rcount);
            //  for(Case cas:setCase){
            //  cas.addError('All DAP assets related to case quote is not fulfilled');
            //  }
            for (Asset ast: lstAsset) {
                ast.Fulfillment_Status__c = 'Fulfilled';
            }
            update lstAsset;
        } else {
            //AdVerificationCase(setQuoteDapIds);
        }
    }
    
    Public void AdVerificationCase(Set < Id > setQuoteDapIds) {
        Integer rrrcount = 0;
        ProductCase__c ppcase = ProductCase__c.getValues('Add Verification');
        if (ppcase != null) {
            List < Case > lstCase = [Select Id, Oracle_Quote__c from
                                     case where Oracle_Quote__c = :
                                     setQuoteDapIds and Type =: ppcase.Case_Type__c
                                    ];
            if (lstCase.size() < 1) {
                List < Asset > lstAsset = [Select AccountId, Line_type__c, order_line_item__r.order.Oracle_Quote__c from Asset where asset_type__c = 'Parent'
                                           and(Fulfillment_Status__c = 'Fulfilled') and Product_Code__c = 'DIGITALAGENT'
                                           and order_line_item__r.order.Oracle_Quote__c =: setQuoteDapIds
                                          ];
                
                Id quoteIdds = null;
                Id accid = null;
                for (Asset asst: lstAsset) {
                    if (asst.Line_type__c == 'Add') {
                        System.debug('DAP ADD');
                        rrrcount++;
                        quoteIdds = asst.order_line_item__r.order.Oracle_Quote__c;
                        accid = asst.AccountId;
                    }
                }
                System.debug('Record Count' + rrrcount);
                if (rrrcount > 0) {
                    System.debug('DAP ADD');
                    
                    List < Case > lstCases = new List < Case > ();
                    
                    System.debug('DAP ADD');
                    Map < String, String > mapManualQueueName = new Map < String, String > ();
                    for (Group grp: [SELECT DeveloperName, Id, Name, Type FROM Group WHERE Type = 'Queue']) {
                        mapManualQueueName.put(grp.DeveloperName, grp.Id);
                    }
                    Case caseToAdd = new Case();
                    caseToAdd.Status = 'New';
                    caseToAdd.Origin = 'Web';
                    caseToAdd.Type = ppcase.Case_Type__c;
                    caseToAdd.Is_Tiger_Lead__c = false;
                    caseToAdd.Oracle_Quote__c = quoteIdds;
                    caseToAdd.Description = 'Complete Ad Verification';
                    caseToAdd.Is_Pre_Welcome_Call__c = false;
                    caseToAdd.Area__c = ppcase.Case_Area__c;
                    caseToAdd.Subject = ppcase.Case_Subject__c;
                    caseToAdd.Sub_Area__c = ppcase.Case_Sub_Area__c;
                    caseToAdd.AccountId = accid;
                    if (ppcase.Case_Subject__c != null) {
                        if (mapManualQueueName.containskey(ppcase.Case_Subject__c)) {
                            caseToAdd.ownerId = mapManualQueueName.get(ppcase.Case_Subject__c);
                        }
                    }
                    lstCases.add(caseToAdd);
                    if (lstCases.size() > 0) {
                        Insert lstCases;
                    }
                }
            }
        }
    }
    
    /**
* Update Order Products Fullfillment Status to Fullfilled When
*    The case belongs to Tiger lead Amendment Orders Open Queue.
* Updating Order products Fullfillment status in turn updates Order Fullfillment status and this in turn creates Assets
*/
    
    // CRM-1371 Using below set to avoid processing same order if its already processed by below function
    private static Set<Id> fullFillOrderProductsForTigerLeadAmendmentOrdersIds = new Set<Id>();
    public static void fullFillOrderProductsForTigerLeadAmendmentOrders(List<Case> newCaseValues, Map<Id,Case> oldCaseValuesMap){
        Set<Id> orderIds = new Set<Id>();
        List<Order> toBeFullfilledOrderProducts = new List<Order>();
        for(Case caseVar : newCaseValues){
            if(caseVar.Status == 'Closed' && oldCaseValuesMap.get(caseVar.Id).Status != 'Closed' && caseVar.Order__c != null &&
               caseVar.Subject == 'Amendment Quote Submitted' && caseVar.Type == 'TigerLead' ){                                                                    
                   // CRM-1371 check if Order is processed earlier, if not then add it to set
                   if (!fullFillOrderProductsForTigerLeadAmendmentOrdersIds.contains(caseVar.Order__c)) {
                       orderIds.add(caseVar.Order__c);
                       // CRM-1371
                       fullFillOrderProductsForTigerLeadAmendmentOrdersIds.add(caseVar.Order__c);
                   }
               }
        }
        
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!orderIds.isEmpty()) {
            for(Order item : [SELECT Id, Fulfillment_Status__c
                              FROM Order 
                              WHERE Id IN :orderIds
                              AND Fulfillment_Status__c != 'Pending Fulfillment']){
                                  if(item.Fulfillment_Status__c != 'Fulfilled'){
                                      item.Fulfillment_Status__c = 'Pending Fulfillment';
                                      toBeFullfilledOrderProducts.add(item);
                                  }
                              }
            try{
                update toBeFullfilledOrderProducts;
            }
            catch(exception ex){
                System.debug('exception message ' +ex.getMessage() );
            }
        }
    }
    /*
@method      : updateClearsaveonAfterUpdate
@description : Updates the Saved Amount for the CAR based on the orderproduct 
@params      : Map<Id, case> newMap
@returns     : void
*/
    public void updateClearsaveonAfterUpdate(List<case> lstCA){                                           
        
        set<Id> caseid = new set<Id>();
        set<Id> sAssetIds = new set<Id>();
        set<Id> OrderIds = new set<Id>();
        set<Id> QuoteIds = new set<Id>();
        Set<Id> theAssetIds = new Set<Id>();
        Map<Id,List<Case_Asset_Relationship__c>> CARsCountMap   = new Map<Id, List<Case_Asset_Relationship__c>>();
        List<Id> LAssetIds = new List<Id>();
        List<Case_Asset_Relationship__c> updatelstCA = new List<Case_Asset_Relationship__c>();
        Asset theAsset = null;
        Map<Id, Asset> toBeUpdated = new Map<Id, Asset>();
        
        for(case theRelationship : lstCA) {
            caseid.add(theRelationship.id);
            QuoteIds.add(theRelationship.Oracle_Quote__c);   
        }
        system.debug('CaseID'+caseid);
        system.debug('QuoteIds'+QuoteIds);
        // CRM-2504 Changes to exclude the expired and cancelled assets to generate and Save amount and clean save flag
        List<Case_Asset_Relationship__c> lstCAR = new List<Case_Asset_Relationship__c>([Select id,Asset__c,Asset__r.At_Risk__c,At_Risk_Amount__c,case__c,case__r.Status,Case__r.Order__c,Asset_Status__c from Case_Asset_Relationship__c where Case__c in : caseid and Asset_Status__c!= 'Expired' AND Asset_Status__c != 'Cancelled']);
        system.debug('Cars'+lstCAR.size()); 
        for(Case_Asset_Relationship__c car : lstCAR) {
            LAssetIds.add(car.Asset__c);
        }
        Map<Id,String>  assetDatesMap  = OrderItemTriggerHandler.createAssetDateMap(LAssetIds);
        CARsCountMap =  OrderItemTriggerHandler.fetchCARCount(assetDatesMap);
        
        List<Order> ord = new List<order>([Select id ,Oracle_Quote__c ,Case__c from order where Case__c in : caseid]);
        system.debug('orders'+ord.size());
        for(order o : ord){
            OrderIds.add(o.Id); 
        }
        system.debug('ord'+OrderIds);
        Map<id,OrderItem> lstOrderItems = new Map<id,OrderItem>([Select id,OrderId ,Asset__c from OrderItem where OrderId in : OrderIds]);
        for(OrderItem o : lstOrderItems.values()){
            sAssetIds.add(o.Asset__c);
        } 
        map<id,Asset> assetmap = new map<id,Asset>([select id from asset where id in:sAssetIds]);
        system.debug('lstOrderItems '+lstOrderItems.size());    
        system.debug('Map Values coming here ravilla*'+assetDatesMap); 
        system.debug('Internal Map Values coming here Venu@'+CARsCountMap);
        system.debug('Asset Map Values coming here Venu@'+assetmap); 
        for(Case_Asset_Relationship__c theRelationship : lstCAR) {
            theAssetIds.add(theRelationship.Asset__c);         
          //system.debug('The Vaules in the Asset Map are' + assetmap);
            if(!CARsCountMap.isEmpty()){
            If(CARsCountMap.get(theRelationship.Asset__c) != null){
            system.debug('The count of the CArs' + CARsCountMap.get(theRelationship.Asset__c).size());
            If(CARsCountMap.get(theRelationship.Asset__c).size() > 1){
                    theRelationship.Saved_Amount__c = 0;        
           }
           else if(CARsCountMap.get(theRelationship.Asset__c).size() < 2){
                system.debug('Inside#####Loop:********' +theRelationship.Asset_Status__c);
                theRelationship.Clear_Save__c = True;
                theRelationship.Saved_Amount__c = theRelationship.At_Risk_Amount__c;
                }
                }
                }
          else if(assetmap.isEmpty() || !assetmap.containskey(theRelationship.Asset__c)){
                system.debug('Inside Loop:' +theRelationship.Asset_Status__c);
                theRelationship.Clear_Save__c = True;
                theRelationship.Saved_Amount__c = theRelationship.At_Risk_Amount__c;
            }                    
              updatelstCA.add(theRelationship);
            }
        
        if(updatelstCA.size()>0){
        Try{
            Update updatelstCA;
            }
                Catch (Exception e){
                System.debug('Exception Occured while updating the CAR records on Case close is '+ e.getMessage() + 'Line Number is' + e.getLineNumber());
            }
        }
        for(Id theAssetId : theAssetIds) {        
            toBeUpdated.put(theAssetId, new Asset(
                Id = theAssetId,
                At_Risk__c = false
            ));        
        }  
        
        // Updating Assets.
        if(toBeUpdated.size() > 0) {
            SkipAssetTrigger.setSkipTrgTrue();
            update toBeUpdated.values();
        }
        
    }     
    // CRM-5924 Update Case Assignment for Broker Support Cases- Start  
    public void BrokerSupportCaseBeforeInsertUpdate(List<Case> newCaseList, Map<Id,Case> oldCaseMap, Boolean isInsert, Boolean isUpdate) {
        List<case> lstcases = new List<case>();
        List<case> casesneedassignment = new List<case>();
        Set<Id> setAccId = new Set<Id>();
        Map<Id,Id>mapcaseownerId = new Map<Id,Id>();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        System.debug('newList:'+newCaseList);
        ID  BrokerSupportId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Broker Support').RecordTypeId;
        for(case cse:newCaseList){
            if(cse.RecordTypeId == BrokerSupportId)
                setAccId.add(cse.AccountId);
        }  
        
        if(!setAccId.isEmpty() || test.isRunningTest()){
            List<AccountTeamMember> lstAccountTeam = [Select AccountId, UserId From AccountTeamMember 
                                                      Where TeamMemberRole = 'Account Manager' 
                                                      AND AccountId IN:setAccId and User.IsActive = True];
            if(!lstAccountTeam.isEmpty()){
                for(AccountTeamMember accountTeam :lstAccountTeam){
                    mapcaseownerId.put(accountTeam.AccountId, accountTeam.UserId);
                }
            }
            System.debug('The MAp after assignement:'+mapcaseownerId);
            for(case ca:newCaseList){
                If(isUpdate && oldCaseMap.get(ca.Id).RecordTypeId != BrokerSupportId && ca.RecordTypeId == BrokerSupportId){
                    casesneedassignment.add(ca);
                }
                else if(isInsert && ca.RecordTypeId == BrokerSupportId){
                    casesneedassignment.add(ca);
                }
            }
            for (case cas:casesneedassignment){
                //Id AccownerId = mapcaseownerId.get(cas.AccountId);
                //Id BrokersupportId = '00Gj00000024NuN';
                Case ca = new Case(Id=cas.Id);
                if(mapcaseownerId.containsKey(cas.AccountId)){
                    ca.ownerId = mapcaseownerId.get(cas.AccountId);
                }
                else {
                    System.debug('Case Coming Here '+cas);
                    ca.setOptions(dmlOpts);
                }
                lstcases.add(ca);
            }
            if(!lstcases.isEmpty()){
                Update lstcases;
            }
        }
        // CRM-5924 Update Case Assignment for Broker Support Cases- End
    }
}