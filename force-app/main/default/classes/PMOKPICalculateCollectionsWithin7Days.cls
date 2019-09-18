/*

* This class is used by PMO tool. 
COUNT of Cases With Record Type = "Collections" Created Date 
WITH Minimum of 3 TASKS (WITH Type = call, meeting, other, message, follow up, contract review, maintenance call, billing setup, customer update) 
AND 3 TASKS (WITH Type = Emails) (with Task Created Date = First 7 Days of Associated Case's Life)
DIVIDED by
COUNT of Cases with Record Type = "Collections" where Created Date = Last 30 Days
*/

global without sharing class PMOKPICalculateCollectionsWithin7Days implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); }
    }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        //denominator
        Map<Id, Case> cases2 = new Map<Id, Case>([SELECT Id from Case where recordtype.developerName = 'Collections' AND recordtype.SObjectType='Case' AND OwnerId=: userId AND CreatedDate = LAST_N_DAYS:30 Limit 50000]);
        Integer num2 = 0;
        if(cases2 != null && cases2.size() > 0)
            num2 = cases2.size();

        if(num2 == 0)
            return 0;   

        //numerator
        Map<Id, Case> cases1 = new Map<Id, Case>([SELECT Id, CreatedDate from Case where recordtype.developerName = 'Collections' AND recordtype.SObjectType='Case' AND OwnerId=: userId AND CreatedDate = LAST_N_DAYS:30 Limit 50000]);
        Map<Id, Datetime> casesWithCreatedDate = new Map<Id, Datetime>();

        for(Id ii : cases1.keySet()){
            casesWithCreatedDate.put(ii, cases1.get(ii).CreatedDate.addDays(7));
        }

        List<Task> tasks1 = [SELECT Id, whatid, CreatedDate from Task where 
        (Type='Call' OR 
         Type='Meeting' OR 
         Type='Other' OR 
         Type='Message' OR 
         Type='Follow Up' OR 
         Type='Contract Review' OR 
         Type='Maintenance Call' OR 
         Type='Billing Setup' OR 
         Type='Customer Update' 
        )
        AND whatid IN : cases1.keySet() LIMIT 50000];

        List<Task> tasks2 = [SELECT Id, whatid, CreatedDate from Task where Type='Emails' AND whatid IN : cases1.keySet() LIMIT 50000];
        
        Integer num1 = 0;
        Map<Id, Integer> casesWTask1Count = new Map<Id, Integer>(); //Caseid and task count 
        Map<Id, Integer> casesWTask2Count = new Map<Id, Integer>(); //caseid and task count

        for(Task t : tasks1){
            if(t.CreatedDate >= cases1.get(t.whatid).CreatedDate && t.CreatedDate <= casesWithCreatedDate.get(t.whatid)){
                if(casesWTask1Count.containsKey(t.whatid)){
                    Integer ix = casesWTask1Count.get(t.whatid);
                    casesWTask1Count.put(t.whatid, ix + 1);
                }
                else{
                    casesWTask1Count.put(t.whatid, 1);                
                }
            }
        }
        for(Task t : tasks2){
            if(t.CreatedDate >= cases1.get(t.whatid).CreatedDate && t.CreatedDate <= casesWithCreatedDate.get(t.whatid)){
                if(casesWTask2Count.containsKey(t.whatid)){
                    Integer ix = casesWTask2Count.get(t.whatid);
                    casesWTask2Count.put(t.whatid, ix + 1);
                }
                else{
                    casesWTask2Count.put(t.whatid, 1);                
                }
            }
        }
        
        for(Id ii : casesWTask1Count.keySet()){
            if(casesWTask1Count.get(ii) >= 3 && casesWTask2Count.containsKey(ii) && casesWTask2Count.get(ii) >= 3)
                num1++;
        }

        return (num1 * 100) / num2;
    }

}