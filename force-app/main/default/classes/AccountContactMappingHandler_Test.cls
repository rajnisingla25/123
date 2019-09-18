/********************************************************************************************
*   @Author :       Vamsi Ch(Brillio Technologies) 
*   @Purpose:       Test Class for AccountContactMappingHandler
*   @TestClass      AccountContactMappingHandler_Test
*   @Class          AccountContactMappingHandler
*   @JIRA           
*   @CreatedDate:   
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
***********************************************************************************************
*/

@isTest
private class AccountContactMappingHandler_Test{  
    static testMethod void testMethod1(){ 
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
                
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c ='Primary Contact';
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        newCase.contactId=null;
        newCase.accountId=null;
        update newCase;
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = parentAccount.id;
        fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    
    static testMethod void testMethod2(){  
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
        newContact.Optional_Email_1__c = 'testSender2@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
               
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c ='Primary Contact';
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = parentAccount.id;
        //fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    
    static testMethod void testMethod3(){ 
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
                
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;                        
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = parentAccount.id;
        //fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    
    static testMethod void testMethod4(){
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
        newContact.Optional_Email_1__c = 'testSender2@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        
        
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = parentAccount.id;
        //fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    static testMethod void testMethod5(){    
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
        newContact.Optional_Email_1__c = 'testSender2@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
                       
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        Id [] fixedSearchResults= new Id[1];
        //fixedSearchResults[0] = parentAccount.id;
        fixedSearchResults[0] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    static testMethod void testMethod6(){  
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
                
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;                
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[1];
        //fixedSearchResults[0] = parentAccount.id;
        fixedSearchResults[0] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    static testMethod void testMethod7(){
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
        parentAccount.Type = 'Agent Team';
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
        newContact.Type__c = 'Agent';
        upsert newContact;
               
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;        
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = parentAccount.id;
       // fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    
    static testMethod void testMethod8(){
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
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        parentAccount.Type = 'Franchise Company';
        upsert parentAccount;                
        
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Agent';
        upsert newContact;
                
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;        
        accountRelation.Contact_To__c = newContact.id;
        upsert accountRelation;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = parentAccount.id;
       // fixedSearchResults[1] = newContact.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
          
    static testMethod void testMethod9(){
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
        
        List<account> accountsToBeUpserted = new list<account>();
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);        
        parentAccount.Primary_Email__c = 'testSender@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c ='testSender@move.com';
        accountsToBeUpserted.add(parentAccount);
        
        
        Account parentAccount2 = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        parentAccount2.Primary_Email__c = 'testSender@move.com';
        parentAccount2.Type = 'Broker';
        parentAccount2.Party_ID__c  = '12345';
        parentAccount2.Customer_Id__c  = '12345';
        parentAccount2.BillingPostalCode  = '12345';
        parentAccount2.BillingCity = 'newyork';
        parentAccount2.MLS_Set_Id__c  = '12345';    
        parentAccount2.Advertiser_Email__c ='testSender@move.com';
        accountsToBeUpserted.add(parentAccount2);                
        
        upsert accountsToBeUpserted;               
       
        List<contact> contactsToBeUpserted = new List<contact>();
        Contact newContact=new Contact();
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,true);
        newContact.Optional_Email_1__c = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        contactsToBeUpserted.add(newContact);
        
        Contact newContact2=new Contact();
        newContact2=TestDataFactory.createContact('Bill','Nork',parentAccount2.Id,true,true);
        newContact2.Optional_Email_1__c = 'testSender@move.com';
        newContact2.Type__c = 'Broker';
        contactsToBeUpserted.add(newContact2);
        
        upsert contactsToBeUpserted;
        
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account_Relationship__c> ACRToBeUpserted = new List<Account_Relationship__c>();
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, null, newContact.Id, null, true, true);
        accountRelation.RecordTypeId =  contRelationShipRTID;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c ='Primary Contact';
        accountRelation.Contact_To__c = newContact.id;
        ACRToBeUpserted.add(accountRelation);
        
        Account_Relationship__c accountRelation2 = TestDataFactory.createAccountRelationship
                                                                (parentAccount2.Id, null, newContact2.Id, null, true, true);
        accountRelation2.RecordTypeId =  contRelationShipRTID;
        accountRelation2.Active__c = true;
        accountRelation2.Is_Parent_Primary__c = true;
        accountRelation2.Billing_Contact__c =true;
        accountRelation2.Contact_Role__c ='Primary Contact';
        accountRelation2.Contact_To__c = newContact.id;
        ACRToBeUpserted.add(accountRelation2);
        
        upsert ACRToBeUpserted;
        
        Case newCase=new Case();
        newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);
        newCase.Origin = 'Email-Realtor Consumer:androidfeedback@realtor.com';
        update newCase;
        
        Id [] fixedSearchResults= new Id[3];
        fixedSearchResults[0] = parentAccount.id;
        fixedSearchResults[1] = newContact.id;
        fixedSearchResults[2] = newContact2.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.StartTest(); 
        EmailMessage newEmailMsg= new EmailMessage();
        newEmailMsg.ParentId=newCase.id;
        newEmailMsg.FromAddress='testSender@move.com';
        newEmailMsg.Headers='move';
        newEmailMsg.ToAddress='testServiceAgent@move.com';
        newEmailMsg.incoming=true;
        insert newEmailMsg;                                       
        Test.StopTest();
    }
    
    static testMethod void testException1(){
        AccountContactMappingHandler acm = new AccountContactMappingHandler();
        List<emailMessage> emailMessageList = new List<emailMessage>();
        acm.FindEmailMatch(emailMessageList);
        //acm.FindEmailMatch(null); 
        acm.fetchAppropriateContact(null);
        acm.fetchAppropriateAccount(null,null);
        acm.fetchStandardContact(null);
    }
}