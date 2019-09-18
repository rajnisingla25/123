@isTest (seeAllData = false)
public with sharing class AccountBillingInsight_Test {

    
    
    @testSetup
    static void dataSetup() {
            //Inserting Customsetting for Account 
    
      DisabledTrigger__c Dtrg = new DisabledTrigger__c();
      Dtrg.Name = 'Disabled';
      Dtrg.TaskTrigger__c = UserInfo.getUserName();
      Dtrg.AssetTrigger__c = UserInfo.getUserName();
      insert Dtrg;
      
      Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
      insert arc;     
    
        //Inserting Test Account       
      Account testAccount = TestDataFactory.createAccount('Test Account BI',null,false);
      testAccount.Party_ID__c           = '123456';
      testAccount.Primary_Email__c      = 'testAccount@move.com';
      testAccount.Account_Sub_Type__c   ='Prospect';
      testAccount.Type = 'Broker';
      insert testAccount; 
      
      Zuora__CustomerAccount__c testBillingAccount = new Zuora__CustomerAccount__c();
      testBillingAccount.Name                           = 'Test Billing Account';
      testBillingAccount.Zuora__BillToName__c           = 'Test Bill To';
      testBillingAccount.Zuora__BillCycleDay__c         = '22nd of the month';
      testBillingAccount.Zuora__Batch__c                = 'Batch1';
      testBillingAccount.Zuora__Zuora_Id__c             = 'z1234567890';
      testBillingAccount.Zuora__Status__c               = 'Active';
      testBillingAccount.Zuora__Account__c              = testAccount.Id;
      insert testBillingAccount; 
      
      
      Zuora__ZInvoice__c testzInvoice = new Zuora__ZInvoice__c();
      testzInvoice.Name                 = 'Test Invoice';
      testzInvoice.Zuora__Account__c    = testAccount.id;
      insert testzInvoice;
      
      Asset testAsset = new Asset(Name = 'Test Asset',External_ID__c = '12987',Billing_Period__c ='Monthly', status = 'Active',price =250, AccountId = testAccount.id);
      insert testAsset;
      
      list<Invoice_Item__c> invoiceItemList = new list<Invoice_Item__c>();
      integer recordCount = 10;
      
      for( integer counter = 0 ;counter <= recordCount;counter++){
            invoiceItemList.add( new Invoice_Item__c(
                                    Name = 'Test INVItem '+counter,
                                    Charge_Date__c = date.Today()-3,
                                    Charge_Amount__c = 123.22,
                                    Service_End_Date__c = date.Today() + 5,
                                    Service_Start_Date__c = date.Today()-5,
                                    Tax_Amount__c = 123.22,
                                    Unit_Price__c = 123.22,
                                    Asset__c = testAsset.Id,
                                    Invoice__c = testzInvoice.Id)); 
      }
      insert invoiceItemList;
      
      
      Zuora__Subscription__c zSubs = new Zuora__Subscription__c();
      zSubs.Zuora__Zuora_Id__c = 'z1234567890';
      zSubs.Asset__c = testAsset.Id;
      insert zSubs;
    }
    
    static testMethod void testAccountBillingInsightConstructor(){
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];    
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        
      Test.stopTest();
       
    }
    
    static testMethod void testReportWithoutBillingAcc(){
        
      Zuora__CustomerAccount__c zCustomerAccount = [select Zuora__Status__c from Zuora__CustomerAccount__c where Name = 'Test Billing Account' limit 1];
      zCustomerAccount.Zuora__Status__c = 'In Active';
      update zCustomerAccount;
      
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];    
      
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        
     Test.stopTest();
       
    }
    
    static testMethod void testAccountBillingInsightExport(){
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];    
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        accBIExt.populateBillingInsightDataForExport();
      Test.stopTest();
       
    }
    
    static testMethod void testPopulateBillingInsightTableWithoutDate(){
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];    
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        accBIExt.populateBillingInsightTable();
      Test.stopTest();
       
    }
    static testMethod void testPopulateBillingInsightTableWithDates(){
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];    
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
        pref.getParameters().put('startDate',(date.today()-300).format());
        pref.getParameters().put('endDate',(date.today()-200).format());
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        accBIExt.populateBillingInsightTable();
      Test.stopTest();
       
    }
    
    static testMethod void testPopulateFutureInvoices(){
      Account custAccount = [select Id from Account where Name = 'Test Account BI' limit 1];
      
      list<ZuoraBillingPreviewObject.InvoiceItem> futureInvItems            = new list<ZuoraBillingPreviewObject.InvoiceItem>();
      list<ZuoraBillingPreviewapi.BillingPreviewResult> apiResponseList     = new list<ZuoraBillingPreviewapi.BillingPreviewResult>();
      ZuoraBillingPreviewapi.BillingPreviewResult apiResponse           = new ZuoraBillingPreviewapi.BillingPreviewResult();
      
      
      
      for( integer i= 0 ;i<=10 ;i++){
        ZuoraBillingPreviewObject.InvoiceItem tempInvItem = new ZuoraBillingPreviewObject.InvoiceItem();
        tempInvItem.ChargeAmount                            = 23.25;
        tempInvItem.SubscriptionInvoiceSeparately           = true;
        tempInvItem.ServiceStartDate                        = Date.today();
        tempInvItem.ServiceEndDate                          = Date.today();
        tempInvItem.SubscriptionId                          = 'z1234567890';
        futureInvItems.add( tempInvItem );
      } 
      apiResponse.AccountId             = custAccount.Id;
      apiResponse.Success               = true;
      apiResponse.size                  = 1;
      apiResponse.InvoiceItem           = futureInvItems;
      apiResponse.Errors                = new list<ZuoraBillingPreviewapi.Error>();
      apiResponseList.add( apiResponse );
      
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',custAccount.id);
       
        Test.setCurrentPage(pref);
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(custAccount);
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        accBIExt.invoiceResultsZuora = apiResponseList;
        accBIExt.populateFutureInvoices();
      Test.stopTest();
       
    }
    
     static testMethod void testException(){
      
      Test.startTest();
        
        PageReference pref = Page.AccountBillingInsight;
        pref.getParameters().put('id',null);
        Test.setCurrentPage(pref);
    
        ApexPages.StandardController accStdcon = new ApexPages.StandardController(new Account());
        AccountBillingInsight accBIExt = new AccountBillingInsight(accStdcon);
        
      Test.stopTest();
       
    }
    
    
    
   
}