//
// (c) 2015 Appirio, Inc.
//
// Class Name: AccountTriggerHandler
// Description: Handler Class for AccountTrigger
//
// 7th April 2015    Ravinder   Original (Task # T-376543)
// 11th May 2015     Sonu Sharma Modified
// 08th June 2016    Leap# 7995 Krishnaveni Bodala Added Method-onBeforeUpdate() to check the Pre-auth flag
// 24th May  2017    CRM-1166           Varun Kavoori         Added Method     afterupdate   SuspensionResumeStatusUpdate
//

public class AccountTriggerHandler {
    
    private integer batchSize = 0;
    private boolean isExecuting = false;
    private AccountTriggerHandlerManager accountTriggerManager = null;
    
    public AccountTriggerHandler(Boolean isExecuting, Integer size) {
        batchSize = size;
        isExecuting = isExecuting;
        accountTriggerManager = new AccountTriggerHandlerManager();
    }
    
    // After Insert Method of Trigger
    public void onAfterInsert(Map<Id,Account> accountsMap) {
        // Do not allow the trigger to call webservice if 'Set CDH Webservice Callout Off' Field is off from Custom Setting
        if(Switch_AccountTrigger__c.getInstance().Set_CDH_Webservice_Callout_Off__c == false) {
            accountTriggerManager.webserviceCallout(accountsMap.values(), null);
        }
        // Do Not allow the Populating of the Assocated Fields if 'Set_Associate_Agent_Broker_Populate_Off__c' is Off
        if(Switch_AccountTrigger__c.getInstance().Set_Associate_Agent_Broker_Populate_Off__c == false) {
            accountTriggerManager.populateAssociatedFields(accountsMap,null);  
        } 
        accountTriggerManager.createCaseOnWelcomeEmaicheck(accountsMap.values(), null); //CRM-4282
        
    }
    
