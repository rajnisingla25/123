@isTest
Public class ReturnToQueueController_Test  {
    static testMethod void ReturnToQueueController_Test(){
         //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
    
     Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Standard').getRecordTypeId();
      
      CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;
                  
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact;
    List<Case> Cases = new List<Case >();
     Case testCase = new case();
     testCase.recordTypeId = rtId;
     testCase.Status = 'New';
     testCase.Origin = 'Phone';
     testCase.AccountId = theAccount.Id;
     testCase.ContactId = testContact.Id;
     testCase.ownerId = Userinfo.getUserId();     
     cases.add(testCase);     
    Insert cases;   
    
    Set<Id> selectedCases = new Set<Id>();
    for(case cs : cases){
    selectedCases.add(cs.Id);
    }
    
    test.startTest();
    PageReference pgr = page.ReturnToQueue;
    pgr.getParameters().put('caseId',testCase.id);
    Test.SetCurrentPage(pgr);    
     ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cases);
    stdSetController.setSelected(cases);
    ReturnToQueueController  Ret  = new ReturnToQueueController(stdSetController);
    Ret.triggerAssignmentRules();
    ReturnToQueueController.reassignCaseWithActiveRule(selectedCases);
       test.stopTest();  
    }
 }