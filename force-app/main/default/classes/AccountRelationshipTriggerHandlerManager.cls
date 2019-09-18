//
// (c) 2015 Appirio, Inc. 
//
// Trigger Handler Manager: AccountRelationshipTriggerHandlerManager
// For Trigger Handler: AccountRelationshipTriggerHandler
// For Trigger: AccountRelationshipTrigger
// On SObject: Account Relationship (Account_Relationship__c)
// Description: For "Account Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Child Account".
// For "Contact Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Contact To" +
// "Contact Role(Primary Contact/Billing Contact)". Also, auto-populates 'Account.Parent_Broker__c' and validate primary parent account.
// The billing contact cannot be marked inactive if there is no other billing contact associated with that account.
//
// User Story Acceptance Criteria Updated on 29th April 2015 For Issue # I-157451 - A duplicate contact relationship should not be allowed
// irrespective of contact role. The new unique key for contact relationship records is "Parent Account" + "Contact To".
//
// 23rd March 2015    Hemendra Singh Bhati    Original (Task # T-372661)
// 26th March 2015    Hemendra Singh Bhati    Modified (Task # T-373693)  - Complete code re-factored.
// 01st April 2015    Hemendra Singh Bhati    Modified (Task # T-374701)  - Removed active flag from all unique combinations for both
//                                                                          "Account Relationship" and "Contact Relationship" record types.
// 09th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added Method: populateAccountParentBroker(). Added logic to
//                                                                          auto-populate 'Account.
//                                                                          '.
// 10th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added Method: validatePrimaryParentAccount(). Added logic to
//                                                                          validate primary parent account.
// 24th April 2015    Hemendra Singh Bhati    Modified (Issue # I-155139) - The billing contact cannot be marked inactive if there is no other
//                                                                        - billing contact associated with that account.
//                                                                        - Added Method: validateBillingContactDeactivation().
// 29th April 2015    Hemendra Singh Bhati    Modified (Issue # I-157451) - A duplicate contact relationship should not be allowed irrespective
//                                                                        - of contact role.
//                                                                        - Updated Methods: validateAccountRelationshipRecords(), 
//                                                                        - validateExistingContactRelationshipTypeRecords().
// 06th May 2015      Hemendra Singh Bhati    Modified (Task # T-392803)  - Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a
//                                                                        - new record on 'Account_Relationship__c' object is created and whenever
//                                                                        - the "Active" field is updated to "False".
//                                                                        - Added Method: updateIsSentToCDH().
// 27th May 2015      Ravindra Shekhawat      Modified (Task # T-)        - Added code for rolling up Agent/Office on brokers and agents on office and
//                                                                        - brokers
//                                                                                                                                              - Added Methods: processOldAccounts(), processAgentRelationship()
//                                                                        - processOfficeRelationship(), filterChildOfficeAgents(),
//                                                                        - filterAccountRelationships(), rollUpAccounts().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166269) - Deleted Methods: processOldAccounts(), processAgentRelationship(),
//                                                                        - processOfficeRelationship(), filterChildOfficeAgents(), rollUpAccounts().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166282) - Added Method: computeTotalAgentsAndTotalOffices().
// 06th June 2016     Krishna Veni Bodala     Modified (LEAP  # 8761)     - Added code to not to reset the is_sent_to_CDH falg for the batchintegration user id
public class AccountRelationshipTriggerHandlerManager {
  private final String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';
  private final String CONTACT_RELATIONSHIP_RECORD_TYPE = 'Contact Relationship';
  private Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
  private Id AccRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;  
  private final String ACCOUNT_TYPE_BROKER = 'Broker';
  private final String ACCOUNT_TYPE_REALTOR_OFFICE = 'Realtor Office';
  private final String ACCOUNT_TYPE_REALTOR_AGENT = 'Realtor Agent';

  // Error Messages.
  private String accountTypeErrorMessage = ''; 
  private String contactTypeErrorMessage = '';
  

