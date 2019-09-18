@isTest(SeeAllData=true)
public class Z_RetryPastDueinvoicesSchedule_Test{
    
    public static testMethod void testMethod1(){
    Account theAccount = new Account();
        theAccount.Name = 'my test account';
        theAccount.BillingState = 'CA';
        theAccount.Type = 'Realtor Agent';
        theAccount.Currency_Type__c = 'USD';
        theAccount.Billing_Preference__c = 'bp';
        
        
        insert theAccount;
        
        Zuora__CustomerAccount__c BiilAccount = new Zuora__CustomerAccount__c();
        BiilAccount.Zuora__Account__c = theAccount.Id;
        BiilAccount.Past_Due_Balance__c = 40;
        insert BiilAccount;
        
        String zID = '44444444444444444444444444444444';
        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = theAccount.id;
        pp.PaymentMethodId__c = zId;
        pp.SplitPercentage__c = 100;
        insert pp;
        
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = '';
        inv.Zuora__Account__c = theAccount.Id;
        inv.Zuora__DueDate__c = system.today();
        inv.Zuora__Balance2__c = 5;
        inv.Invoice_Status__c = 'Past Due'; 
        inv.Zuora__TotalAmount__c = 40;
        Insert Inv;
        
        Zuora__ZInvoice__c inv2 = new Zuora__ZInvoice__c();
        inv2.Name = 'TestInv2';
        inv2.Zuora__Status__c = '';
        inv2.Zuora__Account__c = theAccount.Id;
        inv2.Zuora__DueDate__c = system.today();
        inv2.Zuora__Balance2__c = 2;
        inv2.Invoice_Status__c = 'Past Due'; 
        inv2.Zuora__TotalAmount__c = 50;
        Insert Inv2;
                      
        Zuora__Payment__c  Payment= new Zuora__Payment__c();
        Payment.Zuora__Account__c = theAccount.Id;
        Payment.Zuora__Status__c = 'Processed';
        Payment.Zuora__BillingAccount__c = BiilAccount.Id;
        Payment.Split__c = 10.00;
        Payment.ZPaymentMethodId__c = zID;
        insert Payment;
        
        Zuora__Payment__c  Payment2= new Zuora__Payment__c();
        Payment2.Zuora__Account__c = theAccount.Id;
        Payment2.Zuora__Status__c = 'Error';
        Payment2.Zuora__BillingAccount__c = BiilAccount.Id;
        Payment2.ZPaymentMethodId__c = zID;
        Payment2.Split__c = 10.00;
        insert Payment2;
        
        
        Zuora__PaymentInvoice__c Invpay = new Zuora__PaymentInvoice__c();       
        Invpay.Zuora__Invoice__c = Inv.Id;
        Invpay.Zuora__Payment__c = Payment.Id;
        Invpay.Zuora__ApplyAmount__c = 2;
        insert Invpay;
        Zuora__PaymentInvoice__c Invpay2 = new Zuora__PaymentInvoice__c();       
        Invpay2.Zuora__Invoice__c = Inv2.Id;
        Invpay2.Zuora__Payment__c = Payment2.Id;
        Invpay2.Zuora__ApplyAmount__c = 4;
        insert Invpay2;
                
        test.startTest();
        system.debug('Here@');
        String CRON_EXP = '0 0 0 * * ?';
        System.schedule('Test Check', CRON_EXP, new Z_RetryPastDueinvoicesSchedule());             
        test.stopTest();
                   
    }                 
}