    // After Update Method of Trigger
    public void onAfterUpdate(Map<Id,Account> accountsMap, Map<Id,Account> oldAccountMap) {
        map<id,String> AcctidEmail = New map<id,String>();
        // Do not allow the trigger to call webservice if 'Set CDH Webservice Callout Off' Field is off from Custom Setting
        if(Switch_AccountTrigger__c.getInstance().Set_CDH_Webservice_Callout_Off__c == false && AccountTriggerHandlerManager.essentialsrunning == false) {
            accountTriggerManager.webserviceCallout(accountsMap.values(), oldAccountMap);
        }
        // Do Not allow the Populating of the Assocated Fields if 'Set_Associate_Agent_Broker_Populate_Off__c' is Off
        if(Switch_AccountTrigger__c.getInstance().Set_Associate_Agent_Broker_Populate_Off__c == false) {
            accountTriggerManager.populateAssociatedFields(accountsMap,oldAccountMap);
        }
        //CRM-5555-Start
        if(Switch_AccountTrigger__c.getInstance().Brokeraccountblacoreflag__c == false) { 
            accountTriggerManager.Brokeraccountblacoreflag(accountsMap.values(),oldAccountMap);
        }
        //CRM-5555-End
        if(!AccountTriggerHandlerManager.onTerritorychagneFlag)
            accountTriggerManager.onAccountTerritorychange(accountsMap,oldAccountMap);
        
        Set<String> setAccId = new Set<String>();
        //when account primary contact email is changed
        //Replaced 'Primary_Email__c' with 'Email_Address__c' as part of Jira SMCI-554
        For(Account Acctloop : accountsMap.values()){
            AcctidEmail.put(Acctloop.Id,Acctloop.Email_Address__c);
            
            //Added by Pratik on 16th Oct 2018 for CRM-4963
            if(Acctloop.Payment_Plan__c != oldAccountMap.get(Acctloop.Id).Payment_Plan__c
               && Acctloop.Payment_Plan__c)
            {
                setAccId.add(Acctloop.Id);
            }
            //Ends here
        }
        If(AcctidEmail.size() > 0){
            //AssetEmailUpdateOnAccountEmailChange.UpdateAssetEmail(AcctidEmail);
        }
        accountTriggerManager.createCaseOnWelcomeEmaicheck(accountsMap.values(), oldAccountMap); //CRM-4282
        
        //Added by Pratik on 16th Oct 2018 for CRM-4963
        if(!setAccId.isEmpty())
        {   
            Set<String> setStatus = new Set<String>();
            setStatus.add('New');
            setStatus.add('In Progress');
            setStatus.add('Pending Cancel');
            List<Case> lstCase = [Select Status From Case Where AccountId IN:setAccId and status=:setStatus and RecordType.Name='Collections'];
            
            for(Case objCase :lstCase)
                objCase.Status = 'Payment Plan';
            
            if(!lstCase.isEmpty())
                update lstCase;
        }
        //Ends here        
    }
    
    
  /*  Public Static void InsertUpdatePhone(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        List<Phone__c> lstPhone = new List<Phone__c>();
        if(oldAccountMap==null){
            for(Account  acc:newAccountMap.values()){
                if(acc.Account_Phone_Formatted__c!=null || Test.isRunningTest()){
                    Phone__c phne = new Phone__c();
                    phne.Name = acc.Account_Phone_Formatted__c;
                    phne.Phone_Type__c = 'Phone';
                    phne.Account__c = acc.Id;
                    lstPhone.add(phne);
                }
                if(acc.Account_HomePhone_Formatted__c!=null || Test.isRunningTest()){
                    Phone__c Homephne = new Phone__c();
                    Homephne.Name = acc.Account_Phone_Formatted__c;
                    Homephne.Phone_Type__c = 'HomePhone';
                    Homephne.Account__c = acc.Id;
                    lstPhone.add(Homephne);
                }
                if(acc.Account_Mobile1_Formatted__c!=null || Test.isRunningTest()){
                    Phone__c Mobile1phne = new Phone__c();
                    Mobile1phne.Name = acc.Account_Phone_Formatted__c;
                    Mobile1phne.Phone_Type__c = 'Mobile1';
                    Mobile1phne.Account__c = acc.Id;
                    lstPhone.add(Mobile1phne);
                }
                if(acc.Account_Mobile2_Formatted__c!=null || Test.isRunningTest()){
                    Phone__c Mobile2phne = new Phone__c();
                    Mobile2phne.Name = acc.Account_Phone_Formatted__c;
                    Mobile2phne.Phone_Type__c = 'Mobile2';
                    Mobile2phne.Account__c = acc.Id;
                    lstPhone.add(Mobile2phne);
                }
                if(acc.Account_Work_Formatted__c!=null || Test.isRunningTest()){
                    Phone__c Workphne = new Phone__c();
                    Workphne.Name = acc.Account_Phone_Formatted__c;
                    Workphne.Phone_Type__c = 'Work';
                    Workphne.Account__c = acc.Id;
                    lstPhone.add(Workphne);
                }
            }
        } else {
            Map<String,phone__c> mapPhoneNumbers = new Map<String,phone__c>();
            
            for(Phone__c phonne:[Select Id,Name,Phone_Type__c,Account__c from Phone__c where Account__c=:newAccountMap.keyset()]){
                if(phonne.Phone_Type__c==null){phonne.Phone_Type__c='';}
                mapPhoneNumbers.put(phonne.Phone_Type__c+'$$'+phonne.Account__c,phonne);
            }
            for(Account  acc:newAccountMap.values()){
                if(acc.Account_Phone_Formatted__c!=oldAccountMap.get(acc.id).Account_Phone_Formatted__c || Test.isRunningTest()){
                    Phone__c phne = new Phone__c();
                    if(mapPhoneNumbers.containskey('Phone$$'+acc.Id)){
                        phne = mapPhoneNumbers.get('Phone$$'+acc.Id);
                    } else {
                        phne.Account__c = acc.Id;
                    }
                    phne.Name = acc.Account_Phone_Formatted__c;
                    phne.Phone_Type__c = 'Phone';
                    
                    lstPhone.add(phne);
                }
                if(acc.Account_HomePhone_Formatted__c!=oldAccountMap.get(acc.id).Account_HomePhone_Formatted__c || Test.isRunningTest()){
                    //  if(acc.Account_HomePhone_Formatted__c!=null){
                    Phone__c Homephne = new Phone__c();
                    if(mapPhoneNumbers.containskey('HomePhone$$'+acc.Id)){
                        Homephne = mapPhoneNumbers.get('HomePhone$$'+acc.Id);
                    } else {
                        Homephne.Account__c = acc.Id;
                    }
                    Homephne.Name = acc.Account_HomePhone_Formatted__c;
                    Homephne.Phone_Type__c = 'HomePhone';
                    
                    lstPhone.add(Homephne);
                    //  }
                }
                if(acc.Account_Mobile1_Formatted__c!=oldAccountMap.get(acc.id).Account_Mobile1_Formatted__c || Test.isRunningTest()){
                    //  if(acc.Account_Mobile1_Formatted__c!=null){
                    Phone__c Mobile1phne = new Phone__c();
                    if(mapPhoneNumbers.containskey('Mobile1$$'+acc.Id)){
                        Mobile1phne = mapPhoneNumbers.get('Mobile1$$'+acc.Id);
                    } else {
                        Mobile1phne.Account__c = acc.Id;
                    }
                    Mobile1phne.Name = acc.Account_Mobile1_Formatted__c;
                    Mobile1phne.Phone_Type__c = 'Mobile1';
                    
                    lstPhone.add(Mobile1phne);
                    // }
                }
                if(acc.Account_Mobile2_Formatted__c!=oldAccountMap.get(acc.id).Account_Mobile2_Formatted__c || Test.isRunningTest()){
                    //  if(acc.Account_Mobile2_Formatted__c!=null){
                    Phone__c Mobile2phne = new Phone__c();
                    if(mapPhoneNumbers.containskey('Mobile2$$'+acc.Id)){
                        Mobile2phne = mapPhoneNumbers.get('Mobile2$$'+acc.Id);
                    } else {
                        Mobile2phne.Account__c = acc.Id;
                    }
                    Mobile2phne.Name = acc.Account_Mobile2_Formatted__c;
                    Mobile2phne.Phone_Type__c = 'Mobile2';
                    
                    lstPhone.add(Mobile2phne);
                    // }
                }
                if(acc.Account_Work_Formatted__c!=oldAccountMap.get(acc.id).Account_Work_Formatted__c || Test.isRunningTest()){
                    //if(acc.Account_Work_Formatted__c!=null){
                    Phone__c Workphne = new Phone__c();
                    if(mapPhoneNumbers.containskey('Work$$'+acc.Id)){
                        Workphne = mapPhoneNumbers.get('Work$$'+acc.Id);
                    } else {
                        Workphne.Account__c = acc.Id;
                    }
                    Workphne.Name = acc.Account_Work_Formatted__c;
                    Workphne.Phone_Type__c = 'Work';
                    
                    lstPhone.add(Workphne);
                    // }
                }
            }
        }
        upsert lstPhone;
    } */
    
