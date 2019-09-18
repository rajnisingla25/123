//Name        : AutoRenewalAssetResetBatch
//Description : This Batch resets the Assets which are ready for next Auto Renewal Schedule.
//Frequencey  : Every Day
//Author      : Pallavi Tammana
//History     : CRM-1776: Updated condition in Query to check for Follow Up Status instead of Renewed Status.

global class AutoRenewalAssetResetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    
    global set<ID> AsstIdset = new set<ID>();
    global String Query;
       
    global AutoRenewalAssetResetBatch(set<ID> AsstIds) {
        AsstIdset.addall(AsstIds);
    }
     //CRM-1776: Updated condition in Query to check for Follow Up Status instead of Renewed Status.
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ AsstIdset:'+AsstIdset);
        Date d = System.today().addMonths(-1);
        System.debug('d:'+d);
        Query = 'Select Id, Follow_Up_Status__c, KickoutReason__c, Renewal_Status__c, Renewal_Type__c, AutoRenewQuoteProduct__c, Reason__c, Reason_Details__c,AutoRenewalPicked__c, FollowUpStatus_Bkup__c, KickoutReason_Bkup__c, QuoteProductId_Bkup__c, Reason_Bkup__c, ReasonDetail_Bkup__c from Asset where Start_Date__c =: d AND Follow_Up_Status__c = \'Renewed\' AND Status = \'Active\' AND Id IN :AsstIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
    
        List<Asset> AsstUpdList = new List<Asset>();
                
        for(Asset asst: scope) {
                            
            //Copying the values to Backup fields for reporting   
            asst.FollowUpStatus_Bkup__c    = asst.Follow_Up_Status__c;
            asst.KickoutReason_Bkup__c     = asst.KickoutReason__c;
            asst.QuoteProductId_Bkup__c    = asst.AutoRenewQuoteProduct__c;
            asst.Reason_Bkup__c            = asst.Reason__c;
            asst.ReasonDetail_Bkup__c      = asst.Reason_Details__c;
            
            //Resetting values for next cycle of Auto Renewals   
            asst.AutoRenewalPicked__c      = false;
            asst.Follow_Up_Status__c       = '';
            asst.Reason__c                 = '';
            asst.Reason_Details__c         = '';
            asst.KickoutReason__c          = '';
            asst.AutoRenewQuoteProduct__c  = '';
            asst.Renewal_Type__c           = 'Manual';
            asst.Renewal_Status__c         = '';
            
            AsstUpdList.add(asst);

        }
        
        if(!AsstUpdList.isEmpty()) {
            update AsstUpdList;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {          
    }
}