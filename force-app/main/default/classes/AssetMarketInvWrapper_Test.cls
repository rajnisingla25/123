//
// (c) 2015 NTTDATA, Inc.
//
// Apex Test Class Name: AccountAssetInvWrapper_Test
// For Testing: AssetMarketInvWrapper.cls
//
// 22nd December 2015   Sudhakar Reddy
//
@isTest
Public class AssetMarketInvWrapper_Test {
     
  static testMethod void testAssetMarketInvWrapperFunctionality() {
  MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
  AssetMarketInvWrapper aaIw = new AssetMarketInvWrapper();
  InventoryInformation ii = new InventoryInformation();
  InventoryInformationAssets.AssetLeadDetails inald = new InventoryInformationAssets.AssetLeadDetails();
  //InventoryInformationAssets.AssetId Invinf = new InventoryInformationAssets.AssetId();
  Asset asst = new Asset();
  //AssetMarketInvWrapper aaiald = new AssetMarketInvWrapper(asst);
  
  //AssetMarketInvWrapper aaiad = new AssetMarketInvWrapper(asst,ii);
  //aaiald.
  Account Acc = new Account();
  List<Asset> ppassdetails = new List<Asset>();
  List<InventoryInformation> assinv = new List<InventoryInformation>();
 // AssetMarketInvWrapper aaIw1 = new AssetMarketInvWrapper(ppassdetails,inald);
  }
 
 }