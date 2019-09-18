public class JSON2Apex {

	public String type;
	public Params params;
	public String waitlist_guid;
	public String party_id;
	public String product_type;
	public String market_type;
	public String waitlist_slot;
	public String state;
	public String market_name;
	public String waitlist_type;
	public String lead_routing;
	public String quantity;
	public String owner_name;
	public String created_by;
	public String ranking;
	public String last_worked_date;
	public String remnant_spend;
	public String pre_auth_status_date;
	public String pre_auth_expiry_date;
	public String presales_available_date;
	public String inventory_available_flex;
	public String presales_available_flex;
	public String inventory_available_fast;
	public String presales_available_fast;
	public String total_available_flex;
	public String total_available_fast;
	public String account_sub_type;
	public String waitlist_status;
    Public String original_max_spend;
    // Public String historical_tier_price_number ;
     //Public String historical_flex_unit_price ;
     //Public String historical_fast_unit_price ;
public List<waitlist_markets> waitlist_markets ;
    
    public Class Waitlist_markets{
        Public String waitlist_id ;
Public String waitlist_guid ; 
Public String historical_tier_price_number  ;
Public String historical_flex_unit_price;  
Public String historical_fast_unit_price  ;
Public String market_id  ;
Public String market_key ; 
Public String current_tier_price_number  ;
Public String current_flex_unit_price ; 
Public String current_fast_unit_price ; 
        
    }
	public class Request {
		public String type;
		public String party_id;
		public String market_name;
		public String market_type;
		public String product_type;
		public String state;
		public String waitlist_type;
		public String waitlist_slot;
		public String waitlist_status;
		public String lead_routing;
		public Integer quantity;
		public String created_by;
		public String owner_name;
		public String account_sub_type;
		public String remnant_spend;
	}

	public class Params {
		public Request request;
	}
	
	public static list<JSON2Apex> parse(String json) {
		return (list<JSON2Apex>) (List<JSON2Apex>)System.JSON.deserialize(json, list<JSON2Apex>.class);
	}
}