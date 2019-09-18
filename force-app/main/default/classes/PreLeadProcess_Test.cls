@isTest
public class PreLeadProcess_Test 
{

    public static testmethod void testBatchLeadCreation()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        List<Lead_Pre_Lead_Mapping__mdt> lstLeadPreLeadMapping = new List<Lead_Pre_Lead_Mapping__mdt>();
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping.DeveloperName = 'Account__c';
        leadPreLeadMapping.MasterLabel = 'Account__c';
        leadPreLeadMapping.Pre_Lead_Field_Name__c = 'AccountId__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping2 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping2.DeveloperName = 'Business_Unit__c';
        leadPreLeadMapping2.MasterLabel = 'Business_Unit__c';
        leadPreLeadMapping2.Pre_Lead_Field_Name__c = 'Business_Unit__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping2);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping3 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping3.DeveloperName = 'Contact__c';
        leadPreLeadMapping3.MasterLabel = 'Contact__c';
        leadPreLeadMapping3.Pre_Lead_Field_Name__c = 'Contact__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping3);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping4 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping4.DeveloperName = 'Email';
        leadPreLeadMapping4.MasterLabel = 'Email';
        leadPreLeadMapping4.Pre_Lead_Field_Name__c = 'Email__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping4);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping5 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping5.DeveloperName = 'FirstName';
        leadPreLeadMapping5.MasterLabel = 'FirstName';
        leadPreLeadMapping5.Pre_Lead_Field_Name__c = 'First_Name__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping5);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping6 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping6.DeveloperName = 'LastName';
        leadPreLeadMapping6.MasterLabel = 'LastName';
        leadPreLeadMapping6.Pre_Lead_Field_Name__c = 'Last_Name__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping6);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping7 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping7.DeveloperName = 'Lead_Origin__c';
        leadPreLeadMapping7.MasterLabel = 'Lead_Origin__c';
        leadPreLeadMapping7.Pre_Lead_Field_Name__c = 'Lead_Origin__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping7);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping8 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping8.DeveloperName = 'LeadSource';
        leadPreLeadMapping8.MasterLabel = 'LeadSource';
        leadPreLeadMapping8.Pre_Lead_Field_Name__c = 'Lead_Source__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping8);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping9 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping9.DeveloperName = 'Campaign__c';
        leadPreLeadMapping9.MasterLabel = 'Campaign__c';
        leadPreLeadMapping9.Pre_Lead_Field_Name__c = 'Link_Campaign__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping9);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping10 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping10.DeveloperName = 'OwnerId';
        leadPreLeadMapping10.MasterLabel = 'OwnerId';
        leadPreLeadMapping10.Pre_Lead_Field_Name__c = 'Lead_Owner__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping10);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping11 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping11.DeveloperName = 'Phone';
        leadPreLeadMapping11.MasterLabel = 'Phone';
        leadPreLeadMapping11.Pre_Lead_Field_Name__c = 'Phone__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping11);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping12 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping12.DeveloperName = 'Product_Type__c';
        leadPreLeadMapping12.MasterLabel = 'Product_Type__c';
        leadPreLeadMapping12.Pre_Lead_Field_Name__c = 'Product_Type__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping12);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping13 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping13.DeveloperName = 'Contact_Method__c';
        leadPreLeadMapping13.MasterLabel = 'Contact_Method__c';
        leadPreLeadMapping13.Pre_Lead_Field_Name__c = 'Contact_Method_Id__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping13);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping14 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping14.DeveloperName = 'Ignore_Owner_Assignment__c';
        leadPreLeadMapping14.MasterLabel = 'Ignore_Owner_Assignment__c';
        leadPreLeadMapping14.Pre_Lead_Field_Name__c = 'Ignore_Owner_Assignment__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping14);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping15 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping15.DeveloperName = 'Referring_Agent_Email__c';
        leadPreLeadMapping15.MasterLabel = 'Referring_Agent_Email__c';
        leadPreLeadMapping15.Pre_Lead_Field_Name__c = 'Referring_Agent_Email__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping15);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping16 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping16.DeveloperName = 'Referring_Agent_Name__c';
        leadPreLeadMapping16.MasterLabel = 'Referring_Agent_Name__c';
        leadPreLeadMapping16.Pre_Lead_Field_Name__c = 'Referring_Agent_Name__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping16);
        
