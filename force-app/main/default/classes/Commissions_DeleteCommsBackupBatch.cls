global class Commissions_DeleteCommsBackupBatch implements Database.Batchable<sObject>{
    
    //START METHOD    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'Select Id,Quota_Number__c From Commissions_Backup__c Where Quota_Number__r.Payment_Status__c  = \'Payroll Processed\' AND CreatedDate <= LAST_N_DAYS:2';
        return Database.getQueryLocator(query);
    }
	
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Commissions_Backup__c> lstCommissionBackup) { 
        system.debug('scope=='+lstCommissionBackup.size());
        if(lstCommissionBackup.size() > 0){
            delete lstCommissionBackup;
        }
    }
    
     //FINISH METHOD 
    global void finish(Database.BatchableContext BC) 
    {
    }
}