public class Commissions_PayoutChangeBatchSch{
    /**
    global class Commissions_PayoutChangeBatchSch implements Schedulable {
        global void execute(SchedulableContext sc) {
            Commissions_PayoutChangeBatch commsPCB = new Commissions_PayoutChangeBatch (); 
            database.executebatch(commsPCB,50);
        }
    }
    **/
}