        Lead_Pre_Lead_Mapping__mdt leadPreLeadMapping17 = new Lead_Pre_Lead_Mapping__mdt();
        leadPreLeadMapping17.DeveloperName = 'Referring_Agent_Phone__c';
        leadPreLeadMapping17.MasterLabel = 'Referring_Agent_Phone__c';
        leadPreLeadMapping17.Pre_Lead_Field_Name__c = 'Referring_Agent_Phone__c';
        lstLeadPreLeadMapping.add(leadPreLeadMapping17);
        
        //insert lstLeadPreLeadMapping;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        insert newPreLead;
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Callback_Date__c = '06/30/2019';
        led.Callback_Time__c = '10:00 AM';
        Leads.add(Led);
        Insert Leads; 
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Lead_origin__c = 'Nurture Lead';
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    
    
    public static testmethod void testBatchLead2()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Hot Offer';
        Leads.add(Led);
        Insert Leads; 
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Hot_Lead__c = False;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead3()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Upsell';
        Leads.add(Led);
        Insert Leads; 
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Hot_Lead__c = False;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead4()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Upsell';
        led.Lead_Origin__c = 'Outbound Call Campaign';
        Leads.add(Led);
        Insert Leads; 
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Hot_Lead__c = False;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead5()
    {
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Upsell';
        led.Callback_Date__c = '06/30/2019';
        led.Callback_Time__c = '10:00 AM';
        Leads.add(Led);
        Insert Leads; 
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Product_Type__c = 'Prospecting';
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead6()
    {
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
        parentAccount.Type = 'Realtor Agent';
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Link_Campaign__c = campaign.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Upsell';
        led.lead_origin__c = 'Inbound Calls';
        Leads.add(Led);
        Insert Leads; 
        
        
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Product_Type__c = 'Prospecting';
        newPreLead.Hot_Lead__c = false;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead7()
    {
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
        parentAccount.Type = 'Realtor Agent';
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        //led.Link_Campaign__c = campaign.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Prospecting';
        led.lead_origin__c = 'Outbound Call Campaign';
        Leads.add(Led);
        Insert Leads; 
        
        
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Product_Type__c = 'Prospecting';
        newPreLead.Hot_Lead__c = false;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead8()
    {
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
        parentAccount.Type = 'Realtor Agent';
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        //led.Link_Campaign__c = campaign.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Prospecting';
        led.lead_origin__c = 'Nurture Lead';
        Leads.add(Led);
        Insert Leads; 
        
        
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Product_Type__c = 'Prospecting';
        newPreLead.Hot_Lead__c = false;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    public static testmethod void testBatchLead9()
    {
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
        parentAccount.Type = 'Realtor Agent';
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
        
        ContactMethod__c CMRecord = TestDataFactory.createContactMethod(newContact.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        Campaign campaign = new Campaign(); 
        campaign.Name = 'test';
        insert campaign;
        
        List<Lead> Leads = new List<Lead>();
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = parentAccount.id;
        Led.Contact__c = newContact.id;
        led.Callback_Date__c = '06/30/2019';
        led.Callback_Time__c = '10:00 AM';
        //led.Link_Campaign__c = campaign.id;
        led.Assigned_Group__c = 'test_group';
        led.Product_Type__c = 'Prospecting';
        led.lead_origin__c = 'Nurture Lead';
        Leads.add(Led);
        Insert Leads; 
        
        
        
        Pre_Lead__c newPreLead = getPreLead('Pratik', 'R', newContact.Id, parentAccount.Id,campaign.Id, CMRecord.Id);
        newPreLead.Product_Type__c = 'Upsell';
        newPreLead.Hot_Lead__c = false;
        insert newPreLead;
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(newPreLead);
        PreLeadProcess.processPreleadToLead(lstSObject);
    }
    
    static Pre_Lead__c getPreLead(String firstName, String lastName, String contactId, String accountId, String campaignId, String cmId)
    {
        Pre_Lead__c newPreLead = new Pre_Lead__c();
        newPreLead.First_Name__c = firstName;
        newPreLead.Last_Name__c = lastName;
        newPreLead.Business_Unit__c = 'Business Unit';
        newPreLead.Account__c = accountId;
        newPreLead.AccountId__c = accountId;
        newPreLead.Contact__c = contactId;
        newPreLead.Campaign__c = campaignId;
        newPreLead.Email__c = 'pratik@move.com';
        newPreLead.Hot_Lead__c = True;
        newPreLead.Ignore_Owner_Assignment__c = True;
        newPreLead.Lead_Origin__c = 'Email';
        newPreLead.Lead_Owner__c = UserInfo.getUserId();
        newPreLead.Lead_Source__c = 'Partner';
        newPreLead.Phone__c = '1234432112';
        newPreLead.Product_Type__c = 'COBROKE';
        newPreLead.Company__c = 'Move';
        newPreLead.Contact_Method_Id__c  = cmId;
        return newPreLead;
    }
}