    public void onBeforeUpdate(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){         
        populateFields(newAccountMap.values(), oldAccountMap);
        accountTriggerManager.accountInactivationCheck(newAccountMap, oldAccountMap);
        accountTriggerManager.accountEssentialsResend(newAccountMap.values(), oldAccountMap); // CRM-4160 Added new parameter oldMap
        
        // CRM-3402 - Update Payment_Plan__c if Billing Status changes to current
        accountTriggerManager.updatePaymentPlanFlag(newAccountMap, oldAccountMap);
        
    }
    
    
    //Inventory Account Owner Sync    
    public void AccountOwnerSync(Map<Id,Account> newaccountmap,Map<Id,Account> oldaccount){
        Integer party_id;
        string owner_name;
        string updated_by;
        string account_sub_type;
        string Phone;
        string alias;
        Set<id> userIds = new Set<id>();
        /*List<Account> newaccount = New List<Account>();

//Check whether account has waitlist
List<Waitlist__c> Waitlistdata = [select id,Account__c from Waitlist__c Where Account__c in : newaccountmap.keySet()];
for(Waitlist__c Wlloop : Waitlistdata){
If(newaccountmap.containsKey(Wlloop.Account__c)){
newaccount.add(newaccountmap.get(Wlloop.Account__c));
}
}

If(newaccount.size() > 0 && !newaccount.isEmpty()){*/
        for(Account Acctloop : newaccountmap.values()){
            userIds.add(Acctloop.OwnerId);
        }
        userIds.add(Userinfo.getUserId());
        // Retrieve user alias  
        Map<ID,User> UserData = new Map<ID,User>([SELECT Id, alias,NT_Login_ID__c FROM User WHERE Id IN:userIds]);
        
        //Retrieving primary contact details
        List<Account_Relationship__c> primarycntct;
        Map<id,Contact> ContactMap = New Map<id,Contact>();
        try{ 
            primarycntct = [select Parent_Account__c,Contact_To__r.Id,Contact_To__r.Phone from Account_Relationship__c where 
                            Contact_Role__c = 'Primary Contact' and Parent_Account__c In :newaccountmap.keySet() and Active__c = true];
            for(Account_Relationship__c rltnloop : primarycntct){
                ContactMap.put(rltnloop.Parent_Account__c,rltnloop.Contact_To__r);
            }
        }catch(queryexception e){
            // No action
        }
        
        for(Account Acctloop : newaccountmap.values()){
            
            if(Acctloop.OwnerId != oldaccount.get(Acctloop.id).OwnerId && (Acctloop.Type == 'Realtor Agent' || Acctloop.Type == 'Broker') ){
                party_id = Integer.valueof(Acctloop.party_id__c);
                owner_name = UserData.get(Acctloop.OwnerId).NT_Login_ID__c;
                updated_by = UserData.get(Userinfo.getUserId()).NT_Login_ID__c;
                account_sub_type = Acctloop.account_sub_type__c;
                try{
                    if(ContactMap.containskey(Acctloop.Id)){
                        Phone = ContactMap.get(Acctloop.Id).Phone;
                    } 
                }catch(exception e){
                    //No action   
                } 
                
                RESTOwnerSyncWithInventory.RESTAccountOwnerSync(party_id,owner_name,updated_by,account_sub_type,Phone,Acctloop.Id); 
                
            }
        }
        
        //}
    }
    
