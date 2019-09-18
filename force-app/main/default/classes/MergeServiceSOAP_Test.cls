@isTest(seeAllData = false)
public class MergeServiceSOAP_Test {
    
    static Account account1 = new Account();
    static Account account2 = new Account();
    static Account account3 = new Account();
    static Account account4 = new Account();
    static Contact contact1 = new Contact();
    static Contact contact2 = new Contact();
    static String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';
    static Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    static String CONTACT_RELATIONSHIP_RECORD_TYPE = 'Contact Relationship';
    static Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    
    static void setupData() {
    
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Business_Hours__c bh1 = new Business_Hours__c(Name='StatusChange', Lowermin__c=450, UpMin__c=960);
        insert bh1;
        Business_Hours__c bh2 = new Business_Hours__c(Name='OwnChange', Lowermin__c=450, UpMin__c=960);
        insert bh2;
        Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
        insert testSetting;
        Switch_AssetTrigger__c testSetting1 = new Switch_AssetTrigger__c(Set_Overall_Trigger_Off__c = True);
        insert testSetting1;
        list < string > VictimPartyIDs;
        id rectypid = [select id from RecordType where SobjectType = 'Account' and name = 'B2B'].id;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
  
        List<Account> accs = new List<Account>();
        account1.RecordTypeId = rectypid;
        account1.name = 'XYZ';
        account1.Phone = '+49-12345';
        account1.BillingStreet = 'Am Tierpark 16';
        account1.BillingCity = 'Cologne';
        account1.BillingPostalCode = '54321';
        account1.BillingState = 'Nordrhein-Westfalen';
        account1.BillingCountry = 'Germany';
        account1.Primary_Email__c = 'ra@gmail.com';
        account1.Home_Phone__c = '967622877';
        account1.Work_Phone__c = '456789';
        account1.Mobile1__c = '1234566';
        account1.Mobile2_Other__c = '1245787';
        account1.party_id__c = 'account1';
        accs.add(account1);
        
        account2= new Account();
        account2.RecordTypeId = rectypid;
        account2.name = 'XYZ';
        account2.Phone = '+49-12345';
        account2.BillingStreet = 'Am Tierpark 16';
        account2.BillingCity = 'Cologne';
        account2.BillingPostalCode = '54321';
        account2.BillingState = 'Nordrhein-Westfalen';
        account2.BillingCountry = 'Germany';
        account2.Primary_Email__c = 'ra@gmail.com';
        account2.Home_Phone__c = '967622877';
        account2.Work_Phone__c = '456789';
        account2.Mobile1__c = '1234566';
        account2.Mobile2_Other__c = '1245787';
        account2.party_id__c = 'account2';
        accs.add(account2);
        
        account3= new Account();
        account3.RecordTypeId = rectypid;
        account3.name = 'XYZ';
        account3.Phone = '+49-12345';
        account3.BillingStreet = 'Am Tierpark 16';
        account3.BillingCity = 'Cologne';
        account3.BillingPostalCode = '54321';
        account3.BillingState = 'Nordrhein-Westfalen';
        account3.BillingCountry = 'Germany';
        account3.Primary_Email__c = 'ra@gmail.com';
        account3.Home_Phone__c = '967622877';
        account3.Work_Phone__c = '456789';
        account3.Mobile1__c = '1234566';
        account3.Mobile2_Other__c = '1245787';
        account3.party_id__c = 'account3';
        accs.add(account3);
        
        account4= new Account();
        account4.RecordTypeId = rectypid;
        account4.name = 'XYZ';
        account4.Phone = '+49-12345';
        account4.BillingStreet = 'Am Tierpark 16';
        account4.BillingCity = 'Cologne';
        account4.BillingPostalCode = '54321';
        account4.BillingState = 'Nordrhein-Westfalen';
        account4.BillingCountry = 'Germany';
        account4.Primary_Email__c = 'ra@gmail.com';
        account4.Home_Phone__c = '967622877';
        account4.Work_Phone__c = '456789';
        account4.Mobile1__c = '1234566';
        account4.Mobile2_Other__c = '1245787';
        account4.party_id__c = 'account3';
        accs.add(account4);
        
        insert accs;
        
        id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and name = 'Standard'].id;

