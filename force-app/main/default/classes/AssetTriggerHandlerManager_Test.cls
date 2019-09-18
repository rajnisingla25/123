@isTest(seeAllData=false)
public class AssetTriggerHandlerManager_Test {
 //public Opportunity testopp;
     @testSetup static void DataCreationMethodName() {
     DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.Opportunity_Trigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt2', Email='standarduser22@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing22', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Primary_Territory__c='test', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@testorg.com');
        
         //system.runas(u) {
         set<id> setAccountids =new set<id>();
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          testAccount.Sales_Lock_User__c =u.id;
          insert testAccount; 
          
          Account testAccount2 = TestDataFactory.createAccount('Test Account2',null,false);
          testAccount2.Primary_Email__c = 'testAccount@move.com';
          testAccount2.Party_ID__c = 'PartyId';
          testAccount2.Sales_Lock_User__c =u.id;
          insert testAccount2;
          Opportunity testopp = new Opportunity(      Name = 'The Opportunity',
                                                    StageName = 'Prospecting',
                                                    CloseDate = system.today(),
                                                    AccountId = testAccount.Id,
                                                    Opportunity_Short_Description__c = 'sDesc',
                                                    Amount = 0.00);
                                                   insert testopp;
     }
     
     static testMethod void testAssetTriggerHandlerAsyncOpportunityUpdate(){
     Set<Id> setOppId = new Set<Id>();
     for(Opportunity oppt:[Select Id from Opportunity]){
     setOppId.add(oppt.id);
     }
         list<asset> alist = new list<asset>();
         Asset a = new asset();
         a.name = 'Test Name';
         insert a;
         alist.add(a);
    AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
    athm.AsyncOpportunityUpdate(setOppId);
         
    athm.CreateCaseWhenAssetExpires(alist);
    }
    //private static final 
    static testMethod void testAssetTriggerHandlerManagerFunctionality(){
    List<Asset> lstAsset = new List<Asset>();
    Map<Id,Asset> mapAsset = new Map<Id,Asset>();
    Set<id> setAccountids = new Set<Id>();
    AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
    athm.updateAccountInfoOnAssetInsert(lstAsset);
    athm.updateAccountInfoOnAssetUpdate(mapAsset,mapAsset);
    athm.updateCaseAssetRelationshipOnAssetUpdate(mapAsset,mapAsset);
    //athm.OnAssetListPriceUpdate(mapAsset,mapAsset);
    
    //athm.UpdateProductGeoOnBDXParentAssets(lstAsset,mapAsset);
    
    //athm.getAccountsToUpdate(lstAsset,true);
    //athm.getAssetsOfAccount(setAccountids);
    //athm.getUpdatedAssets(mapAsset,mapAsset);
    //athm.manageAccountReassignementForAssets(lstAsset,mapAsset);
    }


    /*
    AssetTriggerHandlerManager
    updateAccountInfoOnAssetInsert
    updateAccountInfoOnAssetUpdate
    updateCaseAssetRelationshipOnAssetUpdate
    autoPopulateAccountProductFields
    populateProposedLeadsBasedOnProduct
    updateAssetOLIFulfillmentStatus
    updateFulfillToAssetsCPLoginStatus

    */

    static testMethod void updateAccountInfoOnAssetInsertTest(){
        //Test Data
        //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt2', Email='standarduser22@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing22', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Primary_Territory__c='test', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@testorg.com');
        
         system.runas(u) {
         set<id> setAccountids =new set<id>();
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          testAccount.Sales_Lock_User__c =u.id;
          insert testAccount; 
          
          Account testAccount2 = TestDataFactory.createAccount('Test Account2',null,false);
          testAccount2.Primary_Email__c = 'testAccount@move.com';
          testAccount2.Party_ID__c = 'PartyId';
          testAccount2.Sales_Lock_User__c =u.id;
          insert testAccount2; 
          set<id> accountIds = new set<id>();
          accountIds.add(testAccount2.id);
          map<id,account> mapAcc=new map<id,account>();
          mapAcc.put(testAccount.id,testAccount);
          setAccountids.add(testAccount.id);
          Set<Id> setBMQuoteIds = new Set<Id>();   
          BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
          quote.BigMachines__Account__c                   = testAccount.id;        
          quote.BigMachines__Status__c                    = 'Pending';
          quote.BigMachines_Quote_Type__c                 = 'New';
          quote.BigMachines__Status__c = 'Document Expired';   
          quote.BigMachines__Site__c = Label.BigMachineSite;
          insert quote;
          setBMQuoteIds.add(quote.Id);
          
        Asset_Promised_Leads__c ast = New Asset_Promised_Leads__c();
        ast.name = 'Product code';
        ast.Promised_Leads_Full__c =10;
        ast.Promised_Leads_Half__c = 5;
        insert ast;
        //Inserting assets
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Quantity=12, Name = 'Asset1',Asset_Type__c='Parent', status = 'Cancelled',price =250, AccountId = testAccount.id,UsageEndDate=date.Today(), Product_Type__c='Half');
        Asset asset2 = new Asset(Quantity=12, Name = 'Asset2',Asset_Type__c='Parent', status = 'Expired',price =250, AccountId = testAccount.id, Product_Type__c='Full');
        Asset asset3 = new Asset(Name = 'Asset3',Asset_Type__c='Parent', status = 'Active',price =250, AccountId = testAccount.id);
        Asset asset4 = new Asset(Name = 'Asset4',Asset_Type__c='Parent',Category__c='BDX', status = 'Active',price =250, AccountId = testAccount.id);
        
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
       
        map<id,asset> oldmapasset =new map<id,asset>();
        map<id,asset> newmapasset=new map<id,asset>();
        insert assets;
        for( Asset asst : assets){
             oldmapasset.put(asst.id,asst);
             newmapasset.put(asst.id,asst);
        }
        Test.startTest();
        
        for( Asset asst : newmapasset.values()){
             if( asst.status == 'Cancelled'){
                asst.status = 'Active';
                break;
             }
        }
        
        Map<Id, List<Asset>> theAccountAssets = new Map<Id, List<Asset>>();
        theAccountAssets.put(asset3.AccountId, new List<Asset>());  
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
       // athm.updateAccountInfoOnAssetInsert(assets);
        athm.manageAccountReassignementForAssets(assets, oldmapasset);
        //athm.manageAccountReassignementForAssets(assets, new map<id,asset>());
       // athm.updateAccountInformation(accountIds,false);
        //athm.AdVerificationCase(setBMQuoteIds);
        athm.getAssetsOfAccount(setAccountids);
        //athm.getUpdatedAssets(oldmapasset,newmapasset);
        athm.rolledUpFromAssets(newmapasset,oldmapasset,mapAcc,true);       
        athm.getUpdatedAssets(oldmapasset, newmapasset, true, false);
        athm.getCurrentUserInformation();
       
        athm.updatePromisedLeadsForAssets(assets[0],ast);
        athm.updatePromisedLeadsForAssets(assets[1],ast);
        athm.getUpdatedAssets(assets, oldmapasset);
        athm.UpdateProductGeoOnBDXParentAssets(assets,oldmapasset);
        Test.stopTest();
        }
    }
    
    
    
     static testMethod void updateAccountInfoOnAssetInsertTest22(){
        //Test Data
        //Inserting Disabled custom setting
        list<string> accountIdList = new list<string>();
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt2', Email='standarduser22@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing22', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Primary_Territory__c='test', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@testorg.com');
        
         system.runas(u) {
         set<id> setAccountids =new set<id>();
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          testAccount.Sales_Lock_User__c =u.id;
          insert testAccount; 
          
          Account testAccount2 = TestDataFactory.createAccount('Test Account2',null,false);
          testAccount2.Primary_Email__c = 'testAccount@move.com';
          testAccount2.Party_ID__c = 'PartyId';
          testAccount2.Sales_Lock_User__c =u.id;
          insert testAccount2; 
          
          accountIdList.add( testAccount.id);
          accountIdList.add( testAccount2.id);
          
          set<id> accountIds = new set<id>();
          accountIds.add(testAccount2.id);
          map<id,account> mapAcc=new map<id,account>();
          mapAcc.put(testAccount.id,testAccount);
          setAccountids.add(testAccount.id);
          Set<Id> setBMQuoteIds = new Set<Id>();   
          BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
          quote.BigMachines__Account__c                   = testAccount.id;        
          quote.BigMachines__Status__c                    = 'Pending';
          quote.BigMachines_Quote_Type__c                 = 'New';
          quote.BigMachines__Status__c = 'Document Expired';     
          quote.BigMachines__Site__c = Label.BigMachineSite;
          insert quote;
          setBMQuoteIds.add(quote.Id);
          
        Asset_Promised_Leads__c ast = New Asset_Promised_Leads__c();
        ast.name = 'Product code';
        ast.Promised_Leads_Full__c =10;
        ast.Promised_Leads_Half__c = 5;
        insert ast;
        //Inserting assets
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today(),Price=100,End_Date__c=date.Today(),Auto_Renewal__c='test11');
              assets.add(asset1);
        map<string,opportunity> accountIdToOpportunity  = new map<string,opportunity>();
        map<string,string> accountIdToOpportunityId     = new map<string,string>();
        accountIdToOpportunity = TurboUtilityClass.createOpportunities( accountIdList, 'Listing Going Dark');
        
        for( string accountId : accountIdToOpportunity.keySet() ){
            accountIdToOpportunityId.put(accountId, accountIdToOpportunity.get(accountId).Id  );
        }
     
        Test.startTest();
            insert assets;
           
            Asset asset5 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today(),Price=100,End_Date__c=date.Today(),Auto_Renewal__c='test11');
            insert asset5;
            map<id,asset> oldmapasset5 =new map<id,asset>();
            oldmapasset5.put(asset5.id,asset5);
            map<id,asset> oldmapasset =new map<id,asset>();
            oldmapasset.put( assets[0].id, assets[0]);
            system.debug('old values'+ oldmapasset);
            
            assets[0].status = 'Active';
            assets[0].accountid=testAccount2.id;
            assets[0].Price =102;
            assets[0].End_Date__c=date.Today().adddays(2);
            assets[0].Auto_Renewal__c='test11';
            //assets.add(asset1);
            update assets;
            
            asset5.AccountId=testAccount2.id;
            asset5.status = 'Active';
             
             asset5.Fulfillment_Status__c = 'Fulfilled';
             asset5.Turbo_Actions__c = 'Send Cancellation Email - Impressions not reducing since 504 hours';
             
            //update asset5;
            map<id,asset> newmapasset5=new map<id,asset>();
            newmapasset5.put(asset5.id,asset5);
            map<id,asset> newmapasset=new map<id,asset>();
            newmapasset.put( assets[0].id, assets[0]);
            system.debug('New values'+ newmapasset);
            
            AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
            
            athm.getUpdatedAssets(oldmapasset5, newmapasset5, false, true);
            //athm.updateAccountInformation(accountIds,true);
            athm.rolledUpFromAssets(newmapasset,oldmapasset,mapAcc,false); 
           // AssetTriggerHandlerManager.CreateTurboCancelQuote(JSON.serializePretty(assets),accountIdToOpportunityId);  
        Test.stopTest();
        }
    }
     static testMethod void updateAccountInfoOnAssetInsertTest23(){
        //Test Data
        //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt2', Email='standarduser22@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing22', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Primary_Territory__c='test', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@testorg.com');
        
         system.runas(u) {
         set<id> setAccountids =new set<id>();
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          testAccount.Sales_Lock_User__c =u.id;
          insert testAccount; 
          
          Account testAccount2 = TestDataFactory.createAccount('Test Account2',null,false);
          testAccount2.Primary_Email__c = 'testAccount@move.com';
          testAccount2.Party_ID__c = 'PartyId';
          testAccount2.Sales_Lock_User__c =u.id;
          insert testAccount2; 
          
          map<id,account> mapAcc=new map<id,account>();
          mapAcc.put(testAccount.id,testAccount);
          setAccountids.add(testAccount.id);
          Set<Id> setBMQuoteIds = new Set<Id>();   
          BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
          quote.BigMachines__Account__c                   = testAccount.id;        
          quote.BigMachines__Status__c                    = 'Pending';
          quote.BigMachines_Quote_Type__c                 = 'New';
          quote.BigMachines__Status__c = 'Document Expired';   
          quote.BigMachines__Site__c = Label.BigMachineSite;   
          insert quote;
          setBMQuoteIds.add(quote.Id);
          
        Asset_Promised_Leads__c ast = New Asset_Promised_Leads__c();
        ast.name = 'Product code';
        ast.Promised_Leads_Full__c =10;
        ast.Promised_Leads_Half__c = 5;
        insert ast;
        //Inserting assets
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today());
        Asset asset2 = new Asset(Name = 'Asset2', status = 'Expired', AccountId = testAccount.id);
        Asset asset3 = new Asset(Name = 'Asset3', status = 'Active', AccountId = testAccount.id);
        Asset asset4 = new Asset(Name = 'Asset4', status = 'Active', AccountId = testAccount.id);
        
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        Asset asset5 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today());
        insert asset5;
        map<id,asset> oldmapasset5 =new map<id,asset>();
        oldmapasset5.put(asset5.id,asset5);
        map<id,asset> oldmapasset =new map<id,asset>();
        oldmapasset.put(asset1.id,asset1);
        Test.startTest();
        insert assets;
        asset1.status = 'Active';
        
        update assets;
        asset5.AccountId=testAccount2.id;
         asset5.status = 'Active';
        update asset5;
         map<id,asset> newmapasset5=new map<id,asset>();
        newmapasset5.put(asset5.id,asset5);
        map<id,asset> newmapasset=new map<id,asset>();
        newmapasset.put(asset1.id,asset1);
        
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
       
        athm.getUpdatedAssets(oldmapasset5, newmapasset5, false, false);
      
        Test.stopTest();
        }
    }
    
    
    
    static testMethod void updateAccountInfoOnAssetUpdateTest(){
        //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
     
       CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;   
        ProductCase__c cs = new ProductCase__c();
        cs.Name='DIGITIALAGENT';
        cs.Case_Record_Type__c ='Standard';
        cs.Case_Area__c='New/Renewal Order';
        cs.Case_Description__c='Complete Ad Verificaton';
        cs.Case_Sub_Area__c='DART API Failure';
        cs.Case_Subject__c ='DAP Failed to Fulfill';
        cs.Case_Type__c ='Digital Ad Package';
        cs.Queue__c ='Ad_Operations';
        insert cs;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          insert testAccount;       
       
        
         Set<Id> setBMQuoteIds = new Set<Id>();   
          BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
          quote.BigMachines__Account__c                   = testAccount.id;        
          quote.BigMachines__Status__c                    = 'Pending';
          quote.BigMachines_Quote_Type__c                 = 'New';
          quote.BigMachines__Status__c = 'Document Expired';    
           quote.BigMachines__Site__c = Label.BigMachineSite;
          insert quote;
          setBMQuoteIds.add(quote.Id);
           ProductCase__c cs1 = new ProductCase__c();
        cs1.Name='Add Verification';
        cs1.Case_Record_Type__c ='Standard';
        cs1.Case_Area__c='New/Renewal Order';
        cs1.Case_Description__c='Complete Ad Verificaton';
        cs1.Case_Sub_Area__c='DART API Failure';
        cs1.Case_Subject__c ='DAP Failed to Fulfill';
        cs1.Case_Type__c ='Digital Ad Package';
        cs1.Queue__c ='Add Verification';
        insert cs1;
        //Inserting a test account
       
        
       
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.ProductCode = 'DIGITALAGENT';   
        insert prod;
        
        Asset asset1 = new Asset(Name = 'Asset1',Line_type__c='Add', status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Market__c='Abc12431',product2id=prod.id,Fulfillment_Status__c='Pending Fulfillment',Comments__c='test',Follow_Up_Status__c='TestBefore',asset_type__c='Parent');
        insert asset1;
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        
        asset1.Follow_Up_Status__c = 'test';
        update asset1;
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        Asset asset2 = new Asset(Name = 'Asset1',Line_type__c='Add', status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Market__c='Abc12431',product2id=prod.id,Fulfillment_Status__c='Failure',Comments__c='test',Follow_Up_Status__c='testafter',asset_type__c='Parent');
        insert asset2;
        assetsMap.put(asset2.id,asset2);
        oldAssetMap.put(asset2.id,asset1);
        Test.startTest();
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
        athm.updateAccountInfoOnAssetUpdate(oldAssetMap, assetsMap);
         athm.AdVerificationCase(setBMQuoteIds);
        Test.stopTest();
    }

    static testMethod void updateCaseAssetRelationshipOnAssetUpdateTest(){
       //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
        insert testAccount;       
        
        Account_Listing__c alist = new Account_Listing__c();
        alist.City__c = 'Fremont';
        alist.Account_Name__c = testAccount.Id;
        insert alist;
        
        
       Product2 testProduct = Commissions_TestDataFactory.CreateProduct('TURBO Prod',false);
       testProduct.ProductCode = 'TURBO';   
       insert testProduct;
         //Inserting assets
        Asset asset1 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Market__c='Abc12431');
        Asset asset2 = new Asset(Name = 'Asset2', status = 'Expired', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500);
        Asset asset3 = new Asset(Name = 'Asset3', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500);
        Asset asset4 = new Asset(Name = 'Asset4', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500);
        Asset asset5 = new Asset(Name = 'Asset4', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500, Product2Id = testProduct.Id, Market__c='Fremont,CA');
        List<Asset> assets = new List<Asset>();
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        assets.add(asset5);
        insert assets;
      
        ////Inserting case record
        //Case case1 = new Case(subject='test case', description='test case description', type = 'New', status = 'New');
        //insert case1;


        ////Inserting Case_Asset_Relationship__c records
        //Case_Asset_Relationship__c car_Records = new Case_Asset_Relationship__c(Asset__c= asset1.id, Case__c = case1.id);
        //insert car_Records;


        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        for(Asset asset: assets){   
            oldAssetMap.put(asset.id,asset); 
        }
        assets.clear();
        asset1.end_Date__c = Date.newInstance(2016, 9, 30);
        asset2.end_Date__c = Date.newInstance(2016, 9, 30);
        asset3.end_Date__c = Date.newInstance(2016, 9, 30);
        asset4.end_Date__c = Date.newInstance(2016, 9, 30);
        asset5.end_Date__c = Date.newInstance(2016, 9, 30);
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        assets.add(asset5);
        update assets;

        for(Asset asset: assets){            
            assetsMap.put(asset.id,asset);
        }
        
        Test.startTest();
            AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
            athm.updateCaseAssetRelationshipOnAssetUpdate(oldAssetMap, assetsMap);
            athm.populateAccountListingBasedOnProduct(assets, assetsMap,false);
        Test.stopTest();
    }


   /* static testMethod void autoPopulateAccountProductFieldsTest(){
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        Test.startTest();
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
        athm.autoPopulateAccountProductFields(oldAssetMap, assetsMap, true);
        athm.autoPopulateAccountProductFields(oldAssetMap, assetsMap, false);
        Test.stopTest();
    }*/


    static testMethod void populateProposedLeadsBasedOnProductTest(){
   
        
        List<Asset> oldAssetMap = new List<Asset>();
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        Test.startTest();
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
        athm.populateProposedLeadsBasedOnProduct(oldAssetMap, assetsMap, true);
        athm.populateProposedLeadsBasedOnProduct(oldAssetMap, assetsMap, false);
        Test.stopTest();
    }
   
    static testMethod void updateAssetOLIFulfillmentStatusTest(){
       //Inserting Disabled custom setting
        // Commenting the method due to exception "Zuora.zAPIException: Please upload Zuora WSDL at first."
        OrderDecompController.stopCreatingAccount = true;
       
       DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = UserInfo.getUserName();
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        insert disabledTriggerCustomSetting;
        Switch_CaseTrigger__c sct = new Switch_CaseTrigger__c();
        sct.Set_Overall_Trigger_Off__c = true;
        insert sct;
        Tiger_Lead_Products__c TLProducts= new Tiger_Lead_Products__c();
        TLProducts.Name = 'TOPIDX';
        TLProducts.Tiger_Lead_Product_List__c = 'TOPIDX';
        TLProducts.TigerLeadActivities__c = 'Complete TOPIDX Manual Activity1;Complete TOPIDX Manual Activity2';
        TLProducts.Queue_Name__c = 'DAP_Fulfillment';
        insert TLProducts;
        
       
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
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
        
        
       Product2 testProduct = Commissions_TestDataFactory.CreateProduct('COBROKE Prod',false);
       testProduct.ProductCode = 'COBROKE';   
       insert testProduct;
       
       Product2 testProduct1 = Commissions_TestDataFactory.CreateProduct('TOPIDX Prod',false);
       testProduct1.ProductCode = 'TOPIDX';   
       insert testProduct1;
       
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
            thePricebookEntrie1.Pricebook2Id = Test.getStandardPricebookId();
            thePricebookEntrie1.Product2Id = testProduct1.Id;
            thePricebookEntrie1.UnitPrice = 1000;
            thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
                quote.BigMachines__Account__c                   = testAccount.id;        
                quote.BigMachines__Status__c                    = 'Ordered';
                quote.BigMachines_Quote_Type__c                 = 'New';
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
        theTestOrder.products__c='COBROKE';
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
      
         //Inserting assets
        Asset asset1 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Market__c='Abc12431',Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        Asset asset2 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset2', status = 'Expired', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        Asset asset3 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset3', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        Asset asset4 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset4', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500, Product2Id = testProduct1.Id,Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        Asset asset5 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset4', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500, Product2Id = testProduct.Id, Market__c='Fremont,CA',Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        
        List<Asset> assets = new List<Asset>();
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        assets.add(asset5);
        insert assets;
      
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> newAssetsMap = new Map<Id, Asset>();
        for(Asset asset: assets){   
            oldAssetMap.put(asset.id,asset); 
        }
        List<Asset> assetsNew = [ select Product_Code__c,Order_Line_Item__c,Name,status,AccountId,End_Date__c,Order_Type__c,Start_Date__c,Total_Net__c,Fulfillment_Status__c,Asset_Type__c from Asset limit 10];
        for(Asset asst: assetsNew){   
            asst.Fulfillment_Status__c = 'Fulfilled';
        }
        update assetsNew;
        for(Asset asst: assetsNew){   
            newAssetsMap.put(asst.id,asst); 
        }
        
       
        Test.startTest();
            
            AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
            athm.updateAssetOLIFulfillmentStatus(newAssetsMap, oldAssetMap);
        Test.stopTest();
        
    }

     static testMethod void updateFulfillToAssetsCPLoginStatusTest(){
       //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          insert testAccount;       
       
        
       
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.ProductCode = 'FIVESTREET';   
        insert prod;
        
        
        Asset_Promised_Leads__c apl = new Asset_Promised_Leads__c(Name = 'FIVESTREET' , Promised_Leads_Full__c = 15 , Promised_Leads_Half__c = 10);    
         
         insert apl;
         
         //Inserting assets
        Asset asset1 = new Asset(Name = 'Asset1',Quantity = 1 ,Product2Id = prod.id , status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset2 = new Asset(Name = 'Asset2', Quantity = 2 ,Product2Id = prod.id, status = 'Expired', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset3 = new Asset(Name = 'Asset3',Quantity = 3 ,Product2Id = prod.id,status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset4 = new Asset(Name = 'Asset4',Quantity = 4 ,Product2Id = prod.id , status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        List<Asset> assets = new List<Asset>();
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        insert assets;
      
        ////Inserting case record
        //Case case1 = new Case(subject='test case', description='test case description', type = 'New', status = 'New');
        //insert case1;


        ////Inserting Case_Asset_Relationship__c records
        //Case_Asset_Relationship__c car_Records = new Case_Asset_Relationship__c(Asset__c= asset1.id, Case__c = case1.id);
        //insert car_Records;


        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        for(Asset asset: assets){   
            oldAssetMap.put(asset.id,asset); 
        }
        assets.clear();
        asset1.end_Date__c = Date.newInstance(2016, 9, 30);
        asset2.end_Date__c = Date.newInstance(2016, 9, 30);
        asset3.end_Date__c = Date.newInstance(2016, 9, 30);
        asset4.end_Date__c = Date.newInstance(2016, 9, 30);
        
        asset1.Quantity = 5;
        asset2.Quantity = 6;
        asset3.Quantity = 7;
        asset4.Quantity = 8;
       
        asset1.Product_Type__c  = 'Half';
        asset2.Product_Type__c  = 'Half';
        asset3.Product_Type__c = 'Half';
        asset4.Product_Type__c = 'Half';
          
        
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        update assets;

        for(Asset asset: assets){            
            assetsMap.put(asset.id,asset);
        }
        
        
          //Inserting assets
        Asset assetParent = new Asset(Name = 'Asset1',Asset_Type__c='Parent',Get_CP_Login_Status__c='',Quantity = 1 ,Product2Id = prod.id , status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset assetFulfillTo = new Asset(Name = 'Asset2',Asset_Type__c='Fulfill To',Get_CP_Login_Status__c='', Quantity = 2 ,Product2Id = prod.id, status = 'Expired', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        insert assetParent;
        assetFulfillTo.Parent_Asset__c = assetParent.id;
        insert assetFulfillTo;
        List<Asset> assetList = new List<Asset>();
        assetList.add(assetParent);
        assetList.add(assetFulfillTo);
        set<Id> assetIds = new set<Id>();
        Map<Id, Asset> oldAssetMapForCP = new Map<Id, Asset>();
        for(Asset asset: assetList){   
            oldAssetMapForCP.put(asset.id,asset); 
            assetIds.add(asset.id);
        }
        
        Map<Id, Asset> newAssetMapForCP = new Map<Id, Asset>( [select Asset_Type__c,Get_CP_Login_Status__c,Id from Asset where Id in:assetIds ]);
        for(Asset asset: newAssetMapForCP.values()){            
            asset.Get_CP_Login_Status__c = 'Complete';
        }
        update newAssetMapForCP.values();
        
        Test.startTest();
            AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
            athm.updateFulfillToAssetsCPLoginStatus(newAssetMapForCP, oldAssetMapForCP);
            athm.populateProposedLeadsBasedOnProduct(assets,oldAssetMap,true);
            athm.populateProposedLeadsBasedOnProduct(assets,oldAssetMap,false);
        Test.stopTest();
    }
    static testMethod void getUpdatedAssets_Test(){
         //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
       
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
          insert testAccount;       
       
        
       
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.ProductCode = 'FIVESTREET';   
        insert prod;
        
        
        Asset_Promised_Leads__c apl = new Asset_Promised_Leads__c(Name = 'FIVESTREET' , Promised_Leads_Full__c = 15 , Promised_Leads_Half__c = 10);    
         
         insert apl;
         
         //Inserting assets
        Asset asset1 = new Asset(Name = 'Asset1',Quantity = 1 ,Product2Id = null , status = 'Cancelled', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset2 = new Asset(Name = 'Asset2', Quantity = 2 ,Product2Id = null, status = 'Expired', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset3 = new Asset(Name = 'Asset3',Quantity = 3 ,Product2Id = prod.id,status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        Asset asset4 = new Asset(Name = 'Asset4',Quantity = 4 ,Product2Id = prod.id , status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'Retention', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500,Product_Type__c = 'Full',Market__c='Abc12431');
        List<Asset> assets = new List<Asset>();
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        insert assets;
       

        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Set<Id> assetIds = new Set<Id>();
        for(Asset asset: assets){   
            oldAssetMap.put(asset.id,asset); 
            assetIds.add( asset.id );
        }
       
        
        list<Asset> newAssetList =  [select Name,Product_Type__c,Product2Id,Promised_Leads__c,Quantity from Asset where Id in:assetIds ];
        for(Asset asst: newAssetList){            
            if( asst.Name == 'Asset2'){
                asst.Product2Id = prod.id;
            }
            if( asst.Name == 'Asset3'){
                asst.Product_Type__c = 'Half';
            }
            if( asst.Name == 'Asset4'){
                asst.Quantity = 3;
            }
        }
        update newAssetList;
        
        Test.startTest();
            AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
            athm.getUpdatedAssets(newAssetList, oldAssetMap);
        Test.stopTest();
        
    }
    static testMethod void AssetTriggerHandler_Test(){
       //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        
          Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Party_ID__c = 'PartyId';
         // testAccount.Sales_Lock_User__c =u.id;
          insert testAccount; 
         //Inserting assets
        Asset asset1 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today());
        Asset asset2 = new Asset(Name = 'Asset2', status = 'Expired', AccountId = testAccount.id);
        Asset asset3 = new Asset(Name = 'Asset3', status = 'Active', AccountId = testAccount.id);
        Asset asset4 = new Asset(Name = 'Asset4', status = 'Active', AccountId = testAccount.id);
        List<Asset> assets = new List<Asset>();
        asset1.Fulfillment_Status__c = 'Pending Fulfillment';
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        assets.add(asset4);
        map<id,asset> oldmapasset =new map<id,asset>();
        oldmapasset.put(asset1.id,asset1);
        Test.startTest();
        insert assets;
        
         map<id,asset> newmapasset=new map<id,asset>();
        newmapasset.put(asset1.id,asset1);
        contact co1 = new Contact();
        co1.FirstName = 'First';
        co1.LastName = 'Last';
        co1.AccountId = testAccount.Id;

        insert  co1;
       Contract C = New Contract();
      C.AccountId = testAccount.Id;
      C.Status = 'Draft';
     // C.Opportunity__r = O;
      C.CustomerSigned = co1;
     // C.Product__c = 'B2B Analysis';
     // C.No_of_users__c = 5;
      //C.CurrencyIsoCode = 'SEK';
     // C.Monthly_Subscription__c = 100;
     // C.Total_Subscription_Amount__c = 1000;
      //C.One_Off_Amount__c = 0;
      //C.First_Contract_Start_Date__c = Date.today();
      C.StartDate = Date.today();
      //C.EndDate= Date.today();
      C.ContractTerm = 2;
      //C.Running_Subscription__c = 'No';
      Insert C;
        
        asset1.status = 'Expired';
        asset1.Contract__c = C.Id;
        asset1.Fulfillment_Status__c = 'Fulfilled';
        asset1.Contract_Term__c = '12';
        asset1.Line_Type__c = 'Add';
        //asset1.Line_Type__c = 'CUSTOMLEAD';
        update assets;
        
        AssetTriggerHandler ath=new AssetTriggerHandler();
        
        //ath.onAfterUpdate();
        //ath.IsTriggerContext=true;
       // ath.isExecuting =false;
             ath.Assetfullfillmentmethod(oldmapasset,newmapasset);
             Boolean tgrContext = ath.IsTriggerContext;
             tgrContext = ath.IsVisualforcePageContext;
             tgrContext = ath.IsWebServiceContext;
             tgrContext = ath.IsExecuteAnonymousContext;
        }
    
        private static testMethod void testCaseAccountPopulationFromRelationship() {  
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
          //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
      Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
   insert arc;       
   ProductCase__c  pc = new ProductCase__c(Name = 'Add Verification', Case_Type__c = 'Digital Ad Package');
   insert pc;  
   ProductCase__c  pc1 = new ProductCase__c(Name = 'DIGITIALAGENT', Case_Type__c = 'Digital Ad Package',Case_Area__c = 'New/Renewal Order',Case_Sub_Area__c ='DART API Failure');
   insert pc1;     
   Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
        List<Account> listAccount = new list<Account>();
        Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
        parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
        parentAcc1.ShippingState  = 'CA';
        parentAcc1.ShippingCountry  = 'USA';
        listAccount.add(parentAcc1);
        
        Account parentAcc2 = TestDataFactory.createAccount('Parent Acc2',null,false);
        parentAcc2.Primary_Email__c = 'parentAcc2@move.com';
        parentAcc2.ShippingState  = 'CA';
        parentAcc2.ShippingCountry  = 'USA';
        listAccount.add(parentAcc2);        
         insert listAccount; 
        
        List<Contact> listContact = new List<Contact>();    
        Contact testContact = TestDataFactory.createContact('TestContact1','Last1',parentAcc1.id,true,false);
        testContact.Email = 'testContact1@move.com';
        testContact.Type__c = 'Primary';
        listContact.add(testContact);
        
        Contact testContact2 = TestDataFactory.createContact('TestContact2','Last2',parentAcc2.id,true,false);
        testContact2.Email = 'testContact2@move.com';
        testContact2.Type__c = 'Primary';
        listContact.add(testContact2);
        insert listContact;
        
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        // Create Relationship records for Contact Relationhsip
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                            parentAcc1.Id, null, listContact.get(0).Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        toBeInserted.add(accountRelation); 
        
        // Create Relationship records for Contact Relationhsip
        Account_Relationship__c accountRelation1 = TestDataFactory.createAccountRelationship(
                            parentAcc2.Id, null, listContact.get(1).Id, null, true, false);
        accountRelation1.RecordTypeId =     contactRelationshipRecordTypeId;
        accountRelation1.Active__c = true;
        toBeInserted.add(accountRelation1); 
        
        insert toBeInserted;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;   
             BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
                quote.BigMachines__Account__c                   = listAccount[0].id;        
                quote.BigMachines__Status__c                    = 'Pending';
                quote.BigMachines_Quote_Type__c                 = 'New';
                quote.BigMachines__Site__c = Label.BigMachineSite;
                insert quote;               
                Set<Id> setQuoteDapIds = new Set<Id>();              
                setQuoteDapIds.add(quote.Id);                   
            Product2 newProduct                 = new Product2();
                newProduct.Name                     = 'Test Product';        
                newProduct.ProductCode              ='DIGITALAGENT' ;
                newProduct.S_No__c                  = 2;
                insert newProduct; 
             
             // Extracting Standard Price Book ID.
        Id theStandardPriceBookId = Test.getStandardPricebookId();                
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
            thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
            thePricebookEntrie1.Product2Id = newProduct.Id;
            thePricebookEntrie1.UnitPrice = 1000;
            thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        System.debug('theTestProducts:' + thePricebookEntrie1.id);   
        // Inserting Test Orders.        
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
            theTestOrder.Status = 'Created';
            theTestOrder.Type = 'New';          
            theTestOrder.AccountId = listAccount[0].Id;
            theTestOrder.Pricebook2Id = theStandardPriceBookId;           
            theTestOrder.Fulfillment_Status__c ='Fulfilled';   
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
          theOrderItem.Fulfillment_Status__c ='Fulfilled';          
      //insert theOrderItem;    
     
      //System.debug('theOrderItems:' + theOrderItem.id );     
    
         // Inserting Test Assets.
        Asset theTestAsset = new Asset();        
          theTestAsset.Name = 'The Test Asset';
            theTestAsset.Status = 'Active';
            theTestAsset.AccountId = listAccount[0].Id;
            theTestAsset.asset_type__c ='Parent';           
            theTestAsset.Fulfillment_Status__c = 'pendig Fulfillment';
            theTestAsset.Asset_Type__c = 'Parent';
            //theTestAsset.Order_Line_Item__c = theOrderItem.Id;
            theTestAsset.Line_type__c ='Add';          
            theTestAsset.Product2Id = newProduct.Id; 
       insert theTestAsset; 
      Test.startTest();
            Case theCase = TestDataFactory.createCase(
               'The Final Test Case',
               'New',
               'International',
               'The Final Test Case',
               testContact.id,
               listAccount[0].id,
               false
              );
              theCase.Relationship__c = accountRelation.Id;
              theCase.Oracle_Quote__c= quote.Id;
              theCase.Origin = 'Email';   
              insert theCase;    
                  
              theCase = [Select Accountid , Oracle_Quote__c From Case WHERE Id =: theCase.Id];   
         
              List<Case> lstCase = new List<Case>();
            
              set<Case> caseIds = new set<Case>();
              caseIds.add(theCase);
           
        
        ID CollectionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Collections').RecordTypeId;      
       Case theCase1 = TestDataFactory.createCase(
               'The Final Test Case',
               'New',
               'International',
               'The Final Test Case',
               testContact.id,
               listAccount[0].id,
               false
              );
              theCase1.Relationship__c = accountRelation.Id;
              theCase1.Oracle_Quote__c= quote.Id;
              theCase1.Origin = 'Email';              
              theCase1.SubStatus__c = 'Pending Customer';
              theCase1.ParentId = theCase.id;
              insert theCase1;        
              theCase1.Type = 'Digital Ad Package';
              theCase1.Area__c = 'New/Renewal Order';
              theCase1.Sub_Area__c  = 'DART API Failure';  
              theCase1.Status = 'Closed' ;
              theCase1.order__c = theTestOrder.Id; 
              theCase1.RecordTypeId = CollectionRtID;              
              theCase1.SubStatus__c = 'Monitoring'; 
              theCase1.Origin = 'Phone';
              theCase1.ownerId = userinfo.getuserid();
             // update theCase1;
        
          Test.stopTest();
        
    }
    
    static testMethod void updateOrderWhenAssetCancelledTest(){
       //Inserting Disabled custom setting
        // Commenting the method due to exception "Zuora.zAPIException: Please upload Zuora WSDL at first."
        OrderDecompController.stopCreatingAccount = true;
       
       DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        
        insert disabledTriggerCustomSetting;
       
        //Inserting a test account
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
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
  
       
       Product2 testProduct1 = Commissions_TestDataFactory.CreateProduct('Realsuite respond',false);
       testProduct1.ProductCode = 'RSRESPOND';   
       insert testProduct1;
       
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
            thePricebookEntrie1.Pricebook2Id = Test.getStandardPricebookId();
            thePricebookEntrie1.Product2Id = testProduct1.Id;
            thePricebookEntrie1.UnitPrice = 1000;
            thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
                quote.BigMachines__Account__c                   = testAccount.id;        
                quote.BigMachines__Status__c                    = 'Ordered';
                quote.BigMachines_Quote_Type__c                 = 'New';
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
      
         //Inserting assets
         Asset asset1 = new Asset(Order_Line_Item__c = theOrderItem.Id,Name = 'Asset4', status = 'Active', AccountId = testAccount.id, End_Date__c = Date.newInstance(2016,9,9), Order_Type__c = 'New', Start_Date__c = Date.newInstance(2016, 8, 9), Total_Net__c=500, Product2Id = testProduct1.Id, Market__c='Fremont,CA',Fulfillment_Status__c='Pending Fulfillment',Asset_Type__c='Parent');
        insert asset1;
           
        Test.startTest();
        asset1.Line_Type__c = 'Cancel';
        asset1.Fulfillment_Status__c = 'Fulfilled';
        asset1.Turbo_Actions__c = 'Send Cancellation Email - Impressions not reducing since 504 hours';
        update asset1;
        Test.stopTest();
        
    }
     private static testMethod void testCaseForLCM() {  
          //creating test data 
           //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
          Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
            agentAcc.Primary_Email__c = 'parentAcc@move.com';
            agentAcc.Type = 'Realtor Agent';
            agentAcc.Party_ID__c  = '12345';
            agentAcc.Customer_Id__c  = '12345';
            agentAcc.BillingPostalCode  = '12345';
            agentAcc.BillingCity = 'newyork';
            agentAcc.MLS_Set_Id__c  = '12345';    
        
            insert agentAcc;
            
            Account lenderAcc = TestDataFactory.createAccount('Agent Account', null, false);
            lenderAcc.Primary_Email__c = 'parentAcc@move.com';
            lenderAcc.Type = 'Lender Individual';
            lenderAcc.Party_ID__c  = '67890';
            lenderAcc.Customer_Id__c  = '67890';
            lenderAcc.BillingPostalCode  = '67890';
            lenderAcc.BillingCity = 'newyork';
            lenderAcc.MLS_Set_Id__c  = '67890';  
            lenderAcc.nmls_Id__c = '123456';  
            lenderAcc.Email_Address__c = 'test@test.com';
            insert lenderAcc;
            
              List<Contact> contacts= new List<Contact>();
            //Create Contacts
            Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
             //Create Contacts
            testContact = TestDataFactory.createContact('TestContact','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
            
            insert contacts;
            DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
          List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();

              Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

            Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(0).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(1).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation);
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(2).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(3).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            accountRelation.Total_comarketing_assets__c = 0;
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
                    accountRelation.Initial_comarketer_spend_percent__c = 10;

            toBeInserted.add(accountRelation);
            insert toBeInserted;
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = agentAcc.Id;
            ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.comarketer_actual_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.Total_comarketing_assets__c = 10;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            ar.Current_comarketer_spend_percent__c = 10;

            //ar.relationship_CAP__c = 280;
            insert ar;
            
             PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = lenderacc.id;
        pp.PaymentMethodId__c =  '44444444444444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        pp.Reason_Code__c = 'New Chip';
        pp.Recently_Added__c = true;

        insert pp;
            List<Comarketing_relationship__c> clist = new List<Comarketing_Relationship__c>();
            for(Integer i=0; i<=3;i++){
            comarketing_relationship__c c1 = new comarketing_relationship__c();
            c1.relationship__c = ar.id;
            c1.agent_account__c = agentAcc.id;
            c1.lender_account__c = lenderAcc.id;
            c1.Payment_Profile__c = pp.id;
            c1.status__c = 'Active';
            c1.Agent_Lender_Asset_Id__c = '7865'+i;
           // c1.lender_asset_monthly_contribution__c = 50;
           // c1.agent_asset_monthly_contribution__c = 400;
            clist.add(c1);
            }
             insert cList;
            Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
            prod.ProductCode = 'COBROKE';   
            insert prod;
            
            Product2 prod1 = Commissions_TestDataFactory.CreateProduct('Name',false);
            prod1.ProductCode = 'RSRESPOND';   
            insert prod1;
            
             //Inserting assets
                List<Asset> assets = new List<Asset>();

                Asset asset1 = new Asset(Name = 'Asset1', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id,UsageEndDate=date.Today());
                Asset asset2 = new Asset(Name = 'Asset2', extended_net_price__c =250,PRODUCT2ID = PROD1.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id);
                Asset asset3 = new Asset(Name = 'Asset3', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id);
                Asset asset4 = new Asset(Name = 'Asset4', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Cancel', Category__c='BDX', status = 'Cancelled',price__c =250, AccountId = agentAcc.id);
                
                assets.add(asset1);
                assets.add(asset2);
                assets.add(asset3);
                assets.add(asset4);
               
                insert assets; 
                for(Integer i=0; i<=3; i++){
                   clist[i].cfcb_asset__c = assets[i].id;
                }
                update cList;
                
       Test.StartTest();
          Delete disabledTriggerCustomSetting;
          Asset asset5 = new Asset(Name = 'Asset5', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id, UsageEndDate=date.Today());
          insert asset5;
          assets.clear();
          asset1.fulfillment_status__c = 'Fulfilled';
           assets.add(asset1);
           asset2.fulfillment_status__c = 'Fulfilled';
           assets.add(asset2);
           asset3.fulfillment_status__c = 'Fulfilled';
           assets.add(asset3);
           asset4.fulfillment_status__c = 'Fulfilled';
           assets.add(asset4);
           update assets;
          
           
       Test.stopTest();
            
    }
     private static testMethod void testCaseForLCM3() {  
          //creating test data 
           //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
          Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
            agentAcc.Primary_Email__c = 'parentAcc@move.com';
            agentAcc.Type = 'Realtor Agent';
            agentAcc.Party_ID__c  = '12345';
            agentAcc.Customer_Id__c  = '12345';
            agentAcc.BillingPostalCode  = '12345';
            agentAcc.BillingCity = 'newyork';
            agentAcc.MLS_Set_Id__c  = '12345';    
        
            insert agentAcc;
            
            Account lenderAcc = TestDataFactory.createAccount('Agent Account', null, false);
            lenderAcc.Primary_Email__c = 'parentAcc@move.com';
            lenderAcc.Type = 'Lender Individual';
            lenderAcc.Party_ID__c  = '67890';
            lenderAcc.Customer_Id__c  = '67890';
            lenderAcc.BillingPostalCode  = '67890';
            lenderAcc.BillingCity = 'newyork';
            lenderAcc.MLS_Set_Id__c  = '67890';   
            lenderAcc.nmls_id__c = '12455'; 
            lenderAcc.Email_Address__c = 'test@test.com';
        
            insert lenderAcc;
            
              List<Contact> contacts= new List<Contact>();
            //Create Contacts
            Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
             //Create Contacts
            testContact = TestDataFactory.createContact('TestContact','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
            
            insert contacts;
            DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
          List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();

              Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

            Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(0).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(1).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            accountRelation.Total_comarketing_assets__c = 0;
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(2).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(3).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
                    accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation);
            insert toBeInserted;
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = agentAcc.Id;
            ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.comarketer_actual_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            ar.Total_comarketing_assets__c = 10;
            ar.Current_comarketer_spend_percent__c = 10;

            //ar.relationship_CAP__c = 280;
            insert ar;
            
             PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = lenderacc.id;
        pp.PaymentMethodId__c =  '44444444444444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        pp.Reason_Code__c = 'New Chip';
        pp.Recently_Added__c = true;

        insert pp;
            List<Comarketing_relationship__c> clist = new List<Comarketing_Relationship__c>();
            for(Integer i=0; i<=3;i++){
            comarketing_relationship__c c1 = new comarketing_relationship__c();
            c1.relationship__c = ar.id;
            c1.agent_account__c = agentAcc.id;
            c1.lender_account__c = lenderAcc.id;
            c1.Payment_Profile__c = pp.id;
            c1.status__c = 'Active';
            c1.Agent_Lender_Asset_Id__c = '5678'+i;
            //c1.lender_asset_monthly_contribution__c = 50;
            //c1.agent_asset_monthly_contribution__c = 400;
            clist.add(c1);
            }
            insert cList;
            Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
            prod.ProductCode = 'COBROKE';   
            insert prod;
            
             //Inserting assets
                List<Asset> assets = new List<Asset>();

                Asset asset1 = new Asset(Name = 'Asset1',extended_net_price__c =250, PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id,UsageEndDate=date.Today());
                Asset asset2 = new Asset(Name = 'Asset2', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id);
                Asset asset3 = new Asset(Name = 'Asset3', extended_net_price__c =250,PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, AccountId = agentAcc.id);
                Asset asset4 = new Asset(Name = 'Asset4', extended_net_price__c =250, PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', Category__c='BDX', status = 'Active',price__c =250, AccountId = agentAcc.id);
                
                assets.add(asset1);
                assets.add(asset2);
                assets.add(asset3);
                assets.add(asset4);
                
                insert assets; 
                for(Integer i=0; i<=3; i++){
                   clist[i].cfcb_asset__c = assets[i].id;
                }
                update cList;
                
       Test.StartTest();
           Delete disabledTriggerCustomSetting;
          ar.relationship_CAP__c = 200;
          update ar;
           assets.clear();
          asset1.fulfillment_status__c = 'Fulfilled';
           assets.add(asset1);
           asset2.fulfillment_status__c = 'Fulfilled';
           assets.add(asset2);
           asset3.fulfillment_status__c = 'Fulfilled';
           assets.add(asset3);
           asset4.fulfillment_status__c = 'Fulfilled';
           assets.add(asset4);
           update assets;
           Asset asset6 = new Asset(Name = 'Asset6', PRODUCT2ID = PROD.ID, fulfillment_status__C = 'FULFILLED', Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active',price__c =250, extended_net_price__c =250,AccountId = agentAcc.id, UsageEndDate=date.Today());
          insert asset6;
          
          
       Test.stopTest();
            
    }
    
    private static testMethod void testCaseForLCM2() {  
          //creating test data 
           //Inserting Disabled custom setting
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
          Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
            agentAcc.Primary_Email__c = 'parentAcc@move.com';
            agentAcc.Type = 'Realtor Agent';
            agentAcc.Party_ID__c  = '12345';
            agentAcc.Customer_Id__c  = '12345';
            agentAcc.BillingPostalCode  = '12345';
            agentAcc.BillingCity = 'newyork';
            agentAcc.MLS_Set_Id__c  = '12345';    
        
            insert agentAcc;
            
            Account lenderAcc = TestDataFactory.createAccount('Agent Account', null, false);
            lenderAcc.Primary_Email__c = 'parentAcc@move.com';
            lenderAcc.Type = 'Lender Individual';
            lenderAcc.Party_ID__c  = '67890';
            lenderAcc.Customer_Id__c  = '67890';
            lenderAcc.BillingPostalCode  = '67890';
            lenderAcc.BillingCity = 'newyork';
            lenderAcc.MLS_Set_Id__c  = '67890';   
            lenderAcc.nmls_id__c = '12345'; 
            lenderAcc.Email_Address__c = 'test@test.com';
            insert lenderAcc;
            
              List<Contact> contacts= new List<Contact>();
            //Create Contacts
            Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
             //Create Contacts
            testContact = TestDataFactory.createContact('TestContact','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
            
            insert contacts;
            DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
          List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();

              Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

            Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(0).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(1).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            accountRelation.Total_comarketing_assets__c = 0;
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(2).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
                        accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(3).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
                    accountRelation.Initial_comarketer_spend_percent__c = 10;
            accountRelation.Total_comarketing_assets__c = 0;
            toBeInserted.add(accountRelation);
            insert toBeInserted;
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = agentAcc.Id;
            ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.comarketer_actual_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            ar.current_comarketer_spend_percent__c = 20;
            ar.Total_comarketing_assets__c = 10;
            ar.relationship_CAP__c = 80;
            insert ar;
            
             PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = lenderacc.id;
        pp.PaymentMethodId__c =  '44444444444444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        pp.Reason_Code__c = 'New Chip';
        pp.Recently_Added__c = true;

        insert pp;
            List<Comarketing_relationship__c> clist = new List<Comarketing_Relationship__c>();
            for(Integer i=0; i<=3;i++){
            comarketing_relationship__c c1 = new comarketing_relationship__c();
            c1.relationship__c = ar.id;
            c1.agent_account__c = agentAcc.id;
            c1.lender_account__c = lenderAcc.id;
            c1.Payment_Profile__c = pp.id;
            c1.status__c = 'Active';
            C1.Agent_Lender_Asset_Id__c = '12334'+i;
            c1.agent_zuora_comment__c = '';
            c1.lender_asset_monthly_contribution__c = 50;
            c1.agent_asset_monthly_contribution__c = 400;
            clist.add(c1);
            }
            insert cList;
            Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
            prod.ProductCode = 'COBROKE';   
            insert prod;
            
             //Inserting assets
                List<Asset> assets = new List<Asset>();

                Asset asset1 = new Asset(Name = 'Asset1', PRODUCT2ID = PROD.ID, Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active', price__c =250, extended_net_price__c =0,AccountId = agentAcc.id, UsageEndDate=date.Today());
                Asset asset2 = new Asset(Name = 'Asset2', PRODUCT2ID = PROD.ID, Asset_Type__c='Parent', line_type__c = 'Add', status = 'Cancelled',price__c =250, extended_net_price__c =250,AccountId = agentAcc.id);
                Asset asset3 = new Asset(Name = 'Asset3', PRODUCT2ID = PROD.ID, Asset_Type__c='Parent', line_type__c = 'Amend', status = 'Active',price__c =250, extended_net_price__c =250,AccountId = agentAcc.id);
                Asset asset4 = new Asset(Name = 'Asset4', PRODUCT2ID = PROD.ID, Asset_Type__c='Parent', line_type__c = 'Add', Category__c='BDX', status = 'Active',price__c =250, extended_net_price__c =250,AccountId = agentAcc.id);
                
                assets.add(asset1);
                assets.add(asset2);
                assets.add(asset3);
                assets.add(asset4);
                
                insert assets; 
              
                
       Test.StartTest();
       assetTriggerHandlerManager obj = new assettriggerHandlerManager();
           //obj.updateComarketingRelWhenAssetUpdates(newAssetMap,oldAssetMap);
       obj.getAssetsOfAccount(new Set<ID>{agentAcc.Id});
       assetTriggerHandlerManager.updateAccountInformation(new Set<ID>{agentAcc.Id}, false);
       assetTriggerHandlerManager.updateAccountInformation(new Set<ID>{agentAcc.Id}, true);
       Test.stopTest();
            
    }
    
    private static testMethod void testCaseForOpcity1() {  
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
        agentAcc.Primary_Email__c = 'parentAcc@move.com';
        agentAcc.Type = 'Realtor Agent';
        agentAcc.Party_ID__c  = '12345';
        agentAcc.Customer_Id__c  = '12345';
        agentAcc.BillingPostalCode  = '12345';
        agentAcc.BillingCity = 'newyork';
        agentAcc.MLS_Set_Id__c  = '12345';    
        insert agentAcc;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateProductSingle();
        Product2 prod = mtduc.CreateProductManualSingle();
        prod.ProductCode = 'OPCITYCORE';   
        update prod;
   
        Asset asset1 = new Asset(Fulfillment_Status__c='Waiting To Process', Name = 'Asset1', PRODUCT2ID = PROD.ID, Asset_Type__c='Parent', line_type__c = 'Add', status = 'Active', price__c =250, extended_net_price__c =0,AccountId = agentAcc.id);
        insert asset1;
        Asset asset2 = new Asset(Parent_Asset__c = asset1.Id,Fulfillment_Status__c='Manual', Name = 'Asset2', PRODUCT2ID = PROD.ID, Asset_Type__c='Fulfill To', line_type__c = 'Add', status = 'Active',price__c =250, extended_net_price__c =250,AccountId = agentAcc.id);
        insert asset2; 
        
        Test.StartTest();
        SkipAssetTrigger.skiptrigger=false;
        asset2.Fulfillment_Status__c = 'Fulfilled';
        update asset2;
        Test.stopTest();
            
    }
}