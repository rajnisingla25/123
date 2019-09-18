@IsTest
public class WLJsonTest {
    
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
        
        WLJson obj1 = new WLJson();
        
           
    obj1.party_id='' ;
    obj1.product_type='' ;
    obj1.waitlist_status='' ;
    obj1.market_name ='';
    obj1.market_type ='';
    obj1.market_subtype='';
    obj1.waitlist_slot ='';
        obj1.county ='';
    obj1.city ='';
    obj1.territory='' ;
    obj1.waitlist_degree='' ;
    obj1.lead_routing ='';
    obj1.quantity ='';
    obj1.owner_name ='';
    obj1.created_by ='';
    obj1.created_date ='';
    obj1.updated_by ='';
    obj1.updated_date ='';
    obj1.comment ='';
    obj1.ranking ='';
    obj1.customer_id='' ;
    obj1.account_name ='';
    obj1.bob_territory ='';
    obj1.inventory_available_flex='' ;
    obj1.presales_available_flex ='';
    obj1.inventory_available_fast ='';
    obj1.presales_available_fast ='';
    obj1.total_available_flex ='';
    obj1.waitlist_guid ='';
    obj1.original_max_spend='' ;
    obj1.phone ='';
    obj1.current_utilized_spend='' ;
    obj1.remnant_spend ='';
    
    
    obj1.state_id ='';
    obj1.waitlist_status_change_date=''  ;
    obj1.call_status  ='';
    obj1.account_sub_type=''   ;
    obj1.last_worked_date  ='' ;
    obj1.pre_auth_status_date =''  ;
    obj1.pre_auth_expiry_date ='';
    obj1.presales_available_date ='' ;
    obj1.total_available_fast   ='';
      
//obj1.markets = new obj1.markets();
        
        
        list<WLJson> obj = WLJson.parse(json);
        System.assert(obj != null);
    }
}