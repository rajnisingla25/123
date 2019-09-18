global class Updatecasecountbatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT id,parentid FROM case where parentid  <> null';
        system.debug('query:'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<case> scope){
        system.debug('in here');
        set<id> parentids = new set<id>();
        list<case> updatecase = new list<case>();
        
        for(case caseloop : scope){
            parentids.add(caseloop.parentid);
        }
        
        list < aggregateResult > calccasecount = [SELECT count(id) casecount,parentid FROM case where parentid in : parentids group by parentid];
        
        for (aggregateResult agrlp: calccasecount ) {
            case tempecase = new case();
            tempecase.id = string.valueof(agrlp.get('parentid'));
            tempecase.Child_cases__c= integer.valueof(agrlp.get('casecount'));
            updatecase.add(tempecase);
        }
        update updatecase;
        system.debug('updatecase:'+updatecase);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}