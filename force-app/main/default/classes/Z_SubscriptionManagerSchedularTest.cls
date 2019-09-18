@isTest(seealldata = true)
public class Z_SubscriptionManagerSchedularTest {
    public static Map<String, Zuora__SubscriptionProductCharge__c> CmSubmaptest;
    static testMethod void testmethod_one(){
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');  
        Dtrg.AssetTrigger__c = UserInfo.getUserName();
        update Dtrg;
        Account agentAcc = makeAccount('Realtor Agent');
        Account LenderAcc = makeAccount('Lender Individual');
        Product2 Product = makepruduct();        
        Zuora__CustomerAccount__c ZuoraAccountagent =   makeBillingAccount(agentAcc);
        Zuora__CustomerAccount__c ZuoraAccountlender=   makeBillingAccount(LenderAcc);
        PaymentProfiles__c pp = makeccPaymentProfile(agentAcc);
        Asset theAsst = makeAsset(agentAcc.Id, Product.Id, pp.Id);
        List<comarketing_relationship__c> cms= makeComarkeing(agentAcc, LenderAcc, theAsst);
        List<Zuora__Subscription__c>  Subs = makeSubscription(agentAcc.Id,LenderAcc.Id, theAsst.Id , cms);
        createSubProdChrg(Subs, LenderAcc.Id);
        List<Id> cmsids = new List<Id>();
        for(comarketing_relationship__c inloop: cms){
            cmsids.add(inloop.Id); 
        }
        querySubprodchargesfortest(cmsids);        
       Test.startTest();
        System.schedule('Test Check33', '0 0 0 * * ?', new Z_SubscriptionManagerSchedular());
         System.schedule('Test Check444', '0 0 0 * * ?', new Z_SubscriptionManagerErrorSchedular());
        Test.stopTest();    
    }
    static testMethod void testmethod_two(){
      Z_SubscriptionCallhelper.prepareSubscriptionRequest('4111111111','341231231','1212313','1231231',20.0, Date.today(),'1310239103',true);
      Z_SubscriptionCallhelper.amendForUpdateProduct('updateproduct',  '213123123123', '131231231', 20.0,  'e2341213123112', Date.today());
      Z_SubscriptionCallhelper.amendForCredit('Credit', '223212312313', '12312312313', 20.0, '3121232	31231231', Date.today());
      Z_SubscriptionCallhelper.createAmendmentforCancel('Cancel','19231972321',Date.today());
      Z_SubscriptionCallhelper.amendApiCall(new List<Zuora.zObject>()); 
      Z_SubscriptionCallhelper.Z_subscribe(new List <Zuora.zApi.SubscribeRequest>());
    }
    public static void querySubprodchargesfortest(List<Id> cmsids){
        CmSubmaptest = new Map<String, Zuora__SubscriptionProductCharge__c>();
        integer i = 1;
        for(Zuora__SubscriptionProductCharge__c inloop: [SELECT Id,Zuora__ProductRatePlanChargeId__c ,Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c ,Zuora__Subscription__r.Zuora__Zuora_Id__c, Zuora__Subscription__r.CMRelationshipId__c,Zuora__Type__c , Zuora__Price__c 
                                                         FROM Zuora__SubscriptionProductCharge__c where createddate = today]){                                                          
                                                             String CMid =  inloop.Zuora__Price__c < 0 ? cmsids[1]+'Agent': cmsids[1]+ 'Lender';                                                                                                                           
                                                             CmSubmaptest.put(CMid , inloop);
                                                             String CMids =  inloop.Zuora__Price__c < 0 ? cmsids[2]+'Agent': cmsids[2]+ 'Lender'; 
                                                             CmSubmaptest.put(CMids , inloop);                                                           
                                                         }                                                                                                                   
        
    }
    public static Account makeAccount(String accType) {
        
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
    
    public static Zuora__CustomerAccount__c makeBillingAccount(Account acc) {
        Zuora__CustomerAccount__c testAcc = new Zuora__CustomerAccount__c();
        testAcc.Name = 'my test billing account';
        testAcc.Zuora__Account__c = acc.id;
        testAcc.Zuora__External_Id__c = '33333333333333333333333333'+ acc.Id;
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
    
    static String zID = '4444444444444444444444444444.444';
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
    public static Asset makeAsset(Id AccId, Id Productid, Id pp){
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId =AccId;     
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        myAsset.Product2ID   = Productid;
        myAsset.Payment_Profile__c = pp;
        myAsset.price__c = 30;
        // myAsset.ContactId = Contactid;
        myAsset.Subscription_Id__c = '323232323232323232323232323';
        insert myAsset;
        
        return myAsset;
    }
    public static List<Zuora__Subscription__c> makeSubscription(Id AccId,Id LId, Id AssetId, List<comarketing_relationship__c> cms){
        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c zuoraSub1 = new Zuora__Subscription__c();
        zuoraSub1.Name = 'Test2';
        zuoraSub1.Zuora__Account__c =  AccId;        
        zuoraSub1.Zuora__Status__c = 'Active';
        zuoraSub1.Status__c = 'Processing';
        zuoraSub1.PaymentMethodId__c = '44444444444444444444444444444444';  
        zuoraSub1.Zuora__Zuora_Id__c = '891829412989283';
        zuoraSub1.CMRelationship__c = cms[1].Id;      
        subs.add(zuoraSub1);
        Zuora__Subscription__c zuoraSub2 = new Zuora__Subscription__c();
        zuoraSub2.Name = 'Test3';
        zuoraSub2.Zuora__Account__c =  LId;        
        zuoraSub2.Zuora__Status__c = 'Active';
        zuoraSub2.Status__c = 'Processing';
        zuoraSub2.Zuora__Zuora_Id__c = '891829412112989283`';
        zuoraSub2.PaymentMethodId__c = '44444444444444444444444444444444';             
        zuoraSub2.Asset__c = AssetId; 
        zuoraSub2.AssetID__c = AssetId;
        zuoraSub2.CMRelationship__c = cms[2].Id;
        subs.add(zuoraSub2);
        
        insert subs;
        system.debug('@@@@@- Subscription  '+subs );
        return subs;
    }
    public static void createSubProdChrg(List< Zuora__Subscription__c> subId, String sfdcAccountId) {
        List<Zuora__SubscriptionProductCharge__c> subprodlist = new List<Zuora__SubscriptionProductCharge__c>();
        Zuora__SubscriptionProductCharge__c zuoraSubProdChrg = new Zuora__SubscriptionProductCharge__c();
        zuoraSubProdChrg.Name = 'New Component';
        zuoraSubProdChrg.Zuora__Zuora_Id__c = '2c92c0f94e4d3a3f014e6ee2e77c5436';
        zuoraSubProdChrg.Zuora__Subscription__c = subId[0].Id;
        zuoraSubProdChrg.Zuora__Account__c = sfdcAccountId;
        zuoraSubProdChrg.Zuora__Type__c = 'Recurring';
        zuoraSubProdChrg.Zuora__Price__c = 20;
        zuoraSubProdChrg.Zuora__ProductName__c = 'test product';
        zuoraSubProdChrg.Zuora__External_Id__c = 'testzuoraid23230000000002';
        zuoraSubProdChrg.Z_Charge_Number__c = '3434334';
        zuoraSubProdChrg.Zuora__ChargeNumber__c = '3434334';
        zuoraSubProdChrg.Zuora__RatePlanName__c = 'Connection(SM) for Co-Brokerage: Payment Based';
        subprodlist.add(zuoraSubProdChrg);
        Zuora__SubscriptionProductCharge__c zuoraSubProdChrg2 = new Zuora__SubscriptionProductCharge__c();
        zuoraSubProdChrg2.Name = 'New Component';
        zuoraSubProdChrg2.Zuora__Zuora_Id__c = '2c92c0f94e4d3a3f014e6ee2e77c5436';
        zuoraSubProdChrg2.Zuora__Subscription__c = subId[1].Id;
        zuoraSubProdChrg2.Zuora__Account__c = sfdcAccountId;
        zuoraSubProdChrg2.Zuora__Type__c = 'Recurring';
        zuoraSubProdChrg2.Zuora__Price__c = -20;
        zuoraSubProdChrg2.Zuora__ProductName__c = 'test product';
        zuoraSubProdChrg2.Zuora__External_Id__c = 'testzuoraid0000000002';
        zuoraSubProdChrg2.Z_Charge_Number__c = '12121212';
        zuoraSubProdChrg2.Zuora__ChargeNumber__c = '12121212';
        zuoraSubProdChrg2.Zuora__RatePlanName__c = 'Connection(SM) for Co-Brokerage: Payment Based';
        subprodlist.add(zuoraSubProdChrg2);
        
        insert subprodlist;
        system.debug('@@@@@- Product charges '+subprodlist );
    }
    
}