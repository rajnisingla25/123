/*
    Class: SFMC_FormSubmissionHelper
    Purpose: Helper class for form submission object to create lead records.
    Created by: Bupendra
    Created date : 12/1/2018
*/
public without sharing class SFMC_FormSubmissionHelper{

    public static boolean fireTrigger = true;
    
    /*
        Purpose: This method will process from submission record and will update or create Lead 
    */
    public static void processFormSubmissionData(Map<Id, Form_Submission__c> formSubmissionMap){        
        try{                        
            AccountContactMatch.RecordInfoWrapper[] recordInfoWrappers = new AccountContactMatch.RecordInfoWrapper[]{};
                        
            Map<Id, Form_Submission__c> formSubmissionMapForCM = new Map<Id, Form_Submission__c>();
            Map<Integer, Form_Submission__c> formSubmissionMapForInfoWrapper = new Map<Integer, Form_Submission__c>();            
            Set<Id> campaignIdSet = new Set<Id>();
            Map<Id, Id> campaignIdToFormSubmissionIdMap = new Map<Id, Id>();
            Integer iCount = 0;
            for(Form_Submission__c formSubmissionRecord : formSubmissionMap.values()){
                if(String.isNotBlank(formSubmissionRecord.Campaign_Id__c)){
                  campaignIdToFormSubmissionIdMap.put(formSubmissionRecord.Campaign_Id__c , formSubmissionRecord.Id);    
                }
                if(formSubmissionRecord.Lead__c != null) continue;    
                AccountContactMatch.RecordInfoWrapper recordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
                recordInfoWrapper.Email = formSubmissionRecord.Email__c;
                recordInfoWrapper.Phone = formSubmissionRecord.Phone__c;
                recordInfoWrapper.CMId = formSubmissionRecord.Contact_Method_Id__c;
                recordInfoWrapper.AccountId = formSubmissionRecord.Account_Id__c;
                recordInfoWrapper.Campaign = formSubmissionRecord.Campaign_Id__c;
                        
                recordInfoWrappers.add(recordInfoWrapper);
                ++iCount;
                formSubmissionMapForInfoWrapper.put(iCount,formSubmissionRecord);
            }
            
            Map<Id, Campaign> formSubmissionToCampaignRecordMap = new Map<Id, Campaign>();
            if(!campaignIdToFormSubmissionIdMap.isEmpty()){
              formSubmissionToCampaignRecordMap = getFormSubmissionToCampaignMap(campaignIdToFormSubmissionIdMap); 
            }
            System.debug('formSubmissionToCampaignRecordMap :' + formSubmissionToCampaignRecordMap);
            
            //condition to call AccountContactMatch method if CM id is not available in form submission.
            System.debug('-->> recordInfoWrappers = ' + recordInfoWrappers);
            List<AccountContactMatch.RecordInfoWrapper> returnRecordInfoWrappers = AccountContactMatch.getRecordInfo(recordInfoWrappers);
            System.debug('-->> returnRecordInfoWrappers = ' + returnRecordInfoWrappers);
            System.debug('-->> formSubmissionMapForInfoWrapper = ' + formSubmissionMapForInfoWrapper);
            
            Map<id,Form_Submission__c> formSubmissionMapForCMIdfound = new Map<id,Form_Submission__c>();
            Map<id,Form_Submission__c> formSubmissionMapForCMIdNotfound = new Map<id,Form_Submission__c>();
            if(returnRecordInfoWrappers != null && !returnRecordInfoWrappers.isEmpty()){
                iCount = 0;
                for(AccountContactMatch.RecordInfoWrapper returnRecordInfoWrapper : returnRecordInfoWrappers){
                    iCount++;
                    if(returnRecordInfoWrapper.CMId != null){
                        Integer orderKey = returnRecordInfoWrapper.Order ; 
                        if(formSubmissionMapForInfoWrapper.containsKey(iCount)){
                            Form_Submission__c formSubmissionRecord = formSubmissionMapForInfoWrapper.get(iCount);
                            formSubmissionRecord.Contact_Method_Id__c = returnRecordInfoWrapper.CMId;
                            formSubmissionRecord.Account_Id__c = returnRecordInfoWrapper.AccountId;
                            formSubmissionRecord.Contact_Id__c = returnRecordInfoWrapper.contactId;
                            formSubmissionRecord.Lead_Matching_Type__c = returnRecordInfoWrapper.MatchType;
                            formSubmissionMapForCMIdfound.put(formSubmissionRecord.id,formSubmissionRecord);
                            
                        }else{
                            System.debug('Problem in Account Contact Match method not returning same order value');
                        }
                    }else{
                        Form_Submission__c formSubmissionRecord = formSubmissionMapForInfoWrapper.get(iCount);
                        formSubmissionRecord.Lead_Matching_Type__c = returnRecordInfoWrapper.MatchType;
                        formSubmissionMapForCMIdNotfound.put(formSubmissionRecord.id,formSubmissionRecord);
                    }
                                        
                }
            }
            // this is because in lead object , account and contact was not set after putting CM id. 
            System.debug('-->>> formSubmissionMapForCMIdfound = ' + formSubmissionMapForCMIdfound);
            if(!formSubmissionMapForCMIdfound.isEmpty()){
                update formSubmissionMapForCMIdfound.values();
                
                
                Map<Id,Form_Submission__c> formSubmissionMapForCMId = getFormSubmissionRecord(formSubmissionMapForCMIdfound.keyset());
                for(Form_Submission__c formSubmissionRecordForCMId : formSubmissionMapForCMId.values()){
                    formSubmissionMapForCM.put(formSubmissionRecordForCMId.Id, formSubmissionRecordForCMId);
                }
            }
            
            // condition where after calling ACM class also, ACP id is not populated.
            Map<Id, Lead> newLeadMapByFormSubmissionIdNotCM = new Map<Id, Lead>();
            Map<Id,Form_Submission__c> formSubmissionMapById = new Map<Id,Form_Submission__c>();
            
            for(String formSubmissionId : formSubmissionMapForCMIdNotfound.keySet()){
                Form_Submission__c formSubmissionRecord = formSubmissionMapForCMIdNotfound.get(formSubmissionId);
                newLeadMapByFormSubmissionIdNotCM.put(formSubmissionRecord.id, createLead(formSubmissionRecord,formSubmissionToCampaignRecordMap));    
                formSubmissionMapById.put(formSubmissionRecord.id, formSubmissionRecord);
            }
            
            if(!newLeadMapByFormSubmissionIdNotCM.isEmpty()){
                Map<id,String> errorMessageMapByFormSubmissionId = new Map<id,String>();
                    
                errorMessageMapByFormSubmissionId.putAll(upsertLeadAndRecordErrors(newLeadMapByFormSubmissionIdNotCM,true));
                
                associateLeadToFormSubmission(errorMessageMapByFormSubmissionId,newLeadMapByFormSubmissionIdNotCM,new Map<id, Lead>(),formSubmissionMapById);
            }
            
            if(!formSubmissionMapForCM.isEmpty()){
                processFormSubmissionsForCM(formSubmissionMapForCM,formSubmissionToCampaignRecordMap);
            }
        }catch(Exception ex){
            system.debug('Exception stack : ' + ex.getStackTraceString());
            system.debug('Exception message : ' + ex.getMessage());
            SFMC_FormSubmissionHelper.recordExceptionError(formSubmissionMap,ex.getMessage());
        }
                
    }
    
    /*
        * Added by : Sarang D
        * Description : To populate the recent campaign name value in lead, we are querying Campaign records. 
        * This method returns formSubmissionToCampaignRecordMap that will be used later to get campaign values related to FS record.
    */
    private static Map<Id, Campaign> getFormSubmissionToCampaignMap(Map<Id,Id> campaignIdToFormSubmissionIdMap){
        Map<Id, Campaign> formSubmissionToCampaignRecordMap = new Map<Id, Campaign>();
        for(Campaign campaignRecord : [select id, name
                                   from Campaign
                                   where id in : campaignIdToFormSubmissionIdMap.keySet()]){
            formSubmissionToCampaignRecordMap.put(campaignIdToFormSubmissionIdMap.get(campaignRecord.id), campaignRecord);
        }
        return formSubmissionToCampaignRecordMap;
    }
    
    /*
        Purpose: This private method is used to catch and record from submission record exception in any line of code. 
    */
    @TestVisible
    public static void recordExceptionError(Map<Id, Form_Submission__c> newFormSubmissionMap,String exceptionMessage){
        if(newFormSubmissionMap != null){
            for(String keyid : newFormSubmissionMap.keySet()){
                Form_Submission__c newFormSubmissionObj = newFormSubmissionMap.get(keyid);
                newFormSubmissionObj.Error_Message__c = exceptionMessage;
            }
            Database.update(newFormSubmissionMap.values(),false);
        }
    }
    
    /*
        Purpose: This private method is used to process from submission record which has CM ID 
    */
    private static void processFormSubmissionsForCM(Map<Id, Form_Submission__c> formSubmissionMapForCM, Map<Id, Campaign> formSubmissionToCampaignRecordMap){
        Set<Id> accIdSetUsableForLeadGen = new Set<Id>();
        
        Map<Id, Id> contactMethodIdMapByAccountId = new Map<Id, Id>();
        
        for(Form_Submission__c formSubmissionRecord : formSubmissionMapForCM.values()){
            if(String.isNotBlank(formSubmissionRecord.Account_Id__c)){
                contactMethodIdMapByAccountId.put(formSubmissionRecord.Account_Id__c , formSubmissionRecord.Contact_Method_Id__c);
            }
        }
        
        Map<Id, Lead> leadMapByCMId = new Map<Id, Lead>();
        Set<String> marketingLeadTypesToBeExcluded = new Set<String>{SFMC_Constants.MLT_EVENT, SFMC_Constants.MLT_AUTO_RENEW};
        
        for(Lead leadRecord : [SELECT Account__c, Contact__c, CreatedDate, Lead_Origin__c, Status, Last_Engagement_Activity_Date__c,Phone,Email,RDC_Contact_Type__c,Contact_Method__c,OwnerId,Contact_Method__r.Type__c
                               FROM Lead
                               WHERE Account__c IN : contactMethodIdMapByAccountId.keyset()  
                               AND Status IN :SFMC_Constants.LEAD_OPEN_STATUSES
                        AND Marketing_Lead_Type__c NOT IN: marketingLeadTypesToBeExcluded
                               AND RecordType.Name=:SFMC_Constants.LEAD_RECORD_TYPE_RDC]){
            Id contactMethodId  = contactMethodIdMapByAccountId.get(leadRecord.Account__c);
        
            if(contactMethodId != null){
                leadMapByCMId.put(contactMethodId, leadRecord);
            }
            
        }
        System.debug('-->> leadMapByCMId = ' + leadMapByCMId);
                
        Map<id,Lead> updateLeadMapByFormSubmissionId = new Map<id,Lead>();
        Map<id,Lead> newLeadMapByFormSubmissionId = new Map<id,Lead>();
            
        
        Lead_Gen_Setting__mdt[] leadGenSetting = [SELECT Reject_Lead_If_more_than_Days__c FROM Lead_Gen_Setting__mdt];
        Integer daysToCheck = (Integer) (leadGenSetting.isEmpty() || Test.isRunningTest() ? 30 : leadGenSetting[0].Reject_Lead_If_more_than_Days__c);
        
        System.debug('daysToCheck = ' +daysToCheck);
        
        for(Form_Submission__c formSubmissionRecord : formSubmissionMapForCM.values()){         
            Lead leadRecord = leadMapByCMId.get(formSubmissionRecord.Contact_Method_Id__c);
            
            System.debug('leadRecord ' +leadRecord);
            if(leadRecord == null){ // there is no open lead, create a new lead             
                newLeadMapByFormSubmissionId.put(formSubmissionRecord.id,createLead(formSubmissionRecord,formSubmissionToCampaignRecordMap));
                continue;
            }
                    
            
            updateLeadMapByFormSubmissionId.put(formSubmissionRecord.id,leadRecord);
            
            if(leadRecord.Lead_Origin__c == SFMC_Constants.NURTURE_LEAD){
                System.debug(System.now().addDays(daysToCheck * -1));
                if(leadRecord.CreatedDate > System.now().addDays(daysToCheck * -1)){
                    //lead is updated with campaign
                    updateLead(leadRecord,formSubmissionRecord, true, formSubmissionToCampaignRecordMap);
                    
                }
                else{
                    //reject the lead and create new lead
                    leadRecord.status = SFMC_Constants.LEAD_REJECTED_STATUS;
                    leadRecord.Rejected_Reason__c = SFMC_Constants.LEAD_REJECTED_REASON_CLOSED_DUE_TO_NEW_SUBMISSION;
                    newLeadMapByFormSubmissionId.put(formSubmissionRecord.id,createLead(formSubmissionRecord,formSubmissionToCampaignRecordMap));
                }
                
            }
            else{// if the lead is not Nurture lead type, update this lead with campaign
                    //lead is updated with campaign
                    updateLead(leadRecord,formSubmissionRecord, false, formSubmissionToCampaignRecordMap);
                    //updateLeadCampaignMapByFormSubmission.put(formSubmissionRecord, leadRecord);
            }
        }
        
        
        Map<id,String> errorMessageMapByFormSubmissionId = new Map<id,String>();
        
        //this is for new Lead
        System.debug('newLeadMapByFormSubmissionId = ' + newLeadMapByFormSubmissionId);
        if(!newLeadMapByFormSubmissionId.isEmpty()){            
            errorMessageMapByFormSubmissionId.putAll(upsertLeadAndRecordErrors(newLeadMapByFormSubmissionId,true));
        }
        
        
        //this is for updating lead
        System.debug('updateLeadMapByFormSubmissionId = ' + updateLeadMapByFormSubmissionId);
        if(!updateLeadMapByFormSubmissionId.isEmpty()){
            errorMessageMapByFormSubmissionId.putAll(upsertLeadAndRecordErrors(updateLeadMapByFormSubmissionId,false));
        }
        
        //finally update FormSubmission Records as it holds key in map
        Form_Submission__c[] updateFormSubmissionList = associateLeadToFormSubmission(errorMessageMapByFormSubmissionId,newLeadMapByFormSubmissionId,updateLeadMapByFormSubmissionId,formSubmissionMapForCM);
                
    }
    
    /*
        Purpose: This private method is used to update form submission record with corresponding lead or error message 
    */
    private static Form_Submission__c[] associateLeadToFormSubmission(Map<id,String> errorMessageMapByFormSubmissionId, Map<id, Lead> newLeadMapByFormSubmissionId,Map<id, Lead>  updateLeadMapByFormSubmissionId,Map<id,Form_Submission__c> formSubmissionMapByFormSubmissionId){
        Form_Submission__c[] updateFormSubmissionList = new Form_Submission__c[]{};
        
        if(!newLeadMapByFormSubmissionId.isEmpty()){
            System.debug('newLeadMapByFormSubmissionId ' + newLeadMapByFormSubmissionId); 
            for(String formSubmissionId : newLeadMapByFormSubmissionId.keyset()){
                Form_Submission__c formSubmissionRecord = formSubmissionMapByFormSubmissionId.get(formSubmissionId);                
                //We need condition because in case of failure we don't need to map lead. 
                if(errorMessageMapByFormSubmissionId.containsKey(formSubmissionId)){
                    formSubmissionRecord.Error_Message__c = errorMessageMapByFormSubmissionId.get(formSubmissionId);
                }else{
                    formSubmissionRecord.Error_Message__c = '';
                    formSubmissionRecord.Lead__c = newLeadMapByFormSubmissionId.get(formSubmissionId).Id;
                }
                updateFormSubmissionList.add(formSubmissionRecord);
            }
        }
                
        if(!updateLeadMapByFormSubmissionId.isEmpty()){
            for(String formSubmissionId : updateLeadMapByFormSubmissionId.keyset()){
                Form_Submission__c formSubmissionRecord = formSubmissionMapByFormSubmissionId.get(formSubmissionId);
                if(newLeadMapByFormSubmissionId.get(formSubmissionId) != null){
                    continue; //because this record updated in above loop. newLeadMapByFormSubmission
                }               
                //We need condition because in case of failure we don't need to map lead.
                if(errorMessageMapByFormSubmissionId.containsKey(formSubmissionId)){
                    formSubmissionRecord.Error_Message__c = errorMessageMapByFormSubmissionId.get(formSubmissionId);
                }else{
                    formSubmissionRecord.Error_Message__c = '';
                    formSubmissionRecord.Lead__c = updateLeadMapByFormSubmissionId.get(formSubmissionId).Id;
                }
                updateFormSubmissionList.add(formSubmissionRecord);
            }
        }           
        
        System.debug('-->> updateFormSubmissionList =' + updateFormSubmissionList);
        update updateFormSubmissionList;
        
        
        return updateFormSubmissionList;
    }
    /*
        Purpose: This private method is used to populate lead field from form submission record
    */
    private static void updateLead(Lead leadToUpdate, Form_Submission__c formSubmissionRecord, Boolean isNurture, Map<Id, Campaign> formSubmissionToCampaignRecordMap){
        String campaignName = '';
        if(!formSubmissionToCampaignRecordMap.isEmpty() &&
           formSubmissionToCampaignRecordMap.containsKey(formSubmissionRecord.Id) &&
           formSubmissionToCampaignRecordMap.get(formSubmissionRecord.Id) != null){
            campaignName = formSubmissionToCampaignRecordMap.get(formSubmissionRecord.Id).Name;
        }
        if(isNurture){
            leadToUpdate.Status = 'New';
            leadToUpdate.Follow_Up_Status__c = null;
            System.debug('formSubmissionRecord.OwnerId->>'+formSubmissionRecord.OwnerId);
            leadToUpdate.OwnerId = formSubmissionRecord.OwnerId;
        }
        leadToUpdate.Recent_Campaign__c = campaignName;
        leadToUpdate.Recent_Campaign_Id__c = formSubmissionRecord.Campaign_Id__c;
        leadToUpdate.Link_Campaign__c  = formSubmissionRecord.Campaign_Id__c;
        leadToUpdate.Recent_Form_Submission_Date__c = System.now();
        //leadToUpdate.Last_Engagement_Date__c = System.now();
        leadToUpdate.Last_Engagement_Activity_Date__c = System.now();
        leadToUpdate.Business_Unit__c = formSubmissionRecord.Business_Unit__c;
        leadToUpdate.Lead_Origin__c = formSubmissionRecord.Lead_Origin__c;
        leadToUpdate.Product_Type__c = formSubmissionRecord.Product_Type__c;
        leadToUpdate.postalcode = formSubmissionRecord.Zip_Code__c;
        leadToUpdate.Lead_Matching_Type__c = formSubmissionRecord.Lead_Matching_Type__c;
        leadToUpdate.Phone = SFMC_Utility.getFormattedPhoneNumber(String.isNotBlank(formSubmissionRecord.Phone__c) ? formSubmissionRecord.Phone__c  : leadToUpdate.Phone);
        leadToUpdate.Email = String.isNotBlank(formSubmissionRecord.Email__c) ? formSubmissionRecord.Email__c : leadToUpdate.Email;
        leadToUpdate.Contact_Method__c = String.isBlank(leadToUpdate.Contact_Method__c) ? formSubmissionRecord.Contact_Method_Id__c : leadToUpdate.Contact_Method__c;
        //JIRA - SMCI
        leadToUpdate.Lead_Medium__c = formSubmissionRecord.Medium__c;
        leadToUpdate.LeadSource = formSubmissionRecord.Source__c;
        leadToUpdate.Lead_Content__c = formSubmissionRecord.UTM_Content__c;
        //Google tag manager GCLID related changes
        leadToUpdate.GCLID__c = formSubmissionRecord.GCLID__c;
        // Facebook - capture extenal lead id
        leadToUpdate.Facebook_Lead_ID__c = formSubmissionRecord.Facebook_Lead_ID__c;
        leadToUpdate.RDC_URL_Link__c = formSubmissionRecord.URL__c;
            
    }
    
    private static Lead createLead(Form_Submission__c formSubmissionRecord,Map<Id, Campaign> formSubmissionToCampaignRecordMap){
        String campaignName = '';
        if(!formSubmissionToCampaignRecordMap.isEmpty() &&
           formSubmissionToCampaignRecordMap.containsKey(formSubmissionRecord.Id) &&
           formSubmissionToCampaignRecordMap.get(formSubmissionRecord.Id) != null){
            campaignName = formSubmissionToCampaignRecordMap.get(formSubmissionRecord.Id).Name;
        }
        
        /*Landing_Page_Parameters__c landingPage = Landing_Page_Parameters__c.getValues(formSubmissionRecord.RDC_Contact_Type__c);
        String leadRDCVal = '';
        if(landingPage.Lead_Picklist_Value__c != null){
            leadRDCVal = landingPage.Lead_Picklist_Value__c;
        }*/
        String leadRDCVal = '';
        List<Landing_Page_Parameters__c> landingPageSettings = Landing_Page_Parameters__c.getall().values();
        Map<String,String> settingMap = new Map<String,String>();
        for(Landing_Page_Parameters__c lpp : landingPageSettings){
            settingMap.put(lpp.Picklist_Value__c,lpp.Lead_Picklist_Value__c);
        }
        if(settingMap.containsKey(formSubmissionRecord.RDC_Contact_Type__c)){
            leadRDCVal = settingMap.get(formSubmissionRecord.RDC_Contact_Type__c);
        }
        String callbackDate;
        String callbackTime;
        if(Test.isRunningTest()){
        callbackDate = Datetime.now().addDays(3).format('MM/dd/yyyy');
        callbackTime = '6:00 AM';
        }
        
        return new Lead(
            Account__C = formSubmissionRecord.Account_Id__c, 
            Contact__c = formSubmissionRecord.Contact_Id__c, 
            lastName = formSubmissionRecord.Last_Name__c, 
            firstName = formSubmissionRecord.First_Name__c, 
            Company = formSubmissionRecord.Last_Name__c, 
            Phone = SFMC_Utility.getFormattedPhoneNumber(formSubmissionRecord.Phone__c) , 
            Email = formSubmissionRecord.Email__c, 
            Recent_Campaign__c = campaignName,
            Recent_Campaign_Id__c = formSubmissionRecord.Campaign_Id__c,
            Link_Campaign__c = formSubmissionRecord.Campaign_Id__c,  
            Lead_Medium__c = formSubmissionRecord.Medium__c, 
            Recent_Form_Submission_Date__c = System.now(), 
            //Last_Engagement_Date__c = System.now(), 
            Last_Engagement_Activity_Date__c = System.now(),
            Business_Unit__c = formSubmissionRecord.Business_Unit__c, 
            Lead_Origin__c = formSubmissionRecord.Lead_Origin__c, 
            Product_Type__c = formSubmissionRecord.Product_Type__c, 
            postalcode = formSubmissionRecord.Zip_Code__c,
            RDC_Contact_Type__c = leadRDCVal,
            Contact_Method__c = formSubmissionRecord.Contact_Method_Id__c, 
            Lead_Submission_Date__c = System.now(),
            Lead_Matching_Type__c = formSubmissionRecord.Lead_Matching_Type__c,
            LeadSource = formSubmissionRecord.Source__c,
            Lead_Content__c = formSubmissionRecord.UTM_Content__c,
            //Google tag manager GCLID related changes
            GCLID__c    = formSubmissionRecord.GCLID__c,
            // Facebook -capture extenal lead id
            Facebook_Lead_ID__c = formSubmissionRecord.Facebook_Lead_ID__c,
            RDC_URL_Link__c = formSubmissionRecord.URL__c,
            Callback_Date__c = callbackDate,
            Callback_Time__c = '6:00 AM'
            );
    }   
    
    /*
        Purpose: Log error message in error message map whenever there is any database failure for lead
    Modified by: Sarang D
           Added code to fetch set DML Option for leads getting upserted so that assignment rules are set for these leads.
    */
    private static Map<id,String> upsertLeadAndRecordErrors(Map<id,Lead> leadMapByFormSubmissionId, Boolean isInsert){
        Map<id,String> errorMessageMapByFormSubmissionId = new Map<id,String>();        
        List<Id> formSumissionIds = new List<Id>();
        List<Lead> leadRecords = new List<Lead>();
        List<Id> updateLeadIds = new List<Id>();
        
        //Fetching lead assignment rule and setting DML Option with the same. To be used to set options for leads that are getting created.
        AssignmentRule leadAssignMentRule = [select id from AssignmentRule where SobjectType = 'Lead'and Active = true limit 1];
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.assignmentRuleHeader.assignmentRuleId= leadAssignMentRule.id;    
        
        //loop to avoid duplicate leads.
        for(String formSubmissionId :leadMapByFormSubmissionId.keyset()){
            Lead leadRecord = leadMapByFormSubmissionId.get(formSubmissionId);
            System.debug('updateLeadIds = ' + updateLeadIds);
            if(leadRecord != null && (leadRecord.id == null || !updateLeadIds.contains(leadRecord.id))){
                updateLeadIds.add(leadRecord.id);
                formSumissionIds.add(formSubmissionId);
                leadRecord.setOptions(dmlOption);
                leadRecords.add(leadRecord);
            }
        }
        
        System.debug('leadRecords = ' + leadRecords);       
         
        Database.SaveResult[] SaveResultList;
        if(isInsert){
            SaveResultList = Database.insert(leadRecords, false);
        }else{
            SaveResultList = Database.update(leadRecords, false);
        }
        System.debug('SaveResultList = ' + SaveResultList);
        for(integer index=0 ; index < SaveResultList.size()  ; index++ ){
            Database.SaveResult SaveResultRecord = SaveResultList.get(index);
            if(!SaveResultRecord.isSuccess()){
                String errorMessage = '';
                for(Database.Error error : SaveResultRecord.getErrors()){
                    errorMessage += error.getMessage() +'\n';
                }
                errorMessageMapByFormSubmissionId.put(formSumissionIds.get(index),errorMessage);
            }
        }
        System.debug('errorMessageMapByFormSubmissionId = ' + errorMessageMapByFormSubmissionId);
        return errorMessageMapByFormSubmissionId;
    }
    
    
    /*
        Purpose: This private method is used to fetch form submission record list
    */
    public static Map<Id,Form_Submission__c> getFormSubmissionRecord(set<id> formSubmissionIds){
        Map<Id,Form_Submission__c> formSubmissionMap = new Map<Id,Form_Submission__c>([SELECT Last_Name__c, First_Name__c, Source__c, UTM_Content__c, Campaign_Id__c,  Lead__c,  Contact_Method_Id__c,  
                                                                                                Contact_Id__c, Phone__c ,  Medium__c, Email__c,Business_Unit__c,Lead_Origin__c,Product_Type__c, Zip_Code__c,
                                                                                                RDC_Contact_Type__c,Account_Id__c,Lead_Matching_Type__c, Form_Type__c,Error_Message__c,OwnerId,
                                                                                                GCLID__c,Facebook_Lead_ID__c,URL__c
                                                                                       FROM Form_Submission__c
                                                                                       WHERE Id IN : formSubmissionIds]); 
        return formSubmissionMap;
    }
    
    public static void createEngagementActivities(Map<Id, Form_Submission__c> triggerMap, Boolean isInsert){
        if(isInsert){
            Set<Id> formSubmissionIdSet = new Set<Id>();
            for(Id formSubmissionId : triggerMap.keySet()){
                System.debug('formtype>>>'+triggerMap.get(formSubmissionId).Form_Type__c);
                formSubmissionIdSet.add(formSubmissionId);
            }
            if(!formSubmissionIdSet.isEmpty()){
                SFMC_EngagementActivityUtils.createEGAforFormSubmission(formSubmissionIdSet);   
            }
        }
    }
    
    @future
    public static void updatePreferenceField(set<Id> formSubmissionIds){
        SFMC_PreferenceUtils.updateContactMethodPreference(formSubmissionIds);  
    }
       
}