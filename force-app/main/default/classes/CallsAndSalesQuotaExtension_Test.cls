//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: CallsAndSalesQuotaExtension_Test
// For Controller Class: CallsAndSalesQuotaExtension
// For Apex Page: CallsAndSalesQuota
// Description: Here, we are displaying apex gauge charts that will help a sales manager to view trending information on sales and calls. The
// charts will display based on daily call (task) done by rep and quota define for the daily call. Also based on daily total amout for the orders
// that reps owns with the quota define with the target amount.
//
// 18th May 2015    Hemendra Singh Bhati    Original (Task # T-396116)
//
@isTest
private class CallsAndSalesQuotaExtension_Test {
  /**********************
  private static final Integer COUNTER = 5;
  private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'Move Agent Sales Rep';
  private static Map<Integer, String> allMonths = new Map<Integer, String> {
    1 => 'January',
    2 => 'February',
    3 => 'March',
    4 => 'April',
    5 => 'May',
    6 => 'June',
    7 => 'July',
    8 => 'August',
    9 => 'September',
    10 => 'October',
    11 => 'November',
    12 => 'December'
  };

  private static testMethod void testExtensionFunctionality() {
    // Extracting System Administrator Profile.
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
    
    system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');

    // Inserting Test User.
   
   User theTestUser = new User(alias = 'standt', email='standardusertest346@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing796', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = profile[0].Id,timezonesidkey='America/New_York', 
                            username='standarduserTes346@test.com',Payout_Rate_Month_1__c=1,Payout_Rate_Month_2__c=2,Payout_Rate_Month_3__c=3,Team__c='Regional Directors Team');
    system.runas(theTestUser){
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theAccount.Type = 'Broker';
    theAccount.Customer_Care_Calls__c = 'Yes';
    theAccount.Sales_Calls__c = 'Yes';
    theAccount.Marketing_Emails__c = 'Yes';
    theAccount.Agent_SLE__c = 'Yes';
    theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';

        DisabledTrigger__c Dtrg             = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;


    insert theAccount;

    // Setting The Current Page.
    PageReference thePage = Page.CallsAndSalesQuota;
    Test.setCurrentPage(thePage);

    // System Administrator Backdoor.
        ApexPages.currentPage().getParameters().put('condition', '1');

    ApexPages.StandardController theStandardController = new ApexPages.standardController(theAccount);
    CallsAndSalesQuotaExtension theController = null;

    Test.startTest();

    // Test Case - 1
    system.runAs(theTestUser) {
      theController = new CallsAndSalesQuotaExtension(theStandardController);
      system.assert(
        theController.dailyCallsData.size() == 0 &&
        theController.dailySalesData.size() == 0 &&
        theController.monthlySalesData.size() == 0,
        'Error: No quota record found for the logged-in user.'
      );
    }
    
    Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
    inv.Name = 'TestInv';
    inv.Zuora__Status__c = 'Past Due';
    inv.Zuora__Account__c = theAccount.Id;
    inv.Zuora__DueDate__c = System.today().adddays(1);
       Insert Inv;

    Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
        
         // Inserting Test Quota.
    Quota__c theTestQuota = new Quota__c(
      Activity_Type__c = 'Other',
      Period_Month__c = allMonths.get(Date.today().month()),
      User__c = theTestUser.id,
      Sales_Service_Rep__c = UserInfo.getUserId(),
      Status__c = 'Active',
      Target_Activity_Daily__c = 10,
      Target_Activity_Monthly__c = 300,
      Target_Amount_Daily__c = 1000,
      Target_Amount_Monthly__c = 30000,
      Type__c = 'Sales'
    );
    insert theTestQuota;
    
    // Inserting Test Tasks.
    Id theRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
    List<Task> theTestTasks = new List<Task>();
    for(Integer index = 0;index < COUNTER;index++) {
      theTestTasks.add(new Task(
        WhatId = theAccount.Id,
        Subject = 'Call',
        ActivityDate = Date.today(),
        Status = 'Completed',
        Priority = 'Normal',
        Type = 'Call',
        RecordTypeId = theRecordTypeId
      ));
    }
    insert theTestTasks;

    // Inserting Test Product.
    Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      S_No__c = 2,
      Family = 'Hardware'
    );
    insert theTestProduct;

    // Extracting Standard Pricebook Id.
   // PriceBook2 theStandardPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true ];
   
    Id standardPriceBookId = Test.getStandardPricebookId();

    // Extracting Standard Pricebook Entry.
  //  PricebookEntry thePricebookEntry = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry
  //                                      WHERE Pricebook2Id = :standardPriceBookId AND isActive = true LIMIT 1];
                                        
    PricebookEntry thePricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, Product2Id = theTestProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert thePricebookEntry;                                    

    // Inserting Test Orders.
    List<Order> theTestOrders = new List<Order>();
    for(Integer index = 0;index < COUNTER;index++) {
      theTestOrders.add(new Order(
        EffectiveDate = Date.today(),
        Status = 'Created',
        AccountId = theAccount.Id,
        Pricebook2Id = standardPriceBookId
      ));
    }
    insert theTestOrders;

    // Inserting Test Order Item.
    List<OrderItem> theTestOrderItems = new List<OrderItem>();
    for(Order theTestOrder : theTestOrders) {
      theTestOrderItems.add(new OrderItem(
        Quantity = 1.00,
        PricebookEntryId = thePricebookEntry.Id,
        OrderId = theTestOrder.Id,
        UnitPrice = 100.00
      ));
    }
    insert theTestOrderItems;

    // Test Case - 2
    theController = new CallsAndSalesQuotaExtension(theStandardController);
    system.assert(
      theController.dailyCallsData.size() != 0 &&
      theController.dailySalesData.size() != 0,
      'Error: The extension class failed to build gauge charts data related to daily calls and daily sales.'
    );

    // Test Case - 3
        ApexPages.currentPage().getParameters().put('condition', '2');
    theController = new CallsAndSalesQuotaExtension(theStandardController);
    system.assert(
      theController.monthlySalesData.size() != 0,
      'Error: The extension class failed to build gauge charts data related to monthly sales.'
    );

    Test.stopTest();
   } 
  }
  private static testMethod void testExtensionFunctionality1() {
    // Extracting System Administrator Profile.
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
    
    system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');

    // Inserting Test User.
   
   User theTestUser = new User(alias = 'standt', email='standarduser96@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing96', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = profile[0].Id,timezonesidkey='America/New_York', 
                            username='standarduser296@test.com',Payout_Rate_Month_1__c=1,Payout_Rate_Month_2__c=2,Payout_Rate_Month_3__c=3,Team__c='Regional Directors Team');
                            
       User u=[Select Id,Name from User where Id=:UserInfo.getUserId() limit 1];                    
    system.runas(u){
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'hsingh@appirio.com';
    theAccount.Type = 'Broker';
    //theAccount.Customer_Care_Calls__c = 'Yes';
   // theAccount.Sales_Calls__c = 'Yes';
   // theAccount.Marketing_Emails__c = 'Yes';
   // theAccount.Agent_SLE__c = 'Yes';
   // theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';
   // theAccount.Customer_Care_Calls__c = 'yes';
    
    DisabledTrigger__c Dtrg             = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
    insert Dtrg;
    
    insert theAccount;

    // Setting The Current Page.
    PageReference thePage = Page.CallsAndSalesQuota;
    Test.setCurrentPage(thePage);

    // System Administrator Backdoor.
        ApexPages.currentPage().getParameters().put('condition', '1');

    ApexPages.StandardController theStandardController = new ApexPages.standardController(theAccount);
    CallsAndSalesQuotaExtension theController = null;

    Test.startTest();

    // Test Case - 1
    system.runAs(theTestUser) {
      theController = new CallsAndSalesQuotaExtension(theStandardController);
      system.assert(
        theController.dailyCallsData.size() == 0 &&
        theController.dailySalesData.size() == 0 &&
        theController.monthlySalesData.size() == 0,
        'Error: No quota record found for the logged-in user.'
      );
    }
    
    Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
    inv.Name = 'TestInv';
    inv.Zuora__Status__c = 'Past Due';
    inv.Zuora__Account__c = theAccount.Id;
    inv.Zuora__DueDate__c = System.today().adddays(1);
       Insert Inv;

    Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
        
         // Inserting Test Quota.
    Quota__c theTestQuota = new Quota__c(
      Activity_Type__c = 'Other',
       Period_Month__c = allMonths.get(Date.today().month()),
    // Period_Month__c = 'January',
      User__c = theTestUser.id,
      Sales_Service_Rep__c = UserInfo.getUserId(),
      Status__c = 'Active',
      Target_Activity_Daily__c = 10,
      Target_Activity_Monthly__c = 300,
      Target_Amount_Daily__c = 1000,
      Target_Amount_Monthly__c = 30000,
      Type__c = 'Sales',
      //Period_Month__c = String.valueOf(System.Today().month()),
      Period_Year__c = Decimal.valueOf(System.Today().year())
    );
    insert theTestQuota;
     System.debug('******Quota'+theTestQuota);
    // Inserting Test Tasks.
    Id theRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
    List<Task> theTestTasks = new List<Task>();
    for(Integer index = 0;index < COUNTER;index++) {
      theTestTasks.add(new Task(
        WhatId = theAccount.Id,
        Subject = 'Call',
        ActivityDate = Date.today(),
        Status = 'Completed',
        Priority = 'Normal',
        Type = 'Call',
        RecordTypeId = theRecordTypeId
      ));
    }
    insert theTestTasks;

    // Inserting Test Product.
    Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      S_No__c = 2,
      Family = 'Hardware'
    );
    insert theTestProduct;

    // Extracting Standard Pricebook Id.
    //PriceBook2 theStandardPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
    Id standardPriceBookId = Test.getStandardPricebookId();

    // Extracting Standard Pricebook Entry.
    //PricebookEntry thePricebookEntry = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry
    //                                    WHERE Pricebook2Id = :standardPriceBookId AND isActive = true LIMIT 1];

    PricebookEntry thePricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, Product2Id = theTestProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert thePricebookEntry;                                    
    

    // Inserting Test Orders.
    List<Order> theTestOrders = new List<Order>();
    for(Integer index = 0;index < COUNTER;index++) {
      theTestOrders.add(new Order(
        EffectiveDate = Date.today(),
        Status = 'Created',
        AccountId = theAccount.Id,
        Pricebook2Id = standardPriceBookId
      ));
    }
    insert theTestOrders;

    // Inserting Test Order Item.
    List<OrderItem> theTestOrderItems = new List<OrderItem>();
    for(Order theTestOrder : theTestOrders) {
      theTestOrderItems.add(new OrderItem(
        Quantity = 1.00,
        PricebookEntryId = thePricebookEntry.Id,
        OrderId = theTestOrder.Id,
        UnitPrice = 100.00
      ));
    }
    insert theTestOrderItems;

    // Test Case - 2
    theController = new CallsAndSalesQuotaExtension(theStandardController);
   system.assert(
      theController.dailyCallsData.size() != 0 &&
      theController.dailySalesData.size() != 0,
      'Error: The extension class failed to build gauge charts data related to daily calls and daily sales.'
    );

    // Test Case - 3
        ApexPages.currentPage().getParameters().put('condition', '2');
    theController = new CallsAndSalesQuotaExtension(theStandardController);
    system.assert(
      theController.monthlySalesData.size() != 0,
      'Error: The extension class failed to build gauge charts data related to monthly sales.'
    );

    Test.stopTest();
   } 
  }
  ***********************/
}