/*
 * Developer:  Sarang D
 * Purpose: Controller for VF page FBPage. Gets FB settings and has remote action methods to get access token.
*/
public with sharing class SFMC_FBPageController {
    
    public static FBLeadGen_setting__c fbSetting = FBLeadGen_setting__c.getValues('Base setting');

    public String userId{get;set;}

    public SFMC_FBPageController(){
        userId = fbSetting.User_Id__c;
    }

    
    
    @RemoteAction
    public static List<String> getFBSetting(){
        List<String> fbSettingsList = new List<String>();
        fbSettingsList.add(fbSetting.FB_SDK_Endpoint__c);
        fbSettingsList.add(fbSetting.App_Id__c);
        fbSettingsList.add(fbSetting.FB_API_version__c);
        return fbSettingsList;
    }
    
    @RemoteAction
    public static void getPermanantAccessToken(String shortLivedAccessToken, String pageId){
        //Call to get long lived access token.
        String endpoint = SFMC_Constants.FB_GRAPH_URL + 'oauth/access_token?client_id='
            + fbSetting.App_Id__c
            + '&client_secret='
            + fbSetting.Client_Secret__c
            + '&grant_type=fb_exchange_token&fb_exchange_token='
            + shortLivedAccessToken;
        HttpResponse LongLivedAccessTokenResponse = null;

        if (Test.isRunningTest()) {
            LongLivedAccessTokenResponse = new HttpResponse();
             //Sample reponse:
            LongLivedAccessTokenResponse.setBody('{"access_token":"EAAL1iFctlEQBAJHcEtG7kgsMVc4jjLusJzePZANhbzbUnFzPUhnLCWinDRxcgyjZBqbotiktHsYxpEZAhwmfDirmABCja27tQ4MYUxzAGWp4yzG2jaNSiRnSBeNBvwubIlkuUkOvlKa07jROX3L3qQVgr2rKIlXivKBvKco0wZDZD","token_type":"bearer"}');
        }else{
            LongLivedAccessTokenResponse = SFMC_Utility.makeHttpCallout('GET', 'application/json', endPoint, '', '');
        }
        
        Map<String,Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(LongLivedAccessTokenResponse.getBody());
        String longLivedAccessToken = (String)responseMap.get('access_token');
        
        //Call to get permanant access token.
        /*Sample response*/
        /* {
           	"data": [
              {
                 "access_token": "EAAL1iFctlEQBABmbodZANGRZAK4eLvXN3HlYE6aEuIl5Rk6btV4zOKHFNrZBsQfQx46fR3zcahxVeqZCBdtpyC2gRQlym8tLn7WhhaKYozAPjPBOMkw3Jl0MnqHiZBTbB6sZCO5uN1VoVuGpVqZBNoRRGyEJULkUP2jGoDxW4VQMgZDZD",
                 "category": "Information Technology Company",
                 "category_list": [
                    {
                       "id": "1130035050388269",
                       "name": "Information Technology Company"
                    }
                 ],
                 "name": "Unofficial-Poc",
                 "id": "609696262789730",
                 "tasks": [
                    "ANALYZE",
                    "ADVERTISE",
                    "MODERATE",
                    "CREATE_CONTENT",
                    "MANAGE"
                 ]
              },
              {
                 "category": "Information Technology Company",
                 "category_list": [
                    {
                       "id": "1130035050388269",
                       "name": "Information Technology Company"
                    }
                 ],
                 "name": "SFDC Services",
                 "id": "2444899372247090",
                 "tasks": [
                    "ANALYZE",
                    "ADVERTISE",
                    "MODERATE",
                    "CREATE_CONTENT",
                    "MANAGE"
                 ]
              }
           ],
           "paging": {
              "cursors": {
                 "before": "NjA5Njk2MjYyNzg5NzMw",
                 "after": "MjQ0NDg5OTM3MjI0NzA5MAZDZD"
              }
           }
        }
		*/
        endpoint = SFMC_Constants.FB_GRAPH_URL + fbSetting.User_Id__c + '/accounts?access_token=' + longLivedAccessToken;
        HttpResponse neverExpireAccessTokenResponse = null;
        if (Test.isRunningTest()) {
            neverExpireAccessTokenResponse = new HttpResponse();
             //Sample reponse:
            neverExpireAccessTokenResponse.setBody('{ "data": [ { "access_token": "EAAL1iFctlEQBABmbodZANGRZAK4eLvXN3HlYE6aEuIl5Rk6btV4zOKHFNrZBsQfQx46fR3zcahxVeqZCBdtpyC2gRQlym8tLn7WhhaKYozAPjPBOMkw3Jl0MnqHiZBTbB6sZCO5uN1VoVuGpVqZBNoRRGyEJULkUP2jGoDxW4VQMgZDZD", "category": "Information Technology Company", "category_list": [ { "id": "1130035050388269", "name": "Information Technology Company" } ], "name": "Unofficial-Poc", "id": "609696262789730", "tasks": [ "ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE" ] }, { "category": "Information Technology Company", "category_list": [ { "id": "1130035050388269", "name": "Information Technology Company" } ], "name": "SFDC Services", "id": "2444899372247090", "tasks": [ "ANALYZE", "ADVERTISE", "MODERATE", "CREATE_CONTENT", "MANAGE" ] } ], "paging": { "cursors": { "before": "NjA5Njk2MjYyNzg5NzMw", "after": "MjQ0NDg5OTM3MjI0NzA5MAZDZD" } } }');
        }else{
            neverExpireAccessTokenResponse = SFMC_Utility.makeHttpCallout('GET', 'application/json', endPoint, '', '');
        }

        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(neverExpireAccessTokenResponse.getBody());
        List<Object> objectArray = (List<Object>)dataMap.get('data');
        List<FBLeadGen_setting__c> fbSettingList = new List<FBLeadGen_setting__c>();
        for(Object obj:objectArray){
        	Map<String, Object> newCast = (Map<String, Object>)obj;
            String tokenValue = (String)newCast.get('access_token');
            if(String.isNotBlank(tokenValue)){
                FBLeadGen_setting__c newSetting;
                if(FBLeadGen_setting__c.getValues(pageId) != null){	//If setting with this pageId already exist, update access token.
                    newSetting = FBLeadGen_setting__c.getValues(pageId);
                    newSetting.Access_Token__c = tokenValue;
                }
                else{
                	newSetting = new FBLeadGen_setting__c(name = pageId, Access_Token__c = tokenValue);    
                }
                fbSettingList.add(newSetting);
                break;    //Breaking loop because one page Id will give access token for that particular page. Hence, no need to iterate over responses from other pages.
        
            }
        }   
        try{
            upsert fbSettingList;    
        }
        catch(Exception ex){
            system.debug('In Error');
            Error__c logError = new Error__c(Entity_Id__c ='FB POC',
                                             Interface_Name__c = 'SFMC_FBPageController',
                                             Error_Description__c =  'Error Message: ' + ex.getMessage()+ 'Error cause: ' + ex.getStackTraceString());
            insert logError;
        }
    }
}