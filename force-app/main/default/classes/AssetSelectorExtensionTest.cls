@istest
public class AssetSelectorExtensionTest {

    static testmethod void assetSelectorTest(){
         DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
         Account testAcc = TestDataFactory.createAccount('The Test Account', null, false);
        testAcc.Primary_Email__c = 'testAcc@move.com';
        testAcc.Type = Constants.OFFICE_ACCOUNT_TYPE;
        testAcc.Account_Sub_Type__c = 'Prospect';   
        insert testAcc;
        List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < 10; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = testAcc.Id,
         Price = 10,
         End_Date__c = Date.today().addDays(index),
         Auto_Renewal__c = 'Yes',
         Status = 'Active'
        ));
    }
        insert theTestAssets;
        Test.startTest();
        apexpages.StandardController ssc = new apexpages.standardcontroller(testAcc);
        AssetSelectorExtension controller = new AssetSelectorExtension(ssc);
        controller.SelectedAssetId = theTestAssets[1].id;
        pageReference p = controller.deleteAsset();
        Test.stopTest();
    }
}