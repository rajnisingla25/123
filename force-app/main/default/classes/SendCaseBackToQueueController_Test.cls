@isTest
Public class SendCaseBackToQueueController_Test{
    static testMethod void SendCaseBackToQueueController_Test(){
          //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theAccount.ShippingState  = 'CA';
    theAccount.ShippingCountry  = 'USA';
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);  
    
     Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Standard').getRecordTypeId();
     
     CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
              insert setting;
            
    Case testCase = new case();
     testCase.recordTypeId = rtId;
     testCase.Status = 'New';
     testCase.Origin = 'Phone';
     testCase.AccountId = theAccount.Id;     
     testCase.ownerId = Userinfo.getUserId();     
      Insert testCase;
    system.debug('testCase:' + testCase.Id);    
     test.startTest();
    PageReference pgr = page.SendCaseBackToQueue;
    pgr.getParameters().put('caseId',testCase.id);
    Test.SetCurrentPage(pgr);    
    SendCaseBackToQueueController IP = new SendCaseBackToQueueController();   
    SendCaseBackToQueueController.triggerAssignmentRules(testCase.id);
    SendCaseBackToQueueController.reassignCaseWithActiveRule(testCase.id);
    test.stopTest();
    }  
}