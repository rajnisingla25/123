/* 
 *    Copyright (c) 2016 Zuora, Inc.
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *    this software and associated documentation files (the "Software"), to use copy, 
 *    modify, merge, publish the Software and to distribute, and sublicense copies of 
 *    the Software, provided no fee is charged for the Software.  In addition the
 *    rights specified above are conditioned upon the following:
 *
 *    The above copyright notice and this permission notice shall be included in all
 *    copies or substantial portions of the Software.
 *
 *    Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *    or promote products derived from this Software without specific prior written
 *    permission from Zuora, Inc.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *    FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *    ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
 *
 *    IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *
 *    BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */
@isTest
public class Z_TestFactory {

    public static final String SAVE_RESULT_ID   = '11111111111111111111111111111111';
    public static final String ZUORA_ACCOUNT_ID = '22222222222222222222222222222222';
    public static final String ZUORA_PM_ID      = '33333333333333333333333333333333';
    public static final String DELETE_RESULT_ID = '44444444444444444444444444444444';
    public static final String ZUORA_CONTACT_ID = '55555555555555555555555555555555';
    public static final String DELETE_RESULT_ERROR_MESSAGE = 'Test Delete Failure Message';
    public static final String SAVE_RESULT_ERROR_MESSAGE   = 'Test Save Failure Message';
    public static final String TEST_SESSION = 'EnEpgBW9vbuf4iWW9gKhOqW8oKI8u5QyTFkvBc4fkGNxRHC1P0lNxBkNJ9I9BMyVMFXBtjLTnYfkbrhJ0n6Ce1V35wfg9C65c5ZUL8AaKlYqejjnKYNMkpZaHKzKdTUbrwp4NNBqMRYPJlm2sUjzrUC4RzHqKZwyohJbA4y3nuGd9duSng049GxJAMbXmHzD';

    /**
     * Insert a test account in the db
     */
    public static Account makeAccount() {

        Account testAcc = new Account();

        testAcc.Name = 'my test account';

        insert testAcc;
        return testAcc;
    }

    /**
    * Creates a test Account. Has option for specifying Parent Account and whether or not to insert the object
    **/
    public static Account makeAccount(Account parent, Boolean doInsert) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingState = 'GA';
        testAcc.BillingCountry = 'USA';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123 Main St';
        testAcc.Primary_Email__c= 'ra@gmail.com';
        testAcc.Home_Phone__c= '967622877';
        testAcc.Work_Phone__c = '456789';
        testAcc.Mobile1__c = '1234566';
        testAcc.Mobile2_Other__c = '1245787';
        testAcc.party_id__c = '206084041';
        testAcc.Type = 'Broker';
        testAcc.Auto_Renewal__c = True;
        testAcc.Territories__c = 'test';
        testAcc.Account_Sub_Type__c = 'Prospect';
        
        if (parent != null) {
            testAcc.ParentId = parent.Id;
        }
        if (doInsert) {
            insert testAcc;
        }
    
