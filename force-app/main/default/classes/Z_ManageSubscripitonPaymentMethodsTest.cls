@IsTest(seeAllData=true)
public class Z_ManageSubscripitonPaymentMethodsTest {
    
    
    @isTest static void test_method_one() {
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');  
        Dtrg.AssetTrigger__c = UserInfo.getUserName();
        update Dtrg;
        Account Acc = makeAccount();
        Product2 Product = makepruduct();
        BigMachines__Quote__c BMQ = makeBMQuote(Acc.id);
        BigMachines__Quote_Product__c BMQP = Makequoteproduct(BMQ.Id, Product.id);
        Zuora__CustomerAccount__c ZuoraAccount=  makeBillingAccount(Acc);
        PaymentProfiles__c pp = makeccPaymentProfile(Acc);
        Asset Asst = makeAsset(Acc.Id, Product.Id, pp.Id);
        List<Zuora__Subscription__c>  Subs = makeSubscription(Acc.Id, Asst.Id);
        Account agentAcc = makeAccount2('Realtor Agent');
        Account LenderAcc = makeAccount2('Lender Individual');
         PaymentProfiles__c pp2 = makeccPaymentProfile(LenderAcc);
        Account_Relationship__c relation = Makerelation(agentAcc.id, LenderAcc.id);
        List<comarketing_relationship__c> CM = makeComarkeing(agentAcc, LenderAcc, Asst);
       CM[0].payment_profile__c = pp2.Id;
        update CM;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageSubscriptionPaymentmethods'));
        System.currentPageReference().getParameters().put('id', BMQ.id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(subs);
        stdSetController.setSelected(Subs);
        
        Z_ManageSubscripitonPaymentMethods cont = new Z_ManageSubscripitonPaymentMethods();
        cont.rowIndex2 = 0;
        cont.size = 50;
        cont.LenderPage =false;
        cont.SelectAll = true;
        cont.init();
        //ext.Selectall = true;
        cont.orderByColumn = 'Id';
        cont.Ascdesc = 'ASC';
        cont.getTotalPages();
        cont.save();
        cont.getthevalues();
        cont.previous(); 
        cont.first(); 
        cont.Reasoncode = '';
        cont.Fieldapi= '';
        cont.rowIndex = 123;
        cont.last(); 
        cont.next(); 
        cont.refreshPageSize();
        cont.hasNext = false;
        cont.hasPrevious = false;
        cont.pageNumber  =20;
        cont.onLoad(); 
        cont.getqry();
        cont.Search();
        cont.orderByColumn = 'Id';
        cont.UpdateQuotelineitems();
        cont.Updatesubscriptions();
        cont.renderIFrame();
        cont.orderByColumn = 'Id';
        cont.init();
        cont.goBack();
        cont.AuthorizeQuotelineitems();
        cont.profileToEdit = pp.id;
        cont.sfdcAccountId = acc.id;
        cont.searchForZuoraAccount(Acc.Id);
        List<Zuora.ZObject> listzobjs = new List<Zuora.ZObject>();
        Set<String> ids = new  Set<String>();
        cont.SendSublistToZuora(listzobjs,ids );
        //cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        // cont.paymentProfileList.add(makeWrapper(pp));
        cont.cardType = 'Visa';
        cont.expirationDate = '05/2020';
        cont.cardHolderName = 'Test Holder';
        cont.cardcvv = '123';
        cont.billingaddress = '123 test lane';
        cont.billingCity = 'Test city';
        cont.billingState = 'California';
        cont.billingPostalCode = '95124';
        cont.billingCountry = 'United States';
        cont.editProfile();
        cont.goBack();
        cont.ActType = 'Lender Individual';
        cont.rid = relation.Id;
        cont.goBack();
        cont.renderIFrame();
        
        Test.setCurrentPageReference(new PageReference('Page.LenderPaymentProfile'));
        System.currentPageReference().getParameters().put('id', LenderAcc.id);
        System.currentPageReference().getParameters().put('rId', relation.Id);
        
        Z_ManageSubscripitonPaymentMethods cont2 = new Z_ManageSubscripitonPaymentMethods();
        cont2.sfdcAccountId  = LenderAcc.Id;
        cont2.rowIndex2 = 0;
        cont2.SelectAll = true;
        cont2.orderByColumn = 'Id';
        cont2.Ascdesc = 'ASC';
        cont2.Reasoncode = '';
        cont2.Fieldapi= '';
        cont2.rowIndex = 123;
        cont2.hasNext = false;
        cont2.hasPrevious = false;
        cont2.pageNumber  =20;
        cont2.orderByColumn = 'Id';
        cont2.size = 50;
       
        cont2.returnToAccount();
        cont2.goBack();             
        cont2.ActType = 'Lender Individual';
        cont2.goBack();
        cont2.queryPaymentProfiles();
        cont2.init();
        cont2.renderIFrame();
        cont2.UpdateRelationships();
        cont2.AuthorizeExistingLenderProfiles();
        
        
    }
    
    public static Account_Relationship__c Makerelation(String agent, string Lender){
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.parent_account__c = agent;
        ar.child_account__c = Lender;
        insert ar;
        return ar;
    }
     public static Account makeAccount2(String accType) {
        
        Account testAcc = new Account();
        testAcc.Name = 'my test account';
        testAcc.BillingState = 'CA';
        testAcc.BillingStreet = '123 Test Ln';
        testAcc.BillingCity = 'Test City';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '95111';
        testAcc.ShippingStreet = '123 Test Ln';
        testAcc.ShippingCity = 'Test City';
        testAcc.ShippingCountry = 'United States';
        testAcc.ShippingPostalCode = '95111';
        testAcc.ShippingState = 'CA';
        testAcc.Type = accType ;
         testAcc.MLS_Set_Id__c  = '67890';   
            testAcc.nmls_id__c = '12455'; 
        testAcc.Primary_Email__c = 'parentAcc@move.com';
        
        insert testAcc;
        return testAcc;
    }
    
    public static Account makeAccount() {
        
        Account testAcc = new Account();
        testAcc.Name = 'my test account';
        testAcc.BillingState = 'CA';
        testAcc.BillingStreet = '123 Test Ln';
        testAcc.BillingCity = 'Test City';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '95111';
        testAcc.ShippingStreet = '123 Test Ln';
        testAcc.ShippingCity = 'Test City';
        testAcc.ShippingCountry = 'United States';
        testAcc.ShippingPostalCode = '95111';
        testAcc.ShippingState = 'CA';
        testAcc.Type = 'Association';
        
        insert testAcc;
        return testAcc;
    }
    public static Account makeDetailedAccount(String bp) {
        
        Account testAcc = new Account();
        testAcc.Name = 'my test account';
        testAcc.BillingState = 'CA';
        testAcc.Type = 'Realtor Agent';
        testAcc.Currency_Type__c = 'USD';
        testAcc.Billing_Preference__c = bp;
        
        insert testAcc;
        return testAcc;
    }
    public static List<comarketing_relationship__c> makeComarkeing(Account agentAcc, Account lenderAcc ,Asset theTestAssets){
        
        List<comarketing_relationship__c> cm = new List<comarketing_relationship__c>();
        comarketing_relationship__c cr = new comarketing_relationship__c();
        cr.status__c = 'Active';
        cr.agent_account__c = agentAcc.id;
        cr.lender_account__c = lenderAcc.id;
        cr.cfcb_asset__c = theTestAssets.id;
        cr.Agent_Zuora_Status__c = 'Pending Update';
        cr.Lender_Zuora_Status__c ='Pending Update';
        cr.Action__c = 'Add';
        cr.Amendment_Effective_Date__c = Date.today();
        cr.Lender_Asset_Monthly_Contribution__c = 20;
        cr.Lender_Cancellation_Date__c = date.today();
        cr.Agent_Cancellation_Date__c = date.today();
        cr.Credit__c = 20;
        cr.Agent_Lender_Asset_Id__c =agentAcc.id + '-' + lenderAcc.id + '-' + theTestAssets.Id +'12';
        cm.add(cr);
        comarketing_relationship__c cr1 = new comarketing_relationship__c();
        cr1.status__c = 'Active';
        cr1.agent_account__c = agentAcc.id;
        cr1.lender_account__c = lenderAcc.id;
        cr1.cfcb_asset__c = theTestAssets.id;
        cr1.Agent_Zuora_Status__c = 'Pending Update';
        cr1.Lender_Zuora_Status__c ='Pending Update';
        cr1.Action__c = 'Amend';
        cr1.Amendment_Effective_Date__c = Date.today();
        cr1.Lender_Asset_Monthly_Contribution__c = 10;
        cr1.Lender_Cancellation_Date__c = date.today();
        cr1.Agent_Cancellation_Date__c = date.today();
        cr1.Credit__c = 20;
        cr1.Agent_Lender_Asset_Id__c =agentAcc.id + '-' + lenderAcc.id + '-' + theTestAssets.Id +'34';
        cm.add(cr1);
        comarketing_relationship__c cr2 = new comarketing_relationship__c();
        cr2.status__c = 'Active';
        cr2.agent_account__c = agentAcc.id;
        cr2.lender_account__c = lenderAcc.id;
        cr2.cfcb_asset__c = theTestAssets.id;
        cr2.Agent_Zuora_Status__c = 'Pending Update';
        cr2.Lender_Zuora_Status__c ='Pending Update';
        cr2.Action__c = 'Cancel';
        cr2.Amendment_Effective_Date__c = Date.today();
        cr2.Lender_Asset_Monthly_Contribution__c = 20;
        cr2.Lender_Cancellation_Date__c = date.today();
        cr2.Agent_Cancellation_Date__c = date.today();
        cr2.Credit__c = 20;
        cr2.Agent_Lender_Asset_Id__c =agentAcc.id + '-' + lenderAcc.id + '-' + theTestAssets.Id+ '444';
        cm.add(cr2);
        insert cm;
        system.debug('@@@@@- Comarketing  '+cm );
        return cm;
        //return 
    }

    public static Product2 makepruduct(){
        Product2 theTestProduct         = new Product2(
            Name                          = 'Connection(SM) for Co-Brokerage',
            Family                        = 'Hardware',
            S_No__c                       = 2,
            ProductCode                   = 'COBROKE'
        );
        insert theTestProduct;
        return theTestProduct;
    } 
    public static BigMachines__Quote__c makeBMQuote(Id AccId){
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Account__c = AccId;
        insert quote;
        return quote;
    }
    static String zID = '44444444444444444444444444444444';
    Public Static BigMachines__Quote_Product__c Makequoteproduct(Id QuoteId, Id prodId){
        
        BigMachines__Quote_Product__c bquoteAddModify  = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c       = QuoteId;
        bquoteAddModify.Line_Type__c           = 'Add';
        bquoteAddModify.BigMachines__Product__c     = prodId;
        bquoteAddModify.BigMachines__Quantity__c     = 1;
        bquoteAddModify.BigMachines__Sales_Price__c   = 10;
        bquoteAddModify.Zuora_Payment_Method__c = zID;
        insert bquoteAddModify;
        return bquoteAddModify;
    }
    public static Zuora__CustomerAccount__c makeBillingAccount(Account acc) {
        Zuora__CustomerAccount__c testAcc = new Zuora__CustomerAccount__c();
        testAcc.Name = 'my test billing account';
        testAcc.Zuora__Account__c = acc.id;
        testAcc.Zuora__External_Id__c = '33333333333333333333333333333333';
        testAcc.Zuora__Currency__c = 'USD';
        testAcc.Zuora__BillToCity__c = 'Test City';
        testAcc.Zuora__BillToCountry__c = 'United States';
        testAcc.Zuora__BillToAddress1__c = '123 Test Lane';
        testAcc.Zuora__BillToState__c = 'California';
        testAcc.Zuora__BillToPostalCode__c = '95124';
        testAcc.Zuora__BillToName__c = 'Tyler Bill';
        
        
        insert testAcc;
        return testAcc;
    }
    
    
    public static PaymentProfiles__c makeccPaymentProfile(Account acc){
        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = acc.id;
        pp.PaymentMethodId__c = zId;
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        pp.Reason_Code__c = 'New Chip';
        pp.Recently_Added__c = true;
        
        insert pp;
        return pp;
    }
    
    
    public static Asset makeAsset(Id AccId, Id Productid, Id pp){
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId =AccId;     
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.status = 'Active';
        myAsset.Asset_Type__c = 'Parent';
        myAsset.Product2ID   = Productid;
        myAsset.Payment_Profile__c = pp;
        // myAsset.ContactId = Contactid;
        myAsset.Subscription_Id__c = '323232323232323232323232323';
        insert myAsset;
        return myAsset;
    }
    public static List<Zuora__Subscription__c> makeSubscription(Id AccId, Id AssetId){
        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c zuoraSub2 = new Zuora__Subscription__c();
        zuoraSub2.Name = 'Test2';
        zuoraSub2.Zuora__Account__c =  AccId;
        zuoraSub2.Zuora__SubscriptionStartDate__c = system.Today(); 
        zuoraSub2.Zuora__SubscriptionEndDate__c = system.Today();  
        zuoraSub2.Zuora__Status__c = 'Active';
        zuoraSub2.Status__c = 'Processing';
        zuoraSub2.PaymentMethodId__c = zID;
        zuoraSub2.Zuora__NextRenewalDate__c  = system.Today();  
        zuoraSub2.Zuora__TermStartDate__c = system.today().addDays(2);
        zuoraSub2.Zuora__TermEndDate__c = system.today().addDays(9);
        zuoraSub2.Asset__c = AssetId; 
        zuoraSub2.AssetID__c = AssetId;
        subs.add(zuoraSub2);
        
        insert subs;
        return subs;
    }
}