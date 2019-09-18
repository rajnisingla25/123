//Name        : AutoRenewalDeleteQuoteProdBatch 
//Description : This Batch deletes quote Products for all auto renewable assets which are oversold.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalDeleteQuoteProdBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> BMQIdset = new set<ID>();
    global String Query;
       
    global AutoRenewalDeleteQuoteProdBatch(set<ID> BMQIds) {
        BMQIdset.addall(BMQIds);
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ BMQIdset:'+BMQIdset);
        Query = 'SELECT ID FROM BigMachines__Quote__c WHERE ID IN :BMQIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {
        Map<Id,List<BigMachines__Quote_Product__c>> bmqListMap = new Map<Id,List<BigMachines__Quote_Product__c>>();
        Set<Id> bmqIdSet = new Set<Id>();
        
        for(BigMachines__Quote_Product__c bmqp : [Select Id, Asset_Structure__c, BigMachines__Quote__c, Line_Type__c, 
                                                     BigMachines__Quote__r.Id, DocumentNumber__c, Billing_Period__c, 
                                                     Need_Manual_Renew__c, BigMachines__Quote__r.BigMachines_Quote_Type__c
                                                      from BigMachines__Quote_Product__c where BigMachines__Quote__r.Id IN: scope]) {
            if(bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c == 'Auto-Renew' && bmqp.Line_Type__c == 'Renew' && bmqp.Need_Manual_Renew__c){
                if(bmqListMap.containsKey(bmqp.BigMachines__Quote__r.Id)){
                    List<BigMachines__Quote_Product__c> bmqpList = bmqListMap.get(bmqp.BigMachines__Quote__r.Id);
                    bmqpList.add(bmqp);
                    bmqListMap.put(bmqp.BigMachines__Quote__r.Id, bmqpList);
                
                }else{
                    bmqListMap.put(bmqp.BigMachines__Quote__r.Id, new List<BigMachines__Quote_Product__c> {bmqp});
                    bmqIdSet.add(bmqp.BigMachines__Quote__r.Id);
                }                                           
            }
        }
        
        if(!bmqIdSet.isEmpty()) {   
            for(Id bmqId: bmqIdSet) {
                List<BigMachines__Quote_Product__c> bmqpList = bmqListMap.get(bmqId);
                if(!bmqpList.isEmpty()) {
                    String wbserAuReneLineStr = null;
                    List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine= new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();                    
                    for(BigMachines__Quote_Product__c bmqp: bmqpList) {
                        WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper auto = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
                        auto.BMDocumentNumber = String.valueof(bmqp.DocumentNumber__c);
                        auto.BMActionRequired = 'Remove';
                        auto.BillingType = bmqp.Billing_Period__c;
                        lstwbserAuReneLine.add(auto);                                   
                    }
                    wbserAuReneLineStr = JSON.serialize(lstwbserAuReneLine);
                    lstwbserAuReneLine.clear();
                    if(!Test.isRunningTest() && wbserAuReneLineStr != null) {
                        String quotId = bmqId;
                        autoRenewalQuote(quotId, wbserAuReneLineStr); 
                    }
                }       
            }
        }    
    }
    
    public static void autoRenewalQuote (String QuoteId, String updateAutoRenewalQuoteList) {
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine = (List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateAutoRenewalQuoteList, List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>.class);
        WebserviceCallBigMachineQuoteCls wbcbmq = new WebserviceCallBigMachineQuoteCls();
        wbcbmq.UpdateDeleteAutoRenewalQuote(QuoteId, lstwbserAuReneLine);  
    }
    
    global void finish(Database.BatchableContext BC) {            
        
    
    }
    

}