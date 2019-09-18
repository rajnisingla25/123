//
// (c) 2015 NTTDATA, Inc.
//
// Apex Test Class Name: ProductExclusionTriggerHandler_Test
// For Testing: ProductRestrictionTrigger.trigger And ProductExclusionTriggerHandler.cls
//
// 22nd December 2015   Sonu Sharma 
//
@isTest
private class ProductExclusionTriggerHandler_Test {     
@testSetup static void DataSetUpClass() {
Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
   insert arc; 
  MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
  //ProductExclusionTrigger
  mtduc.CreateDisabledTriggerSingle();
  mtduc.CreateBrokerAccountSingle();
  mtduc.CreateRealtorOfficeAccountSingle();
  mtduc.CreateRealtorAgentAccountSingle();
  mtduc.CreateBrockerOfficeAccountRelationshipSingle();
  mtduc.CreateRealtorAgentAccountRelationshipSingle();
  mtduc.CreateProductSingle();
  mtduc.CreatePricebookEntrySingle();
  order odr = mtduc.CreateOrderNoQuoteSingle();
  mtduc.CreateOrderItemNoQuoteSingle();
  mtduc.CreateProductRestrictionFlagSingle();
  Product_Restriction_Flag__c sple = mtduc.UpdateProductRestrictionFlagSingle();
    List<Product_Restriction_Flag__c> lstPLE = new List<Product_Restriction_Flag__c>();
  lstPLE.add(sple);
}
  static testMethod void testProductExclusionTriggerFunctionality() {
  set<Id> setOrderIds = new Set<Id>();
  set<Id> setAccountIds = new Set<Id>();
  for(Order odr:[Select Id,AccountId from order]){
  setOrderIds.add(odr.id);
  setAccountIds.add(odr.AccountId);
  }
  MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
  List<Product_Restriction_Flag__c> lstPLE = new List<Product_Restriction_Flag__c>();
  lstPLE = [Select id,Name, Account__c, Is_Active__c ,Product__c from Product_Restriction_Flag__c];
  Set<Id> setPLE = new Set<Id>();
  for(Product_Restriction_Flag__c prf:lstPLE){
  setPLE.add(prf.id);
  }
  ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();

  peth.ExpireBrokerShowcaseAssetProductExclusion(lstPLE,true);
  peth.ShowCaseOfficeAgentProductExclusion(setOrderIds);
  peth.CallCreateUpdateProductExclusion(setPLE,true);
  peth.CreateUpdateShowcaseProductExclusion(setAccountIds,true);
  peth.CreateUpdateProductExclusion(lstPLE,true);
  peth.CreateUpdateAssetShowcaseProductExclusion(setAccountIds,true);
  peth.ExpireBrokerShowcaseAssetProductExclusion(setAccountIds,true);
  peth.DeleteProductExclusion(lstPLE);
  }
 
 }