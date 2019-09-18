global class Updatecasecmntcountbatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Case_Comment_Count__c from case';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<case> scope){
        set<id> parentids = new set<id>();
        map<id,case> casemap = new map<id,case>();
        list<case> updatecase = new list<case>();
        
        for(case caseloop : scope){
            casemap.put(caseloop.id, caseloop);
            parentids.add(caseloop.id);
        }
        
        list < aggregateResult > calccasecount = [SELECT count(id) casecount,parentid FROM casecomment where parentid in :parentids group by parentid];

        for (aggregateResult agrlp: calccasecount ) {
            if(integer.valueof(agrlp.get('casecount')) != casemap.get(string.valueof(agrlp.get('parentid'))).Case_Comment_Count__c){
               case tempecase = new case();
               tempecase.id = string.valueof(agrlp.get('parentid'));
               tempecase.Case_Comment_Count__c = integer.valueof(agrlp.get('casecount')); 
               system.debug('casecmntcount:'+integer.valueof(agrlp.get('casecount'))); 
               updatecase.add(tempecase);
            }
        }
        system.debug('updatecase:'+updatecase);
        update updatecase;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}