@isTest
public class Commissions_AmendCommission_Test{
    
     
      public static testMethod void mainTest4() {
     
        String ManagerTeam1 = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM; 
        
        //String Recordtype = Commissions_Constants.APPROVAL_RECORD_TYPE;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541w@move.com','test1541w@move.com',false,WLVTerritory);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = ManagerTeam;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        allUsers.add(User2);
        //Insert User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15w4@move.com','test15w4@move.com',false,WLVTerritory);
        user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        user1.Vacation_End_Date__c = Date.today().adddays(10);
        //user1.managers__c = user2.Id;
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = WLVTerritory;
        allUsers.add(User1);
        //insert user1;      
        
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154244w@move.com','test154244w@move.com',false,WLVTerritory);
        user4.LastName ='Matthews';
        user4.FirstName='Adrian';
        user4.Team__c = ManagerTeam;
        allUsers.add(User4);
        //insert user4;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542e@move.com','test1542e@move.com',false,WLVTerritory);
        //user3.managers__c = user2.Id;
        user3.managers__c = 'Adrian Matthews';
        user3.FirstName = 'FName1';
        User3.Team__c = WLVTerritory;
        //insert user3;
        allUsers.add(User3);
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
       
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
        acc.ShippingStreet = 'Test Street';
        acc.ShippingCity = 'City';
        acc.ShippingState = 'State';
        acc.ShippingPostalCode = '12345';
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user1.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c =   system.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;   
          
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
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
        r.OwnerId = user1.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;
        //set<Id> orderOwnerIds = new set<id>();
        //orderOwnerIds.add(user1.id);
        List<Asset> allAssets = new List<Asset>();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test1';
        assets.Ownerid = user2.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = type1;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = status;
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = Date.newInstance(2016,03,01);
        assets.End_Date__c = system.today().addDays(-10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'Amend';
        assets.Price = 10.00;
        assets.Sign_in_AE__c= user1.id;
        assets.Commission_field__c='Calculate';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = 120.00;
        assets.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;  
         
        allAssets.add(assets);   
        
        Asset assets2 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets2.RecordTypeId = rectypidasset;
        assets2.Name = 'test1';
        assets2.Ownerid = user2.id;
        assets2.Renewal_Status__c = 'Renew';
        assets2.Auto_Renewal__c = 'No';
        assets2.Asset_Type__c = type1;
        assets2.Product2Id = prdctdata.id;
        assets2.Fulfillment_Status__c = fullfilled;
        assets2.Status = status;
        assets2.At_Risk__c = false;
        assets2.Billing_Period__c = 'Monthly';
        assets2.Start_Date__c = Date.newInstance(2017,03,01);
        assets2.End_Date__c = system.today().addDays(-10);
        assets2.Asset_Type__c = 'Parent';
        assets2.Auto_Renewal__c  = 'Yes';
        assets2.Line_Type__c = 'Amend';
        assets2.Price = 10.00;
        assets2.Sign_in_AE__c= user1.id;
        assets2.Commission_field__c='Calculate';
        assets2.Total_Net__c = 1200.00;
        assets2.Delta_Price__c = 120.00;
        assets2.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets2.AccountId = acc.id;   
        allAssets.add(assets2);   
        //insert assets;
        //assets.Line_Type__c = 'Amend';
        //update assets;
 
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user3.Id,prdctdata.Id,false);
        assets1.Name = 'test2';
        assets1.Ownerid = user3.id;
        assets1.Renewal_Status__c = 'Renew';
        assets1.Auto_Renewal__c = 'No';
        assets1.Asset_Type__c = type1;
        assets1.Product2Id = prdctdata.id;
        assets1.Fulfillment_Status__c = fullfilled;
        assets1.Status = status;
        assets1.At_Risk__c = false;
        assets1.Billing_Period__c = 'Monthly';
        assets1.Start_Date__c = Date.newInstance(2016,04,01);
        assets1.End_Date__c = system.today().addDays(-10);
        assets1.Asset_Type__c = 'Parent';
        assets1.Auto_Renewal__c  = 'Yes';
        assets1.Line_Type__c = 'Amend';
        assets1.Price = 10.00;
        assets1.Sign_in_AE__c= user3.id;
        assets1.Commission_field__c='Calculate';
        assets1.Total_Net__c = 1200.00;
        assets1.Delta_Price__c = 120.00;
        assets1.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets1.AccountId = acc.id;  
        allAssets.add(assets1);       
        insert allAssets;
        //assets.Line_Type__c = 'Amend';
        //update assets1;
        
         
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        id rectypidpaprvl = Schema.SObjectType.Quota__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
          
       
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);//new Quota__c();
        //QuotaHandlerlatest.ID =  'a2EZ00000007lHbMAI';
        QuotaHandlerlatest.Target_Amount__c = 1000;
        QuotaHandlerlatest.Target_Amount_2__c = 1000;
        QuotaHandlerlatest.User__c= User1.Id;
        QuotaHandlerlatest.User_Team__c = WLVTerritory;
        QuotaHandlerlatest.Period_Name__c = period.id; 
        QuotaHandlerlatest.Is_Kicker__c= false;         
        insert QuotaHandlerlatest;
          
          
          
