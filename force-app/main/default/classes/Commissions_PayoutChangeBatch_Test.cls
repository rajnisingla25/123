@isTest(seeAllData = false)
public class Commissions_PayoutChangeBatch_Test {
    /**
    public static testMethod void mainTest() {
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;
        string AOPayout = Commissions_Constants.ASSET_OWNER_COMPONENTS;     
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser1246@mail.com','test154@move.com',True,WLVTeam);
        User1.LastName ='FName';
        update User1;        
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser12461@mail.com','test1541@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;      
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        system.debug('cAccount:' + cAccount.Id);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.User_team__c = WLVTeam;   
        QuotaHandler.Is_Kicker__c = TRUE;   
        insert QuotaHandler;
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.User_team__c = ManagerTeam;        
        insert QuotaHandler1;
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        insert prdctdata;     
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        Comm.user_team__c = WLVTeam;
        insert comm;
         
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prdctdata.Id,rectypidq,null,false);
        Comm1.user_team__c = ManagerTeam;
        insert comm1; 
        
        String Component3 = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(Component3,rectypidp,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        pa.Payout_Change_Status__c = 'Approved';
        pa.Record_Processed__c = FALSE;
        insert pa;
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(Component3,rectypidp,0.0,0.0,Null,Null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Payout_Change_Status__c = 'Approved';
        pa1.Record_Processed__c = FALSE;
        insert pa1;
        
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId(); 
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout(Component3,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa2.Name = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        pa2.Commissionable__c = 10.00;
        pa2.Period__c = period.Id;
        pa2.Payout_Change_Status__c = 'Approved';
        pa2.Record_Processed__c = FALSE;
        insert pa2; 
        
        String Component2A = Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER;
        String Component2B = Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER;
        String Component2C = Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER;
        String Component2D = Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER;
        
        Payout__c pa21= Commissions_TestDataFactory.CreatePayout(Component2A,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa21.Name = Component2A;
        pa21.Commissionable__c = 10.00;
        pa21.Period__c = period.Id;
        pa21.Payout_Change_Status__c = 'Approved';
        pa21.Record_Processed__c = FALSE;
        insert pa21; 
        Payout__c pa22= Commissions_TestDataFactory.CreatePayout(Component2B,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa22.Name = Component2B;
        pa22.Commissionable__c = 10.00;
        pa22.Period__c = period.Id;
        pa22.Payout_Change_Status__c = 'Approved';
        pa22.Record_Processed__c = FALSE;
        insert pa22;
        Payout__c pa23= Commissions_TestDataFactory.CreatePayout(Component2C,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa23.Name = Component2C;
        pa23.Commissionable__c = 10.00;
        pa23.Period__c = period.Id;
        pa23.Payout_Change_Status__c = 'Approved';
        pa23.Record_Processed__c = FALSE;
        insert pa23;
        Payout__c pa24= Commissions_TestDataFactory.CreatePayout(Component2D,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa24.Name = Component2D;
        pa24.Commissionable__c = 10.00;
        pa24.Period__c = period.Id;
        pa24.Payout_Change_Status__c = 'Approved';
        pa24.Record_Processed__c = FALSE;
        insert pa24;
        pa24.Commissionable__c = 100.00;
        update pa24;        
        Commissions_PayoutChangeBatch co = new Commissions_PayoutChangeBatch();
        Test.startTest();
        Database.executeBatch(co,200);
        Test.stopTest();
    }
    public static testMethod void mainTest1() {
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        string AOPayout = Commissions_Constants.ASSET_OWNER_COMPONENTS;     
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser1246@mail.com','test154@move.com',True,RDTeam);
        User1.LastName ='FName';
        update User1;        
              
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;      
                
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.User_team__c = RDTeam;   
        QuotaHandler.Is_Kicker__c = TRUE;   
        insert QuotaHandler;
       
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        insert prdctdata;     
       
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        Comm.user_team__c = RDTeam;
        insert comm; 
                       
        String Component3 = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout(Component3,rectypidp1,Null,Null, 0, 0,2.25,1.05,2.02,3.00,false);
        pa2.Name = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        pa2.Commissionable__c = 10.00;
        pa2.Period__c = period.Id;
        pa2.Payout_Change_Status__c = 'Approved';
        pa2.Record_Processed__c = FALSE;
        insert pa2; 
        
        Commissions_PayoutChangeBatch co = new Commissions_PayoutChangeBatch();
        Test.startTest();
        Database.executeBatch(co,200);
        Test.stopTest();
    }
    **/
}