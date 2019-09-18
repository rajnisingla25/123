public without sharing class Opcity_FulfillTo_Assets_Controller {
    public Boolean isOpcityBlaTeamUser {get; set;}        // CRM-6063
    public class AssetWrapper {
        public Boolean selected {get; set;}
        public Asset fulfillToAsset {get; set;}
        public AssetWrapper(Asset fulfillToAsset ) {
            this.fulfillToAsset = fulfillToAsset;
            selected = false;
        }
    }
    
    public String borkerAccountName {get; set;}
    public List<AssetWrapper> fulfillToAssets {get; set;}
    public Opcity_FulfillTo_Assets_Controller() {
        // CRM-6063 - Start
        isOpcityBlaTeamUser = OPCityAccountSummaryHelper.isBLAUser();
        // CRM-6063 - End
        fulfillToAssets = new List<AssetWrapper>();
        List<String> prodCodes = Label.Opcity_product_Codes.split(',');
        String query = 'SELECT unlicensed_state_leads__c, can_disclose_fees__c, Product_Type__c, Source__c, Setup_Fee__c, Contract_Term__c, Opcity_MSA__c, Backup_Monthly_Plan__c, Launch_Date__c, Expected_Monthly_Lead_Volume__c, Contract_Signed_Date__c, Stage__c, Sign_in_AE__r.Name, Line_Type__c, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Account.Party_Id__c, Parent_Asset__r.Asset_Number__c, Parent_Asset__r.Account.Name, Asset_Number__c, AccountId, Account.Name, Name, Fulfillment_Status__c, Focus_Fire_Id__c, Asset_Owner_Full_Name__c,Product_Code__c FROM Asset WHERE ' +
                       'Asset_Type__c=\'Fulfill To\' AND Fulfillment_Status__c=\'Manual\' AND Product_Code__c IN :prodCodes AND ';
        //query += 'OwnerId=\''+UserInfo.getuserId()+'\' AND ';
        Id accountId = apexpages.currentpage().getparameters().get('accountId');
        String parentAssetId = apexpages.currentpage().getparameters().get('assetId');
        if (accountId != null) {
            query += 'Parent_Asset__r.AccountId=\'' + accountId + '\'';
        }
        else if (parentAssetId != null) {
            List<String> assetIds = new List<String>();
            for (String aId : parentAssetId.split(',')) {
                if (aId.trim().length()>0) {
                    assetIds.add(aId);
                }
            }
            system.debug(assetIds);
            query += 'Parent_Asset__c=:assetIds';
        }
        
        query += ' ORDER BY Account.Party_Id__c, CreatedDate DESC';
        if (accountId == null && parentAssetId == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Broker Account Id and Parent Asset Id are missing!'));
        }
        else {
            system.debug(query);
            Set<String> officesWithBLA = new Set<String>();
            List<Asset> assets = (List<Asset>)(DataBase.query(query));
            for (Asset fulfillToAsset : assets) {
                borkerAccountName = fulfillToAsset.Parent_Asset__r.Account.Name;
                if (Label.Opcity_BLA_Product_Codes.contains(fulfillToAsset.Product_Code__c)) {
                    officesWithBLA.add(fulfillToAsset.AccountId);
                }
            }

            for (Asset fulfillToAsset : assets) {
                Boolean addToList = true;
                if (fulfillToAsset.Product_Code__c == 'OPCITYCORE' && officesWithBLA.contains(fulfillToAsset.AccountId)) {
                    addToList = false;
                }
                if (addToList) {   
                    fulfillToAssets.add(new AssetWrapper(fulfillToAsset));
                }
            }
            if (fulfillToAssets.isEmpty()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'No Pending Fulfillment Assets Found!'));
            }
        }
    }
    
    public void updateAssetToFulfilled() {
        List<Asset> assetsToBeUpdated = new List<Asset>();
        Set<Id> selectedblaOfficeIds = new Set<Id>();
        for (AssetWrapper fulfillToAsset : fulfillToAssets) {
            if (fulfillToAsset.selected) {
                fulfillToAsset.fulfillToAsset.Fulfillment_Status__c = 'Fulfilled';
                assetsToBeUpdated.add(fulfillToAsset.fulfillToAsset);
                if (Label.Opcity_BLA_Product_Codes.contains(fulfillToAsset.fulfillToAsset.Product_Code__c)) {
                    selectedblaOfficeIds.add(fulfillToAsset.fulfillToAsset.AccountId);
                }
            }
        }
        // CRM-6063 - Fulfill respective office Core along with BLA
        if (!selectedblaOfficeIds.isEmpty()) {
            for (Asset coreAsset : [SELECT Fulfillment_Status__c FROM Asset WHERE AccountId IN :selectedBLAOfficeIds AND Fulfillment_Status__c='Manual' AND Asset_Type__c='Fulfill To' AND Product_Code__c='OPCITYCORE']) {
                coreAsset.Fulfillment_Status__c = 'Fulfilled'; 
                //assetsToBeUpdated.add(coreAsset);
            }
        }
        
        String error = updateAssets(assetsToBeUpdated);
        if (error == null) {
            for (AssetWrapper fulfillToAsset : fulfillToAssets) {
                if (fulfillToAsset.selected) {
                    fulfillToAsset.selected = false;
                }
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Selected Asset(s) has been fulfilled Successfully!'));
        }
    }
    
    public void save() {
        List<Asset> assetsToBeUpdated = new List<Asset>();
        for (AssetWrapper fulfillToAsset : fulfillToAssets) {
            if (fulfillToAsset.fulfillToAsset.Fulfillment_Status__c == 'Manual') {
                assetsToBeUpdated.add(fulfillToAsset.fulfillToAsset);
            }
        }
        String error = updateAssets(assetsToBeUpdated);
        if (error == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'All Asset(s) has been updated Successfully!'));
        }
    }

    private String updateAssets(List<Asset> assetsToBeUpdated) {
        String error = null;
        if (!assetsToBeUpdated.isEmpty()) {
            try {
                update assetsToBeUpdated;
            }
            catch (exception e) {
                error = e.getMessage();
            }
        }
        else {
            error = 'No Asset Selected!';
        }
        if (error != null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, error));
        }
        return error;
    }
}