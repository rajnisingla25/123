/*    Copyright (c) 2014 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *   this software and associated documentation files (the "Software"), to use copy, 
 *   modify, merge, publish the Software and to distribute, and sublicense copies of 
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
 *
 *   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *
 *   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */
@isTest(SeeAllData=true)
public class Z_PaymentProfileManagerControllerTest {

    private static final String DEBUG_STR = 'Z_PaymentProfileManagerControllerTest: ';

    public static final String TEST_SAVE_RESULT_ID = '11111111111111111111111111111111';
    public static final String TEST_SAVE_RESULT_ERROR_MESSAGE = 'Test Save Failure Message';
    public static final String TEST_DELETE_RESULT_ID = '22222222222222222222222222222222';
    public static final String TEST_DELETE_RESULT_ERROR_MESSAGE = 'Test Delete Failure Message';
    public static final String TEST_SESSION = 'EnEpgBW9vbuf4iWW9gKhOqW8oKI8u5QyTFkvBc4fkGNxRHC1P0lNxBkNJ9I9BMyVMFXBtjLTnYfkbrhJ0n6Ce1V35wfg9C65c5ZUL8AaKlYqejjnKYNMkpZaHKzKdTUbrwp4NNBqMRYPJlm2sUjzrUC4RzHqKZwyohJbA4y3nuGd9duSng049GxJAMbXmHzD';
    
    //successful with id
    @isTest static void test_method_one() {
        // Implement test code
        Account acc = makeAccount();
        Zuora__CustomerAccount__c bAcc = makeBillingAccount(acc);

        BigMachines__Quote__c bMQuote = makeBMQuote(acc);
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', bMQuote.id);

        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        cont.sfdcBillingAccountId =  bAcc.id;
        cont.sfdcBillingAccount = bAcc;
        Boolean test2 = cont.hasSfdcBillingAccount;
        cont.getPaymentMethodOptions();
        cont.searchForQuote(bMQuote.id);
        //cont.searchForSFDCBillingAccount(acc.Id);
        cont.onLoad();
        cont.updateQuoteWithAuthSuccess();
    }
    //no sfdc id
    @isTest static void test_method_two() {
        // Implement test code
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        cont.zuoraAccountId = '11111111111111111111111111111111111';
        cont.zuoraAccount = new Zuora.ZObject('Account');
        Boolean test = cont.hasZuoraAccount;
    }
    //has id but account DNE
    @isTest static void test_method_three() {
        // Implement test code
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', '1');
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
    }

    //retrieve existing wrappers
    @isTest static void test_method_four() {
        // Implement test code
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        PaymentProfiles__c pp = makeACHPaymentProfile(acc);
        cont.profileToEdit = pp.id;
        cont.sfdcAccountId = acc.id;
        cont.paymentProfileList = cont.retrieveExistingWrappers();
    }   

    //ach edit
    @isTest static void test_method_five() {
        // Implement test code
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        PaymentProfiles__c pp = makeACHPaymentProfile(acc);
        cont.profileToEdit = pp.id;
        cont.sfdcAccountId = acc.id;
        cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        cont.paymentProfileList.add(makeWrapper(pp));
        cont.achAbaCode = '123';
        cont.achAccountName = 'Test ACH account name';
        cont.achAccountType = 'Checking';
        cont.achBankName = 'Test Bank';
        if(cont.achPaymentProfileList != null){

        }
        cont.editProfile();
    }
    //credit card edit
    @isTest static void test_method_six() {
        // Implement test code
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        PaymentProfiles__c pp = makeCCPaymentProfile(acc);
        cont.profileToEdit = pp.id;
        cont.sfdcAccountId = acc.id;
        cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        cont.paymentProfileList.add(makeWrapper(pp));
        cont.cardType = 'Visa';
        cont.expirationDate = '05/2020';
        cont.cardHolderName = 'Test Holder';
        cont.cardcvv = '123';
        cont.billingaddress = '123 test lane';
        cont.billingCity = 'Test city';
        cont.billingState = 'California';
        cont.billingPostalCode = '95124';
        cont.billingCountry = 'United States';
        if(cont.ccPaymentProfileList != null){

        }
        cont.editProfile();
    }
    //delete profile
    @isTest static void test_method_seven() {
        // Implement test code
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        PaymentProfiles__c pp = makeACHPaymentProfile(acc);
        BigMachines__Quote__c bMQuote = makeBMQuote(acc);
        cont.quoteId = bMQuote.id;
        cont.quote = bMQuote;
        cont.profileToDelete = pp.id;
        cont.sfdcAccountId = acc.id;
        cont.sfdcAccount = acc;
        cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        cont.paymentProfileList.add(makeWrapper(pp));
        cont.deleteProfile();
    }   

