@isTest(seeAlldata=false)
private class Opcity_FulfillTo_Assets_Controller_Test {

    static testMethod void testMethod1() {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name = 'Set Overall Trigger Off', Set_Overall_Trigger_Off__c = True);
        insert arc;
        List < Asset > assets = new List < Asset > ();
        Set < Id > setAssetIds = new Set < id > ();
        Map < Id, Asset > MapAssetIds = new Map < Id, Asset > ();
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateRealtorOfficeAccountSingle();
        mtduc.CreateRealtorAgentAccountSingle();
        mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        mtduc.CreateRealtorAgentAccountRelationshipSingle();
        Product2 prod = mtduc.CreateProductSingle();
        prod.ProductCode='OPCITYCORE';
        update prod;
        Id assetId = mtduc.CreateFullfilledAssetSingle().Id;
        Asset a = mtduc.CreateFulfilltoFullfilledAssetSingle();
        a.Fulfillment_Status__c = 'Manual';
        a.Asset_Type__c='Fulfill To';
        update a;
        
        Test.StartTest();
        PageReference pageRef = Page.Opcity_FulfillTo_Assets;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('assetId',assetId);
        Opcity_FulfillTo_Assets_Controller cnt = new Opcity_FulfillTo_Assets_Controller();
        for (Opcity_FulfillTo_Assets_Controller.AssetWrapper a1 : cnt.fulfillToAssets) {
            a1.selected = true;
        }
        cnt.updateAssetToFulfilled();
        cnt.save();
        Test.StopTest();
    }
}