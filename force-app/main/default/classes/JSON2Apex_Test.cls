@IsTest
public class JSON2Apex_Test {
	
	static testMethod void testParse() {
		String json = '['+'{'+
		'  \"params\": {'+
		'    \"request\": {'+
		'      \"__type\": \"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel\",'+
		'      \"party_id\": \"3098165\",'+
		'      \"market_name\": \"00043\",'+
		'      \"market_type\": \"Postal Code\",'+
		'      \"product_type\": \"Connection for Co-Brokerage\",'+
		'      \"state\": \"FL\",'+
		'      \"waitlist_type\": \"Warm\",'+
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
		'  \"waitlist_type\": \"Warm\",'+
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
		'  \"waitlist_status\": \"Active\"'+
		'}'+']';
		list<JSON2Apex> obj = JSON2Apex.parse(json);
		System.assert(obj != null);
	}
}