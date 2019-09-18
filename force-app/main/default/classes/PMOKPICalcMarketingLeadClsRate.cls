/*

* This class is used by PMO tool. 
Marketing Lead Close Rate
*/

global without sharing class PMOKPICalcMarketingLeadClsRate implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        //get list of orders 
        //SAME as KPI # Campaign Orders Closed which was  used earlier 
        Integer num = 0;
        Integer den = 0;
        
        List<Order> ordList = [Select Id from Order where iscampaignorderclosed__c = TRUE AND ownerid = :userId AND opportunity.closedate = LAST_N_DAYS:30 LIMIT 20000];
        if(ordList != null)
            num = ordList.size();
        
        //COUNT of Leads where Assigned To = Running User AND Convert Date = Last 30 Days?
        // Converted date is the opp close date of a closed-won fulfilled oppty associated with lead
        //get converted leads owned by this ownerid
        Map<Id, Lead> lMap = new Map<Id, Lead>([Select id from Lead where ownerId=:userId AND Status='Converted' LIMIT 20000]);
        //get their opportunities which have amount and are closed won fulfilled
        Set<Id> denLeads = new Set<Id>();
        
        if(lMap != null && lMap.size() > 0){
            List<Opportunity> opplist = [SELECT id, Lead__c, stageName, probability, closedate FROM Opportunity where Lead__c IN: lMap.keySet() AND StageName = 'Closed Won - Fulfilled' LIMIT 20000];
            for(Opportunity oo : opplist){
                denLeads.add(oo.Lead__c);
            }
        }
        
        if(denLeads != null && denLeads.size() > 0)
            den = denLeads.size();
        
        return (den == 0 ? 0 : ((num * 100) / den));

    }
}