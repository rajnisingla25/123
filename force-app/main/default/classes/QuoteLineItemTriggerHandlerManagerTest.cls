@isTest
private class QuoteLineItemTriggerHandlerManagerTest {
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
    @isTest
    static void QuoteLineItemTriggerHandlerManagerTest() {
        
        Switch_CaseTrigger__c swc = new Switch_CaseTrigger__c(Name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = true);
        insert swc;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com', QuoteTrigger__c  = 'test@test.com');
        insert Dtrg;
    
         Account acc    = TestDataFactory.createAccount('The Test Account', null, false);
         acc.Primary_Email__c    = 'test@test.com';
         insert acc;
         
        Account newRealtorOfficeAccount = new Account();
        newRealtorOfficeAccount.name = 'XYZ';
        newRealtorOfficeAccount.Phone = '+49-12345';
        newRealtorOfficeAccount.party_id__c = '206084041';
        newRealtorOfficeAccount.Type = 'Realtor Office';
        newRealtorOfficeAccount.Auto_Renewal__c = True;
        newRealtorOfficeAccount.Territories__c = 'test';
        insert newRealtorOfficeAccount;
        
        Account newRealtorAgentAccount = new Account();
        newRealtorAgentAccount.name = 'XYZ';
        newRealtorAgentAccount.Phone = '+49-12345';
        newRealtorAgentAccount.party_id__c = '206084041';
        newRealtorAgentAccount.Type = 'Realtor Agent';
        newRealtorAgentAccount.Auto_Renewal__c = True;
        newRealtorAgentAccount.Territories__c = 'test';
        insert newRealtorAgentAccount;
         
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SHOWCASE' ;
        newProduct.S_No__c                  = 2;
        insert newProduct;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = acc.id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Renewal_Start_Date__c = system.today();
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Quantity = 10;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        insert assets;
        
        Asset fulfillassets = new Asset();
        fulfillassets.Name = 'test';
        fulfillassets.Renewal_Status__c = 'Renew';
        fulfillassets.Auto_Renewal__c = 'No';
        fulfillassets.Asset_Type__c = 'Fulfill To';
        fulfillassets.AccountId = acc.id;
        fulfillassets.parent_asset__c = assets.id;
        fulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        fulfillassets.Product2Id = newProduct.id;
        fulfillassets.Fulfillment_Status__c = 'Fulfilled';
        fulfillassets.Renewal_Start_Date__c = system.today();
        fulfillassets.Status = 'Active';
        fulfillassets.At_Risk__c = false;
        fulfillassets.Quantity = 10;
        fulfillassets.Billing_Period__c = 'Monthly';
        fulfillassets.Start_Date__c = system.today();
        fulfillassets.End_Date__c = system.today().addDays(10);
        //fulfillassets.Asset_Type__c = 'Parent';
        fulfillassets.Auto_Renewal__c  = 'Yes';
        fulfillassets.Line_Type__c = 'renew';
        fulfillassets.Price = 10.00;
        fulfillassets.Get_CP_Login_Status__c = 'Ready';
        insert fulfillassets;
        
        Asset participantfulfillassets = new Asset();
        participantfulfillassets.Name = 'test';
        participantfulfillassets.Renewal_Status__c = 'Renew';
        participantfulfillassets.Auto_Renewal__c = 'No';
        participantfulfillassets.Asset_Type__c = 'Participant';
        participantfulfillassets.AccountId = acc.id;
        participantfulfillassets.parent_asset__c = fulfillassets.id;
        participantfulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        participantfulfillassets.Product2Id = newProduct.id;
        participantfulfillassets.Fulfillment_Status__c = 'Fulfilled';
        participantfulfillassets.Renewal_Start_Date__c = system.today();
        participantfulfillassets.Status = 'Active';
        participantfulfillassets.At_Risk__c = false;
        participantfulfillassets.Quantity = 10;
        participantfulfillassets.Billing_Period__c = 'Monthly';
        participantfulfillassets.Start_Date__c = system.today();
        participantfulfillassets.End_Date__c = system.today().addDays(10);
        participantfulfillassets.Auto_Renewal__c  = 'Yes';
        participantfulfillassets.Line_Type__c = 'renew';
        participantfulfillassets.Price = 10.00;
        insert participantfulfillassets;
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = acc.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        insert quoteauto;
        
        Test.startTest();
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify.Line_Type__c                    = 'Renew';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.Need_Manual_Renew__c = false;
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "Renew", "SoldToaccountId": "' + acc.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Renew", "assetId": "' + fulfillassets.id + '", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Renew", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "' + participantfulfillassets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        bquoteAddModify.Line_Type__c                    = 'Renew';
        bquoteAddModify.Need_Manual_Renew__c            = true;
        update bquoteAddModify;
        
        BigMachines__Quote_Product__c bquoteAddModify1   = new BigMachines__Quote_Product__c();
        bquoteAddModify1.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify1.Line_Type__c                    = 'Renew';
        bquoteAddModify1.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify1.BigMachines__Quantity__c        = 1;
        bquoteAddModify1.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify1.Need_Manual_Renew__c = false;
        bquoteAddModify1.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + acc.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "' + fulfillassets.id + '", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "' + participantfulfillassets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify1;
        
        bquoteAddModify1.Line_Type__c                    = 'Renew';
        bquoteAddModify1.Need_Manual_Renew__c            = false;
        update bquoteAddModify1;
        
        BigMachines__Quote_Product__c bquoteAddModify2   = new BigMachines__Quote_Product__c();
        bquoteAddModify2.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify2.Line_Type__c                    = 'Renew';
        bquoteAddModify2.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify2.BigMachines__Quantity__c        = 1;
        bquoteAddModify2.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify2.Need_Manual_Renew__c            = false;
        bquoteAddModify2.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + acc.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "' + fulfillassets.id + '", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "' + participantfulfillassets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify2;
                
        Test.stopTest();
    
    }
    
