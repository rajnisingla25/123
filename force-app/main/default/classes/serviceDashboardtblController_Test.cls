/*
Author : Srinivas Vadla
Purpose : Serves as a controller test for serviceDashboardtable lightning component
JIRA : CRM-2266
*/
@isTest
public class serviceDashboardtblController_Test {
    static testmethod void serviceTest(){
       DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
       Account theTestAccount = TestDataFactory.createAccount('Team Member Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmailRandom@test.com';
        insert theTestAccount; 
       Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
      
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting; 
        case newcase = new case();
            newcase.AccountId = theTestAccount.Id;
            //newcase.ContactId = personContact,
            newcase.RecordTypeId = devRecordTypeId;
            newcase.Type='My Type';
            newcase.Origin='My Origin';
            newcase.Status='My Status';
            //newcase.Call_Attempt__c='1';
            Insert newcase;
        serviceDashboardtblController.fetchcaseInfo('New Issues');
        serviceDashboardtblController.fetchcaseInfo('Top Issues');
        serviceDashboardtblController.fetchcaseInfo('Known Issues');
        serviceDashboardtblController.fetchcaseInfo('Resolved Issues');
       // SObjectType caseType = Schema.getGlobalDescribe().get('Case');
       serviceDashboardtblController.getselectOptions( newcase,'Type_of_Issue__c');
    }
}