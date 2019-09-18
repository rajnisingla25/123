@isTest
Public class VFController_Test  {
    static testMethod void VFController_Test(){
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
   
   Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = theAccount.id;
        Led.Contact__c = testContact.id;
        led.Assigned_Group__c = 'test_group';
        
        Insert led; 
     test.startTest();
    PageReference pgr = page.LeadListViewRefresh;
    pgr.getParameters().put('Id',led.id);
    Test.SetCurrentPage(pgr);    
     ApexPages.StandardController sc = new ApexPages.standardController(Led);  
              
    VFController  Ret  = new VFController(sc); 
    Ret.autoRun();
    test.stopTest();      
   }
  }