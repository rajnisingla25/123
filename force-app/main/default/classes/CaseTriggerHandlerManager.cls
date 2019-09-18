// (c) 2015 Appirio, Inc.
//
// Trigger Handler Manager: CaseTriggerHandlerManager
// Trigger Handler: CaseTriggerHandler
// Trigger Name: CaseTrigger
// On SObject: Case
// Description: Case Creation Validation.
//
// 24th March 2015    Hemendra Singh Bhati   Original (Task # T-373061)
// 27th March 2015    Hemendra Singh Bhati   Modified (Issue # I-153134) - Updated Method: validateCasesCreation().
// 30th March 2015    Hemendra Singh Bhati   Modified (Issue # I-153134) - Updated Method: validateCasesCreation().
// 10th April 2014    Ravindra Shekhawat     Modified (Task # T-377170)  - Added Methods: upsertCaseResolutionTracking(),
//                                                                         insertCaseResolutionTracking().
// 13th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Added Comments, Formatted Code For Methods:
//                                                                       - upsertCaseResolutionTracking(), insertCaseResolutionTracking().
// 14th April 2015    Hemendra Singh Bhati   Modified (Issue # I-154954) - Updated Method: validateCasesInsertionUpdation().
//                                                                       - Changed method name from "validateCasesCreation" to
//                                                                       - "validateCasesInsertionUpdation". Re-factored method code to include
//                                                                       - logics to validation case updations.
// 15th April 2015    Ravindra Shekhawat     Modified (Task # T-377170)  - Added Method: updateCaseDurationForClosedCases().
// 01st May 2015      Hemendra Singh Bhati   Modified (Issue # I-157478) - Added Method: validateParentCaseStatusClosed().
// 06th May 2015      Ravindra Shekhawat     Modified (Task # T-380067)  - Added Method: setSLAFields(),updateSLAFields(),getCaseTypeSLAValueMap(),filterClosedCases()
// 25th May 2015      Manish Soni            Modified (Issue # I-164322) - Added Method: updateCaseAccountFromRelationship()
// 01st June 2015     Hemendra Singh Bhati   Modified (Task # T-380907)  - Added Method: updateAssetAtRiskFlagOnCaseUpdate().
// 02nd June 2015     Hemendra Singh Bhati   Modified (Issue # I-165795) - Updated Method: validateParentCaseStatusClosed().
// 23rd June 2015     Kalyan Meda            Modified LEAP - 1585        - Added Method: assignCaseToRetentionOrCollectionRepOnAccount(),isRepOnVacation()
// 1st  Sept 2015     Kalyan Meda            Modified LEAP - 4292        - Added Method : updateCaseContactFromRelationship()
// 14th June 2016     Venkataramana cheedara Modified LEAP - 8795        - Modified Method : updateParentCaseStatus() , Added condition to not update the Case if the Parent Case Status = Closed.
// 27th June 2016     Anup Garg              Modified LEAP - 8665        - Modified Method : Reorder Retention case routing logic
// 11th July 2016     Varun Kavoori          Modified LEAP - 8600        - Modified Method : addRepToAccountTeamOnCaseClosure
// 29th Sept 2016     Varun Kavoori          Modified LEAP - 8976        - Modified Method : addRepToAccountTeamOnCaseClosure 
// 7th  Dec 2016      Varun Kavoori          Modified CRM - 671          - Added Method : CreateCaseCommOnFollowup
// 2nd Feb 2017       Haritha Devarakonda    Modified CRM - 945          - Added Method : InvokeCaseAssignmentRules
// 24th Feb 2017      Shraddha Kabade        Modified for New products   - Added Method : updateFulfillmentStatusOnCaseClosed
// 6th Jul 2018       Vamsi Chinnam          Modified Sep-149            - Modified Method : updateCaseAccountFromRelationship and updateCaseContactFromRelationship, 
//Added condition not to execute for email-to-case(E2C) cases on Insert
//Added Logic for to attach the E2C Case to the relationship account upon contact update
// 12th Jul 2018      Vamsi Chinnam          Modified Sep-153            - Modified Method : assignCaseToRetentionRepOnAccount
//Added condition for update scenario to assignOwnership only for EmailToCase Cases 
//When either recordType or Type is updated to Retention.
public without sharing class CaseTriggerHandlerManager {
    
    public Map<Id,Set<Id>> output = new Map<Id,Set<Id>>();
    Map<String, Case_Type_SLA_Setting__c> caseTypeSLAValueMap = new Map<String, Case_Type_SLA_Setting__c>();
    
    /*
@method      : updateAssetAtRiskFlagOnCaseUpdate
@description : Update asset at risk flag if a case is updated.
@params      : Map<Id, Case> newMap, Map<Id, Case> oldMap
@returns     : void
*/
    public void updateAssetAtRiskFlagOnCaseUpdate(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        // Processing newly updated cases.
        Set<Id> theCaseIds = new Set<Id>();
        for(Case theCase : newMap.values()) {
            // Here, a retention case is getting "Opened" or "Closed".
            if(
                String.isNotBlank(theCase.Type) &&
                theCase.Type.equalsIgnoreCase('Retention') &&
                oldMap.get(theCase.Id).Status != theCase.Status &&
                (
                    (String.isNotBlank(theCase.Status) && theCase.Status.equalsIgnoreCase('Closed')) ||(String.isNotBlank(oldMap.get(theCase.Id).Status) && oldMap.get(theCase.Id).Status.equalsIgnoreCase('Closed'))
                )
            ) {
                theCaseIds.add(theCase.Id);
            }
            // Here, a case is changed from "Non-Retention" to "Retention" and Vice-Versa.
            else if(
                String.isNotBlank(theCase.Status) &&
                !theCase.Status.equalsIgnoreCase('Closed') &&
                oldMap.get(theCase.Id).Type != theCase.Type &&
                (
                    (String.isNotBlank(theCase.Type) && theCase.Type.equalsIgnoreCase('Retention')) ||
                    (String.isNotBlank(oldMap.get(theCase.Id).Type) && oldMap.get(theCase.Id).Type.equalsIgnoreCase('Retention'))
                )
            ) {
                theCaseIds.add(theCase.Id);
            }
        }
        system.debug('TRACE: CaseTriggerHandlerManager - theCaseIds - ' + theCaseIds);
        
        // Processing case asset relationships on the basis of which we wil mark an asset at risk flag to "True" or "False".
        if(theCaseIds.size() > 0) {
            Set<Id> theAssetIds = new Set<Id>();
            for(Case_Asset_Relationship__c theRelationship : [SELECT Asset__c FROM Case_Asset_Relationship__c WHERE Case__c IN :theCaseIds
                                                              AND Asset__c != null]) {
                                                                  theAssetIds.add(theRelationship.Asset__c);
                                                              }
            system.debug('TRACE: CaseTriggerHandlerManager - theAssetIds - ' + theAssetIds);
            
            theCaseIds = new Set<Id>();
            Map<Id, Set<Id>> theAssetCaseMapping = new Map<Id, Set<Id>>();
            for(Case_Asset_Relationship__c theRelationship : [SELECT Asset__c, Case__c FROM Case_Asset_Relationship__c WHERE Asset__c IN :theAssetIds
                                                              AND Case__c != null]) {
                                                                  theCaseIds.add(theRelationship.Case__c);
                                                                  if(!theAssetCaseMapping.containsKey(theRelationship.Asset__c)) {
                                                                      theAssetCaseMapping.put(theRelationship.Asset__c, new Set<Id>());
                                                                  }
                                                                  theAssetCaseMapping.get(theRelationship.Asset__c).add(theRelationship.Case__c);
                                                              }
            system.debug('TRACE: CaseTriggerHandlerManager - theCaseIds - ' + theCaseIds);
            system.debug('TRACE: CaseTriggerHandlerManager - theAssetCaseMapping - ' + theAssetCaseMapping);
            
            // Extracting cases where Status != 'Closed' and Type = 'Retention'.
            Set<Id> theOpenRetentionCasesIds = new Set<Id>();
            if(theCaseIds.size() > 0) {
                for(Case theCase : [SELECT Id FROM Case WHERE Id IN :theCaseIds AND Status != 'Closed' AND Type = 'Retention']) {
                    theOpenRetentionCasesIds.add(theCase.Id);
                }
            }
            system.debug('TRACE: CaseTriggerHandlerManager - theOpenRetentionCasesIds - ' + theOpenRetentionCasesIds);
            
            // Determining assets at risk.
            Set<Id> theAssetsAtRisk = new Set<Id>();
            if(theOpenRetentionCasesIds.size() > 0) {
                for(Id theCaseId : theOpenRetentionCasesIds) {
                    for(Id theAssetId : theAssetCaseMapping.keySet()) {
                        if(theAssetCaseMapping.get(theAssetId) != null && theAssetCaseMapping.get(theAssetId).contains(theCaseId)) {
                            theAssetsAtRisk.add(theAssetId);
                        }
                    }
                }
            }
            system.debug('TRACE: CaseTriggerHandlerManager - theAssetsAtRisk - ' + theAssetsAtRisk);
            
            // Processing assets at risk.
            Asset theAsset = null;
            List<Asset> toBeUpdated = new List<Asset>();
            for(Id theAssetId : theAssetCaseMapping.keySet()) {
                theAsset = new Asset(Id = theAssetId);
                if(theAssetsAtRisk.contains(theAssetId)) {
                    theAsset.At_Risk__c = true;
                }
                else {
                    theAsset.At_Risk__c = false;
                }
                toBeUpdated.add(theAsset);
            }
            system.debug('TRACE: CaseTriggerHandlerManager - toBeUpdated - ' + toBeUpdated);
            
            // Updating assets.
            if(toBeUpdated.size() > 0) {
                update toBeUpdated;
            }
        }
    }
    
    
    
    
    /*
@method      : getPublicGroupsForCaseOwners
@description : Determines public group names for case owners recursively.
@params      : Set<Id> caseOwnerIds.
@returns     : Map<Id,Set<String>> ownerIdsWithPublicGroupNames.
*/
    public Map<Id,Set<String>> getPublicGroupsForCaseOwners(Set<Id> caseOwnerIds) {
        Map<Id,Set<Id>> ownerIdsWithPublicGroupIds = getPublicGroupsIdsForCaseOwnerIds(caseOwnerIds);
        
        Set<Id> groupIds = new Set<Id>();
        for(Id caseOwnerId : ownerIdsWithPublicGroupIds.keySet()) {
            groupIds.addAll(ownerIdsWithPublicGroupIds.get(caseOwnerId));
        }
        
        Map<Id,String> groupIdWithItsName = new Map<Id,String>();
        for(Group theGroup : [SELECT Id, Name FROM Group WHERE Id IN: groupIds]) {
            groupIdWithItsName.put(theGroup.Id, theGroup.Name);
        }
        
        Map<Id,Set<String>> result = new Map<Id,Set<String>>();
        for(Id caseOwnerId : ownerIdsWithPublicGroupIds.keySet()) {
            if(!result.containsKey(caseOwnerId)) {
                result.put(caseOwnerId, new Set<String>());
            }
            for(Id groupId : ownerIdsWithPublicGroupIds.get(caseOwnerId)) {
                result.get(caseOwnerId).add(groupIdWithItsName.get(groupId));
            }
        }
        return result;
    }
    
    /*
@method      : getPublicGroupsIdsForCaseOwnerIds
@description : Determines public group Ids provided case owner Ids.
@params      : Set<Id> userOrGroupIds.
@returns     : Map<Id,Set<Id>> publicGroupsIdsForCaseOwnerIds.
*/
    public Map<Id,Set<Id>> getPublicGroupsIdsForCaseOwnerIds(Set<Id> userOrGroupIds) {
        Id outputMapKey = null;
        Set<Id> nestedGroupIds = new Set<Id>();
        
        // Only query actual groups and not roles and queues.
        List<GroupMember> records = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN
                                     :userOrGroupIds AND UserOrGroupId != null AND Group.Type = 'Regular'];
        for(GroupMember record:records) {
            // Found a group, remember for traversal.
            if((record.UserOrGroupId + '').startsWith('005')) {
                if(!output.containsKey(record.UserOrGroupId)) {
                    output.put(record.UserOrGroupId, new Set<Id>());
                }
                output.get(record.UserOrGroupId).add(record.GroupId);
            }
            else {
                outputMapKey = null;
                for(Id caseOwnerId : output.keySet()) {
                    if(output.get(caseOwnerId).contains(record.UserOrGroupId)) {
                        outputMapKey = caseOwnerId;break;
                    }
                }
                if(outputMapKey != null) {
                    output.get(outputMapKey).add(record.GroupId);
                }
            }
            nestedGroupIds.add(record.GroupId);
        }
        
        // Call self to get nested groups we found.
        if(nestedGroupIds.size() > 0) {
            Map<Id,Set<Id>> returnedData = getPublicGroupsIdsForCaseOwnerIds(nestedGroupIds);
            for(Id caseOwnerId : returnedData.keySet()) {
                if(!output.containsKey(caseOwnerId)) {
                    output.put(caseOwnerId, new Set<Id>());
                }
                output.get(caseOwnerId).addAll(returnedData.get(caseOwnerId));
            }
        }
        
        return output;
    }
    
    /*
@method     : updateParentCaseStatus
@description: Parent status update
@params     : trigger.new
@returns    : void.
*/
    public static  boolean parentCaseUpdateFlag = false;
    //CRM-1371 Set of IDs to avoid updating same parent Case again and again.
    private static set<ID> updateParentCaseStatusIds = new set<ID>();
    public void updateParentCaseStatus(map<ID,case> newMap,map<ID,Case> oldmap)
    {
        //if(parentCaseUpdateFlag = true)
        //    return ;
        set<ID> parentcaseIDs = new set<ID>();
        list<case> parentCases = new list<Case>();
        ID caseGlobalRT_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Global').RecordTypeId;
        
        for(case theCase : newmap.values()){
            if(theCase.ParentId != null && oldMap.get(theCase.Id).Status != theCase.Status && theCase.Status.equalsIgnoreCase('Closed')){
                //CRM-1371 check if parent case is already updated
                if (!updateParentCaseStatusIds.contains(theCase.ParentId)) {
                    parentcaseIDs.add(theCase.ParentId);
                    updateParentCaseStatusIds.add(theCase.ParentId); //CRM-1371 if not add it to set
                }
            }
        }
        
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!parentcaseIDs.isEmpty()) {
            for(case ocase : [SELECT Id FROM Case WHERE ID IN:parentcaseIDs AND recordTypeID!=: caseGlobalRT_ID AND Status != 'Closed'])
            {
                parentCases.add(new case(ID=ocase.ID,Status='Review'));
            }
        }
        
        /*   
//temp fix service leap starts here
list<casesibelids__c> csesbltoupdate = new list<casesibelids__c>();
map<string,casesibelids__c> idsmap = new map<string,casesibelids__c>();
list<casesibelids__c> casesibelids = [select id,Name,Siebel_SR__c,Is_Updated__c from casesibelids__c where Name in :newMap.keySet()];  
for(casesibelids__c idsloop : casesibelids){
idsmap.put(idsloop.Name,idsloop);
}

for(case caseloop : newMap.values()){
if(oldMap.get(caseloop.id).SiebelMigrationID__c == null){
case tempcase = new case();
casesibelids__c tempcsesbl = new casesibelids__c();
tempcase.id = caseloop.id;
try{
tempcase.SiebelMigrationID__c = idsmap.get(caseloop.id).Siebel_SR__c;
parentCases.add(tempcase);
tempcsesbl.id = idsmap.get(caseloop.id).id;
//tempcsesbl.name = caseloop.id;
tempcsesbl.Is_Updated__c = true;
csesbltoupdate.add(tempcsesbl);
} catch(exception e){
//no action required   
}
}
}
if(csesbltoupdate.size() > 0){
upsert csesbltoupdate; 
} */
        
        //temp fix ends here
        
        if(!parentCases.isEmpty()){
            parentCaseUpdateFlag = true;
            update parentCases;
        }
        
    }
    /*
@method     : setSLAFields
@description: Sets SLA Date Time if SLA is Enforced
@params     : trigger.new
@returns    : void.
*/
    public void setSLAFields(List<Case> newValues){
        System.debug('TempCaseMap is : '+newValues);
        
        // Get the SLA Setting for the Case Types
        Map<String,Case_Type_SLA_Setting__c> caseTypeSLAValuesMap = getCaseTypeSLAValueMap();
        
        // Iterate over the Case to Find Case For which SLA Should be Updated
        System.debug('TempCaseMap is : '+newValues);
        for(Case c: newValues){
            //Check if Setting Exists for the Current Case Type
            boolean isSlaChanged = false;
            if(caseTypeSLAValuesMap.containsKey(c.Type)) {
                System.debug('Trace : got the Configuration for this type : '+c.Type);
                // Fetch the custom setting for Case Type
                Case_Type_SLA_Setting__c slaSetting = caseTypeSLAValuesMap.get(c.Type);
                // if SLA in Inforced and SLA_Date_Time is Not Null Update the SLA_DATE_Time__c
                if(slaSetting.Enforce_SLA__c && slaSetting.SLA_Date_Time__c != null){
                    System.debug('Trace: Setting the SLA Time for Case '+c.Subject);
                    isSlaChanged =  true;
                    c.SLA_Date_Time__c = DateTime.now().addHours(Integer.valueOf(slaSetting.SLA_Date_Time__c));
                }
                if(slaSetting.Enforce_Next_Touch__c && slaSetting.Next_Touch_Date_Time__c != null) {
                    System.debug('Trace: Setting the Next Touch Time for Case '+c.Subject);
                    c.Next_Touch_Date_Time__c = DateTime.now().addHours(Integer.valueOf(slaSetting.Next_Touch_Date_Time__c));
                    isSlaChanged = true;
                }
            }
        } // End Of For Loop
        
    } 
    
    /*
@method     : updateSLAFields
@description: Sets SLA Achieved For Closed Cases and Update next Touch Time if Next Touch is Enforced
@params     : trigger.new
@returns    : void.
*/
    public void updateSLAFields(Map<Id, Case> newCaseValuesMap, Map<Id, Case> oldCaseValuesMap){
        //List<Case> caseListToUpdate = new List<Case>();
        //List<Case> closedCasesListToUdpate ; 
        Map<Id,Case> nonClosedCases;
        
        // Get the SLA Setting for the Case Types
        Map<String,Case_Type_SLA_Setting__c> caseTypeSLAValuesMap = getCaseTypeSLAValueMap();
        // Get the Closed Case 
        Map<Id,Case> closedCases = filterClosedCases(newCaseValuesMap,oldCaseValuesMap);
        
        // Iterate over the Case to Find Case For whihc SLA Should be Updated
        for(Case c: newCaseValuesMap.values()) {
            //Check if Setting Exists for the Current Case Type
            if(caseTypeSLAValuesMap.containsKey(c.Type)) {
                // Fetch the custom setting for Case Type
                Case_Type_SLA_Setting__c slaSetting = caseTypeSLAValuesMap.get(c.Type);
                if(closedCases.containsKey(c.Id)){
                    if (c.SLA_Date_Time__c >= DateTime.now()) {
                        c.SLA_Achieved__c = true;
                        c.Next_Touch_Date_Time__c=null;
                    }
                }else {
                    // if SLA in Enforced and SLA_Date_Time is Not Null Update the SLA_DATE_Time__c
                    if(slaSetting.Enforce_Next_Touch__c && slaSetting.Next_Touch_Date_Time__c != null){
                        // Update Next Touch Time Only If It was not Overridden in UI
                        if(c.Next_Touch_Date_Time__c == oldCaseValuesMap.get(c.Id).Next_Touch_Date_Time__c) {
                            c.Next_Touch_Date_Time__c = DateTime.now().addHours(Integer.valueOf(slaSetting.Next_Touch_Date_Time__c));
                        }
                    }
                    if(c.Status.equalsIgnoreCase(Constants.CASE_STATUS_CLOSED)) {
                        c.Next_Touch_Date_Time__c=null;
                    }
                    // Added For Issue I-163523
                    if(c.Status != oldCaseValuesMap.get(c.Id).Status && oldCaseValuesMap.get(c.Id).Status == Constants.CASE_STATUS_CLOSED) {
                        if(c.SLA_Achieved__c) {
                            c.SLA_Achieved__c = false;
                        }
                    }
                }
                
            } // End Of If
        } // End Of For Loop
        
    } 
    /*  
//this method can be deleted after sales golive as there wont be case sync with Siebel 
public void updatesibelsr(Map<Id, Case> newMap,Map<Id, Case> oldMap) {
map<string,string> idsmap = new map<string,string>();
list<case> casestoupdate = new list<case>(); 
list<casesibelids__c> casesibelids = [select Name,Siebel_SR__c from casesibelids__c where Name in :newMap.keySet()];  
for(casesibelids__c idsloop : casesibelids){
idsmap.put(idsloop.Name,idsloop.Siebel_SR__c);   
}

for(case caseloop : newMap.values()){
if(oldMap.get(caseloop.id).SiebelMigrationID__c == null){
case tempcase = new case();
tempcase.id = caseloop.id;
tempcase.SiebelMigrationID__c = idsmap.get(caseloop.id);
casestoupdate.add(tempcase);
}
}
if(casestoupdate.size() > 0){
update casestoupdate; 
}
} */
    
    /*
@method      : validateCasesInsertionUpdation
@description : Validates user's public group while inserting/updating a case.
@params      : trigger.newMap, trigger.oldMap, trigger.isInsert
@returns     : void.
*/
    // CRM-1371 Set of Id to avoid updating same account again and again.
    private static Set<Id> validateCasesInsertionUpdationIds = new Set<Id>();
    public void validateCasesInsertionUpdation(Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isInsert) {
        // Extract case owners Ids.
        Set<Id> caseOwnerIds = new Set<Id>();
        List<Case> filteredNewValues = new List<Case>();
        // Update Acount based on case Status
        // Whenever we have an open collection case for an account, we set the Credit Status of the Account to "Not Current" . 
        //Once the Case is closed we can set it back to "Current".   
        list<Account> acclist = new list<Account>();
        set<ID> accIds = new set<ID>();
        set<ID> accIdsNew = new set<ID>();    
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;          
        
        ID CollectionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Collections').RecordTypeId;
        
        for(Case theCase : newMap.values()) {
            
            System.debug('acctid--->' + theCase.AccountId + theCase.RecordTypeId);
            if(thecase.AccountID != null && thecase.recordTypeID == CollectionRtID ){
                // CRM-1371 check if id is already added
                if (!validateCasesInsertionUpdationIds.contains(thecase.AccountID)) {
                    accIdsNew.add(thecase.AccountID);
                    validateCasesInsertionUpdationIds.add(thecase.AccountID); // CRM-1371 if not add it
                }
                if(thecase.status == 'Open' ||thecase.status == 'Closed')                          
                    accIds.add(thecase.AccountID); 
                
            }
            
            
            if(isInsert) {
                if(theCase.OwnerId != null && (theCase.OwnerId + '').startsWith('005')) {
                    caseOwnerIds.add(theCase.OwnerId);
                    filteredNewValues.add(theCase);
                }
            }
            else {
                if(theCase.OwnerId != null && (oldMap.get(theCase.Id).Type != theCase.Type || oldMap.get(theCase.Id).Origin != theCase.Origin ||oldMap.get(theCase.Id).OwnerId != theCase.OwnerId || oldMap.get(theCase.Id).Product_Category__c != theCase.Product_Category__c ||(oldMap.get(theCase.Id).Contact_Do_Not_Call__c != theCase.Contact_Do_Not_Call__c && theCase.Contact_Do_Not_Call__c == false))) {
                    filteredNewValues.add(theCase);
                    if((theCase.OwnerId + '').startsWith('005')) {
                        caseOwnerIds.add(theCase.OwnerId);
                    }
                }
            }
        }
        
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!accIdsNew.isEmpty()) {
            // set Account credit status based on case status
            //AND (Status =: 'Open' OR Status =: 'Closed' OR Status =: 'New'OR Status =: 'In Progress'OR Status =: 'Escalated')
            // CRM-6194 - Added condition Type!='Moving' to skip Moving cases.
            for(Account oacc: [SELECT ID,Credit_Status__c,Past_Due__c,(SELECT ID,status FROM Cases WHERE RecordTypeId =: CollectionRtID AND Type != 'Moving' ORDER By Status ASC) FROM Account WHERE ID IN: accIdsNew]){
                
                if(oacc.cases.size() >0){
                    list<case> closedcases = new list<case>();
                    for(case ocase : oacc.cases){
                        if(ocase.status == 'Open'||ocase.status=='Escalated'||ocase.status=='New'||ocase.status=='In Progress'){
                            //                        acclist.add(new Account(ID=oacc.ID,Credit_Status__c = 'Not Current'));
                            acclist.add(new Account(ID=oacc.ID,Past_Due__c = true));
                            break;
                        }
                        if(ocase.status == 'Closed'){
                            closedcases.add(ocase);                           
                        }
                    }
                    if(closedcases.size() == oacc.cases.size()){
                        //                    acclist.add(new Account(ID=oacc.ID,Credit_Status__c = 'Current')); 
                        acclist.add(new Account(ID=oacc.ID,Past_Due__c = false));                                                            
                    }
                }
            }
            if(acclist.size() > 0)
                update acclist;
            
        }
        
        // Set case owner Id as logged-in user when a case is updated.
        // Since the case has already been assigned to a queue.
        if(caseOwnerIds.size() == 0) {
            system.debug('TRACE: Using logged-in user as case owner.');
            caseOwnerIds = new Set<Id>{ UserInfo.getUserId() };
                }
        
        system.debug('TRACE: Case Owner Ids - ' + caseOwnerIds);
        system.debug('TRACE: Filtered New Values - ' + filteredNewValues);
        
        // Extract case owners all regular public groups including sub-groups.
        Map<Id,Set<String>> caseOwnersPublicGroups = getPublicGroupsForCaseOwners(caseOwnerIds);
        system.debug('TRACE: Case Owners Public Groups - ' + caseOwnersPublicGroups);
        
        // Processing newly inserted cases.
        String caseType = null;
        String caseStatus = null;
        String caseOrigin = null;
        Set<String> caseOwnerPublicGroupNames = new Set<String>();
        for(Case theCase : filteredNewValues) {
            if(theCase.OwnerId != null) {
                caseOwnerPublicGroupNames = caseOwnersPublicGroups.get((theCase.OwnerId + '').startsWith('005') ? theCase.OwnerId : UserInfo.getUserId());
                if(caseOwnerPublicGroupNames == null) {
                    caseOwnerPublicGroupNames = new Set<String>();
                }
            }
            system.debug('TRACE: Case Owner Public Group Names - ' + caseOwnerPublicGroupNames);
            
            caseType = String.isNotBlank(theCase.Type) ? theCase.Type : '';
            caseStatus = String.isNotBlank(theCase.Status) ? theCase.Status : '';
            caseOrigin = String.isNotBlank(theCase.Origin) ? theCase.Origin : '';
            
            /*
if((caseType.equalsIgnoreCase('Realtor Professional') ||
caseType.equalsIgnoreCase('Realtor Consumer') ||`
caseType.equalsIgnoreCase('Move General Email') ||
caseOrigin.equalsIgnoreCase('Email')
) &&
!caseStatus.equalsIgnoreCase('Closed') 
//  && !caseOwnerPublicGroupNames.contains('Email Team')         // Commeneted as per LEAP-3253

) {
theCase.addError('Case via Email can only be created/updated by a member of "Email Team".');
}
else 
*/ // commented as per 3253 story
            if(
                caseType.equalsIgnoreCase('MLS Support') && !caseStatus.equalsIgnoreCase('Closed') && !caseOwnerPublicGroupNames.contains('Resolution Team') && !caseOwnerPublicGroupNames.contains('MLS Support Team')&& profileName != 'System Administrator' ) {            
                    theCase.addError('The case of type "MLS Support" can only be created/updated by a member of "MLS Support Team" or "Resolution Team" or "System Administrator".');
                }
            /* Commented as per LEAP-4077
else if(
caseType.equalsIgnoreCase('Collections') &&
!caseStatus.equalsIgnoreCase('Closed') &&
(!caseOwnerPublicGroupNames.contains('CC Collections Team') && !caseOwnerPublicGroupNames.contains('Sales Collections Team'))
) {
theCase.addError('The case of type "Collections" can only be created/updated by a member of "CC Collections Team" or "Sales Collections Team".');
} */
            else if(
                caseType.equalsIgnoreCase('Global') && !caseStatus.equalsIgnoreCase('Closed') &&(!caseOwnerPublicGroupNames.contains('Resolution Team') && !caseOwnerPublicGroupNames.contains('MLS Support Team'))) {
                    theCase.addError('The case of type "Global" can only be created/updated by a member of "MLS Support Team" or "Resolution Team".');
                }
            // Added LEAP-5075 - Kalyan Meda
            else if(
                caseType.equalsIgnoreCase('Resolution') && caseStatus.equalsIgnoreCase('Closed') && profileName != 'System Administrator' && !caseOwnerPublicGroupNames.contains('Resolution Team') && !caseOwnerPublicGroupNames.contains('Customer Service Flex Team')                 ) {
                    theCase.addError('You are not authorized to close Resolution cases.');
                }
            
            
            /* Commented as per LEAP-4077
else if(
caseType.equalsIgnoreCase('Sales Support') &&
!caseStatus.equalsIgnoreCase('Closed') &&
!caseOwnerPublicGroupNames.contains('Sales Support Team')
) {
theCase.addError('The case of type "Sales Support" can only be created/updated by a member of "Sales Support Team".');
}*/ 
            /* COmmented as per LEAP-4077
else if(
caseType.equalsIgnoreCase('Product Setup') &&
!caseStatus.equalsIgnoreCase('Closed') &&
theCase.Contact_Do_Not_Call__c == false &&
(
(String.isNotBlank(theCase.Product_Category__c) &&
(theCase.Product_Category__c.equalsIgnoreCase('TP') || theCase.Product_Category__c.equalsIgnoreCase('RDC'))) ||
String.isBlank(theCase.Product_Category__c)
) &&
!caseOwnerPublicGroupNames.contains('Product Setup Team')
) {
theCase.addError('The case of type "Product Setup" and product category "TP" or "RDC" can only be created/updated by a member of "Product Setup Team".');
} */
            
            //Commenting the code as per Bug LEAP-3166
            /* else if(
caseType.equalsIgnoreCase('Resolution') &&
!caseStatus.equalsIgnoreCase('Closed') &&
!caseOwnerPublicGroupNames.contains('Sales Support Team')
) {
theCase.addError('The case of type "Resolution" can only be created/updated by a member of "Sales Support Team".');
}*/
            /* else if(
caseType.equalsIgnoreCase('Resolution') &&
!caseStatus.equalsIgnoreCase('Closed') &&
!caseOwnerPublicGroupNames.contains('Resolution Team')
) {
theCase.addError('The case of type "Resolution" can only be created/updated by a member of "Resolution Team".');
} */        
        } 
    } 
    
    
    /**
@method    : insertCaseResolutionTracking 
@description : This method insert into CaseHistory object after a case is created.
@params    : trigger.new
@return    : void.
*/
    public void insertCaseResolutionTracking(List<Case> newValues) {
        Set<Id> setOwnerId = new Set<Id>();
        Map<Id, User> mapUser = new Map<Id, User>();
        
        Set<Id> setQueueId = new Set<Id>();
        Map<Id, Group> mapQueue = new Map<Id, Group>();
        
        List<Case_Resolution_Tracking__c> listCaseHistory = new List<Case_Resolution_Tracking__c>();
        
        // Populating worksite and collecting sub case ids.
        for(case c : newValues) {
            String ownerId = c.OwnerId;
            if(ownerId.startsWith('005')) {
                setOwnerId.add(c.OwnerId);
            }
            else {
                setQueueId.add(c.OwnerId);
            }
        }
        
        // Fetching owners details.
        if(setOwnerId.size() > 0) {
            mapUser = new Map<Id, User>([SELECT Id, Email, Name FROM User WHERE Id IN :setOwnerId]);
        }
        if(setQueueId.size() > 0) {
            mapQueue = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id IN :setQueueId]);
        }
        
        // Creating case history.
        Case_Resolution_Tracking__c caseHistory;
        
        for(case c : newValues){
            String ownerId = c.OwnerId;
            
            caseHistory = new Case_Resolution_Tracking__c();
            caseHistory.Case__c = c.Id;
            caseHistory.Change_type__c = 'Status';
            
            if(ownerId.startsWith('005')) {
                caseHistory.Owner_Type__c = 'User';
                caseHistory.Owner_name__c = mapUser.containsKey(c.ownerId) ? mapUser.get(c.OwnerId).Name : ''; //CRM-4434 Added null check
            }
            else {
                caseHistory.Owner_Type__c = 'Queue';
                caseHistory.Owner_name__c = mapQueue.containskey(c.OwnerId) ? mapQueue.get(c.OwnerId).Name : ''; //CRM-4434 Added null check
            }
            
            caseHistory.Owner_id__c = c.OwnerId;
            caseHistory.Start_time__c = DateTime.now();
            caseHistory.New_status__c = c.Status;
            
            listCaseHistory.add(caseHistory);
        }
        
        // Inserting case history.
        if(listCaseHistory.size() > 0) {
            insert listCaseHistory;
        }
    }
    
    
    /**
@method    : upsertCaseResolutionTracking 
@description : This method inserts/updates CaseHistory object if the status/owner of a case is changed.
@params    : trigger.newMap,trigger.oldMap
@return    : void.
*/
    public void upsertCaseResolutionTracking(Map<Id, Case> newCaseValuesMap, Map<Id, Case> oldCaseValuesMap) {
        
        Set<Id> setOwnerId = new Set<Id>();
        Map<Id, User> mapUser = new Map<Id, User>();
        
        Set<Id> setQueueId = new Set<Id>();
        Map<Id, Group> mapQueue = new Map<Id, Group>();
        
        Set<Id> setCaseChangeId = new Set<Id>();
        List<Case_Resolution_Tracking__c> listCaseHistory = new List<Case_Resolution_Tracking__c>();
        
        // Get the cases which got changed.
        for(Case c : newCaseValuesMap.values()) {
            if((c.OwnerId != oldCaseValuesMap.get(c.Id).OwnerId || c.Status != oldCaseValuesMap.get(c.Id).Status ||
                c.SubStatus__c != oldCaseValuesMap.get(c.Id).SubStatus__c || c.Outcome__c != oldCaseValuesMap.get(c.Id).Outcome__c )) {
                    setCaseChangeId.add(c.Id);
                }
            
            // Add the set/queue's ids to the changed queue/users sets.
            String ownerId = c.OwnerId;
            if(ownerId.startsWith('005')) {
                setOwnerId.add(c.OwnerId);
            }
            else {
                setQueueId.add(c.OwnerId);
            }
        }
        
        // Fetching owners/queue details for the cases which were update. 
        if(setOwnerId.size() > 0) {
            mapUser = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :setOwnerId]);
        }
        if(setQueueId.size() > 0) {
            mapQueue = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id IN :setQueueId]);
        }
        
        // Updating previous case history for end time.
        Case_Resolution_Tracking__c caseHistory;
        if(setCaseChangeId.size() > 0) {
            for(Case c : [SELECT Id, RecordTypeId, Status, IsClosed, OwnerId, (SELECT Id, End_time__c FROM Case_History__r ORDER BY Createddate DESC LIMIT 1)
                          FROM Case WHERE Id IN :setCaseChangeId]) {
                              if(c.Case_History__r != null && c.Case_History__r.size() > 0) {
                                  caseHistory = new Case_Resolution_Tracking__c(Id = c.Case_History__r.get(0).Id, End_time__c = DateTime.now());
                                  listCaseHistory.add(caseHistory);
                              }
                          }
        }
        
        // Updating Case_Resolution_Tracking__c on case.
        for(Case c : newCaseValuesMap.values()) {
            String ownerId = c.OwnerId;
            if(c.OwnerId != oldCaseValuesMap.get(c.Id).OwnerId) {
                caseHistory = new Case_Resolution_Tracking__c();
                caseHistory.Case__c = c.Id;
                caseHistory.Change_type__c = 'Owner';
                
                if(ownerId.startsWith('005')) {
                    caseHistory.Owner_Type__c = 'User';
                    caseHistory.Owner_name__c = mapUser.get(c.OwnerId).Name;
                }
                else {
                    caseHistory.Owner_Type__c = 'Queue';
                    caseHistory.Owner_name__c = mapQueue.get(c.OwnerId).Name;
                }
                
                caseHistory.Owner_id__c = c.OwnerId;
                caseHistory.Start_time__c = DateTime.now();
                caseHistory.New_status__c = c.Status;
                
                listCaseHistory.add(caseHistory);
            }
            else if(c.Status != oldCaseValuesMap.get(c.Id).Status) {
                caseHistory = new Case_Resolution_Tracking__c();
                
                if(c.Status == 'Closed') {
                    caseHistory.Comment_Count__c = 1;
                }
                
                caseHistory.Case__c = c.Id;
                caseHistory.Change_type__c = 'Status';
                
                if(ownerId.startsWith('005')) {
                    caseHistory.Owner_Type__c = 'User';
                    caseHistory.Owner_name__c = mapUser.get(c.OwnerId).Name;
                }
                else {
                    caseHistory.Owner_Type__c = 'Queue';
                    caseHistory.Owner_name__c = mapQueue.get(c.OwnerId).Name;
                }
                
                caseHistory.Owner_id__c = c.OwnerId;
                caseHistory.Start_time__c = DateTime.now();
                caseHistory.New_status__c = c.Status;
                
                listCaseHistory.add(caseHistory);
            }
            else if(c.Outcome__c != oldCaseValuesMap.get(c.Id).Outcome__c) {
                caseHistory = new Case_Resolution_Tracking__c();
                
                if(c.Status == 'Closed') {
                    caseHistory.Comment_Count__c = 1;
                }
                
                caseHistory.Case__c = c.Id;
                caseHistory.Change_type__c = 'Outcome';
                
                if(ownerId.startsWith('005')) {
                    caseHistory.Owner_Type__c = 'User';
                    caseHistory.Owner_name__c = mapUser.get(c.OwnerId).Name;
                }
                else {
                    caseHistory.Owner_Type__c = 'Queue';
                    caseHistory.Owner_name__c = mapQueue.get(c.OwnerId).Name;
                }
                
                caseHistory.Owner_id__c = c.OwnerId;
                caseHistory.Start_time__c = DateTime.now();
                caseHistory.Outcome__c = c.Outcome__c;
                
                listCaseHistory.add(caseHistory);
            }
            
            if(c.SubStatus__c != oldCaseValuesMap.get(c.Id).SubStatus__c) {
                caseHistory = new Case_Resolution_Tracking__c();
                
                if(c.Status == 'Closed') {
                    caseHistory.Comment_Count__c = 1;
                }
                
                caseHistory.Case__c = c.Id;
                caseHistory.Change_type__c = 'Sub Status';
                
                if(ownerId.startsWith('005')) {
                    caseHistory.Owner_Type__c = 'User';
                    caseHistory.Owner_name__c = mapUser.get(c.OwnerId).Name;
                }
                else {
                    caseHistory.Owner_Type__c = 'Queue';
                    caseHistory.Owner_name__c = mapQueue.get(c.OwnerId).Name;
                }
                
                caseHistory.Owner_id__c = c.OwnerId;
                caseHistory.Start_time__c = DateTime.now();
                caseHistory.Sub_Status__c  = c.SubStatus__c;
                
                listCaseHistory.add(caseHistory);
            }
        }
        
        // Upserting case history list.
        if(listCaseHistory.size() > 0) {
            upsert listCaseHistory;
        }
        
    }
    
    
    
    
    /*
@method      : updateCaseDurationForClosedCases
@description : Updates Case Duration for Closed Cases.
@params      : trigger.newMap, trigger.oldMap
@returns     : void.
*/
    public void updateCaseDurationForClosedCases(Map<Id, Case> newCaseValuesMap, Map<Id, Case> oldCaseValuesMap) {
        for(Case c : newCaseValuesMap.values()) {
            if((c.Status != oldCaseValuesMap.get(c.Id).Status) && c.Status == 'Closed') {
                //c.Total_Hours_Taken_To_Close_Case__c =  (DateTime.now().getTime() - c.CreatedDate.getTime()) / 3600000;
                //Changed For Issue I-160888
                decimal duration = decimal.valueOf((DateTime.now().getTime() - c.CreatedDate.getTime()));
                decimal closeDuration = duration/(1000*60*60);
                c.Total_Hours_Taken_To_Close_Case__c = closeDuration;
            }
        }
    }
    
    /*
@method      : validateParentCaseStatusClosed
@description : A user should not be able to close the parent global case if there are still child cases that are open.
: If the child cases also have cases associated with them with open status, then the parent global case cannot be closed.
@params      : trigger.newMap, trigger.oldMap
@returns     : void.
*/
    public void validateParentCaseStatusClosed(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        system.debug('TRACE: New Values - ' + newMap.values());
        
        // Extracting Parent Case Ids To Process.
        // Filtering New Values.
        Map<Id, String> parentCaseWithCaseNumber = new Map<Id, String>();
        Map<Id, List<Case>> closedParentCaseAndItsChildCases = new Map<Id, List<Case>>();
        Set<Id> parentCaseIds = new Set<Id>();
        for(Case theCase : newMap.values()) {
            
            if(theCase.isClosed && theCase.RecordTypeId == CaseRecordTypes__c.getValues('Retention').Record_Type_Id__c){
                theCase.SavedAmount__c = theCase.Saved_Amount_Rollup__c;
            }
            if(oldMap.get(theCase.Id).Status != theCase.Status){
                theCase.StatusAsOfDate__c = DateTime.now();
            }
            // Processing Parent Case.
            if(
                oldMap.get(theCase.Id).Status != theCase.Status &&
                theCase.Status != '' &&
                theCase.Status.equalsIgnoreCase('Closed')
            ) {
                theCase.IsUpdateLastSurveyDate__c = true;
                theCase.Is_Manual_Survey_Send__c = false;
                parentCaseIds.add(theCase.Id);
                parentCaseWithCaseNumber.put(theCase.Id, theCase.CaseNumber);
            }
            
            // Processing Child Case.
            else if(
                theCase.ParentId != null &&
                oldMap.get(theCase.Id).Status != theCase.Status
            ) {
                if(!closedParentCaseAndItsChildCases.containsKey(theCase.ParentId)) {
                    closedParentCaseAndItsChildCases.put(theCase.ParentId, new List<Case>());
                }
                closedParentCaseAndItsChildCases.get(theCase.ParentId).add(theCase);
            }
        }
        system.debug('TRACE: parentCaseIds - ' + parentCaseIds);
        system.debug('TRACE: parentCaseWithCaseNumber - ' + parentCaseWithCaseNumber);
        system.debug('TRACE: closedParentCaseAndItsChildCases - ' + closedParentCaseAndItsChildCases);
        
        // Processing Parent Case Ids.
        Boolean hasError;
        Set<Id> childCasesToBeIgnored = new Set<Id>();
        Set<Id> newParentCaseIdsToProcess = new Set<Id>();
        for(Id parentCaseId : parentCaseIds) {
            if(closedParentCaseAndItsChildCases.containsKey(parentCaseId)) {
                hasError = false;
                for(Case theCase : closedParentCaseAndItsChildCases.get(parentCaseId)) {
                    if(theCase.Status != '' && !theCase.Status.equalsIgnoreCase('Closed') && Bypass_Rules_and_Triggers__c.getInstance().Disable_Case_Validation__c == false) { //Leap - 8043
                        hasError = true;
                        theCase.addError('The parent case # ' + parentCaseWithCaseNumber.get(parentCaseId) +' cannot be closed since its child case # ' + theCase.CaseNumber + ' is still open.\r\n');
                    }
                    else {
                        childCasesToBeIgnored.add(theCase.Id);
                    }
                }
                if(!hasError) {
                    newParentCaseIdsToProcess.add(parentCaseId);
                }
            }
            else {
                newParentCaseIdsToProcess.add(parentCaseId);
            }
        }
        system.debug('TRACE: newParentCaseIdsToProcess - ' + newParentCaseIdsToProcess);
        
        // Processing Existing Child Cases.
        Map<Id, List<Case>> parentCaseAndItsChildCases = new Map<Id, List<Case>>();
        
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!newParentCaseIdsToProcess.IsEmpty()) {
            for(Case theCase : [SELECT Id, ParentId, Status, CaseNumber FROM Case WHERE ParentId IN :newParentCaseIdsToProcess AND
                                Status != 'Closed' AND Id NOT IN :childCasesToBeIgnored]) {
                                    if(!parentCaseAndItsChildCases.containsKey(theCase.ParentId)) {
                                        parentCaseAndItsChildCases.put(theCase.ParentId, new List<Case>());
                                    }
                                    parentCaseAndItsChildCases.get(theCase.ParentId).add(theCase);
                                }
        }
        system.debug('TRACE: parentCaseAndItsChildCases - ' + parentCaseAndItsChildCases);
        
        // Validating Parent Cases.
        for(Id parentCaseId : newParentCaseIdsToProcess) {
            if(parentCaseAndItsChildCases.containsKey(parentCaseId) && Bypass_Rules_and_Triggers__c.getInstance().Disable_Case_Validation__c == false) {//Leap- 8043
                for(Case theChildCase : parentCaseAndItsChildCases.get(parentCaseId)) {
                    newMap.get(parentCaseId).addError('The parent case # ' + parentCaseWithCaseNumber.get(parentCaseId) +' cannot be closed since its child case # ' + theChildCase.CaseNumber + ' is still open.\r\n');
                }
            }
        }
    }
    
    /**
* @method      : filterClosedCases
* @description : This Method Creates a Map of Case_Type_SLA_Setting__c
* @return      : Map<String,Case_Type_SLA_Setting__c>
*/
    private Map<String,Case_Type_SLA_Setting__c> getCaseTypeSLAValueMap() {
        Map<String,Case_Type_SLA_Setting__c> caseTypeSLAValueMap = new Map<String,Case_Type_SLA_Setting__c>();
        if(Case_Type_SLA_Setting__c.getAll()!=null && Case_Type_SLA_Setting__c.getAll().size()>0){
            caseTypeSLAValueMap = Case_Type_SLA_Setting__c.getAll();
            System.debug('Trace: in getEmailConfigMap'+caseTypeSLAValueMap);
        }
        return caseTypeSLAValueMap;      
    }
    
    /**
* @method      : filterClosedCases
* @description : This Method Filters the Closed Cases
* @param       : trigger.newMap, trigger.OldMap
* @return      : Map<Id,Case>
*/
    private Map<Id,Case> filterClosedCases(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        Map<Id,Case> closedCasesMap = new Map<Id,Case>();
        // Get the Cases Which were closed
        for(Case c : newCaseValuesMap.values()) {
            if((c.Status != oldCaseValuesMap.get(c.Id).Status) && c.Status.equalsIgnoreCase(Constants.CASE_STATUS_CLOSED)) {
                closedCasesMap.put(c.Id,c);
            }
        }
        return closedCasesMap;
    }
    
    /**
@method    :  updateLastSurveyDetails
@description: This method updates the Last Survey Details on Case and Related Case Contact (CRM-2244)
@param     : Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap
@return    : void.
*/
    public void updateLastSurveyDetails(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        // CRM-2836, CRM-3694: Updated this method to use custom setting values to send survey when case is closed
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, List<Case>> contIdCasesIdMap = new Map<Id, List<Case>>();
        Map<String, String> recTypeIdFieldMap = new Map<String, String>();
        List<Contact> updContactList = new List<Contact>();
        Set<Contact> updContactSet = new Set<Contact>();
        Map<Id, Decimal> caseIdLimitMap = new Map<Id, Decimal>();
        Map<Id, Decimal> caseIdAgeLimitMap = new Map<Id, Decimal>();
        String notInList = 'NOT IN:';
        Map<String, SurveyOnCaseClosed__c> surveyCondMap = SurveyOnCaseClosed__c.getAll();
        List<String> condList = new List<String>();
        // Sorting the records for sequential execution when custom setting values are of same record type
        if(!surveyCondMap.isEmpty()){
            condList.addAll(surveyCondMap.keySet());
            condList.sort();
        }
        
        for(Case newCase : newCaseValuesMap.values()){
            if(newCase.Status== 'Closed' && newCase.Status != oldCaseValuesMap.get(newCase.Id).Status && newCase.Last_Survey_Send_Date__c == null){
                // This custom setting contains case record type and other field values for which survey needs to be sent
                for(String cs: condList){
                    SurveyOnCaseClosed__c rec = surveyCondMap.get(cs);
                    System.debug('condList--'+cs);
                    if(rec.Record_Type_Id__c == newCase.RecordtypeId){
                        // Field value will be like "Tier1,Tier2,Extra-Help", "NOT IN: CC-Leads" etc
                        List<String> typeList = new List<String>();
                        List<String> outcomeList = new List<String>();
                        List<String> areaList = new List<String>();
                        List<String> subAreaList = new List<String>();
                        List<String> acctType = new List<String>();
                        List<String> notTypeList = new List<String>();
                        List<String> notAreaList =  new List<String>();
                        List<String> notSubAreaList =  new List<String>();
                        List<String> notOutcomeList =  new List<String>();
                        List<String> onboardTypeList = new List<String>();
                        List<String> notOnboardTypeList = new List<String>();
                        if(rec.Type__c != null){
                            if(!rec.Type__c.startsWith(notInList)){
                                typeList = rec.Type__c.split(',');
                            } else {
                                notTypeList = rec.Type__c.substring(8).split(',');
                            }
                        }
                        if(rec.Area__c != null){
                            if(!rec.Area__c.startsWith(notInList)){
                                areaList = rec.Area__c.split(',');
                            } else {
                                notAreaList = rec.Area__c.substring(8).split(',');
                            }
                        }
                        if(rec.Outcome__c != null){
                            if(!rec.Outcome__c.startsWith(notInList)){
                                outcomeList = rec.Outcome__c.split(',');
                            } else {
                                notOutcomeList = rec.Outcome__c.substring(8).split(',');
                            }
                        }
                        if(rec.Sub_Area__c != null){
                            if(!rec.Sub_Area__c.startsWith(notInList)){
                                subAreaList = rec.Sub_Area__c.split(',');
                            } else {
                                notSubAreaList = rec.Sub_Area__c.substring(8).split(',');
                            }
                        }
                        //CRM-4397: Added new field condition
                        if(rec.Onboarding_Type__c != null){
                            if(!rec.Onboarding_Type__c.startsWith(notInList)){
                                onboardTypeList = rec.Onboarding_Type__c.split(',');
                            } else {
                                notOnboardTypeList = rec.Onboarding_Type__c.substring(8).split(',');
                            }
                        }
                        if(rec.Account_Type__c != null){
                            acctType = rec.Account_Type__c.split(',');
                        }
                        
                        //CRM-4397: Updated IF condition to add onboardTypeList conditions
                        if((acctType.isEmpty() || acctType.contains(newCase.Account_Type__c)) && 
                           (typeList.isEmpty() || typeList.contains(newCase.Type)) && (notTypeList.isEmpty() || !notTypeList.contains(newCase.Type)) && 
                           (areaList.isEmpty() || areaList.contains(newCase.Area__c)) && (notAreaList.isEmpty() || !notAreaList.contains(newCase.Area__c)) && 
                           (subAreaList.isEmpty() || subAreaList.contains(newCase.Sub_Area__c)) && (notSubAreaList.isEmpty() || !notSubAreaList.contains(newCase.Sub_Area__c)) &&
                           (outcomeList.isEmpty() || outcomeList.contains(newCase.Outcome__c)) && (notOutcomeList.isEmpty() || !notOutcomeList.contains(newCase.Outcome__c)) && 
                           (onboardTypeList.isEmpty() || onboardTypeList.contains(newCase.Onboarding_Type__c)) && (notOnboardTypeList.isEmpty() || !notOnboardTypeList.contains(newCase.Onboarding_Type__c))){
                               contactIdSet.add(newCase.ContactId);
                               System.debug('case--->>>!!!'+newCase);
                               if(contIdCasesIdMap.containsKey(newCase.ContactId)){
                                   List<Case> c = contIdCasesIdMap.get(newCase.ContactId);
                                   c.add(newCase);
                                   contIdCasesIdMap.put(newCase.ContactId,c);
                               } else {
                                   contIdCasesIdMap.put(newCase.ContactId, new List<case> {newCase}); 
                               }
                               recTypeIdFieldMap.put(newCase.RecordtypeId, rec.Field_to_update__c);
                               caseIdLimitMap.put(newCase.Id, rec.Send_survey_days_limit__c);
                               caseIdAgeLimitMap.put(newCase.Id, rec.Case_Age__c);
                           }
                    }
                }
            }
        }
        System.debug('contactIdSet--->>>!!!'+contactIdSet);
        if(!contactIdSet.isEmpty()){
            for(Contact cont : [SELECT Id,Last_Survey_Send_Date__c,Can_Send_Survey__c, Email, BAD_Email__c,PS_Service_Survey_Send_Date__c, Onboarding_Survey_Date__c  FROM Contact WHERE Id in : contactIdSet]) {
                List<Case> cl = contIdCasesIdMap.get(cont.Id);
                if(String.isBlank(cont.Email)){
                    cont.Survey_Not_Sent__c = true;
                    cont.Survey_Not_Sent_Reason__c = 'Email is Blank';
                    for(Case c: cl){
                        c.Survey_Not_Sent__c = true;
                        c.Survey_Not_Sent_Reason__c = 'Email is Blank';
                    }
                    updContactSet.add(cont);
                } else if(cont.BAD_Email__c == 'BAD Email'){
                    cont.Survey_Not_Sent__c = true;
                    cont.Survey_Not_Sent_Reason__c = 'Contact has BAD Email';
                    for(Case c: cl){
                        c.Survey_Not_Sent__c = true;
                        c.Survey_Not_Sent_Reason__c = 'Contact has BAD Email';
                    }
                    updContactSet.add(cont);
                } else {
                    
                    for(Case c: cl){
                        // Prevent Contacts from being sent a survey more than once in any 7 day period 
                        Decimal numOfdaysLimit = caseIdLimitMap.get(c.Id);
                        Decimal caseAgeLimit = caseIdAgeLimitMap.get(c.Id);
                        Date sentSurveyDate = (Date) cont.get(recTypeIdFieldMap.get(c.RecordtypeId));
                        System.debug('mape---'+recTypeIdFieldMap+numOfdaysLimit);
                        
                        if(caseAgeLimit != null && c.CreatedDate.Date().daysBetween(system.date.today()) > caseAgeLimit){
                            cont.Can_Send_Survey__c = false;
                            cont.Survey_Not_Sent__c = c.Survey_Not_Sent__c = true;
                            cont.Survey_Not_Sent_Reason__c = c.Survey_Not_Sent_Reason__c ='Case is older than '+caseAgeLimit.intValue()+' Days'; 
                        } else if (sentSurveyDate == null || numOfdaysLimit == null || (sentSurveyDate != null && sentSurveyDate.daysBetween(system.date.today()) > numOfdaysLimit)) {
                            // Updating Can_Send_Survey__c=true on case will send the survey to contact email via WF rule.
                            cont.put(recTypeIdFieldMap.get(c.RecordtypeId), system.today());
                            cont.Can_Send_Survey__c = c.Can_Send_Survey__c  = true;   
                            c.Last_Survey_Send_Date__c = system.today();   
                        } else {
                            cont.Can_Send_Survey__c = false;
                            cont.Survey_Not_Sent__c = c.Survey_Not_Sent__c = true;
                            cont.Survey_Not_Sent_Reason__c = c.Survey_Not_Sent_Reason__c ='Contact has had survey in last 7 Days';  
                        }
                    }
                    updContactSet.add(cont); 
                }  
            }
        }
        system.debug('Contact set---->>>'+updContactSet);
        if(!updContactSet.isEmpty()){
            updContactList.addAll(updContactSet);
            update updContactList;
        }
    }
    
    /**
@method    :  updateCaseAccountFromRelationship
@description: This method updates Account on case based on the selected contact relationship on case.
@param     : Boolean isUpdate, Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap
@return    : void.
*/
    public void updateCaseAccountFromRelationship(Boolean isUpdate, List<Case> newCaseValues, Map<Id,Case> oldCaseValuesMap) {
        System.debug('Running this code');
        List<Id> contactRelationshipIds = new List<Id>();
        List<Case> casesToBeUpdate = new List<Case>(); 
        Set<Id> setAccountIds = new Set<Id>();
        // Iterate Over the Updated Cases and Get the Contact Id for Which Last Survey Date should be updated
        for(Case newCase : newCaseValues) {
            string caseOrigin = newCase.Origin;
            
            // If case updates and relationship change
            if(isUpdate){                    
                if(newCase.Relationship__c != oldCaseValuesMap.get(newCase.Id).Relationship__c) {
                    if(newCase.Relationship__c == null){
                        newCase.AccountId = null;
                    }
                    else{
                        contactRelationshipIds.add(newCase.Relationship__c);
                        casesToBeUpdate.add(newCase);   
                    }           
                }                    
            }
            else{ // If new case inserted
                //Case Orgin check so that it won't trigger for E2C cases
                if(CaseOrigin==null || !CaseOrigin.containsIgnoreCase('Email-')){    
                    if(newCase.Relationship__c != null){
                        contactRelationshipIds.add(newCase.Relationship__c); 
                        casesToBeUpdate.add(newCase);
                    }
                }
            }
            setAccountIds.add(newCase.AccountId);
        }
        
        if(!contactRelationshipIds.isEmpty()){
            // Retrive parent account from relationship
            Map<Id, Account_Relationship__c> mapRelationship = new Map<Id,Account_Relationship__c>([SELECT Parent_Account__c,Parent_Account__r.Home_Phone__c,Parent_Account__r.Mobile1__c,Parent_Account__r.Mobile2_Other__c,Parent_Account__r.Work_Phone__c,Parent_Account__r.Phone, Id, Contact_To__c, Active__c 
                                                                                                    FROM Account_Relationship__c 
                                                                                                    WHERE Id IN: contactRelationshipIds AND RecordType.DeveloperName = 'Contact_Relationship' ]);
            for(Case newCase : casesToBeUpdate){
                if(newCase.Relationship__c !=null && mapRelationship.containsKey(newCase.Relationship__c)){
                    // Assign account to case from relationship 
                    newCase.AccountId = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
                    //newCase.ContactMobile = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
                    newCase.Account_Phone__c = mapRelationship.get(newCase.Relationship__c).Parent_Account__r.Phone;
                    //Commented as part of ACP implementation.
                    //newCase.Work_Phone__c = mapRelationship.get(newCase.Relationship__c).Parent_Account__r.Work_Phone__c;
                    //newCase.Mobile__c = mapRelationship.get(newCase.Relationship__c).Parent_Account__r.Mobile1__c;
                    //newCase.Home_Phone__c = mapRelationship.get(newCase.Relationship__c).Parent_Account__r.Home_Phone__c;
                    //newCase.Other_Phone__c = mapRelationship.get(newCase.Relationship__c).Parent_Account__r.Mobile2_Other__c;
                    
                }
                setAccountIds.add(newCase.AccountId);
            }
        }
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Home_Phone__c,Mobile1__c,Mobile2_Other__c,Work_Phone__c,Phone, Id FROM Account WHERE Id IN: setAccountIds]);
        for(Case newCase : casesToBeUpdate){
            // Assign account to case from relationship 
            //newCase.AccountId = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
            //newCase.ContactMobile = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
            if(mapAccount.containskey(newCase.AccountId)){
                newCase.Account_Phone__c = mapAccount.get(newCase.AccountId).Phone;
                //Commented as part of ACP implementation.
                //newCase.Work_Phone__c = mapAccount.get(newCase.AccountId).Work_Phone__c;
                //newCase.Mobile__c = mapAccount.get(newCase.AccountId).Mobile1__c;
                //newCase.Home_Phone__c = mapAccount.get(newCase.AccountId).Home_Phone__c;
                //newCase.Other_Phone__c = mapAccount.get(newCase.AccountId).Mobile2_Other__c;
            }
        }
        
        
    } 
    
    /**
@method    :  updateCaseContactFromRelationship
@description: This method updates Contact on case based on the Relationship record if it exists in Relationships Object
@param     : Boolean isUpdate, Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap
@return    : void.
*/
    public void updateCaseContactFromRelationship(Boolean isUpdate, List<Case> newCaseValues, Map<Id,Case> oldCaseValuesMap) {
        
        system.debug('newCaseValues:'+newCaseValues);
        system.debug('oldCaseValuesMap:'+oldCaseValuesMap);
        List<Id> accountRelationshipIds = new List<Id>();
        Set<Id> contactRelationshipIds = new Set<Id>();
        List<Case> casesToBeUpdate = new List<Case>(); 
        
        // Iterate Over the Updated Cases and Get the Contact Id for Which Last Survey Date should be updated
        for(Case newCase : newCaseValues) {
            string caseOrigin = newCase.Origin;
            
            // If case updates and relationship change
            if(isUpdate){
                if(CaseOrigin!=null){
                    //Case Orgin check so that it will trigger only for E2C cases
                    if(CaseOrigin.containsIgnoreCase('Email-')){
                        //Only if contact is updated
                        if(newCase.ContactId != oldCaseValuesMap.get(newCase.Id).ContactId){
                            casesToBeUpdate.add(newCase);
                            if(newCase.contactId!=null)
                                contactRelationshipIds.add(newCase.contactId);
                        }                                      
                    }
                }
                if(newCase.AccountId != oldCaseValuesMap.get(newCase.Id).AccountId) {
                    /*     if(newCase.AccountId == null){
newCase.ContactId = null;
}
else{
accountRelationshipIds.add(newCase.AccountId);
casesToBeUpdate.add(newCase);   
}           */
                }                
            }
            else{ // If new case inserted
                //Case Orgin check so that it won't trigger for E2C cases
                if(CaseOrigin==null || !CaseOrigin.containsIgnoreCase('Email-')){
                    if(newCase.AccountId != null){
                        accountRelationshipIds.add(newCase.AccountId); 
                        casesToBeUpdate.add(newCase);
                    }
                }
            }
        }
        system.debug('@@ contactRelationshipIds'+contactRelationshipIds);
        system.debug('@@ contactRelationshipIds size'+contactRelationshipIds.size());
        if(contactRelationshipIds.size()>0){
            // Retrive Active Primary Contact from relationship for the Account On case
            Map<Id, Account_Relationship__c> mapRelationship = new Map<Id,Account_Relationship__c>([SELECT Parent_Account__c, Id, Contact_To__c 
                                                                                                    FROM Account_Relationship__c 
                                                                                                    WHERE Contact_To__c IN: contactRelationshipIds 
                                                                                                    AND Contact_Role__c='Primary Contact']);                                                                                                   
            // Iterate and prepare Account Primary Contact Map
            Map<Id,Id> accountContactmap = new Map<Id,Id>();
            for(Account_Relationship__c relationship : mapRelationship.values()){
                accountContactmap.put(relationship.Contact_To__c,relationship.Parent_Account__c);
            }    
            system.debug('@@ accountContactmap'+accountContactmap);
            for(Case newCase : casesToBeUpdate){
                if(newCase.ContactId !=null && accountContactmap.containsKey(newCase.ContactId)){
                    // Assign Contact to case from relationship 
                    system.debug('@@ assigning AccountfromRelationship');
                    newCase.AccountId = accountContactmap.get(newCase.ContactId);
                }
            }
            
        }
        system.debug('TRACE : Account relationship : '+ accountRelationshipIds);
        
        if(!accountRelationshipIds.isEmpty()){
            // Retrive Active Primary Contact from relationship for the Account On case
            Map<Id, Account_Relationship__c> mapRelationship = new Map<Id,Account_Relationship__c>([SELECT Parent_Account__c, Id, Contact_To__c 
                                                                                                    FROM Account_Relationship__c 
                                                                                                    WHERE Parent_Account__c IN: accountRelationshipIds 
                                                                                                    AND Contact_Role__c='Primary Contact'
                                                                                                    //AND Relationship_Type__c = 'Contact' subbu commented 
                                                                                                    AND Active__c = TRUE 
                                                                                                    AND RecordType.DeveloperName = 'Contact_Relationship' ]);
            // Iterate and prepare Account Primary Contact Map
            Map<Id,Id> accountContactmap = new Map<Id,Id>();
            for(Account_Relationship__c relationship : mapRelationship.values()){
                accountContactmap.put(relationship.Parent_Account__c,relationship.Contact_To__c);
            }
            
            for(Case newCase : casesToBeUpdate){
                if(newCase.AccountId !=null && accountContactmap.containsKey(newCase.AccountId)){
                    // Assign Contact to case from relationship 
                    newCase.ContactId = accountContactmap.get(newCase.AccountId);
                }
            }
        }
    }
    
    
    
    
    /**
@method     :  assignCaseToRetentionOrCollectionRepOnAccount
@description: Assigns the case to retention rep on the Account Team if assigned. If not assigned, the case is assigned to the Retention Queue
@param      : List<Case> newCaseValues
@return     : void.
*/
    
    public void assignCaseToRetentionRepOnAccount(List<Case> newCaseValues,Map<id,Case> oldCaseMap){
        
        set<Id> sAccId = new set<Id>();
        Map< Id, Id > accountTeammemberMap = new Map < Id,Id >();
        Set< Id > repIds = new Set <  Id >();
        Set <Case> retentionCases = new Set <Case>();
        // Get new retention cases
        for (Case newCase : newCaseValues){
            if(newCase.RecordTypeId == CaseRecordTypes__c.getValues('Retention').Record_Type_Id__c){
                sAccId.add(newCase.Accountid);
                retentionCases.add(newCase);
            }
        } 
        
        system.debug('TRACE Account Ids : ' + sAccId );
        List< AccountTeamMember> retentionRepsOnTheAccount = new List< AccountTeamMember>();
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!sAccId.isEmpty()) {
            // Query Retention Reps assigned on the Account
            retentionRepsOnTheAccount = [SELECT TeamMemberRole, User.Vacation_Start_Date__c, User.Vacation_End_Date__c,AccountId FROM 
                                         AccountTeamMember WHERE TeamMemberRole = 'Retention Rep' AND AccountId IN: sAccId];
        }
        
        //CRM-1371 - Commenting below SOQL, var retentionQueueId is not used anywhere.
        // Query Queue ID
        //Id retentionQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'Retention Cases - Open'].id;
        
        
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type = 'Queue' and (Name Like '%Retention%' or Name Like '%R & C%') ];
        
        //  List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type = 'Queue' and Name Like '%R & C%'];
        Map<String,ID> queueAndIdMap = new Map<String,ID>();
        for (Group grp : queueList){
            if(grp.name.contains('Tiger')){
                queueAndIdMap.put('TigerLeadRetention',grp.id);
            }
            else if (grp.name.contains('R & C')) {
                queueAndIdMap.put('rcmanager',grp.id);
            }          
            
            else{
                queueAndIdMap.put('Retention',grp.id);
            }
        }
        
        
        
        // Map Accounts and Reps
        for (AccountTeamMember rep : retentionRepsOnTheAccount){
            // Add the account and Rep to the map only if the rep is not on vacation
            if(!isRepOnVacation(rep.User.Vacation_Start_Date__c, rep.User.Vacation_End_Date__c)){
                if(accountTeammemberMap.containsKey(rep.AccountId) == false){
                    accountTeammemberMap.Put(rep.AccountId, rep.UserId);
                }
            }
        }
        
        ///  Assign the case to owner if there is a Rep on the account . Else Assign it to Queue
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        Map<id,Account> accountPastDueMap = new Map<id,Account>();
        if (!sAccId.isEmpty()) {
            accountPastDueMap=new Map<id,Account>([SELECT id,Past_due__c FROM Account WHERE id IN :sAccId]);
        }
        Id retentionRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        for (Case newCase : retentionCases){
            
            // if(newCase.RecordTypeId == CaseRecordTypes__c.getValues('Retention').Record_Type_Id__c){
            //boolean pastdue=[select Past_Due__c  from account where id IN: sAccId LIMIT 1].Past_Due__c ;//}
            
            /*    if(accountTeammemberMap.containsKey(newCase.AccountId)){
newCase.ownerid = accountTeammemberMap.get(newCase.Accountid);
}else{
// Route Tiger Lead cases to tiger lead retentions queue. Else
if(newCase.Is_Tiger_Lead__c){
newCase.ownerid = queueAndIdMap.get('TigerLeadRetention') ;
}
else if(accountPastDueMap.containskey(newCase.AccountId) && accountPastDueMap.get(newCase.AccountId).Past_Due__c){
newCase.ownerid = queueAndIdMap.get('rcmanager');
}               

else{
newCase.ownerid = queueAndIdMap.get('Retention');
}                            
} */
            
            /* Reorder the Case Routing logic as per Leap - 8665.  */      
            // Route Tiger Lead cases to tiger lead retentions queue. Else
            /*string CaseOrigin = newCase.Origin;                
if(newCase.Is_Tiger_Lead__c && Trigger.isInsert){
newCase.ownerid = queueAndIdMap.get('TigerLeadRetention') ;
}
//Added condition for update scenario to assignOwnership only for EmailToCase Cases 
//When either recordType or Type is updated to Retention.
else if(accountPastDueMap.containskey(newCase.AccountId) && accountPastDueMap.get(newCase.AccountId).Past_Due__c && (Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && CaseOrigin!=null && CaseOrigin.containsIgnoreCase('Email-') && Trigger.isUpdate))){
newCase.ownerid = queueAndIdMap.get('Retention');
}               
else if(accountTeammemberMap.containsKey(newCase.AccountId) && (Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && CaseOrigin!=null && CaseOrigin.containsIgnoreCase('Email-') && Trigger.isUpdate))){
newCase.ownerid = accountTeammemberMap.get(newCase.Accountid);
} 
else if(Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && CaseOrigin!=null && CaseOrigin.containsIgnoreCase('Email-') && Trigger.isUpdate)){
newCase.ownerid = queueAndIdMap.get('Retention');
} */                           
            /*CRM-5346 - Modified the below logic to remove the condition of checking the origin = Email-*/
            if(newCase.Is_Tiger_Lead__c && Trigger.isInsert){
                newCase.ownerid = queueAndIdMap.get('TigerLeadRetention') ;
            }
            //Added condition for update scenario to assignOwnership only for EmailToCase Cases 
            //When either recordType or Type is updated to Retention.
            else if(accountPastDueMap.containskey(newCase.AccountId) && accountPastDueMap.get(newCase.AccountId).Past_Due__c && (Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && Trigger.isUpdate))){
                newCase.ownerid = queueAndIdMap.get('Retention');
            }               
            else if(accountTeammemberMap.containsKey(newCase.AccountId) && (Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && Trigger.isUpdate))){
                newCase.ownerid = accountTeammemberMap.get(newCase.Accountid);
            } 
            else if(Trigger.isInsert || (newCase.Type=='Retention' && (newCase.Type!= oldCaseMap.get(newCase.Id).Type || oldCaseMap.get(newCase.Id).RecordTypeId !=retentionRecTypeId) && Trigger.isUpdate)){
                newCase.ownerid = queueAndIdMap.get('Retention');
            }
            
        }
    }
    
    
    /**
@method     : addRepToAccountTeamOnCaseClosure
@description: Adds the user who closes the case to the account team i f there is 
@param      : Map<Id, Case> newMap, Map<Id, Case> oldMap
@return     : void
*/  
    
    // This method will not work for data loads because the user who is doing the data load will be added to the Account Team 
    // if there is none on the account.Set_Retention_Rep_to_Account_Team_off__c flag on the CUSTOM SETTING Switch_CaseTrigger__c has to be disabled 
    // and a seperate load has to be done on the Account Team object.
    public void addRepToAccountTeamOnCaseClosure(Map<Id, Case> newCaseValuesMap, Map<Id, Case> oldCaseValuesMap){
        
        Set < Id > closedCasesAccountSet = new Set < Id > ();
        Map < Id, Id > closedCasesAccountMap = new Map < Id, Id > (); //  AccountId,CaseId
        
        
        
        
        List < AccountTeamMember > retentionRep = new List < AccountTeamMember > ();
        
        
        
        
        // Get Account id's of the closed cases
        for (Case c: newCaseValuesMap.values()) {
            System.debug(((c.Status +'!='+ oldCasevaluesMap.get(c.Id).Status +'&&'+ c.Status +'=='+ 'Closed' +'&&'+ c.type +'=='+ 'Retention' +'&&'+ c.Owner.Profile.Name +'=='+ 'Move Retentions & Collections')));
            if (c.Status != oldCasevaluesMap.get(c.Id).Status && c.Status == 'Closed') {
                if (c.type == 'Retention' || c.type == 'Collections'){
                    closedCasesAccountSet.add(c.Id);
                }
                
                System.debug('closedCasesAccountSet*');
                // closedCasesAccountOwnerMap.put(c.AccountId,c.OwnerId);
            }
        }
        System.debug(closedCasesAccountSet + 'closedCasesAccountSet*');
        List<AsyncRecordProcessExecution__c> lstAsyncRecord = new List<AsyncRecordProcessExecution__c>();
        if(closedCasesAccountSet.size()>0){
            String caseIds = '';
            for(String s:closedCasesAccountSet) {
                caseIds += (caseIds==''?'':',')+s;
            } 
            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
            arpe.Name = 'Case Trigger';
            arpe.Interface_Name__c = 'CaseTrigger';
            arpe.ClassName__c = 'CaseTriggerHandlerManager';
            arpe.MethodName__c = 'AsyncaddRepToAccountTeamOnCaseClosure';
            arpe.Boolean_Param__c = true;
            arpe.Records_To_Process_Ids__c = caseIds+'';
            lstAsyncRecord.add(arpe);
        }
        if(lstAsyncRecord.size()>0){
            Insert lstAsyncRecord;
        }
        
    }
    
    Public void AsyncaddRepToAccountTeamOnCaseClosure(Set<Id> closedCasesIdSet){
        
        Set<String> setRepsType = new Set<String>();
        setRepsType.add(Constants.ACCOUNT_TEAM_RETENTION_REP_ROLE);
        setRepsType.add(Constants.ACCOUNT_TEAM_COLLECTIONS_REP_ROLE);
        AccountTeamMember atm = new AccountTeamMember();
        //Set<Id> closedCasesAccountSet = new Set<Id>();
        Map < Id, Id > closedCasesAccountOwnerMap = new Map < Id, Id > ();
        
        Map < Id, Id > existingCollectionRepMap = new Map < Id, Id > ();
        Map < Id, Id > existingRetentionRepMap  = new Map < Id, Id > ();
        List < AccountTeamMember > atmList = new List < AccountTeamMember > ();
        for(Case cse:[Select id,AccountId,OwnerId,Type,Owner.Profile.Name from case where Id=:closedCasesIdSet]){
            if(cse.Type=='Collections' && (cse.Owner.Profile.Name == 'Credit & Collections Admin' || cse.Owner.Profile.Name == 'Move Retentions & Collections')){
                existingCollectionRepMap.put(cse.AccountId,cse.ownerId);
            }
            if(cse.Type=='Retention' && cse.Owner.Profile.Name == 'Move Retentions & Collections'){
                existingRetentionRepMap.put(cse.AccountId,cse.ownerId);
            }
            closedCasesAccountOwnerMap.put(cse.AccountId,cse.ownerId);
        }
        // Get the reps on the accounts
        List < AccountTeamMember > retentionRepsOnTheAccount = [SELECT UserId, AccountId,TeamMemberRole FROM AccountTeamMember 
                                                                WHERE TeamMemberRole =: setRepsType AND AccountId IN: closedCasesAccountOwnerMap.keyset()];
        
        system.debug('TRACE  in addRepToAccountTeamOnCaseClosure RETENTION REPS on the account : ' + retentionRepsOnTheAccount);
        
        // Remove the Account ids from closedCasesAccountSet which have retention reps associated to them.
        for (AccountTeamMember teamMember: retentionRepsOnTheAccount) {
            if (teamMember.AccountId != null) {
                if(teamMember.TeamMemberRole==Constants.ACCOUNT_TEAM_COLLECTIONS_REP_ROLE){
                    existingCollectionRepMap.remove(teamMember.AccountId);
                }
                if(teamMember.TeamMemberRole==Constants.ACCOUNT_TEAM_RETENTION_REP_ROLE){
                    existingRetentionRepMap.remove(teamMember.AccountId);
                }
            }
        }
        
        // Iterate over the accounts which does not have a rep associated and associate the current user as a rep on the account.    
        for (Id acct: existingCollectionRepMap.keyset()) {
            atm.AccountId = acct;
            atm.TeamMemberRole = Constants.ACCOUNT_TEAM_COLLECTIONS_REP_ROLE;//CollectionRepRole;
            System.debug(existingCollectionRepMap+'TESTTTTT'+acct);
            if(existingCollectionRepMap.containskey(acct)){
                if((existingCollectionRepMap.get(acct)+'').contains('005')){
                    System.debug(existingCollectionRepMap+'TESTTTTT'+acct);
                    atm.UserId = existingCollectionRepMap.get(acct);
                }
            } 
            atmList.add(atm);
        }
        for (Id acct: existingRetentionRepMap.keyset()) {
            atm.AccountId = acct;
            atm.TeamMemberRole = Constants.ACCOUNT_TEAM_RETENTION_REP_ROLE;//retentionRepRole;
            System.debug(closedCasesAccountOwnerMap+'TESTTTTT'+acct);
            if(existingRetentionRepMap.containskey(acct)){
                if((existingRetentionRepMap.get(acct)+'').contains('005')){
                    System.debug(existingRetentionRepMap+'TESTTTTT'+acct);
                    atm.UserId = existingRetentionRepMap.get(acct);
                }
            } 
            atmList.add(atm);
        }
        
        system.debug('### ATM List: ' + atmList);
        
        // Try to insert the team members on the account and catch exceptions
        try{
            insert atmList;
        }
        catch( DmlException e){
            system.debug('EXCEPTION OCCURED In addRepToAccountTeamOnCaseClosure  : ' + e.getMessage());
        }
        
    }
    
    
    
    /**
@method     :  isRepOnVacation
@description: Returns true if the rep is on vacation . Returns true if the start and end date on the rep's User record are blank.
@param      : Date startDate , Date endDate
@return     : Boolean
*/
    
    // Check if the rep is on vacation or not
    public boolean isRepOnVacation(Date startDate , Date endDate){
        
        if (startDate == null || endDate == null)
            return false;
        
        if(system.today()<startDate && system.today()<endDate)
            return false;
        
        if(system.today()>startDate && system.today()<endDate)
            return true;
        
        if (system.today()>endDate && system.today()>startDate)
            return false;
        
        else return false;
        
        
    }
    
    
    
    /**
@method     :  updateCaseRelationshipStatus
@description: 
@param      : List<Case> newCaseValues
@return     : void.
*/
    
    public void updateCaseRelationshipStatus(map<ID,Case> newmap,map<ID,Case> oldmap)
    {
        map<ID,list<Case_Asset_Relationship__c>> caseAssetMap =new map<ID,list<Case_Asset_Relationship__c>>();
        for(Case oCase : newmap.values()){
            if(oCase.isClosed != oldmap.get(oCase.ID).isClosed){
                if(!caseAssetMap.containsKey(ocase.ID))
                    caseAssetMap.put(ocase.Id,new list<Case_Asset_Relationship__c>());
            }            
        }
        
        // CRM-1371 - Adding SOQL under if to avoid unnecessary execution of SOQL
        if (!caseAssetMap.isEmpty()) {
            for(Case_Asset_Relationship__c oCAR : [SELECT ID,Case__c,Asset_Price__c,Asset__r.PRice,Asset__r.List_Price__C,Status__C FROM Case_Asset_Relationship__c WHERE Asset_Price__c != null and  Case__c  != null and Case__c IN: caseAssetMap.keyset() ]){
                if(oCAR.Case__c  != null) {
                    if(oCAR.Asset_Price__c == oCAR.Asset__r.List_Price__C)
                        caseAssetMap.get(oCar.case__c).add(new Case_Asset_Relationship__c (ID=oCAR.ID,Status__c = 'Saved'));
                }
            }
        }
        
    }
    
    public void updateTLactivitiesOwner(map<ID,Case> newmap,map<ID,Case> oldmap)
    {
        Map<Id,id> MapCaseOwnerIds = new Map<Id,id>();
        for(Case cse:newmap.values()){
            if(((cse.ownerId+'').contains('005') && !(oldmap.get(cse.Id).ownerId+'').contains('005')) || ((cse.ownerId+'').contains('005') && (cse.ownerId!=oldmap.get(cse.Id).ownerId))){
                MapCaseOwnerIds.put(cse.id,cse.OwnerId);
            }
        }
        if(MapCaseOwnerIds.keyset().size()>0){
            Set<String> setSubjects = new Set<String>{'Ad Verification Case','Manual Activities'}; 
                List<Task> lstTask = [Select Id,ownerId,whatId from Task where whatId=:MapCaseOwnerIds.keyset() and Status!='Completed' and (Is_Tiger_Lead__c=true OR Subject=:setSubjects)];
            for(Task tsk:lstTask){
                tsk.ownerId = MapCaseOwnerIds.get(tsk.WhatId);
            }
            if(lstTask.size()>0){
                update lstTask;
            }
        }
    }
    
    
    /**
@method    :  CreateCaseCommOnFollowup
@description: This method Creates Case Comments when Followup Status is Updated
@param     : Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap
@return    : void.
*/
    public void CreateCaseCommOnFollowup(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        List<CaseComment> childCom = new List<CaseComment>();
        
        String userName = UserInfo.getUserName();
        Id rectypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        Id rectypecollectionid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collections').getRecordTypeId();
        List<String> ValidProfiles = new List<String>(Label.CaseLastWorkedProfiles.split(','));
        /*Map<Id,String> mapProfileNames = new Map<Id,String>();
for(Profile prf:[Select Id,Name from Profile where id=:userinfo.getProfileId()]){
mapProfileNames.put(prf.Id,prf.Name);
}*/
        for(Case newCase : newCaseValuesMap.values()) {
            System.debug('Trace: In CreateCaseCommOnFollowup: New Value :'+newCase.Followup_Status__c);
            System.debug('Trace: In CreateCaseCommOnFollowup: Old Value :'+oldCaseValuesMap.get(newCase.Id).Followup_Status__c);
            
            if (newCase.recordtypeid == rectypeid && newCase.Type != 'Retention') {
                if(newCase.Followup_Status__c != oldCaseValuesMap.get(newCase.Id).Followup_Status__c) {
                    newCase.Last_Worked__c = datetime.now();
                    
                    CaseComment newCom = new CaseComment();
                    newCom.CommentBody = newCase.Followup_Status__c;
                    if(newCase.Comments__c != null) {
                        newCom.CommentBody = newCom.CommentBody + ' ' + newCase.Comments__c;
                    }
                    newCom.IsPublished = TRUE;
                    newCom.ParentId = newCase.id;
                    if(newcom.get('Id') == null) 
                        childCom.add(newcom);
                    else 
                        childCom.add(newcom);
                    System.debug('Trace: In CreateCaseCommOnFollowup: NewCom :'+Newcom);              
                    
                }
            }
                System.debug('Valid Profile Ids from label'+ ValidProfiles);
                System.debug('User Profile Ids Coming Here is'+ userinfo.getProfileId());
                /*if (ValidProfiles.contains(userinfo.getProfileId())){
                    If((newCase.recordtypeid == rectypeid || newCase.recordtypeid == rectypecollectionid)){
                        newCase.Last_non_Finance_worked_Date__c = datetime.now();//newCase.Last_Worked__c;datetime.now();
                    }
                }*/
            }
            
            /*  if (newCase.recordtypeid == rectypeid || newCase.recordtypeid== rectypecollectionid){
//  System.debug();
if(newCase.Followup_Status__c != oldCaseValuesMap.get(newCase.Id).Followup_Status__c) {
String profileName='';oldCaseValuesMap.get(newCase.Id).Followup_Status__c//newCase.Followup_Status__c != oldCaseValuesMap.get(newCase.Id).Followup_Status__c && 
System.debug(mapProfileNames+'KK'+userinfo.getProfileId());
if(mapProfileNames.containskey(userinfo.getProfileId())){profileName = mapProfileNames.get(userinfo.getProfileId());}
System.debug(Label.CaseLastWorkedProfiles+'LLLLLLLL'+profileName);
System.debug(Label.CaseLastWorkedProfiles.contains(profileName)+'KK');
System.debug('Valid Profile Ids from label'+ ValidProfiles);
if(ValidProfiles.contains(userinfo.getProfileId())){
newCase.Last_non_Finance_worked_Date__c = datetime.now();  //newCase.Last_Worked__c
}
}
}*/
        if(childCom.size() > 0  && !userName.contains('nvmapiuser@move.com')){
            SkipCaseCommentTrigger.setSkipTrgTrue();              
            SkipCaseTrigger.setSkipTrgTrue();
            if(checkRecursive.runOnce()){ 
                insert childCom;
            }
        }
        
        
        
        
    }     
    /**
@method    :  invokeCaseAssignmentRules
@description: CRM-945: This method invokes case assignment rules when Followup Status is Updated
@param     : Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap
@return    : void.
*/
    // CRM-1371 Set of ID to avoid same case again and again
    private Static Set<Id> invokeCaseAssignmentRulesIds = new Set<Id>();
    public void invokeCaseAssignmentRules(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        system.debug('>>>>>> Inside Case Assignment Rules >>>>>>>');
        List<Case> updCaseList = new List<Case>();
        for(Case newCase:newCaseValuesMap.values()){
            Case oldCase = oldCaseValuesMap.get(newCase.Id);
            if((oldCase.Status != newCase.Status || oldCase.Ownership_Type__c != newCase.Ownership_Type__c) 
               && (newCase.Status == 'Review' && newCase.Ownership_Type__c == 'Queue')){
                   system.debug('>>>>>> Inside Case Assignment Rules Conditions >>>>>>>');
                   // CRM-1371 check if this case is already updated.
                   if (!invokeCaseAssignmentRulesIds.contains(newCase.Id)) {
                       updCaseList.add(new Case(Id=newCase.Id));
                       invokeCaseAssignmentRulesIds.add(newCase.Id); // CRM-1371 if not add it to set
                   }
               }
        }
        if(!updCaseList.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(updCaseList, dmo);            
        }
    }
    
    /** 
* Assets should be created only when case is closed for manual fulfillment.
* Update Fulfillment status on Order to "Pending Fulfillment" when case is closed.
* CRM-1703: For Reesio, once the case is closed, update the Order Fulfillment Status to 'Fulfilled' if all OrderItems are fulfilled.
* Added new manual fulfillment products DOMAINNAME,LISTHUBPRO as part of CRM_2341,CRM_2329
**/    
    
    public void updateFulfillmentStatusAfterCaseClosed(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        Set<id> OrderOnCaseSet = new Set<id>();
        Set<id> reesioOrdersSet = new Set<id>();
        Set<id> processedOLISet = new Set<id>();
        Set<String> ManualPartNumbers = new Set<String>{'REESIO', 'MEDIABUY', 'LISTHUBPRO', 'DOMAINNAME'};   
            // CRM-3209 Added MOVING Products
            ManualPartNumbers.addAll(Label.Moving_Product_Codes.split(','));
        Set<String> fulfillmentStatus = new Set<String>{'Manual', 'Pending Fulfillment'};
            Set<Order> updateOrderSet = new Set<Order>();
        List<Order> ordList = new List<Order>();
        System.debug('newmap--->'+ newCaseValuesMap);
        for(Case newCase : newCaseValuesMap.values()){
            Case oldCase = oldCaseValuesMap.get(newCase.id);
            if(newCase.status == 'closed' && newCase.status != oldCase.Status && oldcase.Type == 'Order' && oldCase.Order__c != null){
                OrderOnCaseSet.add(oldCase.Order__c);
                System.debug('cas- --->'+ OrderOnCaseSet);
            }
            
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!OrderOnCaseSet.isEmpty()) { 
            
            for(OrderItem ordItm:[Select id, OrderId, Asset__r.Fulfillment_Status__c, Asset__r.Line_type__c, 
                                  Asset__r.Start_Date__c, Asset__r.End_Date__c, Asset__c, PricebookEntry.product2.productCode, 
                                  Part_Number__c, Order.Fulfillment_Status__c, Fulfillment_Status__c
                                  from orderItem 
                                  where OrderId IN :OrderOnCaseSet and Part_Number__c IN :ManualPartNumbers 
                                  and Order.Fulfillment_Status__c IN :fulfillmentStatus]){
                                      if((ordItm.Part_Number__c == 'MEDIABUY' && ordItm.Order.Fulfillment_Status__c == 'Manual') || (ordItm.Part_Number__c == 'DOMAINNAME' && ordItm.Order.Fulfillment_Status__c == 'Manual')){
                                          Order ord = new Order();
                                          ord.id = ordItm.OrderId;
                                          ord.Fulfillment_Status__c = 'Pending Fulfillment';
                                          updateOrderSet.add(ord);
                                          System.debug('order---->'+ ordItm);
                                      } 
                                      // CRM-3209 Added MOVING Products
                                      else if((ordItm.Part_Number__c == 'REESIO' || ordItm.Part_Number__c == 'LISTHUBPRO' || Label.Moving_Product_Codes.contains(ordItm.Part_Number__c)) && 
                                              (ordItm.Order.Fulfillment_Status__c == 'Pending Fulfillment' && ordItm.Fulfillment_Status__c == 'Fulfilled') || test.isRunningTest()) {
                                                  // CRM-1703: Get Reesio Orders for which reesio OrderItem is already fulfilled.
                                                  reesioOrdersSet.add(ordItm.OrderId);
                                                  processedOLISet.add(ordItm.id);
                                              }
                                      
                                  }
        }
        
        // Filter orders on which all OrderItems are not fulfilled.
        if (!reesioOrdersSet.isEmpty()) {
            Set<Id> oliOnOrdersSet = new Set<Id>();
            for(OrderItem theOrderItem : [SELECT Id, OrderId, Fulfillment_Status__c FROM OrderItem WHERE OrderId IN :reesioOrdersSet
                                          AND Id NOT IN :processedOLISet]) {
                                              if(theOrderItem.Fulfillment_Status__c != 'Fulfilled'){
                                                  oliOnOrdersSet.add(theOrderItem.OrderId);
                                              }
                                          }
            //2341 to check if all cases closed on order
            List<Case> closedCases = [Select id from Case where Order__c =:reesioOrdersSet and status != 'Closed'];
            if (closedCases.isEmpty()) {
                for(Id ordId : reesioOrdersSet) {
                    if(!oliOnOrdersSet.contains(ordId)) {
                        updateOrderSet.add(new Order(
                            Id = ordId,
                            Fulfillment_Status__c = 'Fulfilled',
                            Status = 'Complete'
                        ));
                    }
                }
            }
        }
        
        if(!updateOrderSet.isEmpty() && !test.isRunningTest()){
            ordList.addAll(updateOrderSet);
            update ordList;
        }
    }
    
    //CRM-1713 -venu-did changes for TOPIDX cases
    public void updateFulfillmentStatusAfterCaseClosedForIDXProduct(Map<Id,Case> newCaseValuesMap, Map<Id,Case> oldCaseValuesMap) {
        Set<id> OrderOnCaseSet = new Set<id>();
        Set<String> IDXPartNumbers = new Set<String>{'TOPIDX'};
            // Set<String> IDXProductCode = new Set<String>{'TOPIDX'};
            Set<Order> updateOrderSet = new Set<Order>();
        List<Order> ordList = new List<Order>();
        List<OrderItem> updateOrderItemList = new List<OrderItem>();        
        System.debug('newmap--->'+ newCaseValuesMap);
        for(Case newCase : newCaseValuesMap.values()){
            Case oldCase = oldCaseValuesMap.get(newCase.id);
            if(newCase.status == 'closed' && newCase.status != oldCase.Status && newCase.Area__c == 'Top Producer IDX' && newCase.Subject.contains('TP IDX Fulfillment Required')){
                OrderOnCaseSet.add(oldCase.Order__c);
                System.debug('cas- --->'+ OrderOnCaseSet);
            }            
        }                
        
        if (!OrderOnCaseSet.isEmpty() && OrderOnCaseSet!= Null) { 
            for(OrderItem ordItem:[Select id, OrderId,Part_Number__c,PricebookEntry.product2.productCode,Order.Fulfillment_Status__c, Fulfillment_Status__c,Contract_Term__c,Start_Date__c,End_Date__c
                                   from orderItem  where OrderId IN :OrderOnCaseSet and PricebookEntry.product2.productCode IN :IDXPartNumbers and Line_Type__c ='Add']){   
                                       
                                       if(ordItem.PricebookEntry.product2.productCode == 'TOPIDX' && ordItem.Order.Fulfillment_Status__c == 'Pending Fulfillment'){
                                           Order ord = new Order();
                                           ord.id = ordItem.OrderId;
                                           ord.Status = 'Complete';
                                           ord.Fulfillment_Status__c = 'Fulfilled';
                                           updateOrderSet.add(ord);
                                           ordItem.Fulfillment_Status__c = 'Fulfilled';                    
                                           ordItem.Start_Date__c = Date.today();
                                           ordItem.End_Date__c = Date.today().addMonths(integer.valueof(ordItem.Contract_Term__c)).addDays(-1); 
                                           updateOrderItemList.add(ordItem);
                                       }
                                   }
        }
        
        update updateOrderItemList;
        
        if(!updateOrderSet.isEmpty()){
            ordList.addAll(updateOrderSet);
            update ordList;
        }
        
    }
    
    // CRM-2092 Added by Venu- to update the last modified by field
    public void updateCaseLastWorkedByForCollectionCases(Map<Id, Case> newCaseValuesMap, Map<Id, Case> oldCaseValuesMap) {
        ID collectionRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Collections').RecordTypeId;
        Id rententionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        for(Case newCase : newCaseValuesMap.values()) {
            if((newCase.Followup_Status__c != oldCaseValuesMap.get(newCase.Id).Followup_Status__c) && ((newCase.RecordTypeId == collectionRecordTypeId)||(newCase.RecordTypeId == rententionRecordTypeId))) {
                newCase.Last_Worked_By__c = UserInfo.getUserId();
            }
        }
    }
    // CRM-2092 Added by Venu- to update the last modified by field
    
    // CRM-3191 - Prevent inserting/updating new case if there is already an open case on the account - private method. 
    private void validateRetentionCaseType(Map<Id, Case> newCases) {
        Id retentionTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        List<String> notAllowedTypes = Label.Not_Allowed_Retention_Types.split(',');
        Map<String, List<Case>> accIdCase = new Map<String, List<Case>>();
        for (Case newCase : newCases.values()) {
            if (newCase.AccountId != null && newCase.Type != null && newCase.RecordTypeId == retentionTypeId && 
                notAllowedTypes.contains(newCase.Type) && newCase.Status != 'Closed') {
                    List<Case> cases = accIdCase.get(newCase.AccountId);
                    if (cases == null) {
                        cases = new List<Case>();
                    }
                    cases.add(newCase);
                    accIdCase.put(newCase.AccountId, cases);
                }  
        }
        if (!accIdCase.isEmpty()) {
            for (AggregateResult result : [SELECT AccountId, COUNT(Id) FROM Case WHERE AccountId IN :accIdCase.keySet() AND RecordTypeId = :retentionTypeId AND Type IN :notAllowedTypes AND Status != 'Closed' AND ID NOT IN :newCases.keySet() GROUP BY AccountId HAVING COUNT(Id)>0]) {
                
                for (Case c : accIdCase.get(String.valueOf(result.get('AccountId')))) {
                    c.addError(Label.Duplicate_Retention_Case_Message);
                }        
            }
        }
    }
    // CRM-3191 - Prevent inserting/updating new case if there is already an open case on the account - public method. 
    public void validateRetentionCaseType(Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isInsert) {
        if (Label.Not_Allowed_Retention_Types != 'none') {
            if (isInsert) {
                validateRetentionCaseType(newMap);
            }
            else {
                Map<Id, Case> cases = new Map<Id, Case>();
                for (Case newCase : newMap.values()) {
                    Case oldCase = oldMap.get(newCase.Id);
                    if (newCase.AccountId != oldCase.AccountId || newCase.RecordTypeId != oldCase.RecordTypeId || 
                        newCase.Type != oldCase.type || newCase.Status != oldCase.Status) {
                            cases.put(newCase.id, newCase);
                        }
                }
                if (!cases.isEmpty()) {
                    validateRetentionCaseType(cases);    
                }
            }
        }
    }
    // CRM-3191 - End
    
    //CRM- 3448: Updating Case Owner's Manager for Service Request Record Type Cases.
    public void UpdateCaseManagers(List<Case> newCSList, Map<Id,Case> oldMap, Boolean isInsert){
        Map<Id,Id> CaseOwnMap =  new Map<Id,Id>();
        Map<Id,Id> UsrMgrsMap = new Map<Id,Id>();
        Map<Id,Id> MgrMgrsMap = new Map<Id,Id>();
        set<Id> setAccountIds = new set<Id>();
        for(Case cs : newCSList){
            Case oldCase;
            if(!isInsert)
                oldCase = oldMap.get(cs.Id);
            if((isInsert && cs.OwnerId != null) || cs.OwnerId != oldCase.OwnerId) {
                CaseOwnMap.put(cs.AccountId, cs.OwnerId);
            }    
            if(cs.AccountId!=null){
                setAccountIds.add(cs.AccountId);
            }    
        }
        if(!CaseOwnMap.isEmpty()){
            for(User usr: [Select Id, ManagerId, Manager.ManagerId from User where Id IN: CaseOwnMap.values()]){
                if(usr.Manager.ManagerID != null)
                    UsrMgrsMap.put(usr.Id, usr.Manager.ManagerId);
            }
            System.debug('UsrMgrsMap:'+UsrMgrsMap); 
            for(User usr: [Select Id, ManagerId, Manager.ManagerId from User where Id IN: UsrMgrsMap.values()]){
                System.debug('usr:'+usr);
                for(Id usrId: UsrMgrsMap.keyset()){
                    System.debug('usrId:'+usrId);
                    if(usr.ManagerId != null)
                        MgrMgrsMap.put(usrId,usr.ManagerId); 
                }
            }
            System.debug('MgrMgrsMap:'+MgrMgrsMap);      
            for(Case newCS: newCSList){
                if(newCS.OwnerId != null){
                    if(!UsrMgrsMap.isEmpty() && UsrMgrsMap.get(newCS.OwnerId) != null)
                        newCS.Managers_Manager__c = UsrMgrsMap.get(newCS.OwnerId);
                    if(!MgrMgrsMap.isEmpty() && MgrMgrsMap.get(newCS.OwnerId) != null)
                        newCS.Managers_Managers_Manager__c = MgrMgrsMap.get(newCS.OwnerId);
                }
                
            }
            
        }   
        
    }
    //CRM- 3448: Updating Case Owner's Manager for Service Request Record Type Cases.
    public void UpdatePhoneNumberManager(List<Case> newCSList, Map<Id,Case> oldMap, Boolean isInsert){
        system.debug('PPPPP'+newCSList);
        set<Id> setAccountIds = new set<Id>();
        for(Case cs : newCSList){
            system.debug(cs.AccountId+'PPPPP');
            if(cs.AccountId!=null){
                setAccountIds.add(cs.AccountId);
            }    
        }
        
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Home_Phone__c,Mobile1__c,Mobile2_Other__c,Work_Phone__c,Phone, Id FROM Account WHERE Id IN: setAccountIds]);
        for(Case newCase : newCSList){
            // Assign account to case from relationship 
            //newCase.AccountId = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
            //newCase.ContactMobile = mapRelationship.get(newCase.Relationship__c).Parent_Account__c;
            if(mapAccount.containskey(newCase.AccountId)){
                newCase.Account_Phone__c = mapAccount.get(newCase.AccountId).Phone;
                //Commented as part of ACP implementation.
                //newCase.Work_Phone__c = mapAccount.get(newCase.AccountId).Work_Phone__c;
                //newCase.Mobile__c = mapAccount.get(newCase.AccountId).Mobile1__c;
                //newCase.Home_Phone__c = mapAccount.get(newCase.AccountId).Home_Phone__c;
                //newCase.Other_Phone__c = mapAccount.get(newCase.AccountId).Mobile2_Other__c;
            }
        } 
    }
    
    public void UpdateSFMCSyncFlag(List<Case> newCSList, Map<Id,Case> oldMap, Boolean isInsert){
    
        ID CollectionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Collections').RecordTypeId;
         for(Case theCase : newCSList) {
            if((isInsert || oldMap.get(theCase.Id).SFMC_Sync__c == False) && thecase.recordTypeID == CollectionRtID ){
                theCase.SFMC_Sync__c = True;
            }
         }
    }
    
    
    //MRB has this piece of code to populate account and contact on new cases for Live agent. 
    /* public void setLiveAgentAccountPopulation(Map<Id, Case> newMap){
Set<Id> ContactIds = new Set<Id>();
for(Case c : newMap.values()){
if(c.accountId == null && c.contactId != null){
contactIds.add(c.contactId);
}
}
if(!contactIds.isEmpty()){
for(contact c: [Select id, email from contact where Id IN: contactIds]){
AccountContactMatch.RecordInfoWrapper[] recordInfoWrappers = new AccountContactMatch.RecordInfoWrapper[]{};
AccountContactMatch.RecordInfoWrapper recordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
recordInfoWrapper.Email = c.Email;
recordInfoWrappers.add(recordInfoWrapper);
List<AccountContactMatch.RecordInfoWrapper> returnRecordInfoWrappers = AccountContactMatch.getRecordInfo(recordInfoWrappers);
System.debug('-->> returnRecordInfoWrappers = ' + returnRecordInfoWrappers);
} 
}

} */ 
    // The following Method updates the phone fields from Contact Method during Case creation when the status is New or Open - venkat arisa
    public void populateCasePhoneFields(List<Case> newCaseList){
        set<Id> accountsList = new set<Id>();
        List<Case> newCases = new List<Case>();
        for(Case caseRecord: newCaseList){           
            if(caseRecord.AccountId != null){
                accountsList.add(caseRecord.AccountId);
                newCases.add(caseRecord);
            }                  
        }
        
        if(!accountsList.isEmpty()){
            system.debug(' **** accountsList *** '+accountsList);
            system.debug(' **** newCases *** '+newCases);
            MoveUtility.updatePhoneFields(newCases,accountsList); 
        }        
    } 
    // CRM-6223: populate case fields using description field (Email-to-Case flow)
    /*
    public void populateOpcityResearchFields(List<Case> newCaseList, Map<Id, Case> oldMap){
        Map<String,Opcity_Research_Case_Field_Mappings__c> orMap = Opcity_Research_Case_Field_Mappings__c.getAll(); 
        Map<String,String> mappings = new Map<String,String>();
        for(Opcity_Research_Case_Field_Mappings__c orm: orMap.values()){
            mappings.put(orm.Email_Field_Name__c, orm.Case_Field_API_Name__c);
        }
        Id recTypeid = Schema.SObjectType.Case.RecordTypeInfosByName.get('Opcity Research').RecordTypeId;
        List<Schema.PicklistEntry>  stateFieldResult = Case.state_opcity__c.getDescribe().getPicklistValues();

        for(Case cr: newCaseList){
            if(cr.description != null && cr.RecordTypeId == recTypeid && cr.Run_Opcity_Mapping_Trigger__c && !oldMap.get(cr.id).Run_Opcity_Mapping_Trigger__c){
                List<String> fieldValList = cr.description.split('\n');
                Set<String> fieldValSet = new Set<String>(fieldValList);
                fieldValSet.remove('');
                system.debug(fieldValSet);
                for(String fv: fieldValSet){
                    String fname = fv.substringBefore(':').trim().removeEnd('*');
                    String fvalue = fv.substringAfter(':');
                    system.debug(fname);
                    if(mappings.containsKey(fname) && fvalue != null){
                        if(fname.equalsIgnoreCase('State')){
                            for( Schema.PicklistEntry f : stateFieldResult ){   
                				if(f.getValue() == fvalue){
                				    cr.put(mappings.get(fname), fvalue);
                				    break;
                				}
                			}
                        } else {
                             cr.put(mappings.get(fname), fvalue);
                        }
                    } 
                }
            } 
        }
    }*/
}