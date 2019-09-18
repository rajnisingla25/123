global class WaitlistExpireBatch implements Database.Batchable<sObject>{

  global Database.QueryLocator start(Database.BatchableContext BC){
      String query =  label.WaitlistExpireQuery;       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Waitlist_Item__c > scope){
         for(Waitlist_Item__c wl : scope){
             wl.Status__c= 'Expired';           
         }
         update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}