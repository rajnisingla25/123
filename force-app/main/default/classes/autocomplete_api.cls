global class autocomplete_api 
{
    public String AutocompleteJson {get ;set;}
    
    public autocomplete_api()
    {
        String value1 =System.currentPageReference().getParameters().get('input');
        System.debug('welcome to sales froce---- value: ' + value1 );
        AutocompleteJson=callHTTPautoComplete(value1 );
    }
    
    public autocomplete_api(ApexPages.StandardController stdController) 
    {
        String value1 =System.currentPageReference().getParameters().get('input');
        System.debug('welcome to sales froce---- value: ' + value1 );
        AutocompleteJson=callHTTPautoComplete(value1 );
    }
    
    public string callHTTPautoComplete(String searchValue)
    {
        //if(test.isRunningTest()){return 'Called from Test Class';}//added by Radhika
        System.debug('in call Http auto complete');
        HttpRequest request = new HttpRequest();
        Http httpProtocol = new Http();
        searchValue=searchValue.replace(' ', '%20');
       // System.debug('------------- searchValue: ' + searchValue);
       
        // CRM-1660 Start - moved hard coded URL to custom setting, and changed the below code accordingly
        //String endpoint ='http://autocomplete.api.move.com/v2/v2.0.8.0-p109/autocomplete/suggest?input='+searchValue;
        Waitlist_Urls__c autocompleteURL = Waitlist_Urls__c.getValues('AWSAutocompleteURL');
        String endpoint = autocompleteURL.URL__c + searchValue;
        // CRM-1660 End
        
        System.debug('--------- endpoint : ' + endpoint );
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        if(test.isRunningTest()){return 'Called from Test Class';}
        HttpResponse response = httpProtocol.send(request);
        System.debug(response.getBody());  
        String  myjson1 = response.getBody();
        System.debug('HTTP Response is ' + myjson1)  ;
        return myjson1;
    }   
}