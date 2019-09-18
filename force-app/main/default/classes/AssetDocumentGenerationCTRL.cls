public class AssetDocumentGenerationCTRL {

    public string parentID = '';
    public Asset oAsset {get;set;}
    public AssetDocumentGenerationCTRL()
    {
        parentID  = ApexPages.currentPage().getParameters().get('parentID');
        oAsset = [SELECT ID,Product_Logins__c FROM Asset WHERE ID =: parentID];
    }

}