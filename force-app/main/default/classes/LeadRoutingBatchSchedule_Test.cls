@isTest
private class LeadRoutingBatchSchedule_Test{
    static testMethod void method1(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;       
        Robin_Round__c rb = new Robin_Round__c(Name = 'MaxCount',Default_Size__c = 50);
        insert rb;      
        Lead_Custom_Setting__c lcs = new Lead_Custom_Setting__c(Name='LeadSetting',Lead__c='Event,Webinar,RDC Webinar,Un Specified');
        insert lcs;
        Lead_Batch_Schedule__c lbs = new Lead_Batch_Schedule__c(Name='LeadRoutingBatchSchedule',Value__c='No');
        insert lbs;
        Account theAccount1 = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount1.Primary_Email__c = 'theAccount@move.com';  
        insert theAccount1;   
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        Lead theLead = TestDataFactory.CreateLead('Test','Test','New',theAccount1.Id,null,'Test',false); 
        theLead.Ignore_Owner_Assignment__c = 'No';
        theLead.ownerId = testGroup.Id ;       
        insert theLead;
        update theLead;
        test.startTest();
            LeadRoutingBatchSchedule sh1 = new LeadRoutingBatchSchedule();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}