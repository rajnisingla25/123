@isTest
public class Commissions_ClawbackCommissions_Test {
    private static Boolean IsUpdate;
      
    public static testMethod void mainTest1() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
       
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;   
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;     
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting;    
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'Tiger';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
            
        Order r =new Order();       
        r.AccountId=Acc.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user2.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;
       
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Cancel';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Ignore';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = -10;
        assets.Start_Date__c = system.today().adddays(-365);   
        assets.end_Date__c =Date.Today().addDays(-10);
        insert assets;
         Test.setCreatedDate(assets.Id, DateTime.newInstance(2016,04,04));  
        assets.Line_Type__c = 'Cancel';
        update assets;
        
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets1.RecordTypeId = rectypidasset;
        assets1.Name = 'test';
        assets1.Ownerid = user1.id;
        assets1.Product2Id = prdctdata.id;
        assets1.Fulfillment_Status__c = fullfilled;
        assets1.Status = 'Active';     
        assets1.Asset_Type__c = 'Parent';        
        assets1.Line_Type__c = 'Cancel';        
        assets1.Sign_in_AE__c= user1.id;
        assets1.Commission_field__c='Ignore';
        assets1.Total_Net__c = 1200.00;
        assets1.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets1.AccountId = acc.id;
        assets1.Delta_Price_w_o_Tax__c = 1000;
        assets1.Start_Date__c = system.today();   
        assets1.end_Date__c =Date.Today().addDays(-10);
        
        insert assets1;
         //Test.setCreatedDate(assets1.Id, DateTime.newInstance(2016,04,04));  
        assets1.Line_Type__c = 'Cancel';
        update assets1;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q4';
        insert QuotaHandlerM;
        
