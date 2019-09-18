@IsTest
Public class InvoicePaymentProfilesController_Test{
    static testMethod void InvoicePaymentProfilesController_Test(){
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
        
    List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
    Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
    inv.Name = 'TestInv';
    inv.Zuora__Status__c = 'Past Due';
    inv.Zuora__Account__c = theAccount.Id;
       Insert Inv;
    system.debug('Inv:' + Inv.Id);   
       
    List<PaymentProfiles__c> Payments = new List<PaymentProfiles__c>();    
    PaymentProfiles__c pay = new PaymentProfiles__c();
    pay.Account__c = theAccount.Id;
    pay.ExpirationDate__c ='06/2019';
    pay.CardholderName__c ='Test';
    pay.MaskNumber__c ='************4111';
    pay.CreditCardType__c = 'Visa';
    pay.Payment_Method_Type__c = 'CreditCard';          
    pay.SplitPercentage__c =100.00;
    Insert Pay;    
    
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact;      

    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
    
 CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
             insert setting;     
            
    Case testCase = new case();
     testCase.recordTypeId = rtId;
     testCase.Status = 'New';
     testCase.Origin = 'Phone';
     testCase.AccountId = theAccount.Id;
     testCase.ContactId = testContact.Id;
      Insert testCase;
    system.debug('testCase:' + testCase.Id);    
    
    Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= testCase.AccountId;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
    
    PageReference pgr = page.paymentprofiles;
    pgr.getParameters().put('id',inv.id);
    Test.SetCurrentPage(pgr);
    ApexPages.StandardController sc = new ApexPages.standardController(Pay);
    InvoicePaymentProfilesController IP = new InvoicePaymentProfilesController(Sc);
    IP.invoice = invoices;
    IP.payments = payments;
    IP.BillingAccountManager();
    }
    static testMethod void InvoicePaymentProfilesController_TestCase(){
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);    
    
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact;
    
     
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Case_Auto_Assign_To_Rep_Off__c=true);
    insert testSetting;
     
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Retention').getRecordTypeId();
            
    Case testCase = new case();
     testCase.recordTypeId = rtId;
     testCase.Status = 'New';
     testCase.Origin = 'Phone';
     testCase.AccountId = theAccount.Id;
     testCase.ContactId = testContact.Id;
      Insert testCase;
       
    
    Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= testCase.AccountId;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
    
    PageReference pgr = page.MakePaymentonCase;
    pgr.getParameters().put('id',testCase.id);
    Test.SetCurrentPage(pgr);
    ApexPages.StandardController sc = new ApexPages.standardController(testCase);
    InvoicePaymentProfilesController IP = new InvoicePaymentProfilesController(Sc);
    IP.CaseBillingManager(); 
 }
 }