        return testAcc;
    }

    /**
    * Creates a test Opportunity. Has option for specifying SFDC Account and whether to insert the object
    **/
    public static Opportunity makeOpportunity(Account acc, Boolean doInsert)
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

    /**
    * Creates a test Contact. Has option for specifying SFDC Account and whether to insert the object
    **/
    public static Contact makeContact(Account acc, Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Smith';
        con.Phone = '1111111111';
        con.Email = 'test@test.com';
        con.MailingStreet = '123 Main St';
        con.MailingCity = 'Atlanta';
        con.MailingCountry = 'USA';
        con.MailingState = 'GA';
        con.MailingPostalCode = '12345';
        con.Type__c = 'Other';
        con.Active__c = true;
     
        if (acc != null) {
            con.AccountId = acc.Id;
        }
        if (doInsert) {
            insert con;
        }
        
        return con;
    }

    /**
    * Creates a test Contact Relationship. Has options for SFDC Account, whether the Contact Relationship should be used as Bill / Sold relationship for Zuora, and whether to insert object
    **/
    public static Account_Relationship__c makeContactRelationship(Account acc, Contact con, Boolean isBillTo, Boolean isSoldTo, Boolean doInsert) {
        Account_Relationship__c conRel = new Account_Relationship__c();
        conRel.Active__c = true;
        conRel.Billing_Contact__c = (isBillTo) ? true : false;
        conRel.Child_Account__c = (acc != null) ? acc.Id : null;
        conRel.Contact_Role__c = (isSoldTo) ? 'Primary Contact' : null;
        conRel.Contact_To__c = (con != null) ? con.Id : null;
        conRel.Entity_Name__c = 'Test Entity';
        conRel.Is_Parent_Primary__c = true;
        conRel.Parent_Account__c = (acc != null) ? acc.Id : null;
        conRel.Relationship_Type__c = 'Member';
        conRel.Zuora_Sync__c = true;

        List<RecordType> recTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Account_Relationship__c' AND DeveloperName = 'Contact_Relationship'];
        conRel.RecordTypeId = (recTypes.size() > 0) ? recTypes[0].Id : null;

        if (doInsert) {
            insert conRel;
        }
        return conRel;
    }

    /**
    * Creates a test CPQ Quote. Has option for specifying whether the Quote should already be approved and whether to insert the object
    **/
    public static BigMachines__Quote__c makeCpqQuote(Account acc, Opportunity opp, Decimal firstMonthPayment, Boolean authSet, Boolean doInsert){
        BigMachines__Quote__c cpqQuote = new BigMachines__Quote__c();

        cpqQuote.BigMachines_first_month_payment__c = (firstMonthPayment != null) ? firstMonthPayment : 100.00;
        cpqQuote.BigMachines__Account__c = (acc != null) ? acc.Id : null;
        cpqQuote.BigMachines__Opportunity__c = (opp != null) ? opp.Id : null;
        cpqQuote.BigMachines__Status__c = 'CREATED';
        cpqQuote.BigMachines__Total__c = 0.00;

        if (authSet) {
            cpqQuote.BigMachines_authorization_status__c = 'Success';
            cpqQuote.BigMachines_authorization_amount__c = 100.00;
            cpqQuote.BigMachines_authorization_date__c = System.now();
        }

        List<RecordType> recTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Standard'];
        if (recTypes.size() > 0) {
            cpqQuote.RecordTypeId = recTypes[0].Id;
        }
        
        if (doInsert) {
            insert cpqQuote; 
        }
        return cpqQuote;
    }

    /**
    * Creates a test Billing Account. Has option for specifying the Account and whether the to insert the object
    **/
    public static Zuora__CustomerAccount__c makeBillingAccount(Account acc, Boolean doInsert) {
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
        billAcc.Zuora__External_Id__c = ZUORA_ACCOUNT_ID;
        billAcc.Zuora__PaymentTerm__c = 'Due Upon Receipt';
        billAcc.Zuora__Status__c = 'Active';
        billAcc.Zuora__Zuora_Id__c = ZUORA_ACCOUNT_ID;
        
        if (doInsert) {
            insert billAcc;
        }
        return billAcc;
    }

    /**
    * Creates a test Save Result with success depending on "success" param
    **/
    public static Zuora.zApi.SaveResult createSaveResult(Boolean success) {
        Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
        saveResult.Success = (success != null) ? success : true;
    
        if (success) {
            saveResult.Id = SAVE_RESULT_ID;
        } else {
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Message', SAVE_RESULT_ERROR_MESSAGE);
    
            saveResult.Errors = new List<Zuora.zObject>{error};
        }
        
        return saveResult;
    }

    /**
    * Creates a test Payment Method ZObject list. Option for specifying whether it should "find" the record or not (i.e. empty list or not)
    **/
    public static List<Zuora.ZObject> retrievePaymentMethods(Boolean exists, Boolean isCreditCard) {
        List<Zuora.ZObject> paymentMethods = new List<Zuora.ZObject>();

        exists = (exists != null) ? exists : true;
 
        if (exists) {
            Zuora.ZObject testPM = new Zuora.ZObject('PaymentMethod');
            testPM.setValue('Id', ZUORA_PM_ID);
            testPM.setValue('AccountId', ZUORA_ACCOUNT_ID);
            paymentMethods.add(testPM);

            if (isCreditCard) {
                testPM.setValue('Type', 'CreditCard');
                testPM.setValue('CreditCardType', 'Visa');
                testPM.setValue('CreditCardMaskNumber', '************1111');
                testPM.setValue('CreditCardHolderName', 'Test Name');
                testPM.setValue('CreditCardExpirationMonth', System.today().month());
                testPM.setValue('CreditCardExpirationYear', System.today().addYears(1).year());
                testPM.setValue('BankIdentificationNumber', '411111');
            } else {
                testPM.setValue('Type', 'ACH');
                testPM.setValue('AchAbaCode', '411111111');
                testPM.setValue('AchAccountName', 'Test Account');
                testPM.setValue('AchAccountNumberMask', '*****1111');
                testPM.setValue('AchAccountType', 'Checking');
                testPM.setValue('AchBankName', 'Test Bank');
            }
        }

        return paymentMethods;
    }

    /**
    * Creates a test Account ZObject list. Option for specifying whether it should "find" the record or not (i.e. empty list or not)
    **/
    public static List<Zuora.ZObject> retrieveTestAccount(Boolean accountExists) {
        Zuora.ZObject testAcc = new Zuora.ZObject('Account');
        testAcc.setValue('Id', ZUORA_ACCOUNT_ID);

        List<Zuora.ZObject> retrievedAccounts = (accountExists) ? new List<Zuora.ZObject>{testAcc} : new List<Zuora.ZObject>();
        return retrievedAccounts;
    }

    public static List<Zuora_Payment_Profile_Allowed_Country__c> setupWhitelistCountries() {
        List<Zuora_Payment_Profile_Allowed_Country__c> whitelistCountries = new List<Zuora_Payment_Profile_Allowed_Country__c>();
        List<Zuora_Payment_Profile_Allowed_Country__c> settingsToInsert = new List<Zuora_Payment_Profile_Allowed_Country__c>();

        Zuora_Payment_Profile_Allowed_Country__c usaSetting = new Zuora_Payment_Profile_Allowed_Country__c();
        usaSetting.Active__c = true;
        usaSetting.Country_ISO_Code__c = 'USA';
        usaSetting.Name = 'United States - Test';

        Zuora_Payment_Profile_Allowed_Country__c canSetting = new Zuora_Payment_Profile_Allowed_Country__c();
        canSetting.Active__c = true;
        canSetting.Country_ISO_Code__c = 'CAN';
        canSetting.Name = 'Canada = Test';

        Boolean doInsertUsa = true;
        Boolean doInsertCan = true;

        List<Zuora_Payment_Profile_Allowed_Country__c> existingSettings = [SELECT Name, Country_ISO_Code__c FROM Zuora_Payment_Profile_Allowed_Country__c 
            WHERE Name = :usaSetting.Name OR Name = :canSetting.Name 
            OR Country_ISO_Code__c = :usaSetting.Country_ISO_Code__c OR Country_ISO_Code__c = :canSetting.Country_ISO_Code__c];

        for (Zuora_Payment_Profile_Allowed_Country__c countrySetting : existingSettings) {
            System.debug('Inserting existing Allowed Country Setting: '+countrySetting);
            whitelistCountries.add(countrySetting);

            if (countrySetting.Name == usaSetting.Name || countrySetting.Country_ISO_Code__c == usaSetting.Country_ISO_Code__c) {
                System.debug('No need to insert USA setting');
                doInsertUsa = false;
            }

            if (countrySetting.Name == canSetting.Name || countrySetting.Country_ISO_Code__c == canSetting.Country_ISO_Code__c) {
                System.debug('No need to insert CAN setting');
                doInsertCan = false;
            }
        }

        if (doInsertUsa) {
            settingsToInsert.add(usaSetting);
        } 

        if (doInsertCan) {
            settingsToInsert.add(canSetting);
        } 

        if (settingsToInsert.size() > 0) {
            insert settingsToInsert;
            whitelistCountries.addAll(settingsToInsert);
        }

        return whitelistCountries;
    }

    /**
    * Returns a test Session variable
    **/
    public static String createTestSession() {
        return TEST_SESSION;
    }

    /**
    * Creates a test Delete Result with success depending on "success" param
    **/
    public static Zuora.ZApi.DeleteResult createTestDeleteResult(Boolean success) {
        //Default success to true if null
        success = (success != null) ? success : true;

        Zuora.ZApi.DeleteResult testResult = new Zuora.ZApi.DeleteResult(); 
    
        if (success) {
            testResult.Success = true;
            testResult.Id = DELETE_RESULT_ID;
        } else {
            Zuora.zObject testError = new Zuora.zObject('Error');
            testerror.setValue('Message', DELETE_RESULT_ERROR_MESSAGE);
    
            testResult.Success = false;
            testResult.Errors = new List<Zuora.zObject>{testError};
        }

        return testResult;
    }

    public static List<Account_Relationship__c> makeAccRelationships(Account acc, Contact con1, Contact con2, Boolean doInsert) {
        List<Account_Relationship__c> accRels = new List<Account_Relationship__c>();

        String accId = (acc != null) ? acc.Id : null;
        String con1Id = (con1 != null) ? con1.Id : null;
        String con2Id = (con2 != null) ? con2.Id : null;

        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = con1Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = con1Id;
        ar.Zuora_Ship_to_Contact_ID__c = con1Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = accId;

        Account_Relationship__c ar2 = new Account_Relationship__c();
        ar2.Contact_to__c = con2Id; 
        ar2.Billing_Contact__c = false;
        ar2.Contact_Role__c = 'Secondary Contact';
        ar2.Zuora_Bill_to_Contact_ID__c = con2Id;
        ar2.Zuora_Ship_to_Contact_ID__c = con2Id;
        ar2.Relationship_Type__c = 'Contact';
        ar2.Active__c = true;
        ar2.Parent_Account__c = accId;
        List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE Name='Contact Relationship' AND SobjectType = 'Account_Relationship__c'];
        if (!rt.isEmpty()) {
           ar2.RecordTypeId = rt[0].Id; 
        }

        accRels.add(ar);
        accRels.add(ar2);

        if (doInsert) {
            insert accRels;
        }
        return accRels;
    }

    public static Order makeOrder(Account acc, Boolean doInsert) {
        Order order = new Order();
        order.AccountId = (acc != null) ? acc.Id : null;
        order.EffectiveDate = Date.Today();
        order.Status = 'Created';
        order.Fulfillment_Status__c = 'Pending Fulfillment';
        order.Pricebook2Id = Test.getStandardPricebookId();
        if (doInsert) {
            insert order;
        }
        return order;
    }

    public static Asset makeAsset(Account acc, Contact con, Boolean doInsert) {
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId = (acc != null) ? acc.Id : null;
        myAsset.ContactId = (con != null) ? con.Id : null;
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        if (doInsert) {
            insert myAsset;
        }
        return myAsset;
    }

    public static List<OrderItem> makeOrderItemList1(Asset asset, Order order, PriceBookEntry pe) {
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem oi1 = makeOrderItem(asset, order, 'Add', pe, true);
        OrderItem oi2 = makeOrderItem(asset, order, 'Cancel', pe, true);
        OrderItem oi3 = makeOrderItem(asset, order, 'Amend', pe, true);
        OrderItem oi4 = makeOrderItem(asset, order, 'Coterm', pe, true);
        //OrderItem oi5 = makeOrderItem(asset, order, 'Renew', pe, true);
        OrderItem oi6 = makeOrderItem(asset, order, 'Credit', pe, true);
        OrderItem oi7 = makeOrderItem(asset, order, 'Buyout', pe, true);
        OrderItem oi8 = makeOrderItem(asset, order, 'Invalid order line', pe, true);
        OrderItem oi9 = makeOrderItem(asset, order, 'Add TigerLead', pe, true);

        orderItemList.add(oi1);
        orderItemList.add(oi2);
        orderItemList.add(oi3);
        orderItemList.add(oi4);
        //orderItemList.add(oi5);
        orderItemList.add(oi6);
        orderItemList.add(oi7);
        orderItemList.add(oi8);
        orderItemList.add(oi9);
        return orderItemList;
    }

    public static List<OrderItem> makeOrderItemList2(Asset asset, Order order, PriceBookEntry pe) {
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem oi9 = makeOrderItem(asset, order, 'Add TigerLead', pe, true);
        orderItemList.add(oi9);
        return orderItemList;
    }

    public static OrderItem makeOrderItem(Asset asset, Order order, String lineType, PriceBookEntry pe, Boolean doInsert) {
        OrderItem oi = new OrderItem();
        oi.OrderId = (order != null) ? order.Id : null;
        oi.Quantity = 1;
        oi.Asset__c = (asset != null) ? asset.Id : null;
        oi.Extended_Net_Price__c = 10.00;
        oi.Contract_Term__c = '12';
        oi.Part_Number__c = 'testpartnumber';
        oi.Subscription_Term__c = '1';
        oi.Override_Term__c = 1;
        oi.Line_Type__c = lineType;
        oi.Billing_Period__c = 'Month';
        oi.Cancellation_Date__c = Date.today();
        oi.Buyout_Amount__c = 100.00;
        oi.Credit_Amount__c = 100.00;
        oi.UnitPrice=10.00;
        oi.Quantity = 1;
        oi.PricebookEntryId = pe.Id;
        oi.Term_Start_Date__c = Date.today();
        oi.Start_Date__c = Date.today();
        oi.Commerce_Group__c = 'Broker Marketing Solution';
        if (doInsert) { 
            insert oi;
        }
        return oi;
    }
    
    public static PriceBookEntry makePriceBookEntry() {
        Product2 p2 = new Product2();
        p2.Name='test prod';
        p2.s_no__c = 2;
        insert p2;
      
        PricebookEntry pe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p2.Id, UnitPrice = 1);
        insert pe;
        return pe;
    }
}