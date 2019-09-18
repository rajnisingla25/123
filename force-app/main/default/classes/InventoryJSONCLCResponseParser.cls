public class InventoryJSONCLCResponseParser {
	public Request request;
	public List<Inventory_aggregates_by_geoarea> inventory_aggregates_by_geoarea;
	public List<Inventoryitems> inventoryitems;
	public String geo_json;

	public class Request {
		public String type;
		public String party_id;
		public List<String> part_numbers;
		public String country;
		public String stateId;
		public String county;
		public String city;
	}

	public class Inventory_aggregates_by_geoarea {
		public String area;
		public String area_type;
		public String part_number;
		public String product_name;
		public String market_type;
		public String product_size;
		public String lead_routing;
		public Integer quantity;
		public Integer allocated;
		public Integer available;
		public Integer presale;
		public Integer reserved;
		public Integer reserved_presale;
		public Integer sold;
		public String party_id;
		public Integer party_allocated;
		public Integer party_available;
		public Integer party_presale;
		public Integer party_reserved;
		public Integer party_reserved_presale;
		public Integer party_sold;
	}

	public class Inventoryitems {
		public String market_name;
		public String market_type;
		public String part_number;
		public String product_name;
		public String product_size;
		public String lead_routing;
		public String city;
		public String county;
		public String state_id;
		public Integer price_tier;
		public Double flex_unit_price;
		public Integer fast_unit_price;
		public Integer available;
		public Integer available_presale;
		public Integer sold;
		public String inventory_market_status;
		public Double cost_per_action;
		public String market_key;
		public String secondary_cities;
		public Integer has_multiple_mapping;
		public Integer clc;
		public Integer customer_min_quantity;
	}

	
	public static InventoryJSONCLCResponseParser parse(String json) {
		return (InventoryJSONCLCResponseParser) System.JSON.deserialize(json, InventoryJSONCLCResponseParser.class);
	}
}