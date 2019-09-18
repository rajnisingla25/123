//
// (c) 2015 Appirio, Inc.
//
// Apex Controller: CreateQuoteController
// For Apex Page: CreateQuote
// Description: Creates a opportunity in background and redirects on the custom quote (CPQ) creation screen.
//
// 01st April 2015   Hemendra Singh Bhati   Original (Task # T-375114)
// 20th April 2015   Chun Yeung             modified createOpportunity and added createQuote()
public with sharing class CreateQuoteController {
  // CRM-5484 - Get Oracle Site Id
  public static string oracleId = getOracleSiteId();
  private static string getOracleSiteId() {
      return [SELECT Id FROM BigMachines__Configuration_Record__c WHERE BigMachines__Is_Active__c=true LIMIT 1].Id;
  }
  // CRM-5484 - End
  public CreateQuoteController() {
  }

    public PageReference createQuote() {
    Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    Id caseId = ApexPages.currentPage().getParameters().get('caseId');
    String type = ApexPages.currentPage().getParameters().get('type');
    //String oracleId = System.Label.OracleSiteId;
    ID oppId = createOpportunity();
    String protocol = 'https://';
    String baseURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api');
    PageReference pageRef = new PageReference(protocol + baseURL +'/apex/BigMachines__QuoteEdit?oppId='+oppId+'&actId='+accountId+'&caseId='+caseId+'&type='+type +'&siteid='+oracleId);      
    return pageRef;
  }
    
 /* 
    public PageReference createQuote() {
    Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    ID oppId = createOpportunity();
    String protocol = 'https://';
    String baseURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api');
    PageReference pageRef = new PageReference(protocol + baseURL +'/apex/BigMachines__QuoteEdit?oppId='+oppId+'&actId='+accountId);      
    return pageRef;
  }

*/
  
 //  public PageReference createOpportunity() {
  private ID createOpportunity() {
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    Id leadId = ApexPages.currentPage().getParameters().get('leadid');
    Id campaignId;
    Id RecordTypeId;
    
    
    
    
    
    if(String.isNotBlank(accountId)) {
        try {
        Opportunity theOpportunity;
        
        for(Account acct:[Select Id,name,type from Account where Id=:accountId]){
        //if(acct.Type=='Broker'){
        RecordTypeId = [Select Id,Name from RecordType where DeveloperName='Broker_Field_Sales'].Id;
        //} 
        if(acct.Type.contains('Agent')){
        RecordTypeId = [Select Id,Name from RecordType where DeveloperName='Inside_Sales'].Id;
        }
        }
        
        if(String.isNotBlank(leadId)) {
            system.debug('TRACE: LeadID ' + leadId);
            
            for(CampaignMember ledd:[Select Id,campaignId from CampaignMember where LeadId=:leadId order by CreatedDate desc limit 1]){
              campaignId= ledd.campaignId ;
              system.debug('TRACE: campaignId ' + campaignId);
            }
            
            
            
        theOpportunity = new Opportunity(
          Name = 'The Opportunity',
          StageName = 'Prospecting',
          CloseDate = system.today(),
          AccountId = accountId,
          Account_Type__c = 'Short',
          Lead__c = leadId,
          campaignId = campaignId,
          RecordTypeId = RecordTypeId
          
        );
        }
        else {
            system.debug('TRACE: Opty without Lead ');
        theOpportunity = new Opportunity(
          Name = 'The Opportunity',
          StageName = 'Prospecting',
          CloseDate = system.today(),
          AccountId = accountId,
          Account_Type__c = 'Short',
          RecordTypeId = RecordTypeId
          
        );
        }
          insert theOpportunity;
          system.debug('TRACE: Opty Id ' + theOpportunity.Id );
          return theOpportunity.Id;
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'An internal error occurred while processing your request. Please contact system administrator.'
        ));
        }
    }
    return null;
  }
}