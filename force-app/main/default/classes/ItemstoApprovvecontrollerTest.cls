@isTest(SeeAllData = false)
private class ItemstoApprovvecontrollerTest {

    private static testMethod void testItemtoApprove() {
         DisabledTrigger__c vb=new DisabledTrigger__c(
                name='Disabled',
                TaskTrigger__c=''
            );
        insert vb;
        Switch_CaseTrigger__c sb = new Switch_CaseTrigger__c(
            Set_Overall_Trigger_Off__c = false
            );
        insert sb;
        List<Account> listAccount = new List<Account>();
        Account parentAcc2 = TestDataFactory.createAccount('Parent Acc2',null,false);
        parentAcc2.Primary_Email__c = 'parentAcc2@move.com';
        parentAcc2.ShippingState  = 'CA';
        parentAcc2.ShippingCountry  = 'USA';
        listAccount.add(parentAcc2);        
        insert listAccount;
        Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Id RTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
                
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = RTypeId);
        insert setting;  
        
        User thisUser = [SELECT Id FROM User WHERE Name = :'Kelly Lange'];
        System.runAs (thisUser) {
            Case case2 = new case();
            case2.Cancel_type__c = null;
            case2.Request_Type__c = 'Cancel Only';
            case2.AccountId  = parentAcc2.Id;
            case2.recordTypeId = RecordTypeId;
            case2.Status = 'New';
            case2.Origin = 'Web';
            case2.Type = 'Lead Suspension';
            case2.Subject = '1st Invoice did not Collect on Asset';
            case2.CreatedDate  = System.today();
            case2.Description = 'Test Description'; 
            insert case2;
            
            Approval.ProcessSubmitRequest r = new Approval.ProcessSubmitRequest();

            r.setObjectId(case2.Id);
        
            Approval.process(r);
        }
        User thatUser = [SELECT Id FROM User WHERE Name = :'Stuart Sim'];
        System.runAs (thatUser) {
            Test.startTest();
            ItemstoApprovvecontroller itac = new ItemstoApprovvecontroller();
            ItemstoApprovvecontroller.ApproveRejectnavigation();
            ItemstoApprovvecontroller.REASSIGNnavigation();
            Case cs = [select Id from Case where Request_Type__c = 'Cancel Only' limit 1];
            PageReference pref = Page.ItemstoApprovve;
            pref.getParameters().put('id',cs.id);
            Test.setCurrentPage(pref);
        
            ApexPages.StandardController accStdcon = new ApexPages.StandardController(cs);
            ItemstoApprovvecontroller accBIExt = new ItemstoApprovvecontroller(accStdcon);
            Test.stopTest();
        }
    }

}