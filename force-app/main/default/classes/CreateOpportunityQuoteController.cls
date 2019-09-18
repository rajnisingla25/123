//
// (c) 2015 Appirio, Inc.
//
// Apex Controller: CreateOpportunityQuoteController
// For Apex Page: CreateOpportunityQuote
// Description: Creates a opportunity in background and redirects on the custom quote (CPQ) creation screen.
// 12th May 2015     Ravindra Shekhawat     Original ( Task # T-394321 ) 
public with sharing class CreateOpportunityQuoteController {

 public CreateOpportunityQuoteController() {
  }

 //Create Quote on Opportunity
  public PageReference createOpportunityQuote() {
    Id accountId = ApexPages.currentPage().getParameters().get('accId');
    ID oppId = ApexPages.currentPage().getParameters().get('oppId');
    String protocol = 'https://';
    String baseURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api');
    PageReference pageRef = new PageReference(protocol + baseURL +'/apex/BigMachines__QuoteEdit?oppId='+oppId+'&actId='+accountId+'&siteid='+CreateQuoteController.oracleId);   //CRM-5484 - Added Siteid      
    return pageRef;
  }

}