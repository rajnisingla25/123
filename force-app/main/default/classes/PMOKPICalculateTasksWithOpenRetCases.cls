/*

* This class is used by PMO tool. 

COUNT of Tasks Related to Case with Record Type = "Retention"
Case Status = Open 
Due Date = Last 30 Days


*/

global without sharing class PMOKPICalculateTasksWithOpenRetCases implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (stub instanceof Id) {Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); }
    }


    @TestVisible
    private static Integer calculate(Id userId) {

        Integer tskCnt = 0;
        Map<Id, List<Task>> caseTask = new Map<Id, List<Task>>(); //cases with list of tasks

        List<Task> tasks = [Select Id, whatid from Task where what.type='Case' AND Ownerid=:userId AND ActivityDate = LAST_N_DAYS:30 LIMIT 20000];  
        for(task t : tasks)
        {
            if(caseTask.containskey(t.Whatid))
            {
                 caseTask.get(t.Whatid).add(t);
            }
            else
            {
                caseTask.put(t.whatId, new List<Task>{t});
            }
        }
        
        List<Case> caseList = [select id from case where id IN:caseTask.KeySet() AND recordtype.developerName = 'Retention' AND isClosed=false LIMIT 20000];
        for(case c : caseList)
        {
            if(caseTask.containsKey(c.id))
            {
                tskCnt += caseTask.get(c.id).size();
            }
        }
        
        return tskCnt; 

    }



}