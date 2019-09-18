//Name        : AutoRenewalQuoteAssetBatch 
//Description : This Batch deletes quote Products for all auto renewable assets which are oversold.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteAssetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> BMQIdset = new set<ID>();
    global set<ID> AcctIdset = new set<ID>();
    global set<ID> AsstIdset = new set<ID>();
    global String Query;
       
    global AutoRenewalQuoteAssetBatch(set<ID> BMQIds, Set<ID> AcctIds, Set<Id> AsstIds) {
        BMQIdset.addall(BMQIds);
        AcctIdset.addall(AcctIds);
        AsstIdset.addall(AsstIds);
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ BMQIdset:'+BMQIdset);
        Query = 'SELECT ID FROM BigMachines__Quote__c WHERE ID IN :BMQIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> scope) {

        Set<BigMachines__Quote__c> bmqIdSet = new Set<BigMachines__Quote__c>();
        List<BigMachines__Quote__c> bmqIdList = new List<BigMachines__Quote__c>();
        Set<Asset> AsstSet = new Set<Asset>();
        List<Asset> AsstList = new List<Asset>();
        Date startDate;
        Date endDate;
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }
        
        for(BigMachines__Quote__c bmq :  scope) {
            bmqIdSet.add(bmq);
        }
        
        for(Asset asst: [Select Id, Follow_Up_Status__c, Renewal_Type__c, KickoutReason__c
             from Asset where Id IN: AsstIdset]) {
            
            asst.Follow_Up_Status__c = 'Manual Renewal';
            asst.AutoRenewalPicked__c = true;
            asst.Renewal_Type__c = 'Manual';
            asst.KickoutReason__c = 'Oversold Market';
            asst.AutoRenewQuoteProduct__c = '';
            AsstSet.add(asst);
        
        }
        //CRM-1305 - Auto Renew Quote creation job sets Non AR assets to Manual Renewal
        for(Asset Assetloop: [Select Id, Follow_Up_Status__c, Renewal_Type__c, KickoutReason__c
             from Asset where AccountId IN: AcctIdset AND Id NOT IN: AsstIdset AND Asset_Type__c='Parent' AND Status = 'Active' AND Product2.Auto_Renewal__c =true AND End_Date__c >=: startDate AND End_Date__c <=: endDate]) {
             
            Assetloop.Follow_Up_Status__c = 'Manual Renewal';
            Assetloop.AutoRenewalPicked__c = true;
            Assetloop.Renewal_Type__c = 'Manual';
            Assetloop.KickoutReason__c = 'Forced Manual Renewal';
            Assetloop.AutoRenewQuoteProduct__c = '';
            AsstSet.add(Assetloop);
        }
        
        if(!AsstSet.isEmpty()) {
            AsstList.addall(AsstSet);
            Update AsstList;
        }
        
        if(!bmqIdSet.isEmpty()) {
            bmqIdList.addall(bmqIdSet);
            delete bmqIdList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {            
        
    
    }
    

}