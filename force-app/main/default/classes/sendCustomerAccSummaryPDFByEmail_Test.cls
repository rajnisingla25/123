@isTest
public class sendCustomerAccSummaryPDFByEmail_Test {
    public static testMethod void sendCustAccSumByEmail(){
        //Inserting Customsettings 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c cu = new Collection_Users__c(Name= 'batchintegration user');
        insert cu;
        Suppress_in_Customer_Statements_Settings__c scs = new Suppress_in_Customer_Statements_Settings__c(Name='Customer',Promo_Codes__c='FREERS;FREEC');
        insert scs;
        OrderDecompController.stopCreatingAccount = true;
        //Inserting account
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'ssk112233@gmail.com';
        theTestAccount.Email_Address__c = 'ssk112233@gmail.com';
        theTestAccount.ShippingState  = 'CA';
        theTestAccount.ShippingCountry  = 'USA';
        insert theTestAccount;
        
        //Inserting contact
        Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theTestAccount.Id, true, false);
        theContact.Email='ssk112233@gmail.com';
        insert theContact;
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        // Insert Relationship for Contact Relationhsip
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
            theTestAccount.Id, null, theContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        accountRelation.Relationship_Type__c = 'Contact';
        insert accountRelation; 
        
        // Inserting Assets
         List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Asset1',Asset_Type__c='Parent', status = 'Active',price =250, AccountId = ThetestAccount.ID, Order_type__c='New');
        Asset asset2 = new Asset(Name = 'Asset2',Asset_Type__c='Parent', status = 'Active',price =250, AccountId = ThetestAccount.ID, Order_type__c='Renewal');
        Asset asset3 = new Asset(Name = 'Asset3',Asset_Type__c='Parent', status = 'Active',price =250, AccountId = ThetestAccount.ID, Order_type__c='New');
        Asset asset4 = new Asset(Name = 'Asset4',Asset_Type__c='Parent', status = 'Active',price =250, AccountId = ThetestAccount.ID, Order_type__c='New');
        
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        insert assets;
        
        
        sendCustomerAccSummaryPDFByEmail.verifyIfEmailAlreadySent( theTestAccount.Id);
        sendCustomerAccSummaryPDFByEmail.emailAccountSummaryPdf( theTestAccount.Id);
        
    } 
    
    public static testMethod void CustAccSumPDFPage(){
        
        //Inserting Customsettings 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Suppress_in_Customer_Statements_Settings__c scs = new Suppress_in_Customer_Statements_Settings__c(Name='Customer',Promo_Codes__c='FREERS;FREEC');
        insert scs;
         OrderDecompController.stopCreatingAccount = true;
        //Inserting account
        Account testAccount = TestDataFactory.createAccount('The Test Account', null, false);
        testAccount.Primary_Email__c = 'ssk112233@gmail.com';
        testAccount.Email_Address__c = 'ssk112233@gmail.com';
        testAccount.ShippingState  = 'CA';
        testAccount.ShippingCountry  = 'USA';
        insert testAccount;
        
        Opportunity testopp = new Opportunity(      Name = 'The Opportunity',
                                              StageName = 'Prospecting',
                                              CloseDate = system.today(),
                                              AccountId = testAccount.Id,
                                              Opportunity_Short_Description__c = 'sDesc',
                                              Amount = 0.00);
        
        Account_Listing__c alist = new Account_Listing__c();
        alist.City__c = 'Fremont';
        alist.Account_Name__c = testAccount.Id;
        insert alist;
        
        Product2 testProduct = new Product2();
        testProduct.name = 'Test Product';
        testProduct.productCode = 'COBROKE';
        Insert testProduct;
       
        Product2 testProduct1 = new Product2();
        testProduct1.name = 'TOPIDX Product';
        testProduct1.productCode = 'TOPIDX';
        Insert testProduct1;
        
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = Test.getStandardPricebookId();
        thePricebookEntrie1.Product2Id = testProduct1.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Account__c  = testAccount.id;        
        quote.BigMachines__Status__c  = 'Ordered';
        quote.BigMachines_Quote_Type__c  = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;               
        
        
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
        theTestOrder.Type = 'New';    
        theTestOrder.Is_BMS__c = true;
        theTestOrder.AccountId = testAccount.Id;
        theTestOrder.opportunityId = testopp.Id;
        theTestOrder.Pricebook2Id = Test.getStandardPricebookId();
        theTestOrder.Fulfillment_Status__c ='Pending Fulfillment';   
        theTestOrder.Oracle_Quote__c   =   quote.Id;  
        theTestOrder.tigerLeadProductExists__c =false ;
        insert theTestOrder;        
        // Inserting Order Line Items.        
        OrderItem theOrderItem = new OrderItem();           
        theOrderItem.Quantity = 1.00;         
        theOrderItem.PricebookEntryId = thePricebookEntrie1.id;
        theOrderItem.OrderId = theTestOrder.Id;
        theOrderItem.UnitPrice = 1000;
        theOrderItem.Start_Date__c = Date.today();
        theOrderItem.Inactivate_Date__c = Date.today();             
        theOrderItem.Line_Type__c  = 'Add';
        theOrderItem.Fulfillment_Status__c ='Pending Fulfillment';          
        insert theOrderItem;  
        
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Order_Line_Item__c = theOrderItem.Id, Product2Id = testProduct.id, Extended_Net_Price__c = 100, Start_date__c = date.today(), End_date__c = date.today(), Name = 'Asset1', Commerce_Group__c = 'Broker Marketing Solution',Asset_Type__c='Parent', status = 'Active',price =250,Fulfillment_Status__c = 'Fulfilled', AccountId = testAccount.ID, Order_type__c='New');
        Asset asset2 = new Asset(Order_Line_Item__c = theOrderItem.Id,  Product2Id = testProduct1.id, Extended_Net_Price__c = 100,Name = 'Asset2', Start_date__c = date.today(), End_date__c = date.today() ,Asset_Type__c='Parent', status = 'Active',price =250,Fulfillment_Status__c = 'Fulfilled', AccountId = testAccount.ID, Order_type__c='Renewal');
        assets.add(asset1);
        assets.add(asset2);
        insert assets;
        
        PageReference pageRef = Page.customerAccountSummary;
        pageRef.getParameters().put('id', String.valueOf(testAccount.ID));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        customerAccountSummary testaccCTRL = new customerAccountSummary(sc);
    }
}