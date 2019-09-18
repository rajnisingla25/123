@isTest
private class AccountdetailedViewController_Test {
    
    private static testMethod void AccountdetailedViewController_Test_Invalid_party_id() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
        theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        theAccount.Party_ID__C = '12345';
        insert theAccount;
        
        AccountdetailedViewController.reDirect();
        
    }
    
   private  static testMethod void AccountdetailedViewController_Test_valid_party_Id() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        PageReference pgr = page.AccountdetailedView;
        Test.SetCurrentPage(pgr);
        pgr.getParameters().put('Partyid','12345');
       
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
        theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        theAccount.Party_ID__C = '12345';
        insert theAccount;
        
        AccountdetailedViewController.reDirect();
        
    }
}