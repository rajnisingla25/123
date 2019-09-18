/*
 * Created by:	Sarang Deshpande
 * Description:	Class that mocks error response for access token.
 * Created Date: 11/2/2019
*/
@isTest 
global class SFMC_TriggeredSendAccessTokenErrorMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"message":"Invalid Request"}');
        response.setStatusCode(400);
        return response; 
    }
}