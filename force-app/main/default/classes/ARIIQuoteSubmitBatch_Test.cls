//Name        : ARIIQuoteSubmitBatch_Test
//Description : Test class for ARIIQuoteSubmitBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class ARIIQuoteSubmitBatch_Test{
    static testMethod void method1(){
        ARIICPQCalls.CPQReturnedMsg = 'test msg';
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c autoSubmit = new Schedule_Batch_Setting__c(Name = 'Auto Renewal Quote Submission',Is_Running__c = True, Execution_Time_hr__c = 5);
        insert autoSubmit;
        
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
        newProduct.ProductCode              ='SHOWCASE' ;
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
            assets.End_Date__c = System.today();
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
        //quoteauto.EarliestAssetEndDate__c = System.today().addDays(7);
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
        bquoteAddModify.Start_Date__c                   = System.today().addDays(6);
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        String QId = quoteauto.Id;
        String webList = '';
        System.debug('bmqIdSet:'+bmqIdSet);
        System.debug('bmqListids:'+bmqListids);
        
        Test.startTest();
        ARIIQuoteSubmitBatch ARSubBatch = new ARIIQuoteSubmitBatch(bmqIdSet);       
        Database.BatchableContext bc;             
        ARSubBatch.start(bc);
        ARSubBatch.execute(bc,bmqListids);
        ARSubBatch.finish(bc);
          
        Test.stopTest();
    }
}