  /*
  @method      : validateBillingContactDeactivation
  @description : Validating billing contact for contact relationship records.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateBillingContactDeactivation(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                                 Boolean isInsert) {
    // Contact relationship record type Id.
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Processing newly created/updated contact relationship records.
    Set<Id> toBeIgnored = new Set<Id>();
    Map<Id, List<Account_Relationship__c>> parentAccountMapping = new Map<Id, List<Account_Relationship__c>>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(theAccountRelationship.RecordTypeId != contactRelationshipRecordTypeId || theAccountRelationship.Parent_Account__c == null) {
            continue;
        }

      if(isInsert && String.isBlank(theAccountRelationship.Contact_Role__c)) {
        if(!parentAccountMapping.containsKey(theAccountRelationship.Parent_Account__c)) {
            parentAccountMapping.put(theAccountRelationship.Parent_Account__c, new List<Account_Relationship__c>());
        }
        parentAccountMapping.get(theAccountRelationship.Parent_Account__c).add(theAccountRelationship);
      }
      else if(
        !isInsert &&
        (
          (
            theAccountRelationship.Billing_Contact__c == true &&
            oldMap.get(theAccountRelationship.Id).Active__c == true &&
            theAccountRelationship.Active__c == false
          ) ||
          (
            oldMap.get(theAccountRelationship.Id).Billing_Contact__c == true &&
            theAccountRelationship.Billing_Contact__c == false &&
            String.isBlank(theAccountRelationship.Contact_Role__c)
          ) ||
          (String.isNotBlank(oldMap.get(theAccountRelationship.Id).Contact_Role__c) && String.isBlank(theAccountRelationship.Contact_Role__c))
        )
      ) {
        if(!parentAccountMapping.containsKey(theAccountRelationship.Parent_Account__c)) {
          parentAccountMapping.put(theAccountRelationship.Parent_Account__c, new List<Account_Relationship__c>());
        }
        parentAccountMapping.get(theAccountRelationship.Parent_Account__c).add(theAccountRelationship);
        toBeIgnored.add(theAccountRelationship.Id);
      }
    }
    system.debug('TRACE: parentAccountMapping - ' + parentAccountMapping);
    system.debug('TRACE: toBeIgnored - ' + toBeIgnored);

    // Processing parent account mapping with contact relationship records.
    // Here, we are finding out whether the data set to process has an active billing contact for a parent account.
    // If it has, then we will ignore that parent account.
    // And if there is no active billing contact found, we will compare the data set with existing contact relationship records.
    // Here, the data set means the newly inserted/updated contact relationship records.
    Boolean hasBillingContact;
    Set<Id> parentAccountIds = new Set<Id>();
    for(Id parentAccountId : parentAccountMapping.keySet()) {
        hasBillingContact = false;
        for(Account_Relationship__c theAccountRelationship : parentAccountMapping.get(parentAccountId)) {
            if(theAccountRelationship.Billing_Contact__c == true && theAccountRelationship.Active__c == true) {
                hasBillingContact = true;
                break;
            }
        }

      if(!hasBillingContact) {
        parentAccountIds.add(parentAccountId);
      }
    }

    // Extracting existing contact relationship records.
    if(parentAccountIds.size() > 0) {
        Set<Id> parentAccountsWithActiveBillingContact = new Set<Id>();
        for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c FROM Account_Relationship__c
                                                              WHERE RecordTypeId = :contactRelationshipRecordTypeId AND
                                                              Parent_Account__c IN :parentAccountIds AND Billing_Contact__c = true AND
                                                              Active__c = true AND Id NOT IN :toBeIgnored]) {
            parentAccountsWithActiveBillingContact.add(theAccountRelationship.Parent_Account__c);
        }
        system.debug('TRACE: parentAccountsWithActiveBillingContact - ' + parentAccountsWithActiveBillingContact);

      Account_Relationship__c theAccountRelationship = null;
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Id parentAccountId : parentAccountIds) {
        if(!parentAccountsWithActiveBillingContact.contains(parentAccountId)) {
            theAccountRelationship = parentAccountMapping.get(parentAccountId).get(0);
           // theAccountRelationship.addError(
          //  'Billing contact must be enabled and active since there is no other active billing contact associated with the parent account. ' + 
        //    '[Parent Account URL: ' + baseURL + theAccountRelationship.Parent_Account__c + ']\r\n'
         // );
        }
      }
    }
  }

  /*
  @method      : validatePrimaryParentAccount
  @description : Validating primary parent account.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validatePrimaryParentAccount(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Account relationship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Error Message.
      String errorMessage = 'The selected child account already has a parent marked as primary in the following records:\r\n';

    // Filtering new values.
      Set<Id> primaryParentAccountIds = new Set<Id>();
      Set<Id> childAccountIds = new Set<Id>();

      Map<Id, String> childAccountIdAndItsType = new Map<Id, String>();
      Map<Id, String> primaryParentAccountIdAndItsType = new Map<Id, String>();

    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
      if(theAccountRelationship.RecordTypeId != accountRelationshipRecordTypeId) {
        continue;
        }

      if(isInsert) {
        if(
          theAccountRelationship.Parent_Account__c != null &&
          theAccountRelationship.Child_Account__c != null &&
          theAccountRelationship.Is_Parent_Primary__c == true
        ) {
          filteredNewValues.add(theAccountRelationship);
          primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
          childAccountIds.add(theAccountRelationship.Child_Account__c);
            }
        }
        else {
            if(
              theAccountRelationship.Parent_Account__c != null &&
              theAccountRelationship.Child_Account__c != null &&
              theAccountRelationship.Is_Parent_Primary__c == true &&
              (
                oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c ||
                oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c ||
            oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c
              )
            ) {
                filteredNewValues.add(theAccountRelationship);
                primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
                childAccountIds.add(theAccountRelationship.Child_Account__c);
            }
        }
    }
    system.debug('TRACE: filteredNewValues - ' + filteredNewValues);
    system.debug('TRACE: primaryParentAccountIds - ' + primaryParentAccountIds);
    system.debug('TRACE: childAccountIds - ' + childAccountIds);

    // Determining primary parent account and child account types.
    Set<Id> accountIds = new Set<Id>();
    accountIds.addAll(primaryParentAccountIds);
    accountIds.addAll(childAccountIds);
    for(Account theAccount : [SELECT Id, Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER
                              OR Type = :ACCOUNT_TYPE_REALTOR_AGENT) AND Id IN :accountIds]) {
      if(primaryParentAccountIds.contains(theAccount.Id)) {
        primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }
      else if(childAccountIds.contains(theAccount.Id)) {
        childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }
    }
    system.debug('TRACE: primaryParentAccountIdAndItsType - ' + primaryParentAccountIdAndItsType);
    system.debug('TRACE: childAccountIdAndItsType - ' + childAccountIdAndItsType);

    // Processing filtered new values.
    primaryParentAccountIds = new Set<Id>();
    childAccountIds = new Set<Id>();
    if(filteredNewValues.size() > 0) {
      if(filteredNewValues.size() > 1) {
        Boolean hasError = false;
        for(Integer i = 0;i < filteredNewValues.size() - 1; i++) {
            for(Integer j = i + 1;j < filteredNewValues.size(); j++) {
                hasError = false;
                if(
             filteredNewValues.get(i).Parent_Account__c != filteredNewValues.get(j).Parent_Account__c &&
             filteredNewValues.get(i).Child_Account__c == filteredNewValues.get(j).Child_Account__c
                ) {
              if(
                childAccountIdAndItsType.containsKey(filteredNewValues.get(i).Child_Account__c) &&
                childAccountIdAndItsType.get(filteredNewValues.get(i).Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(i).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(i).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(j).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(j).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)
              ) {
                hasError = true;
                filteredNewValues.get(i).addError(errorMessage + 'Parent Account: ' + filteredNewValues.get(j).Parent_Account__c + ', ' +
                + 'Child Account: ' + filteredNewValues.get(j).Child_Account__c + '\r\n');
              }
              else if(
                childAccountIdAndItsType.containsKey(filteredNewValues.get(i).Child_Account__c) &&
                childAccountIdAndItsType.get(filteredNewValues.get(i).Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(i).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(i).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER) &&
                primaryParentAccountIdAndItsType.containsKey(filteredNewValues.get(j).Parent_Account__c) &&
                primaryParentAccountIdAndItsType.get(filteredNewValues.get(j).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)
              ) {
                hasError = true;
                filteredNewValues.get(i).addError(errorMessage + 'Parent Account: ' + filteredNewValues.get(j).Parent_Account__c + ', ' +
                + 'Child Account: ' + filteredNewValues.get(j).Child_Account__c + '\r\n');
              }
                }
            if(hasError == false) {
              primaryParentAccountIds.add(filteredNewValues.get(i).Parent_Account__c);
              primaryParentAccountIds.add(filteredNewValues.get(j).Parent_Account__c);

              childAccountIds.add(filteredNewValues.get(i).Child_Account__c);
              childAccountIds.add(filteredNewValues.get(j).Child_Account__c);
                }
            }
          }
      }
      else if(filteredNewValues.size() == 1) {
        primaryParentAccountIds.add(filteredNewValues.get(0).Parent_Account__c);
        childAccountIds.add(filteredNewValues.get(0).Child_Account__c);
      }
      system.debug('TRACE: primaryParentAccountIds - ' + primaryParentAccountIds);
      system.debug('TRACE: childAccountIds - ' + childAccountIds);

      // Extracting existing primary parent account Ids and child account Ids.
      Set<Id> existingPrimaryParentAccountIds = new Set<Id>();
      Set<Id> existingchildAccountIds = new Set<Id>();
      List<Account_Relationship__c> theExistingRecords = [SELECT Id, Name, Parent_Account__c, Child_Account__c FROM Account_Relationship__c
                                                          WHERE Child_Account__c IN :childAccountIds AND Is_Parent_Primary__c = true];
      for(Account_Relationship__c theAccountRelationship : theExistingRecords) {
        existingPrimaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        existingchildAccountIds.add(theAccountRelationship.Child_Account__c);
      }

        // Determining primary parent account and child account types.
        accountIds = new Set<Id>();
        accountIds.addAll(existingPrimaryParentAccountIds);
        accountIds.addAll(existingchildAccountIds);
        for(Account theAccount : [SELECT Id, Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER
                                  OR Type = :ACCOUNT_TYPE_REALTOR_AGENT) AND Id IN :accountIds]) {
          if(existingPrimaryParentAccountIds.contains(theAccount.Id)) {
            primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
          }
          else if(existingchildAccountIds.contains(theAccount.Id)) {
            childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
          }
        }
      system.debug('TRACE: primaryParentAccountIdAndItsType - ' + primaryParentAccountIdAndItsType);
      system.debug('TRACE: childAccountIdAndItsType - ' + childAccountIdAndItsType);

      // Determining the usage of above primary parent account Ids in existing records.
      String childAccountType = '';
      String primaryParentAccountType = '';
      Map<Id, List<Account_Relationship__c>> childAccountIdAndItsInstancesMapping = new Map<Id, List<Account_Relationship__c>>();
      for(Account_Relationship__c theAccountRelationship : theExistingRecords) {
        childAccountType = childAccountIdAndItsType.get(theAccountRelationship.Child_Account__c);
        primaryParentAccountType = primaryParentAccountIdAndItsType.get(theAccountRelationship.Parent_Account__c);

        system.debug('TRACE: childAccountType - ' + childAccountType);
        system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountType);

        if(
         String.isNotBlank(childAccountType) &&
         String.isNotBlank(primaryParentAccountType) &&
         (
          (childAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT) && primaryParentAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) ||
          (childAccountType.equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) && primaryParentAccountType.equalsIgnoreCase(ACCOUNT_TYPE_BROKER))
         )
        ) {
            if(!childAccountIdAndItsInstancesMapping.containsKey(theAccountRelationship.Child_Account__c)) {
              childAccountIdAndItsInstancesMapping.put(theAccountRelationship.Child_Account__c, new List<Account_Relationship__c>());
            }
            childAccountIdAndItsInstancesMapping.get(theAccountRelationship.Child_Account__c).add(theAccountRelationship);
        }
      }
      system.debug('TRACE: childAccountIdAndItsInstancesMapping - ' + childAccountIdAndItsInstancesMapping);

      // Processing re-filtered new values.
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
          if(childAccountIdAndItsInstancesMapping.containsKey(theAccountRelationship.Child_Account__c)) {
            primaryParentAccountType = primaryParentAccountIdAndItsType.get(theAccountRelationship.Parent_Account__c);
            system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountType);

            for(Account_Relationship__c theExistingRecord : childAccountIdAndItsInstancesMapping.get(theAccountRelationship.Child_Account__c)) {
                if(isInsert || (theAccountRelationship.Id != theExistingRecord.Id)) {
                    system.debug('TRACE: primaryParentAccountType - ' + primaryParentAccountIdAndItsType.get(theExistingRecord.Parent_Account__c));
                    if(primaryParentAccountType == primaryParentAccountIdAndItsType.get(theExistingRecord.Parent_Account__c)) {
                theAccountRelationship.addError(errorMessage + theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n');
                    }
                }
            }
          }
      }
      }
  }

  /*
  @method      : validateAccountRelationshipRecords
  @description : Validating Account Relationship Records Uniqueness.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateAccountRelationshipRecords(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                                 Boolean isInsert) {
    // Categorizing new values on the basis of record type.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    List<Account_Relationship__c> newAccountTypeValues = new List<Account_Relationship__c>();
    List<Account_Relationship__c> newContactTypeValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theNewRecord : newValues) {
        if(theNewRecord.RecordTypeId == accountRelationshipRecordTypeId) {
            newAccountTypeValues.add(theNewRecord);
        }
        else if(theNewRecord.RecordTypeId == contactRelationshipRecordTypeId) {
            newContactTypeValues.add(theNewRecord);
        }
    }
    system.debug('TRACE: newAccountTypeValues - ' + newAccountTypeValues);
    system.debug('TRACE: newContactTypeValues - ' + newContactTypeValues);

    // Account Type Error Message.
    accountTypeErrorMessage = 'The account relationship with the given combination of parent account and child account';
    //accountTypeErrorMessage += ' is already in use. Please select a different combinaton or activate the existing account relationship.';
    accountTypeErrorMessage += ' is already in use. Please select a different combinaton.';
    accountTypeErrorMessage += ' The account relationship record(s) using this combination is(are) as follows:\r\n';

    // Validating new account relationship type values for unique key: "Parent Account" + "Child Account".
    Set<Id> parentAccountIds = new Set<Id>();
    Set<Id> childAccountIds = new Set<Id>();
    if(newAccountTypeValues.size() > 1) {
      for(Integer i = 0;i < newAccountTypeValues.size() - 1; i++) {
        for(Integer j = i + 1;j < newAccountTypeValues.size(); j++) {
          if(
            newAccountTypeValues.get(j).Parent_Account__c == newAccountTypeValues.get(i).Parent_Account__c &&
            newAccountTypeValues.get(j).Child_Account__c == newAccountTypeValues.get(i).Child_Account__c
          ) {
              newAccountTypeValues.get(i).addError(
               accountTypeErrorMessage + 'Parent Account: ' + newAccountTypeValues.get(j).Parent_Account__c
               + ', Child Account: ' + newAccountTypeValues.get(j).Child_Account__c + '\r\n'
              );
          }
          else {
            parentAccountIds.add(newAccountTypeValues.get(i).Parent_Account__c);
            childAccountIds.add(newAccountTypeValues.get(i).Child_Account__c);

            parentAccountIds.add(newAccountTypeValues.get(j).Parent_Account__c);
            childAccountIds.add(newAccountTypeValues.get(j).Child_Account__c);
          }
        }
      }
    }
    else if(newAccountTypeValues.size() == 1) {
      parentAccountIds.add(newAccountTypeValues.get(0).Parent_Account__c);
      childAccountIds.add(newAccountTypeValues.get(0).Child_Account__c);
    }
    system.debug('TRACE: parentAccountIds - ' + parentAccountIds);
    system.debug('TRACE: childAccountIds - ' + childAccountIds);

    // Contact Type Error Message.
    contactTypeErrorMessage = 'The contact relationship with the given combination of parent account and contact';
    contactTypeErrorMessage += ' is already in use. Please select a different combinaton';
    contactTypeErrorMessage += ' or activate the existing contact relationship.';
    contactTypeErrorMessage += ' The contact relationship record(s) using this combination is(are) as follows:\r\n';

    // Validating new contact relationship type values for the unique key: "Parent Account" + "Contact To".
    Boolean hasError = false;
    Set<Id> contactToIds = new Set<Id>();
    if(newContactTypeValues.size() > 1) {
      for(Integer i = 0;i < newContactTypeValues.size() - 1; i++) {
        for(Integer j = i + 1;j < newContactTypeValues.size(); j++) {
          hasError = false;
          if(
            newContactTypeValues.get(j).Parent_Account__c == newContactTypeValues.get(i).Parent_Account__c &&
            newContactTypeValues.get(j).Contact_To__c == newContactTypeValues.get(i).Contact_To__c
          ) {
            hasError = true;
              newContactTypeValues.get(i).addError(
               contactTypeErrorMessage + 'Parent Account: ' + newContactTypeValues.get(j).Parent_Account__c
               + ', Contact To: ' + newContactTypeValues.get(j).Contact_To__c + '\r\n'
              );
          }
          if(!hasError) {
            parentAccountIds.add(newContactTypeValues.get(i).Parent_Account__c);
            contactToIds.add(newContactTypeValues.get(i).Contact_To__c);

            parentAccountIds.add(newContactTypeValues.get(j).Parent_Account__c);
            contactToIds.add(newContactTypeValues.get(j).Contact_To__c);
          }
        }
      }
    }
    else if(newContactTypeValues.size() == 1) {
      parentAccountIds.add(newContactTypeValues.get(0).Parent_Account__c);
      contactToIds.add(newContactTypeValues.get(0).Contact_To__c);
    }
    system.debug('TRACE: parentAccountIds - ' + parentAccountIds);
    system.debug('TRACE: contactToIds - ' + contactToIds);

    // Extracting existing records and categorizing them on the basis of record type.
    String theUniqueKey = '';
    Map<String, List<Account_Relationship__c>> uniqueKeyAndExistingAccountTypeRecordsMapping = new Map<String, List<Account_Relationship__c>>();
    Map<String, List<Account_Relationship__c>> uniqueKeyAndExistingContactTypeRecordsMapping = new Map<String, List<Account_Relationship__c>>();
//    if(!parentAccountIds.isEmpty() || !childAccountIds.isEmpty())
    for(Account_Relationship__c theExistingRecord : [SELECT Id, Name, Parent_Account__c, Child_Account__c, Contact_To__c, RecordTypeId
                                                     FROM Account_Relationship__c WHERE (Parent_Account__c != null 
                                                     AND ((Child_Account__c != null) OR (Contact_To__c != null)) 
                                                     AND ((Parent_Account__c IN :parentAccountIds AND
                                                     Child_Account__c IN :childAccountIds) OR (Parent_Account__c IN
                                                     :parentAccountIds AND Contact_To__c IN :contactToIds AND Active__c = true)))]) {
      if(theExistingRecord.RecordTypeId == accountRelationshipRecordTypeId) {
        theUniqueKey = String.valueOf(theExistingRecord.Parent_Account__c) + '__' + String.valueOf(theExistingRecord.Child_Account__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(!uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
            uniqueKeyAndExistingAccountTypeRecordsMapping.put(theUniqueKey, new List<Account_Relationship__c>());
        }
        uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey).add(theExistingRecord);
      }
      else if(theExistingRecord.RecordTypeId == contactRelationshipRecordTypeId) {
        theUniqueKey = String.valueOf(theExistingRecord.Parent_Account__c) + '__' + String.valueOf(theExistingRecord.Contact_To__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(!uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
          uniqueKeyAndExistingContactTypeRecordsMapping.put(theUniqueKey, new List<Account_Relationship__c>());
        }
        uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey).add(theExistingRecord);
      }
    }
    system.debug('TRACE: uniqueKeyAndExistingAccountTypeRecordsMapping - ' + uniqueKeyAndExistingAccountTypeRecordsMapping);
    system.debug('TRACE: uniqueKeyAndExistingContactTypeRecordsMapping - ' + uniqueKeyAndExistingContactTypeRecordsMapping);

    if(uniqueKeyAndExistingAccountTypeRecordsMapping.size() > 0) {
        validateExistingAccountRelationshipTypeRecords(newAccountTypeValues, uniqueKeyAndExistingAccountTypeRecordsMapping, oldMap, isInsert);
    }
    if(uniqueKeyAndExistingContactTypeRecordsMapping.size() > 0) {
        validateExistingContactRelationshipTypeRecords(newContactTypeValues, uniqueKeyAndExistingContactTypeRecordsMapping, oldMap, isInsert);
    }
  }

  /*
  @method      : validateExistingAccountRelationshipTypeRecords
  @description : Validating existing account relationship type records.
  @params      : List<Account_Relationship__c> newAccountTypeValues, Map<String, List<Account_Relationship__c>>
               : uniqueKeyAndExistingAccountTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateExistingAccountRelationshipTypeRecords(List<Account_Relationship__c> newAccountTypeValues, Map<String, List<Account_Relationship__c>>
                                                             uniqueKeyAndExistingAccountTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap,
                                                             Boolean isInsert) {
    // Validating new account type records with existing account relationship records for
    // unique key: "Parent Account" + "Child Account".
    String theUniqueKey = '';
    Boolean hasError = false;
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theNewRecord : newAccountTypeValues) {
        hasError = false;
        theUniqueKey = String.valueOf(theNewRecord.Parent_Account__c) + '__' + String.valueOf(theNewRecord.Child_Account__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(isInsert) {
        if(uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
            for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey)) {
            accountTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
            }
          theNewRecord.addError(accountTypeErrorMessage);
        }
        }
        else {
          if(
          (oldMap.get(theNewRecord.Id).Parent_Account__c != theNewRecord.Parent_Account__c ||
          oldMap.get(theNewRecord.Id).Child_Account__c != theNewRecord.Child_Account__c)
        ) {
            if(uniqueKeyAndExistingAccountTypeRecordsMapping.containsKey(theUniqueKey)) {
              for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingAccountTypeRecordsMapping.get(theUniqueKey)) {
                if(theExistingRecord.Id != theNewRecord.Id) {
                    hasError = true;
                accountTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
              }
              if(hasError) {
              theNewRecord.addError(accountTypeErrorMessage);
              }
            }
          }
        }
    }
  }
  
  /*
  @method      : validateOfficeIsAssociteWithOneBroker
  @description :  Validating an active Office is associte to a single Broker record only.
  @params      : List<Account_Relationship__c> newAccountRelList,Map<Id, Account_Relationship__c> oldIdToAccountRelMap, Boolean isInsert
  @returns     : void
  */
  public void validateOfficeIsAssociteWithOneBroker(List<Account_Relationship__c> newAccountRelList, Map<Id, Account_Relationship__c> oldIdToAccountRelMap,
                                                             Boolean isInsert) {
    //  Validating one active Office is associte to a single Broker record only. 
    
    
    String baseURL           = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    string validationErrorMessage   = '';
    map<id,list<Account_Relationship__c>> childAccountIdToAccRelRecord = new map<id,list<Account_Relationship__c>>();
    
    for( Account_Relationship__c accRel  : newAccountRelList){
      if( accRel.Child_Account_Type__c == 'Realtor Office' 
          && (accRel.Parent_Account_Type__c == 'Broker' 
            || accRel.Parent_Account_Type__c == 'Region'
            || accRel.Parent_Account_Type__c == 'Agent Team'
            || accRel.Parent_Account_Type__c == 'Franchise Company'
            || accRel.Parent_Account_Type__c == 'Broker Council')
          && accRel.Active__c && accRel.RecordTypeDeveloperName__c == 'Account_Relationship'){
        if( !childAccountIdToAccRelRecord.containsKey( accRel.Child_Account__c ) ){
          childAccountIdToAccRelRecord.put( accRel.Child_Account__c, new list<Account_Relationship__c>());
        }
        childAccountIdToAccRelRecord.get( accRel.Child_Account__c ).add( accRel );
      }
    }//End For
    
    if( !childAccountIdToAccRelRecord.isEmpty() ){
      
      map<id,list<Account_Relationship__c>> childAccIdAlreadyHavingBrokerMap = new map<id,list<Account_Relationship__c>>();
      
      for( Account_Relationship__c accRel : [   select   Child_Account__c,
                                Name,
                                Id,
                                Parent_Account_Type__c
                          from Account_Relationship__c
                          where 
                            Child_Account__c IN :childAccountIdToAccRelRecord.keySet()
                            AND
                            Active__c = true
                            AND
                            RecordType.DeveloperName = 'Account_Relationship'
                            AND
                            Parent_Account_Type__c in ('Broker','Region','Agent Team','Franchise Company','Broker Council')
                            AND
                            ID Not IN :newAccountRelList
                          limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()]){
      
        if( !childAccIdAlreadyHavingBrokerMap.containsKey( accRel.Child_Account__c ) ){
          childAccIdAlreadyHavingBrokerMap.put( accRel.Child_Account__c, new list<Account_Relationship__c>());
        }
        childAccIdAlreadyHavingBrokerMap.get( accRel.Child_Account__c ).add( accRel );
      }//End For
      
      if( !childAccIdAlreadyHavingBrokerMap.isEmpty() ){
        
        for( Id childAccId : childAccIdAlreadyHavingBrokerMap.keySet() ){
          
          if( childAccountIdToAccRelRecord.containsKey( childAccId ) ){
            
            for( Account_Relationship__c accRelCurrent : childAccountIdToAccRelRecord.get( childAccId ) ){
              for( Account_Relationship__c accRelHavingBroker : childAccIdAlreadyHavingBrokerMap.get( childAccId ) ){
                
                if( accRelCurrent.Parent_Account_Type__c ==  accRelHavingBroker.Parent_Account_Type__c && accRelCurrent.Name != accRelHavingBroker.Name ){
                  validationErrorMessage   = 'The selected child account (Realtor Office) is already associted and active with the other '+accRelHavingBroker.Parent_Account_Type__c+' account. ';
                  validationErrorMessage       += 'The account relationship record using this combination is:\r\n';
                  validationErrorMessage += accRelHavingBroker.Name + ' [Record URL - ';
                  validationErrorMessage += baseURL + accRelHavingBroker.Id + ']\r\n';
                  accRelCurrent.addError( validationErrorMessage );
                  break;
                }
              }
            }
          }
        }
      }//End IF !childAccIdAlreadyHavingBrokerMap.isEmpty() 
    }
  }

