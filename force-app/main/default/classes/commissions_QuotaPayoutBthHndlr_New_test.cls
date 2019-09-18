@isTest
public class commissions_QuotaPayoutBthHndlr_New_test{


    @testSetup
    public static void setTestData(){        
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

        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;        
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        
        Integer monthValue = system.today().Month();
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3) {       
            brokerRDteam = 'Q3';
        } else if (monthValue <= 6) {
            brokerRDteam = 'Q4';
        } else if (monthValue <= 9) {
            brokerRDteam = 'Q1';
        }

        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();   
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq15422@move.com','testq15422@move.com',true,WLVTerritory,'Heather Riggio'); 
        
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq154221@move.com','testq154221@move.com',true,'Managers Team','Heather Riggio1'); 
        
        SkipAccountTrigger.setSkipTrgTrue();
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);       
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',Date.today().toStartOfMonth(),'Q1',50,50,true);          
        
        Payout_Tier__c pt = new Payout_Tier__c();
        //pt.name = 'Test';
        pt.Period__c = period.Id;
        pt.Low_Level__c = 0;
        pt.High_Level__c =60;
        pt.Sale_Type__c = 'new';
        pt.Tier_Number__c = 'Tier 1';
        insert pt;

        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata; 
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId(); 
        id rectypidmgrTeam = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale with Qualifier',rectypidp, null, null,0,200,true);
        pa.Period__c =period.Id;
        pa.Sale_Type__c = 'New';
        pa.Product_Name__c = prdctdata.id;
        pa.Commissionable__c = 10;
        pa.After_Optimization__c = true;
        update pa;
          
        Payout__c pa12= Commissions_TestDataFactory_New.CreatePayout('New Sale with Qualifier',rectypidp, 0, 200,null,null,true);
        pa12.Period__c =period.Id;
        pa12.Sale_Type__c = 'New';
        pa12.Product_Name__c = prdctdata.id;
        pa12.Commissionable__c = 10;
        pa12.After_Optimization__c = true;
        update pa12;
        
        Payout__c pa121= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, null, null,0,200,true);
        pa121.Period__c =period.Id;
        pa121.Sale_Type__c = 'New';
        pa121.Product_Name__c = prdctdata.id;
        pa121.Commissionable__c = 10;
        pa121.After_Optimization__c = true;
        update pa121;      
        
        Payout__c pa1= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 0, 200,null,null,true);
        pa1.Period__c =period.Id;
        pa1.Sale_Type__c = 'New';
        pa1.Product_Name__c = prdctdata.id;
        pa1.Commissionable__c = 10;
        pa1.After_Optimization__c = true;
        update pa1;
        
              
        Payout__c pa1212= Commissions_TestDataFactory_New.CreatePayout('Renewal with Qualifier',rectypidp, null, null,0,200,true);
        pa1212.Period__c =period.Id;
        pa1212.Sale_Type__c = 'Renewal';
        pa1212.Product_Name__c = prdctdata.id;
        pa1212.Commissionable__c = 10;
        pa1212.After_Optimization__c = true;
        update pa1212; 
        
        Payout__c pa12121 = Commissions_TestDataFactory_New.CreatePayout('Renewal without Qualifier',rectypidp, null, null,0,200,true);
        pa12121.Period__c =period.Id;
        pa12121.Sale_Type__c = 'Renewal';
        pa12121.Product_Name__c = prdctdata.id;
        pa12121.Commissionable__c = 10;
        pa12121.After_Optimization__c = true;
        update pa12121; 
        
        Payout__c pa12123= Commissions_TestDataFactory_New.CreatePayout('Renewal with Qualifier',rectypidp, 0, 200,null,null,true);
        pa12123.Period__c =period.Id;
        pa12123.Sale_Type__c = 'Renewal';
        pa12123.Product_Name__c = prdctdata.id;
        pa12123.Commissionable__c = 10;
        pa12123.After_Optimization__c = true;
        update pa12123; 
        
        Payout__c pa121231= Commissions_TestDataFactory_New.CreatePayout('Renewal without Qualifier',rectypidp, 0, 200,null,null,true);
        pa121231.Period__c =period.Id;
        pa121231.Sale_Type__c = 'Renewal';
        pa121231.Product_Name__c = prdctdata.id;
        pa121231.Commissionable__c = 10;
        pa121231.After_Optimization__c = true;
        update pa121231;      


        Payout__c pa11= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidmgrTeam, 0, 200,null,null,false);
        pa11.Period__c =period.Id;
        pa11.Sale_Type__c = 'New';
        pa11.Product_Name__c = prdctdata.id;
        pa11.Commissionable__c = 10;
        pa11.After_Optimization__c = true;
        upsert pa11;
        
              
        Payout__c pa11212= Commissions_TestDataFactory_New.CreatePayout('Renewal without Qualifier',rectypidmgrTeam, null, null,0,200,false);
        pa11212.Period__c =period.Id;
        pa11212.Sale_Type__c = 'Renewal';
        pa11212.Product_Name__c = prdctdata.id;
        pa11212.Commissionable__c = 10;
        pa11212.After_Optimization__c = true;
        upsert pa11212; 

        Asset assets = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,true);
        
        Quota__c  QuotaHandlerlatest= new Quota__c();        
        QuotaHandlerlatest.Target_Amount__c = 100;
        QuotaHandlerlatest.Target_Amount_2__c = 100;
        QuotaHandlerlatest.User__c= User1.Id;
        QuotaHandlerlatest.User_Team__c = WLVTerritory ;
        QuotaHandlerlatest.Period_Name__c = period.id; 
        QuotaHandlerlatest.Current_Quater__c = brokerRDteam; 
        QuotaHandlerlatest.COBROKE_New__c = 1.00; 
        QuotaHandlerlatest.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerlatest.Renewal_Tier_Changed__c = true;
        QuotaHandlerlatest.Manager_Total_Sale__c = 20;
        QuotaHandlerlatest.Is_Kicker__c = false;
        QuotaHandlerlatest.Managers__c = 'Heather Riggio';
        QuotaHandlerlatest.Manager_Total_Sale_Renewal__c = 10;
        insert QuotaHandlerlatest;  
        
        Quota__c  QuotaHandlerM = new Quota__c();
        QuotaHandlerM.Target_Amount__c = 100;
        QuotaHandlerM.User__c= user2.Id;
        QuotaHandlerM.User_Team__c = WLVTerritory ;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Is_Kicker__c = false;
        QuotaHandlerM.Current_Quater__c = 'Active';
        QuotaHandlerM.Target_Amount_2__c = 100;   
        QuotaHandlerM.Current_Quater__c = brokerRDteam;  
        QuotaHandlerM.New_Sale_Tier_Changed__c  = true;
        QuotaHandlerM.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerM.Manager_Total_Sale__c =10;
        QuotaHandlerM.Managers__c = 'Heather Riggio';
        QuotaHandlerM.Manager_Total_Sale_Renewal__c = 10.0;
        insert QuotaHandlerM;
        
        Quota__c  QuotaHandlerM1 = new Quota__c();
        QuotaHandlerM1.Target_Amount__c = 1000;
        QuotaHandlerM1.User__c= user1.Id;
        QuotaHandlerM1.User_Team__c = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c; //'Managers Team';
        QuotaHandlerM1.Period_Name__c = period.id;
        QuotaHandlerM1.Is_Kicker__c = false;
        QuotaHandlerM1.Current_Quater__c = 'Active';
        QuotaHandlerM1.Target_Amount_2__c = 1000;   
        QuotaHandlerM1.Current_Quater__c = brokerRDteam;  
        QuotaHandlerM1.New_Sale_Tier_Changed__c  = true;
        QuotaHandlerM1.Renewal_Tier_Changed__c = TRUE;
        QuotaHandlerM1.Manager_Total_Sale__c =10;
        QuotaHandlerM1.Manager_Total_Sale_Renewal__c = 10.0;
        insert QuotaHandlerM1;
        
        Quota__c  QuotaHandlerM2 = new Quota__c();
        QuotaHandlerM2.Target_Amount__c = 1000;
        QuotaHandlerM2.User__c= user1.Id;
        QuotaHandlerM2.User_Team__c = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;//'Managers Team';
        QuotaHandlerM2.Period_Name__c = period.id;
        QuotaHandlerM2.Is_Kicker__c = false;
        QuotaHandlerM2.Current_Quater__c = 'Active';
        QuotaHandlerM2.Target_Amount_2__c = 1000;   
        QuotaHandlerM2.Current_Quater__c = brokerRDteam;  
        QuotaHandlerM2.New_Sale_Tier_Changed__c  = TRUE;
        QuotaHandlerM2.Renewal_Tier_Changed__c = true;
        QuotaHandlerM2.Manager_Total_Sale__c =10;
        QuotaHandlerM2.Collection_Target_Amount__c =19;
        QuotaHandlerM2.Managers__c = 'Heather Riggio';
        QuotaHandlerM2.Manager_Total_Sale_Renewal__c = 10.0;
        insert QuotaHandlerM2;
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();        
        id rectypidq1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
        id rectypidq2 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();
         
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.line_type__C = 'Add';
        comm1.user_team__c = WLVTerritory ;
        comm1.Commissionable_Amount2__c=10.00;
        insert comm1;
            
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 10;
        comm2.line_type__C = 'Add';
        comm2.user_team__c = 'Managers Team';
        comm2.Commissionable_Amount2__c=10.00;
        insert comm2;
        
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq1,null,false);
        comm3.Related_to_Asset__c = assets.Id;
        comm3.Asset_Amount__c = 10;
        comm3.line_type__C = 'Add';
        comm3.user_team__c = 'Managers Team';
        comm3.Commissionable_Amount2__c=10.00;
        insert comm3;
        
        Commission__c  comm4 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq1,null,false);
        comm4.Related_to_Asset__c = assets.Id;
        comm4.Asset_Amount__c = 10;
        comm4.line_type__C = 'Add';
        comm4.user_team__c = 'Managers Team';
        comm4.Commissionable_Amount2__c=10.00;
        comm4.Related_Commission__c = comm3.id;
        insert comm4; 
           
        Commission__c  comm41 = Commissions_TestDataFactory.CreateComm(QuotaHandlerM.Id, prdctdata.Id,rectypidq1,null,false);
        comm41.Related_to_Asset__c = assets.Id;
        comm41.Asset_Amount__c = 10;
        comm41.line_type__C = 'Renew';
        comm41.user_team__c = 'Managers Team';
        comm41.Commissionable_Amount1B__c=10.00;
        comm41.Related_Commission__c = comm3.id;
        insert comm41;
        
        Commission__c  comm5 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest.Id, prdctdata.Id,rectypidq1,null,false);
        comm5.Related_to_Asset__c = assets.Id;
        comm5.Asset_Amount__c = 100;
        comm5.line_type__C = 'Add';
        comm5.user_team__c = WLVTerritory;
        comm5.Commissionable_Amount1B__c =10.00;
        comm5.Related_Commission__c = comm3.id;
        insert comm5;
        
        Commission__c  comm6 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest.Id, prdctdata.Id,rectypidq1,null,false);
        comm6.Related_to_Asset__c = assets.Id;
        comm6.Asset_Amount__c = 100;
        comm6.line_type__C = 'Add';
        comm6.user_team__c = WLVTerritory;
        comm6.Renewal_w_Qualifier_Comm_ble_Amount__c =10.00;
        comm6.Related_Commission__c = comm3.id;
        insert comm6;
        
        Commission__c  comm7 = Commissions_TestDataFactory.CreateComm(QuotaHandlerlatest.Id, prdctdata.Id,rectypidq1,null,false);
        comm7.Related_to_Asset__c = assets.Id;
        comm7.Asset_Amount__c = 100;
        comm7.line_type__C = 'Renew';
        comm7.user_team__c =  WLVTerritory;
        comm7.Renewal_w_o_Qualifier_Comm_ble_Amount__c =10.00;
        comm7.Related_Commission__c = comm3.id;
        insert comm7;        
    }    

    public static testMethod void mainTestmethod1() {
        map<Id, Quota__c> mapQuotas = new map<Id,Quota__c>([select Id From Quota__c Limit 1000]);
        Test.StartTest();
            commissions_QuotaPayoutBatch_New qpBatch = new commissions_QuotaPayoutBatch_New(mapQuotas.keySet());
            Database.executeBatch(qpBatch);
        Test.stopTest();
    }
    
    public static testMethod void mainTestmethod2() {
        Test.StartTest();
            commissions_QuotaPayoutBatch_New qpBatch = new commissions_QuotaPayoutBatch_New(null, true);
            Database.executeBatch(qpBatch);
        Test.stopTest();
    }

    public static testMethod void mainTestmethod3() {
        map<Id, Quota__c> mapQuotas = new map<Id,Quota__c>([select Id,User_Team__c,Period_Name__c,User__r.Name,Owner_Name__c,Is_Kicker__c,Final_Collection_Total_Sale__c,
                                Quota_Percentage__c,New_Sale_Tier_Changed__c,Total_Sale__c,Component_1A_Payout__c,Total_Sale_Renewal__c,Manager_Total_Sale_Renewal__c, 
                                Collection_Total_Sale__c,Collection_Target_Amount__c,Renewal_Tier_Changed__c,Component_1B_Payout__c,Total_Clawback_Commission_Amount__c,
                                Collection_Quota_Percentage__c,Manager_Total_Sale__c,Current_Quater__c,ADVANTAGE_New__c,ADVANTAGE_Renew__c,COBROKE_New__c, 
                                COBROKE_Renew__c,DACAMPAIGN_New__c,DACAMPAIGN_Renew__c,DIGITALAGENT_New__c,DIGITALAGENT_Renew__c,DOMAINNAME_New__c,DOMAINNAME_Renew__c, 
                                FEATCMA_New__c,FEATCMA_Renew__c,FEATDISP_New__c,FEATDISP_Renew__c,FEATHOMES_New__c,FEATHOMES_Renew__c,FIVESTREET_New__c, 
                                FIVESTREET_Renew__c,LISTHUBPRO_New__c,LISTHUBPRO_Renew__c,MRKTBUILD_New__c,MRKTBUILD_Renew__c,SELLERLEAD_New__c,SELLERLEAD_Renew__c,
                                SELLERLEADBUNDLE_New__c,SELLERLEADBUNDLE_Renew__c,SHOWCASE_New__c,SHOWCASE_Renew__c,SIGNRIDER_New__c,SIGNRIDER_Renew__c, 
                                STANDLIST_New__c,STANDLIST_Renew__c,TOPCRM_New__c,TOPCRM_Renew__c,TOPIDX_New__c,TOPIDX_Renew__c,TOPMRKSNP_New__c,TOPMRKSNP_Renew__c, 
                                TOPWEB_New__c,TOPWEB_Renew__c,TOPWEBFEE_New__c,TOPWEBFEE_Renew__c,TRKPHNMBR_New__c,TRKPHNMBR_Renew__c,TURBO_New__c,TURBO_Renew__c,
                                WEBSITE_New__c,WEBSITE_Renew__c,WEBSITEFEE_New__c,WEBSITEFEE_Renew__c,REESIO_New__c,REESIO_Renew__c,RSRESPOND_New__c,RSRESPOND_Renew__c,
                                MEDIABUY_New__c ,MEDIABUY_Renew__c,Renewal_Payout__c,Quota_Attainment_Renewal__c,RSCONNECT_New__c, 
                                RSCONNECT_Renew__c,RSTRANSACT_New__c,RSTRANSACT_Renew__c,BETACONNECT_New__c,BETACONNECT_Renew__c, 
                                BETARESPOND_New__c,BETARESPOND_Renew__c,BETATRANSACT_New__c,BETATRANSACT_Renew__c,Record_Processed__c,LocalExpertCity_New__c,LocalExpertCity_Renew__c 
                            From Quota__c Limit 1000]);
        Test.StartTest();
            for(Quota__c q : mapQuotas.values()){
                q.New_Sale_Tier_Changed__c = true;
                q.Renewal_Tier_Changed__c = true;
            }
            commissions_QuotaPayoutBatchHandler_New batchHandler = new commissions_QuotaPayoutBatchHandler_New();
            batchHandler.payoutCalculation(mapQuotas);
        Test.stopTest();
    }
}