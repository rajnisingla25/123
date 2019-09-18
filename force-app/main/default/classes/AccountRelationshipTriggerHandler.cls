//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Name: AccountRelationshipTriggerHandler
// For Trigger: AccountRelationshipTrigger
// On SObject: Account Relationship (Account_Relationship__c)
// Description: For "Account Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Child Account" +
// "Active Flag". For "Contact Relationship" record type, the unique key for checking duplicate records should be "Parent Account" + "Contact To" +
// "Contact Role(Primary Contact/Billing Contact)" + "Active Flag". Also, auto-populate 'Account.Parent_Broker__c' and validate primary parent
// account. The billing contact cannot be marked inactive if there is no other billing contact associated with that account.
//
// User Story Acceptance Criteria Updated on 29th April 2015 For Issue # I-157451 - A duplicate contact relationship should not be allowed
// irrespective of contact role.
//
// 17th March 2015    Hemendra Singh Bhati    Original (Task # T-371098)
// 23rd March 2015    Hemendra Singh Bhati    Modified (Task # T-372661)  - Complete Code Re-factored.
// 26th March 2015    Hemendra Singh Bhati    Modified (Task # T-373693)  - Complete Code Re-factored.
// 09th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added logic to auto-populate 'Account.Parent_Broker__c'.
// 10th April 2015    Hemendra Singh Bhati    Modified (Task # T-377199)  - Added logic to validate primary parent account.
// 23rd April 2015    Hemendra Singh Bhati    Modified (Issue # I-155139) - The billing contact cannot be marked inactive if there is no other
//                                                                        - billing contact associated with that account.
//                                                                        - Updated Method: onBeforeInsertUpdate().
// 29th April 2015    Hemendra Singh Bhati    Modified (Issue # I-157451) - A duplicate contact relationship should not be allowed irrespective
//                                                                        - of contact role.
// 06th May 2015      Hemendra Singh Bhati    Modified (Task # T-392803)  - Set the boolean field "Is_Sent_To_CDH__c" value to "False" whenever a
//                                                                        - new record on 'Account_Relationship__c' object is created and whenever
//                                                                        - the "Active" field is updated to "False".
//                                                                        - Updated Method: onBeforeInsertUpdate().
// 05th June 2015     Hemendra Singh Bhati    Modified (Issue # I-166282) - Updated Method: onAfterInsertUpdate().
//
public class AccountRelationshipTriggerHandler {
    private integer batchSize = 0;
    private boolean isExecuting = false;
    private AccountRelationshipTriggerHandlerManager theManager = null;
    
    public AccountRelationshipTriggerHandler(Boolean isExecuting, Integer size) {
        batchSize = size;
        isExecuting = isExecuting;
        theManager = new AccountRelationshipTriggerHandlerManager();
    }
    
    // Validating account relationship records on before insert/update trigger event.
    public void onBeforeInsertUpdate(List<Account_Relationship__c> newValues, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        
        // CRM-1722: Restrict given profiles from adding another relationship on customer accounts.
        // Restrict users to update Primary Contact on customer accounts
            theManager.restrictInsertUpdAccessForCustomerAcct(newValues, oldMap, isInsert);
        
        // Turn off account relationship records unique combination if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Unique_Relationship_Validation__c == false) {
            system.debug('TRACE: Validating account relationship records.');
            theManager.validateAccountRelationshipRecords(newValues, oldMap, isInsert);
        }
        
