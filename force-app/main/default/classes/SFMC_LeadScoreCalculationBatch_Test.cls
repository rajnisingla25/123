/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SFMC_LeadScoreCalculationBatch_Test {
    @testsetup
    static void testsetup(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
    }
    
    static testMethod void LeadScoreBatchPositiveTest() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 200);
        Test.stopTest();    
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.LeadScore__c != null);         
    }
    
    static testMethod void LeadScoreEABatchPositiveTest() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false); 
        engagementActivityRecord.Activity_Date__c = system.now();
        insert engagementActivityRecord;
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 200);
        Test.stopTest();    
        
        Lead leadObj = [select id,Last_Engagement_Activity_Date__c from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.Last_Engagement_Activity_Date__c != null);         
    }
    
    static testMethod void LeadScoreBatchForBulkDataPositiveTest() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        
        List<Lead> leadRecords = new List<Lead>();
        for(integer i=0; i< 10 ; i++){
            Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN' + i, 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test',false);
            leadRecords.add(leadRecord);
        }
        insert leadRecords;
          
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        
        List<Engagement_Activity__c> engagementActivityList = new List<Engagement_Activity__c>();
        for(List<Lead> leadRecordsInserted : [select id from Lead]){
            for(Lead leadRecord: leadRecordsInserted){
                Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false);
                engagementActivityList.add(engagementActivityRecord);
            }
        }
        
        Lead singleLeadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN' , 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test2',true);
        
        for(integer i = 0 ; i<10 ; i++){
            Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,singleLeadRecord.id,eaTypeRecord.id,false);
            engagementActivityList.add(engagementActivityRecord);
        }
        
        insert engagementActivityList;
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 2000);
        Test.stopTest();    
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: singleLeadRecord.id];
        
        System.assert(leadObj.LeadScore__c != null);    
        
        System.assertEquals([select count() from Lead where LeadScore__c = null], 0);    
    }
    
    
    
    static testMethod void LeadScoreBatchPositiveTestWithCustomSetting() {
        LeadScoreManageRun__c leadScoreManageRunObj = SFMC_TestDataFactory.createLeadManageRunCustomsetting(SFMC_Constants.LEAD_SCORE_BATCH,System.now().addHours(-1),true);
                
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN', 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test-lead',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 200);
        Test.stopTest();    
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.AssertNotEquals(leadObj.LeadScore__c, null);      
    }
    
        
    static testMethod void LeadScoreBatchNegativeTestWithCustomSetting() {
        DateTime customSettingDate = System.now().addHours(-1);
        LeadScoreManageRun__c leadScoreManageRunObj = SFMC_TestDataFactory.createLeadManageRunCustomsetting(SFMC_Constants.LEAD_SCORE_BATCH,customSettingDate,true);
                
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN', 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test-lead',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        
        Test.startTest();
        SFMC_LeadScoreCalculationBatch leadScoreBatch = new SFMC_LeadScoreCalculationBatch(); 
        leadScoreBatch.isAnyError = true;   
        Database.executeBatch(leadScoreBatch, 200); 
        Test.stopTest();    
        
        //Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        LeadScoreManageRun__c leadCustSettingObj = LeadScoreManageRun__c.getInstance(SFMC_Constants.LEAD_SCORE_BATCH);
        
        System.AssertEquals(leadCustSettingObj.LastRunDate__c, customSettingDate);
             
    }
    
    static testMethod void LeadScoreBatchNegativeTestForUpdateFail() {
        DateTime customSettingDate = System.now().addHours(-1);
        LeadScoreManageRun__c leadScoreManageRunObj = SFMC_TestDataFactory.createLeadManageRunCustomsetting(SFMC_Constants.LEAD_SCORE_BATCH,customSettingDate,true);
                
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN', 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test-lead',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 1000; // One-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }
        
        Test.startTest();
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        leadObj.LastName = null;
        List<Lead> leadUpdateList = new List<Lead>{leadObj};
        SFMC_LeadScoreCalculationHelper.recordErrors(Database.update(leadUpdateList,false), new set<id>{leadObj.id});
        Test.stopTest();    
                
        Engagement_Activity__c updatedEARecord = [select createdDate,LastModifiedDate from Engagement_Activity__c where id =: engagementActivityRecord.id];
        
        System.AssertNotEquals(updatedEARecord.createdDate, updatedEARecord.LastModifiedDate);
             
    }

    static testMethod void LeadScoreBatchPositiveTestWithResetDate() {
        DateTime resetDate = System.now().addDays(-10);
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',resetDate,true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 200);
        Test.stopTest();    
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.LeadScore__c != null);         
    }

    static testMethod void LeadScoreBatchForBulkDataPositiveTestResetDate() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        
        List<Lead> leadRecords = new List<Lead>();
        for(integer i=0; i< 10 ; i++){
            Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN' + i, 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test',System.now().addDays(10-i),false);
            leadRecords.add(leadRecord);
        }
        insert leadRecords;
          
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        
        List<Engagement_Activity__c> engagementActivityList = new List<Engagement_Activity__c>();
        for(List<Lead> leadRecordsInserted : [select id from Lead]){
            for(Lead leadRecord: leadRecordsInserted){
                Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,false);
                engagementActivityList.add(engagementActivityRecord);
            }
        }
        
        //Lead singleLeadRecord = SFMC_TestDataFactory.CreateLead('Test Contact LN' , 'Test Contact FN', 'New',accountRecord.id, contactRecord.id,'test2',true);
        
        for(integer i = 0 ; i<10 ; i++){
            Integer leadIndex = Math.mod(i, 3);
            Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecords.get(leadIndex).id,eaTypeRecord.id,false);
            engagementActivityList.add(engagementActivityRecord);
        }
        
        insert engagementActivityList;
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 2000);
        Test.stopTest();    
        
        //Lead leadObj = [select LeadScore__c,id from Lead where id =: singleLeadRecord.id];
        
        //System.assert(leadObj.LeadScore__c != null);    
        
        System.assertEquals([select count() from Lead where LeadScore__c != null], 0);    
    }
    
}