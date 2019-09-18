global class CleanupCronTriggers implements Schedulable {
   global void execute(SchedulableContext SC) {
        List<CronTrigger> cronsToDelete = [Select Id, State from CronTrigger where State = 'DELETED' Limit 125];
        for(CronTrigger ct : cronsToDelete){
            System.abortJob(ct.Id);
        }
    }
}