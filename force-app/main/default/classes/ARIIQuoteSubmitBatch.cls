//Name        : ARIIQuoteSubmitBatch 
//Description : This Batch Auto Submit all the quotes which are due for renewal in the current month based on Asset End Date.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class ARIIQuoteSubmitBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{

    global String Query;
    global set<ID> BMQIdset = new set<ID>();
    
    global ARIIQuoteSubmitBatch (set<ID> BMQIds){
        BMQIdset.addall(BMQIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Query = 'SELECT Id FROM BigMachines__Quote__c WHERE ID IN :BMQIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {
        String quotId = null;
        List< ARIICPQCalls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine= new List< ARIICPQCalls.AutoRenewalQuoteLineWrapper>();        
                        
        List<BigMachines__Quote_Product__c> bmqpList = [Select Id, BigMachines__Quote__c, BigMachines__Quote__r.Name, Billing_Period__c, DocumentNumber__c from BigMachines__Quote_Product__c 
                                                where BigMachines__Quote__r.BigMachines_Quote_Type__c = 'Auto-Renew' AND Line_Type__c = 'Renew' AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress' AND  BigMachines__Quote__r.Id =:scope[0].ID];
        System.debug('bmqpList:'+bmqpList);
        for(BigMachines__Quote_Product__c bmqp : bmqpList) {
        
            ARIICPQCalls.AutoRenewalQuoteLineWrapper auto = new ARIICPQCalls.AutoRenewalQuoteLineWrapper();
            auto.BMDocumentNumber = String.valueof(bmqp.DocumentNumber__c);
            auto.BMActionRequired = 'Renew';
            auto.BillingType = bmqp.Billing_Period__c;
            lstwbserAuReneLine.add(auto);             
            quotId = bmqp.BigMachines__Quote__r.Id;
            
        }
        System.debug('lstwbserAuReneLine:'+lstwbserAuReneLine);
        if(!lstwbserAuReneLine.isEmpty()) {
            String wbserAuReneLineStr = JSON.serialize(lstwbserAuReneLine);
            if(quotId != null && wbserAuReneLineStr != null)
                autoRenewalQuote(quotId, wbserAuReneLineStr);
        }
        
    }
    
    public static void autoRenewalQuote (String QuoteId, String updateAutoRenewalQuoteList) {
        List<ARIICPQCalls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine = (List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateAutoRenewalQuoteList, List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>.class);
        ARIICPQCalls wbcbmq = new ARIICPQCalls();
        if(!Test.isRunningTest()) {ARIICPQCalls.UpdateDeleteAutoRenewalQuote(QuoteId, lstwbserAuReneLine);}
        System.debug('wbcbmq.CPQReturnedMsg:'+ARIICPQCalls.CPQReturnedMsg);
        System.debug('QuoteId:'+QuoteId);
        if(ARIICPQCalls.CPQReturnedMsg != '') {
            BigMachines__Quote__c bmq  = new BigMachines__Quote__c();
            bmq.Id                     = QuoteId;
            bmq.SalesOperations__c     = True;
            System.debug('bmq:'+bmq);         
            Update bmq;
        }
            
    }
    
    global void finish(Database.BatchableContext BC){
    	if(UserInfo.getUserName().contains('internalsystem.user@move.com')){
   			 AsyncApexJob[] jobs = [SELECT Id, JobItemsProcessed from AsyncApexJob 
                                    where JobType='BatchApex' AND (status='Processing' OR status = 'Queued' OR status = 'Holding')
                                    AND ApexClassId IN (Select Id from ApexClass where Name = 'ARIIQuoteCreationSchedulable' OR Name = 'ARIIQuoteSubmitBatch')]; //crm-2516
            if (jobs==null || jobs.size()==0) { 
            ARIIQuoteCreationSchedulable ARschBatch = new ARIIQuoteCreationSchedulable();
                Datetime dtt = System.now().addMinutes(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ARIIBatchJobRecAR'+dtt, sch, ARschBatch);
            }
    	}
    }

}