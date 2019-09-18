public class Z_ErrorQuoteScheduler implements Schedulable {
    list<string> lockedQuotesList = new list<string>();
    string orderId;
    string sfdcAccountId;
    string zBillingAccountId;
    public Z_ErrorQuoteScheduler(list<string> lockedQuotesList, string orderId, string sfdcAccountId, string zBillingAccountId){
        this.lockedQuotesList.addAll(lockedQuotesList);
        this.orderId = orderId;
        this.sfdcAccountId = sfdcAccountId;
        this.zBillingAccountId = zBillingAccountId;
        system.debug('------lockedQuotesList---->'+lockedQuotesList);
    }
    public void execute(SchedulableContext sc){
        // again we are calling sendtoZbilling method when the quotes are get locked
        if(lockedQuotesList != null && lockedQuotesList.size() > 0)
           // Z_queueableSendToZBilling.sendtoZbilling(lockedQuotesList);
        String scheduledJobId = System.enqueueJob(new Z_queueableSendToZBilling(orderId, lockedQuotesList));
        // schedule order update scheduler 
        Z_scheduleProcessInputAndSendToZBilling.scheduleProcessInputAndSendToZBilling(60, orderId, new List<String>(), sfdcAccountId, zBillingAccountId);

    }
    
    public static void scheduleErrorQuoteScheduler(integer seconds, list<string> lockedQuotesList, string orderId, string sfdcAccountId, string zBillingAccountId){
        
        DateTime now = datetime.now().addSeconds(seconds);
        String scheduledDateTime = '';
        scheduledDateTime += now.second();
        scheduledDateTime += ' ' + now.minute();
        scheduledDateTime += ' ' + now.hour();
        scheduledDateTime += ' ' + now.day();
        scheduledDateTime += ' ' + now.month();
        scheduledDateTime += ' ' + '?';
        scheduledDateTime += ' ' + now.year();

        String scheduledTaskName = 'ErrorQuoteScheduler scheduled on ' + DateTime.now() + System.currentTimeMillis();
        String scheduledJobId = System.schedule(scheduledTaskName, scheduledDateTime, new Z_ErrorQuoteScheduler(lockedQuotesList, orderId, sfdcAccountId, zBillingAccountId));
        
    }
}