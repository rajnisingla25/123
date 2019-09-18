//Name        : ARIIOneTimeSchedulable_Test
//Description : Test class for ARIIOneTimeSchedulable.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class ARIIOneTimeSchedulable_Test{
    static testMethod void method1(){
    
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        AutoRenewalNextEndDate__c oneTime = new AutoRenewalNextEndDate__c (Name = 'Auto Renewal One Time',Next_Month_Start_Date__c = System.today().addDays(-7));
        insert oneTime;
        
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
            assets.AutoRenewQuoteProduct__c = 'testAutoQuote';
            assets.AR_Nightly_Update__c = NULL;
            insert assets;            
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'In Progress';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        quoteauto.SalesOperations__c = True;
      
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Renew';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset__c                        = assets.id;
        bquoteAddModify.Start_Date__c                   = System.today().addDays(6);
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        
                                
        
        insert bquoteAddModify;        
        
        test.startTest();
        ARIIOneTimeSchedulable sh1 = new ARIIOneTimeSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
}