@isTest(SeeAllData=true)
public class Z_PaymentMethodCaptureUtilTest {

    private static final String TEST_ACC_ID = '11111111111111111111111111111111';
    
    @isTest static void testmethod_one() {        
        Account Acc = makeAccount();
        Contact cont=  makeContact(Acc);
         Account_Relationship__c Realtio = makeRealationship(Acc.Id, cont);
        BigMachines__Quote__c BMQ = makeBMQuote(Acc);
        Zuora__CustomerAccount__c ZuoraAccount= makeBillingAccount(Acc);
        
        Z_PaymentMethodCaptureUtil.searchForQuote(BMQ.id);
        Account aac2= Z_PaymentMethodCaptureUtil.searchForSFDCAccount(Acc.Id);
        Z_PaymentMethodCaptureUtil.searchForSFDCBillingAccount(ZuoraAccount.Id);
        Z_PaymentMethodCaptureUtil.searchForZuoraAccount(Acc.Id, True);
        Z_PaymentMethodCaptureUtil.CreateZuoraAccountWithSfdcAccountId(Acc.Id);
         Account accounts = [SELECT Id,Name,Type,Billing_Preference__c,Subscription_payment__c ,Currency_Type__c,
                                      BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,
                                      ShippingStreet,ShippingCity,Bill_To_Parent__c ,ShippingCountry,ShippingPostalCode,ShippingState,
                                      Zoura_Account_id__c, Phone, Party_ID__c
                                      FROM Account WHERE Id = :Acc.id LIMIT 1];
        Z_PaymentMethodCaptureUtil nn = new Z_PaymentMethodCaptureUtil();
        nn.createZuoraAccount(accounts);
         List<String> ids = new List<String>();
        ids.add('111111111111111111111');
        nn.deleteZObjects('Account',ids, new Zuora.Zapi()); 
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
        testAcc.Subscription_payment__c = true;
        testAcc.ShippingCountry = 'United States';
        testAcc.ShippingPostalCode = '95111';
        testAcc.ShippingState = 'CA';
        testAcc.Type = 'Moving Company';

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

    public static BigMachines__Quote__c makeBMQuote(Account acc){
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Account__c = acc.id;
        insert quote;
        return quote;
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

   
    
    public static Account_Relationship__c makeRealationship(String acc, Contact con){
        Account_Relationship__c rel = new Account_Relationship__c();
        rel.Active__c = true;
        rel.Average_Transaction_Amount__c = 100;
        rel.Billing_Contact__c = true;
        rel.Parent_Account__c = acc;
        rel.Zuora_Bill_to_Contact_ID__c = '11111111111111111111111111111111';
        rel.Zuora_Ship_to_Contact_ID__c = '11111111111111111111111111111111';
        rel.Contact_Role__c = 'Primary Contact';
        rel.Contact_To__c = con.id;
        rel.Contact_To__r = con;
        insert rel;
        return rel;
    }

    public static Contact makeContact(Account acc){
        Contact con = new Contact();
        con.Account = acc;
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Active__c = true;
        insert con;
        return con;
    }
}