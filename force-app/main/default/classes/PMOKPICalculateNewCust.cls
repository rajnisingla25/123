/*

* This class is used by PMO tool. 
New customer acquisition
*/

global without sharing class PMOKPICalculateNewCust implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        List<aggregateResult> assets_notactive = [Select count(id) accCount, accountid from Asset where status !='Active' AND End_Date__c > LAST_N_DAYS:90 AND OwnerId =: userId group by accountid LIMIT 20000];

        Set<Id> accids = new Set<Id>();
        if(assets_notactive != null && assets_notactive.size() > 0){
            for(aggregateResult ar : assets_notactive){
                accids.add((Id)ar.get('accountid'));
            }
        }

        if(accids != null && accids.size() > 0){
            List<aggregateResult> assets_opp = [Select count(id) accCount, accountid from Opportunity where StageName ='Closed Won - Fulfilled' AND PMO_New_Customer_Acquisition_Prod__c > 0 AND CloseDate = THIS_MONTH AND OwnerId =: userId AND accountid IN: accids group by accountid LIMIT 20000];
            Integer retI = (assets_opp == null ? 0 : assets_opp.size());
            return retI;
        }
        else
            return 0;        

    }
}