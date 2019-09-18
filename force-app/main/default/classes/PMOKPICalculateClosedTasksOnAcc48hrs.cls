/*

* This class is used by PMO tool. It contains logic for calculating number of accounts having cases,, and the tasks of those cases have any two such tasks within 48hrs

*/

global without sharing class PMOKPICalculateClosedTasksOnAcc48hrs implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); }
    }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        Integer accCnt = 0;
        Map<Id, List<Task>> accountTasks = new Map<Id, List<Task>>();

        //get list of accounts with past due and assigned to current user
        Map<Id, Account> acctsMap = new Map<Id, Account>([Select Id from Account where Past_Due__c = TRUE AND ownerid=:userId LIMIT 50000]);

 
        if(acctsMap != null && acctsMap.size() > 0){
            //get Cases related to these accounts
            Map<Id, Case> casesMap = new Map<Id, Case>([Select Id,AccountId from Case where AccountId IN: acctsMap.keySet() LIMIT 50000]);

            if(casesMap != null && casesMap.size() > 0){
                //get Tasks related to these cases
                List<Task> tasks = [Select Id, whatid, ActivityDate from Task where whatid IN: casesMap.keySet() AND IsClosed = TRUE AND ActivityDate = LAST_N_DAYS:30 LIMIT 50000];
                if(tasks != null && tasks.size() > 0){

                    for(Task t : tasks){
                        if(casesMap.containsKey(t.WhatId)){
                            Id tempAccId = casesMap.get(t.WhatId).AccountId;
                            if(accountTasks.containsKey(tempAccId)){
                                accountTasks.get(tempAccId).add(t);
                            }
                            else{
                                accountTasks.put(tempAccId, new List<Task>{t});
                            }
                        }
                        
                    }

                    for(Id xId : accountTasks.keySet()){
                        if(getTasksin48hrs(accountTasks.get(xId)))
                            accCnt++;

                    }
                    return accCnt;    

                }
                else{ //tasks is null
                    return 0;
                }

            }
            else{ //casesMap
                return 0;
            }

        }
        else{ //acctsMap is null
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