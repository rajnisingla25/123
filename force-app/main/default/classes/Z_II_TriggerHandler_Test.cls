/**
* Test class for the invoice item trigger handler.
* @author Waly K. Ndao (waly.ndao@zuora.com)
*/
@isTest(seealldata = false)
private class Z_II_TriggerHandler_Test {

    private static Zuora__ZInvoice__c zuoraInvoice;
    private static Zuora__Subscription__c zuoraSub;
    private static Zuora__SubscriptionProductCharge__c zuoraSubProdChrg;
    private static Account sfdcAccount;
    private static Zuora__CustomerAccount__c zuoraBillingAcc;
    private static zqu__ZProduct__c zuoraProduct;
    private static zqu__ProductRatePlan__c zuoraProdRatePlan;
    private static zqu__ProductRatePlanCharge__c zuoraProductRatePlanChrg;
    private static Asset asset;
    private static Invoice_Item__c invoiceItem;
    private static Invoice_Item_Adjustment__c invoiceItemAdj;


    private static void setupData() {
        //Inserting Customsetting for Subscription 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;

        //Create invoice
        createInvoice(); 

        //Create subscription
        createSubscription(); 
        createComarketing();

        //Create subscription product charge
        createSubProdCharg(); 
        
        //Create salesforce account
        createAccount(); 

        //Create zuora billing account
        createBillingAccount(sfdcAccount.Id);

        //Create product
        createProduct(); 

        //Create product rateplan
        createProdRatePlan(zuoraProduct.Id); 

        //Create product rateplan charge
        createProdRatePlanChrg(zuoraProdRatePlan.Id); 

        //Create asset
        createAsset(sfdcAccount.Id); 

        //Create invoice item
        createInvoiceItem(asset.id); 
    }

    /**
     * This is test method which tests the amendment of subscripiton by deleting Subscription Product Charge and Subscription and adding them againg.
     * It also checks after insert of Invoice Item Adjustment object
     */
    static testMethod void testSuccessPreview() {
        setupData();
        Test.startTest();
            // Simulate amendments and add them again
            delete zuoraSubProdChrg;
            delete zuoraSub;
            createSubscription();
            createSubProdCharg();
            createInvoiceItemAdj();
        Test.stopTest();
    }

    /**
     * This method creates Zuora Invoice Item Adjustment
     */
    private static void createInvoiceItemAdj() {
        invoiceItemAdj = new Invoice_Item_Adjustment__c();
        invoiceItemAdj.Invoice_Item_Zuora_Id__c = 'Test II Zuora Id';
        invoiceItemAdj.Amount__c = 5;

        try {
            insert invoiceItemAdj;
        } catch(Exception e){
            System.debug('Exception occured while inserting invoice item adjustment:' + e.getMessage());
        }
    }

    /**
     * This method creates Zuora Invoice Item
     */
    private static void createInvoiceItem(String assetId) {
        invoiceItem = new Invoice_Item__c();
        invoiceItem.RPC_Zuora_ID__c = 'Test Insert SPC';
        invoiceItem.Subscription_Zuora_ID__c = 'Test Insert Sub';
        invoiceItem.Invoice_Zuora_ID__c = 'Test Insert Inv';
        invoiceItem.Account_Zuora_ID__c = 'Test Insert Bacc';
        invoiceItem.Product_Zuora_ID__c = 'Test Insert Product';
        invoiceItem.PRP_Zuora_ID__c = 'Test Insert PRP';
        invoiceItem.PRPC_Zuora_ID__c = 'Test Insert PRPC';
        invoiceItem.Asset_In_Zuora__c = assetId;
        try {
            insert invoiceItem;
        } catch(exception e){
            System.debug('Exception occured while inserting invoice item:' + e.getMessage());
        }
    }

    /**
     * This method creates Salesforce Account
     */
    private static void createAccount() {
        sfdcAccount = new Account();
        sfdcAccount.Name = 'Test Account';
        sfdcAccount.BillingCity = 'Atlanta';
        sfdcAccount.BillingCountry = 'United States';
        sfdcAccount.BillingPostalCode = '30333';
        sfdcAccount.BillingState = 'Georgia';
        sfdcAccount.BillingStreet = '123 Main Street';
        sfdcAccount.Primary_Email__c = 'test@zuora.com.nobody';
        insert sfdcAccount;
    }

    /**
     * This method creates Zuora Invoice
     */
    private static void createInvoice() {
        zuoraInvoice = new Zuora__ZInvoice__c();
        zuoraInvoice.Zuora__Zuora_Id__c = 'Test Insert Inv';
        insert zuoraInvoice;
    }

    /**
     * This method creates Zuora Subscription
     */
    private static void createSubscription() {
        zuoraSub = new Zuora__Subscription__c();
        zuoraSub.Name = 'Test Insert Sub';
        insert zuoraSub;
    }

    /**
     * This method creates Zuora Subscription Product Charge
     */
    private static void createSubProdCharg() {
        zuoraSubProdChrg = new Zuora__SubscriptionProductCharge__c();
        zuoraSubProdChrg.Zuora__ChargeNumber__c = 'Test Insert SPC';
        insert zuoraSubProdChrg;
    }

