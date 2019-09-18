public class CreateWaitlistResponse {
    public class params{
        public request requestdata;
    }
    public class request{
        Public String type;
        Public String party_id;
        Public String market_name;
        Public String market_type;
        Public String product_type;
        Public String state;
        Public String waitlist_type;
        Public String waitlist_slot;
        Public String waitlist_status;
        Public String lead_routing;
        Public String quantity;
        Public String created_by;
        Public String owner_name;
        Public String account_sub_type;
        Public String remnant_spend;
    }
    
    Public Class ResponseFormat{
        public String Type;
        public params requestparams;
        Public String   waitlist_guid;
        Public String   party_id;
        Public String   product_type;
        Public String   market_type;
        Public String   waitlist_slot;
        Public String   state;
        Public String   market_name;
        Public String   waitlist_type;
        Public String   lead_routing;
        Public String   quantity;
        Public String   owner_name;
        Public String   created_by;
        Public String   ranking;
        Public String   last_worked_date;
        Public String   remnant_spend;
        Public String   pre_auth_status_date;
        Public String   pre_auth_expiry_date;
        Public String   presales_available_date;
        Public String   inventory_available_flex;
        Public String   presales_available_flex;
        Public String   inventory_available_fast;
        Public String   presales_available_fast;
        Public String   total_available_flex;
        Public String   total_available_fast;
        Public String   account_sub_type;
        Public String   waitlist_status;
    }
    Public void MyMethod(){
    
    }
}