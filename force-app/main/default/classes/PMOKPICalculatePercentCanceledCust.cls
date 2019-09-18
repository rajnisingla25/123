/*

* This class is used by PMO tool. 

% Cancelled and resold customers


*/

global without sharing class PMOKPICalculatePercentCanceledCust implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) { if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Decimal calculate(Id userId) {
        
        List<aggregateResult> assets_cancelled = [Select count(id) accCount, accountid from Asset where status='Cancelled' AND Cancellation_Effective_Date__c = LAST_N_DAYS:30 AND OwnerId =: userId group by accountid LIMIT 20000];
        Set<Id> account_asset_cancelled = new Set<Id>();
        
        for(aggregateResult ar : assets_cancelled){
            account_asset_cancelled.add((Id) ar.get('accountid'));
        }
        Integer a = account_asset_cancelled == null ? 0 : account_asset_cancelled.size(); //Denominator in the calculation
        
        if(a == 0)
            return 0;
        
        
        List<aggregateResult> assets_fulfilled_cancelled = [Select count(id) accCount, accountid from Asset where status='Active' AND Start_Date__c = LAST_N_DAYS:30 AND Renewal_Status__c = null AND Fulfillment_Status__c = 'Fulfilled' AND OwnerId =: userId AND accountid IN: account_asset_cancelled GROUP BY accountid LIMIT 20000];
        
         
        Integer b = assets_fulfilled_cancelled == null ? 0 : assets_fulfilled_cancelled.size();       
           
        Decimal p = (a == 0 ? 0 : b/a * 100);
        
        return p;

    }
}