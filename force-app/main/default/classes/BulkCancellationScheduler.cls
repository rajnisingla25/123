public class BulkCancellationScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        // Variables to be set from custom setting
        Boolean runJob = true;
        Integer batchSize = 30;
        Integer minutesToRunJobAgain = 1;
        
        Schedule_Batch_Setting__c bulkCancellation = Schedule_Batch_Setting__c.getValues('Bulk Cancellation');
        if (bulkCancellation != null) {
            runJob = bulkCancellation.Is_Running__c;
            batchSize = Integer.valueOf(bulkCancellation.Batch_Size__c);
            minutesToRunJobAgain = Integer.valueOf(bulkCancellation.Execution_Min__c);
        }
        
        if (runJob) {
            Set<Id> accountIds = new Set<Id>();
            Integer totalRecords = 0;
            for (AggregateResult result : [SELECT Asset__r.AccountId accountId, count(Id)cnt FROM Bulk_Process__c WHERE Status__c='New' AND Asset__c != null 
                                            AND RecordType.Name='Cancellation' GROUP BY Asset__r.AccountId LIMIT :batchSize]) {
                if (totalRecords < batchSize) {
                    totalRecords += Integer.valueOf(result.get('cnt'));
                    accountIds.add(String.valueOf(result.get('accountId')));
                }
                else {
                    break;
                }
            }
            if (accountIds.size()>0) {
                Map<Id, Bulk_Process__c> bulkProcessRecs = new Map<Id, Bulk_Process__c>();
                for (Bulk_Process__c rec : [SELECT Id FROM Bulk_Process__c WHERE Account__c IN :accountIds AND Status__c='New']) {
                    rec.Status__c = 'Processing';
                    bulkProcessRecs.put(rec.Id, rec);
                }
                update bulkProcessRecs.values();
                
                BulkCancellationBatch batch = new BulkCancellationBatch(bulkProcessRecs.keySet());
                Database.executeBatch(batch, batchSize);
                
                // Re-Schedule this Job again after <minutesToRunJobAgain> minute(s)
                Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'BulkCancellation%' AND nextfiretime != null];
                if (rcount<2  || Test.isRunningTest()){
                    BulkCancellationScheduler bcs = new BulkCancellationScheduler();
                    Datetime dtt = System.now().addMinutes(minutesToRunJobAgain).addSeconds(1);
                    String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                    system.schedule('BulkCancellation'+dtt, sch, bcs);
                    
                    for (CronTrigger ct: [SELECT Id FROM CronTrigger WHERE State = 'DELETED' AND nextfiretime = null LIMIT 20]) {
                        System.abortJob(ct.Id); 
                    }
                }    
                // Re-scheduling code ends here
            }
        }
    }
}