        List<Contact> cons = new List<Contact>();
        contact1.RecordTypeId = cntctrectypid;
        contact1.FirstName = 'Joe';
        contact1.LastName = 'Schmoe';
        contact1.Email = 'Joe.Schmoe@test.de';
        contact1.AccountId = account1.id;
        contact1.MailingStreet = account1.BillingStreet;
        contact1.MailingState = account1.BillingState;
        contact1.MailingCity = account1.BillingCity;
        contact1.MailingPostalCode = account1.BillingPostalCode;
        contact1.MailingCountry = account1.BillingCountry;
        contact1.Phone = account1.Phone;
        contact1.Type__c = 'Agent';
        contact1.Active__c=True;
        contact1.Contact_Party_ID__c = 'contact1';
        contact1.Do_Not_Contact__c = TRUE;
        cons.add(contact1);
        
        contact2.RecordTypeId = cntctrectypid;
        contact2.FirstName = 'Joe';
        contact2.LastName = 'Schmoe';
        contact2.Email = 'Joe.Schmoe@test.de1';
        contact2.AccountId = account1.id;
        contact2.MailingStreet = account1.BillingStreet;
        contact2.MailingState = account1.BillingState;
        contact2.MailingCity = account1.BillingCity;
        contact2.MailingPostalCode = account1.BillingPostalCode;
        contact2.MailingCountry = account1.BillingCountry;
        contact2.Phone = account1.Phone;
        contact2.Type__c = 'Agent';
        contact2.Active__c=True;
        contact2.Contact_Party_ID__c = 'contact2';
        cons.add(contact2);
         
        insert cons;
               
