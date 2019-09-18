/*
 * Created by:  Sarang Deshpande
 * Description: Queuable class invoked from Case trigger through SFMC_CaseTriggerHandler to make triggered send REST API call.
 * Created Date: 8/2/2019
*/
public with sharing class SFMC_TriggeredSendQueuable implements Queueable,Database.AllowsCallouts{

    String jsonRequestString1;
    String jsonRequestString2;
    String jsonRequestString3;
    Triggered_Send_Setting__mdt triggeredSendSetting;
    
    public SFMC_TriggeredSendQueuable(String jsonRequestString1, String jsonRequestString2,String jsonRequestString3, Triggered_Send_Setting__mdt triggeredSendSetting) {
        this.jsonRequestString1 = jsonRequestString1;
        this.jsonRequestString2 = jsonRequestString2;
        this.jsonRequestString3 = jsonRequestString3;
        this.triggeredSendSetting = triggeredSendSetting;
    }
    
    public void execute(QueueableContext context) {
        system.debug('In execute: ' + context.getJobId());
        executeTriggerSend();
    }
    
    /*
     * Created by:  Sarang Deshpande
     * Description: Method to invoke method that will execute triggered Send using HTTP request based on request type.
     * Created Date: 8/2/2019
    */
    public void executeTriggerSend(){
        try{
            String accessKey = getAccessKey(triggeredSendSetting.SFMC_Client_Id__c, triggeredSendSetting.SFMC_Client_Secret__c);
            if(String.isBlank(accessKey)) return;
            if(String.isNotBlank(jsonRequestString1) && !jsonRequestString1.equals('[]')){
                executeTriggeredSendCallout(accessKey,jsonRequestString1, SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1);
            }
            if(String.isNotBlank(jsonRequestString2) && !jsonRequestString2.equals('[]')){
                executeTriggeredSendCallout(accessKey,jsonRequestString2, SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_2);
            }
            if(String.isNotBlank(jsonRequestString3) && !jsonRequestString3.equals('[]')){
                executeTriggeredSendCallout(accessKey,jsonRequestString3, SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_3);
            }
        }
        catch(CalloutException ex){
            system.debug('Callout Exception : ' + ex.getStackTraceString());
            system.debug('Callout message : ' + ex.getMessage());
            Error__c logError = new Error__c(Entity_Id__c ='Case Triggered Send', Interface_Name__c = 'SFMC_TriggeredSendQueuable', Error_Description__c = ex.getMessage());
            insert logError;
        }
        catch(Exception ex){
            system.debug('Exception : ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c ='Case Triggered Send', Interface_Name__c = 'SFMC_TriggeredSendQueuable', Error_Description__c = ex.getMessage());
            insert logError;
        }
    }
    
    /*
     * Created by:  Sarang Deshpande
     * Description: Method to get access key that is used for authorisation.
     * Created Date: 8/2/2019
    */
    public String getAccessKey(String clientId, String clientSecret){
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeStringField('clientId', clientId);
        gen.writeStringField('clientSecret',clientSecret);
        gen.writeEndObject();  
        HTTPResponse res = SFMC_Utility.makeHttpCallout('POST', 'application/json', 'https://auth.exacttargetapis.com/v1/requestToken', gen.getAsString(), '');         
        String accessKey;
        JSONParser parser = JSON.createParser(res.getBody());
        Boolean isError = false;
        String errorCode;
        String errorMessage;
        while (parser.nextToken() != null) {
            if (parser.getText().equals('accessToken')) {
                parser.nextToken();
                accessKey = parser.getText();
                break;
            }
            if(parser.getText().equals('message')){
                isError = true;
                parser.nextToken();
                errorMessage = parser.getText();
            }
            if(parser.getText().equals('errorcode')){
                parser.nextToken();
                errorCode = parser.getText();
            }
        }
        if(isError){
            Error__c logError = new Error__c(Entity_Id__c ='Case Triggered Send: getAccessKey()',
                                                 Interface_Name__c = 'SFMC_TriggeredSendQueuable',
                                                 Error_Description__c =  'Error Message: ' + errorMessage+ 'Error Code: ' + errorCode);
            insert logError;
        }
        system.debug('accessKey : ' + accessKey);
        return accessKey;
    }
    
    /*
     * Created by:  Sarang Deshpande
     * Description: Method to execute triggered Send using HTTP request.
     * Created Date: 8/2/2019
    */
    private void executeTriggeredSendCallout(String accessKey,String jsonRequestBody, Integer failedCount){
        String url;
        Decimal customerKey = (failedCount == SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_1) ? triggeredSendSetting.Triggered_send_id_1__c : (failedCount == SFMC_Constants.NVM_FAILED_COUNT_THRESHOLD_2) ? triggeredSendSetting.Triggered_send_id_2__c : triggeredSendSetting.Triggered_send_id_3__c;
        url = 'https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+customerKey+'/sendBatch'; 
        HTTPResponse res = SFMC_Utility.makeHttpCallout('POST', 'application/json', url, jsonRequestBody, 'Bearer ' + accessKey);
        system.debug('Response body: ' + res.getBody());
        system.debug('Response status: ' + res.getStatus());
        system.debug('Response status code: ' + res.getStatusCode());
        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            System.debug(LoggingLevel.WARN, 'Message definition send API could not forward data to Marketing Cloud: ' + res.toString());
            Error__c logError = new Error__c(Entity_Id__c ='Case Triggered Send', Interface_Name__c = 'SFMC_TriggeredSendQueuable', Error_Description__c = res.toString());
            insert logError;
        }
    }
}