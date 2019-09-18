//Name        : AutoRenewalQuoteSubmitBatch 
//Description : This Batch Auto Submit all the quotes which are due for renewal in the current month based on Asset End Date.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteSubmitBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{

    global String Query;
    global set<ID> BMQIdset = new set<ID>();
    
    global AutoRenewalQuoteSubmitBatch(set<ID> BMQIds){
        BMQIdset.addall(BMQIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Query = 'SELECT Id FROM BigMachines__Quote__c WHERE ID IN :BMQIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {
        
        Integer submitDays = 5;
        String quotId = null;
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine= new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();    
        
        Schedule_Batch_Setting__c autoSubmit = Schedule_Batch_Setting__c.getValues('Auto Renewal Quote Submission');
        if(autoSubmit != null){submitDays = Integer.valueOf(autoSubmit.Execution_Time_hr__c);}
        System.debug('submitDays:'+submitDays);
        Date dt = System.today() + submitDays +1;
        System.debug('dt:'+dt);
                        
        List<BigMachines__Quote_Product__c> bmqpList = [Select Id, BigMachines__Quote__c, BigMachines__Quote__r.Name, Billing_Period__c, DocumentNumber__c from BigMachines__Quote_Product__c 
                                                where BigMachines__Quote__r.BigMachines_Quote_Type__c = 'Auto-Renew' AND Line_Type__c = 'Renew' AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress' AND  BigMachines__Quote__r.Id =:scope[0].ID AND BigMachines__Quote__r.EarliestQuoteProductStartDate__c = :dt];
                          
        for(BigMachines__Quote_Product__c bmqp : bmqpList) {
        
            WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper auto = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
            auto.BMDocumentNumber = String.valueof(bmqp.DocumentNumber__c);
            auto.BMActionRequired = 'Renew';
            auto.BillingType = bmqp.Billing_Period__c;
            lstwbserAuReneLine.add(auto);             
            quotId = bmqp.BigMachines__Quote__r.Id;
            
        }
        
        if(!lstwbserAuReneLine.isEmpty()) {
            String wbserAuReneLineStr = JSON.serialize(lstwbserAuReneLine);
            if(quotId != null && wbserAuReneLineStr != null)
                autoRenewalQuote(quotId, wbserAuReneLineStr);
        }
        
    }
    
    public static void autoRenewalQuote (String QuoteId, String updateAutoRenewalQuoteList) {
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine = (List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateAutoRenewalQuoteList, List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>.class);
        WebserviceCallBigMachineQuoteCls wbcbmq = new WebserviceCallBigMachineQuoteCls();
        if(!Test.isRunningTest()) {wbcbmq.UpdateDeleteAutoRenewalQuote(QuoteId, lstwbserAuReneLine);}
        System.debug('wbcbmq.CPQReturnedMsg:'+wbcbmq.CPQReturnedMsg);
        System.debug('QuoteId:'+QuoteId);
        if(wbcbmq.CPQReturnedMsg != '') {
            BigMachines__Quote__c bmq  = new BigMachines__Quote__c();
            bmq.Id                     = QuoteId;
            bmq.SalesOperations__c     = True;
            System.debug('bmq:'+bmq);         
            Update bmq;
        }
            
    }
    
    global void finish(Database.BatchableContext BC){
    
    }

}