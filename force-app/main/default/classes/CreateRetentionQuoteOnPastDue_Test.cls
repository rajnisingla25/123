@isTest
public class CreateRetentionQuoteOnPastDue_Test {
    static testMethod void CreateRetentionQuote_Test() {
        //Inserting Customsetting for Account 
        Integer COUNTER = 1;
        Map < Id, String > AssetIdMap = new Map < Id, String > ();
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name = 'Disabled', TaskTrigger__c = 'Test@test.com', AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        List < Account > theAccounts = new List < Account > ();
        List < string > accountIds = new List < string > ();
        for (Integer index = 0; index < COUNTER; index++) {
            theAccounts.add(new Account(
                name = 'XYZ',
                Past_Due__c = TRUE,
                Type = 'Broker',
                Account_Sub_Type__c = 'Customer'
            ));
        }
        insert theAccounts;

        Contact testContact = TestDataFactory.createContact('Test Contact', 'TestL', theAccounts[0].Id, true, false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        Opportunity theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Prospecting';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = theAccounts[0].id;
        theOpportunity.Opportunity_Short_Description__c = 'Retention';
        theOpportunity.Amount = 0.00;
        insert theOpportunity;
        Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case;
        Map < String, Schema.RecordTypeInfo > CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName();
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention', Record_Type_Id__c = rtnId);
        insert setting;

        //Inserting Test Case       
        Case testCase1 = TestDataFactory.createCase('Invalid Rights', 'pending Cancel', 'Collections', 'Test Description', testContact.Id, theAccounts[0].Id, true);
        Case testCase = new Case(
            Subject ='Invalid Rights123',
            Status = 'Pending Cancel',
            //Type = 'Collections',
            Description = 'Test Description');
            testCase.AccountId = theAccounts[0].Id;
            testCase.ContactId =  testContact.Id;
            insert testCase;
            
        // Inserting Test Product.
        Product2 theTestProduct = new Product2(
            Name = 'Connection(SM) for Co-Brokerage',
            Family = 'Hardware',
            S_No__c = 2,
            ProductCode = 'TURBO'
        );

        insert theTestProduct;

        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProduct.Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;
        insert thePricebookEntrie;
        COUNTER=10;
        // Inserting Test Orders.
        List < Order > orders = new List < order > ();
        for (Account acc: theAccounts) {
            Orders.add(new Order(
                EffectiveDate = System.today(),
                AccountId = acc.Id,
                Status = 'Created',
                Fulfillment_Status__c = 'Fulfilled',
                Pricebook2Id = thePricebookEntrie.Pricebook2Id));
        }
        insert orders;
        
        List < OrderItem > oitem = new list < OrderItem > ();
        for (Integer index = 0; index < COUNTER; index++) {
            oitem.add(new OrderItem(
                Quantity = 1.0,
                PricebookEntryId = thePricebookEntrie.id,
                OrderId = orders[0].Id,
                Fulfillment_Status__c = 'Fulfilled',
                Credit_Amount__c = 10.00,
                Line_Type__c = 'Renew',
                UnitPrice = 100
            ));
        }

        insert oitem;
        
        // Inserting Test Asset. 
        List < Asset > Assets = new List < Asset > ();
        for (Integer index = 0; index < COUNTER; index++) {
            Assets.add(new Asset(
                Name = 'Test Asset123 - ',
                AccountId = theAccounts[0].Id,
                End_Date__c = Date.today().addDays(-2),
                Status = 'Active',
                Product2ID = theTestProduct.Id,
                Line_Type__c = 'Add',
                Asset_Type__c = 'Parent',
                Fulfillment_Status__c = 'Fulfilled',
                start_date__c = Date.today().addDays(-182),
                Credit_Status__c = '',
                Product_Email__C = 'srini@move.com',
                Inflight_Quote__c = '',
                CampaignId__c = '12345',
                Quantity = 1,
                Order_Line_Item__c = oitem[index].Id,
                Renewal_Order_Product__c = oitem[index].Id,
                Renewal_Start_Date__c = Date.today().addDays(-1)));
        }
        Insert Assets;
        
        list<BigMachines__Quote__c> bmqListids = new list<BigMachines__Quote__c>();
        list<BigMachines__Quote__c> updatebmqListids = new list<BigMachines__Quote__c>();
        BigMachines__Quote__c quoteret = new BigMachines__Quote__c();
        quoteret.BigMachines__Account__c = theAccounts[0].Id;        
        quoteret.BigMachines__Status__c = 'In Progress';
        quoteret.BigMachines_Quote_Type__c = 'Retention';
        quoteret.Current_User_Action__c = 'Save';
        quoteret.Quote_Submitted__c=false;
        quoteret.Name = '2025-201345';
        quoteret.case__c = testCase1.id;
        bmqListids.add(quoteret);
        system.debug('%%%%%%%%'+Schema.SObjectType.BigMachines__Quote__c.fields.case__c.isAccessible());
        insert bmqListids;
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = bmqListids[0].Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = theTestProduct.Id; 
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        bquoteAddModify.DocumentNumber__c               = 2;
        bquoteAddModify.Start_Date__c                   = System.today().addDays(6);
        bquoteAddModify.Asset_Structure__c = '{ "parent": [ {"Type": "new", "SoldToaccountId": "' + theAccounts[0].Id + '", "assetId": "' + Assets[0].id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "new", "assetId": "' + Assets[0].id + '", "FulfillToaccountId": "' + theAccounts[0].id + '", "participant" : [ { "Type": "Retention", "participantaccountId": "' + theAccounts[0].id + '", "assetId": "' + Assets[0].id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        insert bquoteAddModify;
        
        AssetIdMap.put(Assets[0].id, 'cancel##nonPayment');
        Set<Id> bIds = new Set<Id>();
        for (BigMachines__Quote__c q: bmqListids) {
            bIds.add(q.Id);
        }
        Test.startTest();
        CreateRetentionQuoteOnPastDue.submitQuote(bIds); 
        CreateRetentionQuoteOnPastDue.CreateRetentionQuote(testCase.Id);
        CreateRetentionQuoteOnPastDue.reDirectParamsToCPQ(theAccounts[0].Id, theOpportunity.Id, testCase.Id, 'Retention', 'Cancel', AssetIdMap);
        Test.stopTest();
    }
}