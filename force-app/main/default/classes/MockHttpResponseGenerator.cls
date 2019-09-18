@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
 
global HttpResponse respond(HTTPRequest req) {
   
        HttpResponse res = new HttpResponse();
        res.setBody('<ArrayOfArea xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Area><Id>827704</Id><area>Guam</area><areaTypeID>4</areaTypeID><fips>66</fips><geoArea>1.4778935E+09</geoArea><latCentroid>13.444355</latCentroid><longCentroid>144.7863</longCentroid><maxLat>13.7061787</maxLat><maxLong>145.009171</maxLong><minLat>13.1823349</minLat><minLong>144.563431</minLong><stateId>GU</stateId></Area></ArrayOfArea>');
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setStatusCode(200);
        return res;    
}
}