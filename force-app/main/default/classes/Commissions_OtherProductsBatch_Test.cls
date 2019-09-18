@isTest(seeAllData = false)
public class Commissions_OtherProductsBatch_Test {         
    public static testMethod void mainTest1(){          
        Profile p = [select id from profile where name='System Administrator'];        
        String RDteam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;
        String NewTeam = Commissions_Constants.NEW_HIRE_TEAM ;
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,RDteam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = 'Heather Riggio';
        update User3;
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124361@mail.com','test154131@move.com',True,NewTeam);
        User4.Managers__c = 'Heather Riggio';
        user4.Team__c = NewTeam;
        user4.Payout_Rate_Month_1__c = 5;
        user4.Payout_Rate_Month_2__c = 5;
        user4.Payout_Rate_Month_3__c = 5;
        update User4;
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =RDteam;
        QuotaHandler1.RD_Payout__c= 100.00;
        QuotaHandler1.Current_Quater__c = 'Q1';
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;
        QuotaHandler2.RD_Payout__c= 100.00;
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.RD_Payout__c= 100.00;
        QuotaHandler3.Current_Quater__c = 'Q1';
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user4.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =NewTeam;
        QuotaHandler4.RD_Payout__c= 100.00;
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
       
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDteam).getRecordTypeId();
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();     
        
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,Null,Null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        Payout__c pa1 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp1, 1.00, 50.00,Null,Null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        insert pa1;
        Payout__c pa2 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 1.00, 50.00,Null,Null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        insert pa2;
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq,null,false);
        comm.user_team__c = RDteam;
        comm.Commissionable_Amount2__c = 500;
        comm.Commissionable_Amount1B__c = 23.00;
        comm.Signing_AE__c  = user1.id;
        comm.Payout_rate__c = 20.00;
        insert comm;       
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm1.user_team__c = ManagerTeam;
        comm1.Commissionable_Amount2__c = 500;
        comm1.Commissionable_Amount1B__c = 23.00;
        comm1.Signing_AE__c  = user2.id;
        comm1.Payout_rate__c = 20.00;
        insert comm1;
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prdctdata.Id,rectypidq,null,false);
        comm2.user_team__c = WLVTeam;
        comm2.Commissionable_Amount2__c = 500;
        comm2.Commissionable_Amount1B__c = 23.00;
        comm2.Signing_AE__c  = user3.id;
        comm2.Payout_rate__c = 20.00;
        insert comm2;  
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandler4.Id, prdctdata.Id,rectypidq,null,false);
        comm3.user_team__c = NewTeam;
        comm3.Commissionable_Amount2__c = 500;
        comm3.Commissionable_Amount1B__c = 23.00;
        comm3.Signing_AE__c  = user3.id;
        comm3.Payout_rate__c = 20.00;
        insert comm3;       
        
        id rectypidq3 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();  
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq3,null,false);
        comm12.user_team__c = RDteam;
        comm12.Commissionable_Amount2__c = 500;
        comm12.Commissionable_Amount1B__c = 23.00;
        comm12.OpenBook_New_Sale_Comm_ble_Amount__c = 40.00;
        comm12.Signing_AE__c  = user1.id;
        comm12.Related_Commission__c = comm.id;
        insert comm12;
        
        Commissions_OtherProductsBatch co = new Commissions_OtherProductsBatch();
        Test.startTest();
        Database.executeBatch(co,200);
        Test.stopTest();
    }
    public static testMethod void mainTest2(){          
        Profile p = [select id from profile where name='System Administrator'];        
        String RDteam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;
        String NewTeam = Commissions_Constants.NEW_HIRE_TEAM ;
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,RDteam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = 'Heather Riggio';
        update User3;
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124361@mail.com','test154131@move.com',True,NewTeam);
        User4.Managers__c = 'Heather Riggio';
        user4.Team__c = NewTeam;
        user4.Payout_Rate_Month_1__c = 5;
        user4.Payout_Rate_Month_2__c = 5;
        user4.Payout_Rate_Month_3__c = 5;
        update User4;
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =RDteam;
        QuotaHandler1.RD_Payout__c= 100.00;
        QuotaHandler1.Current_Quater__c = 'Q1';
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;
        QuotaHandler2.RD_Payout__c= 100.00;
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.RD_Payout__c= 100.00;
        QuotaHandler3.Current_Quater__c = 'Q1';
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user4.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =NewTeam;
        QuotaHandler4.RD_Payout__c= 100.00;
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
       
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDteam).getRecordTypeId();
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();     
        
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, Null, Null,1.0,100.0,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa; 
        Payout__c pa1 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp1, Null, Null,1.0,100.0,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        insert pa1;
        Payout__c pa2 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, Null, Null,1.0,100.0,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        insert pa2;
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq,null,false);
        comm.user_team__c = RDteam;
        comm.Commissionable_Amount2__c = 50000;
        comm.Commissionable_Amount1B__c = 23.00;
        comm.Signing_AE__c  = user1.id;
        comm.Payout_rate__c = 20.00;
        insert comm;       
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prdctdata.Id,rectypidq,null,false);
        comm1.user_team__c = ManagerTeam;
        comm1.Commissionable_Amount2__c = 50000;
        comm1.Commissionable_Amount1B__c = 23.00;
        comm1.Signing_AE__c  = user2.id;
        comm1.Payout_rate__c = 20.00;
        insert comm1;
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prdctdata.Id,rectypidq,null,false);
        comm2.user_team__c = WLVTeam;
        comm2.Commissionable_Amount2__c = 50000;
        comm2.Commissionable_Amount1B__c = 23.00;
        comm2.Signing_AE__c  = user3.id;
        comm2.Payout_rate__c = 20.00;
        insert comm2;  
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandler4.Id, prdctdata.Id,rectypidq,null,false);
        comm3.user_team__c = NewTeam;
        comm3.Commissionable_Amount2__c = 50000;
        comm3.Commissionable_Amount1B__c = 23.00;
        comm3.Signing_AE__c  = user3.id;
        comm3.Payout_rate__c = 20.00;
        insert comm3;       
        
        id rectypidq3 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();  
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq3,null,false);
        comm12.user_team__c = RDteam;
        comm12.Commissionable_Amount2__c = 50000;
        comm12.Commissionable_Amount1B__c = 23.00;
        comm12.OpenBook_New_Sale_Comm_ble_Amount__c = 40.00;
        comm12.Signing_AE__c  = user1.id;
        comm12.Related_Commission__c = comm.id;
        insert comm12;
        Commission__c  comm21 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prdctdata.Id,rectypidq3,null,false);
        comm21.user_team__c = WLVTeam;
        //comm21.Commissionable_Amount2__c = 50000;
        comm21.Commissionable_Amount1B__c = 23.00;
        comm21.Signing_AE__c  = user3.id;
        comm21.Payout_rate__c = 20.00;
        insert comm21;  
        Commission__c  comm31 = Commissions_TestDataFactory.CreateComm(QuotaHandler4.Id, prdctdata.Id,rectypidq3,null,false);
        comm31.user_team__c = NewTeam;
        //comm31.Commissionable_Amount2__c = 50000;
        comm31.Commissionable_Amount1B__c = 23.00;
        comm31.Signing_AE__c  = user3.id;
        comm31.Payout_rate__c = 20.00;
        insert comm31;
        Commission__c  comm41 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq3,null,false);
        comm41.user_team__c = RDteam;
        //comm.Commissionable_Amount2__c = 50000;
        comm41.Commissionable_Amount1B__c = 23.00;
        comm41.Signing_AE__c  = user1.id;
        comm41.Payout_rate__c = 20.00;
        insert comm41;
        
        Commissions_OtherProductsBatch co = new Commissions_OtherProductsBatch();
        Test.startTest();
        Database.executeBatch(co,200);
        Test.stopTest();
    }
}