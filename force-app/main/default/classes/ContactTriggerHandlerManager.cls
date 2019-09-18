//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Manager: ContactTriggerHandlerManager
// Trigger Handler: ContactTriggerHandler
// For Trigger: ContactTrigger
// On SObject: Contact
// Description: Trigger on contact object to prevent inactivating a contact when contact is primary on any account in account relationship object.
// If contact passes rules to be inactivated, it's affiliations (account relationship records) are also inactivated.
//
// 23rd March 2015    Hemendra Singh Bhati   Original (Task # T-372662) - ContactTriggerHandler Code Refactored.
// 6th April 2015    Kirti Agarwal   Original (Task # T-376542)
// 24th January 2019 Venkat Arisa- 
//
public with sharing class ContactTriggerHandlerManager {
    private final string CONTACT_ROLE_PRIMARY_CONTACT = 'Primary Contact';
    private final String CONTACT_RECORD_TYPE_CONSUMER = 'Consumer';
    
    private static boolean firstentity = true;
    private static string preventityName; 
    AccountRelationshipTriggerHandlerManager AccRelTriggerHndlrMgr = new AccountRelationshipTriggerHandlerManager();
    
    /*
@method      : preventPrimaryAndBillingContactInactivation
@description : Prevent inactivating a contact when contact is primary on any account in account relationship object.
@params      : trigger.newMap, trigger.oldMap
@returns     : void
@task        : T-369907
@createdby   : Hemendra Singh Bhati
@date        : Friday, 13th March 2015.
*/
    public void preventPrimaryAndBillingContactInactivation(Map<Id, Contact> contactsNewMap, Map<Id, Contact> contactsOldMap) {
        // Extract contacts which are being de-activated.
        Set<Id> contactIds = new Set<Id>();
        for(Contact theContact : contactsNewMap.values()) {
            if(
                contactsOldMap.get(theContact.Id).Active__c != theContact.Active__c &&
                theContact.Active__c == false &&
                theContact.RecordTypeId != Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_CONSUMER).RecordTypeId
            ) {
                contactIds.add(theContact.Id);
            }
        }
        
        // Extract account relationships which are linked to above contacts and are primary contacts.
        if(contactIds.size() > 0) {
            Set<Id> contactsToExclude = new Set<Id>();
            Map<Id, List<Account_Relationship__c>> accountRelationshipRecords = new Map<Id, List<Account_Relationship__c>>();
            for(Account_Relationship__c theAccountRelationship : [SELECT Name, Contact_To__c, Contact_Role__c FROM Account_Relationship__c
                                                                  WHERE Contact_To__c IN :contactIds]) {
                                                                      if(!accountRelationshipRecords.containsKey(theAccountRelationship.Contact_To__c)) {
                                                                          accountRelationshipRecords.put(theAccountRelationship.Contact_To__c, new List<Account_Relationship__c>());
                                                                      }
                                                                      accountRelationshipRecords.get(theAccountRelationship.Contact_To__c).add(theAccountRelationship);
                                                                      
                                                                      if(theAccountRelationship.Contact_Role__c == CONTACT_ROLE_PRIMARY_CONTACT) {
                                                                          contactsToExclude.add(theAccountRelationship.Contact_To__c);
                                                                          contactsNewMap.get(theAccountRelationship.Contact_To__c).addError(
                                                                              'The contact cannot be deactivated since it is used a primary contact in account relationship: ' + theAccountRelationship.Name
                                                                          );
                                                                      }
                                                                  }
            
            // If contact passes rules to be inactivated, it's affiliations (account relationship records) are also inactivated.
            Set<Id> filteredContactIds = new Set<Id>();
            for(Id theContactId : contactIds) {
                if(!contactsToExclude.contains(theContactId)) {
                    filteredContactIds.add(theContactId);
                }
            }
            
            List<Account_Relationship__c> toBeDeactivated = new List<Account_Relationship__c>();
            for(Id theContactId : filteredContactIds) {
                if(accountRelationshipRecords.containsKey(theContactId)) {
                    for(Account_Relationship__c theAccountRelationship : accountRelationshipRecords.get(theContactId)) {
                        theAccountRelationship.Active__c = false;
                        toBeDeactivated.add(theAccountRelationship);
                    }
                }
            }
            if(toBeDeactivated.size() > 0) {
                update toBeDeactivated;
            }
        }
    }
    
    //method to used to create map for Contact and its type for webservice callout
    public void webserviceCallout(List<Contact> contacts, Map<Id,Contact> oldContactMap){
        Map<Id, String> contactIdAndTypeMap = new Map<Id, String>();
        
        // CRM-1828 use map instead of list to avoid duplicates
        Map<Id, Account_Relationship__c> relationshipMap = new Map<Id, Account_Relationship__c>();
        //list<Account_Relationship__c> updaterelationobject = new list<Account_Relationship__c>();
        
        //Profile usrProfile = [Select Id, Name FROM Profile Where Id =:UserInfo.getProfileId()];
        String profileName;
        for(Contact cntctloop : contacts){
            profileName = cntctloop.CurrentUserProfile__c;
        }
        
        if(profileName != 'Move Data Integration') {
            if(!(system.isBatch())){ 
                List<Contact_Entity_Fields__c> EntitySettings = [select Name,Entity_Name__c,Zuoura_Sync__c from Contact_Entity_Fields__c order by Entity_Name__c asc];
                set<Id> cntctids = new set<Id>();
                for(Contact cntctloop : contacts){
                    cntctids.add(cntctloop.id);
                }               
                
                String RecordTypId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Contact Relationship').getRecordTypeId();
                String CRecordTypId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Consumer').getRecordTypeId();
                //string RecordTypId = [SELECT id from RecordType where Name ='Contact Relationship'].Id;
                list<Account_Relationship__c> temprelationobject = [select id,Contact_Role__c,Entity_Name__c,Parent_Account__c,Child_Account__c,Contact_To__c,Billing_Contact__c,Zuora_Sync__c from Account_Relationship__c
                                                                    where Contact_To__c in :cntctids and Active__c = true and RecordTypeId = :RecordTypId 
                                                                    //and Billing_Contact__c = true and Parent_Account__r.Zoura_Account_id__c != null];
                                                                    and (Billing_Contact__c = true or Contact_Role__c = 'Primary Contact') and Contact_To__r.RecordTypeId != :CRecordTypId];// CRM-867 ~MRB // and Parent_Account__r.Zoura_Account_id__c != null];
                
                for(Contact con : contacts) {
                If(con.RecordTypeId != Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_CONSUMER).RecordTypeId){
                    if(oldContactMap == null) {
                        //in case of contact record insertion
                        contactIdAndTypeMap.put(con.Id, 'Contact');
                    }else{
                        Contact oldvalues = oldContactMap.get(con.Id);
                        for(Contact_Entity_Fields__c EntityValues : EntitySettings) {
                            if(con.get(EntityValues.Name) != oldvalues.get(EntityValues.Name)){
                                //Making sure not adding same entity multiple times
                                if(firstentity){
                                    preventityName = EntityValues.Entity_Name__c;
                                    firstentity = false;
                                    contactIdAndTypeMap.put(con.Id, EntityValues.Entity_Name__c);
                                    for(Account_Relationship__c relloop : temprelationobject){
                                        if(relloop.Contact_To__c == con.id && (relloop.Billing_Contact__c == true || relloop.Contact_Role__c == 'Primary Contact') && EntityValues.Zuoura_Sync__c){
                                            relloop.Entity_Name__c = EntityValues.Entity_Name__c;
                                            relloop.Zuora_Sync__c = true;
                                            
                                            // CRM-1828 add record in map instead of list to avoid duplicates
                                            //updaterelationobject.add(relloop); 
                                            relationshipMap.put(relloop.id, relloop);
                                        }
                                    }
                                }
                                //Making sure not adding same entity multiple times
                                if(preventityName != EntityValues.Entity_Name__c && !(firstentity)){
                                    contactIdAndTypeMap.put(con.Id, EntityValues.Entity_Name__c);
                                    for(Account_Relationship__c relloop : temprelationobject){
                                        if(relloop.Contact_To__c == con.id && (relloop.Billing_Contact__c == true || relloop.Contact_Role__c == 'Primary Contact') && EntityValues.Zuoura_Sync__c){
                                            relloop.Entity_Name__c = EntityValues.Entity_Name__c; 
                                            relloop.Zuora_Sync__c = true;
                                            
                                            // CRM-1828 add record in map instead of list to avoid duplicates
                                            //updaterelationobject.add(relloop); 
                                            relationshipMap.put(relloop.id, relloop);
                                        }
                                    }
                                }
                            }
                        }               
                    } 
                    }
                }
                sendOutboundMessage(contactIdAndTypeMap);
                
                // CRM-1828 update record from map instead of list to avoid duplicates
                /*if(updaterelationobject.size() >0)
update updaterelationobject;
*/
                if (!relationshipMap.isEmpty()) {
                    update relationshipMap.values();
                }
            }
        }
    }
    
    // future method used to call out external webservice
    @future(callout=true)
    public static void sendOutboundMessage( Map<Id, String> contactIdAndTypeMap) {
        String typeVal;
        String Response;
        String contactId;
        List<Error__c> errorList = new List<Error__c>();
        
        for(Id conId : contactIdAndTypeMap.keySet()) {
            try{
                typeVal =  contactIdAndTypeMap.get(conId);
                contactId = String.valueOf(conId);
                if(contactId.length() == 15) {
                    contactId = MoveUtility.convertID15to18(contactId);
                }
                Response = new xmlnsOracleComInt003ContactSynccont.SyncContactSFDCToCDHServiceBindingQSPort().process(contactId, typeVal);
            }catch(exception e) {
                // Added For Task T-396332
                if(contactId.length() > 15) {
                    contactId = contactId.substring(0,15);
                }
                errorList.add(new Error__c(Entity_Id__c = contactId,Interface_Name__c = typeVal, Error_Description__c = e.getMessage()));
            }
        }
        if(!errorList.isEmpty()) {
            insert errorList;
        }
    }
    
    /**
*  Method to update SMS Opt In field on Account - CRM-951
*  If contact has SMS_Opt_In__c checked then Accounts associated with it must have that box checked 
*  If SMS_Opt_In__c is unchecked on contact, then all associated accounts will be updated to opt out ONLY IF there is no other contact with SMS opt in box checked         
**/
    
    //Commented as part of Jira SMCI-554
    /*public void updateSMSOptIn(List<Contact> oldContact, Map<Id, Contact> newContact){
        
        Set<Id> conSet = new Set<Id> ();
        List<Account> AcctUpdList = new List<Account> ();
        Set<Account> AcctUpdSet = new Set<Account>();
        List<Account_Relationship__c> accRepList = new List<Account_Relationship__c> ();
        
        Map<Id,List<Id>> AcctConMapList = new Map<Id,List<Id>>();
        for (contact contactLoop : oldContact) {
            Contact newContactObj = newContact.get(contactLoop.id);
            
            if(contactLoop.SMS_Opt_In__c != newContactObj.SMS_Opt_In__c || newContactObj.Active__c != contactLoop.Active__c) {
                conSet.add(contactLoop.id);
            }
        }  
        
        List<Account_Relationship__c> AccRelList = [Select id, Parent_Account__c, Active__c, Contact_To__c, Contact_To__r.SMS_Opt_In__c, Parent_Account__r.SMS_Opt_In__c, Contact_To__r.Active__c from Account_Relationship__c where Contact_To__c In :conSet];
        for (Account_Relationship__c AccRelListLoop : AccRelList) {
            
            Account acc= new Account();
            acc.Id = AccRelListLoop.Parent_Account__c;
            if(AccRelListLoop.Contact_To__r.SMS_Opt_In__c == true && !AccRelListLoop.Parent_Account__r.SMS_Opt_In__c && AccRelListLoop.Contact_To__r.Active__c == true && AccRelListLoop.Active__c == true && acc.Id != null){
                acc.SMS_Opt_In__c = true;
                AcctUpdSet.add(acc);
                System.debug('account ------->' + acc);
            } else if((!AccRelListLoop.Contact_To__r.SMS_Opt_In__c || !AccRelListLoop.Contact_To__r.Active__c) && AccRelListLoop.Parent_Account__r.SMS_Opt_In__c == true && acc.Id != null) {
                accRepList.add(AccRelListLoop);
            }
        }
        System.debug('acc set------->' + AcctUpdSet);
        if(!AcctUpdSet.isEmpty()) {
            AcctUpdList.addall(AcctUpdSet);
            update AcctUpdList;
        }
        if(!accRepList.isEmpty())
            AccRelTriggerHndlrMgr.updateSMSOptInField(accRepList);
        
    } */
    
    /*  public void updateSMSOptInField(List<Account_Relationship__c>  accRelLoopList){
Set<Id> acctSet = new Set<Id> ();
Set<Id> contSet = new Set<Id> ();
Set<Id> parentAcctSet = new Set<Id> ();
Map<Id,List<Id>> AcctConMapList = new Map<Id,List<Id>>();
Set<Account> acctUpdSet = new Set<Account> ();
List<Account> acctList = new List<Account> ();
Map<id, Boolean> contactOnAccMap = new Map<id, Boolean>();
Set<Id> RepSet = new Set<Id> ();
Map<Id, Id> conRelMap = new Map<Id, Id>();

for(Account_Relationship__c accRep: accRelLoopList) {
if(!acctSet.contains(accRep.Parent_Account__c)){
acctSet.add(accRep.Parent_Account__c);
}
RepSet.add(accRep.Id);
}

list<Account_Relationship__c> accRelList = [Select id, Parent_Account__c, Contact_To__c, Contact_To__r.SMS_Opt_In__c from Account_Relationship__c  where Parent_Account__c IN :acctSet and Relationship_Type__c = 'Contact' and Active__c = true];

for(Account_Relationship__c accRel: accRelList){
if(!parentAcctSet.contains(accRel.Parent_Account__c)){
parentAcctSet.add(accRel.Parent_Account__c);
}

if(AcctConMapList.containsKey(accRel.Parent_Account__c)) {
List<Id> conList = AcctConMapList.get(accRel.Parent_Account__c);
conList.add(accRel.Contact_To__c);
AcctConMapList.put(accRel.Parent_Account__c, conList);
}else {                
AcctConMapList.put(accRel.Parent_Account__c, new List<Id> {accRel.Contact_To__c});
}                                         
contactOnAccMap.put(accRel.Contact_To__c, accRel.Contact_To__r.SMS_Opt_In__c);
}

set<id> acctMakeFalse = new set<id> ();
for(id acctSetLoop : acctSet){
if(!parentAcctSet.contains(acctSetLoop)) {
Account acct = new Account();
acct.Id = acctSetLoop;
acct.SMS_Opt_In__c = false;
System.debug('make false------>');
acctUpdSet.add(acct);
}
}
System.debug('----> acclist' + AcctConMapList);
for(Id acctId : AcctConMapList.keySet()){
Boolean IsSMSOptInTrueFlag = false;
List<Id> contIdList = AcctConMapList.get(acctId);
for(Id cont: contIdList) {

if(contactOnAccMap.get(cont) == true  && !contactOnAccMap.containsKey(null)) {
IsSMSOptInTrueFlag = true;
Account acct = new Account();
acct.Id = acctId;
acct.SMS_Opt_In__c = true;
acctUpdSet.add(acct);
System.debug('----> conlist true' + IsSMSOptInTrueFlag);
break;
}                   
}
if(!IsSMSOptInTrueFlag) {
Account acct = new Account();
acct.Id = acctId;
acct.SMS_Opt_In__c = false;
acctUpdSet.add(acct);
System.debug('----> conlist fals' + IsSMSOptInTrueFlag);
}

}

if(!acctUpdSet.isEmpty()){
acctList.addall(acctUpdSet);
update acctList;
} 
}
*/
    
    /*. When DoNotContact flag is changed, create an entry in OptInOut table, if entry already exists do an upsert
*/    
    public void updateCMWhenDoNotContact(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){     
        List<Id> contactIds = new List<Id>();
        List<ContactMethod__c> updateContactMethods = new List<ContactMethod__c>();
        Set<ContactMethod__c> updCMSet = new Set<ContactMethod__c>();
        Map<Id,List<ContactMethod__c>> CMContMapList = new Map<Id,List<ContactMethod__c>>();
        
        for(Contact contactRecord: newContactMap.values()){
            if(null != oldContactMap && newContactMap.get(contactRecord.Id).Do_Not_Contact__c != oldContactMap.get(contactRecord.Id).Do_Not_Contact__c){
                contactIds.add(contactRecord.Id);
            }
        }
        
        system.debug(' ****** contactIds '+contactIds); 
        if(!contactIds.isEmpty()){           
            for(ContactMethod__c cm: [Select id, Contact__c, Contact__r.Id, Contact__r.Do_Not_Contact__c, Type__c, RDC_Event_OptIn__c, TP_Info_OptIn__c,
                                      RDC_Promo_OptIn__c, TP_Event_OptIn__c, TP_Promo_OptIn__c, RDC_Info_OptIn__c
                                      from ContactMethod__c where Contact__c In: contactIds and Type__c = 'Email']){
                if(CMContMapList.containsKey(cm.Contact__r.Id)) {
                    List<ContactMethod__c> CMgetList = CMContMapList.get(cm.Contact__r.Id);
                    CMgetList.add(cm);
                    CMContMapList.put(cm.Contact__r.Id, CMgetList);
                } else {
                    CMContMapList.put(cm.Contact__r.Id, new List<ContactMethod__c> { cm });
                }
            }
            for(Id contId:contactIds){
                if(!CMContMapList.isEmpty() && CMContMapList.ContainsKey(contId)){
                    for(ContactMethod__c cm: CMContMapList.get(contId)){
                        cm.RDC_Event_OptIn__c = cm.Contact__r.Do_Not_Contact__c? false:true;
                        cm.RDC_Promo_OptIn__c = cm.Contact__r.Do_Not_Contact__c? false:true; 
                        cm.TP_Event_OptIn__c  = cm.Contact__r.Do_Not_Contact__c? false:true;
                        cm.TP_Promo_OptIn__c  = cm.Contact__r.Do_Not_Contact__c? false:true; 
                        cm.RDC_Info_OptIn__c  = cm.Contact__r.Do_Not_Contact__c? false:true;
                        cm.TP_Info_OptIn__c   = cm.Contact__r.Do_Not_Contact__c? false:true;
                      updCMSet.add(cm);  
                    }
                }
            } 
        }
        
        system.debug(' ****** updCMSet '+updCMSet);
        if(!updCMSet.isEmpty()){
            try{
                updateContactMethods.addAll(updCMSet);
                update updateContactMethods;
            }catch(DMLException ex){
                system.debug(' Unable to Upsert the OptInOut Events due to: '+ ex.getMessage());
            }
        }
    }
    
}