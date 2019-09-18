/*
* This class is used by PMO tool. 
COUNT of Accounts with Assets where  Follow_Up_Status__c changed to 'Renewed' AND AssetName Contains "Showcase"
DIVIDED BY 
COUNT of Accounts where Asset Name CONTAINS "Showcase" 
AND End Date = CQ AND Active = True) (Need to review how to keep denominator unchange for the quarter)
*/

global without sharing class PMOKPICalculateShowcaseRenewalRate implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        List<Asset> shwcaseRenAsset = [Select Id, AccountId from Asset where account.ownerid =: userId AND PMO_isShowcaseRenewed__c = true AND End_Date__c = THIS_QUARTER AND Status='Active' LIMIT 20000];
        List<Asset> shwcaseAsset = [Select Id, AccountId from Asset where account.ownerid =: userId AND PMO_isShowcase__c = true AND End_Date__c = THIS_QUARTER AND Status='Active' LIMIT 20000];
        Set<Id> acc1 = new Set<Id>(); //account ids
        for(Asset as1 : shwcaseRenAsset){
            acc1.add(as1.AccountId);
        }
        Integer num = (acc1 == null ? 0 : acc1.size());

        acc1 = new Set<Id>();
        for(Asset as1 : shwcaseAsset){
            acc1.add(as1.AccountId);
        }
        Integer den = (acc1 == null ? 0 : acc1.size());

        return (den == 0 ? 0 : num * 100 / den);
    
    }
}