// Test Class Name: MoveUtility_Test
// For Apex Class: MoveUtility

@isTest(seeAllData=false)
private class MoveUtility_Test {
    private static testMethod void testgetQueueForUser() {
        
        Test.startTest();
        MoveUtility.getQueueForUser(UserInfo.getUserId());
        Test.stopTest();
    }
    
    private static testMethod void testgetGroupsForIds() {
        Set<Id> userOrGroupIds = new Set<id>() ;
        userOrGroupIds.add(UserInfo.getUserId());
        Test.startTest();
        MoveUtility.getGroupsForIds(userOrGroupIds );
        Test.stopTest();
    }
    
    private static testMethod void testconvertID15to18() {
        Test.startTest();
        String newID = MoveUtility.convertID15to18('001j000000bb5R5');
        Test.stopTest();
        
        System.assert(newId == '001j000000bb5R5AAI');
    }   
    
    private static testMethod void testisBadEmail() {
        Test.startTest();
        Boolean badEmail = MoveUtility.isBadEmail('bad_test@test.com');
        Test.stopTest();
        
        System.assert(badEmail);
    }
    
    private static testMethod void testupdatePhoneFieldsForLead(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        Collection_Users__c coluser = new Collection_Users__c();
        coluser.Name = 'batchintegration user';
        coluser.Id__c  = userinfo.getuserid();
        insert coluser;
        
        List<ContactMethod__c> updCMlist = new List<ContactMethod__c>();
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','9988776655',true,true,'Business Phone');
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');       
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342341234',true,true,'BUSINESS_MOBILE');
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342343424',true,true,'PERSONAL_PHONE');
        ContactMethod__c contactMethodRecord8 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342462334',true,true,'BUSINESS_PHONE');
        ContactMethod__c contactMethodRecord9 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342539234',true,true,'PERSONAL_MOBILE');
        
        contactMethodRecord7.Phone_Extension__c = '4321';
        contactMethodRecord8.Phone_Extension__c = '4121';
        updCMlist.add(contactMethodRecord7);
        updCMlist.add(contactMethodRecord8);       
        update updCMlist;
        
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New1';
        Led11.Company = 'Test1';
        Led11.Account__c = acc.id;
        Led11.Contact__c = cont.id;
        Led11.Email = 'c.s12@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test2';
        Led11.Recent_Campaign_Id__c = '1234';
        Led11.RDC_Contact_Type__c = '';       
        insert Led11;
        
        MoveUtility.updatePhoneFields(new List<Lead>{Led11},new Set<Id>{acc.Id});
    }
    
    private static testMethod void testupdatePhoneFieldsForCase(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        Collection_Users__c coluser = new Collection_Users__c();
        coluser.Name = 'batchintegration user';
        coluser.Id__c  = userinfo.getuserid();
        insert coluser;
        
        List<ContactMethod__c> updCMlist = new List<ContactMethod__c>();
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','9988776655',true,true,'Business Phone');
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');       
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342341234',true,true,'BUSINESS_MOBILE');
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342343424',true,true,'PERSONAL_PHONE');
        ContactMethod__c contactMethodRecord8 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342462334',true,true,'BUSINESS_PHONE');
        ContactMethod__c contactMethodRecord9 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342539234',true,true,'PERSONAL_MOBILE');
        
        contactMethodRecord7.Phone_Extension__c = '4321';
        contactMethodRecord8.Phone_Extension__c = '4121';
        updCMlist.add(contactMethodRecord7);
        updCMlist.add(contactMethodRecord8);       
        update updCMlist;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;   
        Case theCase = new Case(Subject = ' Test case ',Status = 'New',Type = 'Retention',Description = ' sample text ',AccountId = acc.Id,ContactId = cont.Id);
        insert theCase;
        
        MoveUtility.updatePhoneFields(new List<Case>{theCase},new Set<Id>{acc.Id});
    }
    
    private static testMethod void testupdatePhoneFieldsForOppty(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        Collection_Users__c coluser = new Collection_Users__c();
        coluser.Name = 'batchintegration user';
        coluser.Id__c  = userinfo.getuserid();
        insert coluser;
        
        List<ContactMethod__c> updCMlist = new List<ContactMethod__c>();
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','9988776655',true,true,'Business Phone');
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');       
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342341234',true,true,'BUSINESS_MOBILE');
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342343424',true,true,'PERSONAL_PHONE');
        ContactMethod__c contactMethodRecord8 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342462334',true,true,'BUSINESS_PHONE');
        ContactMethod__c contactMethodRecord9 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342539234',true,true,'PERSONAL_MOBILE');
        
        contactMethodRecord7.Phone_Extension__c = '4321';
        contactMethodRecord8.Phone_Extension__c = '4121';
        updCMlist.add(contactMethodRecord7);
        updCMlist.add(contactMethodRecord8);       
        update updCMlist;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Opportunity theOpportunity = mtduc.CreateOppurtunitySingle();
        BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = acc.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        OracleQuote.BigMachines__Site__c = Label.BigMachineSite;        
        insert OracleQuote;
        
        Test.startTest();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New1';
        Led11.Company = 'Test1';
        Led11.Account__c = acc.id;
        Led11.Contact__c = cont.id;
        Led11.Email = 'c.s12@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test2';
        Led11.Recent_Campaign_Id__c = '1234';
        Led11.RDC_Contact_Type__c = '';        
        insert Led11;
        
        theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Closed Won - Fulfilled';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = acc.id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        theOpportunity.Bigmachine_Quote_ID1__c = OracleQuote.Id;
        theOpportunity.Follow_up_status__c = 'LM 1st Attempt';
        theOpportunity.NextContactTime__c = Date.today();
        theOpportunity.Lead__c = Led11.Id;
        insert theOpportunity;
        
        MoveUtility.updatePhoneFields(new List<Opportunity>{theOpportunity},new Set<Id>{acc.Id});
        test.stopTest();
    }
}