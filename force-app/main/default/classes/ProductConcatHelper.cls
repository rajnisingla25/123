global class ProductConcatHelper {
	@invocablemethod(label='Concat String' description='Concats the products list')
     public static String[] concatString(List<Asset> assetid){
         String[] productlist = new List<String>();
         Set<Id> AssetIds = new Set<Id>();
         for(Asset a:  assetid){
             AssetIds.add(a.id);  
         }
         List <OrderItem> productslist= [Select o.PricebookEntry.Name From OrderItem o where o.Asset__r.Id =: AssetIds];
         String concatproduct = String.join(productslist, '+');
         productlist.add(concatproduct);
         return productlist;
         
     }
}