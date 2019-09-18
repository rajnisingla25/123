@isTest
public class Commissions_TranscReportingBatchTest {
    
    public static testMethod void commissionBackupInsertionBatchTest() {   
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
        
        List<Commissions_and_Commissions_Backup__c> lstcommBackup = new List<Commissions_and_Commissions_Backup__c>();
        Commissions_and_Commissions_Backup__c commBackupMapping1 = new Commissions_and_Commissions_Backup__c(Name = '1',Commissions_API_FieldName__c = 'Id',Commission_Backup_API_FieldName__c = 'Commission__c');
        lstcommBackup.add(commBackupMapping1);
        
        Commissions_and_Commissions_Backup__c commBackupMapping2 = new Commissions_and_Commissions_Backup__c(Name = '2',Commissions_API_FieldName__c = 'Related_to_Quota__c',Commission_Backup_API_FieldName__c = 'Quota_Number__c');
        lstcommBackup.add(commBackupMapping2);
        
        Commissions_and_Commissions_Backup__c commBackupMapping3 = new Commissions_and_Commissions_Backup__c(Name = '3',Commissions_API_FieldName__c = 'RecordType.Name',Commission_Backup_API_FieldName__c = 'Record_Type__c');
        lstcommBackup.add(commBackupMapping3);
        
        Commissions_and_Commissions_Backup__c commBackupMapping4 = new Commissions_and_Commissions_Backup__c(Name = '4',Commissions_API_FieldName__c = 'User_Team__c',Commission_Backup_API_FieldName__c = 'User_Team__c');
        lstcommBackup.add(commBackupMapping4);
        
        insert lstcommBackup;
            
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
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',Date.today().toStartOfMonth(),'Q4',50,50,true);        
       
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Cancel',1000,true);
        assets.Delta_Price_w_o_Tax__c = -100;
        assets.Start_Date__c = system.today().addDays(-40);
        update assets;
        
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q4',period.Id,false,true);            
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'cancel';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c = 10.00;
        comm1.status__c ='Active';
        insert comm1;        
        
        Test.startTest();
            Commissions_TransactionReportingBatch obj = new Commissions_TransactionReportingBatch();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}