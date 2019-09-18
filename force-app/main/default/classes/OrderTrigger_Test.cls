//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: OrderTrigger_Test
// For Apex Trigger: OrderTrigger
// Description: This test class will be validating assets created from order line items for order whose boolean flag
// "Is_Order_Creation_Complete__c" is updated to "true".
//
// 04th June 2015   Hemendra Singh Bhati   Original (Task # T-396116)
//
@isTest(seeAllData=false)
private class OrderTrigger_Test {
  // Private Data Members.
  private static final Map<String, String> theOrderProductAndParentAssetFieldsMapping = new Map<String, String> {
    'Description' => 'Description',
    'Quantity' => 'Quantity',
    'Manual_Discount__c' => 'Manual_Discount__c',
    'Discount_Type__c' => 'Discount_Type__c',
    'Total_Discount__c' => 'Total_Discount__c',
    'Asset__c' => 'Legacy_Siebel_Asset_ID__c',
    'Cancellation_Reason__c' => 'Cancellation_Reason__c',
    'Start_Date__c' => 'Start_Date__c',
    'End_Date__c' => 'End_Date__c',
    'HLC__c' => 'HLC__c',
    'HLC_Override__c' => 'HLC_Override__c',
    'Auto_Renewal__c' => 'Auto_Renewal__c',
    'Renewal_Status__c' => 'Renewal_Status__c',
    'Promotion__c' => 'Promotion__c',
    'Promotion_Amount__c' => 'Promotion_Amount__c',
    'Billing_Period__c' => 'Billing_Period__c',
    'Broker_Plan_Affiliation__c' => 'Broker_Plan_Affiliation__c',
    'Market__c' => 'Market__c',
    'Inventory_Status__c' => 'Inventory_Status__c',
    'Quote_Transaction_ID__c' => 'Quote_Transaction_ID__c',
    'Contract_Term__c' => 'Contract_Term__c',
    'Create_Broker_Tools__c' => 'Create_Broker_Tools__c',
    'Product_Email__c' => 'Product_Email__c',
    'Product_Account__c' => 'Product_Account__c',
    'Lead_Type__c' => 'Lead_Type__c',
    'License_Tier_Range__c' => 'License_Tier_Range__c',
    'License_Tier__c' => 'License_Tier__c',
    'Market_Tier__c' => 'Market_Tier__c',
    'NAR_Membership__c' => 'NAR_Membership__c',
    'Extended_Net_Price__c' => 'Extended_Net_Price__c',
    'Line_Type__c' => 'Line_Type__c',
    'UnitPrice' => 'List_Price__c',
    'Id' => 'Order_Line_Item__c',
    'Top_Connector__c' => 'Top_Connector__c',
    'Product_Type__c' => 'Product_Type__c',
    'Featured_Mortgage__c' => 'Featured_Mortgage__c'
  };
  private static final Map<String, String> theParentAssetAndFulfillToAssetFieldsMapping = new Map<String, String> {
    'Cancellation_Reason__c' => 'Cancellation_Reason__c',
    'Order_Line_Item__c' => 'Order_Line_Item__c',
    'Market__c' => 'Market__c',
    'Description' => 'Description',
    'Name' => 'Name',
    'End_Date__c' => 'End_Date__c',
    'Id' => 'Parent_Asset__c',
    'Legacy_Siebel_Asset_ID__c' => 'Legacy_Siebel_Asset_ID__c',
    'Product2Id' => 'Product2Id',
    'Line_Type__c' => 'Line_Type__c',
    'Broker_Plan_Affiliation__c' => 'Broker_Plan_Affiliation__c',
    'Start_Date__c' => 'Start_Date__c'
  };
  private static final Map<String, String> theFulfillToAssetAndMLSAssetFieldsMapping = new Map<String, String> {
    'Cancellation_Reason__c' => 'Cancellation_Reason__c',
    'Order_Line_Item__c' => 'Order_Line_Item__c',
    'Market__c' => 'Market__c',
    'Description' => 'Description',
    'Name' => 'Name',
    'End_Date__c' => 'End_Date__c',
    'Id' => 'Parent_Asset__c',
    'Legacy_Siebel_Asset_ID__c' => 'Legacy_Siebel_Asset_ID__c',
    'Product2Id' => 'Product2Id',
    'Line_Type__c' => 'Line_Type__c',
    'Broker_Plan_Affiliation__c' => 'Broker_Plan_Affiliation__c',
    'Start_Date__c' => 'Start_Date__c'
  };
  private static final Map<String, Map<String, String>> theAssetModelMapping = new Map<String, Map<String, String>> {
    'Realtor Agent' => new Map<String, String> {
      'Connection(SM) for Co-Brokerage' => 'Model 2A',
      'Showcase(SM) Listing Enhancements' => 'Model 1A',
      'Digital Ad Package' => 'Model 2A',
      'Featured CMA(SM)' => 'Model 2A',
      'Featured Display' => 'Model 2A',
      'Featured Homes(SM)' => 'Model 2A',
      'FiveStreet' => 'Model 2A',
      'ListHub Pro' => 'Model 2A',
      'Market Builder' => 'Model 1A',
      'Top Producer CRM' => 'Model 1A',
      'Top Producer IDX' => 'Model 6A',
      'Market Snapshot' => 'Model 1A',
      'Top Producer Website' => 'Model 1A',
      'Domain Name' => 'Model 2A'
    },
    'Broker' => new Map<String, String> {
      'Connection(SM) for Co-Brokerage' => 'Model 3B',
      'Showcase(SM) Listing Enhancements' => 'Model 1B',
      'Standard Listing Enhancements' => 'Model 1B',
      'Sign Rider' => 'Model 1B',
      'Digital Ad Package' => 'Model 2B',
      'Featured CMA(SM)' => 'Model 2B',
      'Featured Display' => 'Model 2B',
      'Featured Homes(SM)' => 'Model 2B',
      'FiveStreet' => 'Model 4A/B',
      'Top Producer CRM - standard' => 'Model 5B',
      'Top Producer CRM - shared' => 'Model 4A/B',
      'Market Snapshot' => 'Model 5B',
      'Top Producer Website' => 'Model 1B',
      'Domain Name' => 'Model 2B'
    }
  };
  private static final List<String> theProductNames = new List<String> {
    'Connection(SM) for Co-Brokerage',
    'Digital Ad Package',
    'Market Builder',
    'Top Producer IDX'
  };

