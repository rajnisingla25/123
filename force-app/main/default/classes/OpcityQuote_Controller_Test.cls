@isTest(seeAllData = false)
Public Class OpcityQuote_Controller_Test{
  
    public static testMethod Void test1 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.Order_Trigger__c= UserInfo.getUserName();
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= UserInfo.getUserId());
        insert coll;
        
        BigMachineUrls__c urls = new BigMachineUrls__c(Name='BM', BigmachineInstance__c='test', Salesforce_Instance__c='test');
        insert urls;
            
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
        
        OrderDecompController.stopCreatingAccount = true;
        SkipOrderItemTrigger.setSkipTrgTrue();
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Account broker = mtduc.CreateBrokerAccountSingle();
        mtduc.CreateRealtorOfficeAccountSingle();
        mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        Contact c = mtduc.CreateContactSingle();
        c.title='test';
        update c;
        Id recTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Contact Relationship').getRecordTypeId();
        Account_Relationship__c rel = new Account_Relationship__c(Parent_Account__c=broker.Id, Contact_To__c=c.Id,Contact_Role__c = 'Primary Contact',RecordTypeId=recTypeId );
        insert rel;
        
        Product2 p = mtduc.CreateProductSingle();
        p.ProductCode = 'OPCITYBLA';
        p.Active_Contract_Terms__c = '6;12;24';
        p.Default_Term__c = '6';
        update p;
        test.startTest();
        PageReference pageRef = Page.OpcityQuote;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',broker.Id);
        OpcityQuote_Controller cont = new OpcityQuote_Controller();
        cont.pageLoadAction();
        List<String> s = cont.confirmedsources;
        cont.unconfirmedsources = new List<String>{'1', '2'};
        cont.confirmedsources = new List<String>{'1', '2'};
        cont.offices[0].selected=true;
        cont.offices[0].action='add';
        cont.offices[0].inflight='In Progress';
        s = cont.offices[0].confirmedsources;
        s = cont.offices[0].unconfirmedsources;
        cont.offices[0].confirmedsources = new List<String>{'1', '2'};
        s = cont.offices[0].unconfirmedsources;
        cont.offices[0].unconfirmedsources = new List<String>{'1', '2'};
        cont.createCPQQuote();
        cont.saveMsa();
        test.stopTest();
    }
}