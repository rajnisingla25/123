@isTest(SeeAllData=True)
public class LaunchFutureAmendmentSchedulableTest { 
    public static String CRON_EXP = '0 0 0 * * ?';
    
    private static void setupData(){
        Account sfdcAccount = makeAccount();
        Contact sfdcContact = Z_LegacyTestFactory.makeContact(sfdcAccount);
        Opportunity sfdcOpp = Z_LegacyTestFactory.makeOpp(sfdcAccount);
        
        zqu__Quote__c zQuote = Z_LegacyTestFactory.makeQuote(sfdcOpp);
        zQuote.zqu__Status__c = 'New';
        zQuote.zqu__StartDate__c = System.today();
        zQuote.Future_Dated_Amendment__c = true;
        zQuote.zqu__Hidden_Subscription_Name__c ='Test Subscription';
        update zQuote;
        zqu__QuoteAmendment__c zQuoteAmend = makeQuoteAmendment(zQuote);
        zqu__QuoteRatePlan__c zQuoteRatePlan = makeQuoteRatePlan(zQuoteAmend, zQuote);
        zqu__QuoteRatePlanCharge__c zQuoteRatePlanChrg = makeQuoteRatePlanCharge(zQuoteRatePlan, zQuote);
        
    }
    
    static testmethod void testSuccessPreview(){
        setupData();
        Test.startTest();
            System.schedule('Test Check', CRON_EXP, new LaunchFutureDatedAmendmentSchedulable());
        Test.stopTest();
        
    }
    
    public static Account makeAccount() {
        //Inserting Customsetting for Subscription 
        /*
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        */
        Account testAcc = new Account();

        testAcc.Name = 'my test account';
        testAcc.BillingStreet = '1051 Hillsdale Blvd';
        testAcc.BillingCity = 'Foster City';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '94117';
        testAcc.BillingState = 'CA';
    

        testAcc.ShippingStreet = '1051 Hillsdale Blvd';
        testAcc.ShippingCity = 'Foster City';
        testAcc.ShippingCountry = 'United States';
        testAcc.ShippingPostalCode = '94117';
        testAcc.ShippingState = 'CA';

        testAcc.Primary_Email__c = 'test@email.com';
        testAcc.Work_Phone__c = '1111111111';
        testAcc.Party_ID__c = '206727180';
        testAcc.Type = 'Broker';
        testAcc.Currency_Type__c = 'USD';
        testAcc.Billing_Preference__c = 'Invoice';

        insert testAcc;
        return testAcc;
    }
    
    public static zqu__QuoteAmendment__c makeQuoteAmendment(zqu__Quote__c testQuote){
        zqu__QuoteAmendment__c testQAmend = new zqu__QuoteAmendment__c();
        testQAmend.zqu__Quote__c = testQuote.Id;
        insert testQAmend;
        return testQAmend;
    }
    
    public static zqu__QuoteRatePlan__c  makeQuoteRatePlan(zqu__QuoteAmendment__c testQAmend, zqu__Quote__c testQuote){
        zqu__QuoteRatePlan__c testQRatePlan = new zqu__QuoteRatePlan__c();
        testQRatePlan.zqu__QuoteAmendment__c = testQAmend.Id;
        testQRatePlan.zqu__Quote__c = testQuote.Id;
        insert testQRatePlan;
        System.debug('TestQuoteid'+ testQRatePlan.zqu__Quote__c);
        return testQRatePlan;
    }
    
    public static zqu__QuoteRatePlanCharge__c makeQuoteRatePlanCharge(zqu__QuoteRatePlan__c testQRatePlan, zqu__Quote__c testQuote){
        zqu__QuoteRatePlanCharge__c testQRatePlanChrg = new zqu__QuoteRatePlanCharge__c();
        testQRatePlanChrg.zqu__QuoteRatePlan__c =  testQRatePlan.Id;
        testQRatePlanChrg.zqu__ChargeType__c = 'Recurring';
        insert testQRatePlanChrg;
        System.debug('quoteid' + testQRatePlanChrg.zqu__QuoteRatePlan__r.zqu__quote__c);
        return testQRatePlanChrg;
    }
    
    public static List<Zuora.zObject> retrieveTestSubs(){
        List<Zuora.zObject> zuoraSubs = new List<Zuora.zObject>();
        Zuora.zObject testObj = new Zuora.zObject('Subscription');
        testObj.setValue('Id', '111111111111111111111');
        testObj.setValue('Name', 'Test Subscription');
        testObj.setValue('Status','Active');
        zuoraSubs.add(testObj);
        return zuoraSubs;
    }
    
    public static List<Zuora.zObject> retrieveTestRatePlans(){
        List<Zuora.zObject> zuoraRatePlans = new List<Zuora.zObject>();
        Zuora.zObject testObj = new Zuora.zObject('RatePlan');
        testObj.setValue('Id', '222222222222222222222');
        testObj.setValue('ProductRatePlanId', '333333333333333333333');
        testObj.setValue('SubscriptionId','111111111111111111111');
        zuoraRatePlans.add(testObj);
        return zuoraRatePlans;
    }
    
    public static List<Zuora.zObject> retrieveTestRatePlanChrgs(){
        List<Zuora.zObject> zuoraRatePlanChrgs = new List<Zuora.zObject>();
        Zuora.zObject testObj = new Zuora.zObject('RatePlanCharge');
        testObj.setValue('Id', '44444444444444444444');
        testObj.setValue('ProductRatePlanChargeId', '55555555555555555555');
        testObj.setValue('RatePlanId','222222222222222222222');
        testObj.setValue('ChargeType', 'Recurring');
        zuoraRatePlanChrgs.add(testObj);
        return zuoraRatePlanChrgs;
    }
    
    
}