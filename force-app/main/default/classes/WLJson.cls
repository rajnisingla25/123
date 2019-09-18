public class WLJson {
    
      
    public string party_id {get;set;}
    public string product_type {get;set;}
    public string waitlist_status {get;set;}
    public string market_name {get;set;}
    public string market_type {get;set;}
    public string market_subtype { get;set;}
    public string waitlist_slot {get;set; }
    public string county {get;set;}
    public  string city {get;set;}
    public string territory {get;set;}
    public string waitlist_degree {get;set;}
    public string lead_routing {get;set;}
    public  string quantity {get;set;}
    public  string owner_name {get;set;}
    public  string created_by {get;set;}
    public  string created_date {get; set;}
    public  string updated_by {get;set;}
    public  string updated_date {get;set;}
    public  string comment {get;set;}
    public  string ranking {get;set;}
    public string customer_id {get;set;}
    public  string account_name {get;set;}
    public  string bob_territory {get;set;}
    public string inventory_available_flex {get;set;}
    public  string presales_available_flex {get;set;}
    public  string inventory_available_fast {get;set;}
    public  string presales_available_fast {get;set;}
    public  string total_available_flex {get;set;}
    public  string waitlist_guid {get;set;}
    public  string original_max_spend { get;set;}
    public  string waitlist_type { get;
                              set;
                                 }
    public string phone { get;set;}
    public string current_utilized_spend { get; set;}
    public string remnant_spend {  get; set;}
    
    
    public string state_id   { get;set;}
    public string waitlist_status_change_date  { get;set;}
    public string call_status  { get;set;}
    public string account_sub_type   { get;set;}
    public string last_worked_date   { get;set;}
    public string pre_auth_status_date   { get;set;}
    public string pre_auth_expiry_date  { get;set;} 
    public string presales_available_date  { get;set;}
    public string total_available_fast   { get;set;}
    
    public List<markets> markets{get;set;} 
      
    public Class markets{
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

    public static list<WLJson> parse(String json) {
        System.debug('=======json ===='+json);
        return (list<WLJson>) (List<WLJson>)System.JSON.deserialize(json, list<WLJson>.class);
    }
    
    
}