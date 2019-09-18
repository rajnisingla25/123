//Name        : ARIIOneTimeBatch
//Description : One Time Manual Job for all Auto Renewal Phase II.
//Frequencey  : Manual for Testing
//Author      : Pallavi Tammana

global class ARIIOneTimeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global set<ID> AcctIdset = new set<ID>();
    global String sessionId;
    global Date dt;
    
    global ARIIOneTimeBatch(set<ID> AcctIds) {
         AcctIdset.addall(AcctIds);
         
         AutoRenewalNextEndDate__c oneTimeDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal One Time');
         if(oneTimeDate != null) {
            dt = oneTimeDate.Next_Month_Start_Date__c;
        }
     }
     
    global String session(String user, String pwd) {
        if(sessionId == null) {
            ARIICPQCalls wcbm = new ARIICPQCalls();
            sessionId = ARIICPQCalls.GetSessionId(null,null);
            System.debug('sessionId:'+sessionId);
        }
        return sessionId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
                
        String Query = 'SELECT ID, BigMachines__Account__c FROM BigMachines__Quote__c WHERE BigMachines__Account__c IN :AcctIdset AND BigMachines_Quote_Type__c  = \'Auto-Renew\' AND BigMachines__Status__c = \'In Progress\' AND (Collections__c = True OR SalesOperations__c = True) AND LastModifiedDate !=: dt ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {  
        
        Set<Id> setAsstId = new Set<Id>();
        List<Asset> lstAsstUpd = new List<Asset>();
        Set<Asset> setAsstUpd = new Set<Asset>();
        String QuoteId = null;                
        
         for(BigMachines__Quote_Product__c bmqp: [select Id, Asset__c, Asset__r.Id, Asset__r.External_ID__c, 
                                BigMachines__Quote__r.BigMachines__Account__c, 
                                BigMachines__Quote__r.BigMachines__Account__r.Id, 
                                BigMachines__Quote__r.BigMachines__Transaction_Id__c
                                from BigMachines__Quote_Product__c 
                                where  BigMachines__Quote__r.Id IN :scope
                                AND Asset__r.Follow_Up_Status__c <> 'Manual Renewal' 
                                AND Asset__r.Follow_Up_Status__c <> 'Will Not Renew'
                                AND Asset__r.Follow_Up_Status__c <> 'Pending Renewal'
                                AND Asset__r.Status = 'Active' AND  Asset__r.AutoRenewQuoteProduct__c != Null
                                AND Asset__r.AR_Nightly_Update__c = NULL
                                AND BigMachines__Quote__r.LastModifiedDate !=: dt]){
            if(bmqp.Asset__c != null) {
                setAsstId.add(bmqp.Asset__c);
                QuoteId = bmqp.BigMachines__Quote__r.BigMachines__Transaction_Id__c;
                
                Asset asst = new Asset();
                asst.Id = bmqp.Asset__r.Id;
                asst.AR_Nightly_Update__c = System.Today();
                setAsstUpd.add(asst);                           
            }            
            System.debug('setAsstId:'+setAsstId);
        }
        
        // Update Asset Nightly Price Date to today
        if(!setAsstUpd.isEmpty()) {
            lstAsstUpd.addAll(setAsstUpd);
            update lstAsstUpd;
        }
    
    }   
    
    global void finish(Database.BatchableContext BC) {
        
         List<BigMachines__Quote_Product__c> QPList = [select Id, Asset__c, Asset__r.External_ID__c, 
                                BigMachines__Quote__r.BigMachines__Account__c
                                from BigMachines__Quote_Product__c 
                                where  BigMachines__Quote__r.BigMachines_Quote_Type__c  = 'Auto-Renew' 
                                AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress' 
                                AND (BigMachines__Quote__r.Collections__c = True OR BigMachines__Quote__r.SalesOperations__c = True)
                                AND Asset__r.Follow_Up_Status__c <> 'Manual Renewal' 
                                AND Asset__r.Follow_Up_Status__c <> 'Will Not Renew'
                                AND Asset__r.Follow_Up_Status__c <> 'Pending Renewal'
                                AND Asset__r.Status = 'Active' AND  Asset__r.AutoRenewQuoteProduct__c != Null
                                AND Asset__r.AR_Nightly_Update__c = NULL
                                AND BigMachines__Quote__r.LastModifiedDate !=: dt];
        
        //Scheduling further Jobs to process remaining records.                       
        if(!QPList.isEmpty()) {       
            ARIIOneTimeSchedulable ARschBatch = new ARIIOneTimeSchedulable();
            Datetime dtt = System.now().addMinutes(2);
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('ARIIOneTimeBatchJobRecAR'+dtt, sch, ARschBatch);
        }
        
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'ARIIOneTimeBatchJob%' and State = 'DELETED' and nextfiretime = null limit 10];
        If (listCronTriggerAsset.size() > 0) {
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++) { System.abortJob(listCronTriggerAsset[i].Id); }
        }
    
    }
}