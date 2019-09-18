@isTest
public class commissions_RenewalCommsBtch_New_Test{
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
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,WLVTerritory,'Heather Riggio');      
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Renew',1000,true);
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,true,true);        
        
        list<Asset> fullfilledAssets = new  list<Asset>();
        fullfilledAssets.add(assets);      
        Test.StartTest();
            commissions_RenewalCommissionsBatch_New sh1 = new commissions_RenewalCommissionsBatch_New();      
            DataBase.executeBatch(sh1);

            /*String sch = '0 0 23 * * ?';
            sh1.start(null);
            sh1.execute(null);  
            sh1.Finish(null);            
            //system.schedule('Test check', sch, sh1);        
            //String SCHEDULE_NAME = 'test'; 
            //id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
           // System.abortJob(cronid);*/
            Test.stopTest();          
    }
 }