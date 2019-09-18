/*
 * Created by:  Sarang Deshpande
 * Description: Class that mocks http response for triggered send 'POST' REST request for sms and emails.
 *              Also, mocks response for access token.
 * Created Date: 11/2/2019
*/
@isTest 
global with sharing class SFMC_TriggeredSendCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        if(request.getEndpoint().endsWith('requestToken')){
            system.debug('In access token : ');
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"accessToken": "Zvw8xhEQZFAU0GA4fVPATANX","expiresIn": 3479}');
            response.setStatusCode(200);
        }
        if(request.getEndpoint().endsWith('sendBatch')){
            system.debug('In sendbatch token : ');
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"requestId": "e5313c38-adf4-4fc9-94fe-20304bdb1e3d","batchHasErrors": true,"responses": [{"recipientSendId": "","hasErrors": true,"messages": ["InvalidOrMissingToAddress"]}]}');
            response.setStatusCode(200);
        }       
        return response; 
    }
}