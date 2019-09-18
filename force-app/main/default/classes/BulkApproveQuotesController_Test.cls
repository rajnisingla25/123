@isTest(seeAlldata=false)
private class BulkApproveQuotesController_Test {
   
    static testMethod void testMethod1() {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        
        BigMachineUrls__c urls = new BigMachineUrls__c(Name='BM', BigmachineInstance__c='test', Salesforce_Instance__c='test');
        insert urls;
        
        Bulk_Approve_Quote_Setting__c setting = new Bulk_Approve_Quote_Setting__c(Name=UserInfo.getUserName(), Quote_Transaction_Id__c='1234');
        insert setting;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        BigMachines__Quote__c q = mtduc.CreateOracleQuoteSingle();
        q.Pending_Approval_With__c = UserInfo.getUserId();
        update q;
        BigMachines__Quote__c q1 = mtduc.CreateOracleQuoteSingle();
        q1.BigMachines__Transaction_Id__c = '1234';
        update q1;
        
        test.startTest();
        BulkApproveQuotesController controller = new BulkApproveQuotesController();
        controller.quotes[0].selected = true;
        controller.updateDummyQuote();
        test.stopTest();
    }
    
}