    @isTest
    static void QuoteLineItemTriggerHandlerManagerTest1() {
        
        Switch_CaseTrigger__c swc = new Switch_CaseTrigger__c(Name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = true);
        insert swc;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com', QuoteTrigger__c  = 'test@test.com');
        insert Dtrg;
    
         Account acc    = TestDataFactory.createAccount('The Test Account', null, false);
         acc.Primary_Email__c    = 'test@test.com';
         insert acc;
         
        Account newRealtorOfficeAccount = new Account();
        newRealtorOfficeAccount.name = 'XYZ';
        newRealtorOfficeAccount.Phone = '+49-12345';
        newRealtorOfficeAccount.party_id__c = '206084041';
        newRealtorOfficeAccount.Type = 'Realtor Office';
        newRealtorOfficeAccount.Auto_Renewal__c = True;
        newRealtorOfficeAccount.Territories__c = 'test';
        insert newRealtorOfficeAccount;
        
        Account newRealtorAgentAccount = new Account();
        newRealtorAgentAccount.name = 'XYZ';
        newRealtorAgentAccount.Phone = '+49-12345';
        newRealtorAgentAccount.party_id__c = '206084041';
        newRealtorAgentAccount.Type = 'Realtor Agent';
        newRealtorAgentAccount.Auto_Renewal__c = True;
        newRealtorAgentAccount.Territories__c = 'test';
        insert newRealtorAgentAccount;
         
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SHOWCASE' ;
        newProduct.S_No__c                  = 2;
        insert newProduct;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = acc.id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Renewal_Start_Date__c = system.today();
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Quantity = 10;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        insert assets;
        
        Asset fulfillassets = new Asset();
        fulfillassets.Name = 'test';
        fulfillassets.Renewal_Status__c = 'Renew';
        fulfillassets.Auto_Renewal__c = 'No';
        fulfillassets.Asset_Type__c = 'Fulfill To';
        fulfillassets.AccountId = acc.id;
        fulfillassets.parent_asset__c = assets.id;
        fulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        fulfillassets.Product2Id = newProduct.id;
        fulfillassets.Fulfillment_Status__c = 'Fulfilled';
        fulfillassets.Renewal_Start_Date__c = system.today();
        fulfillassets.Status = 'Active';
        fulfillassets.At_Risk__c = false;
        fulfillassets.Quantity = 10;
        fulfillassets.Billing_Period__c = 'Monthly';
        fulfillassets.Start_Date__c = system.today();
        fulfillassets.End_Date__c = system.today().addDays(10);
        //fulfillassets.Asset_Type__c = 'Parent';
        fulfillassets.Auto_Renewal__c  = 'Yes';
        fulfillassets.Line_Type__c = 'renew';
        fulfillassets.Price = 10.00;
        fulfillassets.Get_CP_Login_Status__c = 'Ready';
        insert fulfillassets;
        
        Asset participantfulfillassets = new Asset();
        participantfulfillassets.Name = 'test';
        participantfulfillassets.Renewal_Status__c = 'Renew';
        participantfulfillassets.Auto_Renewal__c = 'No';
        participantfulfillassets.Asset_Type__c = 'Participant';
        participantfulfillassets.AccountId = acc.id;
        participantfulfillassets.parent_asset__c = fulfillassets.id;
        participantfulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        participantfulfillassets.Product2Id = newProduct.id;
        participantfulfillassets.Fulfillment_Status__c = 'Fulfilled';
        participantfulfillassets.Renewal_Start_Date__c = system.today();
        participantfulfillassets.Status = 'Active';
        participantfulfillassets.At_Risk__c = false;
        participantfulfillassets.Quantity = 10;
        participantfulfillassets.Billing_Period__c = 'Monthly';
        participantfulfillassets.Start_Date__c = system.today();
        participantfulfillassets.End_Date__c = system.today().addDays(10);
        participantfulfillassets.Auto_Renewal__c  = 'Yes';
        participantfulfillassets.Line_Type__c = 'renew';
        participantfulfillassets.Price = 10.00;
        insert participantfulfillassets;
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = acc.Id;        
        quoteauto.BigMachines__Status__c = 'Pending';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        insert quoteauto;
        
        Test.startTest();       
        
        BigMachines__Quote_Product__c bquoteAddModify2   = new BigMachines__Quote_Product__c();
        bquoteAddModify2.BigMachines__Quote__c           = quoteauto.Id;
        bquoteAddModify2.Line_Type__c                    = 'Renew';
        bquoteAddModify2.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify2.BigMachines__Quantity__c        = 1;
        bquoteAddModify2.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify2.Need_Manual_Renew__c            = false;
        bquoteAddModify2.Asset_Structure__c = '{ "parent": [ {"Type": "NoChange", "SoldToaccountId": "' + acc.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "NoChange", "assetId": "' + fulfillassets.id + '", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "NoChange", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "' + participantfulfillassets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify2;       
        
        bquoteAddModify2.Line_Type__c                    = 'Renew';
        bquoteAddModify2.Need_Manual_Renew__c            = false;
        update bquoteAddModify2;
        
        System.debug('bquoteAddModify2:'+bquoteAddModify2);
        
        delete bquoteAddModify2;
                
        Test.stopTest();
    
    }
    

}