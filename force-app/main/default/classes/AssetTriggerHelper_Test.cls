@isTest(seealldata = false)
public class AssetTriggerHelper_Test {

    static Account objAcc;
    static List<Account> testAccList;
    static Contract theContact;
    static List < Product2 > productList;
    static List < Asset > assetList;
    static Asset testAsset;
    static List < Order > orders;
    static List < OrderItem > orderItems;
    static DisabledTrigger__c Dtrg;
    static List < PricebookEntry > pdPbeList;
    static Opportunity opp;
    static MLS__c mls;
    static list<Account_Relationship__c> listRelationShip;
    static list<AccountTeamMember> memberList;

    static {
        createTestData();
    }

    static void createTestData() {
        OrderDecompController.stopCreatingAccount = true;
        // insert disabled trigger and assert it
        Dtrg = new DisabledTrigger__c(Name = 'Disabled', TaskTrigger__c = 'Test@test.com', AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c c= new Collection_Users__c(Name = 'batchintegration user', Id__c= '005j000000CdBiEAAV');
        insert c;
        CaseRecordTypes__c cr = new CaseRecordTypes__c(Name = 'Retention');
        insert cr;
        System.assertNotEquals(null, Dtrg.Id);

        // insert account and assert it
        objAcc = TestDataFactory.createAccount('The Test Account', null, false);
        objAcc.Primary_Email__c = 'testEmail1@test.com';
        objAcc.Type = 'Broker';
        objAcc.Do_Not_Call__c = false;
        insert objAcc;
        System.assertNotEquals(null, objAcc.Id);

        testAccList = new list<Account>();

        testAccList.add(new Account( Name='Broker Council',Primary_Email__c = 'testEmail1@test.com',Type = 'Broker Council',
                                            Do_Not_Call__c = false ));
        testAccList.add(new Account( Name='Broker Council',Primary_Email__c = 'testEmail1@test.com',Type = 'Realtor Agent',
                                            Do_Not_Call__c = false ));        
        insert testAccList;
        for(Account acc : testAccList){
            System.assertNotEquals(null, acc.Id);
        } 

        // insert account team members and assert it
        memberList = new list<AccountTeamMember>();
        memberList.add(new AccountTeamMember(TeamMemberRole = 'Account Manager', AccountId=objAcc.Id, UserId=userInfo.getUserId()));
        for(Account acc : testAccList){
            memberList.add(new AccountTeamMember(TeamMemberRole = 'Account Manager', AccountId=acc.Id, UserId=userInfo.getUserId() ));
        } 
        insert memberList;
        for(AccountTeamMember member : memberList){
            System.assertNotEquals(null, member.Id);
        }  

        // insert MLS and assert it
        mls = new MLS__c(Name='Test MLS ', Office__c = objAcc.Id, Status__c = 'Active', MLS__c = objAcc.Id);
        insert mls;
        System.assertNotEquals(null, mls.Id);

        // insert account relationship objects and assert it
        listRelationShip = new list<Account_Relationship__c>();
        listRelationShip.add(new Account_Relationship__c( Child_Account__c = testAccList[1].Id, Parent_Account__c=objAcc.Id));
        insert listRelationShip;
        for(Account_Relationship__c relationship : listRelationShip){
            System.assertNotEquals(null, relationship.Id);
        }

        // insert opportunity and assert it
        opp = new Opportunity(Name = 'Test Opp ', AccountId = objAcc.Id, Pricebook2Id = Test.getStandardPricebookId(), 
                                StageName = 'Closed-Won', CloseDate = Date.today() ); 
        insert opp;                                   
        System.assertNotEquals(null, opp.Id);

        // insert products and assert it
        productList = new list < Product2 > ();
        productList.add(new Product2(Name = 'H00-062', Family = 'Professional Development', ProductCode = 'TOPCRM', S_No__c = 1));
        productList.add(new Product2(Name = 'H00-062', Family = 'SHOWCASE', ProductCode = 'SHOWCASE', S_No__c = 1));
        insert productList;
        for (Product2 prod: productList) {
            System.assertNotEquals(null, prod.Id);
        }

        // insert pricebook entry list and assert it
        pdPbeList = new list < PricebookEntry > ();
        pdPbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productList[0].Id, UnitPrice = 1000,
            IsActive = true));
        pdPbeList.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productList[1].Id, UnitPrice = 1100,
            IsActive = true));
        insert pdPbeList;
        for (PricebookEntry pbe: pdPbeList) {
            System.assertNotEquals(null, pbe.Id);
        }

        // insert order object and assert it
        orders = new List < Order > ();
        orders.add(new Order(AccountId = objAcc.id, Fulfillment_Status__c = 'Pending Fulfillment', Status = 'Created', Type = 'New',
            Pricebook2Id = Test.getStandardPricebookId(), EffectiveDate = System.today(),
            EndDate = system.today().addDays(100)));

        orders.add(new Order(AccountId = objAcc.id, Fulfillment_Status__c = 'Fulfilled', Status = 'Created', Type = 'New',
            Pricebook2Id = Test.getStandardPricebookId(), EffectiveDate = System.today(),
            EndDate = system.today().addDays(100), OpportunityId = opp.Id));

        insert orders;
        for (Order order: orders) {
            System.assertNotEquals(null, order.Id);
        }

        // insert order items objects and assert the behavior
        orderItems = new List < OrderItem > ();
        orderItems.add(new OrderItem(UnitPrice = 789.62, Quantity = 6, OrderId = orders[1].Id, Auto_Renewal__c = 'Yes', Line_Type__c = 'Add',
            Fulfillment_Status__c = 'Pending Fulfillment', PricebookEntryId = pdPbeList[0].Id,
            End_Date__c = System.today(), Suppress_Welcome_Calls__c = false, Part_number__c = 'Cobroke1'));
        orderItems.add(new OrderItem(UnitPrice = 789.62, Quantity = 6, OrderId = orders[0].Id, Auto_Renewal__c = 'Yes', Line_Type__c = 'Add',
            Fulfillment_Status__c = 'Fulfilled', PricebookEntryId = pdPbeList[0].Id, End_Date__c = System.today(), 
                            Suppress_Welcome_Calls__c = false, Part_number__c = 'Cobroke1'));

        insert orderItems;
        for (OrderItem item: orderItems) {
            System.assertNotEquals(null, item.Id);
        }

        // insert contract and assert it
        theContact = new Contract();
        theContact.AccountId = objAcc.id;
        insert theContact;
        System.assertNotEquals(null, theContact.Id);

        // insert Assets and assert the behavior
        assetList = new list < Asset > ();
        assetList.add(new Asset(Name = 'Test Asset1', Fulfillment_Status__c = 'Active', AccountId = objAcc.id, 
                            Order_Line_Item__c = orderItems[0].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false, Asset_Type__c ='Parent', Mls_Set__c = mls.Id,
                            Product_Type__c='Showcase', Contract__c = theContact.Id)); 
        assetList.add(new Asset(Name = 'Test Asset2', Fulfillment_Status__c = 'Failure', AccountId = objAcc.id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Participant', Mls_Set__c = mls.Id
                            ,Product_Type__c='Showcase', Contract__c = theContact.Id));
        assetList.add(new Asset(Name = 'Test Asset3', Fulfillment_Status__c = 'Fulfilled', AccountId = objAcc.id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Parent', Mls_Set__c = mls.Id
                            ,Product_Type__c='Showcase', Contract__c = theContact.Id));
        assetList.add(new Asset(Name = 'Test Asset4', Fulfillment_Status__c = 'Fulfilled', AccountId = testAccList[1].id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Parent', Mls_Set__c = mls.Id,
                            Product_Type__c='Showcase', Contract__c = theContact.Id));
        assetList.add(new Asset(Name = 'Test Asset5', Fulfillment_Status__c = 'Pending Fulfillment', AccountId = objAcc.id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Participant', Mls_Set__c = mls.Id,
                            Product_Type__c='Showcase', Contract__c = theContact.Id));
        assetList.add(new Asset(Name = 'Test Asset6', Fulfillment_Status__c = 'Pending Fulfillment', AccountId = testAccList[1].id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Participant', Mls_Set__c = mls.Id,
                            Product_Type__c='Showcase', Contract__c = theContact.Id)); 
        assetList.add(new Asset(Name = 'Test Asset7', Fulfillment_Status__c = 'Active', AccountId = objAcc.id, 
                            Order_Line_Item__c = orderItems[1].id, Product2ID = productList[1].ID, Status='Active',
                            Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false,Asset_Type__c ='Participant', Mls_Set__c = mls.Id
                            ,Product_Type__c='Showcase', Contract__c = theContact.Id));                                                                                                                                               
        insert assetList;
        for (Asset asset: assetList) {
            System.assertNotEquals(null, asset.Id);
        }


    }

    static testMethod void testAssetTriggerHelperFunctionality() {
        Test.startTest(); 
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name = 'Set Overall Trigger Off', Set_Overall_Trigger_Off__c = True);
        insert arc;
        AssetTriggerHelper ath = new AssetTriggerHelper();
        List < Asset > assets = new List < Asset > ();
        Set < Id > setAssetIds = new Set < id > ();
        Map < Id, Asset > MapAssetIds = new Map < Id, Asset > ();
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        //ProductExclusionTrigger
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateRealtorOfficeAccountSingle();
        mtduc.CreateRealtorAgentAccountSingle();
        mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        mtduc.CreateRealtorAgentAccountRelationshipSingle();
        mtduc.CreateProductSingle();
        mtduc.CreateFullfilledAssetSingle();
        mtduc.CreateFulfilltoFullfilledAssetSingle();
        mtduc.CreateParticipantFulfilltoFullfilledAssetSingle();
        assets.add(mtduc.assets);
        setAssetIds.add(mtduc.assets.id);
        MapAssetIds.put(mtduc.assets.id, mtduc.assets);
        MapAssetIds.put(mtduc.fulfillassets.id, mtduc.fulfillassets);
        MapAssetIds.put(mtduc.participantfulfillassets.id, mtduc.participantfulfillassets);
        ath.createCaseWhenNeeded(assets, false);
        ath.ExpiredRelatedAssets(MapAssetIds);
        ath.GenerateJsonStrings(MapAssetIds);

        ath.CreateBackoutQuoteForAgentParticipants(MapAssetIds.keyset());
        ath.CancelOrderLineUponAssetQuantityModification(MapAssetIds, MapAssetIds);
        AssetTriggerHelper.TriggerUpdateAsset(MapAssetIds.keyset());
        mtduc.CreatefailureFullfilledAssetSingle();
        ath.CreateSupportCaseWhenFulfillmentFailed(MapAssetIds, MapAssetIds);
        ath.sendAssetNotification(MapAssetIds.values());
        ath.ProcessBackout(setAssetIds);
        //ath.Assertcasemanagement(assets,MapAssetIds,MapAssetIds);
        Test.stopTest();
    }

    static testmethod void AssetUpdate() {
        Test.startTest();
        Asset objAsset = new Asset();
        objAsset.Name = 'Test Asset';
        objAsset.Fulfillment_Status__c = 'Active';
        objAsset.AccountId = objAcc.id;
        objAsset.Order_Line_Item__c = orderItems[1].id;
        objAsset.Product2ID = productList[0].Id;
        objAsset.Line_Type__c = 'Test';
        objAsset.Suppress_Welcome_Calls__c = false;
        insert objAsset;

        List < Asset > selectedAssets = new List < Asset > ();
        Map < Id, Asset > oldMapAssetIds = new Map < Id, Asset > ();
        Map < Id, Asset > newMapAssetIds = new Map < Id, Asset > ();
        Id standardPriceBookId = Test.getStandardPricebookId();
        List < Product2 > product2List = new List < Product2 > ();

        selectedAssets.add(objAsset);
        oldMapAssetIds.put(objAsset.Id, objAsset);
        objAsset.Fulfillment_Status__c = 'Fulfilled';
        objAsset.Order_Line_Item__c = orderItems[0].id;
        update objAsset;
        selectedAssets.add(objAsset);
        newMapAssetIds.put(objAsset.Id, objAsset);
        AssetTriggerHelper ath = new AssetTriggerHelper();
        //ath.Assertcasemanagement(selectedAssets ,newMapAssetIds,oldMapAssetIds);
        ath.createCaseWhenNeeded(selectedAssets, false);
        Test.stopTest();
    }

    static testMethod void testAssetTriggerHelperFunctionality2() {
        Test.startTest();
        system.debug('2nd method entry');
        Integer COUNTER = 3;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name = 'Set Overall Trigger Off', Set_Overall_Trigger_Off__c = True);
        insert arc;

        Map < Id, Asset > mapoldAssets = new Map < Id, Asset > ();
        Map < Id, Asset > mapnewAssets = new Map < Id, Asset > ();
        // Inserting Assets.
        Asset asst1 = new Asset();
        asst1.Name = 'Test Asset - ';
        asst1.AccountId = objAcc.Id;
        asst1.Contract__c = theContact.Id;
        asst1.Status = 'Active';
        asst1.Product2ID = productList[1].ID;
        asst1.Line_Type__c = 'Renew';
        asst1.Asset_Type__c = 'Parent';
        asst1.Fulfillment_Status__c = 'pending Fulfillment';
        asst1.Product_Type__c = 'Showcase';
        asst1.Order_Line_Item__c = orderItems[0].id;
        asst1.Quantity = 15;
        insert asst1;
        System.debug('asst1.Id ' + asst1.Id);
        Asset assetInserted = [select Id, Name, AccountId, Contract__c, Status, Product2ID, Line_Type__c, Asset_Type__c, Fulfillment_Status__c,TP_Products_Agents__c,
            Product_Type__c, Order_Line_Item__c, Quantity From Asset where Id =: asst1.Id
        ];
        System.assertEquals(15, assetInserted.Quantity);

        // insert another asset where Ultimate_Parent_Id_Text__c is populated.
        Asset asst = new Asset();
        asst.Name = 'Test Asset Name 2';
        asst.Ultimate_Parent_Id_Text__c = asst1.Id;
        asst.AccountId = objAcc.Id;
        asst.Asset_Type__c = 'Participant';
        asst.Status = 'Active';
        asst.Line_Type__c = 'Add';
        asst.Product2Id = productList[1].Id;
        insert asst;
        System.assertNotEquals(null, asst.Id);
        AssetTriggerHelper helper = new AssetTriggerHelper();
        helper.ProcessBackout(new set < Id > {
            asst1.Id
        });

        mapoldAssets.put(asst1.Id, asst1);
        assetInserted.Order_Line_Item__c = orderItems[0].id;
        assetInserted.Fulfillment_Status__c = 'Fulfillment';
        //asst1.RDC_Products_Agents__c = 1;
        assetInserted.Quantity = 10;
        update assetInserted;
        Asset updatedAsset = [select id, Quantity from Asset where Id =: assetInserted.Id];
        System.assertEquals(10, updatedAsset.Quantity);
        mapnewAssets.put(assetInserted.Id, assetInserted);
        orderItems[0].Asset__c = assetInserted.Id;
        update OrderItems;
        AssetTriggerHelper helper2 = new AssetTriggerHelper();
        helper2.CancelOrderLineUponAssetQuantityModification(mapoldAssets, mapnewAssets);
        Map < Id, Asset > mapoldAssets2 = new Map < Id, Asset > ();
        Map < Id, Asset > mapnewAssets2 = new Map < Id, Asset > ();
        Asset asset2 = [select Id, Name, AccountId, Contract__c, Status, Product2ID, Line_Type__c, Asset_Type__c, Fulfillment_Status__c,
            Product_Type__c, Order_Line_Item__c, Quantity From Asset where Id =: asst1.Id
        ];
        asset2.Fulfillment_Status__c = 'Not Active';
        update asset2;
        mapoldAssets2.put(asset2.Id, asset2);
        assetInserted.Fulfillment_Status__c = 'Active';
        assetInserted.Line_Type__c = 'Renew';
        assetInserted.Fulfillment_Status__c = 'Fulfillment';
        assetInserted.Asset_Type__c ='Parent';
        mapnewAssets2.put(assetInserted.Id, assetInserted);
        helper.CreateSupportCaseWhenFulfillmentFailed(mapoldAssets2, mapnewAssets2);
        Set < Id > setAssetIds = new Set < Id > ();
        setAssetIds.add(asst1.Id);
        list < Asset > triggerNew = new list < Asset > ();
        AssetTriggerHelper ath = new AssetTriggerHelper();
        ath.CreateBackoutQuoteForAgentParticipants(setAssetIds);
        ath.ProcessBackout(setAssetIds);
        ath.CreateSupportCaseWhenFulfillmentFailed(mapoldAssets, mapnewAssets);
        Test.stopTest();
    }

    static testmethod void testCreateSupportCaseWhenFulfillmentFailed(){
        // update already inserted assets so that it will execute the method CreateSupportCaseWhenFulfillmentFailed in the trigger.
        Test.startTest();
        system.debug('before fullfill test ');
        SkipAssetTrigger.skiptrigger = false;
        update assetList;
        Test.stopTest();
    }

    static testmethod void testFillingAccountmanager(){
        Test.startTest();
        SkipAssetTrigger.skiptrigger = false;
        AssetTriggerHelper helper = new AssetTriggerHelper();
        map<id,AccountTeamMember> member = helper.FillingAccountmanager(new set<Id>{objAcc.Id});
        Test.stopTest();
    }

    static testmethod void testAssetUpdate2(){
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        test.startTest();
        SkipAssetTrigger.skiptrigger = false;
        SkipBackoutAssetTrigger.skiptrigger = false;
        system.debug('before asset update test ');
        for(Asset asset : assetList){
            asset.Ultimate_Parent_Id_Text__c = assetList[0].Id;
            asset.Fulfillment_Status__c = 'Fulfilled';
            asset.Follow_Up_Status__c = 'test';
        }
        Product2 p = new Product2(Name = 'Respond', Family = 'Realsuite', ProductCode = 'RSRESPOND', S_No__c = 1);
        insert p;
        assetList[0].product2Id = p.Id;
        assetList[0].Status = 'Cancelled';
        assetList[0].Trial__c = true;
        update assetList;
        
        test.stopTest();
    }
    
    
    static testmethod void testmethodNew(){
        test.startTest();
        AssetTriggerHandler h = new AssetTriggerHandler();
        Boolean b = h.IsTriggerContext;
        b = h.isVisualForcePageContext;
        b = h.IsWebServiceContext;
        b = h.IsExecuteAnonymousContext;
        SkipAssetTrigger.skiptrigger = false;
        SkipBackoutAssetTrigger.skiptrigger = false;
        system.debug('before asset update test ');
        for(Asset asset : assetList){
            asset.Ultimate_Parent_Id_Text__c = assetList[0].Id;
            asset.Fulfillment_Status__c = 'Fulfilled';
            asset.Category__c= 'BDX';
        }
        update assetList;

        test.stopTest();
    }
        /* static testMethod void AssetTriggerHandler_Test1(){
         Account testAccount = new account();
         testaccount.name ='test';
         insert testAccount;          
         
         Asset asset1 = new Asset(Name = 'Asset1', status = 'Cancelled', AccountId = testAccount.id,UsageEndDate=date.Today());
         
         List<Asset> assets = new List<Asset>();
         assets.add(asset1);         
         AssetTriggerHandlerManager ath=new AssetTriggerHandlerManager();
            ath.CreateCaseWhenAssetExpires(assets);
     } */
}