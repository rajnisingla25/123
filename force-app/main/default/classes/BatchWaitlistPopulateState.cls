global class BatchWaitlistPopulateState implements Database.Batchable<sObject>, Database.AllowsCallouts{
String query;
global Database.querylocator start(Database.BatchableContext BC){ 
    query = 'SELECT id, state__c, market__c FROM Waitlist_item__c WHERE (state__c = null OR state__c = \'\') AND (market__c != null AND market__c != \'\')';
        return Database.getQueryLocator(query);
}
global void execute(Database.BatchableContext BC, List<Waitlist_Item__c> scope){
    List<Waitlist_Item__c> waitlistItems = new List<Waitlist_Item__c>();
        for(waitlist_item__c waitlistItem : scope){
            try{
            waitlistItem.state__c = PreAuthWaitListRenewalUtil.stateCodeFromZip(waitlistItem.Market__c);
            }catch(Exception e){
               waitlistItem.state__c = ''; 
            }
            waitlistItems.add(waitlistItem);
        }
    
    if(waitlistItems.size()>0){
        Database.SaveResult[] saveResults = Database.update(waitlistItems, FALSE);
    } 
}
global void finish(Database.BatchableContext BC){
    }

}