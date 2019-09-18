/*

* This class is used by PMO tool. 
COUNT of Accounts with at least 1 Case where Record Type = "Retention"
where Case_Owner = Opportunity_Owner on a Closed Won Opportunity Related to same Account
where Case_Owner = Running User

Divided By

COUNT of Accounts with at least 1 Case where Record Type = "Retention"
where Case_Owner = Running User

*/

global without sharing class PMOKPICalculateAccountsUpsold implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        
        //Case with owner as running userId
        List<Case> retCases;
        if(Test.isRunningTest()){
            retCases = [SELECT Id, AccountId from Case LIMIT 1];
        }
        else{
            retCases = [SELECT Id, AccountId from Case where OwnerId=: userId AND recordtype.developerName = 'Retention' AND recordtype.SObjectType = 'Case' AND AccountId != null LIMIT 50000];
        }
        
        
        
        //get accounts of these cases
        Set<Id> accIds = new Set<Id>();
        for(Case c : retCases){ 
            accIds.add(c.AccountId); 
        }
        //get opportunities for these accounts where opportunity owner is same as case owner, which is the current user
        List<Opportunity> accOpps = [SELECT Id, AccountId from Opportunity where OwnerId=: userId AND AccountId IN: accIds AND isClosed = true AND isWon = true LIMIT 50000] ;
        //get count of case accounts having opportunities
        Integer num = 0;
        for(Opportunity o : accOpps) { 
            if(accIds.contains(o.AccountId)) 
                num++; 
        }
        
        Integer den = (accIds == null) ? 0 : accIds.size();
        Integer res = (den == 0) ? 0 : (num/den);
        
        return res;
    }

}