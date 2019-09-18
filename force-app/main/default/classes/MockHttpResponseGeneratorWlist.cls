@isTest
global class MockHttpResponseGeneratorWlist implements HttpCalloutMock {
 
global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        //String json = '{"waitlist_type":"Pre-Auth","waitlist_status":"Pending Pre-Auth","waitlist_slot":"Any","total_available_flex":null,"total_available_fast":null,"state":"CA","remnant_spend":"10","quantity":100,"promo_expiration_date":null,"promo":null,"product_type":"Connection for Co-Brokerage","pricing_tier":null,"presales_available_flex":null,"presales_available_fast":null,"presales_available_date":null,"pre_auth_status":null,"pre_auth_expiry_date":null,"phone":null,"party_id":"139224196","owner_name":"HRIGGIO","original_max_spend":"10","market_type":"Postal Code","market_name":"95665","lead_routing":"Any","last_worked_date":null,"inventory_available_flex":null,"inventory_available_fast":null,"customer_id":null,"current_utilized_spend":null,"created_by":null,"comment":null,"bob_territory":null,"account_sub_type":"Customer","account_name":"A  A Realty -  Broker"}';
        //res.setBody('<ArrayOfArea xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Area><Id>827704</Id><area>Guam</area><areaTypeID>4</areaTypeID><fips>66</fips><geoArea>1.4778935E+09</geoArea><latCentroid>13.444355</latCentroid><longCentroid>144.7863</longCentroid><maxLat>13.7061787</maxLat><maxLong>145.009171</maxLong><minLat>13.1823349</minLat><minLong>144.563431</minLong><stateId>GU</stateId></Area></ArrayOfArea>');
		String json = '['+'{'+
		'  \"params\": {'+
		'    \"request\": {'+
		'      \"__type\": \"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel\",'+
		'      \"party_id\": \"3098165\",'+
		'      \"market_name\": \"00043\",'+
		'      \"market_type\": \"Postal Code\",'+
		'      \"product_type\": \"Connection for Co-Brokerage\",'+
		'      \"state\": \"FL\",'+
		'      \"waitlist_type\": \"Pre-Auth\",'+
		'      \"waitlist_slot\": \"Any\",'+
		'      \"waitlist_status\": \"Active\",'+
		'      \"lead_routing\": \"Any\",'+
		'      \"quantity\": 1,'+
		'      \"created_by\": \"vvall\",'+
		'      \"owner_name\": \"sshar\",'+
		'      \"account_sub_type\": \"Prospect\",'+
		'      \"remnant_spend\": \"0\"'+
		'    }'+
		'  },'+
		'  \"waitlist_guid\": \"f8adc76d-99ce-4c0a-aff4-120e014376db\",'+
		'  \"party_id\": \"3098165\",'+
		'  \"product_type\": \"Connection for Co-Brokerage\",'+
		'  \"market_type\": \"Postal Code\",'+
		'  \"waitlist_slot\": \"Any\",'+
		'  \"state\": \"FL\",'+
		'  \"market_name\": \"00043\",'+
		'  \"waitlist_type\": \"Pre-Auth\",'+
		'  \"lead_routing\": \"Any\",'+
		'  \"quantity\": \"1\",'+
		'  \"owner_name\": \"sshar\",'+
		'  \"created_by\": \"vvall\",'+
		'  \"ranking\": \"0\",'+
		'  \"last_worked_date\": \"\",'+
		'  \"remnant_spend\": \"0\",'+
		'  \"pre_auth_status_date\": \"\",'+
		'  \"pre_auth_expiry_date\": \"\",'+
		'  \"presales_available_date\": \"\",'+
		'  \"inventory_available_flex\": \"0\",'+
		'  \"presales_available_flex\": \"0\",'+
		'  \"inventory_available_fast\": \"0\",'+
		'  \"presales_available_fast\": \"0\",'+
		'  \"total_available_flex\": \"0\",'+
		'  \"total_available_fast\": \"0\",'+
		'  \"account_sub_type\": \"Prospect\",'+
		'  \"waitlist_status\": \"Active\",'+
		'  \"original_max_spend\": \"2000\"'+
		'}'+']';
    res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(201);
        return res;    
    }
}