    //random calls
    @isTest static void test_method_eight() {
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        cont.callbackSuccess();
        cont.callbackFailure();
        cont.renderIFrame();
        cont.returnToAccount();
    }

    @isTest static void test_method_nine() {
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        PaymentProfiles__c pp = makeCCPaymentProfile(acc);
        BigMachines__Quote__c bMQuote = makeBMQuote(acc);
        cont.quoteId = bMQuote.id;
        cont.quote = bMQuote;
        cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        cont.paymentProfileList.add(makeWrapper(pp));
        
        cont.validatePaymentProfiles();
        cont.Profileselect = new List<Z_PaymentProfileManagerController.ProfileSelectorcombo>();
        cont.Profileselect.add(new Z_PaymentProfileManagerController.ProfileSelectorcombo(cont.paymentProfileList[0], 1));
        cont.authorizeCards();
        cont.MakePayment();
        cont.updateprofileamount();
        cont.updatedefaultmethod();
        cont.Performpayment('23',  2, '212', pp);
        cont.updatePaymentProfileSplits();
        cont.performAuthCallout(true,'1','2',100,'1',pp);
        cont.refreshAuthAmounts();
        cont.CreatePayementRecord('Processed', '32323', 4, system.today(), pp, bMQuote, true);
        
    }

    @isTest static void test_method_ten() {
        Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
        Account acc = makeAccount();
        Zuora__CustomerAccount__c bAcc = makeBillingAccount(acc);
        PaymentProfiles__c pp = makeACHPaymentProfile(acc);
        Contact con = makeContact(acc);
        cont.sfdcAccountId = acc.id;
        cont.sfdcAccount = acc;
        cont.sfdcBillingAccountId =  bAcc.id;
        cont.sfdcBillingAccount = bAcc;
        cont.paymentProfileList = new List<Z_PaymentProfileManagerController.Z_PaymentProfileWrapper>();
        cont.paymentProfileList.add(makeWrapper(pp));
        cont.refreshPaymentSplits();
        Account_Relationship__c rel = makeRealationship(acc.id, con);
        //cont.createZuoraAccount(acc);
        rel.Contact_To__r.FirstName = 'Test';
        rel.Contact_To__r.LastName = 'Test';
        update rel;
       // cont.createContactZObject(True,zID,acc,rel);
        //cont.createContactZObject(False,zID,acc,rel);
    }

    /*@isTest static void test_method_eleven() {
    Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
    List<String> ids = new List<String>();
    ids.add(zID);
    cont.deleteZObjects('Account',ids, new Zuora.Zapi());  
    Account acc1 = makeDetailedAccount('Invoice-Terms');
    Account acc2 = makeDetailedAccount('CC-Direct');
    Account acc3 = makeDetailedAccount('Tiger');
    Account acc4 = makeDetailedAccount('Test');
    cont.createAccountZObject(acc1);
    cont.createAccountZObject(acc2);
    cont.createAccountZObject(acc3);
    cont.createAccountZObject(acc4);
    Account acc = makeAccount();
    cont.searchForZuoraAccount(acc.id);

    }*/
    @isTest static void test_method_twelve() {
    Z_PaymentProfileManagerController cont = new Z_PaymentProfileManagerController();
    Z_PaymentProfileManagerController.appendSuccess('Test Success');
    cont.doNothing();
    Boolean t1 = cont.hasZuoraAccount;
    Boolean t2 = cont.hasQuote;
    Boolean t3 = cont.hasSfdcAccount;
    Boolean t4 = cont.hasSfdcBillingAccount;

    }
        