        Quota__c  QuotaHandlerM1 = Commissions_TestDataFactory.CreateQuota(User1.id,period.id,false);
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= User1.Id;
        QuotaHandlerM1.User_Team__c = Commissions_Constants.WLV_TERRITORY_TEAM;
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Target_Amount_2__c = 1000; 
        QuotaHandlerM1.Current_Quater__c = 'Q4';
        insert QuotaHandlerM1;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.Status__c = 'Active';
        comm1.user_team__c = WLVTerritory ;
        insert comm1; 
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM1.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets1.Id;
        comm2.Asset_Amount__c = 100;
        comm2.Status__c = 'Active';
        comm2.Commission_Split__c = 50;
        comm2.user_team__c = WLVTerritory ;
        insert comm2; 
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        //fullfilledAssets.put(assets1.Id , assets1);
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
        //ch1.CreateCommissions(fullfilledAssets);
        Test.stopTest();
    }
    
     public static testMethod void mainTest6() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
       
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg; 
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;        
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting;   
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'Tiger';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
            
       /**
        Order r =new Order();       
        r.AccountId=Acc.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user2.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;
       **/
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Cancel';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Ignore';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = -10;
        assets.Start_Date__c = system.today();   
        assets.end_Date__c =Date.Today().addDays(-10);
        //assets.Product_code__c = 'SELLERLEADBUNDLE';
        insert assets;
         //Test.setCreatedDate(assets.Id, DateTime.newInstance(2016,04,04));  
        assets.Line_Type__c = 'Cancel';
        update assets;
        
        
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q4';
        insert QuotaHandlerM;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.Status__c = 'Active';
        comm1.user_team__c = WLVTerritory ;
        insert comm1; 
        
       
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
    
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
       // ch1.CreateCommissions(fullfilledAssets );
        Test.stopTest();
    }
    
    
     public static testMethod void mainTest2() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,Commissions_Constants.WLV_TERRITORY_TEAM);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = Commissions_Constants.WLV_TERRITORY_TEAM;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;     
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;       
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting;
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'Tiger';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
            
        /*Order r =new Order();       
        r.AccountId=Acc.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user2.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;*/
       
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Credit';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Ignore';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = 10;
        assets.Start_Date__c = Date.newInstance(2016,10,01);
        assets.end_Date__c =Date.Today().addDays(-10);
        insert assets;
        assets.Line_Type__c = 'Credit';
        update assets;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = Commissions_Constants.WLV_TERRITORY_TEAM;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q2';
        insert QuotaHandlerM;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = WLVTerritory ;
        insert comm1; 
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = WLVTerritory ;
        insert comm2; 
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
        ch1.CreateCommissions(fullfilledAssets );
        Test.stopTest();
    }
    
     public static testMethod void mainTest3() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,ManagerTeam);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = WLVTerritory ;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        User1.IsActive = False;
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
      // Switch_AccountRelationshipTrigger__c.getInstance().Set_Overall_Trigger_Off__c = true;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;    
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;       
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting; 
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'name';
        prdctdata.Commission_Category__c = 'CFCB';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.S_No__c = 12;
      
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
      
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        
        assets.Product2Id = prdctdata.id;
         
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Credit';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Calculate';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = -10;
        assets.Start_Date__c = Date.newInstance(2015,01,01);
        insert assets;
        assets.Line_Type__c = 'Cancel';
        update assets;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = WLVTerritory ;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q2';
        insert QuotaHandlerM;
        
         Quota__c  QuotaHandlerM1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user1.Id;
        QuotaHandlerM1.User_Team__c = WLVTerritory ;
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Target_Amount_2__c = 1000; 
        QuotaHandlerM1.Current_Quater__c = 'Q2';
        QuotaHandlerM1.Managers__c = user2.Id;
        insert QuotaHandlerM1;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = WLVTerritory ;
        comm1.status__c ='Active';
        insert comm1; 
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM1.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = WLVTerritory ;
        comm2.status__c ='Active';
        insert comm2; 
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
        ch1.CreateCommissions(fullfilledAssets );
        Test.stopTest();
    }
    
     public static testMethod void mainTest4() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,ManagerTeam);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = ManagerTeam;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;     
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;     
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting;  
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'name';
        prdctdata.Commission_Category__c = 'Tiger';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.S_No__c = 12;
      
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
         
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        
        assets.Product2Id = prdctdata.id;
         
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Credit';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Ignore';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = -10;
        assets.Start_Date__c = Date.newInstance(2015,01,01);
         
        // assets.End_Date__c = Date.newInstance(2015,02,02);
        insert assets;
        assets.Line_Type__c = 'Credit';
        update assets;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q2';
        insert QuotaHandlerM;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        comm1.Commissionable_Amount1B__c = 100;
        comm1.Renewal_w_o_Qualifier_Comm_ble_Amount__c =100;
        comm1.Renewal_w_Qualifier_Comm_ble_Amount__c = 100;
        insert comm1; 
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = ManagerTeam;
        comm2.Commissionable_Amount1B__c = 100;
        comm2.Renewal_w_o_Qualifier_Comm_ble_Amount__c =100;
        comm2.Renewal_w_Qualifier_Comm_ble_Amount__c = 100;
        insert comm2; 
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
        ch1.CreateCommissions(fullfilledAssets );
        Test.stopTest();
    }
    public static testMethod void mainTest5() {
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541@move.com','test1541@move.com',false,ManagerTeam);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = ManagerTeam;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test154111@move.com','test154111@move.com',false,ManagerTeam);
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        User1.Team__c = ManagerTeam;
        User1.LastName ='test';
        User1.FirstName='Heather';
        User1.IsActive= False;
        
        allUsers.add(User1);
        //Insert User2;
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
         string year1 = '2008';
         string month = '12';
         string day = '5';
         string hour = '12';
         string minute = '20';
         string second = '20';
         string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
         Date myDate = date.valueOf(stringDate);
       SkipAccountTrigger.setSkipTrgTrue();
       SkipOrderTrigger.setSkipTrgTrue();
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;  
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;         
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting; 
        Account acc = new Account();
        acc.Name = 'Test';        
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user2.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;
        period.Start_Date__c = date.today();
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'name';
        prdctdata.Commission_Category__c = 'CFCB';
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.S_No__c = 12;
      
        insert prdctdata; 
         
        Id pricebookId= Test.getStandardPricebookId();        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;         
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;            
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
           
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
            
       /* Order r =new Order();       
        r.AccountId=Acc.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user2.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;
       */
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        
        assets.Product2Id = prdctdata.id;
         
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = 'Cancelled';     
        assets.Asset_Type__c = 'Parent';        
        assets.Line_Type__c = 'Credit';        
        assets.Sign_in_AE__c= user2.id;
        assets.Commission_field__c='Ignore';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = -120.00;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;
        assets.Delta_Price_w_o_Tax__c = 100;
        assets.Start_Date__c = Date.today();
        insert assets;
        assets.Line_Type__c = 'Credit';
        update assets;
       
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        List<Quota__c> allQuotas = new List<Quota__c>();     
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000; 
        QuotaHandlerM.Current_Quater__c = 'Q2';
        insert QuotaHandlerM;
        
        Quota__c  QuotaHandlerM1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user2.Id;
        QuotaHandlerM1.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Target_Amount_2__c = 1000; 
        QuotaHandlerM1.Current_Quater__c = 'Q2';
        insert QuotaHandlerM1;
        
        //insert allQuotas;  
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
       List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        insert comm1; 
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM1.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = ManagerTeam;
        comm2.Commission_Split__c = 50;
        insert comm2; 
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        Test.startTest();
        Commissions_ClawbackCommissionsHandler ch1 = new  Commissions_ClawbackCommissionsHandler();
        ch1.CreateCommissions(fullfilledAssets );
        Test.stopTest();
    
    }
}