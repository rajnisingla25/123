//
// (c) 2015 Appirio, Inc.
//
// Extension Name: ProductsOwnedExtension
// For Apex Page: ProductsOwned
// Description: An inline VF page to display Own Co Show at agent level. From a Realtor Agent account, if the Realtor Agent has a
// parent relationship to a Realtor Office, and if that Realtor Office has a parent relationship to a Broker, and the Parent office and
// parent broker both own Co-Show (Product: Showcase(SM) Listing Enhancements), then the Own Co Show flag (Own_CoShow__c) should be checked
// on the Realtor Agent Account.
//
// 01st June 2015     Hemendra Singh Bhati    Original (Task # T-406303)
//
public with sharing class ProductsOwnedExtension {
  // Private Data Member.
  private final String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';

  // Public Data Members.
  public Boolean theRealtorAgentOwnCoShow { get; set; }

  // The Constructor.
  public ProductsOwnedExtension(ApexPages.StandardController theStandardController) {
    Account theLoadedAccount = (Account)theStandardController.getRecord();

    // Determining the loaded account type.
    Boolean isRealtorAgentAccount = false;
    for(Account theAccount : [SELECT Type FROM Account WHERE Id = :theLoadedAccount.Id LIMIT 1]) {
      if(String.isNotBlank(theAccount.Type) && theAccount.Type.equalsIgnoreCase('Realtor Agent')) {
        isRealtorAgentAccount = true;
      }
    }

    theRealtorAgentOwnCoShow = false;
    if(isRealtorAgentAccount) {
      // Account relationship record type Id.
      Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

      Id theRealtorOfficeId = null;
      Boolean theRealtorOfficeOwnCoShow = false;
      Boolean theBrokerOwnCoShow = false;
      for(Account_Relationship__c theRelationship : [SELECT Parent_Account__c, Parent_Account__r.Own_CoShow__c FROM Account_Relationship__c
                                                     WHERE Child_Account__c = :theLoadedAccount.Id AND Is_Parent_Primary__c = true AND
                                                     Parent_Account__r.Type = 'Realtor Office' AND RecordTypeId = :accountRelationshipRecordTypeId
                                                     LIMIT 1]) {
        theRealtorOfficeId = theRelationship.Parent_Account__c;
        theRealtorOfficeOwnCoShow = theRelationship.Parent_Account__r.Own_CoShow__c;
      }

      if(theRealtorOfficeOwnCoShow && theRealtorOfficeId != null) {
        for(Account_Relationship__c theRelationship : [SELECT Parent_Account__c, Parent_Account__r.Own_CoShow__c FROM Account_Relationship__c
                                                       WHERE Child_Account__c = :theRealtorOfficeId AND Is_Parent_Primary__c = true AND
                                                       Parent_Account__r.Type = 'Broker' AND RecordTypeId = :accountRelationshipRecordTypeId
                                                       LIMIT 1]) {
          theBrokerOwnCoShow = theRelationship.Parent_Account__r.Own_CoShow__c;
        }
      }

      if(theRealtorOfficeOwnCoShow && theBrokerOwnCoShow) {
        theRealtorAgentOwnCoShow = true;
      }
    }
  }
}