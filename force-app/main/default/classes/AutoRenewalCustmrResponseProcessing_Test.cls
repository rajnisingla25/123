//Name        : AutoRenewalCustmrResponseProcessing_Test
//Description : Test class for AutoRenewalCustmrResponseProcessing.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
public  class AutoRenewalCustmrResponseProcessing_Test {

    public static testMethod void mainMethod1() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
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
            insert assets;
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        BigMachines__Quote__c AutoQuote = [Select Id, Name from BigMachines__Quote__c where Id=: quoteauto.Id limit 1];
        System.debug('AutoQuote.Name:'+AutoQuote.Name);
        String QuoteName = AutoQuote.Name;
        
        BigMachines__Quote_Product__c qp = [Select Id, Name, BigMachines__Quote__c, BigMachines__Quote__r.Name from BigMachines__Quote_Product__c where Id=: bquoteAddModify.Id limit 1];
        System.debug('qp:'+qp);
        System.debug('qp.BigMachines__Quote__r.Name:'+qp.BigMachines__Quote__r.Name);
        
        Lead ld = new Lead();
        ld.LastName = 'Mr';
        ld.FirstName = 'Test';
        ld.Status = 'New';
        ld.Company = 'Test';
        ld.Contact__c = myContact2.id;
        ld.Phone = '(860) 347-0333';
        ld.Email = 'c.s1@gmail.com';
        ld.Marketing_Lead_Type__c = 'Auto-Renew';
        ld.QuoteNumber__c = QuoteName;
        ld.CustomerResponse__c = '2,Renew: Pay-in-full;';
        ld.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld);       
        //insert ld;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     
     public static testMethod void mainMethod2() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
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
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        BigMachines__Quote__c AutoQuote = [Select Id, Name from BigMachines__Quote__c where Id=: quoteauto.Id limit 1];
        String QuoteName = AutoQuote.Name;
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Mr';
        ld1.FirstName = 'Test';
        ld1.Status = 'New';
        ld1.Company = 'Test';
        ld1.Contact__c = myContact2.id;
        ld1.Phone = '(860) 347-0333';
        ld1.Email = 'c.s1@gmail.com';
        ld1.Marketing_Lead_Type__c = 'Auto-Renew';
        ld1.QuoteNumber__c = QuoteName;
        ld1.CustomerResponse__c = '2,Renew;';
        ld1.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld1);
        //insert ld1;
        
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     public static testMethod void mainMethod3() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        AssetNotRenewReason__c asstRenew = new AssetNotRenewReason__c(Name = 'INSROI', Reason_Name__c = 'Insufficient ROI');
        insert asstRenew;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
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
            insert assets;
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        BigMachines__Quote__c AutoQuote = [Select Id, Name from BigMachines__Quote__c where Id=: quoteauto.Id limit 1];
        String QuoteName = AutoQuote.Name;       
        
        Lead ld2 = new Lead();
        ld2.LastName = 'Mr';
        ld2.FirstName = 'Test';
        ld2.Status = 'New';
        ld2.Company = 'Test';
        ld2.Contact__c = myContact2.id;
        ld2.Phone = '(860) 347-0333';
        ld2.Email = 'c.s1@gmail.com';
        ld2.Marketing_Lead_Type__c = 'Auto-Renew';
        ld2.QuoteNumber__c = QuoteName;
        ld2.CustomerResponse__c = '2,Do Not Renew@INSROI;';
        ld2.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld2);
        //insert ld2;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     
     public static testMethod void mainMethod4() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
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
            insert assets;
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.BigMachines_Quote_Type__c = 'Modify';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c            = true;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + testAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + assets.id + '", "FulfillToaccountId": "' + testAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + testAccount.id + '", "assetId": "' + assets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        BigMachines__Quote__c AutoQuote = [Select Id, Name from BigMachines__Quote__c where Id=: quoteauto.Id limit 1];
        String QuoteName = AutoQuote.Name;       
        
        Lead ld2 = new Lead();
        ld2.LastName = 'Mr';
        ld2.FirstName = 'Test';
        ld2.Status = 'New';
        ld2.Company = 'Test';
        ld2.Contact__c = myContact2.id;
        ld2.Phone = '(860) 347-0333';
        ld2.Email = 'c.s1@gmail.com';
        ld2.Marketing_Lead_Type__c = 'Auto-Renew';
        ld2.QuoteNumber__c = QuoteName;
        ld2.CustomerResponse__c = '2,Renew;';
        ld2.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld2);
        
        Lead ld3 = new Lead();
        ld3.LastName = 'Mr1';
        ld3.FirstName = 'Test11';
        ld3.Status = 'New';
        ld3.Company = 'Test';
        ld3.Contact__c = myContact2.id;
        ld3.Phone = '(860) 347-0333';
        ld3.Email = 'c.s12@gmail.com';
        ld3.Marketing_Lead_Type__c = 'Auto-Renew';
        ld3.QuoteNumber__c = '2017-12345';
        ld3.CustomerResponse__c = '2,Do Not Renew;';
        ld3.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld3);
        
        //insert ld2;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }

}