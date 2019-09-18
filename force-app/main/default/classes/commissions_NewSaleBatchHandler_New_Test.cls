@isTest
public class commissions_NewSaleBatchHandler_New_Test {
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
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,true);
        Asset assets1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Renew',1000,true);
       
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true); 
        
        list<Asset> fullfilledAssets = new  list<Asset>();
        fullfilledAssets.add(assets);  
        fullfilledAssets.add(assets1);    
        Test.StartTest();
            commissions_NewSaleBatch_New sh1 = new commissions_NewSaleBatch_New();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
            String SCHEDULE_NAME = 'test'; 
            id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
            System.abortJob(cronid);
            commissions_NewSaleBatchHandler_New ch1 = new  commissions_NewSaleBatchHandler_New();         
            try{
                ch1.CreateCommissions(fullfilledAssets );
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
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
                
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
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,ManagerTeam,'Heather Riggio');      
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);   
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        //Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,'Managers Team','Q1',period.Id,false,true);     
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,1000,prdctdata.id,'Add',1000,true);
        Asset assets1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,1000,prdctdata.id,'Renew',1000,true);
              
               
        
        list<Asset> fullfilledAssets = new  list<Asset>();
        fullfilledAssets.add(assets); 
        fullfilledAssets.add(assets1);      
        Test.StartTest();
            commissions_NewSaleBatch_New sh1 = new commissions_NewSaleBatch_New();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
            String SCHEDULE_NAME = 'test'; 
            id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
            System.abortJob(cronid);
            commissions_NewSaleBatchHandler_New ch1 = new  commissions_NewSaleBatchHandler_New();         
            try{
                ch1.CreateCommissions(fullfilledAssets );
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
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq155@move.com','testq155@move.com',true,WLVTerritory,'Heather Riggio');      
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Renew',1000,true);
        Asset assets1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user2.id,1000,prdctdata.id,'Renew',1000,true);
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true);        
        
        list<Asset> fullfilledAssets = new  list<Asset>();
        fullfilledAssets.add(assets);      
        fullfilledAssets.add(assets1);
        Test.StartTest();
            commissions_NewSaleBatch_New sh1 = new commissions_NewSaleBatch_New();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
            String SCHEDULE_NAME = 'test'; 
            id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
            System.abortJob(cronid);
            commissions_NewSaleBatchHandler_New ch1 = new  commissions_NewSaleBatchHandler_New();         
            try{
                ch1.CreateCommissions(fullfilledAssets);
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
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        //id rectypidaccount2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
                
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
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,ManagerTeam,'Heather Riggio');      
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);   
        period.Sigh_In_AE__c = 50;
        period.asset_Owner__c= 50;
        update period;
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
       // Account acc1 = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount2,'Test Street','City','State','12345',type,user1.id,true);
        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,ManagerTeam,'Q1',period.Id,false,true);     
        
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,1000,prdctdata.id,'Renew',1000,true);
        Asset assets2 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user2.id,1000,prdctdata.id,'Add',1000,true);      
        Asset assets3 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user2.id,1000,prdctdata.id,'Add',1000,true);      
        assets3.Total_Net__c = 0;
        assets3.Delta_Price_w_o_Tax__c = 1000;
        update assets3; 
        
        
        list<Asset> fullfilledAssets = new  list<Asset>();
        fullfilledAssets.add(assets);
        fullfilledAssets.add(assets2);  
        fullfilledAssets.add(assets3);
           
        Test.StartTest();
            commissions_NewSaleBatch_New sh1 = new commissions_NewSaleBatch_New();                  
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
            String SCHEDULE_NAME = 'test'; 
            id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
            System.abortJob(cronid);
            //commissions_NewSaleBatchHandler_New ch1 = new  commissions_NewSaleBatchHandler_New();         
           //try{
                //ch1.CreateCommissions(fullfilledAssets );                
            //}
           // catch(exception e){}
        Test.stopTest();          
    }
    
    public static testMethod void mainTestmethod5() {     
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidB2Caccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
                
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
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,ManagerTeam,'Heather Riggio');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq155@move.com','testq155@move.com',true,ManagerTeam,'ADRIAN MATTHEWS');      
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidB2Caccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user2.id,1000,prdctdata.id,'Renew',1000,true);
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory_New.CreateQuota(user1.id,ManagerTeam,'Q1',period.Id,false,true);        
        
        list<Asset> fullfilledAssets = new  list<Asset>();   
        fullfilledAssets.add(assets1);
        Test.StartTest();
            commissions_NewSaleBatch_New sh1 = new commissions_NewSaleBatch_New();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);        
            String SCHEDULE_NAME = 'test'; 
            id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
            System.abortJob(cronid);
            commissions_NewSaleBatchHandler_New ch1 = new  commissions_NewSaleBatchHandler_New();         
            try{
                ch1.CreateCommissions(fullfilledAssets);
            }
            catch(exception e){}
        Test.stopTest();          
    }
  
}