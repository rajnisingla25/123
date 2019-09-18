//
// (c) 2015 Appirio, Inc.
//
// Test Class: CreateQuoteController_Test
// Apex Controller: CreateQuoteController
// For Apex Page: CreateQuote
// Description: Creates a opportunity in background and redirects on the custom quote (CPQ) creation screen.
//
// 01st April 2015   Hemendra Singh Bhati   Original (Task # T-375114)
//
@isTest
private class CreateQuoteController_Test {
   static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
    
  private static testMethod void testControllerFunctionality() {
    PageReference createQuotePage = Page.CreateQuote;
    Test.setCurrentPage(createQuotePage);
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account theAccount = TestDataFactory.createAccount('Test Account', null, false);
    theAccount.Primary_Email__c = 'testQuote@move.com';
    theAccount.Type = 'Realtor Agent';
    insert theAccount;
    ApexPages.currentPage().getParameters().put('accountId', theAccount.Id);

    CreateQuoteController theController = new CreateQuoteController();
    theController.createQuote();

    // Put False Account Id and Assert That opportunity is not created
    ApexPages.currentPage().getParameters().put('accountId', '001K0000019GTFBTCC');
    theController.createQuote();
    
  }
  private static testMethod void testControllerFunctionality1() {
    PageReference createQuotePage = Page.CreateQuote;
    Test.setCurrentPage(createQuotePage);
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
     Robin_Round__c rb = new Robin_Round__c(Name = 'MaxCount',Default_Size__c = 50);
    insert rb;          
   Account theAccount = TestDataFactory.createAccount('Test Account', null, false);
    theAccount.Primary_Email__c = 'testQuote@move.com';
    theAccount.Type = 'Realtor Agent';
    insert theAccount;
  Lead theLead = TestDataFactory.CreateLead('Test','Test','New',null,null,'Test',True);   
    ApexPages.currentPage().getParameters().put('accountId', theAccount.Id);
    ApexPages.currentPage().getParameters().put('leadId', theLead.Id);

    CreateQuoteController theController = new CreateQuoteController();
    theController.createQuote();

    // Put False Account Id and Assert That opportunity is not created
    ApexPages.currentPage().getParameters().put('accountId', '001K0000019GTFBTCC');
    theController.createQuote();
    
  }
}