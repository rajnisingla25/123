//Name        : ARIIAccountUpdateBatch
//Description : This Batch updates Account Default Renewal Term.
//Frequencey  : Every Month
//Author      : Pallavi Tammana
//History     : 


global class ARIIAccountUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> AcctIdset = new set<ID>();
    global String Query;
       
    global ARIIAccountUpdateBatch(set<ID> AcctIds) {
        AcctIdset.addall(AcctIds);
    }
     
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ AcctIdset:'+AcctIdset);
        
        Query = 'Select Id from Account where Auto_Renewal__c = True AND AR_Default_Renewal_Term__c = null AND Account_Sub_Type__c = \'Customer\' AND Id IN :AcctIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
    
        List<Account> AcctUpdList = new List<Account>();
        Integer roundRobinStateId = 0;
        Map<Integer,Integer> mapQueueRoundRobinId = new Map<Integer,Integer>();  
        
        for(AR_Account_Renewal_Term__c roundRobinState: AR_Account_Renewal_Term__c.getAll().Values()){
            mapQueueRoundRobinId.put(Integer.valueOf(roundRobinState.Name), Integer.valueOf(roundRobinState.RoundRobin__c));
        } 
        Integer leadNumber = 0;
        Integer roundRobinId = 0;
                
        for(Account acct: scope) {
        
            System.debug('acct:'+acct);
            roundRobinId = Math.Mod(roundRobinStateId +  leadNumber ,2);
            System.debug('value for assignment:'+roundRobinId);
            System.debug('Final Value:'+mapQueueRoundRobinId.get(roundRobinId));
            leadNumber += 1;
            acct.AR_Default_Renewal_Term__c = mapQueueRoundRobinId.get(roundRobinId);
            System.debug('acct:'+acct);
            AcctUpdList.add(acct);
        }
        System.debug('AcctUpdList:'+AcctUpdList);
    
        if(!AcctUpdList.isEmpty()) {
            update AcctUpdList;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {          
    }
}