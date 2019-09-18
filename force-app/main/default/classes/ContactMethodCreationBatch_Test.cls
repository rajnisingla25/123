@isTest
public class ContactMethodCreationBatch_Test
{
    public static testmethod void testConMethodCreationBatch()
    {
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
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled';
        insert semt;
        
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;

        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='move@.com';
        insert dt;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
        
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
        User theUser=new User();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {            
            theUser=TestDataFactory.createUser([SELECT Id FROM UserRole WHERE Name='Project Manager' limit 1].Id, [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id,null, 'user@gmail.com', 'user123123312dsds@gmail.com',  true);
        }
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        parentAccount.Primary_Email__c = 'testSender@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        upsert parentAccount;               
        
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        
        ContactMethod__c contactMethodRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','prat@m.com',true,true,'Personal Email');                    

        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        
        Lead theLead = TestDataFactory.CreateLead('Test','Test','New',theAccount1.Id,null,'Test',false);
        theLead.Ignore_Owner_Assignment__c = 'Yes';
        theLead.ownerId = testGroup.Id;
        theLead.NVMConnect__NextContactTime__c = System.now().addMinutes(-6);
        theLead.Callback_Time__c = '6:00 AM';
        theLead.Last_Interaction_Date__c = Date.today().adddays(-1);
        theLead.Contact_Method__c = contactMethodRecord.Id;
        theLead.Email = 'pratik@move.com';
        insert theLead;
        //update theLead;
        Test.startTest();
        
        String cmQuery = 'Select Id, Email, Contact_Method__c,Contact_Method__r.Contact__r.FirstName,Contact_Method__r.Contact__r.LastName, FirstName,LastName, Contact_Method__r.Email__c, Contact_Method__r.Contact__c From Lead Where Contact_Method__c != Null ';
        ContactMethodCreationBatch cmBatch = new ContactMethodCreationBatch(cmQuery);    
        database.executebatch(cmBatch, 1);  
        
        Test.stopTest();
    }
}