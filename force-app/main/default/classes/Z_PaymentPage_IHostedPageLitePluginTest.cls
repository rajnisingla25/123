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
@isTest(seeAllData=true)
global class Z_PaymentPage_IHostedPageLitePluginTest {
    
    public static final String TEST_ACC_ID = '11111111111111111111111111111111';
    public static final String CUSTOM_SETTING_NAME = 'Test HPM Setting';
    public static final String PAYMENT_METHOD_TYPE_CREDIT_CARD = 'Credit Card';
    @isTest 
    private static void testZ_DefaultValuePluginWithQuote() {
        //TODO: refactor to use CPQ Quote
        setupCustomSetting();

        Account acc = createTestAccount(null, true);
        Contact con = createTestContact(acc, true);
        Opportunity opp = createTestOpportunity(acc, true);
        zqu__Quote__c quote = createTestQuote(acc, opp, con, con, true);

        Z_PaymentPage_IHostedPageLitePlugin controller = new Z_PaymentPage_IHostedPageLitePlugin();
        //controller.customSettingName = CUSTOM_SETTING_NAME;    //Radhika:Commenting since compilation is failing

        PageReference testPage = setupPage(quote.Id);
        System.Test.setCurrentPage(testPage); 

        Test.startTest();
   ApexPages.currentPage().getParameters().put('id',acc.Id);
        Map < String, String > defaultValues = new Map < String, String >();
        //defaultValues = controller.getAdditionalParameters(zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD);
        
        Boolean hasQuote = controller.hasQuote;
        Boolean hasSfdcBillingAccount = controller.hasSfdcBillingAccount;
        Boolean hasAccountInZuora = controller.hasAccountInZuora;
        Boolean foundZuoraAcc = controller.searchForZuoraAccount(acc.Id);
        try{
        defaultValues = controller.getAdditionalParameters('Test');
        }
        catch(Exception e){}
        Test.stopTest();
    }

    @isTest 
    private static void testZ_DefaultValuePluginWithBillingAccount() {
        setupCustomSetting();

        Account acc = createTestAccount(null, true);
        Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);

        Z_PaymentPage_IHostedPageLitePlugin controller = new Z_PaymentPage_IHostedPageLitePlugin();
        //controller.customSettingName = CUSTOM_SETTING_NAME; //Radhika:Commenting since compilation is failing

        PageReference testPage = setupPage(null);
        System.Test.setCurrentPage(testPage); 

        Test.startTest();

        Map < String, String > defaultValues = new Map < String, String >();
        //defaultValues = controller.getAdditionalParameters(zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD);

        Boolean hasQuote = controller.hasQuote;
        Boolean hasAccountInSFDC = controller.hasSfdcBillingAccount;
        Boolean hasAccountInZuora = controller.hasAccountInZuora;
        
        Test.stopTest();
    }
    /*
    @isTest
    private static void testCoverage() {
        setupCustomSetting();

        Account acc = createTestAccount(null, true);
        Contact con = createTestContact(acc, true);
        Opportunity opp = createTestOpportunity(acc, true);
        zqu__Quote__c quote = createTestQuote(acc, opp, con, con, true);
       Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);

        Z_PaymentPage_IHostedPageLitePlugin controller = new Z_PaymentPage_IHostedPageLitePlugin();
        //controller.customSettingName = CUSTOM_SETTING_NAME;

        Test.startTest();

        //No Id or accId present in URL
        PageReference testPage = Page.Z_PaymentProfileManager;
        testPage.getParameters().put('type','CreditCard');
        System.Test.setCurrentPage(testPage); 
        Boolean foundQuote = controller.searchForQuote();
        Boolean foundSfdcBillAcc = controller.searchForSFDCBillingAccount(null);
        Boolean foundZuoraAcc = controller.searchForZuoraAccount(null);
        System.assert(!controller.hasQuote, 'Id param is blank. Quote should not have been found');
        System.assert(!controller.hasSfdcBillingAccount, 'accId param is blank. Billing Account should not have been found');
        System.assert(!controller.hasAccountInZuora, 'Sfdc Account Id is blank. Zuora Account should not have been found');

        //Quote specified
        testPage = setupPage(quote.Id);
        System.Test.setCurrentPage(testPage); 
        foundQuote = controller.searchForQuote();
        foundSfdcBillAcc = controller.searchForSFDCBillingAccount(null);
        foundZuoraAcc = controller.searchForZuoraAccount(null);
        System.assert(controller.hasQuote, 'Id param is specified. Quote should have been found');
        System.assert(!controller.hasSfdcBillingAccount, 'accId param is blank. Billing Account should not have been found');
        System.assert(!controller.hasAccountInZuora, 'Sfdc Account Id is blank. Zuora Account should not have been found');

        //Billing Account Id specified
        testPage = setupPage(null);
       System.Test.setCurrentPage(testPage); 
        foundQuote = controller.searchForQuote();
        foundSfdcBillAcc = controller.searchForSFDCBillingAccount(acc.Id);
        foundZuoraAcc = controller.searchForZuoraAccount();
        System.assert(!controller.hasQuote, 'Id param is blank. Quote should not have been found');
        System.assert(controller.hasSfdcBillingAccount, 'accId param is not blank. Billing Account should have been found');
        System.assert(!controller.hasAccountInZuora, 'Sfdc Account Id is blank. Zuora Account should not have been found');
        

       Map < String, String > defaultValues = controller.getAdditionalParameters(zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD);

        Boolean hasQuote = controller.hasQuote;
        //Boolean hasAccountInSFDC = controller.hasAccountInSFDC;
        Boolean hasAccountInZuora = controller.hasAccountInZuora;
        
        Test.stopTest();
        
    }
    */

    public static Zuora__CustomerAccount__c createBillingAccount(Account acc, Boolean doInsert) {
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
        billAcc.Name = 'Test Billing Account';
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = 'A-001';
        billAcc.Zuora__AutoPay__c = false;
        billAcc.Zuora__Batch__c = 'Batch1';
        billAcc.Zuora__BillCycleDay__c = '1';
        billAcc.Zuora__Balance__c = 0;
        billAcc.Zuora__BillToCity__c = 'Atlanta';
        billAcc.Zuora__BillToCountry__c = 'United States';
        billAcc.Zuora__BillToAddress1__c = '123 Main St';
        billAcc.Zuora__BillToState__c = 'Georgia';
        billAcc.Zuora__BillToPostalCode__c = '12345';
        billAcc.Zuora__BillToId__c = '1234567890';
        billAcc.Zuora__BillToName__c = 'Test Name';
        billAcc.Zuora__BillToWorkEmail__c = 'test@test.com';
        billAcc.Zuora__MRR__c = 100;
        billAcc.Zuora__Credit_Balance__c = 100;
        billAcc.Zuora__Currency__c = 'USD';
        billAcc.Zuora__External_Id__c = TEST_ACC_ID;
        billAcc.Zuora__PaymentTerm__c = 'Due Upon Receipt';
        billAcc.Zuora__Status__c = 'Active';
        billAcc.Zuora__Zuora_Id__c = TEST_ACC_ID;
    
        if (doInsert) {
            insert billAcc;
        }
        return billAcc;
    }

    private static PageReference setupPage(Id quoteId) {
        PageReference pageRef = Page.Z_PaymentProfileManager;
        if (String.isNotBlank(quoteId)) {
            pageRef.getParameters().put('Id', quoteId);
        } else {
            pageRef.getParameters().put('accId', TEST_ACC_ID);
        }    
        pageRef.getParameters().put('type','CreditCard');
        return pageRef;
    }

    private static void setupCustomSetting() {
        /*
        Zuora_Customer_HPM_Setting__c testSetting = new Zuora_Customer_HPM_Setting__c();
        testSetting.Populate_Address1__c  = true;
        testSetting.Populate_City__c  = true;
        testSetting.Populate_Country__c  = true;
        testSetting.Populate_Email__c  = true;
        testSetting.Populate_Phone__c  = true;
        testSetting.Populate_State__c  = true;
        testSetting.Populate_Postal_Code__c  = true;
        testSetting.Populate_Contact_Info_for_BA__c  = true;
        testSetting.Populate_Contact_Info_for_Quotes__c  = true;
        testSetting.Name = CUSTOM_SETTING_NAME;
        testSetting.Update_Quote_With_Payment_Method_Id__c = true;
        testSetting.Payment_Page_Component_Name__c = 'Test_Component_Name';
        testSetting.Display_Quote_Fields__c = true;
        testSetting.Display_Quote_Charge_Fields__c = true;
        testSetting.Allow_for_Renew_Subscription_Quote__c = true;
        testSetting.Allow_for_New_Subscription_Quote__c = true;
        testSetting.Allow_for_Amend_Subscription_Quote__c = true;
        testSetting.Allow_for_Billing_Account_in_SFDC__c = true;
        testSetting.Allow_for_Billing_Account_in_Zuora__c = true;

        insert testSetting;
        */
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

    //Create a test Contact
    public static Contact createTestContact(Account acc, Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Smith';
        con.Phone = '1111111111';
        con.Email = 'tes2222222232t@test.com';
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

    //Create a test Quote
    public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean doInsert) {
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
        quote.zqu__ZuoraAccountId__c = TEST_ACC_ID;
    
        if (doInsert) {
            insert quote;
        }
    
        return quote;
    }
}