        // Turn off primary parent account validation if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Primary_Parent_Account_Validation__c == false) {
            system.debug('TRACE: Validating primary parent account.');
            theManager.validatePrimaryParentAccount(newValues, oldMap, isInsert);
        }
        
        // Turn off billing contact validation for contact relationship records if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Billing_Contact_Validation__c == false) {
            system.debug('TRACE: Validating billing contact for contact relationship records.');
            theManager.validateBillingContactDeactivation(newValues, oldMap, isInsert);
        }
        
        system.debug('TRACE: Validating Office is associte to a single Broker records.');
        theManager.validateOfficeIsAssociteWithOneBroker(newValues, oldMap, isInsert);
        
        // Turn off updation of boolean field "Is_Sent_To_CDH__c" if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Is_Sent_To_CDH_Updation_Off__c == false) {
            system.debug('TRACE: Updating boolean field "Is_Sent_To_CDH__c" for both account and contact relationship records.');
            theManager.updateIsSentToCDH(newValues, oldMap, isInsert);
        }
        theManager.setPrimarycntupdate(newValues);
        theManager.checkcontactUniquenes(newValues,oldMap,isInsert);   
       
        
    }
    public void onBeforeUpdate(map<ID,Account_Relationship__c> newmap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        theMAnager.CheckChildAccountAssetValidation(newmap,oldMap,isInsert);
    }
    public void onAfterInsertUpdateAccount(Map<Id, Account_Relationship__c> newValues, 
                                                  Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
       // theManager.populateParentAccountEmailPhone(newValues, oldmap, isInsert); // commented by venkat arisa for dat load in Rdev
       
       // The following method is added as part of ACP - creates phone object records - venkat arisa
       theManager.createPhoneRecords(newValues, oldmap, isInsert);
    }
    // Populating account parent broker field on after insert/update trigger event.
    public void onAfterInsertUpdate(Map<Id,Account_Relationship__c> newMap, Map<Id, Account_Relationship__c> oldMap, Boolean isInsert) {
        // Turn off auto population of account custom field named 'Account.Parent_Broker__c' if the value of custom setting field is true.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Account_Parent_Broker__c == false) {
            system.debug('TRACE: Populating account parent broker field.');
            theManager.populateAccountParentBroker(newMap.values(), oldMap, isInsert);
        }
        if(AccountRelationshipTriggerHandlerManager.updateAccrealtion == false)
            theManager.populateIsParentPrimary(newMap, oldMap, isInsert);
        if(!isInsert){
            theManager.setbillngcntctfalseupdate(newMap, oldMap);
            theManager.UpdateLCMPartnerAccounts(newMap, oldMap); //LCM-200,LCM-171
        }
        theManager.setPrimarycntfalseupdate(newMap, oldMap, isInsert);  
        // Turn off agent/office account roll-ups on broker account.
        if(Switch_AccountRelationshipTrigger__c.getInstance().Set_Agent_Office_Rollup_Off__c == false) {
            system.debug('TRACE: Computing total agents and total offices.');
            // theManager.computeTotalAgentsAndTotalOffices(newMap, oldMap, isInsert);
            // modified by Ravinder Reddy
            if(isInsert){
                theManager.setbillngcntctfalseinsert(newMap);
            }  
            if(!isInsert){
                theManager.updateAccountforParentChild(newmap.values());
                
            }
        }
        
        theManager.updateSMSOptIn(newMap.values());
        
        // CRM-4613 - Update Case's contact as per primary contact relationship
        theManager.updateCaseContactwithPrimaryContact(newMap, oldMap, isInsert);
    }
    
    public void onAfterDelete(List<Account_Relationship__c> oldList){
        theManager.updateSMSOptInAfterDelete(oldList);
    }
    
    public void updateAccount(List<Account_Relationship__c> actrlist){
       
        //CRM-1684 - Use map instead of list to avoi duplicate accounts.
        //List<Account> UpdateAccList = New List<Account>();
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        For(Account_Relationship__c ar : actrlist) {
            //CRM-1684 - Avoid adding same account again
            if (!accountsToUpdate.containsKey(ar.parent_account__c)) {
                Account TempAccount = New Account();
                TempAccount.id = ar.parent_account__c;
                TempAccount.SyncButtonEnableDisable__c = TRUE;
                accountsToUpdate.put(ar.parent_account__c, TempAccount);
                //UpdateAccList.add(TempAccount);
            }
        }
        /*If(!UpdateAccList.isEmpty()){
            Update UpdateAccList;
        }*/
        system.debug('acct----->>>>'+accountsToUpdate);
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
        
    }
    
    // CRM-2170 Future method to update Billing_Contact__c flag
    public static Boolean runFutureMethod = true;
    private static Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
    public static void onAfterInsertUpdateUpdateForCDHUser(Map<id, Account_Relationship__c> newMap) {
        Map<id, Account_Relationship__c> contactRelMap = new Map<id, Account_Relationship__c>();
        for (Account_Relationship__c rel : newMap.values()) {
            if (rel.RecordTypeId == contRelationShipRTID) {
                contactRelMap.put(rel.id, rel);
            }
        }
        
        if (contactRelMap.size() > 0) {
            updateContactRoleandBillingContact(JSON.serialize(contactRelMap));
        }
    }
    
    
    @future
    private static void updateContactRoleandBillingContact(String newMapJson) {
        runFutureMethod = false;
        Map<id, Account_Relationship__c> newMap = (Map<id, Account_Relationship__c>) JSON.deserialize(newMapJson, Map<id, Account_Relationship__c>.class);
        AccountRelationshipTriggerHandlerManager theLocalManager = new AccountRelationshipTriggerHandlerManager();
        
        // To update Contact_Role__c to 'Primary Contact' and Billing_Contact__c to true if first relationship inserted.
        theLocalManager.setPrimaryandBillingContactonInsert(newMap.values());
        
        // To update old Relationships Contact_Role__c to '' if inserted relationship has Contact_Role__c as 'Primary Contact'.
        theLocalManager.setPrimarycntfalseupdate(newMap, null, true);
        
        // To update old Relationships Billing_Contact__c to false if inserted relationship has Billing_Contact__c  as true.
        theLocalManager.setbillngcntctfalseinsert(newMap);
        
        // To update Is_Parent_Primary__c to true if Contact_Role__c is 'Primary Contact' and vice versa.
        theLocalManager.setPrimarycntupdate(newMap.Values());
      
        update newMap.values();
    }
    
    // CRM-2170 End
    
    public void handleBeforeInsert(List<Account_Relationship__c> lstRelationship)
    {
        Set<String> setAccId = new Set<String>();
        Set<String> setContactId = new Set<String>();
        Map<String, Boolean> mapAccountContactKey = new Map<String, Boolean>();
        
        for(Account_Relationship__c relationship :lstRelationship)
        {
            setAccId.add(relationship.Parent_Account__c);
            setContactId.add(relationship.Contact_To__c);
        }
        
        if(!setContactId.isEmpty())
        {
            List<Account_Relationship__c> lstAccRel = [Select Id, Parent_Account__c, Contact_To__c 
                                                            From Account_Relationship__c 
                                                            Where Parent_Account__c IN :setAccId 
                                                            AND Contact_To__c IN :setContactId 
                                                            AND Active__c = True];
            
            for(Account_Relationship__c relationship :lstAccRel)
                mapAccountContactKey.put(relationship.Parent_Account__c +'-'+relationship.Contact_To__c, true);
            
            for(Account_Relationship__c relationship :lstRelationship)
            {
                if(relationship.RecordTypeId == contRelationShipRTID && mapAccountContactKey.containsKey(relationship.Parent_Account__c +'-'+relationship.Contact_To__c))
                    relationship.addError('Sorry you cannot create duplicate Contact Relationship Records.');
            }
        }
    }
}