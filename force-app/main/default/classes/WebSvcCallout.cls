public with sharing class WebSvcCallout {
    public static String callEchoString(String input) {

        docSample.DocSamplePort sample = new docSample.DocSamplePort();
        //String input = "test";
        sample.endpoint_x = 'http://www.realtor.com';
        //sample.endpoint_x = 'http://206.131.186.15/soa-infra/services/default/TestProject/testprocess1_client_ep';

        // This invokes the EchoString method in the generated class
        //String hi='hi';
        String echo = sample.EchoString(input);
      
        return echo;
    }   

	    
public static void test1() {
    
  HttpRequest req = new HttpRequest(); 
 
  //Set HTTPRequest Method
  req.setMethod('GET');

  //Set HTTPRequest header properties
  //req.setHeader('content-type', 'application/xml');
  req.setHeader('Accept','application/xml');
  req.setHeader('Host','www.move.com');
  //req.setHeader('Connection','keep-alive');
  req.setEndpoint('http://www.realtor.com');
  //req.setHeader('Date',System.getDateString()); 

  //Set the HTTPRequest body	
  req.setBody('nothing'); 	

  Http http = new Http();
  
   try {
 
        //Execute web service call here		
        HTTPResponse res = http.send(req);	

        //Helpful debug messages
        System.debug(res.toString());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
		
} catch(System.CalloutException e) {
	//Exception handling goes here....
}		
}
    
}