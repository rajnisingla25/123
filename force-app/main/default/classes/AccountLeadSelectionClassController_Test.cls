@isTest
Public class AccountLeadSelectionClassController_Test  {
    static testMethod void AccountLeadSelectionClassController_Test(){
         //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
   Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact; 
    List<Lead> Leads = new List<Lead>();
   Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = theAccount.id;
        Led.Contact__c = testContact.id;
        led.Assigned_Group__c = 'test_group';
        Leads.add(Led);
        Insert Leads; 
        
      test.startTest();
    PageReference pgr = page.AccountLeadSelection;
    pgr.getParameters().put('Id',theAccount.id);
    Test.SetCurrentPage(pgr);    
     ApexPages.StandardController sc = new ApexPages.standardController(Led);  
              
    AccountLeadSelectionClassController Ret  = new AccountLeadSelectionClassController(sc); 
    Ret.Led = Leads;  
    Ret.LeadWrapper[0].checked  = True;  
    Ret.Save();
    Ret.SaveQuote();
    test.stopTest();      
  }
}