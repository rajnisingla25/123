// Apex Test Class Name: CountRelatedchildCases_Test 
// For Testing: CountRelatedchildCases.cls
//
// 28th August 2015 Venkataramana Cheedara    Original 

@isTest(seeAllData=false)
private class CountRelatedchildCases_Test {
    static testMethod void CountRelatedchildCasesTest() {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;
                          
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Case parentCase = new Case();
        insert parentCase;
          
        test.startTest();
        Case childCase = new Case();
        childCase.parentid = parentCase.id;
        insert childCase;
        CountRelatedchildCases.updateChildCases(new Map<Id, Case>{childCase.id=>childCase},new Map<Id, Case>{childCase.id=>childCase},false);   
        childCase.parentid = null;
        update childCase ;
        delete childCase ;
        test.stopTest();
    }
}