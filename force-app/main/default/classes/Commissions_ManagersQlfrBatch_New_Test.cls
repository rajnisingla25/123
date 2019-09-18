/*******************************************************************************
Created By         :   Baswaraj Patil
Created Date       :   23-OCT-2018
Usage              :   Test class for the Commissions_ManagersQualifierBatch_New                       

********************************************************************************/
@isTest
public class Commissions_ManagersQlfrBatch_New_Test {
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
        
        Product_Family__c prodFamilyCustSetting = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert prodFamilyCustSetting;
        
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
        prdctdata.ProductCode = 'TPCRM';
        prdctdata.Family = 'Misc';
        prdctdata.isActive = true;
        insert prdctdata;  
        
        Product2 prdctdata2 = new Product2();
        prdctdata2.name = 'New Test2';
        prdctdata2.S_No__c = 13;
        prdctdata2.ProductCode = 'COBROKE';
        prdctdata2.isActive = true;
        insert prdctdata2; 
        
        
        Product2 prdctdata3 = new Product2();
        prdctdata3.name = 'New Test3';
        prdctdata3.S_No__c = 13;
        prdctdata3.ProductCode = 'COBROKE';
        prdctdata3.Family = 'Product Family5';
        prdctdata3.isActive = true;
        insert prdctdata3; 
        
        SkipUserTrigger.setSkipTrgTrue();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio1');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,ManagerTeam,'Heather Riggio2');      
        User user3 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1543@move.com','testq1543@move.com',true,WLVTerritory,'Heather Riggio3');
        User user4 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1544@move.com','testq1544@move.com',true,ManagerTeam,'Heather Riggio4');
        
