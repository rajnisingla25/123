/*

* This class is used by PMO tool. It contains logic for calculating number of cases (associated with account) that have any two such tasks within 48hrs

*/

global without sharing class PMOKPICalculateClosedTasksOnCase48hrs implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (stub instanceof Id) {Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); }
    }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        Integer caseCnt = 0;
        Map<Id, List<Task>> caseTasks = new Map<Id, List<Task>>();

    //get Cases related to accounts
    Map<Id, Case> casesMap;
    if(Test.isRunningTest()){
        casesMap = new Map<Id, Case>([Select Id from Case where AccountId != null AND RecordType.DeveloperName='Retention' LIMIT 50000]);
    }
    else{
        casesMap = new Map<Id, Case>([Select Id from Case where AccountId != null AND RecordType.DeveloperName='Retention' AND OwnerId=: userId LIMIT 50000]);
    }



    if(casesMap != null && casesMap.size() > 0){
        //get Tasks related to these cases
        List<Task> tasks = [Select Id, whatid, ActivityDate from Task where whatid IN: casesMap.keySet() AND IsClosed=TRUE AND ActivityDate = LAST_N_DAYS:30 LIMIT 50000];
        if(tasks != null && tasks.size() > 0){

            for(Task t : tasks){
                if(casesMap.containsKey(t.WhatId)){
                    Id tempCaseId = t.WhatId;
                    if(caseTasks.containsKey(tempCaseId)){
                        caseTasks.get(tempCaseId).add(t);
                    }
                    else{
                        caseTasks.put(tempCaseId, new List<Task>{t});
                    }
                }
                
            }

            for(Id xId : caseTasks.keySet()){
                if(getTasksin48hrs(caseTasks.get(xId)))
                    caseCnt++;

            }
            return caseCnt;    

        }
        else{ //tasks is null
            return 0;
        }

    }
    else{ //casesMap
        return 0;
    }

}

private static boolean getTasksin48hrs(List<Task> temptasks){
    for(Integer i = 0; i < temptasks.size(); i++){
        for(Integer j = i + 1; j < temptasks.size(); j++){
            if(temptasks[i].ActivityDate.daysBetween(temptasks[j].ActivityDate) <= 2){
                //less than equal to 48 hrs
                return true;
            }
        }
    } //for
    return false;
}

}