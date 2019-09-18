/* ****************
CRM-2781 -- RealSuite Supported MLS

*/
global class BatchProcessMLSAccountRealSuite implements Database.Batchable<sObject>,Database.AllowsCallouts{
String query;
global String MLSName;
String retval;
string retval1;
global Database.querylocator start(Database.BatchableContext BC){
DateTime dt = System.now();
if(MLSName==null){
    Query = 'SELECT Id,name,Supports_Realsuite__c,Customer_Id__c FROM Account WHERE  Type = \'MLS Account\'';
    } else{
    Query = 'SELECT Id,name,Supports_Realsuite__c,Customer_Id__c FROM Account WHERE  Type = \'MLS Account\' and Customer_Id__c=:MLSName limit 1';
    }
    return Database.getQueryLocator(query);
}
global void execute(Database.BatchableContext BC, List<account> scope){
   List<Account> AccountList = new List<Account>();
   String responseString = '';
   for(account acc : scope){
   String endPointUrl=System.Label.MLSRealSuiteURL+''+acc.Customer_Id__c; 
HttpRequest req = new HttpRequest(); 
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    req.setEndpoint(endPointUrl);
req.setMethod('GET');
    req.setHeader('Content-Type', 'application/json'); 
    req.setHeader('Accept', 'application/json');
    
    //req.setHeader('Content-Length', '0'); 
    req.setTimeout(120000);
   // req.setBody(strbody);
    
       
            //res=http.send(req);
            //system.debug(res+'');
            if(!Test.isRunningTest()){
            res=http.send(req);
            system.debug('response####'+res.getBody());
                responseString=res.getBody();
            } else {
            if(Test.isRunningTest()){
                responseString = '[{"Prosoft":{"mls_code":"LVNV","state_abbr":"NV","mls_name":"LasVegas","provider":"Greater Las Vegas Assoc. Of REALTORS®","country":"United States","country_abbr":"US","SoldDataAvailable":"Yes","ActiveDataAvailable":"Yes","DatasourceLevelDisclaimer":"Portions Copyright © 2018 by the MLS, All Rights Reserved."}}]';
                                        }
              }
            system.debug('response####'+res.getBody());
            if(res.getStatusCode()==200 && res.getStatus()=='OK' || Test.isRunningTest()){
                JSONParser parser = JSON.createParser(responseString);
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken(); 
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken(); 
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
parser.nextToken();
while (parser.nextToken() != null) {  
if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                String fieldName = parser.getText();
                system.debug('fieldName >>>>>>>>>>>>'+fieldName );   
               if(parser.getText()=='SoldDataAvailable'){
                   parser.nextToken();
                    retval = parser.getText();
                   }else if(parser.getText()=='ActiveDataAvailable'){
                   parser.nextToken();
                   retval1 = parser.getText();
                  }                     
           }
           }
       }
    acc.Supports_Realsuite__c = false;   
     if(retval == 'Yes' && retval1 == 'Yes'){
                   acc.Supports_Realsuite__c = true;     
                   }
AccountList.add(acc);
   }
   update AccountList ;
}

global void finish(Database.BatchableContext BC){
}
}