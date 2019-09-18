@isTest
private class BatchProcessCase_Test {
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
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
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
        
        Case theCase = new Case(
            Subject = 'subject',
            Status = 'Closed',
            Type = 'theType',
            Is_Tiger_Lead__c =true,
            Description = 'description',
        	NVMConnect__NextContactTime__c = System.now().addMinutes(-6) );
            insert theCase;
        //Test.setCreatedDate(theCase.Id, DateTime.now().addHours(-2));
        Test.startTest();
        
        BatchProcessCase sh1 = new BatchProcessCase();    
        database.executebatch(sh1, 25);  
        
        Test.stopTest();
    }
}