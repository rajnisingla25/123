@isTest
private class ARAssociation_Trigger_Test{

public static testMethod void testMethod1() {
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        Product2 pt = mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        
        Asset_AR_Association__c arAsst = new Asset_AR_Association__c();
        arAsst.Asset_Id__c = ast.Id;
        arAsst.External_ID__c = '123-2356743';
        arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
        
        test.startTest();
        insert arAsst;
        update arAsst;
        delete arAsst;
        test.stopTest();
         
        
    
    }
}