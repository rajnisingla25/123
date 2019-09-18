global class InventorySearchConfiguration
{
public decimal listingCount{get;set;}
public decimal multipleImpressionVal{get;set;}

public InventorySearchConfiguration(ApexPages.StandardController stdController) {
listingCount=1;
multipleImpressionVal=1000;
}


}