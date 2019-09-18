/*

* This class is used by PMO tool. It contains logic for calculating total closed tasks of type Call created withing 3 days
and associated with open cases with Record Type as Standard

*/

global without sharing class PMOKPICalculateClosedTasksWithOpenCases implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        Integer ret = 0;
        List<Task> tasks = [Select Id, WhatId from Task where IsClosed = true AND CreatedDate = LAST_N_DAYS:3 AND Type='Call' AND What.Type='Case' AND OwnerId =: userId LIMIT 50000];
        Set<Id> caseids = new Set<Id>();
        for(Task t : tasks){
            caseids.add(t.WhatId);
        }
        if(caseids != null && caseids.size() > 0){
            List<Case> cases = [Select id from Case where IsClosed=FALSE AND recordtype.developerName = 'Standard' AND recordtype.SObjectType='Case' AND Id IN: caseids LIMIT 50000];
            if(cases != null && cases.size() > 0)
                ret = cases.size();
        }
        
        return ret;
    }

}