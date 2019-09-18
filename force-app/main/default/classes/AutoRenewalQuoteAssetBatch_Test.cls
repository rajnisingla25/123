@isTest(seeAllData =false)
public  class AutoRenewalQuoteAssetBatch_Test{
    public static testMethod void mainMethod1(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',QuoteTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
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
            
        Asset assets1 = new Asset();
            assets1.Name = 'test1';
            assets1.Renewal_Status__c = 'Renew';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today();
            assets1.End_Date__c = System.today().addMonths(1);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            assets1.Renewal_Status__c = 'Pending Fulfillment';
            insert assets1;
        
        Set<Id> bmqIdSet = new Set<Id>();
        Set<ID> AcctIdset = New set<ID>();
        Set<ID> AsstIdset = New set<ID>();
        list<BigMachines__Quote__c> bmqListids = new list<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'In Progress';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        bmqIdSet.add(quoteauto.Id);
        bmqListids.add(quoteauto);
        AcctIdset.add(testAccount.Id);
        AsstIdset.add(assets.Id);
        AsstIdset.add(assets1.Id);
        
        
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
        bquoteAddModify1.Need_Manual_Renew__c            = false;
        bquoteAddModify1.DocumentNumber__c               = 3;
        bquoteAddModify1.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets1.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets1.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets1.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify1;
        
        Test.startTest();
        AutoRenewalQuoteAssetBatch ARDelBatch = new AutoRenewalQuoteAssetBatch(bmqIdSet, AcctIdset, AsstIdset);       
        Database.BatchableContext bc;             
        ARDelBatch.start(bc);
        ARDelBatch.execute(bc,bmqListids);
        ARDelBatch.finish(bc);
          
        Test.stopTest();
    
    }
}