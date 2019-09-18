@isTest(SeeAllData = false)
public class commissions_AmendBatchHandler_New_Test {
   
  public static testMethod void mainTestmethod1() {     
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset2(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset2(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
         commission__c cmc = new commission__c(); 
        
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest.id;
        cmc.status__c = 'Active';
        
        insert cmc;
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.CreateCommissions(fullfilledAssets);               
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, cmc, true, true);
            }
            catch(exception e){}
        Test.stopTest();          
    }

  public static testMethod void mainTestmethod2() {     
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c(); 
        
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest.id;
        cmc.status__c = 'Active';
        
        insert cmc;
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.CreateCommissions(fullfilledAssets);               
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, cmc, true, true);
            }
            catch(exception e){}
        Test.stopTest();          
    }
    
  public static testMethod void mainTestmethod3() {     
  
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c(); 
        
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest.id;
        cmc.status__c = 'Active';
        
        insert cmc;
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.CreateCommissions(fullfilledAssets);               
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, null, true, true);
                ch1.getBrokerrdTeam(8);
       
            }
            catch(exception e){}
        Test.stopTest();          
    }
    
  public static testMethod void mainTestmethod4() {     
  
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c(); 
        
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        /*cmc.Related_to_Quota__c = QuotaHandlerlatest.id;*/
        cmc.status__c = 'Active';
        try
       { insert  cmc;
       
       }catch(exception ex){
       
       }
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.CreateCommissions(fullfilledAssets);               
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, cmc, true, true);
                
                
            }
            catch(exception e){}
        Test.stopTest();          
    }
    
    public static testMethod void mainTestmethod5() {     
        
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
        
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {              
                ch1.getBrokerrdTeam(3);
                
                
            }
            catch(exception e){}
        Test.stopTest();          
  
  }
  
   public static testMethod void mainTestmethod6() {     
        
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
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {              
                ch1.getBrokerrdTeam(9);
                
                
            }
            catch(exception e){}
        Test.stopTest();          
  
  }
  
  public static testMethod void mainTestmethod7() {     
        
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
       Quota_Product__c QProduct= new Quota_Product__c();
       
       QProduct.Product_Name__c=prdctdata.id;
       QProduct.Related_To_Quota__c=QuotaHandlerlatest1.id; 
       QProduct.Sales_Achivement__c=366424.56;
       QProduct.Sales__c=185000.0;
       QProduct.Unit_Achivement__c=172.0;
       QProduct.Target__c=true;    
       insert QProduct; 
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        
        
        
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {              
                ch1.createCommissions(fullfilledAssets );
                
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, null, true, true);                
                
            }
            catch(exception e){}
        Test.stopTest();          
  
  }
    
  public static testMethod void mainTestmethod8() {     
  
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        /*List<Product2> pdlst=[select id ,ProductCode from product2 where id=:prdctdata2.id ];
        system.debug('pdlst'+pdlst);
        Product2 prdctdata = pdlst[0];
        */
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Map<string,Schema.RecordTypeInfo> accountRecordtypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id assetAccountB2BRecordtype = accountRecordtypeMap.get('B2B').getRecordTypeId();
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com', assetAccountB2BRecordtype,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() + 367;
       
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
       Quota_Product__c QProduct= new Quota_Product__c();
        
       QProduct.Product_Name__c=prdctdata.id;
       QProduct.Related_To_Quota__c=QuotaHandlerlatest1.id; 
       QProduct.Sales_Achivement__c=366424.56;
       QProduct.Sales__c=185000.0;
       QProduct.Unit_Achivement__c=172.0;
       QProduct.Target__c=true;    
       insert QProduct;
       
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c();         
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest.id;
        cmc.status__c = 'Active';
        insert  cmc;
       
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, null, true, true);                
            }
            catch(exception e){}             
            
            
        Test.stopTest();          
    }

    public static testMethod void mainTestmethod9() {     
  
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata; 
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Map<string,Schema.RecordTypeInfo> accountRecordtypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id assetAccountB2BRecordtype = accountRecordtypeMap.get('B2C').getRecordTypeId();
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com', assetAccountB2BRecordtype,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() - 1367;
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
      
       Quota_Product__c QProduct= new Quota_Product__c();
       QProduct.OwnerId=user1.id;
       
       QProduct.Product_Name__c=prdctdata.id;
       QProduct.Related_To_Quota__c=QuotaHandlerlatest1.id; 
       QProduct.Sales_Achivement__c=366424.56;
       QProduct.Sales__c=185000.0;
       QProduct.Unit_Achivement__c=172.0;
       QProduct.Target__c=true;    
       insert QProduct;
       
        
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c();         
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest.id;
        cmc.status__c = 'Active';
        cmc.Commissionable_Amount2__c = 10;
        cmc.Commissionable_Amount3__c = 9;
        insert cmc;
       
        Test.StartTest();
            commissions_AmdClwbckBtchProcessHdlr_New ch1 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            try {
                ch1.getcommissionrecord(assets1, QuotaHandlerlatest1, null, true, true);                
            }
            catch(exception e){}
            
            commissions_AmdClwbckBtchProcessHdlr_New ch2 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            
            ch2.getcommissionrecord(assets1, QuotaHandlerlatest1, null, false, true);
            
        Test.stopTest();          
    }
    

    public static testMethod void mainTestmethod10() {     
  
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
        Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
        
        string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();

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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata; 
        
        
        System.debug('prdctdata '+prdctdata);  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Map<string,Schema.RecordTypeInfo> accountRecordtypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id assetAccountB2BRecordtype = accountRecordtypeMap.get('B2C').getRecordTypeId();
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com', assetAccountB2BRecordtype,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assets1 = Commissions_TestDataClass_New.CreateAsset3(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
       
        assets.Start_Date__c = date.today() - 1367;
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuotaWithPaymentStatus(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
      
       Quota_Product__c QProduct= new Quota_Product__c();
       //QProduct.OwnerId=user1.id;
       
       QProduct.Product_Name__c=prdctdata.id;
       QProduct.Related_To_Quota__c=QuotaHandlerlatest1.id; 
       QProduct.Sales_Achivement__c=333424.56;
       QProduct.Sales__c=175000.0;
       QProduct.Unit_Achivement__c=132.0;
       QProduct.Target__c=true;    
       insert QProduct;
       
 
       Quota_Product__c QProduct1= new Quota_Product__c();
       QProduct1.Product_Family__c='ProSoft';
       QProduct1.Related_To_Quota__c=QuotaHandlerlatest1.id; 
       QProduct1.Sales_Achivement__c=366424.56;
       QProduct1.Sales__c=185000.0;
       QProduct1.Unit_Achivement__c=172.0;
       QProduct1.Target__c=true;
      
       insert QProduct1;
      
       List <Quota__c> QALST2=[select id,Component_1A_Payout__c,Is_Kicker__c,User_Team__c,User__c ,
                            Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.Agent_Sigh_In_AE__c,
                            (Select Id, Product_Family__c, Product_Name__c, Product_Name__r.Name from Quota_Products__r)
                            FROM Quota__c where id =:QuotaHandlerlatest1.id];
        system.debug('QuotaHandlerlatest1.Quota_Products__r#####'+QuotaHandlerlatest1.Quota_Products__r);
        set<id> asetset=new Set<id>{assets.id,assets1.id};
        
        list<Asset> fullfilledAssets = [select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                                        LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                                        Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                                        from Asset where id IN:asetset];
        
        commission__c cmc = new commission__c();         
        cmc.Related_to_Asset__c = fullfilledAssets[0].id;
        cmc.Related_to_Quota__c = QuotaHandlerlatest1.id;
        cmc.status__c = 'Active';
        cmc.Commissionable_Amount2__c = 10;
        cmc.Commissionable_Amount3__c = 9;
        insert cmc;
       
        Test.StartTest();
            
            commissions_AmdClwbckBtchProcessHdlr_New ch2 = new  commissions_AmdClwbckBtchProcessHdlr_New();         
            
            ch2.getcommissionrecord(assets1, QALST2[0], cmc, true, true);
            
        Test.stopTest();          
    }    
    
}