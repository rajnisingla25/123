global class Commissions_AssetRenewalBatchSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        Commissions_AssetRenewalBatch commsOTH = new Commissions_AssetRenewalBatch(); 
        database.executebatch(commsOTH,200);
    }
}