    public void populateFields(List<Account> newAccList, Map<Id,Account> oldAccountMap){
        //Set<Id> parentBrokerIds = new set<Id>();
        for(Account acc : newAccList){         
            //parentBrokerIds.add(acc.id);
            if(acc.Active_Waitlist_Count__c > 0){
                acc.Pre_Authorized__c = true;
            }
            else{
                acc.Pre_Authorized__c = false;
            }
            //SMCI- ACP functionality to clear data when Email/Phone are blank
            if(acc.Email_Address__c == null){
                acc.Type_Purpose__c = null;
                acc.PrimaryEmail_CMId__c = null;
            }
            if(acc.Phone == null){
                acc.Preferred_Phone__c = null;
                acc.PrimaryPhone_CMId__c = null;
            }
            if(acc.SMS_Phone__c == null){
                acc.PrimarySMS_CMId__c = null;
            }
        } 
        /*
Map<id , Account_Relationship__c> accountRepMap = new Map<id , Account_Relationship__c>([select id,Child_Account__c,Child_Account__r.Type,Child_Account__r.OwnerId,
Parent_Account__c,Parent_Account__r.OwnerId from Account_Relationship__c where Child_Account__c In: parentBrokerIds]);
if(accountRepMap.size() > 0){
for(Account_Relationship__c AR : accountRepMap.values()){
for(account acc : newAccList){ 
if(AR.Child_Account__c == acc.id)
if(AR.Child_Account__r.Type == 'Realtor Office' && (AR.Child_Account__r.OwnerId != AR.Parent_Account__r.OwnerId)){
system.debug('AR.Child_Account__c :'+AR.Child_Account__c);     
acc.addError('Office Account owner can not be changed when parent Broker Exists');
} 
}              
}
}*/
    }
    public void CollectioncaseReAssignment(Map<Id,Account> accountsMap, Map<Id,Account> oldAccountMap){
        set<Id> accountids = new set<Id>();
        List<Id> acctids = new List<Id>();
        List<case> UpdateCaselist = new List<case> ();
        Map<Id,Id> accountTeamMap = new Map<Id,Id>();
        List<case> Caselist = new List<case> ();
        for(Account acctloop : accountsMap.values()){
            Account oldvalues = oldAccountMap.get(acctloop.Id);
            if(acctloop.Total_Contract_Value__c != oldvalues.Total_Contract_Value__c){
                accountids.add(acctloop.id);
                acctids.add(acctloop.id);
            }
        }
        
        if(!accountids.isEmpty())  
            accountTeamMap = Z_InvoicecollectionSchedulable.fetchAccountTeamMembers(acctids);
        System.debug('The Teammember Map coming here is' +accountTeamMap);
            Caselist = [Select id,AccountId ,OwnerId,Followup_Status__c from case where AccountId IN:accountids AND RecordType.Name = 'Collections' AND Status != 'Closed' AND (Account.Billing_Preference__c = 'CC-Direct' OR Account.Billing_Preference__c = 'Invoice-CC')];    
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        for(Account accloop : accountsMap.values()){
            for(case cs : Caselist){
               /* if(accloop.Total_Contract_Value__c >= Collection_Users__c.getInstance(System.Label.Collection_User1).Limit__c && cs.ownerId != Collection_Users__c.getInstance(System.Label.Collection_User1).Id__c){                    
                    //cs.ownerId = [select id from user where name = 'conteras pamela'].Id;
                    cs.ownerId = Collection_Users__c.getInstance(System.Label.Collection_User1).Id__c;                        
                    cs.Followup_Status__c = '';
                    UpdateCaselist.add(cs);
                }*/
                
                if(accloop.Total_Contract_Value__c > integer.valueOf(label.collectioncase_amount) && accloop.Total_Contract_Value__c < integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(accloop.Billing_Preference__c)){
                    cs.ownerid                         = label.userct1; //Eric
                }
               else if(accloop.Total_Contract_Value__c > integer.valueOf(label.collection_amount2) && label.Billingpreference.contains(accloop.Billing_Preference__c)){
                    cs.ownerid                         = label.userct2; //Pam
               }
                else if(accountTeamMap.containsKey(accloop.Id)){ 
                    cs.ownerid                         = accountTeamMap.get(accloop.Id);
               }
                else {
                    System.debug('Case Coming Here '+cs);
                    cs.setOptions(dmlOpts);
                }
                UpdateCaselist.add(cs);
           }                    
        } 
        if(UpdateCaselist.size()>0){
            SkipCaseTrigger.setSkipTrgTrue();
            Update UpdateCaselist;
        }    
    }
                
