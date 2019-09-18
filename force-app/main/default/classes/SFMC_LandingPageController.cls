/*
Class: SFMC_LandingPageController.
Purpose: Landing page controller method.
Created by: Sarang
Created date : 12/31/2018
*/
public with sharing class SFMC_LandingPageController {
    
    //set picklist values on landing page and set default values
    @AuraEnabled
        public static Map<String, String> getPicklistValues(Id cmId){
        Map<String, Landing_Page_Parameters__c> settingMap = Landing_Page_Parameters__c.getAll();
        Map<String, Business_Unit_From_Domain__c> businessUnitMap = Business_Unit_From_Domain__c.getAll();
        Map<String, String> picklistLabelValueMap = new Map<String, String>();


        for(Landing_Page_Parameters__c setting : settingMap.values()){
            picklistLabelValueMap.put(setting.Name, setting.Picklist_Value__c);
            if(setting.Default__c){
                picklistLabelValueMap.put('defaultVal',setting.Picklist_Value__c);
                //picklistLabelValueMap.put(setting.Name,String.valueOf(setting.Sequence__c));
            }
            //picklistLabelValueMap.put(String.valueOf(setting.Sequence__c), setting.Picklist_Value__c);
        }
        for(Business_Unit_From_Domain__c busetting : businessUnitMap.values()){
            picklistLabelValueMap.put(busetting.Community_URL__c, busetting.Business_Unit__c);
        }
        System.debug('picklistLabelValueMap >>'+picklistLabelValueMap);

        
        Id mergeCMId = SFMC_Utility.checkAndGetLatestContactMethodId(cmId);
        if(mergeCMId != null){
            ContactMethod__c objContactMethod = [SELECT Id, Email__c, Contact__r.FirstName, Contact__r.LastName, Phone__c FROM ContactMethod__c WHERE Id =: mergeCMId];
            picklistLabelValueMap.put('Email__c',objContactMethod.Email__c);
            picklistLabelValueMap.put('Phone__c',objContactMethod.Phone__c);
            picklistLabelValueMap.put('First_Name__c',objContactMethod.Contact__r.FirstName);
            picklistLabelValueMap.put('Last_Name__c',objContactMethod.Contact__r.LastName);
        }
        picklistLabelValueMap.put('valuesInSequence', JSON.serialize(getValuesWithSequence()));
        return picklistLabelValueMap;
    }
    
    private static List<String> getValuesWithSequence(){
        Map<String, Landing_Page_Parameters__c> settingMap = Landing_Page_Parameters__c.getAll();
        List<String> valuesInSequenceList = new List<String>();
        Map<Decimal, String> sequenceValueMap = new Map<Decimal, String>();
        List<Decimal> sequencesList = new List<Decimal>();
        for(Landing_Page_Parameters__c setting : settingMap.values()){
            sequencesList.add(setting.Sequence__c);
            sequenceValueMap.put(setting.Sequence__c, setting.Picklist_Value__c);
        }
        sequencesList.sort();
        for(Decimal order : sequencesList){
            valuesInSequenceList.add(sequenceValueMap.get(order));
        }
        return valuesInSequenceList;
    }    

    //Enable or disible popup check
    @AuraEnabled
    public static Boolean enableDisablePopUp(){
        boolean popup = false;
        Landing_Page_Pop_Up_Settings__c popUpSettings = Landing_Page_Pop_Up_Settings__c.getValues('PopUpSettings');
        if(popUpSettings != null){
            popup = popUpSettings.Enable_Pop_Up__c;
        }
        
        return popup;
    }
    //get url parameter values
    @AuraEnabled
    public static String getValueForParam(String urlParamater){
        Landing_Page_Parameters__c setting = Landing_Page_Parameters__c.getValues(urlParamater);
        return (setting == null) ? '' : setting.Picklist_Value__c;
    }
    
    /*
        * created by :  Varun Agarwal
        * Purpose:      Save form submission record with param pass to it.
        * Modified by:  Sarang D, 5/2/2019
        *Description:   Added code to get url parameters related to UTM and populate form submission fields before inserting. Added try catch.
    */
    @AuraEnabled
    public static Form_Submission__c saveFormSubmissionRecord(String urlParam,Form_Submission__c formSubmissionRecord){
        Boolean skipInsertForBots = false;
        //return if nothing to save
        System.debug('formSubmissionRecord >>'+formSubmissionRecord);
        if(formSubmissionRecord == null){
            return null;
        }
        
        System.debug('urlParam >>'+urlParam);
        //add param value to form submission object
        if(urlParam != null){

            formSubmissionRecord.Query_String_Parameters__c = urlParam;
            Map<String,String> urlParamMap = (Map<String,String>)JSON.deserialize(urlParam, Map<String,String>.class);

            String nonLeadSubmission = urlParamMap.get(SFMC_Constants.BOT_FORM_SUBMISSION_PARAM_KEY)!=null?urlParamMap.get(SFMC_Constants.BOT_FORM_SUBMISSION_PARAM_KEY):'';
            skipInsertForBots = nonLeadSubmission.equals(SFMC_Constants.BOT_FORM_SUBMISSION_PARAM_VALUE);

            String contactMethodId = urlParamMap.get(SFMC_Constants.CONTACT_METHOD_ID);
            if(SFMC_Utility.isValid(contactMethodId,ContactMethod__c.sobjecttype)){             
                formSubmissionRecord.Contact_Method_Id__c = contactMethodId; 
                formSubmissionRecord.Submitted_Contact_Method_Id__c = contactMethodId;
                             
            }
            
            String accountId = urlParamMap.get(SFMC_Constants.ACCOUNT_ID);
            if(SFMC_Utility.isValid(accountId,Account.sobjecttype)){
                formSubmissionRecord.Account_Id__c = accountId;
            }
            

            formSubmissionRecord.Medium__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_MEDIUM)) ? SFMC_Constants.ORGANIC : EncodingUtil.urlDecode(urlParamMap.get(SFMC_Constants.UTM_MEDIUM),'UTF-8');		            //formSubmissionRecord.Medium__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_MEDIUM)) ? SFMC_Constants.ORGANIC : urlParamMap.get(SFMC_Constants.UTM_MEDIUM);
            formSubmissionRecord.Source__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_SOURCE)) ? SFMC_Constants.ORGANIC : EncodingUtil.urlDecode(urlParamMap.get(SFMC_Constants.UTM_SOURCE),'UTF-8');		            //formSubmissionRecord.Source__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_SOURCE)) ? SFMC_Constants.ORGANIC : urlParamMap.get(SFMC_Constants.UTM_SOURCE);
            formSubmissionRecord.UTM_Content__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_CONTENT)) ? SFMC_Constants.ORGANIC : EncodingUtil.urlDecode(urlParamMap.get(SFMC_Constants.UTM_CONTENT),'UTF-8');		            //formSubmissionRecord.UTM_Content__c = String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_CONTENT)) ? SFMC_Constants.ORGANIC : urlParamMap.get(SFMC_Constants.UTM_CONTENT);
            //formSubmissionRecord.Product_Type__c = String.isEmpty(urlParamMap.get(SFMC_Constants.PRODUCT_TYPE)) ? null : EncodingUtil.urlDecode(urlParamMap.get(SFMC_Constants.PRODUCT_TYPE),'UTF-8');		            
            formSubmissionRecord.Lead_Origin__c = String.isEmpty(urlParamMap.get(SFMC_Constants.LEAD_ORIGIN)) ? SFMC_Constants.ORGANIC : EncodingUtil.urlDecode(urlParamMap.get(SFMC_Constants.LEAD_ORIGIN),'UTF-8');
            if(!String.isEmpty(urlParamMap.get(SFMC_Constants.UTM_CAMPAIGN_ID))){
                String UTMCampaignId = urlParamMap.get(SFMC_Constants.UTM_CAMPAIGN_ID);
                if(SFMC_Utility.isValid(UTMCampaignId, Campaign.sobjecttype)){
                    formSubmissionRecord.Campaign_Id__c = UTMCampaignId;
                }
            }

            if(!String.isEmpty(urlParamMap.get(SFMC_Constants.GCLID))){
                formSubmissionRecord.GCLID__c = urlParamMap.get(SFMC_Constants.GCLID);
            }

            //If campaign Id is not null and product type is not passed as a parameter, fetch product type related to this campaign and populate Form Submission record.
            if(String.isBlank(formSubmissionRecord.Product_Type__c) && String.isNotBlank(formSubmissionRecord.Campaign_Id__c)){
                List<Campaign> campaignList = [select Target_Product__c from Campaign where id =: formSubmissionRecord.Campaign_Id__c];
                if(campaignList.size() > 0 ){
            		formSubmissionRecord.Product_Type__c = campaignList[0].Target_Product__c;  
            	}
                else{
                    formSubmissionRecord.Error_Message__c = 'No campaign with id : ' + formSubmissionRecord.Campaign_Id__c + ' found';
                }
            }


        }
        try{
            if(!skipInsertForBots){
                insert formSubmissionRecord;   
            }
            return formSubmissionRecord;
        }
        catch(DmlException ex){
            system.debug('Exception stack trace: ' + ex.getStackTraceString());
            system.debug('Exception cause: ' + ex.getCause());
            Error__c logError = new Error__c(Entity_Id__c ='landing page save form submission', Interface_Name__c = 'SFMC_LandingPageController', Error_Description__c = ex.getMessage());
            insert logError;
            return null;
        }
        catch(Exception ex){
            system.debug('Exception stack trace: ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c ='landing page save form submission', Interface_Name__c = 'SFMC_LandingPageController', Error_Description__c = ex.getMessage());
            insert logError;
            return null;
        }
    }
    
    /*
        Created By : Atul Rakate
        Purpose : To update Lead on click of popup
    */
    @AuraEnabled
    public static boolean updateLeadforProdType(Id formSubmissionId, String popupProductType){
        System.debug('formSubmissionId>>>'+formSubmissionId);
        boolean result = false;
        if(formSubmissionId == null || popupProductType == null){  return false;   }
        Form_Submission__c objForm = [SELECT Lead__c FROM Form_Submission__c WHERE Id =: formSubmissionId];
        if(objForm.Lead__c != null){
            String leadId = objForm.Lead__c;
            Lead leadRecord = new Lead(id = objForm.Lead__c, Product_Type__c = popupProductType); 
            update leadRecord;
        }
        return true;
    }
}