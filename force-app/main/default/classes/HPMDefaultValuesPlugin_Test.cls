@IsTest
Public class HPMDefaultValuesPlugin_Test{
    static Testmethod Void HPMDefaultValuesPluginTesting(){
     //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
     //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Billing_Preference__c = 'Invoice-CC';
          testAccount.BillingState = 'NY';
          insert testAccount;
          
          ApexPages.currentPage().getParameters().put('field_passthrough2',testAccount.id);
          HPMDefaultValuesPlugin HVP = New HPMDefaultValuesPlugin();
          HVP.getAdditionalParameters('Test Account');          
    }
}