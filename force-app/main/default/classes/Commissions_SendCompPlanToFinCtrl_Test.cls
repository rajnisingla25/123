@isTest(Seealldata = true)
public class Commissions_SendCompPlanToFinCtrl_Test {
    
    static testmethod void testupdateQuotaSendCompensationToFinance(){
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        
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
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        SkipUserTrigger.setSkipTrgTrue();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio1');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,ManagerTeam,'Heather Riggio2');      
        User user3 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1543@move.com','testq1543@move.com',true,WLVTerritory,'Heather Riggio3');
        User user4 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1544@move.com','testq1544@move.com',true,ManagerTeam,'Heather Riggio4');
        
        SkipAccountTrigger.setSkipTrgTrue();        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),brokerRDteam,50,50,true);   
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,brokerRDteam,period.Id,true,false);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,'Managers Team',brokerRDteam,period.Id,false,false);  
        Quota__c  QuotaHandlerlatest3 = Commissions_TestDataFactory_New.CreateQuota(user3.id,WLVTerritory,brokerRDteam,period.Id,true,true);
        Quota__c  QuotaHandlerlatest4 = Commissions_TestDataFactory_New.CreateQuota(user4.id,'Managers Team',brokerRDteam,period.Id,false,true);
        
        List<Quota__c> lstQuota = [Select Id,Send_Comp_Plan_to__c From Quota__c LIMIT 1];
        Commissions_SendCompPlanToFinanceCtrl.updateSendCompensationPlanToFinance(null);
        Commissions_SendCompPlanToFinanceCtrl.updateSendCompensationPlanToFinance(lstQuota[0].Id);
        
    }

}