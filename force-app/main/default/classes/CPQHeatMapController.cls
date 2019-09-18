public class CPQHeatMapController {
    public Account account {get;set;}
    public String cpqHeatMapURL {get;set;}
    public CPQHeatMapController(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord(); 
        loadData();     
        prepareCPQURL();
    }
    
    public void loadData(){
        account = [select Id,Name,Party_ID__c,ShippingPostalCode from Account Where Id=: account.id];
    }
    
    public void prepareCPQURL(){    
           String cpqSiteName = [Select BigMachines__bm_site__c from BigMachines__Configuration_Record__c Where BigMachines__Is_Primary__c = true LIMIT 1].BigMachines__bm_site__c;
           cpqHeatMapURL = 'https://' + cpqSiteName + '.bigmachines.com/commerce/new_equipment/products/model_configs.jsp?segment=realtor&product_line=inventoryProducts&model=heatMapSFDC&geoLevel_heatmap_selection=ZIPCODE&state_heatmap_selection=&county_heatmap_selection=&city_heatmap_selection=&zipcode_heatmap_selection='+ account.ShippingPostalCode + '&sFDCAccountId=' + account.Id + '&partyID=' + account.Party_ID__c + '&siteName=' + cpqSiteName + '&_variable_name_punchin=true&_from_punchin=true';  
    }
}