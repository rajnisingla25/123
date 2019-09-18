@isTest
private class BatchProcessUpdateRecordTypeLead_Test{
    static testMethod void method1(){
    List<Schedule_Batch_Setting__c> lstScheduleBatchSetting = new List<Schedule_Batch_Setting__c>();
        Schedule_Batch_Setting__c nvmNextContTime = new Schedule_Batch_Setting__c();
        nvmNextContTime.Name = 'NVM Next Contact Time';
        nvmNextContTime.Execution_Min__c = 60;
        nvmNextContTime.Assetresttime__c = 60;
        lstScheduleBatchSetting.add(nvmNextContTime);
        
        Schedule_Batch_Setting__c scheduleSetting = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Execution_Min__c = 1, Assetresttime__c = 1);
        lstScheduleBatchSetting.add(scheduleSetting);
        insert lstScheduleBatchSetting;
        
        Business_Hours__c businessHours = new Business_Hours__c();
        businessHours.Name = 'OwnChange';
        businessHours.Lowermin__c = 1;
        businessHours.UpMin__c = 2;
        insert businessHours;
        
        Business_Hours__c newBusinessHours = new Business_Hours__c();
        newBusinessHours.Name = 'StatusChange';
        newBusinessHours.Lowermin__c = 1;
        newBusinessHours.UpMin__c = 2;
        insert newBusinessHours;
        
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
        
        Lead theLead = TestDataFactory.CreateLead('Test','Test','New',theAccount1.Id,null,'Test',false);
        theLead.Ignore_Owner_Assignment__c = 'Yes';
        //theLead.ownerId = testGroup.Id;
        theLead.NVMConnect__NextContactTime__c = System.now().addMinutes(-6);
        theLead.Callback_Time__c = '6:00 AM';
        insert theLead;
        update theLead;
        Test.startTest();
        
        BatchProcessUpdateRecordTypeLead sh1 = new BatchProcessUpdateRecordTypeLead();    
        database.executebatch(sh1, 25);  
        
        Test.stopTest();
    }
}