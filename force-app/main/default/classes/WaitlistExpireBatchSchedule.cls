global class WaitlistExpireBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      WaitlistExpireBatch WLBatch = new WaitlistExpireBatch();
      database.executebatch(WLBatch,1);
   }
}