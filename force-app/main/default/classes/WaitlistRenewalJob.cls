global class WaitlistRenewalJob implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // List<Waitlist__c> waitilsr =  ; 
        String query =  label.WaitlistRenewalJob;  //CRM-1815
        return Database.getQueryLocator(query);   //CRM-1815
    }
    
    global void execute(Database.BatchableContext BC, List<Waitlist__c> scope){
        
      
        Set<Id> accountIds = new Set<Id>(); // to store all the account Ids of the renewed waitlists. 
        Set<Id> activeWaitListIds = new Set<Id>(); // to get the active waitlist Ids for getting wait list item records to update the status. 
        Set<Id> renewWaitListIds = new Set<Id>(); // to get the renewed waitlist Ids for getting wait list item records to update the status. 
        List<WaitList__c> updateWaitlist = new List<WaitList__c>(); // to update the status of waitlist
        List<Waitlist_Item__c> updateWaitListItems = new List<Waitlist_Item__c>(); // to update the status of waitlist items

       
        
        for(WaitList__c wl : scope){ //updating renewed waitlist to active status
            accountIds.add(wl.account__c); //getting account Ids to get the active waitlists on the account
            renewWaitListIds.add(wl.id); //getting renewed waitlist Ids to get the wait list items to be updated with active status. 
            wl.status__c = 'Active'; //updating the status of the waitlist to Active from Renew. 
            updateWaitlist.add(wl); //adding to the list to update at the end. 
        }
        
        for(WaitList__c wl : [Select Id, Status__c from Waitlist__c where Account__c IN : accountIds AND Status__c = 'Active']){ //updating active wait list to expired status
            activeWaitListIds.add(wl.id); //getting active waitlist Ids to query wait list items to be updated. 
            wl.status__c = 'Expired'; //updating the active wait list record status from Active to Expired. 
            
            updateWaitlist.add(wl); //adding to the list to update at the end. 
        }
        
        for(Waitlist_Item__c wli : [Select Id, Status__c from Waitlist_Item__c where Waitlist__c IN: renewWaitListIds AND Is_Renewed_Row__c= true]){ //updating renew wait list items with active status
            wli.Status__c = 'Active'; //updating the status from renew to active.
            updateWaitListItems.add(wli); //adding to the list to update at the end. 
        }

        for(Waitlist_Item__c wli : [Select Id, waitlist_Id__c, Status__c from Waitlist_Item__c where Waitlist__c IN: activeWaitListIds AND Status__c IN ('Active','Pending Pre-Auth','Created','Pending Pre-Auth Approval')]){ //updating renew wait list items with active status
            wli.Status__c = 'Expired'; //updating the status from active to Expired.
           // wli.waitlist_Id__c = '0'; //CRM-1717
            updateWaitListItems.add(wli); //adding to the list to update at the end. 
        }
        
        update updateWaitlist;  //updating wait lists 
        update updateWaitListItems; //updating wait list items 
 
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}