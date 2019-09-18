//Name        : LeadRejectionBatch
//Description : This Batch Rejects the Open Leads which are created more than 60days.
//Frequencey  : Every Day
//Author      : Pallavi Tammana

global class LeadRejectionBatch implements Database.Batchable<sObject>{
    String query;
    
    global Database.querylocator start(Database.BatchableContext BC){
        Set<String> setStatus = new Set<String>{'Converted','Rejected'};
            Set<String> setMarketType = new Set<String>{'Event','Auto-Renew','Outbound Call Leads','Opcity'};
                Query = 'SELECT Name,Id, Status, Rejected_Reason__c  FROM Lead WHERE Marketing_Lead_Type__c != :setMarketType and status!= :setStatus and Can_be_Rejected__c = True';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        SkipTrigger.setSkipTrgTrue();
        List<Lead> LeadList = new List<Lead>();
        for(Lead led : scope){
            led.Status = 'Rejected';
            led.Rejected_Reason__c = 'Expired';
            LeadList.add(led);
        }
        if(!Test.isRunningTest()){update LeadList ;}
    }
    
    global void finish(Database.BatchableContext BC){
        ContactMethodReprocessBatch cmReprocessBatch = new ContactMethodReprocessBatch();
        database.executebatch(cmReprocessBatch, 200);
    }
}