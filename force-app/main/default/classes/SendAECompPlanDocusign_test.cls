@isTest(Seealldata = true)
public class SendAECompPlanDocusign_test {
    Public Static String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
    Public Static String ManagerTeam = Commissions_Constants.MANAGERS_TEAM; 
	Public Static String CollectionsTeam = Commissions_Constants.COLLECTION_TEAM;    
    Public Static string type = Constants.OFFICE_ACCOUNT_TYPE;
    /*
    @testSetup static void initiateData(){
        Commissions_AssetsBatchJobSch_New_Test.setTestData();
        Comp_Plan_Docusign_Cred__c cred = new Comp_Plan_Docusign_Cred__c(Name='test');        
        cred.AccountId__c = 'testAcc'; 
        cred.UserId__c = 'testUserId';
        cred.Password__c = 'TestPasswd';
        cred.IntegratorsKey__c = 'TestIntegKey';
        cred.WebServiceUrl__c = 'TestWebService';
        insert cred;
        //User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,CollectionsTeam,'Heather Riggio');      
 
        //Quota__c  QuotaHandlerlatest2 = Commissions_TestDataClass_New.CreateQuota(user1.id,CollectionsTeam,'Q2',period2.Id,true,true);
        
    }*/
    
	public static testmethod void testMethod1() { 
                
        /*DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg; */
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Adrian Matthews').getRecordTypeId();
        id rectypidCollTeam = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(CollectionsTeam).getRecordTypeId();
        id rectypidCollMgr = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Collections Client Relations Manager').getRecordTypeId();
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testtest111@move.com','testtest111@move.com',true,WLVTerritory,'Heather Riggio');      
        User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testqtest111@move.com','testqtest111@move.com',false,ManagerTeam,'Adrian Matthews');      
        user2.firstname ='Adrian';
        user2.LastName = 'Matthews';
        insert user2;
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataClass_New.createPeriod('Test',System.today(),'Q1',50,50,true); 
        period.End_Date__c = System.today().addDays(10);
        update period;
        Payout__c pa= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true); 
        pa.Period__c = period.Id;
        pa.Commissionable__c = 2.8688;
        update pa;
        
        Period__c period1 = Commissions_TestDataClass_New.createPeriod('Test1',System.today(),'Q2',50,50,true);
		period1.End_Date__c = System.today().addDays(10);  
        update period1;
        Payout__c pa1= Commissions_TestDataClass_New.CreatePayout('New Sale with Qualifier',rectypidp1, 50.00, 100.00,null,null,true); 
        pa1.Period__c = period1.Id;
        pa1.Commissionable__c = 1.78567;
        update pa1;
        
        Period__c period2 = Commissions_TestDataClass_New.createPeriod('Test1',System.today(),'Q2',50,50,true);
		period2.End_Date__c = System.today().addDays(10);  
        update period2;
        Payout__c pa2= Commissions_TestDataClass_New.CreatePayout('New Sale with Qualifier',rectypidp1, 50.00, 100.00,null,null,true); 
        pa2.Period__c = period2.Id;
        pa2.Commissionable__c = 7.9797;
        update pa2;
        
        Payout__c collectionPayout= Commissions_TestDataClass_New.CreatePayout('New Sale with Qualifier',rectypidCollTeam, 0.00, 150.00,null,null,false); 
        collectionPayout.Period__c = period2.Id;
        collectionPayout.Commissionable__c = 2.8769;
        upsert collectionPayout;
        
        
        Payout__c collectionMgrPayout= Commissions_TestDataClass_New.CreatePayout('New Sale with Qualifier',rectypidp1, 0.00, 150.00,null,null,false); 
        collectionMgrPayout.Period__c = period2.Id;
        collectionMgrPayout.Commissionable__c = 1.5765;
        upsert collectionMgrPayout;
        
        Payout__c collMgrPayoutWQ= Commissions_TestDataClass_New.CreatePayout('New Sale without Qualifier',rectypidp1, 0.00, 150.00,null,null,false); 
        collMgrPayoutWQ.Period__c = period2.Id;
        collMgrPayoutWQ.Commissionable__c = 0.2341;
        upsert collMgrPayoutWQ;
        
        Quota__c  QuotaHandlerlatest = Commissions_TestDataClass_New.CreateQuota(user1.id,WLVTerritory,'Q1',period.Id,false,true); 
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataClass_New.CreateQuota(user2.id,ManagerTeam,'Q2',period1.Id,true,true); 
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataClass_New.CreateQuota(user1.id,CollectionsTeam,'Q2',period2.Id,true,true);
        Quota__c  QuotaHandlerlatest3 = Commissions_TestDataClass_New.CreateQuota(user2.id,ManagerTeam,'Q2',period2.Id,true,true);
        QuotaHandlerlatest3.Collection_Target_Amount__c = 12334;
        update QuotaHandlerlatest3;
        
        Payout_Tier__c pt = new Payout_Tier__c();
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
        
        Payout_Tier__c pt3 = new Payout_Tier__c();
        //pt.name = 'Test';
        pt3.Period__c = period2.Id;
        pt3.Low_Level__c = 0.00;
        pt3.High_Level__c =150.00;
        pt3.Sale_Type__c = 'new';
        pt3.Tier_Number__c = 'Tier 1';
        insert pt3;
        
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
        
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());     
        SendAECompPlanDocusign.getDsShortName('Co Broker for Connection');
        SendAECompPlanDocusign.SendNow(new Set<Id>{QuotaHandlerlatest.id},false);
        SendAECompPlanDocusign.SendNow(new Set<Id>{QuotaHandlerlatest1.Id},false); 
        SendAECompPlanDocusign.SendNow(new Set<Id>{QuotaHandlerlatest2.id},false);
        SendAECompPlanDocusign.SendNow(new Set<Id>{QuotaHandlerlatest3.Id},false); 
        Test.stopTest();  
    }
    
     private class WebServiceMockImplementation1 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response_map_x,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
           DocuSignAPI.CreateAndSendEnvelopeResponse_element respElement = new DocuSignAPI.CreateAndSendEnvelopeResponse_element ();
           DocuSignAPI.EnvelopeStatus SendEnvelopeResult  = new DocuSignAPI.EnvelopeStatus();
             SendEnvelopeResult.Status = 'Success';            
               SendEnvelopeResult.EnvelopeID = '12345';
       response_map_x.put('response_x', respElement);      
        
        }
    }
}