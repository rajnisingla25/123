/*
 * Created By:  Sarang Deshpande
 * Purpose:     Top level handler class to redirect the flow of form submission based on conditions and type of trigger operation.
*/
public with sharing class SFMC_FormSubmissionTriggerHandler {
    
    public static boolean fireTrigger = true;
    public static Map<Id, Form_Submission__c> formSubmissionIdToReferralFormSubmissionMap = new Map<Id, Form_Submission__c>();
    public static Map<Id, Form_Submission__c> formSubmissionIdToFormSubmissionMap = new Map<Id, Form_Submission__c>();
    /*
    Purpose: Call respective Form submission helper i.e. for regular form submission call FormSubmissionHelper and for Referred call SFMC_ReferralFormSubmissionHelper 
    */
    public static void onAfterInsertOrUpdate(Boolean isInsert, Map<Id, Form_Submission__c> triggerNewMap){
        fireTrigger = false;    // we don't want to trigger to fire as we are updating the same records here
        
        Map<Id,Form_Submission__c> formSubmissionMap = new Map<Id,Form_Submission__c>([SELECT Last_Name__c, First_Name__c,  Campaign_Id__c,  Lead__c,  Contact_Method_Id__c,  Contact_Id__c, Phone__c ,  Medium__c, Email__c,Business_Unit__c,Lead_Origin__c,Product_Type__c, Zip_Code__c,RDC_Contact_Type__c,Account_Id__c,Lead_Matching_Type__c, Form_Type__c,
                                                                                       Friend_Last_Name_1__c,Friend_Last_Name_2__c,Friend_Last_Name_3__c,Friend_Last_Name_4__c,Friend_Last_Name_5__c,
                                                                                       Friend_First_Name_1__c,Friend_First_Name_2__c,Friend_First_Name_3__c,Friend_First_Name_4__c,Friend_First_Name_5__c,
                                                                                       Friend_Phone_1__c,Friend_Phone_2__c,Friend_Phone_3__c,Friend_Phone_4__c,Friend_Phone_5__c,
                                                                                       Friend_Email_1__c,Friend_Email_2__c,Friend_Email_3__c,Friend_Email_4__c,Friend_Email_5__c,
                                                                                       Friend_Lead_Id_1__c,Friend_Lead_Id_2__c,Friend_Lead_Id_3__c,Friend_Lead_Id_4__c,Friend_Lead_Id_5__c,
                                                                                       Error_Message__c,Source__c,UTM_Content__c,OwnerId,GCLID__c,Facebook_Lead_ID__c,URL__c
                                                                                       FROM Form_Submission__c
                                                                                       WHERE Id IN : triggerNewMap.keySet()]);
        
        for(Id formSubmissionId : formSubmissionMap.keySet()){
            Form_Submission__c formSubmissionRecord = formSubmissionMap.get(formSubmissionId);
            if(formSubmissionRecord.Form_Type__c.equals(SFMC_Constants.FORM_TYPE_REFERRAL)){
                formSubmissionIdToReferralFormSubmissionMap.put(formSubmissionId, formSubmissionRecord);
            }
            else{
                formSubmissionIdToFormSubmissionMap.put(formSubmissionId, formSubmissionRecord);
            }
        }
        SFMC_FormSubmissionHelper.processFormSubmissionData(formSubmissionIdToFormSubmissionMap);
        SFMC_ReferralFormSubmissionHelper.processReferralFormSubmissionData(formSubmissionIdToReferralFormSubmissionMap);
        if(Trigger.isInsert){
            system.debug('Before Eng act: ' + formSubmissionIdToFormSubmissionMap);
            SFMC_FormSubmissionHelper.createEngagementActivities(formSubmissionIdToFormSubmissionMap,Trigger.isInsert);
            SFMC_FormSubmissionHelper.updatePreferenceField(triggerNewMap.keyset());
        }
    }
}