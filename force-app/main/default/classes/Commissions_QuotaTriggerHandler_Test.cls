@isTest(seeAllData = false)
public class Commissions_QuotaTriggerHandler_Test {
    public static testMethod void mainTest() {
          
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Broker Regional Directors Sales Team');
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
       
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
        period.BOBAmount__c = 1000;
        period.Tiger_Lead_Qualifier_Amount__c = 10000;
        Update period;
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.user_team__c = user1.team__c;
        QuotaHandler.RD_Team_Qualifier__c = true;
        QuotaHandler.Is_Kicker__c = false;
        QuotaHandler.Period_Name__c = period.id;
        insert QuotaHandler;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ; 
        String NewSale = Commissions_Constants.NEW_SALE_WITH_QUALIFIER;
        String NewSale1 = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(NewSale,rectypidp, null, null,1,100,2.25,1.05,2.02,3.00,false);
        pa.Low_Level__c = Null;
        pa.High_Level__c = null;
        pa.Period__c = period.id;
        pa.Commissionable__c = 2.0;        
        insert pa;
        
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(NewSale1,rectypidp1, null, null,1,100,2.25,1.05,2.02,3.00,false);
        pa1.Low_Level__c = Null;
        pa1.High_Level__c = null;
        pa1.Period__c = period.id;
        pa1.Commissionable__c = 2.0;        
        insert pa1; 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c= 20.00;
        comm.Commissionable_Amount1B__c = 10.00;
        insert Comm;
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c= 20.00;
        comm1.Commissionable_Amount1B__c = 10.00;
        insert Comm1;
        
        Map<Id,Quota__c> KickerQuotas =new Map<Id,Quota__c>();
        Map<Id,Quota__c> KickerQuotasold =new Map<Id,Quota__c>();
        KickerQuotasold.put(QuotaHandler.id,QuotaHandler);
        KickerQuotas.put(QuotaHandler.id,QuotaHandler);
        
        Commissions_QuotaTriggerHandler co = new Commissions_QuotaTriggerHandler();
        Test.startTest();
        co.Kicker(KickerQuotas);
        co.RDTeamSplitRatio(KickerQuotas);
        //co.CommissionUpdate2(KickerQuotas);        
        //co.RDQualifier(KickerQuotas);
        //co.ValidateQuotaInSameMonth(KickerQuotas,KickerQuotasold);
        //co.ValidateQuotaInSameMonth_update(KickerQuotas,KickerQuotasold);
        //co.RDTeamPayOutMap1(KickerQuotas);
        //co.RDTeamPayOutMap2(KickerQuotas);
        Test.stopTest();
    }
    public static testMethod void mainTest1() {
          
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Broker Regional Directors Sales Team');
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
       
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
        period.BOBAmount__c = 1000;
        period.Tiger_Lead_Qualifier_Amount__c = 10000;
        Update period;
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.user_team__c = user1.team__c;
        QuotaHandler.RD_Team_Qualifier__c = true;
        QuotaHandler.Is_Kicker__c = true;
        QuotaHandler.Period_Name__c = period.id;
        insert QuotaHandler;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ; 
        String NewSale = Commissions_Constants.NEW_SALE_WITH_QUALIFIER;
        String NewSale1 = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(NewSale,rectypidp, null, null,Null,Null,2.25,1.05,2.02,3.00,false);
        pa.Low_Level__c = 1.0;
        pa.High_Level__c = 100;
        pa.Period__c = period.id;
        pa.Commissionable__c = 2.0;        
        insert pa;
        
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(NewSale1,rectypidp1, null, null,Null,Null,2.25,1.05,2.02,3.00,false);
        pa1.Low_Level__c = 1.0;
        pa1.High_Level__c = 100;
        pa1.Period__c = period.id;
        pa1.Commissionable__c = 2.0;        
        insert pa1; 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c= 20.00;        
        comm1.Commissionable_Amount1B__c = 10.00;
        insert Comm1;
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm12.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 20.00;        
        comm12.Commissionable_Amount1B__c = 10.00;
        insert Comm12;
        
        
        Map<Id,Quota__c> KickerQuotas =new Map<Id,Quota__c>();
        Map<Id,Quota__c> KickerQuotasold =new Map<Id,Quota__c>();
        KickerQuotasold.put(QuotaHandler.id,QuotaHandler);
        KickerQuotas.put(QuotaHandler.id,QuotaHandler);
        
        Commissions_QuotaTriggerHandler co = new Commissions_QuotaTriggerHandler();
        Test.startTest();
        co.Kicker(KickerQuotas);
        co.RDTeamSplitRatio(KickerQuotas);
        //co.CommissionUpdate2(KickerQuotas);        
        //co.RDQualifier(KickerQuotas);
        //co.ValidateQuotaInSameMonth(KickerQuotas,KickerQuotasold);
        //co.ValidateQuotaInSameMonth_update(KickerQuotas,KickerQuotasold);
        //co.RDTeamPayOutMap1(KickerQuotas);
        //co.RDTeamPayOutMap2(KickerQuotas);
        Test.stopTest();
    }
}