// Modified by Stanley
// Much needed!!!!

@isTest
public class CaseAssetController_Test {
    public static final Integer COUNTER = 10;
    private static Pricebook2 Pbook;
    
    
    public static testMethod void testCaseAsset1(){
        
    test.startTest();   
  //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
    Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
    testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
    //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    
    
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
    Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    
    
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
    insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
    insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
    inv1.Name = 'TestInv';          
    inv1.Zuora__Account__c = testAccount.Id;
    inv1.Zuora__DueDate__c = system.Today()-1;
    inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case  
    Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
    caseRec.Is_Tiger_Lead__c =true;    
        theTestCases.add(caseRec);
        insert theTestCases;
   // Product set up//
   
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
     // Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            S_No__c=1,
            ProductCode='COBROKE', 
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_type__c ='Parent',
             Fulfillment_Status__c = 'Success',
             At_Risk__c = FALSE,
             Subscription_Id__c = '2c92c0f84f445280014f4e087d7b3b37',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(), 
             //       Commented by Stanley Sequeira to remove the Daily_Rate__c field
             //Daily_Rate__c=125,
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
  
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
    controller.finalsave();
  // AssetWrapper a=new AssetWrapper(theTestAssets.get(0));
   //a.lineAction= 'amend';
   CaseAssetController.AssetWrapper  csa = new CaseAssetController.AssetWrapper(theTestAssets.get(0));
    //csa.
    controller.AssetWrapper.add(csa);
    //controller.AssetWrapper.add(theTestAssets.get(0));
    // AssetWrapper
    if(controller.AssetWrapper.size()>0){
    for(CaseAssetController.AssetWrapper assets : controller.AssetWrapper) {
    assets.checked = true;
    }
    }
   controller.Save();
        controller.sortAssets();
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'End Date';
    controller.Zipcoderendered = false;
    controller.EndDaterendered = True;
    controller.SearchButton =true;
    
    controller.last();
    
    controller.filterSearch();  
    test.stopTest();      
 
    }
    public static testMethod void testCaseAsset2(){
        
    test.startTest();   
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
    Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
    
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case       
        theTestCases.add(TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false));
        insert theTestCases;
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
    //  Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            ProductCode='COBROKE',
            S_No__c=1,
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_Type__c = 'Parent',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(),
             //Commented by Stanley Sequeira to remove the Daily_Rate__c field 
             //Daily_Rate__c=125,
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
     controller.testMDTflag = 'TRUE';
       controller.Save();
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'Start Date';
    controller.Zipcoderendered = false;
    controller.StartDaterendered = True;
    controller.SearchButton =true;
    controller.filterSearch();  
    controller.BackToCase();
    test.stopTest();
    }
    
    public static testMethod void testCaseAsset3(){
   
    test.startTest();   
        
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case  
Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
caseRec.Is_Tiger_Lead__c =true;    
        theTestCases.add(caseRec);
        insert theTestCases;
   // Product set up//
   
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
     // Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            S_No__c=1,
            ProductCode='COBROKE', 
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) { 
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Line_Type__c='amend',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_type__c ='Parent',
             Fulfillment_Status__c = 'Success',
             At_Risk__c = FALSE,
             Subscription_Id__c = '2c92c0f84f445280014f4e087d7b3b37',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(), 
             //       Commented by Stanley Sequeira to remove the Daily_Rate__c field
            // Daily_Rate__c=125,
             Cancellation_Reason__c='TEst',
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
    
  // AssetWrapper a=new AssetWrapper(theTestAssets.get(0));
   //a.lineAction= 'amend';
       controller.Save();
       controller.CheckVetted(); // CRM-5764
       controller.UnCheckVetted(); // CRM-5764
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'Zip Code';
    controller.Zipcoderendered = true;
    controller.EndDaterendered = false;
    controller.SearchButton =true;
    controller.filterSearch();
    controller.beginning();
    controller.next();
   controller.getDisableNext();
   controller.getDisablePrevious();
    try{
    controller.previous();
    controller.last();
    }catch(exception e){}
    controller.getitems();
    
    test.stopTest();       
 
    }
    
     public static testMethod void testCaseAsset4(){
   
    test.startTest();   
        
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case  
Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
caseRec.Is_Tiger_Lead__c =true;    
        theTestCases.add(caseRec);
        insert theTestCases;
   // Product set up//
   
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
     // Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            S_No__c=1,
            ProductCode='COBROKE', 
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) { 
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Line_Type__c='amend',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_type__c ='Parent',
             Fulfillment_Status__c = 'Success',
             At_Risk__c = FALSE,
             Subscription_Id__c = '2c92c0f84f445280014f4e087d7b3b37',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(), 
             //       Commented by Stanley Sequeira to remove the Daily_Rate__c field
            // Daily_Rate__c=125,
             Cancellation_Reason__c='TEst',
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
    
  // AssetWrapper a=new AssetWrapper(theTestAssets.get(0));
   //a.lineAction= 'amend';
       controller.Save();
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'Market';
    controller.Zipcoderendered = false;
    controller.EndDaterendered = false;
    controller.SearchButton =true;
    controller.filterSearch();
    controller.beginning();
    controller.next();
   controller.getDisableNext();
   controller.getDisablePrevious();
    try{
    controller.previous();
    controller.last();
    }catch(exception e){}
    controller.getitems();
    
    test.stopTest();       
 
    }