        List<Quota__c> allQuotas = new List<Quota__c>();     
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.Target_Amount_2__c = 1000;
        QuotaHandler.User__c= User1.Id;
        QuotaHandler.User_Team__c = WLVTerritory;
        QuotaHandler.Period_Name__c = period.id;
        QuotaHandler.Is_Kicker__c = true;
        QuotaHandler.Current_Quater__c = 'Active';
        QuotaHandler.Current_Quater__c = 'Q2';   
       
        //insert QuotaHandler;
        allQuotas.add(QuotaHandler);
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User__c= user3.Id;
        QuotaHandler1.User_Team__c = WLVTerritory;
        QuotaHandler1.Period_Name__c = period.id;
        QuotaHandler1.Is_Kicker__c = true;
        QuotaHandler1.Current_Quater__c = 'Active';
        QuotaHandler1.Target_Amount_2__c = 1000;   
        QuotaHandler1.Current_Quater__c = 'Q2';  
       
                
        //insert QuotaHandler1;
        allQuotas.add(QuotaHandler1);
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = WLVTerritory;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Is_Kicker__c = false;
        QuotaHandlerM.Current_Quater__c = 'Active';
        QuotaHandlerM.Target_Amount_2__c = 1000;   
        QuotaHandlerM.Current_Quater__c = 'Q2';  
        QuotaHandlerM.Is_Kicker__c = true;
        
              
        //insert QuotaHandlerM;
        allQuotas.add(QuotaHandlerM);
        Quota__c  QuotaHandlerM1 = Commissions_TestDataFactory.CreateQuota(user4.id,period.id,false);
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user4.Id;
        QuotaHandlerM1.User_Team__c = WLVTerritory;
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Target_Amount_2__c = 1000; 
        QuotaHandlerM1.Is_Kicker__c = true;
        QuotaHandlerM1.Current_Quater__c = 'Active';
        QuotaHandlerM1.Current_Quater__c = 'Q2';  
        //insert QuotaHandlerM1;
        allQuotas.add(QuotaHandlerM1); 
        insert allQuotas;          
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
        List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
         
        comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = 'WLVTerritory';
        comm.Commission_Split__c = 50;
        comm.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm.Commissionable_Amount1B__c =100;
        comm.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm.User_Team__c = Commissions_Constants.COLLECTION_TEAM ;  
          
