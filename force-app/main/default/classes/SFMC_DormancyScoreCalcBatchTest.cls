@isTest
public class SFMC_DormancyScoreCalcBatchTest {
     @testsetup
        static void testsetup(){
            DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
                insert Dtrg;
                
                Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
                insert bh;
                Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
                insert bh1;
        }    
    static testmethod  void dormancyScorePositiveTest(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',false);
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,false);
        eaTypeRecord.Dormancy_Score_After_15_Days__c = 20;
        eaTypeRecord.Dormancy_Score_After_30_Days__c = 15;
        eaTypeRecord.Dormancy_Score_After_60_Days__c = 5;
        insert eaTypeRecord;
        //Create record with 60 days difference
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false);
        engagementActivityRecord.Activity_Date__c = Datetime.now().addDays(-61);
        insert engagementActivityRecord;

        //create record with 120+ difference
        Engagement_Activity__c engagementActivityOlderRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false);
        engagementActivityOlderRecord.Activity_Date__c = Datetime.now().addDays(-121);
        insert engagementActivityOlderRecord;
        
        Test.startTest();
            Database.executeBatch(new SFMC_DormancyScoreCalcBatch(), 200);
        
        Test.stopTest();
        
        Engagement_Activity__c updatedEARecord  = [select score__c,Score_Formula__c from Engagement_Activity__c where id =:engagementActivityRecord.id];
        
        System.debug('updatedEARecord.score__c >>'+updatedEARecord.score__c);
        System.debug('updatedEARecord.Score_Formula__c >>'+updatedEARecord.Score_Formula__c);
        System.AssertEquals(updatedEARecord.score__c, updatedEARecord.Score_Formula__c);
        
        system.AssertEquals([select count() from Engagement_Activity__c where id =: engagementActivityOlderRecord.id],0);
        
    }
    

    static testmethod void dormancyScoreBulkTest(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',false);
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,false);
        eaTypeRecord.Dormancy_Score_After_15_Days__c = 20;
        eaTypeRecord.Dormancy_Score_After_30_Days__c = 15;
        eaTypeRecord.Dormancy_Score_After_60_Days__c = 5;
        insert eaTypeRecord;
        
        List<Engagement_Activity__c> engagementActivityList = new List<Engagement_Activity__c>();
        for(integer i=0; i < 100; i++){
            Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false);
            engagementActivityRecord.Activity_Date__c = Datetime.now().addDays(-20);
            engagementActivityList.add(engagementActivityRecord);
        }
        
        insert engagementActivityList;

        
        Test.startTest();
            Database.executeBatch(new SFMC_DormancyScoreCalcBatch(), 200);           
        Test.stopTest();
                
        
        Engagement_Activity__c updatedEARecord  = [select score__c,Score_Formula__c from Engagement_Activity__c where id =:engagementActivityList[0].id];
        System.AssertEquals(updatedEARecord.score__c, updatedEARecord.Score_Formula__c);
    }
    
    static testMethod void testSchedule() {
        Test.StartTest();
          SFMC_DormancyScoreCalcBatch sh1 = new SFMC_DormancyScoreCalcBatch();      
          String sch = '0 0 23 * * ?';
              system.schedule('Test check', sch, sh1);
        Test.stopTest();
      
    }
}