//Name        : AutoRenewalDeleteQuoteProdBatch_Test
//Description : Test Class for AutoRenewalDeleteQuoteProdBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class AutoRenewalDeleteQuoteProdBatch_Test{

     static testMethod void method1(){
         
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',QuoteTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SELLERLEADBUNDLE' ;
        newProduct.S_No__c                  = 2;
        newProduct.Orderable__c             = True;
        insert newProduct;
        
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
            assets.Renewal_Status__c = 'Pending Fulfillment';
            insert assets;
        
        Set<Id> bmqIdSet = new Set<Id>();
        list<BigMachines__Quote__c> bmqListids = new list<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'In Progress';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        bmqIdSet.add(quoteauto.Id);
        bmqListids.add(quoteauto);
        
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Renew';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;       
        
        BigMachines__Quote_Product__c bquoteAddModify1   = new BigMachines__Quote_Product__c();
        bquoteAddModify1.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify1.Line_Type__c                    = 'Renew';
        bquoteAddModify1.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify1.BigMachines__Quantity__c        = 1;
        bquoteAddModify1.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify1.Need_Manual_Renew__c            = true;
        bquoteAddModify1.DocumentNumber__c               = 3;
        bquoteAddModify1.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify1;
        
        Test.startTest();
        AutoRenewalDeleteQuoteProdBatch ARDelBatch = new AutoRenewalDeleteQuoteProdBatch(bmqIdSet);       
        Database.BatchableContext bc;             
        ARDelBatch.start(bc);
        ARDelBatch.execute(bc,bmqListids);
        ARDelBatch.finish(bc);
          
        Test.stopTest();
     
     }
}