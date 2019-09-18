@istest
public class FollowUpUpdateController_Test {



    Private Static testmethod void CaseUpdate(){        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c  = 'Test@test.com';
        insert Dtrg;        
        Account objAcc = TestDataFactory.createAccount('Test Account', null, false);
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
         CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
         insert setting;
         List<Case> selectedCases = new  List<Case>();
        Case objCase = new Case();
        objCase.RecordTypeId = rtId ;
        objCase.Status = 'Open';
        objCase.Comments__c = 'Test Comment';
        objCase.AccountId = objAcc.id;
        objCase.Followup_Status__c = 'COS';
        objCase.Cancel_Reason__c = 'Lead Quality';
        insert objCase;       
        selectedcases.add(objCase);        
        PageReference pageRef = Page.assetMassUpdate;
        pageRef.getParameters().put('retURL', '/'+selectedCases[0].id);
        Test.setCurrentPage(pageRef);        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(selectedCases);
        sc.setSelected(selectedCases);
      FollowUpUpdateController obj = new FollowUpUpdateController(sc);
      obj.updateCases();        
    }
    
        Private Static testmethod void CaseUpdate1(){        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c  = 'Test@test.com';
        insert Dtrg;        
        Account objAcc = TestDataFactory.createAccount('Test Account', null, false);
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
         CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
         insert setting;
         List<Case> selectedCases = new  List<Case>();
        Case objCase = new Case();
        objCase.RecordTypeId = rtId ;
        objCase.Status = 'Closed';
        objCase.Comments__c = 'Test Comment1';
        objCase.AccountId = objAcc.id;
        objCase.Followup_Status__c = 'Cancel';
        objCase.Cancel_Reason__c = 'Lead Quality';
        insert objCase;       
        selectedcases.add(objCase);        
        PageReference pageRef = Page.assetMassUpdate;
        pageRef.getParameters().put('retURL', '/'+selectedCases[0].id);
        Test.setCurrentPage(pageRef);        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(selectedCases);
        sc.setSelected(selectedCases);
      FollowUpUpdateController obj = new FollowUpUpdateController(sc);
      obj.updateCases();        
    }           
}