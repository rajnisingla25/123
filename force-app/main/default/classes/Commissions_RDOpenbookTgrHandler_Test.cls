@isTest
public class Commissions_RDOpenbookTgrHandler_Test {
    static testMethod void method1(){
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM; 
        Profile p = [select id from profile where name='System Administrator'];       
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',false,'WLV Territory Team');
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        user1.managers__c = 'First Name';
        insert user1;     
        /*
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,null,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.User_Team__c = user1.team__c;
        QuotaHandler.Record_Processed__c = true;            
        insert QuotaHandler;
        */
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        period.Current_Quater__c = 'Q1';
        period.Agent_asset_Owner__c = 50;
        period.asset_Owner__c = 50;       
        insert period;
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.User__c= User1.Id;
        QuotaHandler.User_Team__c = RDTeam;
        QuotaHandler.Period_Name__c = period.id;
        QuotaHandler.Target_Amount_2__c = 1000; 
        try{
        insert QuotaHandler;
        }
        catch(Exception e){}
        //List<Commission__c> allcommissions = new List<Commission__c>();   
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('Open Sale Component',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;  
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c comm = new Commission__c();
        //comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = RDTeam;
        comm.OpenBook_New_Sale_Payout__c = 1.0;
        comm.OpenBook_New_Sale_Commission__c = 2.0;
        comm.OpenBook_New_Sale_Comm_ble_Amount__c = 2000;
        comm.Related_to_Quota__c = QuotaHandler.id;
        insert comm;           
    }
}