public class Commissions_PayoutAdjBatchSch{
    /**
    global class Commissions_PayoutAdjBatchSch implements Schedulable {
        global void execute(SchedulableContext sc) {
            Commissions_PayoutAdjBatch commsPAB = new Commissions_PayoutAdjBatch(); 
            database.executebatch(commsPAB,50);
        }
    }
    **/
}