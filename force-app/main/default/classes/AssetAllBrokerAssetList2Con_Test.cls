//
// (c) 2015 NTTDATA, Inc.
//
// Apex Test Class Name: AccountAssetInvWrapper_Test
// For Testing: AccountAssetInvWrapper.cls
//
// 22nd December 2015   Sonu Sharma 
//
@isTest
Public class AssetAllBrokerAssetList2Con_Test {
     
  static testMethod void testAssetAllBrokerAssetList2ConFunctionality() {
  MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
  mtduc.CreateDisabledTriggerSingle();
  mtduc.CreateBrokerAccountSingle();
  mtduc.CreateRealtorOfficeAccountSingle();
  mtduc.CreateRealtorAgentAccountSingle();
  mtduc.CreateBrockerOfficeAccountRelationshipSingle();
  mtduc.CreateRealtorAgentAccountRelationshipSingle();
  mtduc.CreateProductSingle();
  mtduc.CreatePricebookEntrySingle();
  mtduc.CreateFullfilledAssetSingle();
  mtduc.CreateFulfilltoFullfilledAssetSingle();
  mtduc.CreateParticipantFulfilltoFullfilledAssetSingle();
  PageReference testPage = Page.AllBrokerAssets;
  testPage.getParameters().put('id', mtduc.newAccount.Id);
  Test.setCurrentPage(testPage);
  Test.StartTest();
  AssetAllBrokerAssetList2Con aabal2c = new AssetAllBrokerAssetList2Con();
  aabal2c.getAssets(); 
  aabal2c.SaveAsset();
  aabal2c.Next();
  aabal2c.Previous();
  Test.StopTest();
  }
 
 }