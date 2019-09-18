@isTest
public class Commissions_ASTsToMarkProcessed_New_Test {
    
    public static testMethod void testASTsToMarkProcessed_New() {     
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM ;  
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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;
        system.assertNotEquals(null, prdctdata.Id);
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        system.assertNotEquals(null, acc.Id);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',Date.today().toStartOfMonth(),'Q4',50,50,true);        
        system.assertNotEquals(null, period.Id);
        
        Asset asset1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,true);
        system.assertNotEquals(null, asset1.Id);
        
        Asset asset2 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,1000,prdctdata.id,'Add',1000,true);
        system.assertNotEquals(null, asset2.Id);
        
        //Payout__c payout= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);        
        //system.assertNotEquals(null, payout.Id);
        
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q4',period.Id,false,true); 
        system.assertNotEquals(null, QuotaHandlerlatest1.Id);
        
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,WLVTerritory,'Q4',period.Id,false,true);
        system.assertNotEquals(null, QuotaHandlerlatest2.Id);
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest1.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = asset1.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'Add';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c = 10.00;
        comm1.status__c ='Active';
        insert comm1;
        system.assertNotEquals(null, comm1.Id);
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest2.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = asset2.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'Add';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c = 10.00;
        comm1.status__c ='Active';
        insert comm2; 
        system.assertNotEquals(null, comm2.Id);
        
        Set<Id> usersToskip = new Set<Id>();
        usersToskip.add(user2.Id);
          
        Test.StartTest();
            Commissions_AssetsToMarkProcessed_New processAssetToMarkBatch = new  Commissions_AssetsToMarkProcessed_New(usersToskip);         
            try{
                Database.executeBatch(processAssetToMarkBatch);
            }
            catch(exception e){}
        Test.stopTest();
        List<Asset> lstUpdatedAsset = [Select Id,Record_Processed_for_commission__c From Asset Where Record_Processed_for_commission__c = true];
        system.assertEquals(1, lstUpdatedAsset.size());
    
    } 

}