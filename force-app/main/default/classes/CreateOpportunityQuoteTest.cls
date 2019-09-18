@isTest
public class CreateOpportunityQuoteTest {
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
    }
    static testmethod void Createopportunity(){
       DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
         Account testAcc = TestDataFactory.createAccount('The Test Account', null, false);
        testAcc.Primary_Email__c = 'testAcc@move.com';
        testAcc.Type = Constants.OFFICE_ACCOUNT_TYPE;
        testAcc.Account_Sub_Type__c = 'Prospect';   
        insert testAcc;
       
        Opportunity   theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Prospecting';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = testAcc.id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        insert theOpportunity;
         
        
        apexPages.currentPage().getParameters().put('accid',string.valueof(testacc.id));
        apexpages.currentPage().getParameters().put('oppid',string.valueof(theOpportunity.id));
        CreateOpportunityQuoteController controller = new CreateOpportunityQuoteController();
        pagereference p = controller.createOpportunityQuote();
    }
    
    static testmethod void opportunityupdatetest(){
         DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
        Business_Hours__c businessHours = new Business_Hours__c();
        businessHours.Name = 'OwnChange';
        businessHours.Lowermin__c = 1;
        businessHours.UpMin__c = 2;
        insert businessHours;
        
        Business_Hours__c newBusinessHours = new Business_Hours__c();
        newBusinessHours.Name = 'StatusChange';
        newBusinessHours.Lowermin__c = 1;
        newBusinessHours.UpMin__c = 2;
        insert newBusinessHours;
         Account testAcc = TestDataFactory.createAccount('The Test Account', null, false);
        testAcc.Primary_Email__c = 'testAcc@move.com';
        testAcc.Type = Constants.OFFICE_ACCOUNT_TYPE;
        testAcc.Account_Sub_Type__c = 'Prospect';   
        insert testAcc;
       contact testContact = TestDataFactory.createContact('TestContact1','Last1',testAcc.id,true,false);
    testContact.Email = 'testContact1@move.com';
    testContact.Type__c = 'Primary';
        insert testContact;
         Lead Led = new Lead();
        //Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.LastName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = testAcc.id;
        Led.Contact__c = testContact.id;
        
      insert Led;
     
       Opportunity   theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Prospecting';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = testAcc.id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        theOpportunity.lead__c = led.id;
        insert theOpportunity;
        
        theopportunity.name='The Opportunity updated';
        theopportunity.StageName='Closed Won - Fulfilled';
        update theopportunity;
        
    }
}