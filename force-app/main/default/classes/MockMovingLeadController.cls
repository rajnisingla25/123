@isTest
global class MockMovingLeadController  implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Status" : "Success","UsageRecord":[ { "acct": "106465814", "aid": "02iq00000041Do4","batchnumber": "MVNG 2018.03.19.364","qty": "1","rate": "0","name": "1/1/18 to 3/19/18 : 20 Sent - 0 Duplicates - 0 Lead Credits = 20 Billable"},{ "acct": "106465814", "aid": "1111","batchnumber": "MVNG 2018.03.19.364","qty": "1","rate": "0","name": "1/1/18 to 3/19/18 : 20 Sent - 0 Duplicates - 0 Lead Credits = 20 Billable"}]}');
        res.setStatusCode(200);
        return res;
    }

}