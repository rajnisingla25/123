@IsTest
Public class Z_S_TriggerHandler_Test {

    private static Account sfdcAccount;
    private static Asset asset;
    private static List<Zuora__Subscription__c> zuoraSubList;
    private static Zuora__Subscription__c zuoraSub;
    private static Zuora__ZInvoice__c zuoraInvoice;
    private static Invoice_Item__c zuoraInvItem;
    private static Zuora__SubscriptionProductCharge__c zuoraSubProdChrg;
    private static zqu__ProductRatePlanCharge__c zuoraProdRatePlanChrg; 

    private static void setupData() {
        //Inserting Customsetting for Account  
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
            
        //Create account
        createAccount(); 
        
        //Create asset
        createAsset(sfdcAccount.Id); 
        
        //Create subscripiton
        createSubscription(sfdcAccount.Id, asset.Id); 
        
        //Create invoice
        createInvoice(sfdcAccount.Id); 
        
        //Create invoice item
        createInvoiceItem(zuoraInvoice.Id, zuoraSub.Id, zuoraSub.Name); 
        
        //Create subscription product charge
        createSubProdChrg(zuoraSub.Id, sfdcAccount.Id); 
        
        //Create product rateplan charge
        createProdRatePlanChrg(); 
    }

    /**
     * This method creates Asset
     */
    private static void createAsset(String sfdcAccountId) {
        asset = new Asset();
        asset.Name = 'Z_Stest';
        asset.Asset_Type__c = 'Parent';
        asset.AccountId = sfdcAccountId;
        asset.status = 'active';
        asset.Start_Date__c = system.today();
        asset.End_Date__c = system.today().addDays(10);   
        asset.Line_Type__c = 'Add'; 
        asset.Record_Processed_for_commission__c= true ; 
        insert asset; 
    }

    /**
     * This method creates Salesforce Account
     */
    private static void createAccount() {
        sfdcAccount = TestDataFactory.createAccount('The Test Account', null, false);
        sfdcAccount.Primary_Email__c = 'theAcc@move.com';
        sfdcAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        insert sfdcAccount;
    }

    /**
     * This method creates Zuora Subscription
     */
    private static void createSubscription(String sfdcAccountId, String assetId) {
        zuoraSubList = new List<Zuora__Subscription__c>();
        zuoraSub = new Zuora__Subscription__c();
        zuoraSub.Name = 'Test';
        zuoraSub.Zuora__Account__c = sfdcAccountId;
        zuoraSub.Zuora__SubscriptionStartDate__c = system.Today(); 
        zuoraSub.Zuora__SubscriptionEndDate__c = system.Today();  
        zuoraSub.Zuora__NextRenewalDate__c  = system.Today();  
        zuoraSub.Zuora__TermStartDate__c = system.today().addDays(2);
        zuoraSub.Zuora__TermEndDate__c = system.today().addDays(9);
        zuoraSub.Asset__c = assetId; 
        zuoraSub.AssetID__c = assetId;
        insert zuoraSub;
        zuoraSubList.add(zuoraSub);
    }

    /**
     * This method creates Zuora Invoice
     */
    private static void createInvoice(String sfdcAccountId) {
        zuoraInvoice = new Zuora__ZInvoice__c();
        zuoraInvoice.Name = 'TestInv';
        zuoraInvoice.Zuora__Status__c = 'Past Due';
        zuoraInvoice.Zuora__Account__c = sfdcAccountId;
        insert zuoraInvoice; 
    }

    /**
     * This method creates Zuora Invoice Item
     */
    private static void createInvoiceItem(String invoiceId, String subId, String subName) {
        zuoraInvItem = new Invoice_Item__c();
        zuoraInvItem.Name = 'Test';
        zuoraInvItem.Invoice__c = invoiceId;
        zuoraInvItem.Subscription__c = subId;
        zuoraInvItem.Subscription_Zuora_ID__c = subName;
        insert zuoraInvItem;
    }

    /**
     * This method creates Zuora Subscription Product Charge
     */
    private static void createSubProdChrg(String subId, String sfdcAccountId) {
        zuoraSubProdChrg = new Zuora__SubscriptionProductCharge__c();
        zuoraSubProdChrg.Name = 'New Component';
        zuoraSubProdChrg.Zuora__Zuora_Id__c = '2c92c0f94e4d3a3f014e6ee2e77c5436';
        zuoraSubProdChrg.Zuora__Subscription__c = subId;
        zuoraSubProdChrg.Zuora__Account__c = sfdcAccountId;
        zuoraSubProdChrg.Zuora__Type__c = 'Recurring';
        zuoraSubProdChrg.Zuora__RatePlanName__c = 'Connection(SM) for Co-Brokerage: Payment Based';
        insert zuoraSubProdChrg;
    }

    /**
     * This method creates Zuora Product Rateplan Charge
     */
    private static void createProdRatePlanChrg() {
        zuoraProdRatePlanChrg = new zqu__ProductRatePlanCharge__c();
        zuoraProdRatePlanChrg.Name = 'Connection(SM) for Co-Brokerage: Payment Based';
        zuoraProdRatePlanChrg.zqu__ZuoraId__c = '2c92c0f84d94c58f014d9bb60cdd76bf';
        insert zuoraProdRatePlanChrg;
    }

    /**
     * This is test method which tests
     * 1) After insert of subscription object
     * 2) After Update of Asset object with Subscription information
     */
    static TestMethod Void testSuccessPreview() {
        setupData();
        Test.startTest();
            Z_S_TriggerHandler handler = new Z_S_TriggerHandler();
            handler.onAfterInsert(zuoraSubList);
            handler.updateAssetSubscriptionIds(zuoraSubList);
        Test.stopTest();
    }
}