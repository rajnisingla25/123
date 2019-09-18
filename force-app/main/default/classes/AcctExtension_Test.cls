@isTest(Seealldata = false)
private class AcctExtension_Test{ 

 
        public static testMethod void AcctExtensionmethod(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        ApexPages.StandardController ctlr = new ApexPages.StandardController(newAccount); 
        AcctExtension acctE = new AcctExtension(ctlr);
         list<selectOption> opt =new list<selectOption>();
         opt.add(new SelectOption('','--None--'));
         acctE.addNone(opt);
        acctE.MarketTypeselectedVal ='StateCity';
        acctE.ProductselectedVal='Test1';
        acctE.StatusselectedVal='Test2';
        acctE.DegreeselectedVal ='Test3';
        acctE.PostalCodeselectedVal='Test4';
        acctE.CountySelected='Test5';
        acctE.CitySelected='Test6';
        //acctE.stateSelected='Test7';
        acctE.queryDependecies();
        acctE.queryCitys();
        acctE.queryCountys();
        acctE.checkMarketType();
        acctE.getProductOptions();
        acctE.getPostalCodeOptions();
        acctE.getStatusOptions();
        acctE.getMarketTypetOptions();
        acctE.getDegreeOptions();
        acctE.getLeadRoutingOptions();
        acctE.callapex();
        acctE.submit();
        acctE.cancel();
        acctE.GenerateTable();
        AcctExtension.marketWrapper wp =new AcctExtension.marketWrapper('tr','tb','tc','td','te','tf','tg');
     }
      public static testMethod void AcctExtensionmethod2(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        ApexPages.StandardController ctlr = new ApexPages.StandardController(newAccount); 
        AcctExtension acctE = new AcctExtension(ctlr);
        acctE.MarketTypeselectedVal ='StateCounty';
        acctE.queryDependecies();
        acctE.queryCountys();
        AcctExtension.marketWrapper wp =new AcctExtension.marketWrapper('tr','tb','tc','td','te','tf','tg');
        }
        public static testMethod void AcctExtensionmethod3(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        ApexPages.StandardController ctlr = new ApexPages.StandardController(newAccount); 
        AcctExtension acctE = new AcctExtension(ctlr);
        acctE.MarketTypeselectedVal ='PostalCode';
        acctE.queryDependecies();
        acctE.queryCountys();
        acctE.checkMarketType();
        acctE.cityFlag=true;
        AcctExtension.marketWrapper wp =new AcctExtension.marketWrapper('tr','tb','tc','td','te','tf','tg');
        }
        
}