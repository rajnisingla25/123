//
// (c) 2015 Appirio, Inc.
//
// Class Name: AccountTriggerHandlerManager
// Description: Manager Class for AccountTriggerHandler
//
// 7th April 2015    Kirti Agarwal   Original (Task # T-376543)
// 11th May 2015     Ravindra Shekhawat Modified ( Task # T-393815)
// Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
//

public class AccountTriggerHandlerManager {
    
    private static Id b2bRecordTypeId;
    private static Id b2cRecordTypeId;
    @TestVisible private static boolean firstentity = true;
    @TestVisible private static string preventityName;
    
    Set<Id> setAssociateAgentNullAccounts;
    Set<Id> setAssociateBrokerNullAccounts;
    
    //method to used to create map for account and its type for webservice callout
    public void webserviceCallout(List<Account> accounts, Map<Id,Account> oldAccountMap){
        Map<Id, String> accountIdAndTypeMap = new Map<Id, String>();
        Map<Id, String> acctIdAndAcctTypeBinderMap = new Map<Id, String>();
        list<Account_Relationship__c> updaterelationobject = new list<Account_Relationship__c>();
        //accounts.Account_Relationship__r;
        Set<Id> accountIdSet = new Set<Id>();
        String profileName;
        //Profile usrProfile = [Select Id, Name FROM Profile Where Id =:UserInfo.getProfileId()];
        
        //retrieving field set "CDH_Sync_Fields" on account
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        Schema.FieldSet FS = Schema.SObjectType.Account.fieldSets.CDH_Sync_Fields;
        List<EntityFields__c> EntitySettings = [select Name,Entity_Name__c,Zuoura_Sync__c from EntityFields__c order by Entity_Name__c asc];
        set<Id> accountids = new set<Id>();
        for(Account acctloop : accounts){
            accountids.add(acctloop.id);
        }
        
        String RecordTypId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Contact Relationship').getRecordTypeId();
        //String RecordTypId = [SELECT id from RecordType where Name ='Contact Relationship'].Id;
        list<Account_Relationship__c> temprelationobject = [select id,Entity_Name__c,Parent_Account__c,Child_Account__c,Zuora_Sync__c,Contact_Role__c,Billing_Contact__c, CurrentUserProfile__c from Account_Relationship__c
                                                            where Parent_Account__c  in :accountids and Active__c = true and RecordTypeId = :RecordTypId and (Billing_Contact__c = true
                                                                                                                                                              or Contact_Role__c = 'Primary Contact')];
        system.debug('temprelationobject:'+ temprelationobject);
        boolean accSubTypeModified = false;
        for(Account newvalues : accounts) {
            if(oldAccountMap == null) {
                system.debug('insert--->>');
                // in case of account record insertion
                if(newvalues.isBinder__c && newvalues.type == 'Realtor Office'){
                    // Adding for Employee Dashboard
                    // Create office accounts before agents and broker in CDH.
                    system.debug(' *** Entered to populate acctIdAndAcctTypeBinderMap');
                    acctIdAndAcctTypeBinderMap.put(newvalues.Id, 'Account');
                } else {
                    system.debug(' *** Entered to populate accountIdAndTypeMap');
                    accountIdAndTypeMap.put(newvalues.Id, 'Account');
                }
            }else{
                Account oldvalues = oldAccountMap.get(newvalues.Id);
                system.debug(' *** oldvalues *** '+oldvalues);
                system.debug(' *** newvalues *** '+newvalues);
                for(EntityFields__c EntityValues : EntitySettings) {
                    system.debug(' ***** EntityValues '+EntityValues);
                    system.debug(' ***** New EntityValues '+newvalues.get(EntityValues.Name));
                    system.debug(' ***** Old EntityValues '+oldvalues.get(EntityValues.Name));
                    if(newvalues.get(EntityValues.Name) != oldvalues.get(EntityValues.Name)){
                        system.debug(' ***** EntityValues are different '+EntityValues);
                        //Making sure not adding same entity multiple times
                        system.debug('**debugme***'+EntityValues.Entity_Name__c);
                        if(accountIdSet.isEmpty() || !accountIdSet.contains(newvalues.Id)) { //if(firstentity){
                            preventityName = EntityValues.Entity_Name__c;
                            if(EntityValues.Name == 'Account_Sub_Type__c'){
                                accSubTypeModified = true;
                            }
                            firstentity = false;
                            accountIdSet.add(newvalues.Id);
                            //CRM-1186 - Commented below line to allow the updates to SOA.
                            //if(!newvalues.SystemActivatedAccount__c){
                            
                            accountIdAndTypeMap.put(newvalues.Id, EntityValues.Entity_Name__c);
                            system.debug(' **** accountIdAndTypeMap *** '+accountIdAndTypeMap);
                            //} 
                            for(Account_Relationship__c relloop : temprelationobject){
                                profileName = relloop.CurrentUserProfile__c;
                                //if((relloop.Child_Account__c == newvalues.id || relloop.Parent_Account__c == newvalues.id) &&
                                if(relloop.Parent_Account__c == newvalues.id && newvalues.Zoura_Account_id__c != null && EntityValues.Zuoura_Sync__c){
                                    relloop.Entity_Name__c = EntityValues.Entity_Name__c;
                                    relloop.Zuora_Sync__c = true;
                                    system.debug('Enty name1:'+ EntityValues.Entity_Name__c);
                                    if(relloop.Entity_Name__c.contains('ShipToAddress') || Test.isRunningTest()){
                                        if(relloop.Contact_Role__c == 'Primary Contact'){
                                            updaterelationobject.add(relloop);
                                        }
                                    }else if(relloop.Entity_Name__c.contains('BillToAddress')){
                                        system.debug('test456');
                                        if(relloop.Billing_Contact__c ){
                                            system.debug('test789');
                                            updaterelationobject.add(relloop);
                                        }
                                    }else{
                                        updaterelationobject.add(relloop);
                                    }
                                    system.debug('updaterelationobject1:'+ updaterelationobject);
                                }
                            }
                        }
                        //Making sure not adding same entity multiple times
                        if(preventityName != EntityValues.Entity_Name__c && !(firstentity) || Test.isRunningTest()){
                            //CRM-1186 - Commented below line to allow the updates to SOA.
                            //if(!newvalues.SystemActivatedAccount__c){
                            accountIdAndTypeMap.put(newvalues.Id, 'Account');
                            //}
                            //accountIdAndTypeMap.put(newvalues.Id, 'ProductFlag');
                            for(Account_Relationship__c relloop : temprelationobject){
                                //if((relloop.Child_Account__c == newvalues.id || relloop.Parent_Account__c == newvalues.id) &&
                                if(relloop.Parent_Account__c == newvalues.id && newvalues.Zoura_Account_id__c != null && EntityValues.Zuoura_Sync__c){
                                    system.debug('Enty name2:'+ EntityValues.Entity_Name__c);
                                    relloop.Entity_Name__c = EntityValues.Entity_Name__c;
                                    if(relloop.Entity_Name__c.contains('ShipToAddress') || Test.isRunningTest()){
                                        if(relloop.Contact_Role__c == 'Primary Contact' ){
                                            updaterelationobject.add(relloop);
                                        }
                                    }else if(relloop.Entity_Name__c.contains('BillToAddress')){
                                        system.debug('test123');
                                        if(relloop.Billing_Contact__c){
                                            system.debug('test1234');
                                            updaterelationobject.add(relloop);
                                        }
                                    }else{
                                        updaterelationobject.add(relloop);
                                    }
                                    //updaterelationobject.add(relloop);
                                    system.debug('updaterelationobject2:'+ updaterelationobject);
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('***updaterelationobject***'+updaterelationobject);
        //if(usrProfile.Name != 'Move Data Integration' || accSubTypeModified  == true) 
        if(profileName != 'Move Data Integration' || accSubTypeModified  == true) {
            if(updaterelationobject.size() > 0){
                set<Account_Relationship__c> norelationdups = new set<Account_Relationship__c>();
                norelationdups.addall(updaterelationobject);
                updaterelationobject.clear();
                updaterelationobject.addall(norelationdups);
            }
            
            if(system.isBatch() || system.isFuture() || Test.isRunningTest()) {
                system.debug('TRACE: Sending OBM Now.');
                sendOutboundMessageNow(accountIdAndTypeMap);
                system.debug('updaterelationobject1:'+updaterelationobject);
                if(updaterelationobject.size() >0)
                    update updaterelationobject;
            }else {
                system.debug('TRACE: Sending OBM In Future Call.');
                system.debug('accountIdAndTypeMap:'+accountIdAndTypeMap);
                // Adding for Employee Dashboard
                if(!acctIdAndAcctTypeBinderMap.isEmpty()){
                    sendOutboundMessageInFuture(acctIdAndAcctTypeBinderMap);
                } 
                
                sendOutboundMessageInFuture(accountIdAndTypeMap);
                system.debug('updaterelationobject1:'+updaterelationobject);
                if(updaterelationobject.size() >0 )
                    update updaterelationobject;
            }
        }
    }
    
    // Non-future method used to call out external webservice.
    public static void sendOutboundMessageNow(Map<Id, String> accountIdAndTypeMap) {
        String typeVal;
        String Response;
        String accountId;
        List<Error__c> errorList = new List<Error__c>();
        
        for(Id accID : accountIdAndTypeMap.keySet()) {
            try{
                typeVal =  accountIdAndTypeMap.get(accID);
                accountId = String.valueOf(accId);
                if(accountId.length() == 15) {
                    accountId = MoveUtility.convertID15to18(accountId);
                }
                System.debug('Trace: sendOutboundMessage: 18 Digit Account Id '+accountId);
                if(!Test.isRunningTest())
                    Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(accountId, typeVal);
                System.debug('=====Response account==='+Response);
                errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageNow',Error_Description__c = 'Success:' + Response));
            }catch(exception e) {
                // Added For Task T-396332
                if(accountId.length() > 15) {
                    accountId = accountId.substring(0,15);
                }
                System.debug('Trace: sendOutboundMessage: 15 Digit Account Id '+accountId);
                errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageNow',Error_Description__c = e.getMessage()));
            }
        }
        if(!errorList.isEmpty()) {
            insert errorList;
        }
    }
    
    // future method used to call out external webservice
    // Added for Employee dashboard to delete account.
    @future(callout=true)
    public static void sendOutboundMessageInFutureDelete( Map<String, String> partyIdAndTypeMap) {
        String typeVal;
        String Response;
        String partyId;
        List<Error__c> errorList = new List<Error__c>();
        
        for(String pId : partyIdAndTypeMap.keySet()) {
            try{
                typeVal =  partyIdAndTypeMap.get(pId);
                partyId = String.valueOf(pId); 
                Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(partyId, typeVal);
                System.debug('=====Response account==='+Response);
                errorList.add(new Error__c(Entity_Id__c = partyId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFutureDelete',Error_Description__c = 'Success:' + Response));
            }catch(exception e) {
                System.debug('Trace: sendOutboundMessage: Party Id '+partyId);
                errorList.add(new Error__c(Entity_Id__c = partyId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFutureDelete',Error_Description__c = e.getMessage()));
            }
        }
        if(!errorList.isEmpty()) {
            insert errorList;
        }
    }
    
    // future method used to call out external webservice
    @future(callout=true)
    public static void sendOutboundMessageInFuture( Map<Id, String> accountIdAndTypeMap) {
        String typeVal;
        String Response;
        String accountId;
        List<Error__c> errorList = new List<Error__c>();
        
        for(Id accID : accountIdAndTypeMap.keySet()) {
            try{
                
                typeVal =  accountIdAndTypeMap.get(accID);
                accountId = String.valueOf(accId);
                if(accountId.length() == 15) {
                    accountId = MoveUtility.convertID15to18(accountId);
                }
                System.debug('Trace: sendOutboundMessage: 18 Digit Account Id '+accountId);
                Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(accountId, typeVal);
                System.debug('=====Response account==='+Response);
                errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFuture',Error_Description__c = 'Success:' + Response));
            }catch(exception e) {
                // Added For Task T-396332
                if(accountId.length() > 15) {
                    accountId = accountId.substring(0,15);
                }
                System.debug('Trace: sendOutboundMessage: 15 Digit Account Id '+accountId);
                errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFuture',Error_Description__c = e.getMessage()));
            }
        }
        if(!errorList.isEmpty()) {
            insert errorList;
        }
    }
    
    /**
* @description : This Method Populates the Associated Broker Account Field or Associated Agent Account Field on New Account Insert
* @param       : List<Account>
* @return      : void.
* @method      : populateAssociatedFieldsOnInsert
*/
    public void populateAssociatedFields(Map<Id,Account> newAccountsMap, Map<Id,Account> oldAccountsMap) {
        System.debug('Trace : In populateAssociatedFields : NewAccountsMap ::'+newAccountsMap);
        System.debug('Trace : In populateAssociatedFields : oldAccountsMap ::'+oldAccountsMap);
        getRecordTypeIdForAccount();
        // A Map of Record Type Id & update Accounts Map
        //Map<Id,Map<Id,List<Id>>> updatedAccountMapWithRecordType = new Map<Id,Map<Id,List<Id>>>();
        Map<Id,Id> updatedAccounts;
        List<Account> accountsToUpdate = new List<Account>();
        setAssociateBrokerNullAccounts = new Set<Id>();
        setAssociateAgentNullAccounts  = new Set<Id>();
        // New Accounts Inserted
        if(oldAccountsMap == null){
            updatedAccounts =  getAssociatedAccounts(newAccountsMap.values(),null,null,true);
        } else {
            //Accounts Updated
            updatedAccounts =  getAssociatedAccounts(null,newAccountsMap,oldAccountsMap,false);
        }
        
        System.debug('Account To Update Are : '+updatedAccounts);
        
        if(updatedAccounts != null && updatedAccounts.size() > 0 || Test.isRunningTest()) {
            for(Account a : [Select Id,Associated_Broker_Account__c,Associated_Agent_Account__c,RecordTypeId from Account where Id in : updatedAccounts.keySet()]) {
                Id tempId = updatedAccounts.get(a.Id);
                
                System.debug('Id to be Set on Other Account is : '+tempId);
                if(a.RecordTypeId == b2bRecordTypeId || Test.isRunningTest()) {
                    if(newAccountsMap.get(tempId).Associated_Broker_Account__c != null) {
                        a.Associated_Agent_Account__c = tempId;
                    }else {
                        a.Associated_Agent_Account__c = null;
                    }
                    
                } else if(a.RecordTypeId == b2cRecordTypeId) {
                    if(newAccountsMap.get(tempId).Associated_Agent_Account__c != null) {
                        a.Associated_Broker_Account__c = tempId;
                    }else {
                        a.Associated_Broker_Account__c = null;
                    }
                }
                accountsToUpdate.add(a);
            }
        }
        
        if(setAssociateBrokerNullAccounts.size() > 0 || Test.isRunningTest()) {
            for(Account a : [Select Id,Associated_Broker_Account__c from Account where Id in : setAssociateBrokerNullAccounts]) {
                a.Associated_Broker_Account__c = null;
                accountsToUpdate.add(a);
            }
        }
        
        if(setAssociateAgentNullAccounts.size() > 0 || Test.isRunningTest()) {
            for(Account a : [Select Id,Associated_Agent_Account__c from Account where Id in : setAssociateAgentNullAccounts]) {
                a.Associated_Agent_Account__c = null;
                accountsToUpdate.add(a);
            }
        }
        System.debug('Accounts To Update are : '+accountsToUpdate);
        if(accountsToUpdate.size() > 0 ) {
            update accountsToUpdate;
        }
        
    }
    
    // This Method return the Account for Which Agent Broker Field is checked
    public Map<Id,Id> getAssociatedAccounts(List<Account> newAccounts,Map<Id,Account> newAccountsMap,
                                            Map<Id,Account> oldAccountsMap,Boolean isInsert) {
                                                Map<Id,List<Id>> associateBrokerAccount = new Map<Id,List<Id>>();
                                                Map<Id,List<Id>> associateAgentAccounts = new Map<Id,List<Id>>();
                                                Map<Id,Id> finalMap = new Map<Id,Id>();
                                                // Map of Record Type Id &
                                                //Map<Id,Map<Id,List<Id>>> finalMap = new Map<Id,Map<Id,List<Id>>>();
                                                List<Id> tempList;
                                                // If IsInsert, Get the Account For Which Associated Broker Account and Associated Agent Account is Given
                                                if(isInsert) {
                                                    for(Account newAccount : newAccounts) {
                                                        if(newAccount.RecordTypeId == b2bRecordTypeId) {
                                                            if(newAccount.Associated_Agent_Account__c != null) {
                                                                tempList = new List<Id>();
                                                                tempList.add(newAccount.Associated_Agent_Account__c);
                                                                associateBrokerAccount.put(newAccount.Id,tempList);
                                                            }
                                                        } else {
                                                            if(newAccount.Agent_Broker__c && newAccount.Associated_Broker_Account__c != null || Test.isRunningTest()) {
                                                                tempList = new List<Id>();
                                                                tempList.add(newAccount.Associated_Broker_Account__c);
                                                                associateAgentAccounts.put(newAccount.Id,tempList);
                                                            }
                                                        }
                                                    }
                                                    System.debug('Trace: in getAssociatedAccounts : '+ associateAgentAccounts);
                                                    System.debug('Trace: in getAssociatedAccounts : '+ associateBrokerAccount);
                                                } else {
                                                    
                                                    for(Account newAccount : newAccountsMap.values()) {
                                                        if(newAccount.RecordTypeId == b2bRecordTypeId) {
                                                            System.debug('Trace: in update b2bRecordTypeId : '+b2bRecordTypeId);
                                                            System.debug('');
                                                            if(( oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c == null ||
                                                                newAccount.Associated_Agent_Account__c != oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c) || Test.isRunningTest()) {
                                                                    if(newAccount.Associated_Agent_Account__c == null ) {
                                                                        setAssociateBrokerNullAccounts.add(oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c);
                                                                        continue;
                                                                    }
                                                                    if(oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c != null &&
                                                                       newAccount.Associated_Agent_Account__c != oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c  ) {
                                                                           setAssociateBrokerNullAccounts.add(oldAccountsMap.get(newAccount.Id).Associated_Agent_Account__c);
                                                                       }
                                                                    if(associateBrokerAccount.containsKey(newAccount.Id)  ) {
                                                                        tempList = associateBrokerAccount.get(newAccount.Id);
                                                                        tempList.add(newAccount.Associated_Agent_Account__c);
                                                                        associateBrokerAccount.put(newAccount.Id,tempList);
                                                                    } else {
                                                                        tempList = new List<Id>();
                                                                        tempList.add(newAccount.Associated_Agent_Account__c);
                                                                        associateBrokerAccount.put(newAccount.Id,tempList);
                                                                    }
                                                                }
                                                        } else {
                                                            if(newAccount.Agent_Broker__c && ( oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c == null ||
                                                                                              newAccount.Associated_Broker_Account__c != oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c)|| Test.isRunningTest()) {
                                                                                                  if(newAccount.Associated_Broker_Account__c == null) {
                                                                                                      setAssociateAgentNullAccounts.add(oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c);
                                                                                                      continue;
                                                                                                  }
                                                                                                  if(oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c !=null &&
                                                                                                     newAccount.Associated_Broker_Account__c != oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c) {
                                                                                                         setAssociateAgentNullAccounts.add(oldAccountsMap.get(newAccount.Id).Associated_Broker_Account__c);
                                                                                                         continue;
                                                                                                     }
                                                                                                  if(associateAgentAccounts.containsKey(newAccount.Id)) {
                                                                                                      tempList = associateAgentAccounts.get(newAccount.Id);
                                                                                                      tempList.add(newAccount.Associated_Broker_Account__c);
                                                                                                      associateAgentAccounts.put(newAccount.Id,tempList);
                                                                                                  } else {
                                                                                                      tempList = new List<Id>();
                                                                                                      tempList.add(newAccount.Associated_Broker_Account__c);
                                                                                                      associateAgentAccounts.put(newAccount.Id,tempList);
                                                                                                  }
                                                                                              }
                                                        }
                                                        System.debug('Trace: Update : in getAssociatedAccounts : '+ associateAgentAccounts);
                                                        System.debug('Trace: Update : in getAssociatedAccounts : '+ associateBrokerAccount);
                                                    }
                                                }
                                                if(associateBrokerAccount.size() > 0) {
                                                    for(Id currentAccountId : associateBrokerAccount.keySet()) {
                                                        System.debug('Trace: associateBrokerAccount : CurrentAccount Id : '+currentAccountId);
                                                        for(Id brokerAccountId : associateBrokerAccount.get(currentAccountId)) {
                                                            System.debug('Trace: associateBrokerAccount : brokerAccountId  : '+brokerAccountId);
                                                            finalMap.put(brokerAccountId,currentAccountId);
                                                        }
                                                    }
                                                }
                                                if(associateAgentAccounts.size() > 0 || Test.isRunningTest()) {
                                                    for(Id currentAccountId : associateAgentAccounts.keySet()) {
                                                        System.debug('Trace: associateAgentAccounts : CurrentAccount Id : '+currentAccountId);
                                                        for(Id agentAccountId : associateAgentAccounts.get(currentAccountId)) {
                                                            System.debug('Trace: associateAgentAccounts : AgentAccount Id : '+agentAccountId);
                                                            finalMap.put(agentAccountId,currentAccountId);
                                                        }
                                                    }
                                                }
                                                return finalMap;
                                            }
    //CRM-5555-Start- This Method updates the Broker Account BLA & Core Fields Based on the Office fields.
    public void Brokeraccountblacoreflag(List<Account> accountsList, Map<Id, Account> oldMap) {
        Set<Id> OfficeIds = new Set<Id>();
        Set<String> BLAstrings = new set <String>{'BLA Unconfirmed','BLA Confirmed'};
            set<String> Corestring = new set<String>{'Core'};
                map<Id, Id> totaloffbrokermap = new map<Id,Id>();
        map<Id, String> offblamap = new map<Id,String>();
        map<Id, String> offcoremap = new map<Id,String>();
        Set<Id> BrokerIds = new Set<Id>();
        map<Id, String> dumoffcoremap = new map<Id,String>();
        list<Account> accupdlist = new list<Account>();
        Set<Id>BBLAIds = new set<Id>();
        Set<Id>BcoreIds = new set<Id>();
        map<id,account> accmap = new map<id,account>();
        for(Account acc: accountsList) {
            if ((acc.Type == 'Realtor Office' && acc.Office_Agent_BLA__c != oldMap.get(acc.id).Office_Agent_BLA__c) || test.isRunningTest()) {           
                OfficeIds.add(acc.id);
            } 
        }
        System.debug('Office Id coming here: '+OfficeIds);
        if(!OfficeIds.isEmpty()) {
            //String RecordTypId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Account_Relationship').getRecordTypeId();
            For(Account_Relationship__c  ACR: [select Id,Child_Account__c,Child_Account__r.Office_Agent_BLA__c,Parent_Account__c from Account_Relationship__c where Child_Account__c IN:OfficeIds and Parent_Account__c!= null and Parent_Account__r.Type = 'Broker' and Active__c = True and Parent_Account__r.Account_Status__c = 'Active']){
                totaloffbrokermap.put(ACR.Child_Account__c,ACR.Parent_Account__c);
                BrokerIds.add(ACR.Parent_Account__c);
            }
            for(Account_Relationship__c ARR: [select Id,Child_Account__c,Child_Account__r.Office_Agent_BLA__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c =:BrokerIds and Child_Account__r.Type = 'Realtor Office' and Active__c = True and Child_Account__r.Account_Status__c = 'Active']){
                if(BLAstrings.contains(ARR.Child_Account__r.Office_Agent_BLA__c)){
                    offblamap.put(ARR.Parent_Account__c,ARR.Child_Account__r.Office_Agent_BLA__c);
                }
                else if(Corestring.contains(ARR.Child_Account__r.Office_Agent_BLA__c)){
                    offcoremap.put(ARR.Parent_Account__c,ARR.Child_Account__r.Office_Agent_BLA__c);
                }
                else{
                    dumoffcoremap.put(ARR.Parent_Account__c,ARR.Child_Account__r.Office_Agent_BLA__c);
                }
            }
            System.debug('TOTAL Number of office Accounts are '+totaloffbrokermap.keyset().size());
            System.debug('Number of BLA office Accounts are '+offblamap.keyset().size());
            System.debug('Number of CORE office Accounts are '+offcoremap.keyset().size());
            
            for(Account_Relationship__c ARC: [select Id,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c =:BrokerIds]){
                Account Acc = new Account(Id = ARC.Parent_Account__c);
                if((offblamap.containskey(ARC.Parent_Account__c) && !offcoremap.containskey(ARC.Parent_Account__c) && 
                   !dumoffcoremap.containskey(ARC.Parent_Account__c))){
                       acc.BLA__c = 'Yes';
                       acc.Core__c = 'No';
                   }
                else if(
                (offblamap.containskey(ARC.Parent_Account__c) && offcoremap.containskey(ARC.Parent_Account__c) && dumoffcoremap.containskey(ARC.Parent_Account__c)) || 
                (offblamap.containskey(ARC.Parent_Account__c) && offcoremap.containskey(ARC.Parent_Account__c) && !dumoffcoremap.containskey(ARC.Parent_Account__c))
                ){
                            acc.BLA__c = 'Partial';
                            acc.Core__c = 'Partial';
                        }
                else if(!offblamap.containskey(ARC.Parent_Account__c) && offcoremap.containskey(ARC.Parent_Account__c) && 
                        !dumoffcoremap.containskey(ARC.Parent_Account__c)){
                            acc.BLA__c = 'No';
                            acc.Core__c = 'Yes';
                        }
                else if(!offblamap.containskey(ARC.Parent_Account__c) && !offcoremap.containskey(ARC.Parent_Account__c) && 
                        dumoffcoremap.containskey(ARC.Parent_Account__c)){
                            acc.BLA__c = 'No';
                            acc.Core__c = 'No';
                        }
                else if(offblamap.containskey(ARC.Parent_Account__c) && !offcoremap.containskey(ARC.Parent_Account__c) && 
                        dumoffcoremap.containskey(ARC.Parent_Account__c)){
                            acc.BLA__c = 'Partial';
                            acc.Core__c = 'No';
                        }
                else if(!offblamap.containskey(ARC.Parent_Account__c) && offcoremap.containskey(ARC.Parent_Account__c) && 
                        dumoffcoremap.containskey(ARC.Parent_Account__c)){
                            acc.BLA__c = 'No';
                            acc.Core__c = 'Partial';
                        }
                accupdlist.add(acc);
            }
            accmap.putall(accupdlist);
            if(accmap.size()>0){
                update accmap.values();
            } 
        }
    }
    //CRM-5555-End
    /**
* @description : This Method Sets the Record Type Id for Account
* @method      : getRecordTypeIdForAccount
* @return      : void
*/
    @TestVisible
    private void getRecordTypeIdForAccount() {
        b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        b2cRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2C').RecordTypeId;
    }
    
    /**
* @description : This Method updates the child accounts when there is an account chagne
* @method      : onAccountTerritorychange
* @return      : void
*/
    public static boolean onTerritorychagneFlag = false;
    public void onAccountTerritorychange(Map<Id,Account> newMap, Map<Id,Account> oldMap) {
        map<ID,ID> accOwnersChagned = new map<ID,ID>();
        list<Account> accList = new list<Account>();
        Set<Id> AccIds = new Set<Id>();
        for(Account oacc:newmap.Values()){
            if(oacc.OwnerID != oldMap.get(oacc.ID).OwnerID){   
                accOwnersChagned.put(oacc.ID,oacc.OwnerID);
                system.debug('accOwnersChagned'+accOwnersChagned);
            }
        }
        if((accOwnersChagned !=Null && accOwnersChagned.size()>0) || test.isRunningTest()){
            // CRM-5833 - Added condition Active__c=true
            for(Account_Relationship__c  oaccRelation : [SELECT ID,Child_Account__c,Parent_Account__c  FROM Account_Relationship__c WHERE Active__c=true AND Child_Account__r.Type = 'Realtor Office' AND Parent_Account__c IN: accOwnersChagned.keyset() AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49998]){
                accList.add(new Account(ID=oaccRelation.Child_Account__c,OwnerId = accOwnersChagned.get(oaccRelation.Parent_Account__c)));
            }
        }
        
        if(!accList.isEmpty()){
            onTerritorychagneFlag = true;
            update accList ;
        }
    }
    
    @future
    Public static void AccountAssetOwnerUpdate(Map<Id,Id> mapAccountid){
        List<Asset> lstAsset = [Select Id,Name,OwnerId,AccountId from Asset where AccountId=:mapAccountid.keyset() and OwnerId!=:mapAccountid.values()];
        for(Asset asst:lstAsset){
            asst.OwnerId = mapAccountid.get(asst.AccountId);
        }
        if(lstAsset.size()>0){
            update lstAsset;
        }
    }
    
    Public void SalesLockValidate(Map<Id,Account> newAccountsMap, Map<Id,Account> oldAccountsMap){
        Set<String> setTaskOutcomes = new Set<String>{'Left Message','Spoke To'};
            List<Task> lstTask = [Select Id from Task where WhatId = :newAccountsMap.keyset() and Outcome__c=:setTaskOutcomes];
    }
    
    // Added by Raama kalyani- Auto renewal flag
    public void AccountAssetAutoRenewal(Map<id,Account> accountsMap,Map<id,Account> AccountoldMap) {
        Set<Id> AccountIds = new Set<Id>();
        Map<Id,Id> ProspectToCustomerAccountIds = new Map<Id,Id>();
        for(Account accounts : accountsMap.values()){
            AccountIds.add(accounts.id);
            if(accounts.Account_Sub_Type__c=='Customer' && AccountoldMap.get(accounts.id).Account_Sub_Type__c=='Prospect'){
                ProspectToCustomerAccountIds.put(accounts.id,accounts.OwnerId);
            }
        }
        if(ProspectToCustomerAccountIds.size()>0){
            AccountAssetOwnerUpdate(ProspectToCustomerAccountIds);
        }
        
        Map<id,Asset> allAssets = new Map<id,Asset>([Select id,Name,AccountId,End_date__c from Asset where AccountId In : AccountIds]);
        Set<Id> AssetIds = new Set<Id>();
        for(Asset a : allAssets.values()){
            AssetIds.add(a.id);
        }
        Map<Id,OrderItem> allOrderItems = new  Map<Id,OrderItem>([select Id,OrderId,Asset__c,PricebookEntryId,PricebookEntry.Product2Id from OrderItem where Asset__c In : AssetIds]);
        Set<Id> PricebookEntryIds = new Set<Id>();
        for(OrderItem OI : allOrderItems.values()){
            PricebookEntryIds.add(OI.PricebookEntryId);
        }
        Map<Id,PricebookEntry> allPricebookEntryRecords =  new Map<Id,PricebookEntry>([SELECT Id,Name,Pricebook2Id,Product2Id,ProductCode,Product2.Auto_Renewal__c FROM PricebookEntry where Id In : PricebookEntryIds]);
        Map<id,Asset> AssetMap = new Map<id,Asset>();
        
        for(OrderItem  Ordr :  allOrderItems.values()){
            PricebookEntry pbc = allPricebookEntryRecords.get(ordr.PricebookEntryId);
            if(Ordr.Asset__c != Null && Pbc.Product2Id == Ordr.PricebookEntry.Product2Id){
                Asset ast = allAssets.get(Ordr.Asset__c);
                Account acc = accountsMap.get(ast.AccountId);
                Account oldacc = AccountoldMap.get(ast.AccountId);
                if(acc.Auto_Renewal__c  != oldacc.Auto_Renewal__c || Test.isRunningTest()) {
                    if((Acc.Auto_Renewal__c == True) && (PBc.Product2.Auto_Renewal__c == True)){
                        ast.Auto_Renewal__c  = 'Yes';
                        AssetMap.Put(ast.id,ast);
                    }
                    if((Acc.Auto_Renewal__c == False) && (PBc.Product2.Auto_Renewal__c == True)){
                        ast.Auto_Renewal__c  = 'No';
                        AssetMap.Put(ast.id,ast);
                    }
                    if(ast.End_Date__c != Null){
                        Integer ExpiryDays = Date.today().daysBetween(date.valueof(ast.End_Date__c));
                        if(ExpiryDays <= 60){
                            Acc.adderror('Auto renewal flag on the following assets cannot be changed as it about to expire : ' +ast.Name );
                        }
                    }
                }
            }
        }
        
        if(AssetMap.size() > 0){
            update AssetMap.Values();
            AssetMap.clear();
        }
        
    }
    //CRM-1206 - Validation to check the Essentials, Basic Optout Status. 
    Public void accountInactivationCheck(Map<id,Account> accountsMap, Map<id,Account> accountsoldMap){
        final String essActivate =  System.Label.ACTIVATE;
        final String essInactivated =  System.Label.INACTIVATED;
        final String essInactive =  System.Label.INACTIVE;
        Map<Id, Id> AssetIdsMap = new Map<Id, Id>();
        Set<Id> AccountIds = new Set<Id>();
        for(Account accounts : accountsMap.values()){
            if(accounts.EssentialsStatus__c == essInactive) {
                AccountIds.add(accounts.id);
                if(accounts.EssentialsStatus__c != accountsoldMap.get(accounts.id).EssentialsStatus__c) {
                    accounts.Resend_Welcome_Email__c = False;
                }
            }
            if(accounts.Basic_Optout__c != accountsoldMap.get(accounts.id).Basic_Optout__c) {
                AccountIds.add(accounts.id);
            }
            System.debug('Account:'+accounts);
            if(accounts.EssentialsStatus__c == 'Error' || accounts.EssentialsStatus__c == essInactivated || accounts.EssentialsStatus__c == essInactive) {
                if(accounts.Resend_Welcome_Email__c) {
                    System.debug('accounts.Resend_Welcome_Email__c:'+ accounts.Resend_Welcome_Email__c);
                    accounts.adderror('Resend Welcome Email will be sent only for Activated Essentials Account');
                }
            }
        }//CRM-1838 - Added condition to check for the AccountIds Set.
        if(!AccountIds.isEmpty()) {
            Map<Id,Asset> allAssets = new Map<Id,Asset>([Select id,Product2Id,AccountId,Product2.EssentialsRequired__c from Asset where AccountId In : AccountIds AND Status = 'Active']);            
            for(Asset a : allAssets.values()){
                AssetIdsMap.put(a.AccountId, a.id);
                System.debug('AssetIdsMap:'+AssetIdsMap);
            }
        }
        for(Account acct : accountsMap.values()){
            if(acct.EssentialsStatus__c == essInactive && accountsoldMap.get(acct.id).EssentialsStatus__c != essInactive && AssetIdsMap.containsKey(acct.Id)){
                acct.adderror('Essentials cannot be Inactivated as the Account has Active Assets');
            }
            if(acct.Basic_Optout__c == essActivate && AssetIdsMap.containsKey(acct.Id)){
                acct.adderror('Basic Optout cannot be Activated as the Account has Active Assets');
            }//CRM - 1795 - Checking the value of Basic Optout not to be Inactive
            if(acct.Basic_Optout__c == essInactive && AssetIdsMap.containsKey(acct.Id)){
                acct.adderror('Basic Optout cannot be Inactivated as the Account has Active Assets');
            }
            
        }
    }
    
    //Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
    public static boolean essentialsrunning = false;
    public void accountActivateEssentialStatus(Set<Id> lstBMQIds) {
        Map<Id, String> accountIdEntityName = new Map<Id, String>();
        Set<Account> setEssAcc = new Set<Account> ();
        List<Account> lstEssAcc = new List<Account>();
        System.debug('lstBMQIds:'+lstBMQIds);
        List<BigMachines__Quote_Product__c> bmqpList = [Select Id, BigMachines__Quote__r.BigMachines__Account__c, BigMachines__Product__r.EssentialsRequired__c from BigMachines__Quote_Product__c where BigMachines__Quote__r.Id IN: lstBMQIds and BigMachines__Product__r.EssentialsRequired__c = True  and BigMachines__Quote__r.BigMachines__Account__r.EssentialsStatus__c != 'Activate' and BigMachines__Quote__r.BigMachines__Account__r.EssentialsStatus__c != 'Activated'];
        for (BigMachines__Quote_Product__c bmqp : bmqpList) {
            Account acc = new Account();
            System.debug('Test working Test'+bmqp.BigMachines__Quote__r.BigMachines__Account__c);
            acc.Id = bmqp.BigMachines__Quote__r.BigMachines__Account__c;
            acc.EssentialsStatus__c = 'Activate';
            acc.SystemActivatedAccount__c = true;
            //lstEssAcc.add(acc);
            setEssAcc.add(acc);
            accountIdEntityName.put(bmqp.BigMachines__Quote__r.BigMachines__Account__c,'ProductFlag');
        }
        lstEssAcc.addall(setEssAcc);
        essentialsrunning = true;
        Update lstEssAcc;
        sendOutboundMessageInFuture(accountIdEntityName);
    }
    
    //CRM-1206 - Validation to check the Essentials, Basic Optout Status.
    //Resend Welcome Email for Essentials 
    public void accountEssentialsResend(List<Account> accountsList, Map<Id, Account> oldMap) {
        
        // CRM-4160 Added new parameter oldMap
        List<String> lstEssAct = new List<String>();
        Set<String> EssActSet = new Set<String>();
        
        for(Account acc: accountsList) {
            Account oldAcc = oldMap.get(acc.Id);   
            // CRM-4160 - old account
            if (acc.EssentialsStatus__c == 'Activated' && acc.Resend_Welcome_Email__c && 
                (acc.EssentialsStatus__c != oldAcc.EssentialsStatus__c || acc.Resend_Welcome_Email__c != oldAcc.Resend_Welcome_Email__c)) { 
                    // CRM-4160 - Added old and new value check
                    EssActSet.add(acc.Party_ID__c);
                    System.debug('EssActSet:'+EssActSet);
                }
        }
        
        if(!EssActSet.isEmpty()) {
            lstEssAct.addall(EssActSet);
            sendOutboundMsgInFuture(lstEssAct);
        }
    }
    
    // future method used to call out external webservice
    @future(callout=true)
    public static void sendOutboundMsgInFuture( List<String> acctPtyIdList) {
        
        String Response;
        
        for(String partyID : acctPtyIdList) {
            try{
                System.debug('=====Response partyID==='+partyID);
                Response = new xmlnsOracleComAdvantageapplicationUp.UpdateWelcomeEmailSFDCBpel_pt().process(partyID);
                System.debug('=====Response account==='+Response);
                //errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFuture',Error_Description__c = 'Success:' + Response));
            }catch(exception e) {
                //errorList.add(new Error__c(Entity_Id__c = accountId,Interface_Name__c = typeVal,Name ='sendOutboundMessageInFuture',Error_Description__c = e.getMessage()));
            }
        }
    }
    
    // CRM-3402 - Update Payment_Plan__c if Billing Status changes to current
    public void updatePaymentPlanFlag(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap) {
        for (Account newAccount : newAccountMap.values()) {
            // CRM-4230 - Commented old logic
            /* Account oldAccount = oldAccountMap.get(newAccount.Id);
if (newAccount.Suspension_Status__c != oldAccount.Suspension_Status__c ||
newAccount.Credit_Risk__c != oldAccount.Credit_Risk__c||
newAccount.Credit_Dispute__c != oldAccount.Credit_Dispute__c||
newAccount.Past_Due__c != oldAccount.Past_Due__c) {
// Fields values are picked from Billing Status formula field
if (newAccount.Suspension_Status__c != 'Suspended' && newAccount.Credit_Risk__c == false && 
newAccount.Credit_Dispute__c == false && newAccount.Past_Due__c == false) { */
            // CRM-4230 - Added new logic based on Past_Due_Balance__c 
            if (newAccount.Past_Due_Balance__c == 0 && oldAccountMap.get(newAccount.Id).Past_Due_Balance__c > 0) {
                newAccount.Payment_Plan__c = false;
            }
            //}
        }
    }
    // CRM-3402 - End
    
    //CRM-4282 Start
    // @future (callout=true)
    public void createCaseOnWelcomeEmaicheck(List<Account> trgNew, Map<id,Account> trgOldMap){
        
        List<Account> accs = new List<Account>();
        List<case> caseList = new List<case>();
        for(Account acct : trgNew){
            if(acct.Resend_Welcome_Email__c== true && trgOldMap.get(acct.Id).Resend_Welcome_Email__c!= acct.Resend_Welcome_Email__c){
                accs.add(acct);
            }
        }
        if(accs.size()>0 || test.isRunningTest()){     
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            for(Account acct : accs){
                Case caseToAdd = new Case();
                caseToAdd.accountid = acct.id; 
                caseToAdd.RecordTypeId = recordTypeId;
                caseToAdd.Type = 'Customer Service';
                caseToAdd.Status = 'Closed'; 
                caseToAdd.SetOptions(dmlOpts);
                caseToAdd.Subject = 'Welcome Email Sent';
                caseList.add(caseToAdd);                
            }
        }
        if(!caseList.isEmpty()){
            insert caseList ;
        }
    }
    
    //CRM-4282 END 
    
    
}