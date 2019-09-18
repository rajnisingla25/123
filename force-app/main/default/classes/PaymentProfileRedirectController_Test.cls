@isTest
Public class PaymentProfileRedirectController_Test  {
    static testMethod void PaymentProfileRedirectController_Test(){
         //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
  Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= theAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);  
      
    test.startTest();
    PageReference pgr = page.AccountRedirect;
    pgr.getParameters().put('Id',theAccount.id);
    Test.SetCurrentPage(pgr);    
     ApexPages.StandardController sc = new ApexPages.standardController(cAccount);               
    PaymentProfileRedirectController Ret  = new PaymentProfileRedirectController (sc);     
    Ret.onLoad();
    Ret.CreateZuoraBillingAccount();
    Ret.redirect();
    test.stopTest();         
    
   }
   static testMethod void PaymentProfileRedirectController_Test1(){
         //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);  
    test.startTest();
    PageReference pgr = page.AccountRedirect;
    pgr.getParameters().put('Id',theAccount.id);
    Test.SetCurrentPage(pgr);    
    ApexPages.StandardController sc = new ApexPages.standardController(theAccount);               
    PaymentProfileRedirectController Ret  = new PaymentProfileRedirectController (sc);     
    Ret.onLoad();
    Ret.redirect();
    test.stopTest();         
    
   }
 }