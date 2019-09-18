@isTest(seeAllData = false)
public class Commissions_CreateRetentionComms_Test {
    public static testMethod void mainTest() {        
       
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test1541@move.com',true,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather ';
        update User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542@move.com','test1542@move.com',true,'Retention Team');
        user1.Managers__c = 'Heather Riggio';
        update User1;
       
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);        
        
        Integer YearValue = system.today().Year();       
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;  
        QuotaHandler.Is_Kicker__c = false; 
        QuotaHandler.User_team__c = 'Retention Team';     
        insert QuotaHandler;
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = ManagerTeam;     
        insert QuotaHandler1;
           
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'NORMAL';
        insert prdctdata;         
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Retention Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('Retention New Sale',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.Product2Id = prdctdata .id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        insert assets;
       
        id rectypidcase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention', Record_Type_Id__c = rectypidcase);
        insert setting;
         
        case c =new case();
        c.RecordTypeId =rectypidcase;
        c.Type= 'Retention';
        c.Status='Closed';
        c.OwnerId=user1.id;        
        c.AccountId = Acc.Id;
        c.Origin='Email';
        c.Area__c='Billing';        
        c.Subject='aaaa';
        c.Description='ssssss';
        insert c; 
        
        Map<id,Case> CaseAll = new Map<id,Case>();
        CaseAll.put(c.id,c);
        
        
        Case_Asset_Relationship__c cr = new Case_Asset_Relationship__c();
        cr.Case__c= c.id;
        cr.Asset__c= assets.id;
        cr.At_Risk_Amount__c = 20.00;
        cr.New_Risk__c = 10.00;
        cr.Saved_Amount__c = 21.00;
        insert cr;
        Map<id,Case_Asset_Relationship__c> NewCaseAsset = new Map<id,Case_Asset_Relationship__c>();
        NewCaseAsset.put(cr.id,cr);
        
        AccountTeamMember at =new AccountTeamMember();
        at.AccountId= acc.id;
        at.UserId=user1.id;
        insert at;
         id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        
        Commission__c  commission1 = new Commission__c();
        commission1.RecordTypeId = rectypidq;
        commission1.Related_to_Quota__c = QuotaHandler1.id;
        commission1.Product__c = prdctdata.id;
        commission1.Other_Product__c ='Top Producer';       
        commission1.Related_to_Asset__c = cr.Asset_type__c;
        commission1.Asset_Amount__c= cr.Saved_Amount__c;
        commission1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c=0.00;
        commission1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c=0.00;
        commission1.Retention_Commissionable_Amount1__c = 40.00;
        commission1.Commissionable_Amount2__c = 3.00;
        commission1.Commissionable_Amount3__c = 12.00;
        commission1.Signing_AE__c = at.UserID;
        commission1.Type__c = 'Retention';
        commission1.Case__c = c.id;
        insert commission1;
        
        Commission__c  commission12 = new Commission__c();
        commission12.RecordTypeId = rectypidq;
        commission12.Related_to_Quota__c = QuotaHandler.id;
        commission12.Product__c = prdctdata.id;
        commission12.Other_Product__c ='Top Producer';       
        commission12.Related_to_Asset__c = cr.Asset_type__c;
        commission12.Asset_Amount__c= cr.Saved_Amount__c;
        commission12.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c=0.00;
        commission12.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c=0.00;
        commission12.Retention_Commissionable_Amount1__c = 40.00;
        commission12.Commissionable_Amount2__c = 3.00;
        commission12.Commissionable_Amount3__c = 12.00;
        commission12.Signing_AE__c = at.UserID;
        commission12.Type__c = 'Retention';
        commission12.Case__c = c.id;
        insert commission12;
       
        Map<id,Commission__c> NewCaseCommissionList =  new Map<id,commission__c>();
        NewCaseCommissionList.put(commission1.id,commission1);
        
        set<Id> RetentionCommIds = new set<Id>();
        RetentionCommIds.add(commission1.id);
          
        Commissions_CreateRetentionCommsClass co = new Commissions_CreateRetentionCommsClass();
        Test.startTest();
        co.CaseCommission(CaseAll); 
        //Commissions_CreateRetentionCommsClass.CommissionCalculation(RetentionCommIds);       
        Test.stopTest();
    }
   
}