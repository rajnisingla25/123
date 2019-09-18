//Name        : ContactMethodReprocessBatch
//Description : This Batch Reprocess all the Contact Methods without ExternalId.
//Frequencey  : Every Day
//Author      : Pallavi Tammana

global class ContactMethodReprocessBatch implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
        Query = 'SELECT Id, External_ID__c, Sync_With_CDH__c, Active__c FROM ContactMethod__c WHERE External_ID__c = null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ContactMethod__c> scope){
       List<ContactMethod__c> cmList = new List<ContactMethod__c>();
       for(ContactMethod__c cm : scope){
           cm.Sync_With_CDH__c = True;
           cmList.add(cm);
       }
       if(!Test.isRunningTest()){update cmList;}
    }

    global void finish(Database.BatchableContext BC){
    }

}