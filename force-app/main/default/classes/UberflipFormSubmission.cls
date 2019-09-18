@RestResource(urlMapping='/FormSubmission/*')
global class UberflipFormSubmission {

    public static final String JSON_LABEL_SUBMISSION = 'submission';
    public static final String JSON_LABEL_FIELDS = 'fields';
    public static final String JSON_LABEL_URL = 'url';
    
    public static final String SPL_CHAR_QUESTION_MARK = '?';
    public static final String SPL_CHAR_AMPERSAND = '&';
    public static final String SPL_CHAR_EQUAL = '=';
    public static final String SPL_CHAR_EMPTY_STRING = '';

    public static final String FORM_SUBMISSION_API_NAME= 'Form_Submission__c';
 
    @HttpPost
    global static void doPost() {
      RestRequest req = RestContext.request;
      Map<String, Object> body = new Map<String, Object>();
      Map<String, Object> submission = new Map<String, Object>();
      Map<String, Object> fieldsMap = new Map<String, Object>();
      String jsonBody = req.requestBody.toString();
      System.debug('>>>jsonBody>>>'+jsonBody);
      if (!String.isBlank(jsonBody)) { 
        body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        submission = (Map<String, Object>)body.get(JSON_LABEL_SUBMISSION);
        String url = (String)submission.get(JSON_LABEL_URL);
        String queryParams = String.isNotEmpty(url)?url.substringAfter(SPL_CHAR_QUESTION_MARK):SPL_CHAR_EMPTY_STRING;
        Map<String,String> paramsMap = getParamentersMap(queryParams);
        System.debug('>>>paramsMap>>>'+paramsMap);
        fieldsMap = (Map<String, Object>)submission.get(JSON_LABEL_FIELDS);
        System.debug('fieldsMap :'+fieldsMap.keySet());
        Form_Submission__c formSub = createFormSubmission(fieldsMap,url,queryParams);

        try{
            insert formSub;
        }catch(Exception e){
            Form_Submission__c newFS = new Form_Submission__c();
            newFS.First_Name__c = formSub.First_Name__c;
            newFS.Last_Name__c = formSub.Last_Name__c;
            newFS.Error_Message__c = e.getMessage()+'\n JSON REQUEST:'+jsonBody;
            insert newFS;
        }
      }
    }

    public static Form_Submission__c createFormSubmission(Map<String, Object> fields,String link,String qryParams ){
        Form_Submission__c fs = new Form_Submission__c();
        fs.Medium__c = SFMC_Constants.UBERFLIP_DEFAULT;
        fs.Source__c = SFMC_Constants.UBERFLIP_DEFAULT;
        fs.UTM_Content__c = SFMC_Constants.UBERFLIP_DEFAULT;
        fs.Lead_Origin__c = SFMC_Constants.UBERFLIP_DEFAULT;
        if(fields.containsKey(SFMC_Constants.FIRST_NAME_APINAME)){
            fs.First_Name__c = (String)fields.get(SFMC_Constants.FIRST_NAME_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.LAST_NAME_APINAME)){
            fs.Last_Name__c = (String)fields.get(SFMC_Constants.LAST_NAME_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.EMAIL_APINAME)){
            fs.Email__c = (String)fields.get(SFMC_Constants.EMAIL_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.PHONE_APINAME)){
            fs.Phone__c = (String)fields.get(SFMC_Constants.PHONE_APINAME);
        }
        
        if(fields.containsKey(SFMC_Constants.CAMPAIGN_ID_APINAME)){
            fs.Campaign_Id__c = (String)fields.get(SFMC_Constants.CAMPAIGN_ID_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.CONTACT_METHOD_APINAME)){
            fs.Contact_Method_Id__c = (String)fields.get(SFMC_Constants.CONTACT_METHOD_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.ACCOUNT_ID_APINAME)){
            fs.Account_Id__c = (String)fields.get(SFMC_Constants.ACCOUNT_ID_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.UTM_MEDIUM_APINAME)){
            fs.Medium__c = (String)fields.get(SFMC_Constants.UTM_MEDIUM_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.UTM_SOURCE_APINAME)){
            fs.Source__c = (String)fields.get(SFMC_Constants.UTM_SOURCE_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.UTM_CONTENT_APINAME)){
            fs.UTM_Content__c = (String)fields.get(SFMC_Constants.UTM_CONTENT_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.LEAD_ORIGIN_APINAME)){
            fs.Lead_Origin__c = (String)fields.get(SFMC_Constants.LEAD_ORIGIN_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.BUSINESS_UNIT_APINAME)){
            fs.Business_Unit__c = (String)fields.get(SFMC_Constants.BUSINESS_UNIT_APINAME);
        }
        if(fields.containsKey(SFMC_Constants.PRODUCT_TYPE_APINAME)){
            fs.Product_Type__c = (String)fields.get(SFMC_Constants.PRODUCT_TYPE_APINAME);
        }
        if(String.isNotEmpty(link)){
            fs.URL__c = link;
        }
        if(qryParams.length()>0){
            fs.Query_String_Parameters__c = qryParams;
        }
        fs.Form_Type__c = SFMC_Constants.UBERFLIP_FORM;
        /*If Product type is not set from URL, populate Product type value based on campaign's product type value , if not null there as well.*/
        if(String.isBlank(fs.Product_Type__c) && fs.Campaign_Id__c != null && SFMC_Utility.isValid(fs.Campaign_Id__c, Campaign.sobjecttype)){
            List<Campaign> campaignList = [select Target_Product__c from Campaign where id =: fs.Campaign_Id__c];
            if(campaignList.size() > 0){
                fs.Product_Type__c = campaignList[0].Target_Product__c;    
            }
            else{
                    fs.Error_Message__c = 'No campaign with id : ' + fs.Campaign_Id__c + ' found';
                }
        }
        return fs;
    }

    private static Map<String,String> getParamentersMap(String qParams){
        Map<String,String> paramsMap = new Map<String,String>();
        if(String.isNotEmpty(qParams)){
            List<String> paramList = qParams.split(SPL_CHAR_AMPERSAND);
            for(String p:paramList){
                List<String> pkv = p.split(SPL_CHAR_EQUAL);
                if(pkv.size()==2)
                    paramsMap.put(pkv.get(0), pkv.get(1));
            }
        }
        return paramsMap;
    }
//Add try catch block to to capture errors in the form submissions.
 
}