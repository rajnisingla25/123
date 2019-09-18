@isTest
private class  Send_Custom_Email_Test{

    private static testmethod void testCaseTemplate(){
        EmailShell__c testShell = new EmailShell__c();
        testShell.header__c = 'Header';
        testShell.ShellName__c = 'Shell';
        testShell.Footer__c = 'Footer';
        Insert testShell;
        
        EmailTemplateSetting__c testTemplate = new EmailTemplateSetting__c();
        testTemplate.EmailBody__c = 'testBody {!case.caseNumber}  {!case.createdDate} {!contact.name} {!user.email}';
        testTemplate.From_Address__c='CustomerCare@realtor.com';
        testTemplate.CC_Address__c='CustomerCare@realtor.com,CustomerCare@realtor.com';
        
        testTemplate.subject__c='testSubject';
        testTemplate.TemplateName__c = 'testTemplate';
        testTemplate.Email_Shell__c = testShell.Id;
        insert testTemplate;
        
        List<EmailTransformation__c> etList = new List<EmailTransformation__c>();
        EmailTransformation__c testFieldTransform = new EmailTransformation__c();
        testFieldTransform.KeyPhrase__c = '{!case.caseNumber}';
        testFieldTransform.Replacewith__c = 'CaseNumber';
        testFieldTransform.ObjectName__c = 'Case';
        testFieldTransform.Type__c = 'Field Name';
        testFieldTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testFieldTransform);
        
