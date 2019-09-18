@isTest
public class AccountContactMatch_Test
{
    public static testmethod void testAccountContactMatch()
    {
        String stree='7678';
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled';
        insert semt;
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        test.startTest();
        insert Campaigns;
        
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
        Account mlsAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        MLS__c mls = new MLS__c();
        mls.name = '12345';
        mls.MLS_Set_ID__c = '12345';
        mls.Status__c = 'Active';
        mls.MLS__c = mlsAccount.id;
        insert mls;
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        parentAccount.Primary_Email__c = 'testSender@move.com';
        parentAccount.Type = 'Realtor Agent';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        parentAccount.Total_HLC__c = 100;
        parentAccount.Total_CLC__c = 100;
        upsert parentAccount;               
        
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(newContact.Id,'Email','prat@m.com',true,true,'Personal Email');                    
        parentAccount.PrimaryEmail_CMId__c = contactMethodRecord.Id;
        update parentAccount;
        //CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        Account_Relationship__c accRelationship = TestDataFactory.createAccountRelationshipWithRecordType(parentAccount.Id,newContact.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');          
        //AccountContactPreference__c acpRecord = [Select Id from AccountContactPreference__c where Account__c =: parentAccount.Id Limit 1]; //and ContactMethod__c =: contactMethodRecord.Id];
        //AccountContactPreference__c acpRecord = TestDataFactory.createAccountContactPreference(parentAccount.Id,newContact.Id,contactMethodRecord.Id,true,null,null,null,null,false);
        
        List<AccountContactMatch.RecordInfoWrapper> lstRecordInfoWrapper = new List<AccountContactMatch.RecordInfoWrapper>();
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.ContactId = newContact.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper2 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper2.CMId = contactMethodRecord.Id;
        system.debug('contactMethodRecord.Id ==>'+contactMethodRecord.Id);
        lstRecordInfoWrapper.add(newRecordInfoWrapper2);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper3 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper3.AccountId = parentAccount.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper3);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper4 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper4.Campaign = Campaigns.id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper4);
        
         AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper5 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper5.Email = 'prat@m.com';
        //newRecordInfoWrapper.Phone = '1234567890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper5);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper6 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper6.Email = 'prat@m.com';
        newRecordInfoWrapper6.Phone = '1234567890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper6);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper7 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper7.Phone = '1234567890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper7);
        
        system.debug('1lstRecordInfoWrapper ==>'+lstRecordInfoWrapper.size());
        
        AccountContactMatch.getRecordInfo(lstRecordInfoWrapper);
    }
    
    public static testmethod void testAccountContactMatchEmail()
    {
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled';
        insert semt;
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        test.startTest();
        insert Campaigns;
        
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
        parentAccount.Type = 'Realtor Agent';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        parentAccount.Total_HLC__c = 100;
        parentAccount.Total_CLC__c = 100;
        upsert parentAccount;               
        
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(newContact.Id,'Email','prat@m.com',true,true,'Personal Email');                    
        parentAccount.PrimaryEmail_CMId__c = contactMethodRecord.Id;
        update parentAccount;
        //CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        Account_Relationship__c accRelationship = TestDataFactory.createAccountRelationshipWithRecordType(parentAccount.Id,newContact.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');          
        //AccountContactPreference__c acpRecord = [Select Id from AccountContactPreference__c where Account__c =: parentAccount.Id Limit 1]; //and ContactMethod__c =: contactMethodRecord.Id];
        //AccountContactPreference__c acpRecord = TestDataFactory.createAccountContactPreference(parentAccount.Id,newContact.Id,contactMethodRecord.Id,true,null,null,null,null,false);
        
        List<AccountContactMatch.RecordInfoWrapper> lstRecordInfoWrapper = new List<AccountContactMatch.RecordInfoWrapper>();
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.ContactId = newContact.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.CMId = contactMethodRecord.Id;
        system.debug('contactMethodRecord.Id ==>'+contactMethodRecord.Id);
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.AccountId = parentAccount.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.Campaign = Campaigns.id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.Email = 'prat@m.com';
        //newRecordInfoWrapper.Phone = '1234567890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.Phone = '1234567890';
        //lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        system.debug('lstRecordInfoWrapper ==>'+lstRecordInfoWrapper);
        
        AccountContactMatch.getRecordInfo(lstRecordInfoWrapper);
        AccountContactMatch.getBrokerOfficeRecordInfo(lstRecordInfoWrapper);
        AccountContactMatch ach = new AccountContactMatch();
        ach.ReturnMLSAccount();
    }
    
    public static testmethod void testAccountContactMatchPhone()
    {
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled';
        insert semt;
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        test.startTest();
        insert Campaigns;
        
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
        parentAccount.Type = 'Realtor Agent';
        parentAccount.Phone = '1234567890';
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
        
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(newContact.Id,'Phone','2345467890',true,true,'Personal Phone');                    
        parentAccount.PrimaryEmail_CMId__c = contactMethodRecord.Id;
        update parentAccount;
        contactMethodRecord = [Select id,Phone_Text__c from ContactMethod__c];
        //for(ContactMethod__c cmm:contactMethodRecord){
        contactMethodRecord.Phone_Text__c = '2345467890';
        //}
        System.debug('ContactM*****'+contactMethodRecord);
        update contactMethodRecord;
        System.debug('ContactM*****'+contactMethodRecord);
        //CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        Account_Relationship__c accRelationship = TestDataFactory.createAccountRelationshipWithRecordType(parentAccount.Id,newContact.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');          
        //AccountContactPreference__c acpRecord = [Select Id from AccountContactPreference__c where Account__c =: parentAccount.Id Limit 1]; //and ContactMethod__c =: contactMethodRecord.Id];
        //AccountContactPreference__c acpRecord = TestDataFactory.createAccountContactPreference(parentAccount.Id,newContact.Id,contactMethodRecord.Id,true,null,null,null,null,false);
        
        List<AccountContactMatch.RecordInfoWrapper> lstRecordInfoWrapper = new List<AccountContactMatch.RecordInfoWrapper>();
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper.ContactId = newContact.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper2 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper2.CMId = contactMethodRecord.Id;
        system.debug('contactMethodRecord.Id ==>'+contactMethodRecord.Id);
        lstRecordInfoWrapper.add(newRecordInfoWrapper2);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper3 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper3.AccountId = parentAccount.Id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper3);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper4 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper4.Campaign = Campaigns.id;
        lstRecordInfoWrapper.add(newRecordInfoWrapper4);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper5 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper5.Email = 'prat@m.com';
        newRecordInfoWrapper5.Phone = '1234567890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper5);
        
        AccountContactMatch.RecordInfoWrapper newRecordInfoWrapper6 = new AccountContactMatch.RecordInfoWrapper();
        newRecordInfoWrapper6.Phone = '2345467890';
        lstRecordInfoWrapper.add(newRecordInfoWrapper6);
        
        system.debug('lstRecordInfoWrapper ==>'+lstRecordInfoWrapper.size());
        
        AccountContactMatch.getRecordInfo(lstRecordInfoWrapper);
        //AccountContactMatch.getBrokerOfficeRecordInfo(lstRecordInfoWrapper);
    }
}