        SkipAccountTrigger.setSkipTrgTrue();        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),brokerRDteam,50,50,true);   
        Payout__c pa = Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,brokerRDteam,period.Id,true,false);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,'Managers Team',brokerRDteam,period.Id,false,false);  
        Quota__c  QuotaHandlerlatest3 = Commissions_TestDataFactory_New.CreateQuota(user3.id,WLVTerritory,brokerRDteam,period.Id,true,true);
        Quota__c  QuotaHandlerlatest4 = Commissions_TestDataFactory_New.CreateQuota(user4.id,'Managers Team',brokerRDteam,period.Id,false,true);

        QuotaHandlerlatest1.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerlatest1.Managers__c = 'testq1542@move.com;testq1544@move.com';
        QuotaHandlerlatest1.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerlatest2.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerlatest2.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerlatest3.New_Sale_Tier_Changed__c  = FALSE;
        QuotaHandlerlatest3.Managers__c = 'testq1544@move.com';
        QuotaHandlerlatest3.Renewal_Tier_Changed__c = FALSE;
        QuotaHandlerlatest4.New_Sale_Tier_Changed__c  = FALSE;
        QuotaHandlerlatest4.Renewal_Tier_Changed__c = FALSE;

        List<Quota__c> lstQuotas = new List<Quota__c> {QuotaHandlerlatest1, QuotaHandlerlatest2, QuotaHandlerlatest3, QuotaHandlerlatest4}; 
        
        upsert lstQuotas;
        
        Quota_Product__c qp1 = new Quota_Product__c();
        qp1.Product_Family__c = 'Misc';
        qp1.Related_To_Quota__c = QuotaHandlerlatest2.Id;
        insert qp1;        
        
        Quota_Product__c qp2 = new Quota_Product__c();
        qp2.Product_Family__c = 'Misc';
        qp2.Related_To_Quota__c = QuotaHandlerlatest4.Id;
        insert qp2;
        
        Quota_Product__c qp21 = new Quota_Product__c();
        qp21.Product_Name__c = prdctdata2.Id;
        qp21.Related_To_Quota__c = QuotaHandlerlatest4.Id;
        insert qp21;
        
        /*SkipAssetTrigger.setSkipTrgTrue();
        Asset assetNewSale = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user3.id,user3.id,1000,prdctdata.id,'Add',1000,true);
        Asset assetRenewal = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user4.id,user4.id,1000,prdctdata.id,'Renew',1000,true);
        Asset assetAmend = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        Asset assetClawback = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user2.id,user2.id,-1000,prdctdata.id,'Cancel',-1000,true);
     	*/
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();        
        id rectypidq1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
        id rectypidq2 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest1.Id, prdctdata.Id,rectypidq,null,false);
        //comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'Add';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c = 10.00;
        insert comm1;
            
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest1.Id, prdctdata2.Id,rectypidq,null,false);
        //comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 10;
        comm2.line_type__C = 'Add';
        comm2.user_team__c = WLVTerritory;
        comm2.Commissionable_Amount2__c = 10.00;
        insert comm2;
        
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest1.Id, prdctdata2.Id,rectypidq1,null,false);
        //comm3.Related_to_Asset__c = assets.Id;
        comm3.Asset_Amount__c = 10;
        comm3.line_type__C = 'Add';
        comm3.user_team__c = WLVTerritory;
        comm3.Commissionable_Amount2__c = 10.00;
        insert comm3;
        
        Commission__c  comm4 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest2.Id, prdctdata.Id,rectypidq1,null,false);
        //comm4.Related_to_Asset__c = assets.Id;
        comm4.Asset_Amount__c = 10;
        comm4.line_type__C = 'Add';
        comm4.user_team__c = 'Managers Team';
        comm4.Commissionable_Amount2__c = 10.00;
        //comm4.Related_Commission__c = comm3.id;
        insert comm4; 
           
        Commission__c  comm41 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest2.Id, prdctdata2.Id,rectypidq1,null,false);
        //comm41.Related_to_Asset__c = assets.Id;
        comm41.Asset_Amount__c = 10;
        comm41.line_type__C = 'Add';
        comm41.user_team__c = 'Managers Team';
        comm41.Commissionable_Amount1B__c = 10.00;
        //comm41.Related_Commission__c = comm3.id;
        insert comm41;
        
        Commission__c  comm5 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest3.Id, prdctdata.Id,rectypidq1,null,false);
        //comm5.Related_to_Asset__c = assets.Id;
        comm5.Asset_Amount__c = 100;
        comm5.line_type__C = 'Add';
        comm5.user_team__c = WLVTerritory;
        comm5.Commissionable_Amount1B__c = 10.00;
        //comm5.Related_Commission__c = comm3.id;
        insert comm5;
        
        Commission__c comm6 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest3.Id, prdctdata2.Id,rectypidq1,null, false);
        //comm6.Related_to_Asset__c = assets.Id;
        comm6.Asset_Amount__c = 100;
        comm6.line_type__C = 'Add';
        comm6.user_team__c = WLVTerritory;
        comm6.Renewal_w_Qualifier_Comm_ble_Amount__c = 10.00;
        //comm6.Related_Commission__c = comm3.id;
        insert comm6;
        
        Commission__c comm7 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest3.Id, prdctdata3.Id, rectypidq1, null, false);
        //comm7.Related_to_Asset__c = assets.Id;
        comm7.Asset_Amount__c = 100;
        comm7.line_type__C = 'Renew';
        comm7.user_team__c =  WLVTerritory;
        comm7.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 10.00;
        //comm7.Related_Commission__c = comm3.id;
        insert comm7;
    }
    
    
    public testmethod static void testMgrQualifierBatch(){
        list<Commission__c> lstCommissions = [SELECT id,Name, Total_Commissionable_Amount__c,Product__c,Signing_AE__c,Product__r.Name,Product__r.Family,Related_to_Quota__c,
                                              Related_to_Quota__r.Managers__c,Related_to_Quota__r.User_Team__c,Related_to_Quota__r.Owner_Name__c 
                                              FROM Commission__c]; 
        Test.startTest();
        //Database.executeBatch(new Commissions_ManagersQualifierBatch_New());
        Commissions_ManagersQualifierBatch_New managersBatch = new Commissions_ManagersQualifierBatch_New();
        managersBatch.start(null);
        managersBatch.execute(null, lstCommissions);
        managersBatch.finish(null);
        Test.stopTest();
        list<Quota_Product__c> lstQPs = [Select Id, Sales_Achivement__c From Quota_Product__c]; 
		system.debug('QP1: '+ lstQPs[0].Sales_Achivement__c);  
		system.debug('QP2: '+ lstQPs[1].Sales_Achivement__c); 
		system.debug('QP3: '+ lstQPs[2].Sales_Achivement__c);         
    }
}