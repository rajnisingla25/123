@isTest
public class SFMC_EngagementActivityTypeTrigger_Test {
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
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        Decimal prevScore = leadObj.LeadScore__c;
        
        Test.startTest();
            Engagement_Activity_Type__c updateEATRecord = [select score__c from Engagement_Activity_Type__c where id =: eaTypeRecord.id];
            updateEATRecord.score__c = 150;
            update updateEATRecord;
        Test.stopTest();    
        
        leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.LeadScore__c != prevScore);        
    }
    
    static testMethod void LeadScoreBatchNoChangeTest() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        Decimal prevScore = leadObj.LeadScore__c;
        
        Test.startTest();
            Engagement_Activity_Type__c updateEATRecord = [select score__c from Engagement_Activity_Type__c where id =: eaTypeRecord.id];
            
            update updateEATRecord;
        Test.stopTest();    
        
        leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.LeadScore__c == prevScore);        
    }
    
    static testMethod void LeadScoreBatchBulkTest() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        Lead leadRecord = SFMC_TestDataFactory.CreateLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity_Type__c eaTypeRecord1 = SFMC_TestDataFactory.createEngagementActivtyType('Email open',40,20,true);
        Engagement_Activity_Type__c eaTypeRecord2 = SFMC_TestDataFactory.createEngagementActivtyType('Email open',50,80,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivty(contactRecord.id,leadRecord.id,eaTypeRecord.id,true); 
        
        Lead leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        Decimal prevScore = leadObj.LeadScore__c;
        
        Test.startTest();
            List<Engagement_Activity_Type__c> updateEATRecordList = [select score__c,Dormancy_Score_After_30_Days__c from Engagement_Activity_Type__c ];
            for(Engagement_Activity_Type__c updateEATRecord : updateEATRecordList){
                updateEATRecord.score__c = 100;
                updateEATRecord.Dormancy_Score_After_30_Days__c = 70;
            }
            update updateEATRecordList;
        Test.stopTest();    
        
        leadObj = [select LeadScore__c,id from Lead where id =: leadRecord.id];
        
        System.assert(leadObj.LeadScore__c != prevScore);        
    }
}