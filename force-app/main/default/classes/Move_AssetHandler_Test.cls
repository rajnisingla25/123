@isTest(seeAllData=false)
public class Move_AssetHandler_Test {
static testMethod void Move_AssetHandlerTest(){
        //Test Data
        //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
        insert testAccount;
        Product2 prdctdata1 = new Product2();
        prdctdata1.name = 'New MovingTest';
        prdctdata1.S_No__c = 11;
        prdctdata1.ProductCode = 'MOVINGLEADS';
        prdctdata1.isActive = true;
        insert prdctdata1;
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Asset1', Product2Id = prdctdata1.Id,status = 'Cancelled',Asset_Type__c ='Parent', AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset2 = new Asset(Name = 'Asset2', Product2Id = prdctdata1.Id,status = 'Expired', Asset_Type__c ='Parent',AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset3 = new Asset(Name = 'Asset3', Product2Id = prdctdata1.Id,status = 'Active', Asset_Type__c ='Parent', AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset4 = new Asset(Name = 'Asset4', Product2Id = prdctdata1.Id,status = 'Active', Asset_Type__c ='Parent', AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));

        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);

        map<id,asset> oldmapasset =new map<id,asset>();
        oldmapasset.put(asset1.id,asset1);

        Test.startTest();
      If(Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c == True){
        insert assets;
        }
        //insert assets;
        //List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__DueDate__c = System.TODAY()-3;
        inv.Zuora__Balance2__c = 0.00;
        inv.Zuora__Account__c = testAccount.Id;
        inv.Invoice_Status__c = 'Paid';
        inv.Collection_Case_Created__c = false;
        insert inv;
        update inv;
        //invoices.add(inv);
        //insert  invoices;
        Invoice_Item__c it = new Invoice_Item__c();
        it.Name='Test';
        it.Asset__c = assets[2].id;
        it.Charge_Date__c = date.Today();
   	 	it.Service_Start_Date__c = date.Today();
        it.Charge_Amount__c =50;
        it.Invoice__c = inv.id;
        insert it;
        map<id, decimal> paidmap= new map<id, decimal>();
        Move_AssetHandler mah=new Move_AssetHandler();
        Move_AssetHandler.PaidAmountcaliculation( assets, true);
        Move_AssetHandler.UpdateParentAssetCampaignId( oldmapasset.keyset());
        BatchAssetAmountUpdate bt=new BatchAssetAmountUpdate();
        Database.executebatch(bt);
        Test.StopTest();
    }
    static testMethod void Move_AssetHandlerTest2(){
        //Test Data
        //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
        insert testAccount;


        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.ProductCode='ADVANTAGE' ;
        newProduct.S_No__c = 2;
        insert newProduct;

        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'TestProduct';
        newProduct1.ProductCode='COBROKE' ;
        newProduct1.S_No__c = 2;
        insert newProduct1;


        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Asset1',Product2Id = newProduct.id, status = 'Cancelled',Asset_Type__c ='Parent', AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset2 = new Asset(Name = 'Asset2', Product2Id = newProduct.id ,status = 'Expired', Asset_Type__c ='Parent',AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset3 = new Asset(Name = 'Asset3', Product2Id = newProduct1.id, status = 'Active', Asset_Type__c ='Parent',AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));
        Asset asset4 = new Asset(Name = 'Asset4',Product2Id = newProduct1.id,status = 'Active', Asset_Type__c ='Parent',AccountId = testAccount.id,UsageEndDate=date.Today(),Start_Date__c=date.Today().addDays(-10),End_Date__c= date.Today().addDays(10));

        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);

        map<id,asset> oldmapasset =new map<id,asset>();
        oldmapasset.put(asset1.id,asset1);

        Test.startTest();
        insert assets;


        //List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__DueDate__c = System.TODAY()-3;
        inv.Zuora__Balance2__c = 10.00;
        inv.Zuora__Account__c = testAccount.Id;
        inv.Invoice_Status__c = 'Past Due';
        inv.Collection_Case_Created__c = false;
        insert inv;
        update inv;
        //invoices.add(inv);
        //insert  invoices;
        Invoice_Item__c it = new Invoice_Item__c();
        it.Name='Test';
        it.Asset__c = assets[3].id;
        it.Charge_Date__c = date.Today();
        it.Service_Start_Date__c = date.Today();
        it.Charge_Amount__c =50;
        it.Invoice__c = inv.id;
        insert it;
        map<id, decimal> paidmap= new map<id, decimal>();
        Move_AssetHandler mah=new Move_AssetHandler();
        Move_AssetHandler.PaidAmountcaliculation( assets, true);
        BatchAssetAmountUpdate bt=new BatchAssetAmountUpdate();
        Database.executebatch(bt);
        scheduledAssetBatch sh1 = new scheduledAssetBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Asset pastdue and paid amount schedule',sch,sh1);
        Test.StopTest();
    }
}