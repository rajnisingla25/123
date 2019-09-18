@RestResource(urlMapping='/checkChallenge/*')
global with sharing class SFMC_FBLeadgen implements Database.AllowsCallouts{
    
    public static final String JSON_LABEL_ENTRY = 'entry';
    public static final String JSON_LABEL_CHANGES = 'changes';
    public static final String JSON_LABEL_VALUE = 'value';
    public static final String JSON_LABEL_LEADGENID = 'leadgen_id';
    
    public static final String SPL_CHAR_QUESTION_MARK = '?';
    public static final String SPL_CHAR_AMPERSAND = '&';
    public static final String SPL_CHAR_EQUAL = '=';
    public static final String SPL_CHAR_SLASH = '/';
    
    
    global class JSONResult {
        global Map<String,String> nameValuePairs = new Map<String,String>();
    }
    
    @HttpPost
    global static void doPost(){

        try {
            System.debug('>>>'+RestContext.request.requestBody.toString());            
            //CreateLead('FB102', 'Lead1', 'New', '0013C00000BLmKCQA1', '0033C000008UuWZQA0', 'Facebook', true, RestContext.request.requestBody.toString());
            Map<String,FBLeadGen_setting__c> fbMap = FBLeadGen_setting__c.getAll();
            FBLeadGen_setting__c fbSetting = fbMap.get('Base setting');
            
            String jsonStr = RestContext.request.requestBody.toString();
            jsonStr = jsonStr.replace('"time":', '"time_x":');

            Map<String,String> leadgenIdPageIdMap = new Map<String,String>();

            WebhookRequest wbReq = (WebhookRequest)JSON.deserialize(jsonStr, WebhookRequest.class);

            for(Entries ent:wbReq.entry){
                for(Change chg:ent.changes){
                    if(chg.value.leadgen_id!=null){
                        leadgenIdPageIdMap.put(chg.value.leadgen_id,chg.value.page_id);
                    }
                    //leadgenidList.add(chg.value.leadgen_id);
                }
            }



            String endpoint = '';
            List<FBLeadResponse> fbRespList = new List<FBLeadResponse>();
            List<Error__c> fbErrorList = new List<Error__c>();
            if(leadgenIdPageIdMap.size()<=100){
                for(String lGenId:leadgenIdPageIdMap.keySet()){
                    String pageId = leadgenIdPageIdMap.get(lGenId);
                    endpoint = SFMC_Constants.FB_GRAPH_URL+fbSetting.FB_API_version__c+SPL_CHAR_SLASH+lGenId;
                    FBLeadGen_setting__c pageAccessToken = FBLeadGen_setting__c.getValues(pageId);
                    String authorisationString = 'Bearer '+ pageAccessToken.Access_Token__c;
                    //public static HttpResponse makeHttpCallout(String method, String contentType,String endPoint, String requestBody, String authorisation)
                    HttpResponse fbResponse = null;
                    if(Test.isRunningTest()){
                        fbResponse = new HttpResponse();
                        fbResponse.setStatusCode(200);
                        Campaign camp = [select id from campaign where name = 'Test Campaign' limit 1];
                        fbResponse.setBody('{"created_time":"2019-03-29T23:35:31+0000","id":"2266732930043740","field_data":[{"name":"utm_campaign_id","values":["' + camp.id + '"]},{"name":"email","values":["aparna\u0040comitydesigns.com"]},{"name":"first_name","values":["Aparna"]},{"name":"last_name","values":["Shankar"]},{"name":"phone_number","values":["+13127308283"]},{"name":"utm_content","values":["Paid Ads"]},{"name":"utm_medium","values":["Paid Ads"]},{"name":"utm_source","values":["Facebook"]},{"name":"business_unit","values":["RDC"]},{"name":"lead_origin","values":["Paid Ads"]},{"name":"id","values":["F43FDE3212ZZX0991"]}]}');
                    }else{
                        fbResponse = SFMC_Utility.makeHttpCallout('GET', 'application/json', endpoint, '', authorisationString);
                    }
                    
                    if (fbResponse.getStatusCode() == 200) {
                        FBLeadResponse fBLeadResponse = (FBLeadResponse)JSON.deserialize(fbResponse.getBody(), FBLeadResponse.class);
                        fbRespList.add(fBLeadResponse);
                    }else{
                       Error__c logError = new Error__c(Entity_Id__c ='FB POC',
                                                 Interface_Name__c = 'SFMC_FBLeadGenPOC',
                                                 Error_Description__c = fbResponse.toString()); 
                       fbErrorList.add(logError);
                    }

                }
            }

            if(fbRespList.size()>0){
                createFormSubmissionFromResponse(fbRespList);
            }

            if(fbErrorList.size()>0){
                insert fbErrorList;
            }

        }
        catch (Exception e) {
            system.debug('In error'+e.getMessage());
        }
    }

    public static void createFormSubmissionFromResponse(List<FBLeadResponse> respList){
        List<Form_Submission__c> fsList = new List<Form_Submission__c>();
        for(FBLeadResponse fBLeadResponse:respList){
            Form_Submission__c formSubmissionRecord = new Form_Submission__c();
            formSubmissionRecord.UTM_Content__c = SFMC_Constants.PAID_ADS;
            formSubmissionRecord.Medium__c = SFMC_Constants.PAID_ADS;
            formSubmissionRecord.Source__c = SFMC_Constants.FACEBOOK;
            formSubmissionRecord.Form_Type__c = SFMC_Constants.FORM_TYPE_FACEBOOK;
            formSubmissionRecord.Facebook_Lead_ID__c = String.valueof(fBLeadResponse.id);
            for(Field_data data : fBLeadResponse.field_data){
                system.debug('data.name : ' + data.name);
                if(data.name.equals(SFMC_Constants.FB_JSON_CAMPAIGN_ID)){
                    formSubmissionRecord.Campaign_Id__c = data.values[0];
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_EMAIL)){
                    formSubmissionRecord.Email__c = data.values[0];
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_FIRST_NAME)){
                    formSubmissionRecord.First_Name__c = data.values[0];
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_LAST_NAME)){
                    formSubmissionRecord.Last_Name__c = data.values[0];
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_PHONE_NUMBER)){
                    formSubmissionRecord.Phone__c = SFMC_Utility.getStringFromFormatedPhone(data.values[0]);
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_PRODUCT_TYPE)){
                    formSubmissionRecord.Product_Type__c = data.values[0];
                }
                if(data.name.equals(SFMC_Constants.FB_JSON_BUSINESS_UNIT)){
                    formSubmissionRecord.Business_Unit__c = data.values[0];
                }
                formSubmissionRecord.Lead_Origin__c = SFMC_Constants.PAID_ADS;
            }
            /*
            Added by: Sarang D
            Description:    If product type is not passed as parameter, fetch the product type of related campaign(if campaign ID value is pressent).
            */
            if(formSubmissionRecord.Campaign_Id__c != null && String.isBlank(formSubmissionRecord.Product_Type__c) && SFMC_Utility.isValid(formSubmissionRecord.Campaign_Id__c, Campaign.sobjecttype)){
                List<Campaign> campaignList = [select Target_Product__c from Campaign where id =: formSubmissionRecord.Campaign_Id__c];
                if(campaignList.size() > 0 ){
            		formSubmissionRecord.Product_Type__c = campaignList[0].Target_Product__c;  
            	}
                else{
                    formSubmissionRecord.Error_Message__c = 'No campaign with id : ' + formSubmissionRecord.Campaign_Id__c + ' found';
                }
            }
            fsList.add(formSubmissionRecord);
        }
        
        Database.SaveResult[] results = Database.insert(fsList,false);
        SFMC_Utility.recordDatabaseErrors(results,'FB POC','SFMC_FBLeadGenPOC');
    }
    
    /*
     * Created by: Sarang D
     * Description : This method is used for subscribing this webhook as receiver of leadgen data.
     * This is done by verifying the verify token provided in Facebook webhook setup page and returning back the challenge sent by Facebook.
    */
    @HttpGet
    global static Integer verifyFBTokenAndReturnChallenge()
    { 
        try {
            Map<String,FBLeadGen_setting__c> fbMap = FBLeadGen_setting__c.getAll();
            FBLeadGen_setting__c fbSetting = fbMap.get('Base setting');
            if(RestContext.request.params.get('hub.verify_token').equals(fbSetting.Webhook_verify_token__c)){
                return Integer.valueOf(RestContext.request.params.get('hub.challenge'));    
            }
            else{
                return 401;
            }
        }
        catch (Exception e) {
            return null;
        }
    }
    
    public class Values{
        public Long created_time{get;set;}
        public String page_id{get;set;}
        public String form_id{get;set;}
        public String leadgen_id{get;set;}
    }
    
    public class Change{
        public String field{get;set;}
        public Values value{get;set;}
    }
    
    public class Entries{
        public List<Change> changes{get;set;}
        public String id{get;set;}
        public Long time_x{get;set;} 
    }
    
    public class WebhookRequest{
        public List<entries> entry{get;set;}
    }
    

    public class FBLeadResponse {
        public String created_time;
        public Long id;
        public List<Field_data> field_data;
    }
    
    public class Field_data {
        public String name;
        public List<String> values;
    }
}