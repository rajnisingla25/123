/*
 * Created By:  Sarang Deshpande
 * Purpose:     Helper class to process referral form submisison data coming from Referral Landing page
 *               and create or update the lead based on type of data.
*/
public without sharing class SFMC_ReferralFormSubmissionHelper {

    public static Map<Id, Map<Integer, Integer>> formSubmissionIdToWrapperOrderMap = new Map<Id,  Map<Integer, Integer>>();
    
    /*
     * Created By:  Sarang Deshpande
     * Purpose:     As a parent method to call functions for processing referral data and create/update leads.
     * Parameters:  Map of form submission Id to Form submission record, specifically for referral type of Form submissions.
    */
    public static void processReferralFormSubmissionData(Map<Id, Form_Submission__c> formSubmissionIdToRecordmap){
        try{
            Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToUpdatedWrapperListMap = new Map<Id, List<AccountContactMatch.RecordInfoWrapper>>();
            List<Form_Submission__c> referralTypeFormSubmissionList = new List<Form_Submission__c>();
            Boolean noReferralDataEntered = true;
            
            for(Form_Submission__c formSubmissionRecord : getUpdatedFormSubmissionFromACMMethod(formSubmissionIdToRecordmap.values())){   
                referralTypeFormSubmissionList.add(formSubmissionRecord);
                List<AccountContactMatch.RecordInfoWrapper> wrapperListForOneRecord = createReferralInfoWrapper(formSubmissionRecord);
                //If some data is entered for any of the referrals, set the flag to false.
                if(wrapperListForOneRecord.size() > 0){
                    noReferralDataEntered = false;
                }
                formSubmissionIdToUpdatedWrapperListMap.put(formSubmissionRecord.id, AccountContactMatch.getRecordInfo(wrapperListForOneRecord));
            }
            
            //If flag was never set to false, implies all referral data for all Form submissions was blank.
            // Hence, update FS list with whatever values entered and exit method.
            // This will update Form submission records with data returned from ACM method like campaignId, CMId etc.
            if(noReferralDataEntered){
                update referralTypeFormSubmissionList;
            }
            else if(formSubmissionIdToUpdatedWrapperListMap.size() > 0){
                processWrappersToCreateOrUpdateLeads(formSubmissionIdToUpdatedWrapperListMap, referralTypeFormSubmissionList);
            }
        }
        catch(Exception ex){
            system.debug('Referral form submission Exception' + ex.getStackTraceString());
            SFMC_FormSubmissionHelper.recordExceptionError(formSubmissionIdToRecordmap, ex.getMessage());
        }
    }
    
    /*
     * Created By: Sarang D
     * Purpose:    To pass FS records to ACM method and updated those record instances with values returned from ACM custom method.
     *              These updated FS record instance list would then be passed to process referral data.
    */
    private static List<Form_Submission__c> getUpdatedFormSubmissionFromACMMethod(List<Form_Submission__c> formSubmissionListFromTrigger){
        AccountContactMatch.RecordInfoWrapper[] recordInfoWrappers = new AccountContactMatch.RecordInfoWrapper[]{};
        Map<Integer, Form_Submission__c> formSubmissionMapForInfoWrapper = new Map<Integer, Form_Submission__c>();            
        
        /*Process for getting form submission updated with values returned from ACM custom method.*/
        Integer iCount = 0;
        for(Form_Submission__c formSubmissionRecord : formSubmissionListFromTrigger){
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
        
        //condition to call AccountContactMatch method if CM id is not available in form submission.
        List<AccountContactMatch.RecordInfoWrapper> returnRecordInfoWrappers = AccountContactMatch.getRecordInfo(recordInfoWrappers);        
        List<Form_Submission__c> formSubmissionListWithUpdatedValues = new List<Form_Submission__c>();
        iCount = 0;
        for(AccountContactMatch.RecordInfoWrapper returnRecordInfoWrapper : returnRecordInfoWrappers){
            iCount++;
            if(formSubmissionMapForInfoWrapper.containsKey(iCount)){
                Form_Submission__c formSubmissionRecord = formSubmissionMapForInfoWrapper.get(iCount);
                formSubmissionRecord.Contact_Method_Id__c = returnRecordInfoWrapper.CMId;
                formSubmissionRecord.Account_Id__c = returnRecordInfoWrapper.AccountId;
                formSubmissionRecord.Contact_Id__c = returnRecordInfoWrapper.contactId;
                formSubmissionRecord.Lead_Matching_Type__c = returnRecordInfoWrapper.MatchType;
                formSubmissionListWithUpdatedValues.add(formSubmissionRecord);
            }else{
                System.debug('Problem in Account Contact Match method not returning same order value');
            }
        }
        return formSubmissionListWithUpdatedValues;
    }
    
    /*
     * Created By: Sarang D
     * Purpose:    To create wrapper list for Referral form submission.
     * Returns:    List of ACM wrapper instances for this particular FS record's referrals.
    */
    private static List<AccountContactMatch.RecordInfoWrapper> createReferralInfoWrapper(Form_Submission__c formSubmissionRecord){
        List<AccountContactMatch.RecordInfoWrapper> referralInfoWrapperList = new List<AccountContactMatch.RecordInfoWrapper>();
        Map<Integer, Integer> wrapperSequenceToOrderMap = new Map<Integer, Integer>();
        Integer order = 0;
        if(String.isNotBlank(formSubmissionRecord.Friend_Last_Name_1__c)){
            AccountContactMatch.RecordInfoWrapper referralInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
            referralInfoWrapper.Email = formSubmissionRecord.Friend_Email_1__c;
            referralInfoWrapper.Phone = formSubmissionRecord.Friend_Phone_1__c;
            referralInfoWrapperList.add(referralInfoWrapper);
            order = order +1;
            wrapperSequenceToOrderMap.put(order, 1);
        }
        if(String.isNotBlank(formSubmissionRecord.Friend_Last_Name_2__c)){
            AccountContactMatch.RecordInfoWrapper referralInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
            referralInfoWrapper.Email = formSubmissionRecord.Friend_Email_2__c;
            referralInfoWrapper.Phone = formSubmissionRecord.Friend_Phone_2__c;
            referralInfoWrapperList.add(referralInfoWrapper);
            order = order +1;
            wrapperSequenceToOrderMap.put(order, 2);
        }
        if(String.isNotBlank(formSubmissionRecord.Friend_Last_Name_3__c)){
            AccountContactMatch.RecordInfoWrapper referralInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
            referralInfoWrapper.Email = formSubmissionRecord.Friend_Email_3__c;
            referralInfoWrapper.Phone = formSubmissionRecord.Friend_Phone_3__c;
            referralInfoWrapperList.add(referralInfoWrapper);
            order = order +1;
            wrapperSequenceToOrderMap.put(order, 3);
        }
        if(String.isNotBlank(formSubmissionRecord.Friend_Last_Name_4__c)){
            AccountContactMatch.RecordInfoWrapper referralInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
            referralInfoWrapper.Email = formSubmissionRecord.Friend_Email_4__c;
            referralInfoWrapper.Phone = formSubmissionRecord.Friend_Phone_4__c;
            referralInfoWrapperList.add(referralInfoWrapper);
            order = order +1;
            wrapperSequenceToOrderMap.put(order, 4);
        }
        if(String.isNotBlank(formSubmissionRecord.Friend_Last_Name_5__c)){
            AccountContactMatch.RecordInfoWrapper referralInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
            referralInfoWrapper.Email = formSubmissionRecord.Friend_Email_5__c;
            referralInfoWrapper.Phone = formSubmissionRecord.Friend_Phone_5__c;
            referralInfoWrapperList.add(referralInfoWrapper);
            order = order +1;
            wrapperSequenceToOrderMap.put(order, 5);
        }   
        formSubmissionIdToWrapperOrderMap.put(formSubmissionRecord.id, wrapperSequenceToOrderMap);
        return referralInfoWrapperList;
    } 
    
    
    /*
     * Created By: Sarang D
     * Purpose:    SMCI  - 263: To process wrapper realted to Referral data submitted from form submission, and call create or update methods for lead.
    */
    private static void processWrappersToCreateOrUpdateLeads(Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToWrapperListMap, List<Form_Submission__c> referralTypeFormSubmissionList){
        Set<Id> accountIdSetUsableForLeadCreation = new Set<Id>();
        Set<Id> accountIdSetUsableForLeadUpdation = new Set<Id>();
        Map<Id, Form_Submission__c> formSubmissionIdToRecordMap = new Map<Id, Form_Submission__c>();
        List<Form_Submission__c> formSubmissionForLeadCreationList = new List<Form_Submission__c>();
        Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToWrapperListMapForLeadCreation = new Map<Id, List<AccountContactMatch.RecordInfoWrapper>>();
        Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToWrapperListMapForLeadUpdate = new Map<Id, List<AccountContactMatch.RecordInfoWrapper>>();
        Map<Id, AccountContactMatch.RecordInfoWrapper> accountIdToWrapperMap = new map<Id, AccountContactMatch.RecordInfoWrapper>();
        Set<Id> camapignIdSet = new Set<Id>();
        
        for(Form_Submission__c formSubmissionRecord : referralTypeFormSubmissionList){
            camapignIdSet.add(formSubmissionRecord.Campaign_Id__c);
            List<AccountContactMatch.RecordInfoWrapper> wrapperListForCreatingLeads = new List<AccountContactMatch.RecordInfoWrapper>();
            Integer count = 1;
            Map<Integer, Integer> wrapperSequenceToOrderMap = formSubmissionIdToWrapperOrderMap.get(formSubmissionRecord.Id);
            for(AccountContactMatch.RecordInfoWrapper wrapper : formSubmissionIdToWrapperListMap.get(formSubmissionRecord.id)){
                wrapper.order = wrapperSequenceToOrderMap.get(count);
                if(wrapper.AccountId != null){
                    accountIdToWrapperMap.put(wrapper.AccountId, wrapper);
                }
                else{
                    wrapperListForCreatingLeads.add(wrapper);
                } 
                count++;
            }
            if(wrapperListForCreatingLeads.size() > 0){
                formSubmissionIdToWrapperListMapForLeadCreation.put(formSubmissionRecord.id, wrapperListForCreatingLeads);
                formSubmissionForLeadCreationList.add(formSubmissionRecord);    
            }
        }
        
         List<String> marketingLeadTypesToBeExcluded = new List<String>{SFMC_Constants.MLT_EVENT, SFMC_Constants.MLT_AUTO_RENEW};
        for(Account acc: [select Account_Sub_Type__c , (select id, status from leads__r where status in: SFMC_Constants.LEAD_OPEN_STATUSES and Marketing_Lead_Type__c NOT IN: marketingLeadTypesToBeExcluded and RecordType.Name=:SFMC_Constants.LEAD_RECORD_TYPE_RDC)
                          from account
                          where id in : accountIdToWrapperMap.keySet()]){
                              //Filtering those accounts whose account sub type is not customer and have no open lead associated to them.
                              Boolean accHasNoOpenLead = true;
                              if(!acc.Account_Sub_Type__c.Equals(SFMC_Constants.ACCOUNT_SUB_TYPE_CUSTOMER)){
                                  if(acc.leads__r.isEmpty()){   //If no lead(or no OPEN lead), create and associate one.
                                      accountIdSetUsableForLeadCreation.add(acc.id);    //Accounts that would be used to create leads
                                  }
                                  else{                         //As some open lead is present, this Account will be used for updating that lead.
                                      accountIdSetUsableForLeadUpdation.add(acc.id); 
                                  }
                              }
                          }
        
        for(Form_Submission__c formSubmissionRecord : referralTypeFormSubmissionList){
            List<AccountContactMatch.RecordInfoWrapper> wrapperListForCreatingLeads = new List<AccountContactMatch.RecordInfoWrapper>();
            List<AccountContactMatch.RecordInfoWrapper> wrapperListForUpdatingLeads = new List<AccountContactMatch.RecordInfoWrapper>();
            
            for(AccountContactMatch.RecordInfoWrapper wrapper : formSubmissionIdToWrapperListMap.get(formSubmissionRecord.id)){
                if(accountIdSetUsableForLeadCreation.contains(wrapper.accountId)){
                    wrapperListForCreatingLeads.add(wrapper);
                }
                if(accountIdSetUsableForLeadUpdation.contains(wrapper.accountId)){
                    wrapperListForUpdatingLeads.add(wrapper);
                }
            }
            if(wrapperListForCreatingLeads.size() > 0){ //segregate FS records with wrappers that will create leads.
                if(formSubmissionIdToWrapperListMapForLeadCreation.containsKey(formSubmissionRecord.id)){
                    formSubmissionIdToWrapperListMapForLeadCreation.get(formSubmissionRecord.id).addAll(wrapperListForCreatingLeads);    
                }
                else{
                    formSubmissionIdToWrapperListMapForLeadCreation.put(formSubmissionRecord.id, wrapperListForCreatingLeads);
                    formSubmissionForLeadCreationList.add(formSubmissionRecord);
                }    
            }
            if(wrapperListForUpdatingLeads.size() > 0){ //segregate FS records with wrappers that will update leads.
                formSubmissionIdToWrapperListMapForLeadUpdate.put(formSubmissionRecord.id, wrapperListForUpdatingLeads);
                formSubmissionIdToRecordMap.put(formSubmissionRecord.id, formSubmissionRecord);
            }
        }
        
        Map<Id, Campaign> campignIdToRecordMap = new Map<Id, Campaign>([select id, name from Campaign where id in: camapignIdSet]);
        system.debug('campignIdToRecordMap : ' + campignIdToRecordMap);
        
        List<Form_Submission__c> updatedFormSubmissionRecords = createReferralLeads(formSubmissionIdToWrapperListMapForLeadCreation, formSubmissionForLeadCreationList, campignIdToRecordMap);
        List<Form_Submission__c> onlyLeadCreatorFormSubmssionList = new List<Form_Submission__c>();
        if(formSubmissionIdToRecordMap.size() > 0){
            for(Form_Submission__c fsRec : updatedFormSubmissionRecords){
                if(formSubmissionIdToRecordMap.keyset().contains(fsRec.id)){ //If FS record returned from createReferralLeads is present in updatable FS list(fsForLeadUpdationList) as well,
                    formSubmissionIdToRecordMap.put(fsRec.id, fsRec);       //Then update that fs record with returned FS record(from createReferralLeads) as it will contain latest information.
                }
                else{
                    onlyLeadCreatorFormSubmssionList.add(fsRec);
                }
            }    
            updatedFormSubmissionRecords = updateReferralLeads(formSubmissionIdToWrapperListMapForLeadUpdate, formSubmissionIdToRecordMap.values(), campignIdToRecordMap);
            updatedFormSubmissionRecords.addAll(onlyLeadCreatorFormSubmssionList);
        }
        upsert updatedFormSubmissionRecords;
    }
    
    /*
     * Created By: Sarang D
     * Purpose:    SMCI  - 263: To create as many leads as there are referrals in the submitted form, when form submission type is 'Referral'.
     * Returns:    List of lead record instances to be inserted as a part of lead gen process.
     * Modified by: Sarang D
     * Description: To populate Recent campaign field with campaign name, querying campaign based on ID returned from wrapper.
     * Modified by: Sarang D,20/5/2019
     * Description: Added code to set DML options for assignment rules of leads.
     * 
    */
    private static List<Form_Submission__c> createReferralLeads(Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToWrapperListMapForLeadCreation, List<Form_Submission__c> referralTypeFormSubmissionList, Map<Id, Campaign> campignIdToRecordMap){
        List<Lead> leadsTobeCreated = new List<Lead>();
        List<Id> formSubmissionIdList = new List<Id>();
        Map<id, Form_Submission__c> formSubmissionIdIdToFSRecordMap = new Map<id, Form_Submission__c>();
        List<Form_Submission__c> formSubmissionRecordsToBeUpdated = new List<Form_Submission__c>();
        
        
        //Fetching lead assignment rule and setting DML Option with the same. To be used to set options for leads that are getting created.
        AssignmentRule leadAssignMentRule = [select id from AssignmentRule where SobjectType = 'Lead'and Active = true limit 1];
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.assignmentRuleHeader.assignmentRuleId= leadAssignMentRule.id;    
        
        for(Form_Submission__c formSubmissionRecord: referralTypeFormSubmissionList){
            formSubmissionIdIdToFSRecordMap.put(formSubmissionRecord.id, formSubmissionRecord);
            for(AccountContactMatch.RecordInfoWrapper recordWrapper: formSubmissionIdToWrapperListMapForLeadCreation.get(formSubmissionRecord.Id)){
                formSubmissionIdList.add(formSubmissionRecord.id);
                String campaignName = '';
                if(String.isNotBlank(formSubmissionRecord.Campaign_Id__c) && campignIdToRecordMap.get(formSubmissionRecord.Campaign_Id__c) != null){
                    campaignName = campignIdToRecordMap.get(formSubmissionRecord.Campaign_Id__c).name;
                }
                Lead newLead = new Lead(
                    lastName = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LASTNAME + recordWrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX),
                    firstName = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_FIRSTNAME + recordWrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX), 
                    Company = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LASTNAME + recordWrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX), 
                    Phone = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_PHONE + recordWrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX), 
                    Email = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_EMAIL + recordWrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX),
                    Contact_Method__c = recordWrapper.CMId,
                    Account__c = recordWrapper.AccountId,
                    Contact__c = recordWrapper.ContactId,
                    //Recent_Campaign__c = formSubmissionRecord.Campaign_Id__c, 
                    Recent_Campaign__c = campaignName, 
                    Recent_Campaign_Id__c = formSubmissionRecord.Campaign_Id__c,
                    Link_Campaign__c = formSubmissionRecord.Campaign_Id__c,
                    Business_Unit__c = formSubmissionRecord.Business_Unit__c,
                    Product_Type__c = formSubmissionRecord.Product_Type__c,
                    Lead_Origin__c = SFMC_Constants.LEAD_ORIGIN_MARKETING_REFERRAL,
                    Referral__c = true,
                    Referring_Agent_Name__c = formSubmissionRecord.First_Name__c + ' ' + formSubmissionRecord.Last_Name__c,
                    Referring_Agent_Phone__c = formSubmissionRecord.Phone__c,
                    Referring_Agent_Email__c = formSubmissionRecord.Email__c  ,
                    Lead_Medium__c = formSubmissionRecord.Medium__c,
                    Lead_Content__c = formSubmissionRecord.UTM_Content__c,
                    LeadSource = formSubmissionRecord.Source__c,
                    Lead_Matching_Type__c = formSubmissionRecord.Lead_Matching_Type__c
                );
                newLead.setOptions(dmlOption);
                leadsTobeCreated.add(newLead);
            }
        }     
        
        Database.SaveResult[] results =  Database.insert(leadsTobeCreated, false);
        String previousRecordId = '';
        Integer f = 0;
        //As the order As order of leads created/errored is same as order of wrappers cobined in all form submission, we are leveraging that (i.e 'i')
        //Separate index variable('f') is used to get record from Form submission list to avoid skipping of any form submission record.
        for(Integer i = 0; i< results.size();){            
            Form_Submission__c formSubmissionRecord = formSubmissionIdIdToFSRecordMap.get(formSubmissionIdList[f]);
            Lead leadRecord = leadsTobeCreated[i];
            system.debug('263 create success for lead: ' + leadRecord.id);
            List<AccountContactMatch.RecordInfoWrapper> wrapperList = formSubmissionIdToWrapperListMapForLeadCreation.get(formSubmissionRecord.Id);
            for(Integer j = 0; j < wrapperList.size();j++){   
                if(results[i].isSuccess()){
                    formSubmissionRecord.put(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LEAD + wrapperList[j].order + SFMC_Constants.API_FIELDNAME_SUFFIX, leadsTobeCreated[i].id);
                    system.debug('formSubmissionRecord.Id : ' + formSubmissionRecord.Id);
                    if(formSubmissionRecordsToBeUpdated.size() == 0){
                        formSubmissionRecordsToBeUpdated.add(formSubmissionRecord);   
                        previousRecordId = formSubmissionRecord.Id;
                    }
                    else if(!previousRecordId.equals((String)formSubmissionRecord.Id)){
                        formSubmissionRecordsToBeUpdated.add(formSubmissionRecord);
                    }
                    system.debug('263 formSubmissionRecord 4m create: ' + formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LEAD + wrapperList[j].order + SFMC_Constants.API_FIELDNAME_SUFFIX));
                }
                else{                
                    String errorMessage = '';
                    for(Database.Error error : results[i].getErrors()){
                        errorMessage += error.getMessage() +'\n';
                    }
                    formSubmissionRecord.Error_Message__c += '\nFor Lead  : ' + leadsTobeCreated[i].firstName + ' ' + leadsTobeCreated[i].lastname + ': \n' + errorMessage;
                    formSubmissionRecordsToBeUpdated.add(formSubmissionRecord);
                    system.debug('263 create fail for lead: ' + leadsTobeCreated[i].firstname + leadsTobeCreated[i].lastname );
                }
                i++;
            }
            f++;
        }
        
        system.debug('formSubmissionRecordsToBeUpdated : ' + formSubmissionRecordsToBeUpdated);
        return formSubmissionRecordsToBeUpdated;
    }
    
    /*
     * Created By: Sarang D
     * Purpose:    SMCI  - 263: To create as many leads as there are referrals in the submitted form, when form submission type is 'Referral'.
     * Returns:    List of lead record instances to be inserted as a part of lead gen process.
    */
    private static List<Form_Submission__c> updateReferralLeads(Map<Id, List<AccountContactMatch.RecordInfoWrapper>> formSubmissionIdToWrapperListMapForLeadUpdate,List<Form_Submission__c> referralTypeFormSubmissionList, Map<Id, Campaign> campignIdToRecordMap){
        Map<id, Form_Submission__c> leadIdToFSMap = new Map<id, Form_Submission__c>();
        Map<id, List<Lead>> accountToOpenLeadsListMap = new Map<id, List<Lead>>();
        List<Lead> leadsTobeUpdated = new List<Lead>();
        Set<Id> accountIdSetForLead = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, Form_Submission__c> formSubmissionIdToRecordsToBeUpdatedMap = new Map<Id, Form_Submission__c>();
        Map<Id, List<Lead>> formSubmissionIdToLeadListMap = new Map<Id, List<Lead>>();
            
        for(Form_Submission__c formSubmission : referralTypeFormSubmissionList){
            for(AccountContactMatch.RecordInfoWrapper wrapper : formSubmissionIdToWrapperListMapForLeadUpdate.get(formSubmission.id)){
                accountIdSetForLead.add(wrapper.AccountId);
            }
        }        
        
        List<String> marketingLeadTypesToBeExcluded = new List<String>{SFMC_Constants.MLT_EVENT, SFMC_Constants.MLT_AUTO_RENEW};
        List<Lead> leadListToBeUpdated = [SELECT Account__c, Contact__c, CreatedDate, Lead_Origin__c, Status, Last_Engagement_Activity_Date__c,Phone,Email,RDC_Contact_Type__c,Contact_Method__c,
                                          Referral__c, Referral_Status__c, Referring_Agent_Email__c, Referring_Agent_Name__c, Referring_Agent_Phone__c,
                                          Business_Unit__c, Product_Type__c, Link_Campaign__c, Recent_Campaign__c
                                          FROM Lead
                                          WHERE Account__c IN : accountIdSetForLead 
                                          AND Status IN :SFMC_Constants.LEAD_OPEN_STATUSES
                              			  AND Marketing_Lead_Type__c NOT IN: marketingLeadTypesToBeExcluded
                                          AND RecordType.Name=:SFMC_Constants.LEAD_RECORD_TYPE_RDC];
        for(Lead leadRecord : leadListToBeUpdated){
            if(accountToOpenLeadsListMap.containsKey(leadRecord.Account__c)){
                accountToOpenLeadsListMap.get(leadRecord.Account__c).add(leadRecord);
            }
            else{
                accountToOpenLeadsListMap.put(leadRecord.Account__c, new List<Lead>{leadRecord});    
            }
        }
        
        for(Form_Submission__c formSubmission : referralTypeFormSubmissionList){
            for(AccountContactMatch.RecordInfoWrapper wrapper : formSubmissionIdToWrapperListMapForLeadUpdate.get(formSubmission.id)){
                if(formSubmissionIdToLeadListMap.containsKey(formSubmission.id)){
                    formSubmissionIdToLeadListMap.get(formSubmission.id).addAll(accountToOpenLeadsListMap.get(wrapper.AccountId));
                }
                else{
                    formSubmissionIdToLeadListMap.put(formSubmission.id, accountToOpenLeadsListMap.get(wrapper.AccountId));
                }
            }
        }
        
        //Fetching lead assignment rule and setting DML Option with the same. To be used to set options for leads that are getting created.
        AssignmentRule leadAssignMentRule = [select id from AssignmentRule where SobjectType = 'Lead'and Active = true limit 1];
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.assignmentRuleHeader.assignmentRuleId= leadAssignMentRule.id;
        
        for(Form_Submission__c formSubmission : referralTypeFormSubmissionList){
            if(formSubmissionIdToLeadListMap.get(formSubmission.Id) != null){
                for(Lead leadToUpdate : formSubmissionIdToLeadListMap.get(formSubmission.Id)){
                    if(!leadIdSet.contains(leadToUpdate.Id)){
                        String campaignName = '';
                        if(String.isNotBlank(formSubmission.Campaign_Id__c) && campignIdToRecordMap.get(formSubmission.Campaign_Id__c) != null){
                            campaignName = campignIdToRecordMap.get(formSubmission.Campaign_Id__c).name;
                        }
                        leadIdSet.add(leadToUpdate.Id);
                        leadToUpdate.Business_Unit__c = formSubmission.Business_Unit__c;
                        leadToUpdate.Product_Type__c = formSubmission.Product_Type__c;
                        leadToUpdate.Link_Campaign__c = formSubmission.Campaign_Id__c;
                        //leadToUpdate.Recent_Campaign__c = formSubmission.Campaign_Id__c;
                        leadToUpdate.Recent_Campaign__c = campaignName;
                        leadToUpdate.Recent_Campaign_Id__c = formSubmission.Campaign_Id__c;
                        leadToUpdate.Lead_Origin__c = SFMC_Constants.LEAD_ORIGIN_MARKETING_REFERRAL;
                        leadToUpdate.Referral__c = true;
                        leadToUpdate.Referring_Agent_Email__c = String.isBlank(leadToUpdate.Referring_Agent_Email__c) ? formSubmission.Email__c : leadToUpdate.Referring_Agent_Email__c;
                        leadToUpdate.Referring_Agent_Name__c = String.isBlank(leadToUpdate.Referring_Agent_Name__c) ? formSubmission.First_Name__c + ' ' + formSubmission.Last_Name__c : leadToUpdate.Referring_Agent_Name__c;
                        leadToUpdate.Referring_Agent_Phone__c = String.isBlank(leadToUpdate.Referring_Agent_Phone__c) ? formSubmission.Phone__c : leadToUpdate.Referring_Agent_Phone__c;
                        leadToUpdate.Lead_Matching_Type__c = formSubmission.Lead_Matching_Type__c;
                        //JIRA - SMCI 1012
                        leadToUpdate.Lead_Medium__c = formSubmission.Medium__c;
                        leadToUpdate.LeadSource = formSubmission.Source__c;
                        leadToUpdate.Lead_Content__c = formSubmission.UTM_Content__c;
                        //JIRA - SMCI 1012
                        leadIdToFSMap.put(leadToUpdate.id, formSubmission);
                        leadToUpdate.setOptions(dmlOption);
                        leadsTobeUpdated.add(leadToUpdate);   
                    }
                }
            }
        }        
        
        Database.SaveResult[] results =  Database.update(leadsTobeUpdated, false);
        for(Integer i= 0 ; i<results.size() ; i++){
            Id leadId = leadsTobeUpdated[i].Id;
            Form_Submission__c formSubmissionRecord = leadIdToFSMap.get(leadId);
            if(results[i].isSuccess()){
                for(AccountContactMatch.RecordInfoWrapper wrapper : formSubmissionIdToWrapperListMapForLeadUpdate.get(formSubmissionRecord.Id)){
                    if(wrapper.AccountId.equals(leadsTobeUpdated[i].Account__c)){
                        String existingLeadId = (String)formSubmissionRecord.get(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LEAD + wrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX);
                        if(String.isNotBlank(existingLeadId) && !existingLeadId.equals(leadId)){
                            formSubmissionRecord.put(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LEAD + wrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX, leadId);
                        }
                        else{
                            formSubmissionRecord.put(SFMC_Constants.FRIEND_TYPE_FIELDS_PREFIX_LEAD + wrapper.order + SFMC_Constants.API_FIELDNAME_SUFFIX, leadId);    
                        }
                        formSubmissionIdToRecordsToBeUpdatedMap.put(formSubmissionRecord.Id, formSubmissionRecord);    
                    }
                }
            }
            else{
                String errorMessage = '';
                for(Database.Error error : results[i].getErrors()){
                    errorMessage += error.getMessage() +'\n';
                }
                formSubmissionRecord.Error_Message__c += '\nFor Lead Id : ' + leadId + ': \n' + errorMessage;
                formSubmissionIdToRecordsToBeUpdatedMap.put(formSubmissionRecord.Id, formSubmissionRecord);
            }
        }
        return formSubmissionIdToRecordsToBeUpdatedMap.values();
    }
}