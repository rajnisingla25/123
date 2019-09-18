@isTest
public class Commissions_AssetsBatchJobSch_New_Test {

    @testSetup
    public static void setTestData(){
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        
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
        
        Integer monthValue = system.today().Month();
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3) {       
            brokerRDteam = 'Q3';
        } else if (monthValue <= 6) {
            brokerRDteam = 'Q4';
        } else if (monthValue <= 9) {
            brokerRDteam = 'Q1';
        }

        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        SkipUserTrigger.setSkipTrgTrue();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio1');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,ManagerTeam,'Heather Riggio2');      
        User user3 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1543@move.com','testq1543@move.com',true,WLVTerritory,'Heather Riggio3');
        User user4 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1544@move.com','testq1544@move.com',true,ManagerTeam,'Heather Riggio4');
        
        SkipAccountTrigger.setSkipTrgTrue();        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),brokerRDteam,50,50,true);   
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,brokerRDteam,period.Id,true,false);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,'Managers Team',brokerRDteam,period.Id,false,false);  
        Quota__c  QuotaHandlerlatest3 = Commissions_TestDataFactory_New.CreateQuota(user3.id,WLVTerritory,brokerRDteam,period.Id,true,true);
        Quota__c  QuotaHandlerlatest4 = Commissions_TestDataFactory_New.CreateQuota(user4.id,'Managers Team',brokerRDteam,period.Id,false,true);

        QuotaHandlerlatest1.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerlatest1.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerlatest2.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerlatest2.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerlatest3.New_Sale_Tier_Changed__c  = FALSE;
        QuotaHandlerlatest3.Renewal_Tier_Changed__c = FALSE;    
        QuotaHandlerlatest4.New_Sale_Tier_Changed__c  = FALSE;
        QuotaHandlerlatest4.Renewal_Tier_Changed__c = FALSE;

        List<Quota__c> lstQuotas = new List<Quota__c> {QuotaHandlerlatest1, QuotaHandlerlatest2, QuotaHandlerlatest3, QuotaHandlerlatest4}; 
        
        upsert lstQuotas;

        SkipAssetTrigger.setSkipTrgTrue();
        Asset assetNewSale = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user3.id,user3.id,1000,prdctdata.id,'Add',1000,true);
        Asset assetRenewal = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user4.id,user4.id,1000,prdctdata.id,'Renew',1000,true);
        Asset assetAmend = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assetClawback = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,-1000,prdctdata.id,'Cancel',-1000,true);
      
    }

    @isTest
    public static void AssetSchedularTest(){
        Commissions_AssetsBatchJobScheduler_New p = new Commissions_AssetsBatchJobScheduler_New();
        Datetime dtt = System.now().addSeconds(2);
        String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
        system.schedule('Commissions_AssetsBatchJobScheduler_New_Test'+dtt, sch, p);

        List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
        If (listCronTrigger.size() > 0){
            for (Integer i = 0; i < listCronTrigger.size(); i++) { 
                System.abortJob(listCronTrigger[i].Id);  
            }
        }
    }
    @isTest
    public static void AssetSchedularTest2(){
        Commissions_AssetsBatchJobScheduler_New p = new Commissions_AssetsBatchJobScheduler_New();
        Datetime dtt = System.now().addSeconds(2);
        String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
        system.schedule('Commissions_AssetsBatchJobScheduler_New_Test'+dtt, sch, p);

        List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
        If (listCronTrigger.size() > 0){
            for (Integer i = 0; i < listCronTrigger.size(); i++) { 
                System.abortJob(listCronTrigger[i].Id);  
            }
        }
    }
}