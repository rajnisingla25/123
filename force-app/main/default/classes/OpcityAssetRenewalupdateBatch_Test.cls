@isTest(seeAllData =false)
private class OpcityAssetRenewalupdateBatch_Test{
    static testMethod void method1(){  
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Error_Notification_Email_Settings__c Enes = new Error_Notification_Email_Settings__c(Name= 'OpcityAssetRenewal',Asset_Creation_Error_Emails__c = 'Test@test.com');
        insert Enes;
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='COBROKE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Set<Id> asstIdSet = new Set<Id>();
        list<Asset> asstListids = new list<Asset>();
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        testAccount.Party_ID__c = '45781245';
        testAccount.EssentialsStatus__c = 'Activated';
        insert testAccount;
        
        Asset assets1 = new Asset();
        assets1.Name = 'test';
        assets1.Asset_Type__c = 'Parent';
        assets1.AccountId = testAccount.id;
        assets1.Fulfillment_Status__c = 'Fulfilled';
        assets1.Status = 'Active';
        assets1.Billing_Period__c = 'Monthly';
        assets1.Start_Date__c = system.today().addMonths(-6);
        assets1.End_Date__c = System.today().addDays(-1);
        assets1.Product2Id = newProduct.id;
        insert assets1;
        asstIdSet.add(assets1.Id);
        asstListids.add(assets1);
        Asset assets2 = new Asset();
        assets2.Name = 'test1';
        assets2.Asset_Type__c = 'FulfillTo';
        assets2.AccountId = testAccount.id;
        assets2.ParentId =  assets1.Id;
        assets2.Fulfillment_Status__c = 'Fulfilled';
        assets2.Status = 'Active';
        assets2.Billing_Period__c = 'Monthly';
        assets2.Start_Date__c = system.today().addMonths(-8);
        assets2.End_Date__c = System.today().addDays(1);
        assets2.Product2Id = newProduct.id;
        assets2.List_Price__c = 60;
        assets2.Total_Net__c = 50;
        assets2.Total_List_Price__c = 30;
        asstIdSet.add(assets2.Id);
        asstListids.add(assets2);
        
        Asset assets3 = new Asset();
        assets3.Name = 'test1';
        assets3.Asset_Type__c = 'participant';
        assets3.AccountId = testAccount.id;
        assets3.Fulfillment_Status__c = 'Fulfilled';
        assets3.Status = 'Active';
        assets3.ParentId =  assets1.Id;
        assets2.Billing_Period__c = 'Monthly';
        assets3.Start_Date__c = system.today().addMonths(-12);
        assets3.End_Date__c = System.today().addDays(1);
        assets3.Product2Id = newProduct.id;
        insert assets3;
        asstIdSet.add(assets3.Id);
        asstListids.add(assets3);
        Test.startTest();
        OpcityAssetRenewalupdateBatch JSABatch = new OpcityAssetRenewalupdateBatch(asstIdSet);       
        Database.BatchableContext bc;             
        JSABatch.start(bc);
        JSABatch.execute(bc,asstListids);
        JSABatch.finish(bc);
       // Id batchId = Database.executeBatch(JSABatch);
        date dt = asstListids[0].Start_Date__c.addMonths(12);
        System.assertnotEquals(dt, asstListids[0].Start_Date__c);
        Test.stopTest();
    }
}