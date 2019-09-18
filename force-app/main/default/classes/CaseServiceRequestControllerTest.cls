@isTest
private class CaseServiceRequestControllerTest{
    public static testMethod void test() {
        DisabledTrigger__c vb=new DisabledTrigger__c(
                name='Disabled',
                TaskTrigger__c=''
            );
        insert vb;
        Switch_CaseTrigger__c sb = new Switch_CaseTrigger__c(
            Set_Overall_Trigger_Off__c = true
            );
        insert sb;
        List<Account> listAccount = new List<Account>();
        List<Contact> listContact = new List<Contact>();
        List<Case> caseList = new List<Case>();
        Account parentAcc2 = TestDataFactory.createAccount('Parent Acc2',null,false);
        parentAcc2.Primary_Email__c = 'parentAcc2@move.com';
        parentAcc2.ShippingState  = 'CA';
        parentAcc2.ShippingCountry  = 'USA';
        listAccount.add(parentAcc2);        
        insert listAccount; 

        Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        test.starttest();
        PageReference pref = Page.CaseServiceRequest;
        pref.getParameters().put('id',listAccount[0].id);
        Test.setCurrentPage(pref);
        CaseServiceRequestController cse = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cse.saveAndRedirect();
        CaseServiceRequestController cs = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cs.caserecord.Request_Urgency__c='Future Request';
        cs.caserecord.Cancel_on_date__c = null;
        cs.saveAndRedirect();
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        CaseServiceRequestController cs1 = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cs1.caserecord.Cancel_type__c = null;
        cs1.caserecord.Request_Type__c = 'Cancel Only';
        cs1.saveAndRedirect();
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        CaseServiceRequestController cs2 = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cs2.caserecord.Description = 'Testing';
        cs2.caserecord.Credit_Amount__c = null;
        cs2.caserecord.Request_Type__c = 'Credit to Account Only';
        cs2.saveAndRedirect();
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        CaseServiceRequestController cs3 = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cs3.caserecord.Description = 'Testing';
        cs3.caserecord.Refund_Amount__c = null;
        cs3.caserecord.Request_Type__c = 'Refund to Card Only';
        cs3.saveAndRedirect();
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        CaseServiceRequestController cs4 = new CaseServiceRequestController(new ApexPages.StandardController(listAccount[0]));
        cs4.caserecord.Request_Urgency__c = 'Urgent Request (bills soon)';
        cs4.caserecord.Urgent_Request_Bill_Date__c = null;
        cs4.saveAndRedirect();
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        test.stoptest();
    }
            
}