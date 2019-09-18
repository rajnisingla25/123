//Name        : AutoRenewalQuoteCreationSchedulable_Test
//Description : Test class for AutoRenewalQuoteCreationSchedulable.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class AutoRenewalQuoteCreationSchedulable_Test{
    static testMethod void method1(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c autoCreate = new Schedule_Batch_Setting__c(Name = 'Auto Renewal Quote Creation',Is_Running__c = True);
        insert autoCreate;
        Schedule_Batch_Setting__c autoSubmit = new Schedule_Batch_Setting__c(Name = 'Auto Renewal Quote Submission',Is_Running__c = True, Execution_Time_hr__c = 5);
        insert autoSubmit;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'Auto Renewal Reset Asset',Is_Running__c = True);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
        
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
            //testAccount.OwnerId = u.Id;
            insert testAccount;
            
        Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            insert assets;
        
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
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'In Progress';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        //quoteauto.EarliestAssetEndDate__c = System.today().addDays(4);
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Renew';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Start_Date__c                   = System.today().addDays(6);
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        BigMachines__Quote__c quoteauto1 = new BigMachines__Quote__c();
        quoteauto1.BigMachines__Account__c = testAccount.Id;        
        quoteauto1.BigMachines__Status__c = 'In Progress';
        quoteauto1.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto1.Name = '2020-201345';
        //quoteauto1.EarliestAssetEndDate__c = System.today().addDays(4);
        insert quoteauto1;
        
        
        test.startTest();
        AutoRenewalQuoteCreationSchedulable sh1 = new AutoRenewalQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}