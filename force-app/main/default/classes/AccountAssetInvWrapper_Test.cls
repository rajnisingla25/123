//
// (c) 2015 NTTDATA, Inc.
//
// Apex Test Class Name: AccountAssetInvWrapper_Test
// For Testing: AccountAssetInvWrapper.cls
//
// 22nd December 2015   Sonu Sharma 
//
@isTest
Public class AccountAssetInvWrapper_Test {
     
  static testMethod void testAccountAssetInvWrapperFunctionality() {
  MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
  AccountAssetInvWrapper aaIw = new AccountAssetInvWrapper();
  InventoryInformation ii = new InventoryInformation();
  InventoryInformation.AssetLeadDetails inald = new InventoryInformation.AssetLeadDetails();
  AccountAssetInvWrapper.AssetLeadDetails aaiald = new AccountAssetInvWrapper.AssetLeadDetails(inald);
  Asset asst = new Asset();
  AccountAssetInvWrapper.AssetDetails aaiad = new AccountAssetInvWrapper.AssetDetails(asst,ii);
  //aaiald.
  Account Acc = new Account();
  List<Asset> ppassdetails = new List<Asset>();
  List<InventoryInformation> assinv = new List<InventoryInformation>();
  AccountAssetInvWrapper aaIw1 = new AccountAssetInvWrapper(Acc,ppassdetails,assinv);
  }
 
 }