    private static testMethod void testTriggerFunctionality() {
    // Inserting Custom Setting Data - Order Product And Parent Asset Fields.
     OrderDecompController.stopCreatingAccount = true;    
    List<Order_Product_And_Parent_Asset_Fields__c> theOrderProductAndParentAssetFields = new List<Order_Product_And_Parent_Asset_Fields__c>();
    for(String theName1 : theOrderProductAndParentAssetFieldsMapping.keySet()) {
      theOrderProductAndParentAssetFields.add(new Order_Product_And_Parent_Asset_Fields__c(
        Name = theName1,
        Asset_Field_API_Name__c = theOrderProductAndParentAssetFieldsMapping.get(theName1)
      ));
    }
    insert theOrderProductAndParentAssetFields;

    // Inserting Custom Setting Data - Parent Asset And FulfillTo Asset Fields.
    List<Parent_Asset_And_FulfillTo_Asset_Fields__c> theParentAssetAndFulfillToAssetFields = new List<Parent_Asset_And_FulfillTo_Asset_Fields__c>();
    for(String theName : theParentAssetAndFulfillToAssetFieldsMapping.keySet()) {
      theParentAssetAndFulfillToAssetFields.add(new Parent_Asset_And_FulfillTo_Asset_Fields__c(
        Name = theName,
        FulfillTo_Asset_Field_API_Name__c = theParentAssetAndFulfillToAssetFieldsMapping.get(theName)
      ));
    }
    insert theParentAssetAndFulfillToAssetFields;

    // Inserting Custom Setting Data - FulfillTo Asset And MLS Asset Fields.
    List<FulfillTo_Asset_And_MLS_Asset_Fields__c> theFulfillToAssetAndMLSAssetFields = new List<FulfillTo_Asset_And_MLS_Asset_Fields__c>();
    for(String theName : theFulfillToAssetAndMLSAssetFieldsMapping.keySet()) {
      theFulfillToAssetAndMLSAssetFields.add(new FulfillTo_Asset_And_MLS_Asset_Fields__c(
        Name = theName,
        Participant_Asset_Field_API_Name__c = theFulfillToAssetAndMLSAssetFieldsMapping.get(theName)
      ));
    }
    insert theFulfillToAssetAndMLSAssetFields;

    // Inserting Custom Setting Data - Asset Model Mapping.
    Integer counter = 1;
    Map<String, String> theProductNameAndModelMapping = null;
    List<Asset_Model_Mapping__c> theAssetModelMappingData = new List<Asset_Model_Mapping__c>();
    for(String theAccountType : theAssetModelMapping.keySet()) {
      theProductNameAndModelMapping = theAssetModelMapping.get(theAccountType);
      for(String theProductName : theProductNameAndModelMapping.keySet()) {
        theAssetModelMappingData.add(new Asset_Model_Mapping__c(
          Name = String.valueOf(counter),
          Account_Type__c = theAccountType,
          Product_Name__c = theProductName,
          Model__c = theProductNameAndModelMapping.get(theProductName)
        ));
        counter++;
      }
    }
    insert theAssetModelMappingData;

    // Inserting Custom Setting Data - Error Notification Email Settings.
    Error_Notification_Email_Settings__c theErrorNotificationEmailSettings = new Error_Notification_Email_Settings__c(
      Name = 'Email Addresses',
      Asset_Creation_Error_Emails__c = 'hsingh@appirio.com; manish.soni@appirio.com'
    );
    insert theErrorNotificationEmailSettings;
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    // Inserting Realtor Agent Account.
    Account theRealtorAgentAccount = TestDataFactory.createAccount('The Realtor Agent Account', null, false);
    theRealtorAgentAccount.Type = 'Realtor Agent';
    theRealtorAgentAccount.Primary_Email__c = 'hsingh@appirio.com';

    // Inserting Realtor Office Account.
    Account theRealtorOfficeAccount = TestDataFactory.createAccount('The Realtor Office Account', null, false);
    theRealtorOfficeAccount.Type = 'Realtor Office';
    theRealtorOfficeAccount.Primary_Email__c = 'hsingh@appirio.com';

    // Inserting Test Accounts.
    List<Account> theTestAccounts = new List<Account>();
    theTestAccounts.add(theRealtorAgentAccount);
    theTestAccounts.add(theRealtorOfficeAccount);
    insert theTestAccounts;
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
    parentAccount.Primary_Email__c = 'parentAcc@move.com';
    insert parentAccount;
        
    Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
    childAccount.Primary_Email__c = 'childacc@move.com';
    insert childAccount;  
        
        
   //  Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
  //  childAccount.Primary_Email__c = 'childacc@move.com';
  //  insert childAccount; 
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        
     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User uId =[select Id from User where IsActive=true Limit 1];
           User usr =[select Id,Username,LastName,ProfileId from User where Id =: uId.Id];          
           usr.LastName='Test';           
           update usr;
        
     List<AccountTeamMember> accTeamMember = new List<AccountTeamMember>();
     for(Account theTestAccount : theTestAccounts) {
      accTeamMember.add(new AccountTeamMember(
     //   EffectiveDate = Date.today(),
     //   Status = 'Created',
        AccountId = theTestAccount.Id,
        UserId = usr.id,
         TeamMemberRole = 'test'
     //   Pricebook2Id = theStandardPriceBookId,
        
     //   Is_OLI_Creation_Complete__c = false
      ));
    }
    insert accTeamMember;
     
    // account relationship data    
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        
  //  List<Account_Relationship__c> accountRelation = new List<Account_Relationship__c>();
  
    //Create Account Relationship Records for Accounts
    Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (parentAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Is_Parent_Primary__c = true;
    toBeInserted.add(accountRelation); 
    
    Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
    parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
    insert parentAcc1;
    
    accountRelation = TestDataFactory.createAccountRelationship(
                                                                            parentAcc1.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    toBeInserted.add(accountRelation);    

    // Inserting Products.
    List<Product2> theTestProducts = new List<Product2>();
    for(String theProductName : theProductNames) {
      theTestProducts.add(new Product2(
        Name = theProductName,
        Family = 'Realtor',
        S_No__c = 2,
        ProductCode='Advantage'
      ));
    }
    insert theTestProducts;

    // Extracting Standard Price Book ID.
    Id theStandardPriceBookId = Test.getStandardPricebookId();

    // Inserting Price Book Entries For The Standard Price Book.
    List<PricebookEntry> thePricebookEntries = new List<PricebookEntry>();
    for(Product2 theTestProduct : theTestProducts) {
      thePricebookEntries.add(new PricebookEntry(
        Pricebook2Id = theStandardPriceBookId,
        Product2Id = theTestProduct.Id,
        UnitPrice = 1000,
        IsActive = true
      ));
    }
    insert thePricebookEntries;

    // Inserting Test Orders.
    List<Order> theTestOrders = new List<Order>();
    for(Account theTestAccount : theTestAccounts) {
      theTestOrders.add(new Order(
        EffectiveDate = Date.today(),
        Status = 'Created',
        AccountId = theTestAccount.Id,
        Pricebook2Id = theStandardPriceBookId,
        
        Is_OLI_Creation_Complete__c = false
      ));
    }
    insert theTestOrders;

        
    // Inserting Order Line Items.
    counter = 0;
    List<OrderItem> theOrderItems = new List<OrderItem>();
    for(Order theTestOrder : theTestOrders) {
      for(PricebookEntry thePricebookEntry : thePricebookEntries) {
        theOrderItems.add(new OrderItem(
          Quantity = 1.00,
          PricebookEntryId = thePricebookEntry.Id,
          OrderId = theTestOrder.Id,
          UnitPrice = 100.00,
          Start_Date__c = Date.today(),
          Fulfill_To_Account__c = theTestAccounts.get(counter).Id,          
          Inactivate_Date__c = Date.today(),
            Inventory_Transaction_Id__c = 'test'
        ));
      }
     counter++;
    }
    insert theOrderItems; 

    Test.startTest();
    
    // Updating Test Orders.
    for(Order theTestOrder : theTestOrders) {
      theTestOrder.Is_OLI_Creation_Complete__c = true;
      
    }
    update theTestOrders;
        
         map<id,order> inputmap = new map<id,order>();
        for(Order a :theTestOrders){
            inputmap.put(a.id,a);
            
        }

       orderTriggerHandlerManager orderTriggerHandrMan = new orderTriggerHandlerManager();
        orderTriggerHandrMan.GenerateJsonOrdersStrings(inputmap);
    Test.stopTest();
/*
    system.assert(
      [SELECT Id FROM Asset].size() > 0,
      'Error: The order trigger failed to insert new assets as per the defined model mapping.'
    );*/
    }
     private static testMethod void testTriggerOrderFunctionality() {
    // Inserting Custom Setting Data - Order Product And Parent Asset Fields.
    List<Order_Product_And_Parent_Asset_Fields__c> theOrderProductAndParentAssetFields = new List<Order_Product_And_Parent_Asset_Fields__c>();
    OrderDecompController.stopCreatingAccount = true; 
    for(String theName1 : theOrderProductAndParentAssetFieldsMapping.keySet()) {
      theOrderProductAndParentAssetFields.add(new Order_Product_And_Parent_Asset_Fields__c(
        Name = theName1,
        Asset_Field_API_Name__c = theOrderProductAndParentAssetFieldsMapping.get(theName1)
      ));
    }
    insert theOrderProductAndParentAssetFields;

    // Inserting Custom Setting Data - Parent Asset And FulfillTo Asset Fields.
    List<Parent_Asset_And_FulfillTo_Asset_Fields__c> theParentAssetAndFulfillToAssetFields = new List<Parent_Asset_And_FulfillTo_Asset_Fields__c>();
    for(String theName : theParentAssetAndFulfillToAssetFieldsMapping.keySet()) {
      theParentAssetAndFulfillToAssetFields.add(new Parent_Asset_And_FulfillTo_Asset_Fields__c(
        Name = theName,
        FulfillTo_Asset_Field_API_Name__c = theParentAssetAndFulfillToAssetFieldsMapping.get(theName)
      ));
    }
    insert theParentAssetAndFulfillToAssetFields;

    // Inserting Custom Setting Data - FulfillTo Asset And MLS Asset Fields.
    List<FulfillTo_Asset_And_MLS_Asset_Fields__c> theFulfillToAssetAndMLSAssetFields = new List<FulfillTo_Asset_And_MLS_Asset_Fields__c>();
    for(String theName : theFulfillToAssetAndMLSAssetFieldsMapping.keySet()) {
      theFulfillToAssetAndMLSAssetFields.add(new FulfillTo_Asset_And_MLS_Asset_Fields__c(
        Name = theName,
        Participant_Asset_Field_API_Name__c = theFulfillToAssetAndMLSAssetFieldsMapping.get(theName)
      ));
    }
    insert theFulfillToAssetAndMLSAssetFields;

    // Inserting Custom Setting Data - Asset Model Mapping.
    Integer counter = 1;
    Map<String, String> theProductNameAndModelMapping = null;
    List<Asset_Model_Mapping__c> theAssetModelMappingData = new List<Asset_Model_Mapping__c>();
    for(String theAccountType : theAssetModelMapping.keySet()) {
      theProductNameAndModelMapping = theAssetModelMapping.get(theAccountType);
      for(String theProductName : theProductNameAndModelMapping.keySet()) {
        theAssetModelMappingData.add(new Asset_Model_Mapping__c(
          Name = String.valueOf(counter),
          Account_Type__c = theAccountType,
          Product_Name__c = theProductName,
          Model__c = theProductNameAndModelMapping.get(theProductName)
        ));
        counter++;
      }
    }
    insert theAssetModelMappingData;
  // recordtype r = [select id from recordtype where developername='Account_Relationship' and sobjectType='Account'];
    // Inserting Custom Setting Data - Error Notification Email Settings.
    Error_Notification_Email_Settings__c theErrorNotificationEmailSettings = new Error_Notification_Email_Settings__c(
      Name = 'Email Addresses',
      Asset_Creation_Error_Emails__c = 'hsingh@appirio.com; manish.soni@appirio.com'
    );
    insert theErrorNotificationEmailSettings;
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    // Inserting Realtor Agent Account.
    Account theRealtorAgentAccount = TestDataFactory.createAccount('The Realtor Agent Account', null, false);
    theRealtorAgentAccount.Type = 'Realtor Agent';
     theRealtorAgentAccount.Account_Sub_Type__c = 'Prospect'; 
       //  theRealtorAgentAccount.RecordTypeid = r.id;
    theRealtorAgentAccount.Primary_Email__c = 'hsingh@appirio.com';

    // Inserting Realtor Office Account.
    Account theRealtorOfficeAccount = TestDataFactory.createAccount('The Realtor Office Account', null, false);
    theRealtorOfficeAccount.Type = 'Realtor Office';
         theRealtorOfficeAccount.Account_Sub_Type__c = 'Former Customer'; 
        // theRealtorOfficeAccount.RecordTypeid = r.id;
    theRealtorOfficeAccount.Primary_Email__c = 'hsingh@appirio.com';

    // Inserting Test Accounts.
    List<Account> theTestAccounts = new List<Account>();
    theTestAccounts.add(theRealtorAgentAccount);
    theTestAccounts.add(theRealtorOfficeAccount);
    insert theTestAccounts;
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
    parentAccount.Primary_Email__c = 'parentAcc@move.com';
    insert parentAccount;
        
    Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
    childAccount.Primary_Email__c = 'childacc@move.com';
        childAccount.Account_Sub_Type__c = 'Prospect';
         childAccount.Type = 'Realtor Office';
    insert childAccount;  
        
        
   //  Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
  //  childAccount.Primary_Email__c = 'childacc@move.com';
  //  insert childAccount; 
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        
     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User uId =[select Id from User where IsActive=true Limit 1];
           User usr =[select Id,Username,LastName,ProfileId from User where Id =: uId.Id];          
           usr.LastName='Test';           
           update usr;
        
     List<AccountTeamMember> accTeamMember = new List<AccountTeamMember>();
     for(Account theTestAccount : theTestAccounts) {
      accTeamMember.add(new AccountTeamMember(
     //   EffectiveDate = Date.today(),
     //   Status = 'Created',
        AccountId = theTestAccount.Id,
        UserId = usr.id,
         TeamMemberRole = 'test'
     //   Pricebook2Id = theStandardPriceBookId,
        
     //   Is_OLI_Creation_Complete__c = false
      ));
    }
    insert accTeamMember;
     
    // account relationship data    
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        
  //  List<Account_Relationship__c> accountRelation = new List<Account_Relationship__c>();
  
    //Create Account Relationship Records for Accounts
    Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (parentAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Is_Parent_Primary__c = true;
    toBeInserted.add(accountRelation); 
    
    Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
    parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
    insert parentAcc1;
    
    accountRelation = TestDataFactory.createAccountRelationship(
                                                                            parentAcc1.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    toBeInserted.add(accountRelation);    

    // Inserting Products.
    List<Product2> theTestProducts = new List<Product2>();
    for(String theProductName : theProductNames) {
      theTestProducts.add(new Product2(
        Name = theProductName,
        Family = 'Realtor',
        S_No__c = 2,
        ProductCode = 'Advantage'
      ));
    }
    insert theTestProducts;

    // Extracting Standard Price Book ID.
    Id theStandardPriceBookId = Test.getStandardPricebookId();

    // Inserting Price Book Entries For The Standard Price Book.
    List<PricebookEntry> thePricebookEntries = new List<PricebookEntry>();
    for(Product2 theTestProduct : theTestProducts) {
      thePricebookEntries.add(new PricebookEntry(
        Pricebook2Id = theStandardPriceBookId,
        Product2Id = theTestProduct.Id,
        UnitPrice = 1000,
        IsActive = true
      ));
    }
    insert thePricebookEntries;

    // Inserting Test Orders.
    List<Order> theTestOrders = new List<Order>();
    for(Account theTestAccount : theTestAccounts) {
      theTestOrders.add(new Order(
        EffectiveDate = Date.today(),
        Status = 'Created',
        AccountId = theTestAccount.Id,
        Pricebook2Id = theStandardPriceBookId,
        
        Is_OLI_Creation_Complete__c = false
      ));
    }
    insert theTestOrders;

        
    // Inserting Order Line Items.
    counter = 0;
    List<OrderItem> theOrderItems = new List<OrderItem>();
    for(Order theTestOrder : theTestOrders) {
      for(PricebookEntry thePricebookEntry : thePricebookEntries) {
        theOrderItems.add(new OrderItem(
          Quantity = 1.00,
          PricebookEntryId = thePricebookEntry.Id,
          OrderId = theTestOrder.Id,
          UnitPrice = 1000,
          Start_Date__c = Date.today(),
          Fulfill_To_Account__c = theTestAccounts.get(counter).Id,          
          Inactivate_Date__c = Date.today()
            
        ));
      }
     counter++;
    }
    insert theOrderItems; 

    
    Account account = Z_LegacyTestFactory.makeAccount(); 
    Order order = new Order();
    order.AccountId = account.Id;
    order.EffectiveDate = Date.Today();
    order.Status = 'Created';
    order.Fulfillment_Status__c = 'Pending Fulfillment';
    order.Pricebook2Id = Test.getStandardPricebookId();
    insert order;
    
    BigMachines__Quote__c bmQuote = new BigMachines__Quote__c();
    insert bmQuote;
    BigMachines__Quote_Product__c quoteProduct = new BigMachines__Quote_Product__c();
    quoteProduct.BigMachines__Sales_Price__c = 5;
    quoteProduct.BigMachines__Quantity__c = 5;
    quoteProduct.BigMachines__Quote__c = bmQuote.Id;
    quoteProduct.Contractedimpressions__c = 500;
    quoteProduct.PricePerImpressionSold__c = 500;
    insert quoteProduct;
    
    Product2 p2 = new Product2();
    p2.Name='test prod';
    p2.s_no__c = 2;
    p2.productcode = 'Advantage';
    insert p2;
  
    PricebookEntry pe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p2.Id, UnitPrice = 1);
    
    insert pe;
           
    OrderItem oi = new OrderItem();
    oi.OrderId = order.Id;
    oi.Quantity = 1;
    oi.Extended_Net_Price__c = 10.00;
    oi.Contract_Term__c = '12';
    oi.Part_Number__c = 'testpartnumber';
    oi.Subscription_Term__c = '1';
    oi.Override_Term__c = 1;
    oi.Line_Type__c = 'Add';
    oi.Billing_Period__c = 'Month';
    oi.Cancellation_Date__c = Date.today();
    oi.Buyout_Amount__c = 100.00;
    oi.Credit_Amount__c = 100.00;
    oi.UnitPrice=10.00;
    oi.Quantity = 1;
    oi.PricebookEntryId = pe.Id;        
    oi.Term_Start_Date__c = Date.today();
    oi.Start_Date__c = Date.today();
    oi.Commerce_Group__c = 'Broker Marketing Solution';
    oi.Quote_Product__r = quoteProduct;
    
    
    insert oi;
   
    order.fulfillment_status__c = 'Fulfilled';
    
        
    Test.startTest();
    
    // Updating Test Orders.
    for(Order theTestOrder : theTestOrders) {
      theTestOrder.Is_OLI_Creation_Complete__c = true;
      
    }
    update theTestOrders;
    update order;
    Test.stopTest();
    }
    
    
    
    
}