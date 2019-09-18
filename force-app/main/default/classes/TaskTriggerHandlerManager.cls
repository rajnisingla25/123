//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Manager: TaskTriggerHandlerManager
// For Trigger Handler: TaskTriggerHandler
// For Trigger: TaskTrigger
// On SObject: Task
// Description: If sales rep working on an account of sub type 'Prospect' and create activity on that (Type = message or call) then populate
// Sales lock user field with the sales rep and pouplate Lock Expiration Date with the 10 days threshold. If while creating activities Sales
// lock user already populated then dont populate again.
//
// 20th March 2015    Hemendra Singh Bhati   Original (Task # T-372157)
// 09th April 2015    Hemendra Singh Bhati   Modified (Task # T-376903) - Replace Record Type 'Prospect' Checks With Account Sub Type 'Prospect'.
// 08th May 2015      Hemendra Singh Bhati   Modified (Task # T-393511) - Updated Method: setTaskAccountSalesLockUserAndLockExpirationDate().
// 06 May 2016        Krishna Veni Bodala -  Modified to populate survey email field #LEAP-744
// 21 OCT 2016        Srinivas Pendli - Modified to add outcome values for #CRM-477
public without sharing class TaskTriggerHandlerManager {
    //  private final Integer LOCK_EXPIRATION_DATE_THRESHOLD = 10;
    private final String ACCOUNT_SUB_TYPE_FOR_SALESLOCK = 'Prospect';

    /*
    @method      : setTaskAccountSalesLockUserAndLockExpirationDate
    @description : Populates sales lock user and lock expiration date custom fields on account object. This method also
                           : updates account last sales contact date with most recently created account activity created date.
    @params      : List<Task> newValues
    @returns     : void
    */
    public void setTaskAccountSalesLockUserAndLockExpirationDate(List < Task > newValues) {
        Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;

        // Processing new values.
        // Extract Related Account Ids.
        Set < Id > relatedAccountIds = new Set < Id > ();
        Map < Id, Datetime > theAccountIdAndTaskCreatedDateMapping = new Map < Id, Datetime > ();
        Id TskAssigned;
        for (Task theTask: newValues) {
            if (theTask.WhatId != null && theTask.WhatId.getSObjectType().getDescribe().getName() == 'Account' && theTask.CreatedDate !=null) {
                if (theTask.RecordTypeId == salesActivitiesRecordTypeId) {
                    //CRM-2871: Replaced Date.newInstance to task Created Date
                    theAccountIdAndTaskCreatedDateMapping.put(
                        theTask.WhatId,theTask.CreatedDate
                        //Date.newInstance(theTask.CreatedDate.year(), theTask.CreatedDate.month(), theTask.CreatedDate.day())                       
                    );
                }
                if (String.isNotBlank(theTask.Type) && (theTask.Type.equalsIgnoreCase('Message') || theTask.Type.equalsIgnoreCase('Call') || theTask.Type.equalsIgnoreCase('Call - Outbound'))) {
                  //  relatedAccountIds.add(theTask.WhatId);
                }
                //Code commented by Srinivas Pendli for #CRM-477 on 21.10.2016
                //if (String.isNotBlank(theTask.Outcome__c) && (theTask.Outcome__c.equalsIgnoreCase('Left Message') || theTask.Outcome__c.equalsIgnoreCase('Spoke To')))
                /*
                if(String.isNotBlank(theTask.Outcome__c) && (theTask.Outcome__c.equalsIgnoreCase('Left Message') || theTask.Outcome__c.equalsIgnoreCase('Spoke To')
                || theTask.Outcome__c.equalsIgnoreCase('LM 1st Attempt') || theTask.Outcome__c.equalsIgnoreCase('LM 2nd Attempt') || theTask.Outcome__c.equalsIgnoreCase('LM 3rd Attempt')
                || theTask.Outcome__c.equalsIgnoreCase('Spoke To / Emailed Info'))) {
                    relatedAccountIds.add(theTask.WhatId);
                }*/
                // Modified as part of CRM-713
                System.debug(theTask.Outcome__c+'kKKKK');
                if((theTask.Outcome__c+'').length()<90 && theTask.Outcome__c!='Follow up Scheduled - Pitched (post-demo Follow up)'){
                if(String.isNotBlank(theTask.Outcome__c) && Activity_Outcome__c.getInstance(theTask.Outcome__c) != null) {
                    relatedAccountIds.add(theTask.WhatId);
                }
                }
                TskAssigned = theTask.OwnerId;

            }
        }       
        User user = [select id, Name,profile.Name,Username,Sales_Lock_User__c from User where ID =: UserInfo.getUserId()];
        if(user.Sales_Lock_User__c==false){
            for (Task theTask: newValues) {               
                if ((theTask.RecordTypeId == salesActivitiesRecordTypeId) && String.isNotBlank(theTask.Outcome__c) && (theTask.Outcome__c.equalsIgnoreCase('Left Message') || theTask.Outcome__c.equalsIgnoreCase('Spoke To'))) {
                //theTask.addError('User is not a valid Sales rep');
                    
                }
            }
        }
        string profilename = user.profile.Name;
        String usrName = user.Username;
        // Fetching Prospect Account Records To Update.
        Set<String> setAccountSubType = new Set<String>();
        setAccountSubType.add(ACCOUNT_SUB_TYPE_FOR_SALESLOCK);
        setAccountSubType.add('Former Customer');
        Set<String> profileList = new Set<String>();
        profileList.add('Move Agent Sales Rep');
        profileList.add('Move Broker Sales Rep');
        profileList.add('Move Sales Manager');
        profileList.add('Move Field Sales Rep');
        profileList.add('Move Event Sales Rep'); // CRM-4611
        profileList.add('Move Finance Manager');
        //profileList.add('Open Book Profile');
        profileList.add('Move Agent Sales Manager');
        profileList.add('Move Read Only');
        Map < Id, Account > theAccountsToUpdate = new Map < Id, Account > ();
        
         // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!relatedAccountIds.isEmpty()) {
            for (Account theAccount: [SELECT Id, Sales_Lock_User__c,Sales_Lock_User__r.isActive,Sales_lock_Date__c, Lock_Expiration_Date__c FROM Account WHERE Id IN: relatedAccountIds AND
                     (owner.Profile.Name!=:profileList AND owner.Title!='Regional Director')
                ]) {
                if (theAccount.Sales_Lock_User__c == null ||(theAccount.Sales_Lock_User__c!=null && theAccount.Sales_Lock_User__r.isActive==false)) {
                   if(user.Sales_Lock_User__c==true){
                       //CRM-1939: When NVM User creates Task, Update the Sales Lock to AssignedTo.
                       if(usrName.contains('nvmapiuser@move.com') || usrName.contains('isadmin@move.com'))
                           theAccount.Sales_Lock_User__c = TskAssigned;
                       else
                           theAccount.Sales_Lock_User__c = UserInfo.getUserId();
                       Constants cons = new Constants();
                       theAccount.Lock_Expiration_Date__c = Date.today() + cons.LOCK_EXPIRATION_DATE_THRESHOLD;
                     // theAccount.Sales_lock_Date__c = DateTime.Now() + cons.LOCK_EXPIRATION_DATE_THRESHOLD;
                     // CRM-2008 Venu Ravilla-Did changes to update sales lock expiration to 2 hours
                       theAccount.Sales_lock_Date__c = DateTime.Now().addHours(cons.LOCK_EXPIRATION_DATE_THRESHOLD);

                       theAccount.Is_Update_By_Trigger__c = true;
                       if (!profilename.contains('Service')) {
                           //CRM-1939: When NVM User creates Task, Update Account Sales Lock.
                           if (usrName.contains('nvmapiuser@move.com') || !profilename.contains('Admin'))
                               theAccountsToUpdate.put(theAccount.Id, theAccount);
                       }
                       System.debug('theAccountsToUpdate:'+theAccountsToUpdate);
                    }
                }
            }
        }
        if (theAccountIdAndTaskCreatedDateMapping.size() > 0) {
            Account theAccount = null;
            for (Id theAccountId: theAccountIdAndTaskCreatedDateMapping.keySet()) {
                if (theAccountsToUpdate.containsKey(theAccountId)) {
                    theAccount = theAccountsToUpdate.get(theAccountId);
                    theAccount.Last_Sales_Contact_Date__c = theAccountIdAndTaskCreatedDateMapping.get(theAccountId);
                } else {
                    theAccount = new Account(
                        Id = theAccountId,
                        Is_Update_By_Trigger__c = true,
                        Last_Sales_Contact_Date__c = theAccountIdAndTaskCreatedDateMapping.get(theAccountId)
                    );
                    theAccountsToUpdate.put(theAccount.Id, theAccount);
                }
            }
        }

        if (theAccountsToUpdate.size() > 0) {
            update theAccountsToUpdate.values();
        }
    }

    /*
      @method      : UpdateTaskBasedonAccount
      @description : Update Task field when Related to is Account Contact_ID__c,Contact_Email__c
                     Parent_Account_Type__c,Parent_Account_Name__c,Account_ID__c
      @params      : List<Task> newValues,List<Task> oldValues
      @returns     : void
      @owner:        Ravinder Rallagudam
      */
    public void UpdateTaskBasedonAccount(list < Task > newValues) {
        set < ID > accIds = new set < ID > ();
        set < ID > caseIds = new set < ID > ();
        map < ID, Account > accMap = new map < ID, Account > ();
        map < ID, Task > taskMap = new map < ID, Task > ();
        map < ID, ID > caseIDMap = new map < ID, ID > ();
        Set < Id > whoContactIds = new Set < Id > ();
        Set < Id > whoLeadIds = new Set < Id > ();
        // map<ID,>

        for (Task otask: newValues) {
            if (otask.WhatID != null) {
                if (Schema.Account.SObjectType == otask.WhatID.getSobjectType()) {
                    accIds.add(otask.whatId);
                }
                if (Schema.Case.SObjectType == otask.WhatID.getSobjectType()) {
                    caseIds.add(otask.whatId);
                }
                taskMap.put(otask.Id, otask);
            }
            if ((otask.whoId + '').contains('003')) {
                whoContactIds.add(otask.whoId);
            }
            if ((otask.whoId + '').contains('00Q')) {
                whoLeadIds.add(otask.whoId);
            }
            System.debug('otask:'+otask);
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        Map < id, Lead > mapLeads = new Map < id, Lead >();
        if (!whoLeadIds.isEmpty()) {
            mapLeads = new Map < id, Lead > ([Select id, email, phone from Lead where id =: whoLeadIds]);
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        Map < id, Contact > mapContacts = new Map < id, Contact >();
        if (!whoContactIds.isEmpty()) {
            mapContacts = new Map < id, Contact > ([Select id, email, phone from Contact where id =: whoContactIds]);
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        map < id, Case > caseMap = new map < id, Case >();
        if (!caseIds.isEmpty()) {
            caseMap = new map < id, Case > ([SELECT ID, AccountID, IsClosed, Contact.Email, Type FROM Case
                                                            WHERE ID IN: caseIds AND AccountID != null]);
        }

        system.debug('***caseIDS***' + caseIDS);
        if (!caseIds.isEmpty()) {
            for (Case ocase: caseMap.values()) {
                accIds.add(ocase.AccountID);
                caseIDMap.put(ocase.Id, ocase.AccountID);

            }
        }
        system.debug('***accIDS***' + accIDS);
        map < ID, Account_Relationship__c > BillingContacts = new map < id, Account_Relationship__c > ();
        map < ID, Account_Relationship__c > PrimaryContacts = new map < id, Account_Relationship__c > ();

        accMap = new map < ID, Account > ([SELECT ID, Name, Type, Primary_Email__c,Email_Address__c, Last_Survey_Send_Date__c FROM Account WHERE
                                                                                                        ID IN: accIds]);
        list < Account_Relationship__c > accRelations = [SELECT Contact_To__c,
            Contact_To__r.Email, Contact_To__r.Phone,
            Contact_To__r.Last_Survey_Send_Date__c,
            Parent_Account__c,
            Contact_Role__c,
            Billing_Contact__c,
            email_address__c
            FROM Account_Relationship__c
            WHERE Parent_Account__c IN: accIds
            AND RecordType.DeveloperName = 'Contact_Relationship'
            AND Active__c = true
            AND(Contact_Role__c = 'Primary Contact'
                OR Billing_Contact__c = true)
            order by Name asc limit 49996
        ];
        for (Account_Relationship__c ar: accRelations) {
            if (ar.Billing_Contact__c) {
                BillingContacts.put(ar.Parent_Account__c, ar);
            }
            if (ar.Contact_Role__c == 'Primary Contact') {
                PrimaryContacts.put(ar.Parent_Account__c, ar);
            }

        }
        Set < String > setEmailAddress = new Set < String > ();
        Map < String, Contact > mapContactString = new Map < String, Contact > ();
        for (Task otask: newValues) {
            if (otask.Account_Primary_Email__c != null) {
                setEmailAddress.add(otask.Account_Primary_Email__c);
            }
        }
        for (Contact Contactdata: [select email, Last_Survey_Send_Date__c from Contact where email =: setEmailAddress]) {
            mapContactString.put(Contactdata.email, Contactdata);
        }

        list<Account> toBeUpdatedAccounts = new list<Account>();
        for (Task otask: newValues) {
            if ((otask.whoId + '').contains('003')) {
                otask.Email__c = mapContacts.get(otask.whoId).Email;
                otask.Phone__c = mapContacts.get(otask.whoId).Phone;
            }
            if ((otask.whoId + '').contains('00Q') && mapLeads.get(otask.whoId) != null) {
                otask.Email__c = mapLeads.get(otask.whoId).Email;
                otask.Phone__c = mapLeads.get(otask.whoId).Phone;
            }

            if (otask.WhatID != null) {
                if (Schema.Account.SObjectType == otask.WhatID.getSobjectType() || Schema.Case.SObjectType == otask.WhatID.getSobjectType()) {
                    string whatid = '';
                    if (Schema.Account.SObjectType == otask.WhatID.getSobjectType())
                        whatid = otask.whatid;
                    if (Schema.Case.SObjectType == otask.WhatID.getSobjectType())
                        whatid = caseIDMap.get(otask.whatId);

                    otask.Account_ID__c = whatid;
                    otask.Parent_Account_Name__c = accMap.get(whatid) == null ? null : accMap.get(whatid).Name;
                    otask.Parent_Account_Type__c = accMap.get(whatid) == null ? null : accMap.get(whatid).Type;
                    otask.Account_Primary_Email__c = accMap.get(whatid) == null ? null : accMap.get(whatid).Email_Address__c;
                    system.debug('prim email:' + otask.Account_Primary_Email__c);
                    if (otask.Account_Primary_Email__c != null) {
                        try {
                            Contact Contactdata = mapContactString.get(otask.Account_Primary_Email__c);
                            system.debug('Contactdata:' + Contactdata);
                            IF(Contactdata != null && Contactdata.Last_Survey_Send_Date__c != null) {
                                system.debug('diff:' + system.date.today().daysBetween(Contactdata.Last_Survey_Send_Date__c));
                                if (Contactdata.Last_Survey_Send_Date__c.daysBetween(system.date.today()) > 7) {
                                    otask.Can_Send_Survey__c = true;
                                    Contactdata.Last_Survey_Send_Date__c = system.today();
                                    update Contactdata;
                                }
                            } else IF(Contactdata != null) {
                                otask.Can_Send_Survey__c = true;
                                Contactdata.Last_Survey_Send_Date__c = system.today();
                                update Contactdata;
                            }
                        } catch (exception e) {
                            //no action as for general task can be created on account with contact record for account primary email
                        }
                    }
                    System.debug('PPPPPPP');
                    /* if(BillingContacts.containsKey(whatid)){
                        otask.Contact_ID__c    =  BillingContacts.get(whatid)== null ? null :BillingContacts.get(whatid).Contact_To__c;
                        otask.Contact_Email__c =  BillingContacts.get(whatid) == null ? null :BillingContacts.get(whatid).Contact_To__r.Email;
                     }
                     else */
                    if (PrimaryContacts.containsKey(whatid)) {
                        System.debug('PPPPPPP');

                        //if (otask.whoid != null) {
                            otask.WhoId = PrimaryContacts.get(whatid).Contact_To__c;
                            otask.Contact_ID__c = otask.WhoId;
                        //}
                        otask.Phone__c = PrimaryContacts.get(whatid) == null ? null : PrimaryContacts.get(whatid).Contact_To__r.Phone;
                        otask.Email__c = PrimaryContacts.get(whatid) == null ? null : PrimaryContacts.get(whatid).Contact_To__r.Email;
                    } else {
                        System.debug('PPPPPPP');
                        otask.Phone__c = '';
                        otask.Email__c = '';
                    }

                    /* Krishna Veni Bodala - LEAP-744 - Populate survey email logic.
                        1 - If related to is a case, get it from contact primary email on the case. Also get if the case is closed
                        2 - If related to is an Account, get it from account primary email
                        3 - Else get it from whoId of the contact
                    */
                    if (Schema.Case.SObjectType == otask.WhatID.getSobjectType()) {
                        if(caseMap.containskey(otask.WhatId)){
                        otask.Survey_Email__c = caseMap.get(otask.WhatId).Contact.Email;
                        otask.Is_Case_Closed__c = caseMap.get(otask.WhatId).IsClosed;
                        otask.Case_Type__c = caseMap.get(otask.WhatId).Type;
                        }
                    } else if (Schema.Account.SObjectType == otask.WhatID.getSobjectType()) {
                        otask.Survey_Email__c = accMap.get(otask.WhatId).Email_Address__c;
                  //      if( accMap.get(otask.WhatId).Last_Survey_Send_Date__c != null &&
                  //          accMap.get(otask.WhatId).Last_Survey_Send_Date__c.daysBetween(system.date.today()) > 7){
                  //          toBeUpdatedAccounts.add(new Account(Id=accMap.get(otask.WhatId).Id, Last_Survey_Send_Date__c=Date.today()));
                  //      }
                    } else if (Schema.Contact.SObjectType == otask.WhoId.getSobjectType()) {
                        otask.Survey_Email__c = mapContacts.get(otask.WhoId).Email;
                    }


                }
            }
        }
        //update toBeUpdatedAccounts;
    }
}