@isTest(SeeAllData=True)
public class Z_BillingPreviewTest {
    private static Account account;
    private static Zuora__CustomerAccount__c billingAccount;
    
    private static void setupData() {
        account = Z_LegacyTestFactory.makeAccount(); //Create Account
        billingAccount = Z_LegacyTestFactory.makeBillingAccount(account);
    }
    
    public static testMethod void testSuccessPreview() {
        setupData();
        System.debug(billingAccount.Zuora__Zuora_Id__c);
        
        Test.startTest();
            Z_BillingPreview bPreview = new Z_BillingPreview();
            ZuoraBillingPreviewapi.BillingPreviewResult[] result1 = bPreview.billingPreview(billingAccount.Zuora__Zuora_Id__c, Date.today());
            ZuoraBillingPreviewapi.BillingPreviewResult[] result2 = bPreview.billingPreview(billingAccount.Zuora__Zuora_Id__c, Date.today(), true, false, false, false);
            ZuoraBillingPreviewapi.BillingPreviewResult[] result3 = bPreview.billingPreview(billingAccount.Zuora__Zuora_Id__c, Date.today(), true, true, true, true);
        Test.stopTest();
    } 
    
    public static ZuoraBillingPreviewapi.BillingPreviewResult[] createTestBillingPreviewResponse() {
        ZuoraBillingPreviewapi.BillingPreviewResult[] billingPreviewResult = new List<ZuoraBillingPreviewapi.BillingPreviewResult>();
        
        ZuoraBillingPreviewObject.InvoiceItem testinvObj = new ZuoraBillingPreviewObject.InvoiceItem();      
        ZuoraBillingPreviewObject.InvoiceItem[] testinvoiceItems = new List<ZuoraBillingPreviewObject.InvoiceItem>();
        testinvoiceItems.add(testinvObj);

        ZuoraBillingPreviewapi.Error testerr = new ZuoraBillingPreviewapi.Error();
        ZuoraBillingPreviewapi.Error[] testErrors = new List<ZuoraBillingPreviewapi.Error>();
        testErrors.add(testerr);
        
        ZuoraBillingPreviewapi.BillingPreviewResult testResult = new ZuoraBillingPreviewapi.BillingPreviewResult();
        testResult.InvoiceItem = testinvoiceItems;
        testResult.Success = true;
        testResult.AccountId = billingAccount.Zuora__Zuora_Id__c;
        testResult.Errors = testErrors;
        billingPreviewResult.add(testResult);
        
        return billingPreviewResult;
    }
    
    public static List<Zuora.zObject> retrieveTestSubs() {
        List<Zuora.zObject> zuoraSubs = new List<Zuora.zObject>();
        Zuora.zObject testObj = new Zuora.zObject('Subscription');
        testObj.setValue('Id', '111111111111111111111');
        testObj.setValue('Name', 'Test Subscription');
        testObj.setValue('IsInvoiceSeparate',false);
        zuoraSubs.add(testObj);
        return zuoraSubs;
    }
    
    public static List<Zuora.zObject> retrieveTestCharges() {
        List<Zuora.zObject> zuoraCharges = new List<Zuora.zObject>();
        Zuora.zObject testChrg = new Zuora.zObject('RatePlanCharge');
        testChrg.setValue('Id', '111111111111111111111');
        testChrg.setValue('Name', 'Test Charge');
        zuoraCharges.add(testChrg);
        return zuoraCharges;
    }  
}