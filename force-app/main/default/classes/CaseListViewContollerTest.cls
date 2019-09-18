@isTest
public class CaseListViewContollerTest {
    
    
    
    private Static testMethod void test_REFRESH(){
        CaseListViewContoller controller = new CaseListViewContoller();
        
        PageReference pRef =  controller.Refresh();
        system.assertEquals(null, pRef);
    }
    
    
    private static testMethod void test_ACCEPT(){
        CaseListViewContoller controller = new CaseListViewContoller();
        List<SelectOption> listOfQueues = controller.QueueList;
        controller.displaycaselist();
        controller.Accept();
        //controller.deleteRecord();
    }
    
    private static testMethod void test_INNERCLASS(){
         //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg         	= new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;

	  // Create Test Account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testEmail@test.com';
        insert testAccount;
        
        // Create Test Contact
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'testEmail@move.com';
        insert testContact;
        
        Id caseRecordTypeId			 		= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        insert new CaseRecordTypes__c(Name='Retention', Record_Type_Id__c = String.valueOf(caseRecordTypeId));
        
        Case c = TestDataFactory.createCase('Test Subject', 'New', 'International', 'TEst description', testContact.id, testAccount.id, true) ;
        
        CaseListViewContoller controller = new CaseListViewContoller();
        CaseListViewContoller.CaseWrapper wrapperController = new CaseListViewContoller.CaseWrapper(C);
        
    }
    
    private static testMethod void test_ACCEPT_MULTIPLE_CASES_SELECTED(){
        
        PageReference pgr = page.CaseListView;
        Test.SetCurrentPage(pgr);
        
        List<CaseListViewContoller.CaseWrapper> wrapperList = new List<CaseListViewContoller.CaseWrapper>();
        CaseListViewContoller controller = new CaseListViewContoller();
         //Inserting Customsetting for Account     
		DisabledTrigger__c Dtrg         	= new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        // Create Test Account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testEmail@test.com';
        insert testAccount;
        
        // Create Test Contact
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'testEmail@move.com';
        insert testContact;
        
        // Create Queue
        Group testQueue = new Group(Name='Default Queue', type='Queue');
        insert testQueue;
        
        Case c = TestDataFactory.createCase('Test Subject1', 'New', 'International', 'TEst description1', testContact.id, testAccount.id, false) ;
        c.ownerId = testQueue.id;
        CaseListViewContoller.CaseWrapper wrapperController1 = new CaseListViewContoller.CaseWrapper(C);
        wrapperController1.checked = true;

        wrapperList.add(wrapperController1);
        
        Id caseRecordTypeId			 		= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        insert new CaseRecordTypes__c(Name='Retention', Record_Type_Id__c = String.valueOf(caseRecordTypeId));
        
        
        Case c1 = TestDataFactory.createCase('Test Subject2', 'New', 'International', 'Test description2', testContact.id, testAccount.id, false) ;
        CaseListViewContoller.CaseWrapper wrapperController2 = new CaseListViewContoller.CaseWrapper(C1);
        wrapperController2.checked = true;

        wrapperList.add(wrapperController2);


        controller.Queue = testQueue.id; 
        controller.caselstnew = wrapperList;
        
        controller.Accept();
        //controller.deleteRecord();
        system.assertEquals(1 , ApexPages.getMessages().size());
        
    }
    
    private static testMethod void test_ACCEPT_ONE_CASE_SELECTED(){
        
        PageReference pgr = page.CaseListView;
        Test.SetCurrentPage(pgr);
        
        List<CaseListViewContoller.CaseWrapper> wrapperList = new List<CaseListViewContoller.CaseWrapper>();
        CaseListViewContoller controller = new CaseListViewContoller();
         //Inserting Customsetting for Account     
		DisabledTrigger__c Dtrg         	= new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        
        // Create Test Account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testEmail@test.com';
        insert testAccount;
        
        // Create Test Contact
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'testEmail@move.com';
        insert testContact;
        
        // Create Queue
        Group testQueue = new Group(Name='Default Queue', type='Queue');
      //  insert testQueue;
        
        Id caseRecordTypeId			 		= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        insert new CaseRecordTypes__c(Name='Retention', Record_Type_Id__c = String.valueOf(caseRecordTypeId));


        Case c = TestDataFactory.createCase('Test Subject1', 'New', 'International', 'TEst description1', testContact.id, testAccount.id, true) ;
        c.ownerId = testQueue.id;
        CaseListViewContoller.CaseWrapper wrapperController1 = new CaseListViewContoller.CaseWrapper(C);
        wrapperController1.checked = true;

        wrapperList.add(wrapperController1);
        
        
        
        Case c1 = TestDataFactory.createCase('Test Subject2', 'New', 'International', 'Test description2', testContact.id, testAccount.id, true) ;
        CaseListViewContoller.CaseWrapper wrapperController2 = new CaseListViewContoller.CaseWrapper(C1);
        wrapperController2.checked = false;

        wrapperList.add(wrapperController2);


        controller.Queue = testQueue.id; 
        controller.caselstnew = wrapperList;
        
        controller.Accept();
        //controller.deleteRecord();
        system.assertEquals(0 , ApexPages.getMessages().size());
        
    }
    
    
    
    
    
    
    
}