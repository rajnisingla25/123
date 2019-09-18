//Name        : AutoRenewalQuoteDeletionBatch
//Description : This Batch deletes quote for all auto renewable assets which are oversold and customer response as 'Do not Renew'.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteDeletionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> BMQIdset = new set<ID>();
    global String Query;
       
    global AutoRenewalQuoteDeletionBatch(set<ID> BMQIds) {
        BMQIdset.addall(BMQIds);
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ BMQIdset:'+BMQIdset);
        Query = 'Select Id, BigMachines__Status__c from BigMachines__Quote__c where BigMachines__Status__c = \'In Progress\' AND BigMachines_Quote_Type__c = \'Auto-Renew\' and BigMachines__Line_Items__c < 1 AND  Id IN :BMQIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {
    
        List<BigMachines__Quote__c> BMQUpdList = new List<BigMachines__Quote__c>();
        
        for(BigMachines__Quote__c bmq: scope) {
            bmq.BigMachines__Status__c = 'Rejected';
            BMQUpdList.add(bmq);
        }
        
        if(!BMQUpdList.isEmpty())
            update BMQUpdList;
    
    }
    
    global void finish(Database.BatchableContext BC) {          
    }
    
}