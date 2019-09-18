@isTest(seeAllData = false)
public Class BLAQuoteFocusFireView_Controller_Test {
    public static testMethod Void test1 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.Order_Trigger__c= UserInfo.getUserName();
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= UserInfo.getUserId());
        insert coll;
        
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
        Opcity_Settings__c rec = new Opcity_Settings__c(Name='1', Category__c='ContractType',Type__c='1',value__c='3');
        insert rec;
        Opcity_Settings__c rec1 = new Opcity_Settings__c(Name='2', Category__c='Contract_Monthly_Plan',Type__c='1',value__c='3');
        insert rec1;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Account newAccount = mtduc.CreateBrokerAccountSingle();
        Product2 newProduct = mtduc.CreateProductSingle();
        newProduct.EssentialsRequired__c = True;
        newProduct.ProductCode = 'OPCITYBLA';
        update newProduct;
        mtduc.CreatePricebookEntrySingle();       
        Opportunity theOpportunity = mtduc.CreateOppurtunitySingle();
        mtduc.CreateOpportunityProductSingle();
        
        BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = newAccount.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        OracleQuote.ownerId = UserInfo.getUserId();
        insert OracleQuote;
        
        BigMachines__Quote_Product__c QuoteProduct = new BigMachines__Quote_Product__c();
        QuoteProduct.BigMachines__Quote__c = OracleQuote.id;
        QuoteProduct.BigMachines__Sales_Price__c = 10.00;
        QuoteProduct.BigMachines__Quantity__c = 10;
        QuoteProduct.Need_Manual_Renew__c = false;
        QuoteProduct.BigMachines__Description__c = 'test';
        QuoteProduct.BigMachines__Product__c = newProduct.id;
        QuoteProduct.Line_Type__c = 'Add';
        QuoteProduct.Market_Tier__c = '100';
        QuoteProduct.Commerce_Group__c = 'test';
        QuoteProduct.Product_Account__c = newAccount.Id;
        QuoteProduct.Launch_Date__c = System.today();
        insert QuoteProduct;
        
        PageReference pageRef = Page.OpcityQuote;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('quoteId',OracleQuote.Id);
        ApexPages.currentPage().getParameters().put('qpId','0');
        
        test.StartTest();
        BLAQuoteFocusFireView_Controller cont = new BLAQuoteFocusFireView_Controller();
        cont.updateQuoteProduct();
        cont.finish();
        test.StopTest();
    }
}