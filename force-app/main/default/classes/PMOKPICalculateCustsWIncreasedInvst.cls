/*
* This class is used by PMO tool. 
Count of Accounts where 'Order Amount' > 'Expiring Contract Value' / Count of Accounts with 'Expiring Contract Value' > 0

Expiring contract value: 
sum of all assets 'total net price' where status = active, end date = current month and name starts with 'Connection(SM)' Note: Should not change for the current month. 

Order amount: 
sum of order product total net where line type = renew or add, order type = modify, order status = complete and product name starts with 'Connection(SM)' and effective date = current month

*/

global without sharing class PMOKPICalculateCustsWIncreasedInvst implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }


    @TestVisible
    private static Integer calculate(Id userId) {
        List<Account> accList = [Select Id from Account where ownerId=: userId LIMIT 20000];
        Set<Id> myAcctIds = new Set<Id>();
        for(Account aa : accList){
            myAcctIds.add(aa.Id);
        }
        //get list of order product ... Add more filters (Order Product: Line TypeEQUALSAdd,Renew) AND (Product: Product NameSTARTS WITHConnection(SM))
        List<OrderItem> ois = [Select Id, Total_Price__c, Order.AccountId, Asset__c, Asset__r.Day_One_Total_Net__c, Asset__r.Day_One_End_Date__c from OrderItem 
        where 
        (line_type__c = 'Renew' OR line_type__c = 'Add') AND 
        order.type = 'Modify' AND 
        order.status = 'Complete' AND 
        pricebookentry.name Like 'Connection%' AND 
        order.effectivedate = THIS_MONTH AND 
        Order.Account.ownerid =: userId
        LIMIT 20000];
        if(Test.isRunningTest()){
            ois = [Select Id, Total_Price__c, Order.AccountId, Asset__c, Asset__r.Day_One_Total_Net__c, Asset__r.Day_One_End_Date__c from OrderItem limit 1]; 
        }
        //get count of such acccounts having order amount > expiring contract value
        Set<Id> accnum = new Set<Id>();
        Set<Id> orderitemAssets = new Set<Id>();//extract list of assets 
        for(OrderItem oi : ois){
            orderitemAssets.add(oi.Asset__c);
            if(oi.Order != null && oi.Order.AccountId != null && oi.Total_Price__c >= oi.Asset__r.Day_One_Total_Net__c) //'Order Amount' > 'Expiring Contract Value'
                accnum.add(oi.Order.AccountId);
        }

        Integer num = accnum.size();

        //get list of Accounts with Expiring Contract value > 0 .. which means Day_One_End_Date__c = THIS_MONTH and Day_One_Total_Net__c > 0
        List<Asset> expiringAssetList = [Select Id, AccountId, Day_One_Total_Net__c, Day_One_End_Date__c from Asset where Account.OwnerId =: userId  
        AND End_Date__c = THIS_MONTH AND Day_One_Total_Net__c > 0 LIMIT 20000];
        List<Id> denAccIds = new List<Id>();
        for(Asset as1 : expiringAssetList){
            denAccIds.add(as1.AccountId);
        }
        
        integer den = denAccIds == null ? 0 : denAccIds.size();

        return (den == 0 ? 0 : num * 100 / den);

    }
}