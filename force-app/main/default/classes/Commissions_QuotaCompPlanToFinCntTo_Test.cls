@isTest(seeAlldata=true)
public class Commissions_QuotaCompPlanToFinCntTo_Test {
    
    public static testMethod void quotaCompPlanToFinCntTo() { 
    	String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;         
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Adrian Matthews').getRecordTypeId();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',false,ManagerTeam,'Adrian Matthews');      
        user2.firstname ='Adrian';
        user2.LastName = 'Matthews';
        insert user2;
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true); 
        period.End_Date__c = System.today().addDays(10);
        update period;
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true); 
        pa.Period__c = period.Id;
        update pa;
        
        Period__c period1 = Commissions_TestDataClass_New.createPeriod('Test1',System.today(),'Q2',50,50,true);
		period1.End_Date__c = System.today().addDays(10);  
        update period1;
        Payout__c pa1= Commissions_TestDataClass_New.CreatePayout('New Sale with Qualifier',rectypidp1, 50.00, 100.00,null,null,true); 
        pa1.Period__c = period1.Id;
        update pa1;
        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true); 
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuota(user2.id,ManagerTeam,'Q2',period1.Id,true,true); 
        Payout_Tier__c pt = new Payout_Tier__c();
        system.debug('QuotaHandlerlatest='+QuotaHandlerlatest);
        system.debug('QuotaHandlerlatest1='+QuotaHandlerlatest1);
        //pt.name = 'Test';
        pt.Period__c = period.Id;
        pt.Low_Level__c = 10.00;
        pt.High_Level__c =50;
        pt.Sale_Type__c = 'new';
        pt.Tier_Number__c = 'Tier 1';
        insert pt;
        Quota_Product__c qp1 = new Quota_Product__c();
        qp1.Product_Family__c = 'Misc';
        qp1.Related_To_Quota__c = QuotaHandlerlatest.Id;
        insert qp1;
        Quota_Product__c qp2 = new Quota_Product__c();
        qp2.Product_Family__c = 'Turbo';
        qp2.Related_To_Quota__c = QuotaHandlerlatest.Id;
        insert qp2;
        
        Payout_Tier__c pt1 = new Payout_Tier__c();
        //pt.name = 'Test';
        pt1.Period__c = period1.Id;
        pt1.Low_Level__c = 50.00;
        pt1.High_Level__c =100.00;
        pt1.Sale_Type__c = 'new';
        pt1.Tier_Number__c = 'Tier 2';
        insert pt1;
        Payout_Tier__c pt2 = new Payout_Tier__c();
        //pt.name = 'Test';
        pt2.Period__c = period1.Id;
        pt2.Low_Level__c = 100.00;
        pt2.High_Level__c =150.00;
        pt2.Sale_Type__c = 'new';
        pt2.Tier_Number__c = 'Tier 3';
        insert pt2;
        Quota_Product__c qp3 = new Quota_Product__c();
        qp3.Product_Family__c = 'ProSoft';
        qp3.Related_To_Quota__c = QuotaHandlerlatest1.Id;
        insert qp3;
        Quota_Product__c qp4 = new Quota_Product__c();
        qp4.Product_Family__c = 'Advertising';
        qp4.Related_To_Quota__c = QuotaHandlerlatest1.Id;
        insert qp4;
        Quota_Product__c qp5 = new Quota_Product__c();
        qp5.Product_Family__c = 'Lead Products - Buyer';
        qp5.Related_To_Quota__c = QuotaHandlerlatest1.Id;
        insert qp5;
        
        
        PageReference pageRef = Page.Commissions_SendCompPlanToFinance;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,User__c,User__r.Name,Send_Comp_Plan_to__c,Name,User_Team__c,Period_Name__c,Target_Amount__c,Total_Sale_Renewal__c,Collection_Target_Amount__c FROM Quota__c LIMIT 1]));
        sc.setSelected([SELECT Id,User__c,User__r.Name,Name,User_Team__c,Send_Comp_Plan_to__c,Period_Name__c,Target_Amount__c,Total_Sale_Renewal__c,Collection_Target_Amount__c FROM Quota__c LIMIT 1]);
        Commissions_QuotaCompPlanToFinCntrl cntrl = new Commissions_QuotaCompPlanToFinCntrl(sc); 
        
        Test.startTest();
        cntrl.listviewURL = 'https://moveinc--dev--c.cs79.visual.force.com/apex/QuotaCompPlanConfirmation?retURL=%2Fa2e%3Ffcf%3D00Bj0000004PtXv&wrapMassAction=1&scontrolCaching=1';
        cntrl.sendCompPlanToFinanceUserOnly();
        cntrl.goBackandSelectMore();
        Test.stopTest();     
    }
    
}