        EmailTransformation__c testDateFieldTransform = new EmailTransformation__c();
        testDateFieldTransform.KeyPhrase__c = '{!case.createdDate}';
        testDateFieldTransform.Replacewith__c = 'createdDate';
        testDateFieldTransform.ObjectName__c = 'Case';
        testDateFieldTransform.Type__c = 'Field Name';
        testDateFieldTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testDateFieldTransform);
        
        EmailTransformation__c testContactFieldTransform = new EmailTransformation__c();
        testContactFieldTransform.KeyPhrase__c = '{!contact.name}';
        testContactFieldTransform.Replacewith__c = 'name';
        testContactFieldTransform.ObjectName__c = 'Contact';
        testContactFieldTransform.Type__c = 'Field Name';
        testContactFieldTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testContactFieldTransform);
        
        EmailTransformation__c testUserFieldTransform = new EmailTransformation__c();
        //testUserFieldTransform.KeyPhrase__c = '{!user.email}';
        testUserFieldTransform.KeyPhrase__c = '{!User_Email}';
        testUserFieldTransform.Replacewith__c = 'email';
        testUserFieldTransform.ObjectName__c = 'User';
        testUserFieldTransform.Type__c = 'Field Name';
        testUserFieldTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testUserFieldTransform);
        
        EmailTransformation__c testManualTransform = new EmailTransformation__c();
        testManualTransform.KeyPhrase__c = '[Issue]';
        testManualTransform.Type__c = 'Manual';
        testManualTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testManualTransform);
        
        insert etList;
        
        List<LookupQuery__c> lqList = new List<LookupQuery__c>();
        LookupQuery__c testCaseQuery = new LookupQuery__c();
        testCaseQuery.ObjectApiName__c = 'Case';
        testCaseQuery.Query__c = 'select id,casenumber,AccountId,contactid,createdDate from case';
        testCaseQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testCaseQuery);
        
        LookupQuery__c testAccountQuery = new LookupQuery__c();
        testAccountQuery.ObjectApiName__c = 'Account';
        testAccountQuery.Query__c = 'select id,name from account';
        testAccountQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testAccountQuery);
        
        LookupQuery__c testContactQuery = new LookupQuery__c();
        testContactQuery.ObjectApiName__c = 'Contact';
        testContactQuery.Query__c = 'select id,name from contact';
        testContactQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testContactQuery);
        
        LookupQuery__c testUserQuery = new LookupQuery__c();
        testUserQuery.ObjectApiName__c = 'user';
        testUserQuery.Query__c = 'select id,name,email from user';
        testUserQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testUserQuery);
        
        LookupQuery__c testAssetQuery = new LookupQuery__c();
        testAssetQuery.ObjectApiName__c = 'Asset';
        testAssetQuery.Query__c = 'select id,name from Asset';
        testAssetQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testAssetQuery);
        
        LookupQuery__c testMLSQuery = new LookupQuery__c();
        testMLSQuery.ObjectApiName__c = 'MLS';
        testMLSQuery.Query__c = 'select id,name from MLS__c';
        testMLSQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testMLSQuery);
        
        insert lqList;
        
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled1';
        insert semt;
        
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Name = 'Disabled';
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
        If(parentAccount.Id!=null){
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,false);
        newContact.email = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        }      
        Case newCase=new Case();
        If(newContact.Id!=null&&parentAccount.Id!=null){
            newCase=TestDataFactory.createCase('Case Subject', 'New', 'Retention','description about the case', newContact.Id, parentAccount.Id, true);            
            upsert newCase;
        }
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;
        
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');   
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Asset testAsset = Commissions_TestDataFactory_New.CreateAsset(parentAccount.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        
        
        MLS__c testMLS = new MLS__c();
        testMLS.name = 'testMLS';
        testMLS.MLS__c = parentAccount.id;
        insert testMLS;        
        
        PageReference tpageRef = Page.Send_Customer_Info;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', newCase.Id);
        ApexPages.currentPage().getParameters().put('node','[{"type":"Attachment","Name":"TestFile.txt","ContentType":"text/plain","Body":"VGVzdA=="}]');
        Send_Custom_Email sce = new Send_Custom_Email();
        sce.selectedTemplate =testTemplate.Id;
        sce.QueryTemplateInfo();
        sce.displayAssets();
        sce.displayMLS();
        sce.filenames='TestFile,TestFile';
        sce.updateAttach();
      // sce.filenames='TestFile,TestFile';
        sce.removeAttach();
       
        sce.filenames='TestFile';
        sce.sendmail();
        sce.checkEmailSuccess();
    }
    private static testmethod void testAccountTemplate(){
        EmailShell__c testShell = new EmailShell__c();
        testShell.header__c = 'Header';
        testShell.ShellName__c = 'Shell';
        testShell.Footer__c = 'Footer';
        Insert testShell;
        
        EmailTemplateSetting__c testTemplate = new EmailTemplateSetting__c();
        testTemplate.EmailBody__c = 'testBody {!Account.Name}';
        testTemplate.From_Address__c='CustomerCare@realtor.com';
      
        testTemplate.CC_Address__c='CustomerCare@realtor.com,CustomerCare@realtor.com';
        
        testTemplate.subject__c='testSubject';
        testTemplate.TemplateName__c = 'testTemplate';
        testTemplate.Available_for_Account__c = true;
        testTemplate.Email_Shell__c = testShell.Id;
        insert testTemplate;
        
        List<EmailTransformation__c> etList = new List<EmailTransformation__c>();
        EmailTransformation__c testFieldTransform = new EmailTransformation__c();
        testFieldTransform.KeyPhrase__c = '{!Account.Name}';
        testFieldTransform.Replacewith__c = 'Name';
        testFieldTransform.ObjectName__c = 'Account';
        testFieldTransform.Type__c = 'Field Name';
        testFieldTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testFieldTransform);
               
        
        EmailTransformation__c testManualTransform = new EmailTransformation__c();
        testManualTransform.KeyPhrase__c = '[Issue]';
        testManualTransform.Type__c = 'Manual';
        testManualTransform.EmailTemplateSetting__c = testTemplate.id;
        etList.add(testManualTransform);
        
        insert etList;
        
        List<LookupQuery__c> lqList = new List<LookupQuery__c>();
        
        
        LookupQuery__c testAccountQuery = new LookupQuery__c();
        testAccountQuery.ObjectApiName__c = 'Account';
        testAccountQuery.Query__c = 'select id,name from account';
        testAccountQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testAccountQuery);
        
        LookupQuery__c testContactQuery = new LookupQuery__c();
        testContactQuery.ObjectApiName__c = 'Contact';
        testContactQuery.Query__c = 'select id,name from contact';
        testContactQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testContactQuery);
        
        LookupQuery__c testUserQuery = new LookupQuery__c();
        testUserQuery.ObjectApiName__c = 'user';
        testUserQuery.Query__c = 'select id,name,email from user';
        testUserQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testUserQuery);
        
        LookupQuery__c testAssetQuery = new LookupQuery__c();
        testAssetQuery.ObjectApiName__c = 'Asset';
        testAssetQuery.Query__c = 'select id,name from Asset';
        testAssetQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testAssetQuery);
        
        LookupQuery__c testMLSQuery = new LookupQuery__c();
        testMLSQuery.ObjectApiName__c = 'MLS';
        testMLSQuery.Query__c = 'select id,name from MLS__c';
        testMLSQuery.Email_Template_Setting__c = testTemplate.id;
        lqList.add(testMLSQuery);
        
        insert lqList;
        
        Switch_EmailMessageTrigger__c semt = new Switch_EmailMessageTrigger__c();
        semt.name='Disabled1';
        insert semt;
        
        Switch_CaseTrigger__c sct=new Switch_CaseTrigger__c();
        sct.Name = 'Disabled';
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
        If(parentAccount.Id!=null){
        newContact=TestDataFactory.createContact('Bill','Nork',parentAccount.Id,true,false);
        newContact.email = 'testSender@move.com';
        newContact.Type__c = 'Broker';
        upsert newContact;
        }      
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'COBROKE';
        prdctdata.isActive = true;
        insert prdctdata;
        
        
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');   
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Asset testAsset = Commissions_TestDataFactory_New.CreateAsset(parentAccount.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
        
        
        MLS__c testMLS = new MLS__c();
        testMLS.name = 'testMLS';
        testMLS.MLS__c = parentAccount.id;
        insert testMLS;        
        
        PageReference tpageRef = Page.Send_Customer_Info;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', parentAccount.Id);
        Send_Custom_Email sce = new Send_Custom_Email();
        sce.selectedTemplate =testTemplate.Id;
        sce.QueryTemplateInfo();
        
    }
    private static testmethod void testExceptions(){
        try{
        PageReference tpageRef = Page.Send_Customer_Info;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id',null);
        Send_Custom_Email sce = new Send_Custom_Email();
        sce.selectedTemplate =null;
        sce.QueryTemplateInfo();
        sce.fetchEmailTransformations(null);
        sce.fetchLookupQueries(null);
        sce.queryRelatedRecords(null);
        sce.transformEmailBody(null,null,null);
        }
        catch(exception e){}
    }
    
    private static testmethod void testExceptions2(){
        try{
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
        PageReference tpageRef = Page.Send_Customer_Info;
        Test.setCurrentPage(tpageRef);
        //ApexPages.currentPage().getParameters().put('Id',parentAccount.Id);
        Send_Custom_Email sce = new Send_Custom_Email();                
        sce.fetchLookupQueries(null);
        
        
        }
        catch(exception e){}
    }
}