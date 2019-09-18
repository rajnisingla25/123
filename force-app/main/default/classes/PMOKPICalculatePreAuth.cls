/*

* This class is used by PMO tool. 
Pre-authorized
*/

global without sharing class PMOKPICalculatePreAuth implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        //List<aggregateResult> assets_notactive = [select id, name, waitlist__r.name, Wailist_Type__c from Waitlist_Item__c where waitlist__r.Status__c = 'Active' AND waitlist__r.CreatedDate = LAST_N_DAYS:30 AND Wailist_Type__c = 'Pre-Auth ' AND waitlist__r.Account__r.OwnerId = : userId];

        List<aggregateResult> preauthWaitlist = [select count(id), waitlist__c from Waitlist_Item__c where waitlist__r.Status__c = 'Active' AND waitlist__r.CreatedDate = LAST_N_DAYS:30 AND Wailist_Type__c = 'Pre-Auth' AND waitlist__r.Account__r.OwnerId = : userId 
        GROUP BY waitlist__c LIMIT 50000];
        return preauthWaitlist.size();
        
       /* List<Account> accList = [Select id from Account where ownerid=:userId];
        if(accList != null && accList.size() > 0){
            return (preauthWaitlist.size() * 100 / accList.size());
        }
        else
            return 0;*/
            
        //return preauthWaitlist.size();

    }
}