public static testMethod void testCaseAsset5(){
   
    test.startTest();   
        
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case  
Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
caseRec.Is_Tiger_Lead__c =true;    
        theTestCases.add(caseRec);
        insert theTestCases;
   // Product set up//
   
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
     // Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            S_No__c=1,
            ProductCode='COBROKE', 
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) { 
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Line_Type__c='amend',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_type__c ='Parent',
             Fulfillment_Status__c = 'Success',
             At_Risk__c = FALSE,
             Subscription_Id__c = '2c92c0f84f445280014f4e087d7b3b37',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(), 
             //       Commented by Stanley Sequeira to remove the Daily_Rate__c field
            // Daily_Rate__c=125,
             Cancellation_Reason__c='TEst',
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
    
  // AssetWrapper a=new AssetWrapper(theTestAssets.get(0));
   //a.lineAction= 'amend';
       controller.Save();
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'AssetNumber';
    controller.Zipcoderendered = false;
    controller.EndDaterendered = false;
    controller.SearchButton =true;
    controller.filterSearch();
    controller.beginning();
    controller.next();
   controller.getDisableNext();
   controller.getDisablePrevious();
    try{
    controller.previous();
    controller.last();
    }catch(exception e){}
    controller.getitems();
    
    test.stopTest();       
 
    }
public static testMethod void testCaseAsset6(){
   
    test.startTest();   
        
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_CaseTrigger__c cst = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert cst;
    //Inserting Test Account       
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
    insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
    insert inv1;  
    
    List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case  
Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,false);
caseRec.Is_Tiger_Lead__c =true;    
        theTestCases.add(caseRec);
        insert theTestCases;
   // Product set up//
   
    // set up to create a product   
     // Get price book entries
     Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
     // Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062',
            S_No__c=1,
            ProductCode='COBROKE', 
            Family = 'Professional Development',
            Commission_Category__c = 'Tiger'
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
        
        PricebookEntry pb2 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1100, 
            IsActive = true 
        );
       // pdPbeList.add(pb2);
        
        insert pdPbeList;
   
   // Inserting Assert Test data//
    List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) { 
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAccount.Id,
             Product2ID=prod.ID,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Line_Type__c='amend',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             Asset_type__c ='Parent',
             Fulfillment_Status__c = 'Success',
             At_Risk__c = FALSE,
             Subscription_Id__c = '2c92c0f84f445280014f4e087d7b3b37',
             //End_Date__c=Date.Today()+9,
             start_date__c = Date.Today(), 
             //       Commented by Stanley Sequeira to remove the Daily_Rate__c field
            // Daily_Rate__c=125,
             Cancellation_Reason__c='TEst',
             Renewal_Price__c=50 ,
             Total_Net__c=175, 
             Renewal_Start_Date__c=Date.today().addDays(index)
            ));
        }
    insert theTestAssets;
     //set up for Case_Asset_Relationship__c     
    List<Case_Asset_Relationship__c>  cRel = new List<Case_Asset_Relationship__c>();
    Case_Asset_Relationship__c caseRel = new Case_Asset_Relationship__c();
        caseRel.Cancellation_Reason__c = 'Product Performance';
        caseRel.Asset__c=theTestAssets.get(0).ID;
        caseRel.Case__c=theTestCases.get(0).ID;
        caseRel.New_Risk__c=10.0;
        caseRel.New_List_Price__c=45;
        caseRel.Line_Action__c ='amend';
     insert caseRel;
     
     cRel  = [select id,Cancellation_Reason__c ,Asset__c,Case__c,New_Risk__c,New_List_Price__c,
                 Line_Action__c from Case_Asset_Relationship__c  where id=:caseRel.id];
    PageReference pageRef = Page.CaseAssets;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id', theTestCases.get(0).id);
    ApexPages.standardSetController scx = new ApexPages.standardSetController(cRel);
    CaseAssetController controller = new CaseAssetController(scx);
    
  // AssetWrapper a=new AssetWrapper(theTestAssets.get(0));
   //a.lineAction= 'amend';
       controller.Save();
    controller.getLineAction();
    controller.getCancellationReason();
    controller.CancelSearch();
    controller.MarketZip = 'test';
    controller.searchAssets();
    controller.RadioSearchType = 'AssetNumber';
    controller.Zipcoderendered = false;
    controller.EndDaterendered = false;
    controller.SearchButton =true;
    controller.filterSearch();
    controller.beginning();
    controller.next();
   controller.getDisableNext();
   controller.getDisablePrevious();
    try{
    controller.previous();
    controller.last();
    }catch(exception e){}
    controller.getitems();
    
    test.stopTest();       
 
    }



}