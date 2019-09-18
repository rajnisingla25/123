/*
    * Created By:   Sarang D(Brillio LLC)
    * Date:         8th April 2017
    * Description:  Trigger helper class to filter out social media type of leads entering salesforce via Social media platforms like LinkedIn
                    and create Form submission records as per the data received. This will further trigger Lead gen process.
                    This functionality was developed because we are not able to get hidden fields from LinkedIn via out of the box integration.
                    Thus, based on mapping from LinkedIn campaignId and SF campaignId, we create new FS record and enter into Lead gen process.
                    Finally, we delete this lead generated due to out of the box integration.
*/
public with sharing class SFMC_LeadTriggerHelper {
    
    public static boolean sfmcLeadTriggerHandlerExecuted = false;
    
    /*
        * Created by: Sarang D
        * Description:  To filter out leads of record type 'Social Media' and lead origin 'LinkedIn'
        * Parameters:   Leads from trigger.new variable.
    */
    public static void filterSocialMediaLeads(List<Lead> insertedLeadsList){
        try{
            sfmcLeadTriggerHandlerExecuted = true;  //To avoid coming into this class due to subsequent lead gen processes that follow.
            List<Lead> socialMediaLeads = new List<Lead>();
            Map<ID,Schema.RecordTypeInfo> recordTypemap = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
            
            for(Lead leadRec : insertedLeadsList){
                system.debug('lead.RecrecordTypeId : ' + leadRec.recordTypeId);
                system.debug('lead.LeadSource : ' + leadRec.LeadSource);
                if(leadRec.recordTypeId != null && 
                   recordTypemap.get(leadRec.recordTypeId).getName().equalsIgnoreCase(SFMC_Constants.LEAD_SOCIAL_MEDIA_RECORD_TYPE) &&
                   leadRec.LeadSource != null &&
                   leadRec.LeadSource.equals(SFMC_Constants.LEAD_SOURCE_LINKEDIN)){
                       socialMediaLeads.add(leadRec);
                   }
            }
            system.Debug('socialMediaLeads.size(): ' + socialMediaLeads.size());
            if(socialMediaLeads.size() > 0){
                createLinkedInFormSubmissionRecord(socialMediaLeads);    
            }
            else{
                system.debug('No social media leads of source linkedIn found.');
            }  
        }
        catch(Exception ex){
            system.debug('Error :: ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c ='Form Submission through linkedIn leads ',
                                             Interface_Name__c = 'SFMC_LeadTriggerHandler',
                                             Error_Description__c = ex.getMessage() + '\n' + ex.getStackTraceString());
            insert logError;
        }
    }
    
    /*
        * Created by: Sarang D
        * Description:  To create Form Submission records based on social media lead data and delete the lead created from out of box integration.
    */
    public static void createLinkedInFormSubmissionRecord(List<Lead> linkedInLeadRecordList){
        List<Form_Submission__c> formSubmissionRecordsList = new List<Form_Submission__c>();
        List<Id> leadIdsToBeDeleted = new List<Id>();
        List<Error__c> errorLogList = new List<Error__c>();
        Set<Id> campaignIdSet = new Set<Id>();
        
        for(Lead leadRecord: linkedInLeadRecordList){
            Form_Submission__c newFormSubmission = new Form_Submission__c();
            newFormSubmission.First_Name__c = leadRecord.firstName;
            newFormSubmission.Last_Name__c = leadRecord.lastName;
            newFormSubmission.Email__c = leadRecord.email;
            newFormSubmission.Phone__c = leadRecord.phone; 
            newFormSubmission.Source__c = leadRecord.LeadSource;
            newFormSubmission.Form_Type__c = SFMC_Constants.FORM_TYPE_LINKEDIN;
            if(String.isNotBlank(leadRecord.Recent_Campaign__c)){
                LinkedIn_Campaign_Mappping__c campaignMap =LinkedIn_Campaign_Mappping__c.getValues(leadRecord.Recent_Campaign__c.substringAfterLast(':'));
                if(campaignMap != null){
                    newFormSubmission.Campaign_Id__c = campaignMap.SF_Campaign_Id__c;
                    campaignIdSet.add(campaignMap.SF_Campaign_Id__c);  
                    newFormSubmission.Business_Unit__c = campaignMap.Business_Unit__c;
                }
            }
            newFormSubmission.Medium__c = SFMC_Constants.PAID_ADS;
            newFormSubmission.Lead_Origin__c = SFMC_Constants.PAID_ADS;
            newFormSubmission.Lead_Matching_Type__c = leadRecord.Lead_Matching_Type__c;
            newFormSubmission.Zip_Code__c = leadRecord.PostalCode;
            newFormSubmission.UTM_Content__c = SFMC_Constants.PAID_ADS;
            formSubmissionRecordsList.add(newFormSubmission);
            leadIdsToBeDeleted.add(leadRecord.id);
        }
        
        /*Updating product type of Form Submission based on Target_Product__c of related campaign.*/
        Map<Id, Campaign> campaignIdToRecordMap = new Map<Id, Campaign>([select id,Target_Product__c from Campaign where id in : campaignIdSet]);
        for(Form_Submission__c formSubmissionRecordToBeUpdated : formSubmissionRecordsList){
            if(formSubmissionRecordToBeUpdated.Campaign_Id__c != null && campaignIdToRecordMap.get(formSubmissionRecordToBeUpdated.Campaign_Id__c) != null){
             formSubmissionRecordToBeUpdated.Product_Type__c = campaignIdToRecordMap.get(formSubmissionRecordToBeUpdated.Campaign_Id__c).Target_Product__c;   
            }
        }
        
        Database.SaveResult[] resultList = Database.insert(formSubmissionRecordsList, false);
        for(Integer i = 0; i < resultList.size() ; i++){
            if(!resultList[i].isSuccess()){
                String errorDescription = '';
                for(Database.Error error : resultList[i].getErrors()) {
                    errorDescription += error.getMessage() + '\n';
                }
                errorLogList.add(SFMC_Utility.addErrorLog(formSubmissionRecordsList[i].Campaign_Id__c,
                                             'SFMC_LeadTriggerHandler',
                                             'Error occurred while Form Submission through linkedIn leads for campaign :Description  \n' + errorDescription
                                            ));
            }
        }
        
        Database.DeleteResult[] deleteResultList = Database.delete(leadIdsToBeDeleted); //Deleting the leads which came in through LinkedIn as their job of form submission record creation is over.
        for(Integer i = 0; i< deleteResultList.size(); i++) {
            if (!deleteResultList[i].isSuccess()) {                
                String errorDescription = '';
                // Operation failed, so get all errors   
                for(Database.Error error : deleteResultList[i].getErrors()) {
                    errorDescription += error.getMessage() + '\n';
                }
                errorLogList.add(SFMC_Utility.addErrorLog(deleteResultList[i].getId(),
                                            'SFMC_LeadTriggerHandler',
                                            'Error while deletion of Social media lead after a form submission record is deleted.\n' + errorDescription));            
            }
        }
        insert errorLogList;        
    } 
}