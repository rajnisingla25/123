/*
 * Created by:  Sarang Deshpande
 * Description: Helper class to create triggered send requests based on conditions.
 * Created Date: 6/2/2019
*/
public with sharing class SFMC_CaseTriggerHandler{
    
    public static boolean triggeredSendExecutedOnce;  
    public static String jsonRequestStringNVMCountFirst;
    public static String jsonRequestStringNVMCountSecond;
    public static String jsonRequestStringNVMCountThird;
    //Metadata that fetches triggered send settings which are used conditionally for sending respective triggered emails.
    private static Triggered_Send_Setting__mdt setting = [select From_Name__c, From_Address__c, 
                                                          Triggered_send_id_1__c, Triggered_send_id_2__c, Triggered_send_id_3__c,
                                                          SFMC_Client_Secret__c, SFMC_Client_Id__c from Triggered_Send_Setting__mdt
                                                          where DeveloperName =: 'Triggered_Send_Setting' limit 1];
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Method to create triggered send request based on NVM failed count.
        * Created Date: 6/2/2019
    */
    public static void prepareTriggeredSendRequest(Boolean isInsert, Boolean isUpdate, Set<Id> caseIdList, Map<Id, Case> oldCaseMap){
        List<TriggerSendWrapper> triggerSendWrapperListFirst = new List<TriggerSendWrapper>();
        List<TriggerSendWrapper> triggerSendWrapperListSecond = new List<TriggerSendWrapper>();
        List<TriggerSendWrapper> triggerSendWrapperListThird = new List<TriggerSendWrapper>();
        Boolean isNewCaseStatusValid;
        Boolean isNewCaseTypeValid;
        Boolean isNVMFailedCountValid;
        Boolean isValidBillingPref;
        
        Set<String> validStatuses = SFMC_Constants.validCaseStatuses;
        Set<String> validCaseBillingPref = SFMC_Constants.validBillingPref;
        //These are NVM failed count values for a case record, based on which triggered Email would be executed.
        Set<Integer> validNVMFailedCounts = SFMC_Constants.validNVMFailedCounts;
            
        List<Case> caseRecordsList = [select id, status, type, Related_Contact_FirstName__c,Billing_Preference__c, Total_Contract_Value__c,
                                      Related_Contact_LastName__c,NVM_Failed_Call_Count__c,
                                      account.Email_Address__c, account.PrimaryEmail_CMId__c 
                                      from Case
                                      where id in: caseIdList];
                
                for(Case caseRecord : caseRecordsList){ 
                    // Create Request if:
                    // All 3 criteria are met : 1. Status is either(new, inprogress, open) & type= "Collections" & NVM failed count is one of valid counts(6,14,19)
                    // And
                    // its insert OR
                    // its update and any one field(status, type, NVM failed count) is changed.(Status field being changed from any other value than above 3).
                    isNewCaseStatusValid = validStatuses.contains(caseRecord.status);
                    isNewCaseTypeValid = String.isBlank(caseRecord.type) ? false : caseRecord.type.equals(SFMC_Constants.RECORD_TYPE_COLLECTIONS);
                    isNVMFailedCountValid = validNVMFailedCounts.contains(caseRecord.NVM_Failed_Call_Count__c != null ? caseRecord.NVM_Failed_Call_Count__c.intValue() : null);
                    isValidBillingPref = validCaseBillingPref.contains(caseRecord.Billing_Preference__c);
                    
                    if((isNewCaseStatusValid && isNewCaseTypeValid && isNVMFailedCountValid && isValidBillingPref && caseRecord.Total_Contract_Value__c < 30000) &&
                       ((isInsert)
                       ||
                       (isUpdate) &&
                        ((!validStatuses.contains(oldCaseMap.get(caseRecord.Id).status))
                        || (!validCaseBillingPref.contains(oldCaseMap.get(caseRecord.Id).Billing_Preference__c))
                        || ((caseRecord.Total_Contract_Value__c < 30000) && (oldCaseMap.get(caseRecord.Id).Total_Contract_Value__c > 30000))
                        || (!oldCaseMap.get(caseRecord.Id).type.equals(SFMC_Constants.RECORD_TYPE_COLLECTIONS)) 
                        || (caseRecord.NVM_Failed_Call_Count__c != oldCaseMap.get(caseRecord.Id).NVM_Failed_Call_Count__c)))){
                                         if(caseRecord.NVM_Failed_Call_Count__c == SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1){
                                             triggerSendWrapperListFirst.add(createTriggeredSendRequest(caseRecord.id,
                                                                                                         caseRecord.Related_Contact_FirstName__c,
                                                                                                         caseRecord.Related_Contact_LastName__c,
                                                                                                         caseRecord.account.Email_Address__c, 
                                                                                                         caseRecord.account.PrimaryEmail_CMId__c));
                                         }
                                         else if(caseRecord.NVM_Failed_Call_Count__c == SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_2){
                                             triggerSendWrapperListSecond.add(createTriggeredSendRequest(caseRecord.id,
                                                                                                         caseRecord.Related_Contact_FirstName__c,
                                                                                                         caseRecord.Related_Contact_LastName__c,
                                                                                                         caseRecord.account.Email_Address__c, 
                                                                                                         caseRecord.account.PrimaryEmail_CMId__c));
                                         }
                                         else if(caseRecord.NVM_Failed_Call_Count__c == SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_3){
                                             triggerSendWrapperListThird.add(createTriggeredSendRequest(caseRecord.id,
                                                                                                         caseRecord.Related_Contact_FirstName__c,
                                                                                                         caseRecord.Related_Contact_LastName__c,
                                                                                                         caseRecord.account.Email_Address__c, 
                                                                                                         caseRecord.account.PrimaryEmail_CMId__c));
                                         }
                                     }
                }
        //'fromWrapper' is used to avoid usage of SF std. keyword 'FROM' in code. Hence, it is replaced here.
        jsonRequestStringNVMCountFirst = JSON.serialize(triggerSendWrapperListFirst, true).replace('"fromWrapper":', '"From":');
        jsonRequestStringNVMCountSecond = JSON.serialize(triggerSendWrapperListSecond, true).replace('"fromWrapper":', '"From":');
        jsonRequestStringNVMCountThird = JSON.serialize(triggerSendWrapperListThird, true).replace('"fromWrapper":', '"From":');
        system.debug('count 6 request : ' + jsonRequestStringNVMCountFirst);
        system.debug('count 14 request : ' + jsonRequestStringNVMCountSecond);
        system.debug('count 19 request : ' + jsonRequestStringNVMCountThird);
        //Enqueue a queable method to make HTTP POST callout if any one of the request is not empty.
        if(!jsonRequestStringNVMCountFirst.equals('[]') || !jsonRequestStringNVMCountSecond.equals('[]') || !jsonRequestStringNVMCountThird.equals('[]')){
            SFMC_TriggeredSendQueuable updateJob = new SFMC_TriggeredSendQueuable(jsonRequestStringNVMCountFirst, jsonRequestStringNVMCountSecond, jsonRequestStringNVMCountThird, setting);
            ID jobID = System.enqueueJob(updateJob);    
        }
    }
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Creates JSON request based on parameter values passed.
    */
    private static TriggerSendWrapper createTriggeredSendRequest(Id caseId, String relatedContactFirstName, String relatedContactLastName, String primaryEmailOfAccount, String primaryEmailCMID){
       // Below map is created as a wrapper class 'SubscriberAttributes' can't be created with 'SObject', 'Related_Contact_FirstName__c' etc
       // properties as they are the SF keywords and field API names.
        Map<String, String> subscriberAttributesMap = new Map<String, String>{
             SFMC_Constants.SOBJECT_KEYWORD => SFMC_Constants.CASE_KEYWORD,
             'RecordID' => caseId,
              SFMC_Constants.RELATED_CONTACT_FIRSTNAME => relatedContactFirstName,
              SFMC_Constants.RELATED_CONTACT_LASTNAME => relatedContactLastName
        };
                  
        ContactAttributesWrapper contactAttributesWrapper = new ContactAttributesWrapper(subscriberAttributesMap);
        ToWrapper toWrapper = new ToWrapper(primaryEmailOfAccount, primaryEmailCMID, contactAttributesWrapper);
        FromWrapper fromWrapper = new FromWrapper(setting.From_Name__c, setting.From_Address__c);
        TriggerSendWrapper triggerSendWrapper = new TriggerSendWrapper(toWrapper,fromWrapper);
        return triggerSendWrapper;
    }
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Outermost wrapper class for email sends.
        * Created Date: 6/2/2019 
    */
    private class TriggerSendWrapper{
        ToWrapper To;
        FromWrapper fromWrapper;
        TriggerSendWrapper(ToWrapper toWrapper, FromWrapper fromWrapper){
            this.To = toWrapper;
            this.fromWrapper = fromWrapper;
        }
    }
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Wrapper class for 'From' details of REST request. 
        * Created Date: 6/2/2019
    */
    private class FromWrapper{
        String Name;
        String Address;
        FromWrapper(String Name, String Address){
            this.Name = Name; 
            this.Address = Address; 
        }
    }
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Wrapper class for 'To' details of REST request. 
        * Created Date: 6/2/2019
    */
    private class ToWrapper{
        String Address;
        String SubscriberKey;
        ContactAttributesWrapper ContactAttributes;
        ToWrapper( String Address, String SubscriberKey, ContactAttributesWrapper contactAttributesWrapper){
            this.ContactAttributes = contactAttributesWrapper;
            this.SubscriberKey = SubscriberKey;
            this.Address = Address;            
        }
    }
    
    /*
        * Created by:   Sarang Deshpande.
        * Description:  Wrapper class for 'ContactAttributes' details of REST request. 
        * Created Date: 6/2/2019
    */
    private class ContactAttributesWrapper{
        Map<String, String> SubscriberAttributes = new Map<String, String>();
        ContactAttributesWrapper(Map<String, String> SubscriberAttributes){
            this.SubscriberAttributes = SubscriberAttributes;
        }
    }
}