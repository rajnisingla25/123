@isTest
public class  commissions_updaQuotaTrgHandlr_New_Test{
    @testSetup
    public static void SetupData(){
        String WLVTerritory = 'WLV Territory Team';//Commissions_Constants.HYBRID_AGENT_TEAM ;  
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
        CommissionTeams__c cmt5 = new CommissionTeams__c(Name= 'WLV_BLA_Sales_Team' , Team_Name__c = 'WLV BLA Sales Team');
        insert cmt5;
        
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
        
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154@move.com','testq154@move.com',true,WLVTerritory,'ADRIAN MATTHEWS');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq155@move.com','testq155@move.com',true,'Managers Team','Michael Brent');      
        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),'Q1',50,50,true);        
        upsert period;

        Payout_Tier__c pt = new Payout_Tier__c();
        pt.Period__c = period.Id;
        pt.Low_Level__c = 0;
        pt.High_Level__c =60;
        pt.Sale_Type__c = 'new';
        pt.Tier_Number__c = 'Tier 1';
        insert pt;
        
        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,true);
        
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 0.0, 50.00,null,null,true);        
        pa.Connection_SM_for_Co_Brokerage__c = 5.0;     //currentQuota.COBROKE_New__c =                           
        pa.Digital_Advertising_Campaign__c = 4.0;   //currentQuota.DACAMPAIGN_New__c = 
        pa.Connections_SM_for_Seller_Bundle__c = 3.0;   //currentQuota.SELLERLEADBUNDLE_New__c = 
        pa.Connections_SM_for_Sellers__c = 2.0; //currentQuota.SELLERLEAD_New__c = 
        pa.After_Optimization__c = true;
        update pa;
        
        system.debug('payout:::'+pa+', \n->'+pa.recordType.Name);
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true);
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId(); 
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'Add';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c=10.00;
        comm1.Commission_Split__c = 100;
        insert comm1;
    }

    public static testMethod void mainTest1(){

        User user1 = [select Id, Name From User Where Name = 'ADRIAN MATTHEWS' LIMIT 1];
        User user2 = [select Id, Name From User Where Name = 'Michael Brent' LIMIT 1];
        
        Period__c period = [select Id,Name From Period__c Where Current_Quater__c = 'Q1'];
        system.debug('_Period'+period);
        
        Product2 prod = [Select Id From Product2 Where ProductCode = 'COBROKE'];
        
        Asset asset = [Select Id,Name From Asset Where Name = 'FiveStreet' limit 1];
        
        Quota__c  QuotaHandlerM = new Quota__c();
        QuotaHandlerM.Target_Amount__c = 1000;
        QuotaHandlerM.User__c= user1.Id;
        QuotaHandlerM.User_Team__c = 'WLV Territory Team';//Commissions_Constants.HYBRID_AGENT_TEAM ;
        QuotaHandlerM.Period_Name__c = period.Id;
        QuotaHandlerM.Is_Kicker__c = false;
        QuotaHandlerM.Current_Quater__c = 'Active';
        QuotaHandlerM.Target_Amount_2__c = 1000;   
        QuotaHandlerM.Current_Quater__c = 'Q1';
        QuotaHandlerM.Manager_Total_Sale__c = 1000;  
        QuotaHandlerM.Status__c = 'Active';      
        insert QuotaHandlerM;


        Quota__c  QuotaHandlerM1 = new Quota__c();
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user1.Id;
        QuotaHandlerM1.User_Team__c = 'Managers Team';
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Is_Kicker__c = true;
        QuotaHandlerM1.Current_Quater__c = 'Active';
        QuotaHandlerM1.Target_Amount_2__c = 1000;   
        QuotaHandlerM1.Current_Quater__c = 'Q2';  
        QuotaHandlerM1.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerM1.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerM1.Manager_Total_Sale__c =1000;
        QuotaHandlerM1.Managers__c = 'Heather Riggio';
        insert QuotaHandlerM1;
        
        Quota__c  QuotaHandlerM2= new Quota__c();
        QuotaHandlerM2.Target_Amount__c = 500;
        QuotaHandlerM2.User__c= user1.Id;
        QuotaHandlerM2.User_Team__c = Commissions_Constants.MANAGERS_TEAM;
        QuotaHandlerM2.Period_Name__c = period.id;
        QuotaHandlerM2.Is_Kicker__c = false;
        QuotaHandlerM2.Current_Quater__c = 'Active';
        QuotaHandlerM2.Target_Amount_2__c = 500;
        QuotaHandlerM2.Current_Quater__c = 'Q1';  
        QuotaHandlerM2.Manager_Total_Sale__c =500;
        QuotaHandlerM2.Managers__c = 'Heather Riggio';
        QuotaHandlerM2.Collection_Target_Amount__c = 100;
        QuotaHandlerM2.Manager_Collection_Sale__c = 200;
        insert QuotaHandlerM2;
                
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();
        id collectionrectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Collection Commission').getRecordTypeId();         
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM2.Id, prod.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = asset.Id;
        comm2.Asset_Amount__c = 400;
        comm2.line_type__C = 'Add';
        comm2.user_team__c = 'WLV Territory Team' ;
        comm2.Commissionable_Amount2__c=10.00;
        comm2.Commission_Split__c = 100;
        insert comm2;
        
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM2.Id, prod.Id,rectypidq,null,false);
        comm3.Related_to_Asset__c = asset.Id;
        comm3.Asset_Amount__c = 100;
        comm3.line_type__C = 'Add';
        comm3.user_team__c = 'WLV Territory Team' ;
        comm3.Commissionable_Amount2__c=10.00;
        comm3.Commission_Split__c = 100;
        insert comm3;
        
        Commission__c  comm4 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM2.Id, prod.Id,collectionrectypidq,null,false);
        comm4.Related_to_Asset__c = asset.Id;
        comm4.Asset_Amount__c = 100;
        comm4.line_type__C = 'Add';
        comm4.user_team__c = Commissions_Constants.COLLECTION_TEAM;
        comm4.Commissionable_Amount2__c=100.00;
        comm4.Commission_Split__c = 100;
        insert comm4;

        Test.StartTest();
           update QuotaHandlerM1;
        Test.stopTest();          
    }
    
    public static testMethod void mainTest2(){
        User user1 = [select Id, Name From User Where Name = 'ADRIAN MATTHEWS' LIMIT 1];
        
        Period__c period = [select Id,Name From Period__c Where Current_Quater__c = 'Q1'];
                
        Product2 prod = [Select Id From Product2 Where ProductCode = 'COBROKE'];
        
        Asset asset = [Select Id,Name From Asset Where Name = 'FiveStreet' limit 1];
        
        List<Quota__c> lstQuota = new List<Quota__c>();
        
        Quota__c  QuotaHandlerM1 = new Quota__c();
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user1.Id;
        QuotaHandlerM1.User_Team__c = 'Managers Team';
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Is_Kicker__c = true;
        QuotaHandlerM1.Current_Quater__c = 'Active';
        QuotaHandlerM1.Target_Amount_2__c = 1000;   
        QuotaHandlerM1.Current_Quater__c = 'Q2';  
        QuotaHandlerM1.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerM1.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerM1.Manager_Total_Sale__c =1000;
        lstQuota.add(QuotaHandlerM1);
                
        Quota__c  QuotaHandlerM2 = new Quota__c();
        QuotaHandlerM2.Target_Amount__c = 1000;
        QuotaHandlerM2.User__c= user1.Id;
        QuotaHandlerM2.User_Team__c = 'Managers Team';
        QuotaHandlerM2.Period_Name__c = period.id;
        QuotaHandlerM2.Is_Kicker__c = true;
        QuotaHandlerM2.Current_Quater__c = 'Active';
        QuotaHandlerM2.Target_Amount_2__c = 1000;   
        QuotaHandlerM2.Current_Quater__c = 'Q2';  
        QuotaHandlerM2.Manager_Total_Sale__c =1000;
        QuotaHandlerM2.Managers__c = 'ADRIAN MATTHEWS';
        lstQuota.add(QuotaHandlerM2);
        
        insert lstQuota;
        
        QuotaHandlerM2.Target_Amount__c = 500;
        update QuotaHandlerM2;       
    
    }
    
}