  /*
  @method      : validateExistingContactRelationshipTypeRecords
  @description : Validating existing contact relationship type records.
  @params      : List<Account_Relationship__c> newContactTypeValues, Map<String, List<Account_Relationship__c>>
               : uniqueKeyAndExistingContactTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void validateExistingContactRelationshipTypeRecords(List<Account_Relationship__c> newContactTypeValues, Map<String, List<Account_Relationship__c>>
                                                             uniqueKeyAndExistingContactTypeRecordsMapping, Map<Id, Account_Relationship__c> oldMap,
                                                             Boolean isInsert) {
    // Validating new contact type records with existing contact relationship records for unique key: "Parent Account" + "Contact To".
    String theUniqueKey = '';
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      for(Account_Relationship__c theNewRecord : newContactTypeValues) {
        theUniqueKey = String.valueOf(theNewRecord.Parent_Account__c) + '__' + String.valueOf(theNewRecord.Contact_To__c);
        theUniqueKey = theUniqueKey.toLowerCase();
        if(isInsert) {
        if(uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
            for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey)) {
            contactTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
                theNewRecord.addError(contactTypeErrorMessage);
        }
        }
        else {
          if(
           oldMap.get(theNewRecord.Id).Parent_Account__c != theNewRecord.Parent_Account__c ||
           oldMap.get(theNewRecord.Id).Contact_To__c != theNewRecord.Contact_To__c
          ) {
            if(uniqueKeyAndExistingContactTypeRecordsMapping.containsKey(theUniqueKey)) {
              for(Account_Relationship__c theExistingRecord : uniqueKeyAndExistingContactTypeRecordsMapping.get(theUniqueKey)) {
                if(theExistingRecord.Id != theNewRecord.Id) {
                contactTypeErrorMessage += theExistingRecord.Name + ' [Record URL - ' + baseURL + theExistingRecord.Id + ']\r\n';
                }
              }
              theNewRecord.addError(contactTypeErrorMessage);
            }
          }
        }
    }
  }

  /*
  @method      : populateAccountParentBroker
  @description : Populating Custom Field 'Account.Parent_Broker__c'.
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void populateAccountParentBroker(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap,
                                          Boolean isInsert) {
    // Account relationship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
  //  Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
    Map<Id,Account> Acctupdate = New Map<Id,Account>();
    boolean emladrsupdated = false;                                          
    // Extracting new child account Ids.
    Set<Id> replacedChildAccountIds = new Set<Id>();
    Set<Id> newChildAccountIds = new Set<Id>();
    // CRM-3493 --update preferred phone like primary email on contact level
   /* Set<Id> conIds = new Set<Id>();
    string Tempphone;
    Map<Id,contact>contactmap = new map<Id,contact>();
      for(Account_Relationship__c theAccountRelationship : newValues) {
        if(theAccountRelationship.Contact_To__c!=null && theAccountRelationship.Contact_Role__c == 'Primary Contact' && theAccountRelationship.Relationship_Type__c == 'Contact')
            conIds.add(theAccountRelationship.contact_to__c);
    }     
        if(conIds!=null && conIds.size()>0){
            for(contact conRec: [select id,Preferred_Phone_Number__c,Preferred_Phone__c,HomePhone,MobilePhone,Work_Phone__c,Phone,OtherPhone from contact where id in: conIds] )  {
            contactmap.put(conRec.id,conRec);
        }
        }*/
    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(isInsert) {
          if(
           (theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) &&
           (theAccountRelationship.Child_Account__c != null)
          ) {
            newChildAccountIds.add(theAccountRelationship.Child_Account__c);
            filteredNewValues.add(theAccountRelationship);
          }
        }
        else {  
            // CRM-3493 --update preferred phone like primary email on contact level
          /*  if(theAccountRelationship.RecordTypeId == contactRelationshipRecordTypeId && contactmap.containskey(theAccountRelationship.contact_to__c)){
          if(contactmap.get(theAccountRelationship.contact_to__c).Preferred_Phone__c == 'Home'){
                Tempphone = contactmap.get(theAccountRelationship.contact_to__c).HomePhone;}
            else if (contactmap.get(theAccountRelationship.contact_to__c).Preferred_Phone__c == 'Mobile'){
            Tempphone = contactmap.get(theAccountRelationship.contact_to__c).MobilePhone;}
            else if (contactmap.get(theAccountRelationship.contact_to__c).Preferred_Phone__c == 'Work'){
                Tempphone = contactmap.get(theAccountRelationship.contact_to__c).Work_Phone__c;}
                else if (contactmap.get(theAccountRelationship.contact_to__c).Preferred_Phone__c == 'Other'){
                    Tempphone = contactmap.get(theAccountRelationship.contact_to__c).OtherPhone;}
            else {
                Tempphone = contactmap.get(theAccountRelationship.contact_to__c).Phone;}
             */
            //Replaced 'Primary_Email__c' with 'Email_Address__c' as part of Jira SMCI-554
            If(theAccountRelationship.Contact_Role__c == 'Primary Contact' &&
              (oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c ||
               oldMap.get(theAccountRelationship.Id).Contact_To__c  != theAccountRelationship.Contact_To__c ||
               (oldMap.get(theAccountRelationship.Id).Active__c  != theAccountRelationship.Active__c && theAccountRelationship.Active__c == TRUE))){
                Acctupdate.put(theAccountRelationship.Parent_Account__c,New Account(Id = theAccountRelationship.Parent_Account__c,
                                           Email_Address__c  = theAccountRelationship.Email_Address__c,
                                           Phone = theAccountRelationship.Preferred_Phone__c,
                                           Primary_Contact_Name__c = theAccountRelationship.contact_To__r.name));
            }
            //}
        if(
         (theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) &&
         (
          (oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c) ||
          (oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c) ||
          (oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c)
         )
        ) {
          newChildAccountIds.add(theAccountRelationship.Child_Account__c);
          filteredNewValues.add(theAccountRelationship);

          // Taking care of replaced child accounts.
          if(oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c) {
            newChildAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
            if(oldMap.get(theAccountRelationship.Id).Child_Account__c!=null)
            replacedChildAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
          }
        }
        }
    }

    // Resetting parent broker for replaced child accounts.
    if(replacedChildAccountIds.size() > 0) {
        Map<Id,Account> childAccountsToBeUpdated = new Map<Id,Account>();
        for(Id replacedChildAccountId : replacedChildAccountIds) {
            childAccountsToBeUpdated.Put(replacedChildAccountId,new Account(
              Id = replacedChildAccountId,
              Parent_Broker__c = null
            ));
        }
        for(Account acctt:Acctupdate.values()){
        childAccountsToBeUpdated.put(acctt.id,acctt);
        }
        update childAccountsToBeUpdated.values();
        emladrsupdated = true;
    }

    if(newChildAccountIds.size() > 0) {
        // Filtering child account Ids of type "Realtor Agent" and "Realtor Office" from new child account Ids extracted above.
        Set<Id> filteredChildAccountIds = new Set<Id>();
      Map<Id, String> childAccountIdAndItsType = new Map<Id, String>();
        for(Account theAccount : [SELECT Id,Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_AGENT OR Type = :ACCOUNT_TYPE_REALTOR_OFFICE)
                                  AND Id IN :newChildAccountIds]) {
          filteredChildAccountIds.add(theAccount.Id);
          childAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
        }

        // Determining primary parent account of child accounts filtered above.
        Set<Id> primaryParentAccountIds = new Set<Id>();
        Map<Id, Id> childAccountAndItsPrimaryParentAccount = new Map<Id, Id>();
        for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Child_Account__c FROM Account_Relationship__c
                                                              WHERE RecordTypeId = :accountRelationshipRecordTypeId AND Parent_Account__c != null
                                                            AND Is_Parent_Primary__c = true AND Child_Account__c IN :filteredChildAccountIds]) {
        childAccountAndItsPrimaryParentAccount.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
        primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        }

      // Processing filtered new values.
      for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
        if(
          !childAccountAndItsPrimaryParentAccount.containsKey(theAccountRelationship.Child_Account__c) &&
          theAccountRelationship.Is_Parent_Primary__c == true
        ) {
            childAccountAndItsPrimaryParentAccount.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
            primaryParentAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
      }

      // Determining primary parent account type.
      Map<Id, String> primaryParentAccountIdAndItsType = new Map<Id, String>();
      for(Account theAccount : [SELECT Id,Type FROM Account WHERE (Type = :ACCOUNT_TYPE_REALTOR_OFFICE OR Type = :ACCOUNT_TYPE_BROKER)
                                AND Id IN :primaryParentAccountIds]) {
        primaryParentAccountIdAndItsType.put(theAccount.Id, theAccount.Type);
      }

      // Updating child account field 'Account.Parent_Broker__c'.
      if(childAccountAndItsPrimaryParentAccount.size() > 0) {
        Id parentBrokerId = null;
        String childAccountType = '';
        String primaryParentAccountType = '';
        Map<Id,Account> childAccountsToBeUpdated = new Map<Id,Account>();
        Set<Id> findParentBroker = new Set<Id>();
          for(Id childAccountId : childAccountAndItsPrimaryParentAccount.keySet()) {
            parentBrokerId = null;
            childAccountType = childAccountIdAndItsType.get(childAccountId);
            primaryParentAccountType = primaryParentAccountIdAndItsType.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));

          if(childAccountType == ACCOUNT_TYPE_REALTOR_AGENT && primaryParentAccountType == ACCOUNT_TYPE_REALTOR_OFFICE) {
            parentBrokerId = null;
            findParentBroker.add(childAccountAndItsPrimaryParentAccount.get(childAccountId));
          }
          else if(childAccountType == ACCOUNT_TYPE_REALTOR_OFFICE && primaryParentAccountType == ACCOUNT_TYPE_BROKER) {
            parentBrokerId = childAccountAndItsPrimaryParentAccount.get(childAccountId);
          }

          if(parentBrokerId != null) {
              childAccountsToBeUpdated.put(childAccountId,new Account(
                Id = childAccountId,
                Parent_Broker__c = parentBrokerId
              ));
          }
          }

        if(findParentBroker.size() > 0) {
          // Extracting parent parent broker when child account is "Agent" and parent account is "Office".
          Map<Id, Id> parentParentBrokerMapping = new Map<Id, Id>();
            for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Child_Account__c,contact_to__r.Name FROM Account_Relationship__c
                                                                  WHERE RecordTypeId = :accountRelationshipRecordTypeId AND Parent_Account__c != null
                                                                  AND Is_Parent_Primary__c = true AND Child_Account__c IN :findParentBroker]) {
              parentParentBrokerMapping.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
            }

          // Updating "Agent" child account with parent parent broker account. 
          for(Id childAccountId : childAccountAndItsPrimaryParentAccount.keySet()) {
              parentBrokerId = null;
              childAccountType = childAccountIdAndItsType.get(childAccountId);
              primaryParentAccountType = primaryParentAccountIdAndItsType.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));

              if(childAccountType == ACCOUNT_TYPE_REALTOR_AGENT && primaryParentAccountType == ACCOUNT_TYPE_REALTOR_OFFICE) {
              if(parentParentBrokerMapping.containsKey(childAccountAndItsPrimaryParentAccount.get(childAccountId))) {
                parentBrokerId = parentParentBrokerMapping.get(childAccountAndItsPrimaryParentAccount.get(childAccountId));
              }
              }

              if(parentBrokerId != null) {
                childAccountsToBeUpdated.put(childAccountId,new Account(
                  Id = childAccountId,
                  Parent_Broker__c = parentBrokerId
                ));
              }
          }
        }

          if(childAccountsToBeUpdated.size() > 0) {
              If(!emladrsupdated){
                 for(Account acct:Acctupdate.values()){
                  childAccountsToBeUpdated.put(acct.id,acct);
                  }
                  emladrsupdated = true;
              }
              update childAccountsToBeUpdated.values();
          }
      }
    }
                                              
              If(!emladrsupdated){
                  Update Acctupdate.values();
                  emladrsupdated = true;
              }
                                              
  }
    
    
	//@method: updateAccountEmailPhone
     
     
	public void populateParentAccountEmailPhone(Map<Id, Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        List<Account> Acctupdate = new List<Account>();
        Map<Id, List<ContactMethod__c>> CMMapList = new Map<Id, List<ContactMethod__c>>();
        Set<Id> ConIdSet = new Set<Id>();
        List<ContactMethod__c> cmList = new List<ContactMethod__c>();
        List<ContactMethod__c> conmetList = new List<ContactMethod__c>();
        
        for(Account_Relationship__c ar : newValues.values()) {
            System.debug('ar:'+ar);
            //System.debug('oldMap.get(ar.Id):'+oldMap.get(ar.Id));
            if((isInsert || (!isInsert && (oldMap.get(ar.Id).Contact_Role__c != ar.Contact_Role__c 
                                           || oldMap.get(ar.Id).Contact_To__c != ar.Contact_To__c)))
               && ar.Contact_Role__c == 'Primary Contact'){
                ConIdSet.add(ar.Contact_To__c);
                   System.debug('ar:'+ar);
            }           	
        }
        System.debug('ConIdSet:'+ConIdSet);
        if(!ConIdSet.isEmpty()) {
            for(ContactMethod__c cm:[Select Id, Email__c, Phone__c, Primary_To_Contact__c, Phone_Extension__c, Value__c, Contact__c, Contact__r.Id, Type__c, Type_Purpose__c
                                     from ContactMethod__c Where Contact__c IN: ConIdSet and Active__c  = True order by LastModifiedDate Desc]){
                cmList.add(cm);
                if(CMMapList.containsKey(cm.Contact__r.Id)) {
                    List<ContactMethod__c> CMgetList = CMMapList.get(cm.Contact__r.Id);
                    CMgetList.add(cm);
                    CMMapList.put(cm.Contact__r.Id, CMgetList);
                } else {
                    CMMapList.put(cm.Contact__r.Id, new List<ContactMethod__c> { cm });
                }                                         
            }
        }
        System.debug('CMMapList:'+CMMapList);
        for(Account_Relationship__c ar : newValues.values()) {
            String BusinessPhoneCMId, PersonalPhoneCMId, BusinessmobileCMId, PersonalmobileCMId = null;
            if((isInsert || (!isInsert && (oldMap.get(ar.Id).Contact_Role__c != ar.Contact_Role__c 
                                           || oldMap.get(ar.Id).Contact_To__c != ar.Contact_To__c)))
               && ar.Contact_Role__c == 'Primary Contact'){
                   if(cmList != null && !cmList.isEmpty()){
                       Account acc = New Account();
                       acc.Id = ar.Parent_Account__c;
                       if(ar.Contact_To__c != null)
                            conmetList = CMMapList.get(ar.Contact_To__c);
                       if(!conmetList.isEmpty() && conmetList != null && conmetList.size()>0) {
                           acc.Mobile2_Other__c  = null;
                           acc.Other_Phone_Ext__c  = null;
                           acc.Work_Phone__c  = null;
                           acc.Work_Phone_Ext__c  = null;
                           acc.Mobile1__c = null;
                           acc.Home_Phone__c = null;
                           acc.Email_Address__c = null;
                           acc.PrimaryEmail_CMId__c = null;
                           acc.Type_Purpose__c = null;
                           acc.Phone = null;
                           acc.PrimaryPhone_CMId__c = null;
                           acc.Phone_Extension__c = null;
                           acc.Preferred_Phone__c = null;
                           acc.SMS_Phone__c = null;
                           acc.PrimarySMS_CMId__c = null;
                           for(ContactMethod__c cm: conmetList){
                               System.debug('cm:'+cm);
                               if(cm.Type__c == 'Email' && cm.Primary_To_Contact__c == true){                                   
                                   acc.Email_Address__c = cm.Email__c;
                                   acc.PrimaryEmail_CMId__c = cm.Id;
                                   acc.Type_Purpose__c = cm.Type_Purpose__c;
                               }
                               else if(cm.Type__c == 'Phone'){
                                   //acc.Id = ar.Parent_Account__c;
                                   if(cm.Primary_To_Contact__c == true) {
                                       acc.Phone = cm.Phone__c;
                                       acc.PrimaryPhone_CMId__c = cm.Id;
                                       acc.Phone_Extension__c = cm.Phone_Extension__c;
                                       acc.Preferred_Phone__c = cm.Type_Purpose__c;
                                   }
                                   if(cm.Type_Purpose__c == 'Business Mobile' || cm.Type_Purpose__c == 'Personal Mobile'){
                                        acc.SMS_Phone__c = cm.Phone__c;
                                        acc.PrimarySMS_CMId__c = cm.Id; 
                                   }                                   
                                   if(cm.Type_Purpose__c != 'BUSINESS_FAX') {
                                       System.debug('cm.Id:'+cm.Id);
                                       if(cm.Type_Purpose__c == 'BUSINESS_PHONE' && BusinessPhoneCMId == null){
                                           BusinessPhoneCMId = cm.Id;
                                           acc.Work_Phone__c  = cm.Phone__c;
                                           acc.Work_Phone_Ext__c  = cm.Phone_Extension__c;
                                       }                                
                                       if(cm.Type_Purpose__c == 'PERSONAL_PHONE' && PersonalPhoneCMId == null){
                                           PersonalPhoneCMId = cm.Id;
                                           acc.Home_Phone__c  = cm.Phone__c;
                                           acc.Other_Phone_Ext__c  = cm.Phone_Extension__c;
                                       }
                                       if(cm.Type_Purpose__c == 'BUSINESS_MOBILE' && BusinessmobileCMId == null){
                                           BusinessmobileCMId = cm.Id;
                                           acc.Mobile1__c = cm.Phone__c;                                            
                                       }
                                       if(cm.Type_Purpose__c == 'PERSONAL_MOBILE' && PersonalmobileCMId == null){
                                           PersonalmobileCMId = cm.Id;
                                           acc.Mobile2_Other__c = cm.Phone__c;
                                       }
                                   }
                               }
                           }
                       }
                       Acctupdate.add(acc);
                	}
            	}            	
            	System.debug('Acctupdate:'+Acctupdate);
            	cmList.clear();
            }
        if(!Acctupdate.isEmpty())
    		update Acctupdate;    
    }


  /*
  @method      : updateIsSentToCDH
  @description : Updating boolean field "Is_Sent_To_CDH__c" for both account and contact relationship records.
               : Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a new record on 'Account_Relationship__c' object
               : is created and whenever the "Active" field is updated to "False".
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void updateIsSentToCDH(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Processing new values.
    //Getting the user-Batch Integration user details to make the Is_Sent_to_CDH not reset
    system.debug('Batch User Id:');
    Id batchIntegrationUserId = Collection_Users__c.getInstance('batchintegration user').Id__c;

      system.debug('Batch User Id:' + batchIntegrationUserId);
    /*User batchIntegrationUser=[SELECT Id,Name
                               FROM User
                               WHERE Name='batchintegration user'
                               LIMIT 1
                              ];*/
    for(Account_Relationship__c theAccountRelationship : newValues) {
        if(isInsert) {
            theAccountRelationship.Is_Sent_to_CDH__c = false;
        }
        else if(
         !isInsert && 
         ((oldMap.get(theAccountRelationship.Id).Active__c == true &&
         theAccountRelationship.Active__c == false)|| 
          oldMap.get(theAccountRelationship.Id).Contact_Role__c != theAccountRelationship.Contact_Role__c) &&
         userInfo.getUserId() != batchIntegrationUserId
         //userInfo.getUserId() !=batchintegrationuser.Id
        ) {
            system.debug('theAccountRelationship:'+theAccountRelationship);
            theAccountRelationship.Is_Sent_to_CDH__c = false;
        }
        else if(
         !isInsert && 
         (oldMap.get(theAccountRelationship.Id).Active__c == false &&
         theAccountRelationship.Active__c == true)&&
         userInfo.getUserId() != batchIntegrationUserId
         //userInfo.getUserId() !=batchintegrationuser.Id
        ) {
            theAccountRelationship.Is_Sent_to_CDH__c = false;
            theAccountRelationship.External_ID__c = null;
            theAccountRelationship.End_Date__c = null;
            theAccountRelationship.Start_Date__c = system.today();
        }        
    }
  }

  /*
  @method      : computeTotalAgentsAndTotalOffices
  @description : Compute total agents on office account and total offices/agents on broker account.
  @params      : Map<Id, Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void computeTotalAgentsAndTotalOffices(Map<Id, Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
    // Extracting account relatioship record type Id.
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;

    // Extracting parent and child account Ids.
    // Processing newly inserted/updated account relatioship records.
    Set<Id> theAccountIds = new Set<Id>();
    List<Account_Relationship__c> filteredNewValues = new List<Account_Relationship__c>();
    for(Account_Relationship__c theAccountRelationship : newMap.values()) {
      if(theAccountRelationship.RecordTypeId == accountRelationshipRecordTypeId) {
        // Account Relatioships Inserted.
        if(
          (
            isInsert &&
            theAccountRelationship.Parent_Account__c != null &&
            theAccountRelationship.Child_Account__c != null &&
            theAccountRelationship.Is_Parent_Primary__c == true &&
            theAccountRelationship.Active__c == true
          )
        ) {
          theAccountIds.add(theAccountRelationship.Parent_Account__c);
          theAccountIds.add(theAccountRelationship.Child_Account__c);
          filteredNewValues.add(theAccountRelationship);
        }
        // Account Relatioships Updated.
        else if(
          !isInsert &&
          (
            oldMap.get(theAccountRelationship.Id).Parent_Account__c != theAccountRelationship.Parent_Account__c ||
            oldMap.get(theAccountRelationship.Id).Child_Account__c != theAccountRelationship.Child_Account__c ||
            oldMap.get(theAccountRelationship.Id).Is_Parent_Primary__c != theAccountRelationship.Is_Parent_Primary__c ||
            oldMap.get(theAccountRelationship.Id).Active__c != theAccountRelationship.Active__c
          )
        ) {
          filteredNewValues.add(theAccountRelationship);
  
          // Processing newly updated parent and child accounts.
          if(theAccountRelationship.Parent_Account__c != null) {
            theAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
          if(theAccountRelationship.Child_Account__c != null) {
            theAccountIds.add(theAccountRelationship.Child_Account__c);
          }
  
          // Taking care of replaced old parent and child accounts.
          if(oldMap.get(theAccountRelationship.Id).Parent_Account__c != null) {
            theAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
          if(oldMap.get(theAccountRelationship.Id).Child_Account__c != null) {
            theAccountIds.add(oldMap.get(theAccountRelationship.Id).Child_Account__c);
          }
        }
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountIds - ' + theAccountIds);
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - filteredNewValues - ' + filteredNewValues);

    // Extracting parent and child account types.
    Map<Id, String> theAccountAndTypeMapping = new Map<Id, String>();
    if(theAccountIds.size() > 0) {
      for(Account theAccount : [SELECT Id, Type FROM Account WHERE Id IN :theAccountIds AND Type != '']) {
        theAccountAndTypeMapping.put(theAccount.Id, theAccount.Type);
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountAndTypeMapping - ' + theAccountAndTypeMapping);

    // Processing filtered inserted/updated account relatioship records.
    // Extracting broker and office accounts to update.
    Set<Id> theBrokerAccountIds = new Set<Id>();
    Set<Id> theOfficeAccountIds = new Set<Id>();
    for(Account_Relationship__c theAccountRelationship : filteredNewValues) {
      if(
        isInsert &&
        theAccountAndTypeMapping.containsKey(theAccountRelationship.Parent_Account__c) &&
        theAccountAndTypeMapping.containsKey(theAccountRelationship.Child_Account__c)
      ) {
        if(
          theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER) &&
          theAccountAndTypeMapping.get(theAccountRelationship.Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)
        ) {
          theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
        else if(
          theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE) &&
          theAccountAndTypeMapping.get(theAccountRelationship.Child_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_AGENT)
        ) {
          theOfficeAccountIds.add(theAccountRelationship.Parent_Account__c);
        }
      }
      else if(!isInsert) {
        // Processing newly updated parent accounts.
        if(
          theAccountRelationship.Parent_Account__c != null &&
          theAccountAndTypeMapping.containsKey(theAccountRelationship.Parent_Account__c)
        ) {
          if(theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)) {
            theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
          else if(theAccountAndTypeMapping.get(theAccountRelationship.Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) {
            theOfficeAccountIds.add(theAccountRelationship.Parent_Account__c);
          }
        }

        // Taking care of replaced old parent accounts.
        if(
          oldMap.get(theAccountRelationship.Id).Parent_Account__c != null &&
          theAccountAndTypeMapping.containsKey(oldMap.get(theAccountRelationship.Id).Parent_Account__c)
        ) {
          if(theAccountAndTypeMapping.get(oldMap.get(theAccountRelationship.Id).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_BROKER)) {
            theBrokerAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
          else if(theAccountAndTypeMapping.get(oldMap.get(theAccountRelationship.Id).Parent_Account__c).equalsIgnoreCase(ACCOUNT_TYPE_REALTOR_OFFICE)) {
            theOfficeAccountIds.add(oldMap.get(theAccountRelationship.Id).Parent_Account__c);
          }
        }
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theBrokerAccountIds - ' + theBrokerAccountIds);
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theOfficeAccountIds - ' + theOfficeAccountIds);

    // Extracting broker accounts for office accounts filtered above.
    if(theOfficeAccountIds.size() > 0) {
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c,contact_to__r.name FROM Account_Relationship__c WHERE
                                                            Child_Account__c IN :theOfficeAccountIds AND Parent_Account__c != null AND
                                                            Parent_Account__r.Type = 'Broker' AND Is_Parent_Primary__c = true AND
                                                            Active__c = true]) {
        theBrokerAccountIds.add(theAccountRelationship.Parent_Account__c);
      }
    }
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - Update theBrokerAccountIds - ' + theBrokerAccountIds);

    // Processing broker accounts extracted above.
    Account theAccount = null;
    Map<Id, Account> theAccountsToBeUpdated = new Map<Id, Account>();
    if(theBrokerAccountIds.size() > 0) {
      Map<Id, Id> theOfficeAccountAndItsBrokerAccountMapping = new Map<Id, Id>();
      Map<Id, Integer> totalBrokerOffices = new Map<Id, Integer>();
      Map<Id, Integer> totalBrokerAgents = new Map<Id, Integer>();

      // Computing total offices for broker accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c, Child_Account__c,contact_to__r.Name FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theBrokerAccountIds AND Is_Parent_Primary__c = true
                                                            AND Active__c = true AND Child_Account__c != null
                                                            AND Child_Account__r.Type = 'Realtor Office']) {
        theOfficeAccountAndItsBrokerAccountMapping.put(theAccountRelationship.Child_Account__c, theAccountRelationship.Parent_Account__c);
        if(!totalBrokerOffices.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalBrokerOffices.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalBrokerOffices.put(
          theAccountRelationship.Parent_Account__c,
          totalBrokerOffices.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total offices for broker accounts.
      Integer totalOffices = 0;
      for(Id theAccountId : totalBrokerOffices.size() > 0 ? totalBrokerOffices.keySet() : theBrokerAccountIds) {
        if(theAccountsToBeUpdated.containsKey(theAccountId)) {
          theAccount = theAccountsToBeUpdated.get(theAccountId);
          theAccount.Total_Offices__c = totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) + totalOffices : 0;
        }
        else {
          theAccountsToBeUpdated.put(
            theAccountId,
            new Account(
              Id = theAccountId,
              Total_Offices__c = totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) + totalOffices : 0
            )
          );
        }
        totalOffices = totalOffices + (totalBrokerOffices.containsKey(theAccountId) ? totalBrokerOffices.get(theAccountId) : 0);
      }

      // Computing total agents for broker accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theOfficeAccountAndItsBrokerAccountMapping.keySet()
                                                            AND Is_Parent_Primary__c = true AND Active__c = true
                                                            AND Child_Account__c != null AND Child_Account__r.Type = 'Realtor Agent']) {
        if(!totalBrokerAgents.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalBrokerAgents.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalBrokerAgents.put(
          theAccountRelationship.Parent_Account__c,
          totalBrokerAgents.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total agents for broker accounts.
      Integer totalAgents = 0;
      for(Id theAccountId : totalBrokerAgents.size() > 0 ? totalBrokerAgents.keySet() : theOfficeAccountAndItsBrokerAccountMapping.keySet()) {
        if(theOfficeAccountAndItsBrokerAccountMapping.containsKey(theAccountId)) {
          if(theAccountsToBeUpdated.containsKey(theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId))) {
            theAccount = theAccountsToBeUpdated.get(theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId));
            theAccount.Total_Agents__c = totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) + totalAgents : 0;
          }
          else {
            theAccountsToBeUpdated.put(
              theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId),
              new Account(
                Id = theOfficeAccountAndItsBrokerAccountMapping.get(theAccountId),
                Total_Agents__c = totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) + totalAgents : 0
              )
            );
          }
          totalAgents = totalAgents + (totalBrokerAgents.containsKey(theAccountId) ? totalBrokerAgents.get(theAccountId) : 0);
        }
      }

      system.debug('TRACE: computeTotalAgentsAndTotalOffices - theOfficeAccountAndItsBrokerAccountMapping - ' + theOfficeAccountAndItsBrokerAccountMapping);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalBrokerOffices - ' + totalBrokerOffices);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalBrokerAgents - ' + totalBrokerAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalAgents - ' + totalAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalOffices - ' + totalOffices);
    }

    // Processing office accounts extracted above.
    if(theOfficeAccountIds.size() > 0) {
      Map<Id, Integer> totalOfficeAgents = new Map<Id, Integer>();

      // Computing total agents for office accounts.
      for(Account_Relationship__c theAccountRelationship : [SELECT Id, Parent_Account__c FROM Account_Relationship__c WHERE
                                                            Parent_Account__c IN :theOfficeAccountIds AND Is_Parent_Primary__c = true
                                                            AND Active__c = true AND Child_Account__c != null
                                                            AND Child_Account__r.Type = 'Realtor Agent']) {
        if(!totalOfficeAgents.containsKey(theAccountRelationship.Parent_Account__c)) {
          totalOfficeAgents.put(theAccountRelationship.Parent_Account__c, 0);
        }
        totalOfficeAgents.put(
          theAccountRelationship.Parent_Account__c,
          totalOfficeAgents.get(theAccountRelationship.Parent_Account__c) + 1
        );
      }

      // Computing total agents for office accounts.
      Integer totalAgents = 0;
      for(Id theAccountId : totalOfficeAgents.size() > 0 ? totalOfficeAgents.keySet() : theOfficeAccountIds) {
        if(theAccountsToBeUpdated.containsKey(theAccountId)) {
          theAccount = theAccountsToBeUpdated.get(theAccountId);
          theAccount.Total_Agents__c = totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) + totalAgents : 0;
        }
        else {
          theAccountsToBeUpdated.put(
            theAccountId,
            new Account(
              Id = theAccountId,
              Total_Agents__c = totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) + totalAgents : 0
            )
          );
        }
        totalAgents = totalAgents + (totalOfficeAgents.containsKey(theAccountId) ? totalOfficeAgents.get(theAccountId) : 0);
      }

      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalOfficeAgents - ' + totalOfficeAgents);
      system.debug('TRACE: computeTotalAgentsAndTotalOffices - totalAgents - ' + totalAgents);
    }

    // Updating broker and office accounts with values computed above.
    system.debug('TRACE: computeTotalAgentsAndTotalOffices - theAccountsToBeUpdated - ' + theAccountsToBeUpdated);
    if(theAccountsToBeUpdated.size() > 0) {
      update theAccountsToBeUpdated.values();
    }
  }
  
  public void checkcontactUniquenes(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert){
    
      set<ID> parentIds = new set<ID>();
      list<Account> accList = new list<Account>();
      
      if(isInsert){
          for(Account_Relationship__c accRelation: newValues){
          if(accRelation.Active__c && accRelation.RecordTypeID == contRelationShipRTID ){
              if(accRelation.Contact_Role__c == 'Primary Contact')
                      accRelation.Primary_Contact_Unique__c = ''+accRelation.RecordTypeID + accRelation.Parent_Account__c + accRelation.Contact_Role__c+ accRelation.Active__c;
              if(accRelation.Billing_Contact__c)
                      accRelation.Billing_Contact_Unique__c = ''+accRelation.RecordTypeID + accRelation.Parent_Account__c + ''+ accRelation.Billing_Contact__c + accRelation.Active__c;              
           }
          if(accRelation.Active__c && accRelation.RecordTypeID == AccRelationShipRTID){
              system.debug('test==>'+accRelation.Parent_Account__c);
             parentIds.add(accRelation.Parent_Account__c);  
           }
          }
      }
      else{
          for(Account_Relationship__c accRelUpdate: newvalues){
         if(accRelUpdate.RecordTypeID == contRelationShipRTID){
              if(oldMap.get(accRelUpdate.ID).Active__c && (accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c || accRelUpdate.Contact_Role__c != oldMap.get(accRelUpdate.ID).Contact_Role__c )){                                
                        accRelUpdate.Primary_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + accRelUpdate.Contact_Role__c + accRelUpdate.Active__c;                                                              
                        }
              if(oldMap.get(accRelUpdate.ID).Active__c && (accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c  || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c)){
                        accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c;                        
                        if(!accRelUpdate.Billing_Contact__c)                        
                            accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c + datetime.now();                                                                            
              }
              
              if(accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c || accRelUpdate.Contact_Role__c != oldMap.get(accRelUpdate.ID).Contact_Role__c || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c ){                  
                        accRelUpdate.Primary_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + accRelUpdate.Contact_Role__c + accRelUpdate.Active__c;          
                        }
              if(accRelUpdate.Active__c != oldMap.get(accRelUpdate.ID).Active__c  || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c || accRelUpdate.Billing_Contact__c != oldMap.get(accRelUpdate.ID).Billing_Contact__c){              
                        accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c;                        
                        if(!accRelUpdate.Billing_Contact__c)                        
                            accRelUpdate.Billing_Contact_Unique__c = ''+accRelUpdate.RecordTypeID + accRelUpdate.Parent_Account__c + ''+accRelUpdate.Billing_Contact__c  + accRelUpdate.Active__c + datetime.now();                                                                                                    
              }
                            
            }                            
          }      
      }
  }
   /*
  @method      : updateAccountforParentChild
  @description : Update Child accounts when a new account relatoin recor dis created/updated
  @params      : List<Account_Relationship__c> newValues
  @returns     : void
  @author      : Ravinder Reddy
  */
    
    public void CheckChildAccountAssetValidation(Map<ID,Account_Relationship__c> newValues, Map<ID,Account_Relationship__c> oldmap, boolean isInsert) {
        //set<ID> parentAccountIds = new set<ID>();     // CRM-4150 Commented not in use code.
        //map<ID,ID> accMap2 = new map<ID,ID>();        // CRM-4150 Commented not in use code.
        
        set<ID> childAccountIds = new set<ID>();
        Map<ID,ID> accMap = new Map<ID,ID>();
        if(newValues != Null && newValues.size()>0){      
            for(Account_Relationship__c accRelation: newValues.values()) {
                accMap.put(accRelation.Child_Account__c, accRelation.ID); 
                //accMap2.put(accRelation.Parent_Account__c,accRelation.ID);         // CRM-4150 Commented not in use code.   
                // if update and Active marked true
                if(!isInsert && oldmap.containsKey(accRelation.ID) && oldmap.get(accRelation.ID).Active__c == true && !accRelation.Active__c  &&  accRelation.RecordTypeID == AccRelationShipRTID && accRelation.Child_Account__c != null){             
                    childAccountIds.add(accRelation.Child_Account__c);  
                }
            
                // CRM-4150 Commented not in use code below
                /*
                if(!isInsert && oldmap.containsKey(accRelation.ID) && oldmap.get(accRelation.ID).Active__c == true && !accRelation.Active__c  &&  accRelation.RecordTypeID == AccRelationShipRTID && accRelation.Parent_Account__c != null){             
                    parentAccountIds.add(accRelation.Parent_Account__c);  
                }
                */
            }
        }
        
        // CRM-4150 Commented not in use code below between /**/
        /*
        if(parentAccountIds .size() > 0) {
           for(Asset oassetParent: [SELECT ID,AccountID,Account.Type FROM Asset  WHERE AccountID IN:parentAccountIds AND Asset_Type__c =: 'Parent' AND Status =: 'Active' AND Product_Account__c != null AND Product_Account__r.Type =: 'Realtor Office']){
                if(accMap2.containsKey(oassetParent.AccountID) && newValues.containsKey(accMap2.get(oassetParent.AccountID))){
                    // newValues.get(accMap2.get(oassetParent.AccountID)).addError('You cannot deactivate the office affiliation due to active asset with Broker.');
                }
            }
        }
        */
       
        if(childAccountIds.size() > 0){
            for(Asset oasset: [SELECT ID,AccountID,Account.Type FROM Asset  WHERE AccountID IN:childAccountIds AND Status =: 'Active' AND Account.Type =: 'Realtor Office' AND Fulfillment_Status__c='Fulfilled' AND Parent_Asset__r.status='Active' AND Parent_Asset__r.Fulfillment_Status__c='Fulfilled' AND Product_Code__c='ADVANTAGE']){
                if(accMap.containsKey(oasset.AccountID) && newValues.containsKey(accMap.get(oasset.AccountID))){
                    // CRM-4150 - Un-commented below line.
                    newValues.get(accMap.get(oasset.AccountID)).addError(Label.InActivate_Office_Relationship_Error_Message);
                }
            }
        }

                      
        if(childAccountIds.size() >0){
            list<Account> accList = new list<Account>();
            for(Account oacc : [SELECT ID,Parent_Broker__c FROM Account WHERE ID IN: childAccountIds]){
               Account accTemp = new Account(ID=oacc.ID);
               accTemp.Parent_Broker__c = null;
               accList.add(accTemp);
            }
            if(!accList.isEmpty()) {
                update accList;
            }   
        }
    }
  

   /*
  @method      : updateAccountforParentChild
  @description : Update Child accounts when a new account relatoin recor dis created/updated
  @params      : List<Account_Relationship__c> newValues
  @returns     : void
  @author      : Ravinder Reddy
  */
    
  public void updateAccountforParentChild(list<Account_Relationship__c> newValues)
  {
      set<ID> parentIds = new set<ID>();
      list<Account> accList = new list<Account>();
      
       for(Account_Relationship__c accRelation: newValues){
       
          if(accRelation.Active__c && accRelation.RecordTypeID == AccRelationShipRTID){
              system.debug('test==>'+accRelation.Parent_Account__c);
             parentIds.add(accRelation.Parent_Account__c);  
           }
        }
          
       for(Account_Relationship__c  oaccRelation : [SELECT ID,Child_Account__c,Parent_Account__c,Relationship_Type__c,Parent_Account__r.OwnerID,contact_TO__r.name  FROM Account_Relationship__c WHERE Parent_Account__r.Type = 'Broker' AND  Child_Account__r.Type = 'Realtor Office' AND Parent_Account__c IN: parentIds AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49998]){
                  system.debug('****type****'+oaccRelation.Relationship_Type__c);
                      
              if(oaccRelation.Relationship_Type__c == 'Parent/Child')
          accList.add(new Account(ID=oaccRelation.Child_Account__c,OwnerId = oaccRelation.Parent_Account__r.OwnerID ));
            
       }
      system.debug('accList======'+accList);
       if(!accList.isEmpty()){
           system.debug('accList======'+accList[0]);
            AccountTriggerHandlerManager.onTerritorychagneFlag = true;
            update accList ;
        }   
      
  }
  
 
   /*
  @method      : populateIsParentPrimary
  @description : Populating Contact Account if isPArent Primary is marked true
  @params      : List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  @author      : Ravinder Reddy
  */
  public static boolean updateAccrealtion = false;
  public void populateIsParentPrimary(map<ID,Account_Relationship__c> newmap, Map<Id, Account_Relationship__c> oldMap,
                                          Boolean isInsert) {
    //Is_Parent_Primary__c
    map<ID,ID> contactmap = new map<ID,ID>();
    list<Contact> contactList = new list<Contact>();
    map<ID,ID> parentAccountIDs = new map<ID,ID>();
    list<Account_Relationship__c> accRelationUpdate = new list<Account_Relationship__c>();
    for(Account_Relationship__c accRelation : newmap.values()){
        if(accRelation.RecordtypeID == contRelationShipRTID  ){
            if((isInsert && accRelation.Is_Parent_Primary__c) || ( !isInsert && oldmap != null && oldmap.containskey(accRelation.ID) && accRelation.Is_Parent_Primary__c && oldmap.get(accRelation.ID).Is_Parent_Primary__c != accRelation.Is_Parent_Primary__c )){
                if(accRelation.Contact_To__c != null && accRelation.Parent_Account__c != null)        
                    contactmap.put(accRelation.Contact_To__c,accRelation.Parent_Account__c);
                    parentAccountIDs.put(accRelation.Parent_Account__c,accRelation.ID);
        }
            if(!isInsert && !accRelation.Is_Parent_Primary__c &&  oldmap != null && oldmap.containskey(accRelation.ID) && oldmap.get(accRelation.ID).Is_Parent_Primary__c != accRelation.Is_Parent_Primary__c )
            {
             //CRM-4092: Do not update AccountId to Null if label value is false (Fix for community user issue)
             if(accRelation.Contact_To__c != null && System.Label.MakeAccountIdNull == 'true')        
                    contactmap.put(accRelation.Contact_To__c,null);   
            }
        }
    } 
    
    
     
        
    for(contact con : [SELECT Id,AccountId FROM contact WHERE ID IN: contactmap.keyset()]){ 
        if(contactmap.containsKey(con.ID)){
            contactList .add(new Contact(ID=con.ID,AccountId = contactmap.get(con.ID)));  
        }
        
    }

            for(Account_Relationship__c accRelation : newmap.values()){
                    if (accRelation.Parent_Account__c != null) {
                      parentAccountIDs.put(accRelation.Parent_Account__c,accRelation.ID);
                    }
            }
    
    map<ID,Integer> ContactsCount = new map<ID,Integer>();
     //AggregateResult[] groupedResults = [SELECT Parent_Account__c,Count(ID) contactCount FROM Account_Relationship__c  WHERE Parent_Account__c IN: parentAccountIDs.keyset() AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true   GROUP BY Parent_Account__c limit 49995 ]; 
        
    for (AggregateResult ar : [SELECT Parent_Account__c,Count(ID) contactCount FROM Account_Relationship__c  WHERE Parent_Account__c IN: parentAccountIDs.keyset() AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true   GROUP BY Parent_Account__c limit 49995 ])  {
            ContactsCount.put(''+ar.get('Parent_Account__c'),Integer.valueOf(ar.get('contactCount')));                                         
    }
    for(Account_Relationship__c oaccountRelation :newmap.values())
    {
     if(oaccountRelation.RecordtypeID == contRelationShipRTID && parentAccountIDs.containsKey(oaccountRelation.Parent_Account__c)&&ContactsCount.containsKey(oaccountRelation.Parent_Account__c) && ContactsCount.get(oaccountRelation.Parent_Account__c) == 1){
        if(Isinsert){
        accRelationUpdate.add(new Account_Relationship__c (ID=parentAccountIDs.get(oaccountRelation.Parent_Account__c),Billing_Contact__c = true,Contact_Role__c = 'Primary Contact')); 
        }
        else{
            accRelationUpdate.add(new Account_Relationship__c (ID=parentAccountIDs.get(oaccountRelation.Parent_Account__c))); 
        }
              
              }
    }
    
    
    if(!contactlist.isEmpty()){
      set<contact> contactset = new set<Contact>();
      contactset.addAll(contactlist);
      contactlist.clear();
      for(contact ocon: contactset){

        contactlist.add(ocon);
      }
      update contactlist;
    }
      
    if(!accRelationUpdate.isEmpty()){                                                 
    updateAccrealtion = true;
     set<Account_Relationship__c> accRealtionset = new set<Account_Relationship__c>();
      accRealtionset.addAll(accRelationUpdate);
      accRelationUpdate.clear();
      for(Account_Relationship__c oaccr: accRealtionset){
        accRelationUpdate.add(oaccr);
      }
        update accRelationUpdate;
        }
  } 
    //during insert if account has already billing contact to true then set old billing contact to false
    public void setbillngcntctfalseinsert(Map<Id,Account_Relationship__c> NewMap){
        set<id> prntactids = new set<id>();
        List<Account> Acctupdate = New List<Account>();
        list<Account_Relationship__c> acctreltndata = new list<Account_Relationship__c>();
        for(Account_Relationship__c acctrelloop : NewMap.values()){
            prntactids.add(acctrelloop.Parent_account__c);
            If(acctrelloop.Contact_Role__c == 'Primary Contact'){
                //Replaced 'Primary_Email__c' with 'Email_Address__c' as part of Jira SMCI-554
                Acctupdate.add(New Account(Id = acctrelloop.Parent_Account__c,
                                           Email_Address__c = acctrelloop.Email_Address__c,
                                           Phone = acctrelloop.Preferred_Phone__c,
                                           Primary_Contact_Name__c = acctrelloop.Contact_To__r.Name));
            }
        }
        system.debug('Acctupdate:'+Acctupdate);
        acctreltndata = [select parent_Account__c,Billing_Contact__c,Active__c,contact_to__r.Name 
                         from Account_Relationship__c where parent_Account__c in :prntactids
                         and Billing_Contact__c = true and Active__c = true order by createddate desc];
        for(Account_Relationship__c newvlloop : NewMap.values()){
            if(newvlloop.Billing_Contact__c == true &&
               newvlloop.Active__c == true){
                   system.debug('subbu is here');
                   for(Account_Relationship__c acctrltnloop : acctreltndata){
                       system.debug('Naresh is here');
                       if(acctrltnloop.parent_Account__c == newvlloop.parent_Account__c
                          && acctrltnloop.Billing_Contact__c == true   
                          && acctrltnloop.Active__c == true
                          //excluding the just created one
                          && acctrltnloop.id != acctreltndata[0].id){
                              system.debug('Sanjay is here');
                              acctrltnloop.Billing_Contact__c = false;
                          }
                   }
               }       
        }
        system.debug('acctreltndata:'+acctreltndata);
        if(acctreltndata.size() > 0){
            update acctreltndata;
        }
        
        If(Acctupdate != Null && Acctupdate.size() > 0){
           Update Acctupdate;
        }
    }
     //during update if account has already billing contact to true then set old billing contact to false
    public void setbillngcntctfalseupdate(Map<Id,Account_Relationship__c> NewMap,Map<Id,Account_Relationship__c> OldMap){
        set<id> prntactids = new set<id>();
        set<id> acctrltnids = new set<id>();
        list<Account_Relationship__c> acctreltndata = new list<Account_Relationship__c>();
        
        for(Account_Relationship__c acctrelloop : NewMap.values()){
            if(acctrelloop.Billing_Contact__c != oldmap.get(acctrelloop.id).Billing_Contact__c &&
               acctrelloop.Billing_Contact__c == true){
               prntactids.add(acctrelloop.Parent_account__c);
               acctrltnids.add(acctrelloop.id);    
            }
        }
        
        acctreltndata = [select parent_Account__c,Billing_Contact__c,Active__c 
                         from Account_Relationship__c where parent_Account__c in :prntactids
                         and Billing_Contact__c = true and Active__c = true and id not in :acctrltnids];
        
        for(Account_Relationship__c acctreltnloop : acctreltndata){
            acctreltnloop.Billing_Contact__c = false;
        }
        system.debug('acctreltndata:'+acctreltndata);
        if(acctreltndata.size() > 0){
            update acctreltndata;
        }
    }
    
    //during insert/update if account has already primary contact to true then set old primary contact to false
    public void setPrimarycntfalseupdate(Map<Id,Account_Relationship__c> NewMap,Map<Id,Account_Relationship__c> OldMap, Boolean isInsert){
        set<id> prntactids = new set<id>();
        set<id> acctrltnids = new set<id>();
        list<Account_Relationship__c> acctreltndata = new list<Account_Relationship__c>();
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
        System.debug('Im here near primary contact update old records');
        if(isInsert) {
            for(Account_Relationship__c acctrelloop : NewMap.values()){
                if(acctrelloop.RecordTypeId == contactRelationshipRecordTypeId) {
                    if(acctrelloop.Is_Parent_Primary__c == true || acctrelloop.Contact_Role__c == 'Primary Contact') {
                        prntactids.add(acctrelloop.Parent_account__c);
                        acctrltnids.add(acctrelloop.id);
                    }
                }
            }
        }
        else if(!isInsert){
            for(Account_Relationship__c acctrelloop : NewMap.values()){
                if(acctrelloop.RecordTypeId == contactRelationshipRecordTypeId) {
                    if((acctrelloop.Is_Parent_Primary__c != oldmap.get(acctrelloop.id).Is_Parent_Primary__c &&
                       acctrelloop.Is_Parent_Primary__c == true) || (acctrelloop.Contact_Role__c != oldmap.get(acctrelloop.id).Contact_Role__c &&
                       acctrelloop.Contact_Role__c == 'Primary Contact')){
                       prntactids.add(acctrelloop.Parent_account__c);
                       acctrltnids.add(acctrelloop.id);    
                    }
                }
            }
        }
            
        acctreltndata = [select parent_Account__c,Is_Parent_Primary__c,Contact_Role__c,Active__c 
                         from Account_Relationship__c where parent_Account__c in :prntactids
                         and (Is_Parent_Primary__c = true OR Contact_Role__c = 'Primary Contact') and Active__c = true and id not in :acctrltnids];
                         
        if(!acctreltndata.isEmpty()) {  
            for(Account_Relationship__c acctreltnloop : acctreltndata){
                acctreltnloop.Is_Parent_Primary__c = false;
                acctreltnloop.Contact_Role__c = '';
                acctreltnloop.Primary_Contact_Unique__c = ''+contRelationShipRTID + acctreltnloop.Parent_Account__c + acctreltnloop.Contact_Role__c+ acctreltnloop.Active__c;
            }
            update acctreltndata;
        }
    } 
    
    //during insert/update if account has already primary contact to true then set Contact Role to 'Primary Contact' and viceversa
    public void setPrimarycntupdate(List<Account_Relationship__c> NewMap){
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(CONTACT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;
        System.debug('Im here near primary contact update');
        for(Account_Relationship__c acctrelloop : NewMap){
            if(acctrelloop.RecordTypeId == contactRelationshipRecordTypeId) {
                if(acctrelloop.Is_Parent_Primary__c == true && acctrelloop.Contact_Role__c != 'Primary Contact') {
                    acctrelloop.Contact_Role__c = 'Primary Contact';
                }
                if(acctrelloop.Is_Parent_Primary__c != true && acctrelloop.Contact_Role__c == 'Primary Contact') {
                    acctrelloop.Is_Parent_Primary__c = true;
                }
            }
        }   
    } 
    
/**
 *  Method to update SMS Opt In field on Account (After Insert/Update) - CRM-951
 *  If new Account-Relationship is created and if the contact has SMS_Opt_In__c checked then Account associated with it must have that box checked 
 **/
    
    public void updateSMSOptIn(List<Account_Relationship__c> NewAccRelList){
        Set<Id> ContSet = new Set<Id> ();
        Set<Id> AcctSet = new Set<Id> ();
        Set<Account> AcctUpdSet = new Set<Account> ();
        List<Account> AcctUpdList = new List<Account> ();
        List<Account_Relationship__c> accRepList = new List<Account_Relationship__c> ();
        for (Account_Relationship__c accRelLoop : NewAccRelList){
            System.debug('if accRelLoop ------>' + accRelLoop);
            if(accRelLoop.Active__c == true){
                System.debug('if consetsss accrel------>' + Contset);
                Contset.add(accRelLoop.Contact_To__c);
                AcctSet.add(accRelLoop.Parent_Account__c);
            } else {
                //If Account-Relationship is inactivated then the status of field on account will be not depend on Contact. All other associated contacts will be checked.
                accRepList.add(accRelLoop);                   
            }
        }
        if(!accRepList.isEmpty())
            updateSMSOptInField(accRepList);
        
        for(Account_Relationship__c repObj : [Select Id, Contact_To__c, Parent_Account__c, Contact_To__r.SMS_Opt_In__c from Account_Relationship__c where Contact_To__c IN :ContSet and Parent_Account__c IN :AcctSet and Active__c = true]) {
            Account acc= new Account();
            acc.Id = repObj.Parent_Account__c;
            if(repObj.Contact_To__r.SMS_Opt_In__c == true &&  acc.Id != null){
                acc.SMS_Opt_In__c = true;
                AcctUpdSet.add(acc);
            }
        }
        System.debug('if acccc accrel------>' + AcctUpdSet);
        if(!AcctUpdSet.isEmpty()) {
            AcctUpdList.addall(AcctUpdSet);
            update AcctUpdList;
        }
    } 
    //If contact relationship is deleted, then associated account will be updated to opt out ONLY IF there is no other contact with SMS opt in box checked         
    
    //After Delete
    public void updateSMSOptInAfterDelete(List<Account_Relationship__c> OldAccRelList){
        List<Account_Relationship__c> accRepList = new List<Account_Relationship__c> ();
        for (Account_Relationship__c accRelLoop : OldAccRelList){
            accRepList.add(accRelLoop);
        }
        if(!accRepList.isEmpty())
            updateSMSOptInField(accRepList);
    }
    
    //All other associated contacts will be checked if Account-Relationship is deleted or inactivated.
    public void updateSMSOptInField(List<Account_Relationship__c>  accRelLoopList){
        
        Set<Id> acctSet = new Set<Id> ();
        Set<Id> parentAcctSet = new Set<Id> ();
        Set<Id> contSet = new Set<Id> ();
        Map<Id,List<Id>> AcctConMapList = new Map<Id,List<Id>>();
        Set<Account> acctUpdSet = new Set<Account> ();
        List<Account> acctList = new List<Account> ();
        Map<id, Boolean> contactOnAccMap = new Map<id, Boolean>();
        Set<Id> RepSet = new Set<Id> ();
        Map<Id, Id> conRelMap = new Map<Id, Id>();
        
        for(Account_Relationship__c accRep: accRelLoopList) {
            if(!acctSet.contains(accRep.Parent_Account__c) && accRep.Parent_Account__c != null){
                acctSet.add(accRep.Parent_Account__c);
            }
            RepSet.add(accRep.Id);
        }
        //list<Account_Relationship__c> accRelList = [Select id, Parent_Account__c, Contact_To__c, Contact_To__r.SMS_Opt_In__c from Account_Relationship__c  where Parent_Account__c IN :acctSet and Relationship_Type__c = 'Contact' and id NOT In :RepSet and Active__c = true];
        for(Account_Relationship__c accRel: [Select id, Parent_Account__c, Contact_To__c, Contact_To__r.SMS_Opt_In__c from Account_Relationship__c  where Parent_Account__c IN :acctSet and Relationship_Type__c = 'Contact' and id NOT In :RepSet and Active__c = true]){
            //Accounts having other associated contacts relationships.
            if(!parentAcctSet.contains(accRel.Parent_Account__c)){
                parentAcctSet.add(accRel.Parent_Account__c);
            }
            //Create Map of account ids and associated  contact ids 
            if(AcctConMapList.containsKey(accRel.Parent_Account__c)) {
                List<Id> conList = AcctConMapList.get(accRel.Parent_Account__c);
                conList.add(accRel.Contact_To__c);
                AcctConMapList.put(accRel.Parent_Account__c, conList);
            }else {                
                AcctConMapList.put(accRel.Parent_Account__c, new List<Id> {accRel.Contact_To__c});
            }                                         
            contactOnAccMap.put(accRel.Contact_To__c, accRel.Contact_To__r.SMS_Opt_In__c);
        }
      
         //If an account don't have any other contact associated then make the SMS_Opt_In false.
        for(id acctSetLoop : acctSet){
            if(!parentAcctSet.contains(acctSetLoop)) {
                Account acct = new Account();
                acct.Id = acctSetLoop;
                acct.SMS_Opt_In__c = false;
                acctUpdSet.add(acct);
            }
        }
        for(Id acctId : AcctConMapList.keySet()){
            Boolean IsSMSOptInTrueFlag = false;
            List<Id> contIdList = AcctConMapList.get(acctId);
            for(Id cont: contIdList) {
                
                if(contactOnAccMap.get(cont) == true && !contactOnAccMap.containsKey(null)) {
                    IsSMSOptInTrueFlag = true;
                    Account acct = new Account();
                    acct.Id = acctId;
                    acct.SMS_Opt_In__c = true;
                    System.debug('if  true------>');
                    acctUpdSet.add(acct);
                    break;
                }                   
            }
            if(!IsSMSOptInTrueFlag) {
                Account acct = new Account();
                acct.Id = acctId;
                acct.SMS_Opt_In__c = false;
                System.debug('if  false------>');
                acctUpdSet.add(acct);
            }
            
        }
        
        if(!acctUpdSet.isEmpty()){
            acctList.addall(acctUpdSet);
            update acctList;
        } 
    }
    
    // CRM-1722 : Restrict users to add another relationship on customer accounts when primary contact exists.
    // Restrict users to update Primary Contact on customer accounts ('contact_role__c' and 'contact_to__c' fields)
    public void restrictInsertUpdAccessForCustomerAcct(List<Account_Relationship__c>  newList, Map<id, Account_Relationship__c>  oldMap, Boolean isInsert){
       
        List<String> profileList = new List<String>();
        List<String> userList = new List<String>();
        Set<String> profileSet = new Set<String>();
        Set<String> userSet = new Set<String>();
        Set<String> accIdSet = new Set<String>();
        Set<String> accIdPrimarySet = new Set<String>();
        
        String profileNames = System.Label.RestrictProfilesForContactCreation ;
        profileList = profileNames.split(',');
        profileSet.addAll(profileList);
        String profileName;
        
        // CRM-2125: Allow given users access to add relationship. 
        String userNames = System.Label.EmailEditExceptionForUsers ;
        userList = userNames.split(',');
        userSet.addAll(userList);
        String userFullName = userInfo.getUserName();
        
        // Get current user profile name.
        //Id profileId = userinfo.getProfileId();
        //String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                                           
        //if(profileSet.contains(profileName)){
        
        for(Account_Relationship__c accRel : newList){
            profileName = accRel.CurrentUserProfile__c;
            if(profileSet.contains(profileName) && !userSet.contains(userFullName))
                accIdSet.add(accRel.Parent_Account__c);
        }
        if(profileSet.contains(profileName) && !userSet.contains(userFullName)){
            
            // Get primary relationships for customer accounts.
            for(Account_Relationship__c accRelPrimary : [Select id, Parent_Account__c
                                                  from Account_Relationship__c
                                                  where Relationship_Type__c = 'Contact' and Parent_Account__c IN :accIdSet
                                                  and Contact_Role__c = 'Primary Contact' 
                                                  and Parent_Account__r.Account_Sub_Type__c = 'Customer']){
            
            accIdPrimarySet.add(accRelPrimary.Parent_Account__c);
          }
            
            for(Account_Relationship__c accRel : newList){
                if(accIdPrimarySet.contains(accRel.Parent_Account__c)){
                    if(isInsert){
                        accRel.addError('You do not have access to add another contact to customer account');
                    } else {
                        if((accRel.Contact_Role__c != oldMap.get(accRel.id).Contact_Role__c) || (oldMap.get(accRel.id).Contact_Role__c == 'Primary Contact' && (accRel.Contact_To__c != oldMap.get(accRel.id).Contact_To__c))) {
                            accRel.addError('You do not have access to update Primary Contact on Customer accounts ');
    
                       }
                    }
                }
            }
                  
        }
        
    }
    
    // CRM-2170 - Method to update Billing Contact and Contact Role if its first relationship record
    public void setPrimaryandBillingContactonInsert(List<Account_Relationship__c> newList) {
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account_Relationship__c accRelation : newList){
            if (accRelation.Parent_Account__c != null) {
                parentAccountIds.add(accRelation.Parent_Account__c);
            }
        }
        Map<Id, Integer> contactCount = new Map<Id, Integer>();
        if (parentAccountIds.size() > 0) {    
            for (AggregateResult ar : [SELECT Parent_Account__c, Count(ID) contactCount FROM Account_Relationship__c  WHERE Parent_Account__c IN: parentAccountIDs AND RecordTypeId = :contRelationShipRTID AND Active__c = true GROUP BY Parent_Account__c limit 49995])  {
                contactCount.put(''+ar.get('Parent_Account__c'), Integer.valueOf(ar.get('contactCount')));                                         
            }
        }
        
        for (Account_Relationship__c rel : newList) {
            if (rel.RecordtypeID == contRelationShipRTID && contactCount.containsKey(rel.Parent_Account__c)  && contactCount.get(rel.Parent_Account__c) == 1) {
                rel.Billing_Contact__c = true;
                rel.Contact_Role__c = 'Primary Contact'; 
            }
        }
    }
    // CRM-2170 - End
    
    // CRM-4613 - Update Case's contact as per primary contact relationship
    public void updateCaseContactwithPrimaryContact(Map<id, Account_Relationship__c> newMap, Map<id, Account_Relationship__c> oldMap, Boolean isInsert) {
        if (Label.Allowed_Case_Record_Type_For_Contact_Change != 'none') {
            Map<Id, Id> accountPrimaryContact = new Map<Id, Id>();
            for (Account_Relationship__c newRel : newMap.values()) {
                if (newRel.Contact_Role__c == 'Primary Contact' && newRel.Parent_Account__c != null && newRel.Contact_To__c != null) {
                    Account_Relationship__c oldRel = isInsert?null:oldMap.get(newRel.Id);
                    if (oldRel == null || newRel.Parent_Account__c != oldRel.Parent_Account__c || 
                        newRel.Contact_To__c != oldRel.Contact_To__c ||
                        newRel.Contact_Role__c != oldRel.Contact_Role__c) {
                        
                        accountPrimaryContact.put(newRel.Parent_Account__c, newRel.Contact_To__c);
                    }
                }
            }
            if (!accountPrimaryContact.isEmpty()) {
                List<Case> toUpdateCase = new List<Case>();
                List<String> recordTypes = Label.Allowed_Case_Record_Type_For_Contact_Change.split(',');
                for (Case c : [SELECT Id, AccountId, ContactId FROM Case WHERE AccountId IN :accountPrimaryContact.keySet() 
                               AND Status != 'Closed' AND RecordType.Name IN :recordTypes]) {
                    Id contactId = accountPrimaryContact.get(c.AccountId);
                    if (contactId != null && c.ContactId != contactId) {
                        c.contactId = contactId;
                        toUpdateCase.add(c);
                    }
                }
                if (toUpdateCase.size()>0) {
                    update toUpdateCase;
                }
            }
        }    
    }
    // CRM-4613 - End

    // LCM-200: Update Account sub type on Lender accounts
    // LCM-171: Update Agent/Broker account 'has Co-marketer' flag
    public void UpdateLCMPartnerAccounts(Map<Id,Account_Relationship__c> newRelationshipMap, Map<Id,Account_Relationship__c> oldRelationshipMap){
        Map<String,Account> lenderCancelActMap = new Map<String,Account>();
        Map<String,Account> parentCancelActMap = new Map<String,Account>();
        Set<Account> acctUpdSet = new Set<Account>();
        List<Account> acctUpdList = new List<Account>();
        Set<String> relIdSet = new Set<String>();
        for(Account_Relationship__c ar:newRelationshipMap.values()){
            if(ar.Relationship_Type__c == 'Partner' && ar.Comarketing_status__c != null && ar.Comarketing_status__c != oldRelationshipMap.get(ar.id).Comarketing_status__c 
              && (ar.Comarketing_status__c == 'Active' || ar.comarketing_status__c == 'Cancelled')){
                  Account a = new Account();
                  a.id = ar.Child_Account__c;
                  Account b = new Account();
                  b.id = ar.parent_account__c;
                  if(ar.Comarketing_status__c == 'Active'){
                      a.Account_Sub_Type__c = 'Customer';
                      b.has_co_marketer__c = true;
                      acctUpdSet.add(a);
                      acctUpdSet.add(b);
                  } else {
                      relIdSet.add(ar.id);
                      a.Account_Sub_Type__c = 'Former Customer';
                      b.has_co_marketer__c = false;
                      lenderCancelActMap.put(ar.Child_Account__c, a);
                      parentCancelActMap.put(ar.Parent_account__c, b);
                  }
            }
        }
        if(!relIdSet.isEmpty()){
            Set<String> stSet = new Set<String>{'Active','Pending Activation','Pending Cancellation'};
            for(Account_Relationship__c arel : [Select id,Child_Account__r.Account_Sub_Type__c,Comarketing_status__c,comarketing_action__c,Parent_Account__c from Account_Relationship__c 
                                                where (Child_Account__c IN :lenderCancelActMap.keySet() or Parent_Account__c IN :parentCancelActMap.keySet()) and Comarketing_status__c != null and
                                                (ID IN:relIdSet or Comarketing_status__c != 'Cancelled') and (Comarketing_status__c != 'Pending Activation' or (Comarketing_status__c = 'Pending Activation' and comarketing_action__c != 'Add'))]){
                if(lenderCancelActMap.containsKey(arel.Child_Account__c)){
                   if((!relIdSet.contains(arel.id) && stSet.contains(arel.comarketing_status__c)) || arel.Child_Account__r.Account_Sub_Type__c != 'Customer'){
                       lenderCancelActMap.remove(arel.Child_Account__c);
                   }
                }
                if(parentCancelActMap.containsKey(arel.Parent_Account__c)){
                   if(!relIdSet.contains(arel.id) && stSet.contains(arel.comarketing_status__c)){
                       parentCancelActMap.remove(arel.Child_Account__c);
                   }
                }
            }
            if(!lenderCancelActMap.isEmpty()){
                acctUpdSet.addAll(lenderCancelActMap.values());
            }
            if(!parentCancelActMap.isEmpty()){
                acctUpdSet.addAll(parentCancelActMap.values());
            }
        }
        if(!acctUpdSet.isEmpty()){
            acctUpdList.addAll(acctUpdSet);
            update acctUpdList;
        }
    }
    
    // Usage: Creates Phone object records for all Primary contact Roles 
    // Phone object records are created based on Phone Contact Methods for the respective contacts - venkat arisa
    public void createPhoneRecords(Map<Id, Account_Relationship__c> newRelationshipMap, Map<Id, Account_Relationship__c> oldRelationshipMap, Boolean isInsert) {         
        Map<Account_Relationship__c,Id> relToContactMap = new Map<Account_Relationship__c,Id>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        List<Phone__c> phoneListToBeInserted = new List<Phone__c>();
        
        for(Account_Relationship__c rel: newRelationshipMap.Values()){
            if(rel.Contact_Role__c == 'Primary Contact' && null != rel.Contact_To__c && rel.Active__c == True && 
               ((isInsert && null != rel.Parent_Account__c) || (!isInsert && rel.Parent_Account__c != null && rel.Parent_Account__c != oldRelationshipMap.get(rel.Id).Parent_Account__c))){
                   relToContactMap.put(rel,rel.Contact_To__c);
               }               
        }
        
        contactMap = new Map<Id,Contact>([select id,name,(select id,name, Type__c ,Type_Purpose__c, Contact__c, Phone__c, Phone_Extension__c, Phone_Text__c from Contact_Methods__r where type__c = 'Phone' and Type_Purpose__c != 'BUSINESS_FAX') from Contact where Id IN: relToContactMap.values()]);                              
        for(Account_Relationship__c rel: relToContactMap.Keyset()){
            for(ContactMethod__c cmRecord: contactMap.get(rel.Contact_To__c).Contact_Methods__r){
                Phone__c phoneRecord = new Phone__c();
                if(null != cmRecord.Phone__c){
                    phoneRecord.Account__c        = rel.Parent_Account__c;
                    phoneRecord.Contact_Method__c = cmRecord.Id;
                    phoneRecord.Phone_Type__c     = cmRecord.Type_Purpose__c;
                    phoneRecord.Name              = ContactMethodTriggerHelper.convertFromFormatted(cmRecord.Phone__c);
                    
                    phoneListToBeInserted.add(phoneRecord);
                }                
            }               
        }
        
        system.debug(' *** phoneListToBeInserted *** '+phoneListToBeInserted);
        if(!phoneListToBeInserted.isEmpty()){
            insert phoneListToBeInserted;
        }                        
    }
}