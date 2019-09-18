@RestResource(urlMapping='/GetFields/*')
global class UberflipGetFields{
    
    @HttpPost
    global static responseWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200; 
        responseWrapper respBody = getResponse();
        res.responseBody = Blob.valueOf(JSON.serialize(respBody));
        return respBody;
    }
    

    //wrapper class for the response to an API request
    global class responseWrapper{
        global List<field> data {get;set;}
        global responseWrapper(){
            this.data = new List<field>();
        }
    }
    global class field {
        
        global String display_name {get;set;}
        global String html_name {get;set;} 
        global String control_type {get;set;} 
        global Boolean required {get;set;}
        //global Values val {get;set;}
        global Boolean active {get;set;}

        
        //constructor
        global field() {
            //default all values
            this.display_name = '';
            this.html_name = '';
            this.control_type = '';
            this.required = false;
            //this.val = new Values();
            this.active = true;
        }
    }

    

    private static responseWrapper getResponse(){
        responseWrapper response = new responseWrapper();
        response.data.add(getfield(SFMC_Constants.FIRST_NAME_LABEL,SFMC_Constants.FIRST_NAME_APINAME,'text',true,true));
        response.data.add(getfield(SFMC_Constants.LAST_NAME_LABEL,SFMC_Constants.LAST_NAME_APINAME,'text',true,true));
        response.data.add(getfield(SFMC_Constants.EMAIL_LABEL,SFMC_Constants.EMAIL_APINAME,'text',true,true));
        response.data.add(getfield(SFMC_Constants.PHONE_LABEL,SFMC_Constants.PHONE_APINAME,'text',true,true));
        //We won't be tracking cookie information in SFDC as this wont serve any practical purpose
        //response.data.add(getfield(SFMC_Constants.COOKIE_ID_LABEL,SFMC_Constants.COOKIE_ID_APINAME,'text',true,false));
        response.data.add(getfield(SFMC_Constants.CONTACT_METHOD_LABEL,SFMC_Constants.CONTACT_METHOD_APINAME,'text',true,false));
        response.data.add(getfield(SFMC_Constants.CAMPAIGN_ID_LABEL,SFMC_Constants.CAMPAIGN_ID_APINAME,'text',true,false));
        response.data.add(getfield(SFMC_Constants.PRODUCT_TYPE_LABEL,SFMC_Constants.PRODUCT_TYPE_APINAME,'text',true,false));

       response.data.add(getfield(SFMC_Constants.ACCOUNT_ID_LABEL,SFMC_Constants.ACCOUNT_ID_APINAME,'text',true,false));
       response.data.add(getfield(SFMC_Constants.UTM_MEDIUM_LABEL,SFMC_Constants.UTM_MEDIUM_APINAME,'text',true,false));
       response.data.add(getfield(SFMC_Constants.UTM_SOURCE_LABEL,SFMC_Constants.UTM_SOURCE_APINAME,'text',true,false));
       response.data.add(getfield(SFMC_Constants.UTM_CONTENT_LABEL,SFMC_Constants.UTM_CONTENT_APINAME,'text',true,false));
       response.data.add(getfield(SFMC_Constants.LEAD_ORIGIN_LABEL,SFMC_Constants.LEAD_ORIGIN_APINAME,'text',true,false));
       response.data.add(getfield(SFMC_Constants.BUSINESS_UNIT_LABEL,SFMC_Constants.BUSINESS_UNIT_APINAME,'text',true,false));

        return response;
    }


    private static field getfield(String display_name,String html_name,String control_type,Boolean required,Boolean active){
        field dt = new field();
        dt.display_name = display_name;
        dt.html_name = html_name;
        dt.control_type = control_type;
        dt.required = required;
        //this.val = vals;
        dt.active = active;
        return dt;
    }
    

    
    

}