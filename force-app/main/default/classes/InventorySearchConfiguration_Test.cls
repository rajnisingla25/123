@istest(seealldata=true)
public class InventorySearchConfiguration_Test {
    
       public static testMethod void InventorySearchConfiguration_Test(){
        Account InventoryConfigTest = TestDataFactory.createAccount('Test Account',null,false);
        ApexPages.StandardController sc = New ApexPages.StandardController(InventoryConfigTest);
        InventorySearchConfiguration inventory = new InventorySearchConfiguration(sc); 
           
           inventory.listingCount = 99.00;
           inventory.multipleImpressionVal = 999.00;
       
       }

}