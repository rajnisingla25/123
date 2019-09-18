//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Name: ContactTriggerHandler
// For Trigger: ContactTrigger
// On SObject: Contact
// Description: Trigger on contact object to prevent inactivating a contact when contact is primary on any account in account relationship object.
// If contact passes rules to be inactivated, it's affiliations (account relationship records) are also inactivated.
//
// 13th March 2015    Hemendra Singh Bhati   Original (Task # T-369907)
// 23rd March 2015    Hemendra Singh Bhati   Modified (Task # T-372662) - Complete Code Refactored.
// 6th April 2015    Kirti Agarwal   Original (Task # T-376542)
// 24th Jan 2019 Venkat Arisa- Added createOptInOutWhenDoNotContact Method
//
public with sharing class ContactTriggerHandler {
  private integer batchSize = 0;
  private boolean isExecuting = false;
  private ContactTriggerHandlerManager theManager = null;

  public ContactTriggerHandler(Boolean isExecuting, Integer size) {
    batchSize = size;
    isExecuting = isExecuting;
    theManager = new ContactTriggerHandlerManager();
  }

  public void onBeforeUpdate(Map<Id, Contact> contactsNewMap, Map<Id, Contact> contactsOldMap) {
    // Turn on/off contact inactivation validation logics.
    if(Switch_ContactTrigger__c.getInstance().Set_Contact_Inactivation_Validation_Off__c == false) {
        theManager.preventPrimaryAndBillingContactInactivation(contactsNewMap, contactsOldMap);
    }
  }

   public void onAfterInsert(Map<Id, Contact> contactsNewMap) {
    // Turn on/off Web service callout logics.
    if(Switch_ContactTrigger__c.getInstance().Set_CDH_Webservice_Callout_Off__c == false) {
        theManager.webserviceCallout(contactsNewMap.values(), null);
    }
  }

   public void onAfterUpdate(Map<Id, Contact> contactsNewMap, Map<Id, Contact> contactsOldMap) {
    // Turn on/off Web service callout logics
    if(Switch_ContactTrigger__c.getInstance().Set_CDH_Webservice_Callout_Off__c == false) {
        theManager.webserviceCallout(contactsNewMap.values(), contactsOldMap);
    }
       //theManager.updateSMSOptIn(contactsOldMap.values(), contactsNewMap);
       theManager.updateCMWhenDoNotContact(contactsNewMap,contactsOldMap); 
  }
}