        Contact c1 = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c1.Id,'Email','varisa@yahoo.com',true,true,'Business Email');      
        
        Contact c2 = TestDataFactory.createContactWithEmailAndPhone('varisa@yahoomail.com',null);
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(c2.Id,'Email','venkat.arisa@yahoo.com',true,true,'Business Email');

        Account_Listing__c Ac = new Account_Listing__c();
        AC.Account_Name__c = account1.id;
        AC.Account_Type__c = 'MLS Account';
        AC.MLS_Set_Id__c = 'ravvv';
        AC.State__c = 'Need Values';
        insert AC;

        Zuora__CustomerAccount__c z = new Zuora__CustomerAccount__c();
        z.Zuora__Account__c = account1.id;
        insert z;

        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = account1.id;
        insert attach;
        
        Attachment attach1 = new Attachment();
        attach1.Name = 'Unit Test Attachment';
        bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach1.body = bodyBlob;
        attach1.parentId = contact1.id;
        insert attach1;

        Opportunity opp = new Opportunity();
        opp.name = 'test opp 1';
        opp.StageName = 'Oferecer projeto/orçamento';
        opp.LeadSource = 'Google';
        opp.AccountId = account1.id;
        opp.CloseDate = date.today();
        insert opp;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.whoId=contact1.id;
        t.Subject = 'Donni';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.whatId = account1.id;
        insert t;

        Event newEvent = new Event();
        newEvent.whoId = contact1.id;
        newEvent.Subject = 'Test';
        newEvent.WhatId = account1.id;
        newEvent.ActivityDate = System.today();
        newEvent.IsAllDayEvent = true;
        insert newEvent;

        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.PaymentMethodId__c = 'test';
        pp.Account__c = account1.id;
        insert pp;
        
        Contract co = new Contract();
        co.Accountid = account1.id;
        co.Status = ' ';
        insert co;

        order r = new order();
        r.Accountid = account1.id;
        r.EffectiveDate = System.today();
        r.Contractid = co.id;
        r.Status = 'Created';
        insert r;
        
        Invoice_History__c ih = new Invoice_History__c();
        ih.Name = 'test';
        ih.Bill_To_Account__c = account1.id;
        ih.Bill_To_Contact__c = contact1.id;
        insert ih;
        
        Invoice_Line_Item_History__c il = new Invoice_Line_Item_History__c();
        il.Name = 'test';
        il.Fulfill_To_Account_Id__c = account1.id;
       
        insert il;

        Payment_History__c ph = new Payment_History__c();
        ph.Name = 'test';
        ph.Bill_To_Account__c = account1.id;
        insert ph;

        Campaign_History__c ch = new Campaign_History__c();
        ch.Account__c = account1.id;
        ch.Contact__c = contact1.id;
        insert ch;

        Lead l = new Lead();
        l.FirstName = 'ajay';
        l.LastName = 'kumar';
        l.Company = 'ntt';
        l.Status = 'In progress';
        l.Account__c = account1.id;
        l.Contact__c = contact1.id;
        insert l;
        
        Case c = new case ();
        c.Status = 'New';
        c.Origin = 'Phone';
        c.AccountId = account1.Id;
        c.Contact__c = contact1.id;
        //Insert c;
    }
    
    public static testMethod void testMethod1() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c accr1 = new Account_Relationship__c();
        accr1.Child_Account__c = account1.id;
        accr1.Contact_To__c = contact1.id;
        accr1.Entity_Name__c = 'abc';
        accr1.Is_Parent_Primary__c = true;
        accr1.Parent_Account__c = account3.id;
        accr1.Active__c = true;
        accr1.RecordTypeId = accountRelationshipRecordTypeId;
        accr1.Relationship_Type__c = 'Member';
        accr1.Zuora_Bill_to_Contact_ID__c = 'test';
        accr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr1.Zuora_Sync__c = true;
        recs.add(accr1);
        
        Account_Relationship__c accr2 = new Account_Relationship__c();
        accr2.Child_Account__c = account2.id;
        accr2.Contact_To__c = contact1.id;
        accr2.Entity_Name__c = 'abc';
        accr2.Is_Parent_Primary__c = true;
        accr2.Parent_Account__c = account3.id;
        accr2.Active__c = true;
        accr2.RecordTypeId = accountRelationshipRecordTypeId;
        accr2.Relationship_Type__c = 'Member';
        accr2.Zuora_Bill_to_Contact_ID__c = 'test';
        accr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr2.Zuora_Sync__c = true;
        recs.add(accr2);
        
        insert recs;
        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Account';
        mss.SurvivorExternalID  = 'account2';
        mss.VictimExternalIDs  = new list < string > ();
        List < string > stringlist = new List < string > ();
        stringlist.add('account1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    
    public static testMethod void testMethod2() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c accr1 = new Account_Relationship__c();
        accr1.Child_Account__c = account4.id;
        accr1.Contact_To__c = contact1.id;
        accr1.Entity_Name__c = 'abc';
        accr1.Is_Parent_Primary__c = true;
        accr1.Parent_Account__c = account1.id;
        accr1.Active__c = true;
        accr1.RecordTypeId = accountRelationshipRecordTypeId;
        accr1.Relationship_Type__c = 'Member';
        accr1.Zuora_Bill_to_Contact_ID__c = 'test';
        accr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr1.Zuora_Sync__c = true;
        recs.add(accr1);
        
        Account_Relationship__c accr2 = new Account_Relationship__c();
        accr2.Child_Account__c = account4.id;
        accr2.Contact_To__c = contact1.id;
        accr2.Entity_Name__c = 'abc';
        accr2.Is_Parent_Primary__c = true;
        accr2.Parent_Account__c = account2.id;
        accr2.Active__c = true;
        accr2.RecordTypeId = accountRelationshipRecordTypeId;
        accr2.Relationship_Type__c = 'Member';
        accr2.Zuora_Bill_to_Contact_ID__c = 'test';
        accr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr2.Zuora_Sync__c = true;
        recs.add(accr2);
        
        insert recs;
        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Account';
        mss.SurvivorExternalID = 'account2';
        mss.VictimExternalIDs = new list < string > ();
        List < string > stringlist = new List < string > ();
        stringlist.add('account1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    
    public static testMethod void testMethod3() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c conr1 = new Account_Relationship__c();
        conr1.Child_Account__c = account1.id;
        conr1.Contact_To__c = contact1.id;
        conr1.Entity_Name__c = 'abc';
        conr1.Is_Parent_Primary__c = true;
        conr1.Parent_Account__c = account4.id;
        conr1.Active__c = true;
        conr1.RecordTypeId = contactRelationshipRecordTypeId;
        conr1.Relationship_Type__c = 'Member';
        conr1.Zuora_Bill_to_Contact_ID__c = 'test';
        conr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        conr1.Zuora_Sync__c = true;
        conr1.Contact_Role__c = 'Primary Contact';
        conr1.Billing_Contact__c = true;
        recs.add(conr1);
      
       
        Account_Relationship__c conr2 = new Account_Relationship__c();
        conr2.Child_Account__c = account1.id;
        conr2.Contact_To__c = contact2.id;
        conr2.Entity_Name__c = 'abc';
        conr2.Is_Parent_Primary__c = true;
        conr2.Parent_Account__c = account4.id;
        conr2.Active__c = true;
        conr2.RecordTypeId = contactRelationshipRecordTypeId;
        conr2.Relationship_Type__c = 'Member';
        conr2.Zuora_Bill_to_Contact_ID__c = 'test';
        conr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        conr2.Zuora_Sync__c = true;
        conr2.Contact_Role__c = 'Primary Contact';
        conr2.Billing_Contact__c = true;
        recs.add(conr2);
        
        insert recs;
        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Contact';
        mss.SurvivorExternalID = 'contact2';
        mss.VictimExternalIDs = new list <string>();
        List < string > stringlist = new List < string > ();
        stringlist.add('contact1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    
    public static testMethod void testMethod4() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c accr1 = new Account_Relationship__c();
        accr1.Child_Account__c = account1.id;
        accr1.Contact_To__c = contact1.id;
        accr1.Entity_Name__c = 'abc';
        accr1.Is_Parent_Primary__c = true;
        //accr1.Parent_Account__c = account3.id;
        accr1.Active__c = true;
        accr1.RecordTypeId = accountRelationshipRecordTypeId;
        accr1.Relationship_Type__c = 'Member';
        accr1.Zuora_Bill_to_Contact_ID__c = 'test';
        accr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr1.Zuora_Sync__c = true;
        recs.add(accr1);
        
        Account_Relationship__c accr2 = new Account_Relationship__c();
        accr2.Child_Account__c = account1.id;
        accr2.Contact_To__c = contact1.id;
        accr2.Entity_Name__c = 'abc';
        accr2.Is_Parent_Primary__c = true;
        //accr2.Parent_Account__c = account4.id;
        accr2.Active__c = true;
        accr2.RecordTypeId = accountRelationshipRecordTypeId;
        accr2.Relationship_Type__c = 'Member';
        accr2.Zuora_Bill_to_Contact_ID__c = 'test';
        accr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr2.Zuora_Sync__c = true;
        recs.add(accr2);
        
        insert recs;
               
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Account';
        mss.SurvivorExternalID = 'account2';
        mss.VictimExternalIDs = new list < string > ();
        List < string > stringlist = new List < string > ();
        stringlist.add('account1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();               
        
    }
    
    public static testMethod void testMethod5() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c accr1 = new Account_Relationship__c();
        //accr1.Child_Account__c = account1.id;
        accr1.Contact_To__c = contact1.id;
        accr1.Entity_Name__c = 'abc';
        accr1.Is_Parent_Primary__c = true;
        accr1.Parent_Account__c = account1.id;
        accr1.Active__c = true;
        accr1.RecordTypeId = accountRelationshipRecordTypeId;
        accr1.Relationship_Type__c = 'Member';
        accr1.Zuora_Bill_to_Contact_ID__c = 'test';
        accr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr1.Zuora_Sync__c = true;
        recs.add(accr1);
        
        Account_Relationship__c accr2 = new Account_Relationship__c();
        //accr2.Child_Account__c = account1.id;
        accr2.Contact_To__c = contact1.id;
        accr2.Entity_Name__c = 'abc';
        accr2.Is_Parent_Primary__c = true;
        accr2.Parent_Account__c = account1.id;
        accr2.Active__c = true;
        accr2.RecordTypeId = accountRelationshipRecordTypeId;
        accr2.Relationship_Type__c = 'Member';
        accr2.Zuora_Bill_to_Contact_ID__c = 'test';
        accr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        accr2.Zuora_Sync__c = true;
        recs.add(accr2);
        
        insert recs;
               
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Account';
        mss.SurvivorExternalID = 'account2';
        mss.VictimExternalIDs = new list < string > ();
        List < string > stringlist = new List < string > ();
        stringlist.add('account1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    
    
    public static testMethod void testMethod6() {
        setupData();
        List<Account_Relationship__c> recs = new List<Account_Relationship__c>();
        Account_Relationship__c conr1 = new Account_Relationship__c();
        conr1.Child_Account__c = account1.id;
        conr1.Contact_To__c = contact1.id;
        conr1.Entity_Name__c = 'abc';
        conr1.Is_Parent_Primary__c = true;
        //conr1.Parent_Account__c = account4.id;
        conr1.Active__c = true;
        conr1.RecordTypeId = contactRelationshipRecordTypeId;
        conr1.Relationship_Type__c = 'Member';
        conr1.Zuora_Bill_to_Contact_ID__c = 'test';
        conr1.Zuora_Ship_to_Contact_ID__c = 'testing';
        conr1.Zuora_Sync__c = true;
        conr1.Contact_Role__c = 'Primary Contact';
        conr1.Billing_Contact__c = true;
        recs.add(conr1);
      
       
        Account_Relationship__c conr2 = new Account_Relationship__c();
        conr2.Child_Account__c = account1.id;
        conr2.Contact_To__c = contact2.id;
        conr2.Entity_Name__c = 'abc';
        conr2.Is_Parent_Primary__c = true;
        conr2.Parent_Account__c = account4.id;
        conr2.Active__c = true;
        conr2.RecordTypeId = contactRelationshipRecordTypeId;
        conr2.Relationship_Type__c = 'Member';
        conr2.Zuora_Bill_to_Contact_ID__c = 'test';
        conr2.Zuora_Ship_to_Contact_ID__c = 'testing';
        conr2.Zuora_Sync__c = true;
        conr2.Contact_Role__c = 'Primary Contact';
        conr2.Billing_Contact__c = true;
        recs.add(conr2);
        
        insert recs;
        
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(contact1.Id,'Email','varisa@yahoo.com',true,true,'Business Email');  
        Engagement_Activity__c engActivity = new Engagement_Activity__c(Contact__c = contact1.Id, Contact_Method__c = contactMethodRecord1.Id);
        insert engActivity;

        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Contact';
        mss.SurvivorExternalID  = 'contact2';
        mss.VictimExternalIDs = new list <string>();
        List < string > stringlist = new List < string > ();
        stringlist.add('contact1');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    

    public static testMethod void testMethod7() {
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        TestDataFactory.createDisbaleTriggerCustomSetting();  
        id rectypid = [select id from RecordType where SobjectType = 'Account' and name = 'B2B'].id;
        List<Account> accs = new List<Account>();
        account1.RecordTypeId = rectypid;
        account1.name = 'XYZ';
        account1.Phone = '+49-12345';
        account1.BillingStreet = 'Am Tierpark 16';
        account1.BillingCity = 'Cologne';
        account1.BillingPostalCode = '54321';
        account1.BillingState = 'Nordrhein-Westfalen';
        account1.BillingCountry = 'Germany';
        account1.Primary_Email__c = 'ra@gmail.com';
        account1.Home_Phone__c = '967622877';
        account1.Work_Phone__c = '456789';
        account1.Mobile1__c = '1234566';
        account1.Mobile2_Other__c = '1245787';
        account1.party_id__c = 'account1';
        accs.add(account1);
        
        account2= new Account();
        account2.RecordTypeId = rectypid;
        account2.name = 'XYZ';
        account2.Phone = '+49-12345';
        account2.BillingStreet = 'Am Tierpark 16';
        account2.BillingCity = 'Cologne';
        account2.BillingPostalCode = '54321';
        account2.BillingState = 'Nordrhein-Westfalen';
        account2.BillingCountry = 'Germany';
        account2.Primary_Email__c = 'ra@gmail.com';
        account2.Home_Phone__c = '967622877';
        account2.Work_Phone__c = '456789';
        account2.Mobile1__c = '1234566';
        account2.Mobile2_Other__c = '1245787';
        account2.party_id__c = 'account2';
        accs.add(account2);
        
        insert accs;
        
         id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and name = 'Standard'].id;
        List<Contact> cons = new List<Contact>();
        contact1.RecordTypeId = cntctrectypid;
        contact1.FirstName = 'Joe';
        contact1.LastName = 'Schmoe';
        contact1.Email = 'Joe.Schmoe@test.de';
        contact1.AccountId = account1.id;
        contact1.MailingStreet = account1.BillingStreet;
        contact1.MailingState = account1.BillingState;
        contact1.MailingCity = account1.BillingCity;
        contact1.MailingPostalCode = account1.BillingPostalCode;
        contact1.MailingCountry = account1.BillingCountry;
        contact1.Phone = account1.Phone;
        contact1.Type__c = 'Agent';
        contact1.Active__c=True;
        contact1.Contact_Party_ID__c = 'contact1';
        cons.add(contact1);
        
        contact2.RecordTypeId = cntctrectypid;
        contact2.FirstName = 'Joe';
        contact2.LastName = 'Schmoe';
        contact2.Email = 'Joe.Schmoe@test.de1';
        contact2.AccountId = account2.id;
        contact2.MailingStreet = account2.BillingStreet;
        contact2.MailingState = account2.BillingState;
        contact2.MailingCity = account2.BillingCity;
        contact2.MailingPostalCode = account2.BillingPostalCode;
        contact2.MailingCountry = account2.BillingCountry;
        contact2.Phone = account2.Phone;
        contact2.Type__c = 'Agent';
        contact2.Active__c=True;
        contact2.Contact_Party_ID__c = 'contact2';
        cons.add(contact2);
         
        insert cons;
        
        List<ContactMethod__c> conMethods = new List<ContactMethod__c>();
        ContactMethod__c contactMethod1 = new ContactMethod__c();
        contactMethod1.Contact__c = contact1.Id;
        contactMethod1.Type__c = 'Email';
        contactMethod1.Email__c = 'varisa@gmail.com';
        contactMethod1.Active__c = true;
        contactMethod1.Primary_To_Contact__c = true;
        contactMethod1.External_ID__c = '345677';
        contactMethod1.Bounce_Back_Email__c = TRUE;
        contactMethod1.Source_Type__c = 'Web';
        contactMethod1.Type_Purpose__c ='Business Email';
       conMethods.add(contactMethod1);
        
        ContactMethod__c contactMethod2 = new ContactMethod__c();
        contactMethod2.Contact__c = contact2.Id;
        contactMethod2.Type__c = 'Email';
        contactMethod2.Email__c = 'varisa@outlook.com';
        contactMethod2.Active__c = true;
        contactMethod2.Primary_To_Contact__c = true;
        contactMethod2.External_ID__c = '123456';
        contactMethod2.Source_Type__c = 'Web';
        conMethods.add(contactMethod2);
        contactMethod2.Type_Purpose__c ='Business Email';
        insert conMethods;
        
         Waitlist__c  w = new Waitlist__c();
        w.Account__c= account1.id;
        w.Pre_Auth_Contact__c= contact1.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;
        
        Engagement_Activity__c engActivity = new Engagement_Activity__c(Contact__c = contact1.Id, Contact_Method__c = contactMethod1.Id);
        insert engActivity;      
        
        Lead leadRecord = new Lead(LastName = 'Mr',FirstName = 'Test',Status = 'New',Company = 'Test',Account__c = account2.id,Contact__c = contact1.id,Assigned_Group__c = 'test_group',Contact_Method__c=contactMethod1.Id);
        Insert leadRecord; 
        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'ContactMethod';
        mss.SurvivorExternalID  = '123456';
        mss.VictimExternalIDs = new list <string>();
        List <string> stringlist = new List <string>();
        stringlist.add('345677');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }
    
       /* public static testMethod void testMethod8() {
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        TestDataFactory.createDisbaleTriggerCustomSetting();  
        id rectypid = [select id from RecordType where SobjectType = 'Account' and name = 'B2B'].id;
        List<Account> accs = new List<Account>();
        account1.RecordTypeId = rectypid;
        account1.name = 'XYZ';
        account1.Phone = '+49-12345';
        account1.BillingStreet = 'Am Tierpark 16';
        account1.BillingCity = 'Cologne';
        account1.BillingPostalCode = '54321';
        account1.BillingState = 'Nordrhein-Westfalen';
        account1.BillingCountry = 'Germany';
        account1.Primary_Email__c = 'ra@gmail.com';
        account1.Home_Phone__c = '967622877';
        account1.Work_Phone__c = '456789';
        account1.Mobile1__c = '1234566';
        account1.Mobile2_Other__c = '1245787';
        account1.party_id__c = 'account1';
        accs.add(account1);
        
        
        insert accs;
        
         id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and name = 'Standard'].id;
        List<Contact> cons = new List<Contact>();
        contact1.RecordTypeId = cntctrectypid;
        contact1.FirstName = 'Joe';
        contact1.LastName = 'Schmoe';
        contact1.Email = 'Joe.Schmoe@test.de';
        contact1.AccountId = account1.id;
        contact1.MailingStreet = account1.BillingStreet;
        contact1.MailingState = account1.BillingState;
        contact1.MailingCity = account1.BillingCity;
        contact1.MailingPostalCode = account1.BillingPostalCode;
        contact1.MailingCountry = account1.BillingCountry;
        contact1.Phone = account1.Phone;
        contact1.Type__c = 'Agent';
        contact1.Active__c=True;
        contact1.Contact_Party_ID__c = 'contact1';
        cons.add(contact1);
        
        contact2.RecordTypeId = cntctrectypid;
        contact2.FirstName = 'Joe';
        contact2.LastName = 'Schmoe';
        contact2.Email = 'Joe.Schmoe@test.de1';
        contact2.AccountId = account1.id;
        contact2.MailingStreet = account1.BillingStreet;
        contact2.MailingState = account1.BillingState;
        contact2.MailingCity = account1.BillingCity;
        contact2.MailingPostalCode = account1.BillingPostalCode;
        contact2.MailingCountry = account1.BillingCountry;
        contact2.Phone = account1.Phone;
        contact2.Type__c = 'Agent';
        contact2.Active__c=True;
        contact2.Contact_Party_ID__c = 'contact2';
        cons.add(contact2);
         
        insert cons;
        
        List<ContactMethod__c> conMethods = new List<ContactMethod__c>();
         ContactMethod__c contactMethod1 = new ContactMethod__c();
        contactMethod1.Contact__c = contact1.Id;
        contactMethod1.Type__c = 'Email';
        contactMethod1.Value__c = 'varisa@gmail.com';
        contactMethod1.Value1__c = 'varisa@gmail.com';
        contactMethod1.Active__c = true;
        contactMethod1.Primary_To_Contact__c = true;
        contactMethod1.External_ID__c = '345677';
       conMethods.add(contactMethod1);
        
         ContactMethod__c contactMethod2 = new ContactMethod__c();
        contactMethod2.Contact__c = contact2.Id;
        contactMethod2.Type__c = 'Email';
        contactMethod2.Value__c = 'varisa@outlook.com';
        contactMethod2.Value1__c = 'varisa@outlook.com';
        contactMethod2.Active__c = true;
        contactMethod2.Primary_To_Contact__c = true;
        contactMethod2.External_ID__c = '123456';
        conMethods.add(contactMethod2);
        
        insert conMethods;              
        
        MergeServiceSOAP.MergeInput mss = new MergeServiceSOAP.MergeInput();
        mss.EntityName = 'Contact';
        mss.SurvivorExternalID  = 'contact1';
        mss.VictimExternalIDs = new list <string>();
        List < string > stringlist = new List < string > ();
        stringlist.add('contact2');
        mss.VictimExternalIDs.addall(stringlist);
        
        List<MergeServiceSOAP.MergeInput> listmergeids = new List<MergeServiceSOAP.MergeInput>();
        listmergeids.add(mss);
        
        test.startTest();
        MergeServiceSOAP.MergeObjects(listmergeids);
        test.stopTest();
        
    }*/
}