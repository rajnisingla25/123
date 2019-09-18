@isTest
public class ServiceDashboardControllerTest {
    
    public static testMethod void test1(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Account a = TestDataFactory.createAccount('test Acc 1', null, false);
        a.type = 'Realtor Agent';
        a.Advertiserid__c = '12345';
        insert a;
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;
        Waitlist_Urls__c wlu1 = new Waitlist_Urls__c(Name = 'GetAgnOffSsoDetail', URL__c = '...');
        Waitlist_Urls__c wlu2 = new Waitlist_Urls__c(Name = 'ResetSSOAttempts', URL__c = '...');
        Waitlist_Urls__c wlu3 = new Waitlist_Urls__c(Name = 'ReleaseSSOEmail', URL__c = '...');
        Waitlist_Urls__c wlu4 = new Waitlist_Urls__c(Name = 'ListingsAPI', URL__c = '...{AdvId}');

        List<Waitlist_Urls__c> wluList = new List<Waitlist_Urls__c>{wlu1,wlu2,wlu3,wlu4};
        insert wluList;
        
        List<Case> theTestCases = new List<Case>();
        for(Integer index = 0; index < 2; index++) {
            theTestCases.add(TestDataFactory.createCase(
                'Test Case #' + (index + 1),
                'New',
                'Retention',
                'Test Case #' + (index + 1),
                null,
                a.Id,
                false
            ));
        }
        insert theTestCases;
        ServiceDashboardController.fetchAccountInfo(a.id);
        ServiceDashboardController.fetchOpenCases(a.Id);
        ServiceDashboardController.fetchSSODetails(a.Id);
        ServiceDashboardController.fetchIssues(a.Id);
        ServiceDashboardController.fetchRelationshipInfo(a.Id);
        ServiceDashboardController.resetLoginAttempts('abc@gmail.com');
        ServiceDashboardController.releaseEmailForAdvId('12345');
        ServiceDashboardController.fetchBrokerExclusions(a.id);
        ServiceDashboardController.fetchListings(a.id);
    }
    
}