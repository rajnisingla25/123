/*
        Purpose: Class to host static utility methods that can be used in code throught the application.
        Created by: Sarang D
        Created date : 16/1/2018
    */
public with sharing class SFMC_Utility{
    
    /*
        Purpose: Method to return a wrapper of label value pairs for object and fieldname provided.
        Created by: Sarang D
        Created date : 16/1/2018
    */
    public static String getPicklistLabelvalueJSON(String objectName,String fieldName){ 
        
        try{            
            if(String.isNotBlank(objectName) && String.isNotBlank(fieldName)){
                
                Map<String, String> pickListLabelToValueMap= new Map<String, String>();
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);//From the Object Api name retrieving the SObject
                Sobject newSObject = targetType.newSObject();
                Schema.sObjectType sobjectType = newSObject.getSObjectType(); //grab the sobject that was passed
                Schema.DescribeSObjectResult sobjectTypeDescribe = sobjectType.getDescribe(); //describe the sobject
                Map<String, Schema.SObjectField> fieldMap = sobjectTypeDescribe.fields.getMap(); //get a map of fields for the passed sobject
                List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                for (Schema.PicklistEntry pickListValue : pickListValues) { //for all values in the picklist list
                    pickListLabelToValueMap.put(pickListValue.getLabel(), pickListValue.getValue());
                }
                List<PicklistValuesWrapper> picklistWrapperList = new List<PicklistValuesWrapper>();
                for(String fieldLabel : pickListLabelToValueMap.keySet()){
                    PicklistValuesWrapper wrapper = new PicklistValuesWrapper(fieldLabel, pickListLabelToValueMap.get(fieldLabel), false);
                    picklistWrapperList.add(wrapper);
                }
                return JSON.serialize(picklistWrapperList);
            }
            else{
                return '';
            }
        }
        catch(Exception ex){
            system.debug('Stack trace : ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c ='SFMC_Utility', Interface_Name__c = 'SFMC_Utility', Error_Description__c = ex.getMessage());
            insert logError;
            return '';
        }
    }
    
    /*
        Purpose: Method to return a valid id based on sobject type.
        Created by: Varun Agarwal
        Created date : 02/01/2019
    */
    public static Boolean isValid(String stringValue, Schema.SObjectType sObjectType) {
        Id sObjectId;
        if(stringValue InstanceOf Id){
            sObjectId = (Id)stringValue;
        }
        return !(sObjectId==null || sObjectId.getSObjectType() != sObjectType);
    }
    
    /*
        Purpose: Method to check contact method id and if any merging happen then return survivor contact method id.
        Created by: Varun Agarwal
        Created date : 02/06/2019
    */
    public static ID checkAndGetLatestContactMethodId(Id contactMethodID) {
        if(contactMethodID == null){
            return null;
        }
        String survivorContactMethodId;
        List<ContactMethod__c> cmList = [select id from ContactMethod__c where id = : contactMethodID limit 1];
        if(cmList.isEmpty()){
            List<MergeHistory__c> mergeHistoryList = [select id,Victim_Id__c,Survivor_Id__c from MergeHistory__c where Victim_Id__c = : contactMethodID limit 1];
            if(!mergeHistoryList.isEmpty()){
                survivorContactMethodId = mergeHistoryList.get(0).Survivor_Id__c;
            }
        }else{
            survivorContactMethodId = contactMethodID;
        }
        System.debug('-->> survivorContactMethodId = ' + survivorContactMethodId);
        return survivorContactMethodId;
    }
    
    /*
        Purpose: Method to check if any Database errors happen and if then log into error object.
        Created by: Varun Agarwal
        Created date : 02/14/2019
*/
    public static void recordDatabaseErrors(Database.SaveResult[] results,String entityId,String interfaceName){
        List<Error__c> errList = new List<Error__c>();      
        if(results!=null){
            for(Database.SaveResult res : results){
                if(!res.isSuccess()){
                    String errorMessage = '';
                    for(Database.Error error : res.getErrors()){
                        errorMessage += error.getMessage() +'\n';
                    }
                    Error__c e = new Error__c(Entity_Id__c = entityId, Interface_Name__c = interfaceName, Error_Description__c = errorMessage);
                    errList.add(e);
                }
            }
        }
        
        insert errList;

        System.debug(' errList = '+ errList);
    }   
    /*
        Purpose: Generic wrapper class created to return label and value pair for any picklist field.
        Created by: Sarang D
        Created date : 17/1/2018
*/
    public class PicklistValuesWrapper{
        public String label;
        public String value;
        public Boolean isDefault;
        
        public PicklistValuesWrapper(String label,String value, Boolean isDefault){
            this.label = label;
            this.value = value;
            this.isDefault = isDefault;
        }
    }
    
    /*
        Purpose: Generic method to get request parameters, make HTTP callout and send response.
        Created by: Sarang Deshpande
        Created date : 13/02/2019
*/
    public static HttpResponse makeHttpCallout(String method, String contentType,String endPoint, String requestBody, String authorisation){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type', contentType);
        req.setEndpoint(endPoint);
        if(String.isNotBlank(requestBody)){
            req.setBody(requestBody);    
        }
        if(String.isNotBlank(authorisation)){
            req.setHeader('Authorization', authorisation);
        }
        system.debug('req.getHeader : ' + req.getHeader('Authorization'));
        system.debug('req.getBody : ' + req.getBody());
        system.debug('req.toString : ' + req.toString());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res.toString : ' + res.getBody());
        return res;
    }
    
    /*
        Purpose: Generic method to remove phone type field's formatting and return string.
        Created by: Sarang Deshpande
        Created date : 13/02/2019
    */
    public static string getStringFromFormatedPhone(string phone)
    {
        string retPhone = '';
        string strChar;
        for(Integer iCount = 0; iCount < phone.length(); iCount++)
        {
            strChar = phone.subString(iCount, iCount+1);
            system.debug('strChar=='+strChar);
            if(strChar.isNumeric())
                retPhone += strChar;
        }
        
        system.debug('retPhone  =='+retPhone);
        
        if(retPhone.length() > 10)
            retPhone = retPhone.right(10);
        
        return retPhone;
    }
    
    /*
        Purpose: Generic method to get Error object based on parameters sent.
        Created by: Sarang Deshpande
        Created date : 11/04/2019
    */
    public static Error__c addErrorLog(String entity, String interfaceName, String description){
        return new Error__c(Entity_Id__c =entity,
                                                 Interface_Name__c = interfaceName,
                                                 Error_Description__c = description);
    }
    /*
        Purpose: Format Phone Numbers
        Created by: Aparna Shankar
        Created date : 04/30/2019
    */

    public static String getFormattedPhoneNumber(String phone){
        String nondigits = '[^0-9]';
        String formattedPhoneStr = null;
        if(String.isNotBlank(phone)){
            String PhoneDigits = phone.replaceAll(nondigits,'');

            System.debug(PhoneDigits);
            System.debug(PhoneDigits.length());
            // 10 digit: reformat with dashes
            if (PhoneDigits.length() == 10) 
            formattedPhoneStr =  '(' + PhoneDigits.substring(0, 3) + ') ' +PhoneDigits.substring(3,6) + '-' +PhoneDigits.substring(6,10);
            
            // 11 digit: if starts with 1, format as 10 digit 
            if (PhoneDigits.length() == 11) {
                if (PhoneDigits.substring(0,1) == '1') {
                    formattedPhoneStr =   '(' +PhoneDigits.substring(1,4) + ')' +PhoneDigits.substring(4,7) + '-' +PhoneDigits.substring(7,11);
                }
            }

            if(formattedPhoneStr==null)
            formattedPhoneStr = PhoneDigits;
        }

        return formattedPhoneStr;
    }
}