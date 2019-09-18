@isTest(SeeallData=false)
public class CollectionsTriggerPayments_Test {
public static testMethod void mainTest() {

            // Inserting Test Account.
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Broker';
        theAccount.Customer_Care_Calls__c = 'Yes';
        theAccount.Sales_Calls__c = 'Yes';
        theAccount.Marketing_Emails__c = 'Yes';
        theAccount.Agent_SLE__c = 'Yes';
        theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';

        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        insert theAccount;
Zuora__CustomerAccount__c b = new Zuora__CustomerAccount__c();
       b.Past_Due_Balance__c= 60;
       b.Zuora__Account__c = theAccount.Id;
       insert b;
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = 'Past Due';
        inv.Zuora__Account__c = theAccount.Id;
        inv.Zuora__DueDate__c = System.today().adddays(-5);
        inv.Zuora__Balance2__c = 5;
        inv.Invoice_Status__c = 'Cancelled';
        //inv.Days_Past_Due__c = 6;
         
        Insert Inv;
        
         Zuora__Payment__c pp = new Zuora__Payment__c();
         //pp.Amount__c = 4;
         pp.Zuora__BillingAccount__c = b.Id;
         pp.Zuora__Status__c = 'Processed';
         //pp.Zuora__AppliedInvoiceAmount__c = 100;
         pp.Zuora__Type__c = 'Electronic';
         pp.ZPaymentMethodId__c ='CC';
         pp.Zuora__Effective_Date__c = System.today().AddDays(-1);
         pp.Zuora__Invoice__c = Inv.id;
         Insert pp;
         
        
         
         Zuora__PaymentInvoice__c zpi = new Zuora__PaymentInvoice__c();
       zpi.Zuora__ApplyAmount__c = 100;
       zpi.Zuora__Invoice__c = Inv.id;
       zpi.Zuora__Payment__c = pp.id;
       insert zpi;
       }
}