    public static Zuora.ZApi.DeleteResult createTestDeleteResult(Boolean success) {
        final String FUNC_STR = DEBUG_STR + 'createTestDeleteResult: ';
        System.debug(FUNC_STR+'Starting createTestDeleteResult');

        //Default success to true if null
        success = (success != null) ? success : true;

        Zuora.ZApi.DeleteResult testResult = new Zuora.ZApi.DeleteResult(); 
    
        if (success) {
            testResult.Success = true;
            testResult.Id = TEST_DELETE_RESULT_ID;
        } else {
            Zuora.zObject testError = new Zuora.zObject('Error');
            testerror.setValue('Message', TEST_DELETE_RESULT_ERROR_MESSAGE);
    
            testResult.Success = false;
            testResult.Errors = new List<Zuora.zObject>{testError};
        }
    
        System.Debug(FUNC_STR+'Created test Delete Result: '+testResult);
        return testResult;
    }

    public static String createTestSession() {
        return TEST_SESSION;
    }

    /** 
     * Creates a test SaveResult, taking in boolean to denote success 
     **/
    public static Zuora.ZApi.SaveResult createTestSaveResult(Boolean success) {
        final String FUNC_STR = DEBUG_STR + 'createTestSaveResult: ';
        System.debug(FUNC_STR+'Starting createTestSaveResult');

        //Default success to true if null
        success = (success != null) ? success : true;
    
        Zuora.ZApi.SaveResult testResult = new Zuora.ZApi.SaveResult(); 
    
        if (success) {
            testResult.Success = true;
            testResult.Id = TEST_SAVE_RESULT_ID;
        } else {
            Zuora.zObject testError = new Zuora.zObject('Error');
            testerror.setValue('Message', TEST_SAVE_RESULT_ERROR_MESSAGE);
    
            testResult.Success = false;
            testResult.Errors = new List<Zuora.zObject>{testError};
        }
    
        System.Debug(FUNC_STR+'Created test Save Result: '+testResult);
        return testResult;
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

    static String zID = '44444444444444444444444444444444';
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
    public static PaymentProfiles__c makeACHPaymentProfile(Account acc){
        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = acc.id;
        pp.PaymentMethodId__c = zId;
        pp.ACH_ABA_Code__c = '123';
        pp.ACH_Account_Name__c ='Test Account';
        pp.ACH_Account_Type__c = 'Checking';
        pp.ACH_Bank_Name__c = 'Test Bank';
        pp.Payment_Method_Type__c = 'ACH';
        pp.MaskNumber__c ='xxxxxxxxxxxxx1111';
        pp.SplitPercentage__c = 100;
        insert pp;
        return pp;
    }
    
    public static Z_PaymentProfileManagerController.Z_PaymentProfileWrapper makeWrapper(PaymentProfiles__c pp){
        Z_PaymentProfileManagerController.Z_PaymentProfileWrapper wrapper = new Z_PaymentProfileManagerController.Z_PaymentProfileWrapper();
        wrapper.profileId = pp.Id;
        wrapper.pmType = pp.Payment_Method_Type__c;
        wrapper.paymentProfile = pp;
        wrapper.cardType = 'Visa';
        wrapper.expirationDate = '05/2020';
        wrapper.maskNumber = 'xxxxxxxxxxxxx1111';
        wrapper.pmId = zID;
        wrapper.recently_added = true;
        wrapper.reason_code = 'New Chip';
        wrapper.cardHolderName = 'Test Name';
        wrapper.achAbaCode = '123';
        wrapper.achAccountName = 'Ach test name';
        wrapper.achAccountNumberMask = 'xxxxxxxxxxxxx1111';
        wrapper.achAccountType = 'Checking';
        wrapper.achBankName = 'Test Bank';
        wrapper.cardBIN = '100';
        //wrapper.authRecords = new List<AuthorizationRecord__c>();
        wrapper.isNew = false;
        wrapper.percentSplit = 100;
        wrapper.userBIN = '100';
        wrapper.authAmount = 100;
        wrapper.Paymentamount = 200;
       // wrapper.existingAuthTotal =50;
        wrapper.exampleAmount = 10;
        wrapper.existingPaymentTotal = 20;
        return wrapper;
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

    public static HttpResponse getResponse(){
        HttpResponse res = new HttpResponse();
        res.setBody('ResultCode=0&ResultMsg=Request ID: 4354886009005000001516&TransactionId=4354886009005000001516&GatewayOrderId=11111111111111111111111');
        res.setStatusCode(200);
        return res;
    }


}