global class Commissions_OtherProductsBatchSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        Commissions_OtherProductsBatch commsOTH = new Commissions_OtherProductsBatch(); 
        database.executebatch(commsOTH,200);
    }
}