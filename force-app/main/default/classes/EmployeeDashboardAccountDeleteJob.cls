/*****************************************************************************
* Class Name: EmployeeDashboardAccountDeleteJob
* Author: Shraddha Kabade
* Purpose: To delete Accounts and related data for Employee Dashboard Community user.
* JIRA : SUITE-3153
****************************************************************************/
public class EmployeeDashboardAccountDeleteJob implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public EmployeeDashboardAccountDeleteJob(){}
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select id,Party_id__c from Account where isBinder__c=true and Binder_account_active_till_date__c <= TODAY';
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext BC, List<Account> accRecords){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch execute'+accRecords);
        deleteAll(accRecords, 'franchise');
        
    }
    
    /**
     * Method to delete accounts and all related dependencies
     */
    public void deleteAll(List<Account> accRecords, String parentActType){
        
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> offSet = new Set<Id>();
        Set<Id> brokerIdSet = new Set<Id>();
        Set<Contact> contSet = new Set<Contact>();
        List<Account_Relationship__c> accRelList = new  List<Account_Relationship__c>();
        List<SObject> dependentList = new List<SObject>();
        Set<SObject> dependentSet = new Set<SObject>();
        List<SObject> finalDependentList = new List<SObject>();
        List<Contact> contList = new List<Contact>();
        Set<Account> acctDelSet = new Set<Account>();
        List<Account> acctDelList = new List<Account>();
        Collection_Users__c cu2 = Collection_Users__c.getValues('Employee Dashboard Default Account');
        
        for(Account a: accRecords){      
            accIdSet.add(a.Id);
        }
        // CRM-3230: if any account needs to be deleted then all accounts under it should get deleted. 
        // Added "parentActType" param to check the parent level account getting deleted
        if(parentActType != 'realtor agent'){
            if(parentActType == 'franchise'){
                // Get all community users and update account on user contact record before deleting accounts
                List<User> userList = [Select Id, ContactId, AccountId from User where AccountId In :accIdSet];
                if(!Test.isRunningTest()){
                    accIdSet.clear();
                }
                for(User u :userList){
                    Contact c = new Contact();
                    c.Id = u.ContactId;
                    c.AccountId = cu2.id__c;
                    contSet.add(c);
                    accIdSet.add(u.AccountId);
                }
                
                // Get all accounts under franchise accounts
                for(Account_Relationship__c ar: getChildRelationships(accIdSet)){
                    if(ar.Child_Account__c != null && ar.Child_Account_Type__c == 'Realtor Office'){
                        offSet.add(ar.Child_Account__c);
                        System.debug('relid---'+ar.id+offSet);
                    } else if(ar.Child_Account__c != null){
                        brokerIdSet.add(ar.Child_Account__c);
                    }
                    accRelList.add(ar);
                }
            }
            List<Account_Relationship__c> brokerArList = new List<Account_Relationship__c>();
            // Get all offices under broker
            if(!brokerIdSet.isEmpty()){
                brokerArList = getChildRelationships(brokerIdSet);
            } else if(parentActType == 'broker'){
                brokerArList = getChildRelationships(accIdSet);
            }
            
            for(Account_Relationship__c ar: brokerArList){
                if(ar.Child_Account__c != null){
                    offSet.add(ar.Child_Account__c);
                }
                accRelList.add(ar);
            }
            
            // Get all agents under offices
            if(!offSet.isEmpty()){
                accRelList.addAll(getChildRelationships(offSet));
            } else if(parentActType == 'realtor office') {
                accRelList.addAll(getChildRelationships(accIdSet));
            }
            
            for(Account_Relationship__c ar:accRelList){
                //Add all relationships to this list to delete them
                dependentList.add(ar);
                // To delete all franchise, agent, broker and office accounts, add both parent and child account to the set.
                // CRM-4046: Check for null values.
                if(ar.Parent_Account__c != null){
                    Account a = new Account();
                    a.id = ar.Parent_Account__c;
                    a.Party_id__c = ar.Parent_Account__r.Party_id__c;
                    acctDelSet.add(a);
                }
                if(ar.Child_Account__c != null){
                    Account b = new Account();
                    b.Id = ar.Child_Account__c;
                    b.Party_id__c = ar.Child_Account__r.Party_id__c;
                    acctDelSet.add(b);
                }
            }
            // Add all account relationships where child is getting deleted
            dependentList.addAll(getParentRelationships(accIdSet));

        } else {
            for(Account_Relationship__c ar: getParentRelationships(accIdSet)){
                 Account b = new Account();
                 b.Id = ar.Child_Account__c;
                 b.Party_id__c = ar.Child_Account__r.Party_id__c;
                 acctDelSet.add(b);
                 dependentList.add(ar);
            }
        }    
        //CRM-4046: Querying all dependencies and deleting
        list<Account> accDetailsList = [select id,(select Account_Name__c from Account_Listings__r)
                                        ,(select AccountId from Contracts) 
                                        ,(select AccountId from Assets)
                                        ,(select Account__c from Payment_Profiles__r)
                                        ,(select AccountId from Opportunities)
                                        ,(select whatId from Tasks)
                                        ,(select AccountId from Events)
                                        ,(select AccountId from Orders) 
                                        ,(select AccountId from cases)
                                        ,(select Zuora__Account__c from R00N40000001kyLcEAI__r)
                                        ,(select Id,Account__c from Waitlists__r)
                                        ,(select ParentId from Attachments)
                                        ,(select Bill_To_Account__c from Invoice_History__r)
                                        ,(select Fulfill_To_Account_Id__c from Invoice_Line_Item_History__r)
                                        ,(select Bill_To_Account__c from Payment_History__r)
                                        ,(select Account__c from Leads__r)
                                        ,(select Account__c from Campaign_History__r)
                                        ,(select Office__c from MLSOffice__r where MLS__r.Name Like 'BINDER%')
                                        ,(select Agent__c from MLSAgent__r where MLS__r.Name Like 'BINDER%')
                                        ,(select Parent_Account__c from ParentAccount__r where Relationship_Type__c = 'Contact')
                                        from account where Id in :acctDelSet];
        
        if(!acctDelSet.isEmpty()){
            acctDelList.addAll(acctDelSet);
            if(System.isBatch() || Test.isRunningTest()){
                Map<String, String> partyIdTypeMap = new Map<String, String>();
                for(Account a: acctDelList){
                    
                    partyIdTypeMap.put(a.Party_id__c, 'delete');
                }
                System.debug('=====Response account==='+partyIdTypeMap);
                sendOutboundMessageDelete(partyIdTypeMap);
            }
        }
        
        if(parentActType == 'franchise' && !contSet.isEmpty()){
            contList.addAll(contSet);
            update contList;
        }
        
        //CRM-4046: Add all dependencies to this list
        for (Account acc: accDetailsList){
            dependentList.addAll(acc.cases);
            dependentList.addAll(acc.Leads__r);
            dependentList.addAll(acc.Account_Listings__r);
            dependentList.addAll(acc.Contracts);
            dependentList.addAll(acc.Assets);
            dependentList.addAll(acc.Payment_Profiles__r);
            dependentList.addAll(acc.Tasks);
            dependentList.addAll(acc.Events);
            dependentList.addAll(acc.Opportunities);
            //dependentList.addAll(acc.Orders);
            dependentList.addAll(acc.R00N40000001kyLcEAI__r);
            dependentList.addAll(acc.Waitlists__r);
            dependentList.addAll(acc.Attachments);
            dependentList.addAll(acc.Invoice_History__r);
            dependentList.addAll(acc.Payment_History__r);
            dependentList.addAll(acc.Campaign_History__r);
        }
        System.debug('delall'+dependentList);
        
        // Add to set to remove any duplicates
        dependentSet.addAll(dependentList);
        
        //CRM-4046:
        if(!dependentSet.isEmpty()){
            finalDependentList.addAll(dependentSet);
            delete finalDependentList;
        }
        delete acctDelList;
        
        System.debug('list--'+contList+accRelList+acctDelList);
    }
    
    // CRM-3230: New method to get child relationships for given account
    public List<Account_Relationship__c> getChildRelationships(Set<Id> idSet){
        return [Select id, Parent_Account__c, Child_Account__c, Child_Account_Type__c,Parent_Account__r.Party_id__c, Child_Account__r.Party_id__c from Account_Relationship__c where Parent_Account__c IN :idSet and Relationship_Type__c = 'Parent/Child'];
    }

    // CRM-3230: New method to get parent relationships for given account
    public List<Account_Relationship__c> getParentRelationships(Set<Id> idSet){
        return [Select id, Parent_Account__c, Child_Account__c, Child_Account_Type__c,Parent_Account__r.Party_id__c, Child_Account__r.Party_id__c from Account_Relationship__c where Child_Account__c IN :idSet and Relationship_Type__c = 'Parent/Child'];
    }
    
    public static void sendOutboundMessageDelete( Map<String, String> partyIdAndTypeMap) {
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
    
    public void finish(Database.BatchableContext BC){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch finished');
    }
    
}