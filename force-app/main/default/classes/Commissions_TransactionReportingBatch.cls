global class Commissions_TransactionReportingBatch implements Database.Batchable<sObject>{
    
    //START METHOD
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Commissions_and_Commissions_Backup__c> lstcommBackupmappingData = Commissions_and_Commissions_Backup__c.getAll().values();
        
        Map<String,String> mapCommANDBackupData = new Map<String,String>();
        for(Commissions_and_Commissions_Backup__c commBackup : lstcommBackupmappingData){
            mapCommANDBackupData.put(commBackup.Commissions_API_FieldName__c,commBackup.Commission_Backup_API_FieldName__c);   
        }
        
        String query = 'SELECT ';
        if(mapCommANDBackupData.size() > 0){
            for(String commissionAPIFieldName : mapCommANDBackupData.keySet()){
                query += commissionAPIFieldName + ', ';                
            }
        }
        
        query = query.substring(0, query.length() - 2);
        query += ' FROM Commission__c WHERE Related_to_Quota__r.Payment_Status__c  != \'Payroll Processed\' ';
        
        System.debug('$$$$$$$$'+query);
        
        return Database.getQueryLocator(query);
        /*[SELECT Id,Employee_Number__c,Related_to_Quota__r.Payment_Status__c,Related_to_Quota__c,Related_to_Quota__r.User__r.Name,Related_to_Quota__r.Employee_Number__c,
                                         Related_to_Quota__r.Period_Name__c,
                                         Line_Type__c,RecordTypeId,RecordType.Name,Related_to_Asset__c,Related_to_Asset__r.Account.Party_ID__c,Related_to_Asset__r.Account.Customer_Id__c,
                                         Related_to_Asset__r.Account.Name,Related_to_Asset__r.Start_Date__c,Related_to_Asset__r.End_Date__c,
                                         Related_to_Asset__r.Last_Order_Activity_Date__c,Related_to_Asset__r.CreatedDate,Related_to_Asset__r.Cancellation_Date__c,
                                         Related_to_Asset__r.Cancellation_Reason__c,Product__c,Product__r.Name,Related_to_Asset__r.Market__c,Total_Commissionable_Amount__c,
                                         Final_Commission_Amount__c,Signing_AE__c,Signing_AE__r.Name,User_Team__c,Commission_Split__c,Commission__c FROM Commission__c Where Related_to_Quota__r.Payment_Status__c != 'Payroll Processed']
        */
                
    } 

    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Commission__c> scope) { 
        if(scope.size()>0){
           Commissions_TranscReportingBatchHndlr transactionHandler = new Commissions_TranscReportingBatchHndlr(scope);           
        }      
    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) 
    {
    }

}