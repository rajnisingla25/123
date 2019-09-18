global class geo_api {

     public String geoJson {get ;set;}
    
    public geo_api()
    {
        String value1 =System.currentPageReference().getParameters().get('input');
        System.debug('welcome to sales froce---- value: ' + value1 );
        geoJson=callHTTPgeo(value1 );
    }
    
    public geo_api(ApexPages.StandardController stdController) 
    {
        String value1 =System.currentPageReference().getParameters().get('input');
        System.debug('welcome to sales froce---- value: ' + value1 );
        geoJson=callHTTPgeo(value1 );
    }
    
    public string callHTTPgeo(String countyValue)
    {
        //if(test.isRunningTest()){return 'Called from Test Class';}
        System.debug('in call Http auto complete');
        HttpRequest request = new HttpRequest();
        Http httpProtocol = new Http();
        countyValue=countyValue.replace(' ', '%20');
       // System.debug('------------- searchValue: ' + searchValue);
        String endpoint ='http://geo.svc.move.com/GeoWcfService/State.svc/Counties/'+countyValue+'?app=RDC&v=1&format=json';
       //http://geo.svc.move.com/GeoWcfService/State.svc/Counties/suggest?input='+countyValue 
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