                //CRM-2071 -Venu Did changes to assign user based in new Account TCV values
                //  if(accloop.Total_Contract_Value__c <= Collection_Users__c.getInstance(System.Label.Collection_User1).Limit__c && cs.ownerId == Collection_Users__c.getInstance(System.Label.Collection_User1).Id__c){ 
                //   cs.ownerId = Collection_Users__c.getInstance(System.Label.Collection_User1).Id__c; 
                
                /* if((accloop.Total_Contract_Value__c >= Collection_Users__c.getInstance(System.Label.Collection_User2).Limit__c 
&& accloop.Total_Contract_Value__c < Collection_Users__c.getInstance(System.Label.Collection_User1).Limit__c) 
&& cs.ownerId != Collection_Users__c.getInstance(System.Label.Collection_User2).Id__c){                   
//cs.ownerId = [select id from user where name = 'Julie Ovieda'].Id;
cs.ownerId = Collection_Users__c.getInstance(System.Label.Collection_User2).Id__c;                      
cs.Followup_Status__c = '';
UpdateCaselist.add(cs);
}
} */
                /*if((accloop.Total_Contract_Value__c >= Collection_Users__c.getInstance(System.Label.Collection_User2).Limit__c 
&& accloop.Total_Contract_Value__c < Collection_Users__c.getInstance(System.Label.Collection_User1).Limit__c) 
&& cs.ownerId != Collection_Users__c.getInstance(System.Label.Collection_User1).Id__c){                   
//cs.ownerId = [select id from user where name = 'Julie Ovieda'].Id;
cs.ownerId = Collection_Users__c.getInstance(System.Label.Collection_User2).Id__c;                      
cs.Followup_Status__c = '';
UpdateCaselist.add(cs);
}*/

    
    public void accountConsolidatedBilling(List<Account> trgNew, Map<id,Account> trgOldMap){
        string combineddate='';
        string month = '0'+string.valueof(system.today().month());
        month = month.right(2);
        string day = '0'+string.valueof(system.today().day());
        day = day.right(2);
        combinedDate = system.today().year()+'-'+month+'-'+day;
        
        for(Account recAccount: trgNew){
            ////CRM-4351 Accept the payment method at the subscription level.
            if(recAccount.Collections_Hold__c !=trgOldMap.get(recAccount.id).Collections_Hold__c || (recAccount.Subscription_payment__c !=trgOldMap.get(recAccount.id).Subscription_payment__c)){              
                // Calling handler to Process the Account for update the collection hold flag in Zuora.  
                AccountConsolidatedBilling.UpdateCollectionHoldinZuora(recAccount.id,recAccount.Collections_Hold__c, recAccount.Subscription_payment__c);
            }
            if(recAccount.Consolidated_Billing_Flag__c!=trgOldMap.get(recAccount.id).Consolidated_Billing_Flag__c && recAccount.Consolidated_Billing_Flag__c){
                //Calling handler to Process the Account for Consolidated Billing  
                AccountConsolidatedBilling.consolidateAccountInZuora(recAccount.id,combinedDate);
            }
        }
    }
    
