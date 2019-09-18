@isTest(seeAllData = false)
public class Commissions_TriggerHandler_Test {
/*
private static Boolean IsUpdate;
    public static testMethod void mainTest1() {
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test1541@move.com',true,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather ';
        update User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542@move.com','test1542@move.com',true,WLVTeam);
        user1.Managers__c = 'Heather Riggio';
        update User1;
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1543@move.com','test1543@move.com',true,RDTeam);
        user3.Managers__c = 'Heather Riggio';
        update User3;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;  
        QuotaHandler.Is_Kicker__c = false; 
        QuotaHandler.User_team__c = WLVTeam;     
        insert QuotaHandler;
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = ManagerTeam;     
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;     
        insert QuotaHandler2;
       
        string NewSale =    Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER;
        String CfcbRnwqlr = Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER;
        String CfcbRnwqlr1 =Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER;
        string NewSale1 = Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER;
        string NewSaleAsseOwner = Commissions_Constants.ASSET_OWNER_COMPONENTS;
              
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
        insert prdctdata; 
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId(); 
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr1,rectypidp, 1, 100,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr,rectypidp, 1,100,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        insert pa1;
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout(NewSaleAsseOwner,rectypidp1,10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        insert pa2;
        Payout__c pa3 = Commissions_TestDataFactory.CreatePayout(NewSale ,rectypidp2 , 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        insert pa3;
        
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,True);        
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets1.Sign_in_AE__c = user1.id;
        assets1.Ownerid = user3.id;
        assets1.Renewal_Type__c = 'Auto';
        insert assets1;
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        id rectypidqcb = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();    
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = WLVTeam;
        comm.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c= 100.00;
        comm.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 20.00;
        comm.Payout_Rate_3__c =10;
        comm.Payout_rate__c = 10;
        comm.Payout_rate1B__c = 10; 
        insert comm; 
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets1.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        comm1.Payout_Rate_3__c =10;
        comm1.Payout_rate__c = 10;
        comm1.Payout_rate1B__c = 10; 
        insert comm1;
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets1.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = RDTeam;
        //comm2.Signing_AE__c = user3.id;
        comm2.Payout_Rate_3__c =10;         
        comm2.Payout_rate__c = 10;
        comm2.Payout_rate1B__c = 10;
        insert comm2; 
        
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidqcb,null,false);
        comm12.Related_to_Asset__c = assets1.Id;
        comm12.Asset_Amount__c = 100;
        comm12.user_team__c = ManagerTeam;
        comm12.Commissionable_Amount2__c = 90; 
        comm12.Payout_Rate1B__c = 1.0;
        comm12.Commissionable_Amount1B__c = 90; 
        comm12.Payout_Rate_3__c =10; 
        comm12.Payout_Rate_3__c =10;         
        comm12.Payout_rate__c = 10;
        comm12.Payout_rate1B__c = 10; 
        comm12.Related_Commission__c = comm2.id; 
        insert comm12;
        
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(comm.id);
        allCommissionIds.add(comm1.id);
        allCommissionIds.add(comm2.id);
        allCommissionIds.add(comm12.id);
        Test.startTest();
            Commissions_TriggerHandlerClass.OnIsinsert(allCommissionIds,True);
        Test.stopTest();
    }

    public static testMethod void mainTest2() {
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test1541@move.com',true,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather ';
        update User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542@move.com','test1542@move.com',true,WLVTeam);
        user1.Managers__c = 'Heather Riggio';
        update User1;
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1543@move.com','test1543@move.com',true,RDTeam);
        user3.Managers__c = 'Heather Riggio';
        update User3;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;  
        QuotaHandler.Is_Kicker__c = false; 
        QuotaHandler.User_team__c = WLVTeam;     
        insert QuotaHandler;
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = ManagerTeam;     
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;     
        insert QuotaHandler2;
       
        string NewSale =    Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER;
        String CfcbRnwqlr = Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER;
        String CfcbRnwqlr1 =Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER;
        string NewSale1 = Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER;
        string NewSaleAsseOwner = Commissions_Constants.ASSET_OWNER_COMPONENTS;
        string newsalewo = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;      
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
        insert prdctdata; 
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId(); 
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr1,rectypidp, 1, 100,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr,rectypidp, 1,100,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        insert pa1;
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout(NewSaleAsseOwner,rectypidp1,10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        insert pa2;
        Payout__c pa3 = Commissions_TestDataFactory.CreatePayout(NewSale ,rectypidp2 , 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        insert pa3;
        
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout(newsalewo,rectypidp1,10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        insert pa4;
        
        Payout__c pa5 = Commissions_TestDataFactory.CreatePayout(newsalewo,rectypidp2 , 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Period__c = period.Id;
        insert pa5;
        
        Payout__c pa6 = Commissions_TestDataFactory.CreatePayout(newsalewo,rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa6.Period__c = period.Id;
        insert pa6;
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,True);        
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets1.Sign_in_AE__c = user1.id;
        assets1.Ownerid = user3.id;
        assets1.Renewal_Type__c = 'Auto';
        insert assets1;
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        id rectypidqcb = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = WLVTeam;
        //comm.Commissionable_Amount2__c = 80;
        comm.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c= 100.00;
        comm.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 20.00;
        comm.Payout_Rate_3__c =10;         
        comm.Payout_rate__c = 10;
        comm.Payout_rate1B__c = 10;
        insert comm; 
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets1.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        comm1.Payout_Rate_3__c =10;         
        comm1.Payout_rate__c = 10;
        comm1.Payout_rate1B__c = 10;
        insert comm1;
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets1.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = RDTeam;
        //comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        comm2.Signing_AE__c = user3.id;  
        comm2.Payout_Rate_3__c =10;         
        comm2.Payout_rate__c = 10;
        comm2.Payout_rate1B__c = 10; 
        insert comm2; 
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidqcb,null,false);
        comm12.Related_to_Asset__c = assets1.Id;
        comm12.Asset_Amount__c = 100;
        comm12.user_team__c = ManagerTeam;
        comm12.Commissionable_Amount2__c = 90;
        comm12.Payout_Rate1B__c = 1.0;
        comm12.Commissionable_Amount1B__c = 90; 
        comm12.Payout_Rate_3__c =10;         
        comm12.Payout_rate__c = 10;
        comm12.Payout_rate1B__c = 10;
        comm12.Related_Commission__c = comm2.id;
        insert comm12;
        
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(comm.id);
        allCommissionIds.add(comm1.id);
        allCommissionIds.add(comm2.id);
        allCommissionIds.add(comm12.id);
        Test.startTest();
            Commissions_TriggerHandlerClass.OnIsinsert(allCommissionIds,True);
        Test.stopTest();
    }
    
    public static testMethod void mainTest3() {
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        String NewTeam = Commissions_Constants.NEW_HIRE_TEAM;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test1541@move.com',true,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather ';
        update User2; 
    
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1543@move.com','test1543@move.com',true,RDTeam);
        user3.Managers__c = 'Heather Riggio';
        update User3;
        
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15431@move.com','test15431@move.com',true,NewTeam);
        user4.Managers__c = 'Heather Riggio';
        update User4;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());     
   
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = ManagerTeam;     
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;     
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler21 = Commissions_TestDataFactory.CreateQuota(user4.id,period.id,false);
        QuotaHandler21.Target_Amount__c = 1000;  
        QuotaHandler21.Is_Kicker__c = True; 
        QuotaHandler21.User_team__c = NewTeam;     
        insert QuotaHandler21;
       
       
        string NewSale =    Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER;
        String CfcbRnwqlr = Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER;
        String CfcbRnwqlr1 =Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER;
        string NewSale1 = Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER;
        string NewSaleAsseOwner = Commissions_Constants.ASSET_OWNER_COMPONENTS;
        string newsalewo = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;      
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
        insert prdctdata; 
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId(); 
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr1,rectypidp, 1, 100,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(CfcbRnwqlr,rectypidp, 1,100,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        insert pa1;
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout(NewSaleAsseOwner,rectypidp1,1,100.00,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        insert pa2;
        Payout__c pa3 = Commissions_TestDataFactory.CreatePayout(NewSale ,rectypidp2 , 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        insert pa3;
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout(NewSalewo ,rectypidp1,1,100.00,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        insert pa4;
        Payout__c pa5= Commissions_TestDataFactory.CreatePayout('Open Sale Component' ,rectypidp1,1,100.00,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Commissionable__c = 5.00;
        pa5.Period__c = period.Id;
        insert pa5;
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,True);        
        Asset assets1 = Commissions_TestDataFactory.CreateAsset(rectypidasset,user2.Id,prdctdata.Id,false);
        assets1.Sign_in_AE__c = user2.id;
        assets1.Ownerid = user3.id;
        assets1.Renewal_Type__c = 'Auto';
        insert assets1;
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        id rectypidqcb = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId(); 
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets1.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        comm1.Commissionable_Amount2__c = 90; 
        comm1.Commissionable_Amount1B__c= 10;
        comm1.Payout_Rate_3__c =10;         
        comm1.Payout_rate__c = 10;
        comm1.Payout_rate1B__c = 10;
        comm1.OpenBook_New_Sale_Comm_ble_Amount__c = 10;                
        insert comm1;
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets1.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = RDTeam;
        comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        comm2.Signing_AE__c = user3.id;
        comm2.Payout_Rate_3__c =10;         
        comm2.Payout_rate__c = 10;
        comm2.Payout_rate1B__c = 10;
        comm2.Related_Commission__c = comm1.id; 
        comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm2.Commissionable_Amount1B__c= 10;
        comm2.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm2.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10;    
        comm2.CFCB_RNW_w_Qualifier_Payout_Rate2C__c= 10;   
        comm2.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c= 10;   
        comm2.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = 10;                    
        insert comm2; 
        
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidqcb,null,false);
        comm12.Related_to_Asset__c = assets1.Id;
        comm12.Asset_Amount__c = 100;
        comm12.user_team__c = RDTeam;
        comm12.Commissionable_Amount2__c = 90;
        comm12.Payout_Rate1B__c = 1.0;
        comm12.Commissionable_Amount1B__c = 90;
        comm12.Related_Commission__c = comm2.id; 
        comm12.Payout_Rate_3__c =10;         
        comm12.Payout_rate__c = 10;
        comm12.Payout_rate1B__c = 10; 
        comm12.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm12.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10;
        comm12.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 10;  
        insert comm12;
        
    
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(comm1.id);
        allCommissionIds.add(comm2.id);
        allCommissionIds.add(comm12.id);
        Test.startTest();
            Commissions_TriggerHandlerClass.OnIsinsert(allCommissionIds,True);
        Test.stopTest();
    }
    */
}