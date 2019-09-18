public with sharing class CalloutTestController {
public String endpoint { get; set;}
  public Boolean basicAuth {get;set;}
  public String uname {get; set;}
  public String pwd {get;set;}
  public String reqType {get;set;}
  public String contentType {get;set;}
  public String reqBody {get;set;}
  public Boolean utf8Encode {get;set;}
  public String urlParm {get;set;}
  public String reqHeaders {get; set;}
  public String result { get; set;}
  public String requestBody { get; set;}
  public String resBody {get;set;}
  public String responseTime { get; set; }
  public Boolean showResults { get; set;}
   
  public CalloutTestController(){
    endpoint = 'http://www.realtor5.com';
    showResults = false;
  }
  
  public PageReference callout() {
    if (endpoint == null || endpoint == '' ) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'You must set an endpoint!')); 
      return null;
    } else if (reqType==null) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'You must choose POST, GET or PUT!')); 
      return null;
    } else if ((reqType == 'POST' || reqType == 'PUT') && contentType == null) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'For POST or PUT you must select a Content Type!'));
      return null;
    }
    showResults = true;
    Long lResponseTime = System.currentTimeMillis();
    try {
      HttpRequest req = new HttpRequest(); 
      req.setEndpoint(endpoint);
      req.setMethod(reqType);  
      if (reqType == 'POST' || reqType == 'PUT') {
        req.setHeader('Content-Type', contentType); 
        req.setBody(reqBody);
        reqHeaders = 'Content-Type: ' + req.getHeader('Content-Type') + '; ';
      } else {
        if (urlParm != null && urlParm != '') {
          string parms = '?' + urlParm;
          if (utf8Encode)
            parms = EncodingUtil.urlEncode(urlParm, 'UTF-8');
          req.setEndpoint(endpoint + parms);
        }
      }
      if (basicAuth) {
        Blob headerValue = Blob.valueOf(uname + ':' + pwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        reqHeaders += 'Authorization: ' + req.getHeader('Authorization') + '; ';  
      }
      //req.setCompressed(true); // set this if hitting 3mb request limit
      requestBody = req.getBody();
      Http h = new Http();
      if (!test.isRunningTest()) {
        HttpResponse res = h.send(req);
        result = res.toString();
        resBody = res.getBody();            
      }
    } catch (Exception e) {
      result = e.getMessage();
    }
    lResponseTime = System.currentTimeMillis() - lresponseTime;
    responseTime = String.valueOf(lResponseTime)+ ' ms';
    return null;
  }

  public List<SelectOption> getreqTypeLst() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('POST','POST'));
    options.add(new SelectOption('GET','GET'));
    options.add(new SelectOption('PUT','PUT'));
    return options;
  }
  
  public List<SelectOption> getcontentTypeLst() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('text/xml','text/xml'));
    options.add(new SelectOption('application/json','application/json'));
    return options;
  }
}