@isTest(SeeAlldata = true)
public class Z_MRCPaymentCollectionTest {
    public static String CRON_EXP = '0 0 0 * * ?';
    public static testMethod void testmethod1() {
        Account theAccount = TestDataFactory.createAccount('The Test Account123', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Loan Officer';
         insert theAccount;    
        Zuora__CustomerAccount__c BiilAccount = new Zuora__CustomerAccount__c();
        BiilAccount.Zuora__Account__c = theAccount.Id;
        BiilAccount.Zuora__Balance__c = 232;
        BiilAccount.Zuora__Zuora_Id__c = '2312312321332323';
        insert BiilAccount;
      
        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.SplitPercentage__c =  100;
        pp.PaymentMethodId__c = '2312312412341241242';
        pp.Account__c = theAccount.Id;
        insert pp;
        
        Z_MRCPaymentJob.runthePaymentprocess();
        Zuora__Payment__c  Payment= new Zuora__Payment__c();
        Payment.Zuora__Account__c = theAccount.Id;
        Payment.Zuora__Status__c = 'Error';
        Payment.Zuora__BillingAccount__c = BiilAccount.Id;
        insert Payment;
        Z_MRCCollectionSchedular.runSchedular();
        
    } 
}