@isTest(seeAllData=true)
public class Z_UpdateInvoiceflagtostopretrytest {
    public static testMethod void TestMethod_one() {
       
       // DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        //insert Dtrg;
        
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Broker';
        theAccount.Name = 'Broker2';
        theAccount.Customer_Care_Calls__c = 'Yes';
        theAccount.Sales_Calls__c = 'Yes';
        theAccount.Marketing_Emails__c = 'Yes';
        theAccount.Agent_SLE__c = 'Yes';
        theAccount.Total_Contract_Value__c = 15000;
        theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';
        insert theAccount;     
        
        Zuora__CustomerAccount__c BiilAccount = new Zuora__CustomerAccount__c();
        BiilAccount.Zuora__Account__c = theAccount.Id;
        insert BiilAccount;
       
        Zuora__ZInvoice__c inv2 = new Zuora__ZInvoice__c();
        inv2.Name = 'TestInv';
        inv2.Zuora__Status__c = '';
        inv2.Zuora__Account__c = theAccount.Id;
        inv2.Zuora__DueDate__c = system.today();
        inv2.Zuora__Balance2__c = 10;
        inv2.Invoice_Status__c = 'Cancelled';             
       
        
        insert inv2;
                     
        Zuora__Payment__c  Payment= new Zuora__Payment__c();
        Payment.Zuora__Account__c = theAccount.Id;
        Payment.Zuora__Status__c = 'Processed';
        Payment.ZPaymentMethodId__c = '4111111111111111111';
        Payment.Zuora__BillingAccount__c = BiilAccount.Id;
        
        insert Payment;
    
        Zuora__PaymentInvoice__c Invpay = new Zuora__PaymentInvoice__c();       
        Invpay.Zuora__Invoice__c = inv2.Id;
        Invpay.Zuora__Payment__c = Payment.Id;
        Invpay.Zuora__ApplyAmount__c = 2;
        insert Invpay;
        
        Set<String> Payids = new Set<String>{'4111111111111111111'};        
        Test.startTest();
        Z_UpdateInvoicetostopretry.UpdateInoivceflag(String.Valueof(theAccount.Id), '4111111111111111111');
        Z_UpdateInvoicetostopretry.UpdateInoivceflagfrompage(String.Valueof(theAccount.Id), Payids);
        Test.stopTest();                                         
    }    

}