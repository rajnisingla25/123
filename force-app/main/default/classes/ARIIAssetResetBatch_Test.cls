//Name        : ARIIAssetResetBatch_Test
//Description : Test class for ARIIAssetResetBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class ARIIAssetResetBatch_Test{
    static testMethod void method1(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = True , Assetresttime__c = -1);
        insert autoReset;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.EssentialsStatus__c = 'Activate';
            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        Set<Id> asstIdSet = new Set<Id>();
        list<Asset> asstListids = new list<Asset>();
        
         Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assets1.Id;
            arAsst.External_ID__c = '1234-78979';
        insert arAsst;
        
        asstIdSet.add(assets1.Id);
        asstListids.add(assets1); 
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renewed';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today().addMonths(-1);
            assets.End_Date__c = System.today();
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.Renewal_Status__c = 'Pending Fulfillment';
            insert assets;
        
        Asset_AR_Association__c arAsst1= new Asset_AR_Association__c();
            arAsst1.Asset_Id__c = assets.Id;
            arAsst1.External_ID__c = '1234-789791';
        insert arAsst1;
            
        asstIdSet.add(assets.Id);
        asstListids.add(assets); 

        Schedule_Batch_Setting__c assetReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = True, Assetresttime__c=-2);
        insert assetReset;
        
        Test.startTest();
        ARIIAssetResetBatch ARResetBatch = new ARIIAssetResetBatch(asstIdSet);       
        Database.BatchableContext bc;             
        ARResetBatch.start(bc);
        ARResetBatch.execute(bc,asstListids);
        ARResetBatch.finish(bc);
        Test.stopTest();
        
    
    }
}