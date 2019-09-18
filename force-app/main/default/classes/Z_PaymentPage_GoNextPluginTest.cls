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
 //TODO: refactor for CPQ Quote
@isTest(seeAllData=true)
global class Z_PaymentPage_GoNextPluginTest {

    private static final String DEBUG_STR = 'Z_PaymentPage_GoNextPluginTest: ';
    private static final String TEST_ACC_ID = '11111111111111111111111111111111';
    private static final String TEST_PM_ID = '22222222222222222222222222222222';
   
    @isTest(seeAllData=true)
    private static void testNavigateNextSuccess() {
        System.debug('Starting testNavigateNext');

        Account acc = createTestAccount(null, true);
        Contact con = createTestContact(acc, true);
        Opportunity opp = createTestOpportunity(acc, true);
        zqu__Quote__c quote = createTestQuote(acc, opp, con, con, true);

        System.debug('Creating controller');
        Z_PaymentPage_GoNextPlugin controller = new Z_PaymentPage_GoNextPlugin();
        System.debug('Done creating controller');

        //Setup test page with parameters "accId" and "type"
        PageReference testPage = setupPage(quote.Id);
        System.Test.setCurrentPage(testPage);



        System.debug('Starting test');
        Test.startTest();
        System.debug('Test started');

        PageReference currPage = Page.Z_PaymentProfileManager;
        currPage.getParameters().put('id',acc.Id);
        System.Test.setCurrentPage(currPage);

        System.debug('Creating callbackParameters');
        Map < String, String > callbackParameters = new Map <String, String>();
        callbackParameters.put('success', 'true');
        callbackParameters.put('refId', '1111111111');
        System.debug('callbackParameters created: callbackParameters');

        System.debug('Starting navigateNext');
        PageReference pageRef = controller.navigateNext(zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD, callbackParameters);
        System.debug('Finished navigateNext');
        
        System.debug('Stopping test');
        Test.stopTest();
        System.debug('Test stopped');
    }

    @isTest(seeAllData=true)
    private static void testNavigateNextFailure() {
        System.debug('Starting testNavigateNext');

        System.debug('Creating controller');
        Z_PaymentPage_GoNextPlugin controller = new Z_PaymentPage_GoNextPlugin();
        System.debug('Done creating controller');

        System.debug('Starting test');
        Test.startTest();
        System.debug('Test started');

        System.debug('Creating callbackParameters');
        Map < String, String > callbackParameters = new Map <String, String>();
        callbackParameters.put('success', 'false');
        callbackParameters.put('errorMessage', 'testErrorMessage');
        System.debug('callbackParameters created: callbackParameters');

        System.debug('Starting navigateNext');
        PageReference pageRef = controller.navigateNext(zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD, callbackParameters);
        System.debug('Finished navigateNext');
        
        System.debug('Stopping test');
        Test.stopTest();
        System.debug('Test stopped');
    }

    private static PageReference setupPage(Id quoteId) {
        PageReference pageRef = Page.Z_PaymentProfileManager;
        if (String.isNotBlank(quoteId)) {
            pageRef.getParameters().put('id', quoteId);
        } else {
            pageRef.getParameters().put('accId', TEST_ACC_ID);
        }
        pageRef.getParameters().put('type','CreditCard');
        return pageRef;
    }

    private static PageReference setupPage() {
        PageReference pageRef = Page.Z_PaymentProfileManagerCallback;
        pageRef.getParameters().put('success', 'true');
        pageRef.getParameters().put('refid', TEST_PM_ID);
        return pageRef;
    }

    public static List<Zuora.ZObject> retrieveFakePaymentMethod(Boolean exists) {
        List<Zuora.ZObject> paymentMethods = new List<Zuora.ZObject>();

        Zuora.ZObject testPM = new Zuora.ZObject('PaymentMethod');
        testPM.setValue('Id', TEST_PM_ID);
        testPM.setValue('AccountId', TEST_ACC_ID);

        if (exists) {
            paymentMethods.add(testPM);
        }

        return paymentMethods;
    }

    //Creates a success or failure Zuora Save Result based on the parameter 'success'
    public static Zuora.zApi.SaveResult createSaveResult(Boolean success) {
        Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
        saveResult.Success = success;
    
        if (success) {
            saveResult.Id = '12345678901234567890123456789012';
        } else {
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Message','Test Message');
    
            saveResult.Errors = new List<Zuora.zObject>{error};
        }
        
        return saveResult;
    }

    //Create a test Account
    public static Account createTestAccount(Account parent, Boolean doInsert) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingState = 'GA';
        testAcc.BillingCountry = 'USA';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123 Main St';
        testAcc.Primary_Email__c = 'test@test.com';
        
        if (parent != null) {
            testAcc.ParentId = parent.Id;
        }
        if (doInsert) {
            insert testAcc;
        }
    
        return testAcc;
    }

    //Create a test Opportunity
    public static Opportunity createTestOpportunity(Account acc, Boolean doInsert)
    {                     
           Opportunity opp = new Opportunity();    
        opp.CloseDate = System.today().addMonths(1);           
        opp.StageName = 'Closed Won';
        opp.Type = 'New Business';          
        opp.Name = 'Test Opportunity';
        
        if (acc != null) {
            opp.AccountId = acc.Id;
        }        
        if (doInsert) {
            insert opp;
        }
    
        return opp;
    }

    //Create a test Contact
    public static Contact createTestContact(Account acc, Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Smith';
        con.Phone = '1111111111';
        con.Email = 'test2222sdds@test.com';
        con.MailingStreet = '123 Main St';
        con.MailingCity = 'Atlanta';
        con.MailingCountry = 'USA';
        con.MailingState = 'GA';
        con.MailingPostalCode = '12345';
     
        if (acc != null) {
            con.AccountId = acc.Id;
        }
        if (doInsert) {
            insert con;
        }
        
        return con;
    }

    //Create a test Quote
    public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean doInsert) {
        //TODO: refactor for CPQ Quote
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__SubscriptionType__c = 'New Subscription';
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today();
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.zqu__InitialTerm__c = 12;
        quote.zqu__RenewalTerm__c = 12;
        quote.zqu__Account__c = (acc != null) ? acc.Id : null;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
        quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
        quote.zqu__Currency__c = 'USD';
    
        if (doInsert) {
            insert quote;
        }
    
        return quote;
    }
}