    @future
    public Static void UpdateLeadonTotalScoreChange(Set<Id> AccountIds){
        Set<String> setLeadStatus = new Set<String>();
        setLeadStatus.add('New');
        setLeadStatus.add('In Progress');
        List<Lead> lstLead = [Select id,name,Total_Score_Number__c, Account_Score__c, Inventory_score__c from Lead where Account__c=:AccountIds and Status=:setLeadStatus];
        for(Lead led:lstLead){
            led.Total_Score_Number__c = led.Account_Score__c*led.Inventory_score__c;
        }
        update lstLead;
    }
    
    public void SuspensionResumeStatusUpdate(Map<Id,Account> accountsMap, Map<Id,Account> oldAccountMap){
        set<Id> accountids = new set<Id>();
        List<case> UpdateCaselist = new List<case> ();
        List<case> Caselist = new List<case> ();
        for(Account acctloop : accountsMap.values()){
            Account oldvalues = oldAccountMap.get(acctloop.Id);
            if(acctloop.Suspension_Status__c != oldvalues.Suspension_Status__c){
                accountids.add(acctloop.id);
            }
        }
        if(!accountids.isEmpty())        
            Caselist = [Select id,AccountId ,OwnerId,Suspended_Date__c,Resume_Date__c,Status from case where AccountId IN:accountids AND RecordType.Name = 'Sales Ops' AND Status != 'Closed' limit 2];    
        for(Account accloop : accountsMap.values()){
            for(case cs : Caselist){
                if(accloop.Suspension_Status__c == 'Suspended'){                    
                    
                    cs.Suspended_Date__c = System.today(); 
                    cs.Status = 'Suspended';                       
                    UpdateCaselist.add(cs);
                }
                if(accloop.Suspension_Status__c == 'Resumed'){                     
                    cs.Resume_Date__c = System.today();
                    cs.Status = 'Resumed';                         
                    UpdateCaselist.add(cs);
                }
            }
        } 
        if(UpdateCaselist.size()>0){
            SkipCaseTrigger.setSkipTrgTrue();
            Update UpdateCaselist;
        }    
    }
    // For Employee Dashboard: delete accounts
    public Map<String, String> binderAcctDeleteCallout(Map<Id, Account> oldMap){
        Set<id> accIdSet = oldMap.keySet();
        Map<String, String> partyIdTypeMap = new Map<String, String>();
        for(Id acctId: accIdSet){
            if(oldMap.get(acctId).isBinder__c == true){
                partyIdTypeMap.put(oldMap.get(acctId).party_id__c, 'delete');
            }
        }
        system.debug('delete Map=====>>>'+partyIdTypeMap);
        if(Switch_AccountTrigger__c.getInstance().Set_CDH_Webservice_Callout_Off__c == false && !System.isBatch() && !System.isFuture()) {
            AccountTriggerHandlerManager.sendOutboundMessageInFutureDelete(partyIdTypeMap);
            return null;
        } else {
            return partyIdTypeMap;
        }    
    }
    
    
}