    /**
     * This method creates Zuora Billing Account
     */
    private static void createBillingAccount(String accId) {
        zuoraBillingAcc = new Zuora__CustomerAccount__c();
        zuoraBillingAcc.Zuora__Account__c = accId;
        zuoraBillingAcc.Name = 'Test Billing Account';
        zuoraBillingAcc.Zuora__Zuora_Id__c = 'Test Insert Bacc';
        insert zuoraBillingAcc;
    }

    /**
     * This method creates Zuora Product
     */
    private static void createProduct() {
        zuoraProduct = new zqu__ZProduct__c();
        zuoraProduct.zqu__ZuoraId__c = 'Test Insert Product';
        zuoraProduct.zqu__SKU__c = 'Test Insert Product SKU';
        insert zuoraProduct;
    }

    /**
     * This method creates Zuora Product Rateplan
     */
    private static void createProdRatePlan(String prodId) {
        zuoraProdRatePlan = new zqu__ProductRatePlan__c();
        zuoraProdRatePlan.zqu__ZProduct__c = prodId;
        zuoraProdRatePlan.zqu__ZuoraId__c = 'Test Insert PRP';
        insert zuoraProdRatePlan;
    }

    /**
     * This method creates Zuora Prodcut Rateplan Charge
     */
    private static void createProdRatePlanChrg(String prpId) {
        zuoraProductRatePlanChrg = new zqu__ProductRatePlanCharge__c();
        zuoraProductRatePlanChrg.zqu__ProductRatePlan__c = prpId;
        zuoraProductRatePlanChrg.zqu__ZuoraId__c = 'Test Insert PRPC';
        insert zuoraProductRatePlanChrg;
    }

    /**
     * This method creates Asset
     */
    private static void createAsset(String accId) {
        asset = new Asset();
        asset.name = 'Test Asset';
        asset.AccountId = accId;
        insert asset;
    }
    
    /**
     * This method creates Comarketing relationship
     */
    public static void createComarketing() {
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
        
        //creating account for agent and lender with type as real estate agent and lender
        // Inserting account records.
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
        lenderAcc.nmls_Id__c = '12355';
        
        insert lenderAcc;
       
        Product2 prd = new Product2();
        prd.name = 'Test Product';
        prd.productCode = 'COBROKE';
        Insert prd;
        
        Integer COUNTER = 1;
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,
                AccountId = agentAcc.Id,
                Asset_Type__c='Parent',
                Get_CP_Login_Status__c = 'Ready',
                Fulfillment_Status__c = 'Fulfilled',
                Status = 'Active',
                Product2Id = prd.id,
                price__c = 400
            ));
        }
        insert theTestAssets;       
        
        //creating contacts
        
        List<Contact> contacts= new List<Contact>();
        //Create Contacts
        Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
        testContact.Email = 'testContact@move.com';
        testContact.Type__c = 'Billing';
        contacts.add(testContact);
        
        insert contacts;
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.parent_account__c = agentAcc.Id;
        ar.child_account__c = lenderAcc.id;
        ar.relationship_type__c = 'Partner';
        ar.comarketing_status__c= 'Active';
        ar.comarketer_spend__c = 100;
        ar.total_connections_price__c = 5000;
        ar.total_relationship_assets_price__c = 5000;
        ar.comarketer_actual_spend__c = 100;
        ar.Initial_comarketer_spend_percent__c = 10;
        ar.Parent_account_email__c='agenttest123458@abc.com';
        ar.Child_account_email__c = 'lendertest123458@abc.com';
        insert ar;
        comarketing_relationship__c c = new comarketing_relationship__c();
            c.relationship__c = ar.id;
            insert c;
        ApexPages.currentPage().getParameters().put('rId', ar.id);
        ApexPages.currentPage().getParameters().put('accountType', 'Agent');
        ApexPages.currentPage().getParameters().put('id', String.valueOf(agentAcc.Id));
        comarketingAccountCtrl cr = new comarketingAccountCtrl();
        
        cr.add();
        comarketingDetailsCtrl crd = new comarketingDetailsCtrl();
        
        crd.partyId = '67890';
        crd.comarketerSpend = '100';
        crd.relationshipCAP = '2000';
        crd.selectedAssetsPrice = 5000;
        crd.assetPrice = 5000;
        crd.comarketingSpendPercent = 10;
        
        crd.onChangeLenderSpendMax();
        crd.activate();
        ar.Comarketing_Status__c = 'Active';
        update ar;
        List<Comarketing_Relationship__c> clist = [Select id, status__c from Comarketing_Relationship__c limit 5];
        system.debug('cr---'+clist);
        clist[0].action__c = 'amend';
        clist[0].Agent_Asset_Monthly_Contribution__c = 10;
        update clist[0];
        Comarketing_Relationship__History cch = new Comarketing_Relationship__History();
        cch.parentid = clist[0].id;
        cch.field = 'Agent_Asset_Monthly_Contribution__c';
        insert cch;
    }

}