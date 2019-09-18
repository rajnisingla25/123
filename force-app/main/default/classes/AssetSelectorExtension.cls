public class AssetSelectorExtension{
    public Account account;
    public List<Asset> assetsList {get;set;}
    public String SelectedAssetId {get;set;}
    public Pagination assetsPaginationObj {get;set;}
    public Integer pageSize = 5;
    public AssetSelectorExtension(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord();  
        loadData();     
    }
    
    public void loadData(){
        assetsList = [select Id,Name,SerialNumber,AccountId,InstallDate,Quantity,Contact.Name,Status,IsCompetitorProduct,Include_Asset__c from Asset Where AccountId=: account.id];
        if( assetsList.size() > 0 ){
            assetsPaginationObj = new Pagination(assetsList,pageSize);
        }
    }
    public void updateAssets(){
        update assetsPaginationObj.getRecords();  
    }
    public PageReference deleteAsset(){
            if(SelectedAssetId == null){
                return null;
            }
            //find the deal record within the collection
            Asset tobeDeleted = null;
            for(Asset a :assetsPaginationObj.getRecords()){
                if(a.Id == SelectedAssetId){
                    tobeDeleted = a;
                    break;
                }
            } 
                //if deal record found delete it
                if(tobeDeleted != null){
                    Delete tobeDeleted;
                }
                 
                //refresh the data
                loadData();
                //return null;
            PageReference pr = new PageReference('/'+account.Id);
            pr.setRedirect(true);   
            return pr;
        }
}