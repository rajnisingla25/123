@isTest (SeeAllData=false)
public class Mortgage_Email_Controller_Test{  
    static testMethod void testMethod1() {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        OrderDecompController.stopCreatingAccount = true;
        Mortgage_Email_Controller con = new Mortgage_Email_Controller();
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Product2 newProduct = mtduc.CreateProductSingle();
        newProduct.EssentialsRequired__c = True;
        update newProduct;
        mtduc.CreatePricebookEntrySingle();       
        Opportunity theOpportunity = mtduc.CreateOppurtunitySingle();
       
        Account newAccount = mtduc.CreateBrokerAccountSingle();
        newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();
        update newAccount;
        Contact c = mtduc.CreateContactSingle();
        Account_Relationship__c rel = new Account_Relationship__c(Parent_Account__c=newAccount.Id, Contact_To__c=c.Id, RecordTypeId=Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId);
        insert rel;
        theOpportunity.Accountid = newAccount.Id;
        update theOpportunity;
        
        test.startTest();
        BigMachines__Quote__c OracleQuote = mtduc.CreateOracleQuoteSingle();
        theOpportunity.Bigmachine_Quote_ID1__c = OracleQuote.Id;
        update theOpportunity;
        Order ord = mtduc.CreateOrderSingle(); 
        ord.OpportunityId = theOpportunity.id;
        update ord;   
        
        OrderItem oi = new OrderItem(asset__c=mtduc.CreateFullfilledAssetSingle().Id,OrderId=ord.id,Quantity=1.0,PricebookEntryId=mtduc.thePricebookEntrie.Id,unitPrice=1000,Inventory_Transaction_Id__c = ord.Id,Fulfillment_Status__c = 'Pending Fulfillment');
        insert oi;
        Asset a = mtduc.CreateFullfilledAssetSingle();
        a.Order_Line_Item__c = oi.Id;
        update a;
        
        Attachment attach=new Attachment();     
        attach.Name='InsertionOrder.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=theOpportunity.id;
        insert attach;
        
        Mortgage_Email_Controller.sendEmailFromAsset(a.Id);
        test.StopTest();
    }
}