        //insert comm;   
        allcommissions.add(comm);
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets1.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = 'WLVTerritory';
        comm1.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm1.Commissionable_Amount1B__c =100;
        comm1.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        //insert comm1; 
        allcommissions.add(comm1);
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets2.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = 'WLVTerritory';
        comm2.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm2.Commissionable_Amount1B__c =100;
        comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        //insert comm2;
        allcommissions.add(comm2);
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM1.Id, prdctdata.Id,rectypidq,null,false);
        comm3.Related_to_Asset__c = assets1.Id;
        comm3.Asset_Amount__c = 100;
        comm3.user_team__c = 'WLVTerritory';
        comm3.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm3.Commissionable_Amount1B__c =100;
        comm3.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        //insert comm3;
        allcommissions.add(comm3);
        Commission__c  comm4 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm4.Related_to_Asset__c = assets2.Id;
        comm4.Asset_Amount__c = 100;
        comm4.user_team__c = 'WLVTerritory';
        comm4.Related_to_Quota__c = QuotaHandlerM.ID;
        comm4.Commissionable_Amount1B__c =100;
        comm4.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        allcommissions.add(comm4);
        insert allcommissions;
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(comm.id);
        allCommissionIds.add(comm1.id);
        allCommissionIds.add(comm2.id);
        allCommissionIds.add(comm3.id);
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);      
        
        Commissions_AmendCommissionHandler ch1 = new  Commissions_AmendCommissionHandler();          
          
        ch1.UpdateCommissions(fullfilledAssets );          
           
     } 
     public static testMethod void mainTest2(){     
        String ManagerTeam1 = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;        
        //String Recordtype = Commissions_Constants.APPROVAL_RECORD_TYPE;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'test1541w@move.com','test1541w@move.com',false,WLVTerritory);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = ManagerTeam1;
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        allUsers.add(User2);
        //Insert User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15w4@move.com','test15w4@move.com',false,WLVTerritory);
        user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        user1.Vacation_End_Date__c = Date.today().adddays(10);
        //user1.managers__c = user2.Id;
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = ManagerTeam1;
        allUsers.add(User1);
        //insert user1;      
        
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154244w@move.com','test154244w@move.com',false,WLVTerritory);
        user4.LastName ='Matthews';
        user4.FirstName='Adrian';
        user4.Team__c = ManagerTeam1;
        allUsers.add(User4);
        //insert user4;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542e@move.com','test1542e@move.com',false,WLVTerritory);
        //user3.managers__c = user2.Id;
        user3.managers__c = 'Adrian Matthews';
        user3.FirstName = 'FName1';
        User3.Team__c = ManagerTeam1;
        //insert user3;
        allUsers.add(User3);
        Insert allUsers;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
       
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
        acc.ShippingStreet = 'Test Street';
        acc.ShippingCity = 'City';
        acc.ShippingState = 'State';
        acc.ShippingPostalCode = '12345';
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.RecordTypeId = rectypidaccount;
        acc.Type = type;
        acc.OwnerId = user1.id;
        insert acc;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c =   system.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;   
          
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
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
        r.OwnerId = user1.id;
        //insert r;
          
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        //insert oi;
        //set<Id> orderOwnerIds = new set<id>();
        //orderOwnerIds.add(user1.id);
        List<Asset> allAssets = new List<Asset>();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test1';
        assets.Ownerid = user2.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = type1;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = status;
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = Date.newInstance(2017,03,01);
        assets.End_Date__c = system.today().addDays(-10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'Amend';
        assets.Price = 10.00;
        assets.Sign_in_AE__c= user1.id;
        assets.Commission_field__c='Calculate';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = 120.00;
        assets.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets.AccountId = acc.id;  
         
        allAssets.add(assets);   
        
        Asset assets2 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets2.RecordTypeId = rectypidasset;
        assets2.Name = 'test1';
        assets2.Ownerid = user2.id;
        assets2.Renewal_Status__c = 'Renew';
        assets2.Auto_Renewal__c = 'No';
        assets2.Asset_Type__c = type1;
        assets2.Product2Id = prdctdata.id;
        assets2.Fulfillment_Status__c = fullfilled;
        assets2.Status = status;
        assets2.At_Risk__c = false;
        assets2.Billing_Period__c = 'Monthly';
        assets2.Start_Date__c = Date.newInstance(2017,03,01);
        assets2.End_Date__c = system.today().addDays(-10);
        assets2.Asset_Type__c = 'Parent';
        assets2.Auto_Renewal__c  = 'Yes';
        assets2.Line_Type__c = 'Amend';
        assets2.Price = 10.00;
        assets2.Sign_in_AE__c= user1.id;
        assets2.Commission_field__c='Calculate';
        assets2.Total_Net__c = 1200.00;
        assets2.Delta_Price__c = 120.00;
        assets2.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets2.AccountId = acc.id;   
        allAssets.add(assets2);   
        //insert assets;
        //assets.Line_Type__c = 'Amend';
        //update assets;
 
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user3.Id,prdctdata.Id,false);
        assets1.Name = 'test2';
        assets1.Ownerid = user3.id;
        assets1.Renewal_Status__c = 'Renew';
        assets1.Auto_Renewal__c = 'No';
        assets1.Asset_Type__c = type1;
        assets1.Product2Id = prdctdata.id;
        assets1.Fulfillment_Status__c = fullfilled;
        assets1.Status = status;
        assets1.At_Risk__c = false;
        assets1.Billing_Period__c = 'Monthly';
        assets1.Start_Date__c = system.today();//Date.newInstance(2017,04,01);
        assets1.End_Date__c = system.today().addDays(-10);
        assets1.Asset_Type__c = 'Parent';
        assets1.Auto_Renewal__c  = 'Yes';
        assets1.Line_Type__c = 'Amend';
        assets1.Price = 10.00;
        assets1.Sign_in_AE__c= user3.id;
        assets1.Commission_field__c='Calculate';
        assets1.Total_Net__c = 1200.00;
        assets1.Delta_Price__c = 120.00;
        assets1.Delta_Price_w_o_Tax__c = -120;
        //assets.Order_Line_Item__c = oi.id;
        assets1.AccountId = acc.id;  
        allAssets.add(assets1);       
        insert allAssets;
        //assets.Line_Type__c = 'Amend';
        //update assets1;
        
         
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        id rectypidpaprvl = Schema.SObjectType.Quota__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
          
       
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);//new Quota__c();
        //QuotaHandlerlatest.ID =  'a2EZ00000007lHbMAI';
        QuotaHandlerlatest.Target_Amount__c = 1000;
        QuotaHandlerlatest.Target_Amount_2__c = 1000;
        QuotaHandlerlatest.User__c= User1.Id;
        QuotaHandlerlatest.User_Team__c = ManagerTeam1;
        QuotaHandlerlatest.Period_Name__c = period.id; 
        QuotaHandlerlatest.Is_Kicker__c= false;         
        insert QuotaHandlerlatest;
          
          
          
        List<Quota__c> allQuotas = new List<Quota__c>();     
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.Target_Amount_2__c = 1000;
        QuotaHandler.User__c= User1.Id;
        QuotaHandler.User_Team__c = ManagerTeam1;
        QuotaHandler.Period_Name__c = period.id;
        QuotaHandler.Is_Kicker__c = true;
        QuotaHandler.Current_Quater__c = 'Active';
        QuotaHandler.Current_Quater__c = 'Q2';   
       
        //insert QuotaHandler;
        allQuotas.add(QuotaHandler);
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User__c= user3.Id;
        QuotaHandler1.User_Team__c = ManagerTeam1;
        QuotaHandler1.Period_Name__c = period.id;
        QuotaHandler1.Is_Kicker__c = true;
        QuotaHandler1.Current_Quater__c = 'Active';
        QuotaHandler1.Target_Amount_2__c = 1000;   
        QuotaHandler1.Current_Quater__c = 'Q2';  
       
                
        //insert QuotaHandler1;
        allQuotas.add(QuotaHandler1);
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = ManagerTeam1 ;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Is_Kicker__c = false;
        QuotaHandlerM.Current_Quater__c = 'Active';
        QuotaHandlerM.Target_Amount_2__c = 1000;   
        QuotaHandlerM.Current_Quater__c = 'Q2';  
        QuotaHandlerM.Is_Kicker__c = true;
        
              
        //insert QuotaHandlerM;
        allQuotas.add(QuotaHandlerM);
        Quota__c  QuotaHandlerM1 = Commissions_TestDataFactory.CreateQuota(user4.id,period.id,false);
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user4.Id;
        QuotaHandlerM1.User_Team__c = ManagerTeam1 ;
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Target_Amount_2__c = 1000; 
        QuotaHandlerM1.Is_Kicker__c = true;
        QuotaHandlerM1.Current_Quater__c = 'Active';
        QuotaHandlerM1.Current_Quater__c = 'Q2';  
        //insert QuotaHandlerM1;
        allQuotas.add(QuotaHandlerM1); 
        insert allQuotas;          
        Map<Id, Asset> newTriggerValues = new Map<Id, Asset> ();
        newTriggerValues.put(assets.Id,assets);
        List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
         
        comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = 'WLVTerritory';
        comm.Commission_Split__c = 50;
        comm.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm.Commissionable_Amount1B__c =100;
        comm.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 100;
        comm.Commissionable_Amount2__c = 100;
        comm.User_Team__c = ManagerTeam1 ;
        comm.status__c = 'Active';  
          
        //insert comm;   
        allcommissions.add(comm);
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = 'WLVTerritory';
        comm1.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm1.Commissionable_Amount1B__c =100;
        comm1.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm1.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 100;
        comm1.Commissionable_Amount2__c = 100;
        comm1.User_Team__c = ManagerTeam1 ; 
        comm1.status__c = 'Active'; 
        //insert comm1; 
        allcommissions.add(comm1);
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = 'WLVTerritory';
        comm2.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm2.Commissionable_Amount1B__c =100;
        comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm2.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 100;
        comm2.Commissionable_Amount2__c = 100;
        comm2.User_Team__c = ManagerTeam1 ;
        comm2.status__c = 'Active';  
          
        //insert comm2;
        allcommissions.add(comm2);
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM1.Id, prdctdata.Id,rectypidq,null,false);
        comm3.Related_to_Asset__c = assets.Id;
        comm3.Asset_Amount__c = 100;
        comm3.user_team__c = 'WLVTerritory';
        comm3.Related_to_Quota__c = QuotaHandlerlatest.ID;
        comm3.Commissionable_Amount1B__c =100;
        comm3.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm3.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 100;
        comm3.Commissionable_Amount2__c = 100;
        comm3.User_Team__c = ManagerTeam1 ; 
        comm3.status__c = 'Active'; 
          
        //insert comm3;
        allcommissions.add(comm3);
        Commission__c  comm4 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm4.Related_to_Asset__c = assets.Id;
        comm4.Asset_Amount__c = 100;
        comm4.user_team__c = 'WLVTerritory';
        comm4.Related_to_Quota__c = QuotaHandlerM.ID;
        comm4.Commissionable_Amount1B__c =100;
        comm4.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm4.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 100;
        comm4.Commissionable_Amount2__c = 100;
        comm4.User_Team__c = ManagerTeam1 ;  
        comm4.status__c = 'Active';
          
        allcommissions.add(comm4);
        insert allcommissions;
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(comm.id);
        allCommissionIds.add(comm1.id);
        allCommissionIds.add(comm2.id);
        allCommissionIds.add(comm3.id);
        
        Map<Id, Asset> fullfilledAssets = new Map<Id, Asset> ();
        fullfilledAssets.put(assets.Id , assets);
        Commissions_AmendCommissionHandler ch1 = new  Commissions_AmendCommissionHandler();          
        ch1.UpdateCommissions(fullfilledAssets );          
           
    } 
}