global class AutoBrokerAccountCreation_Schedule implements Schedulable
{
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AutoBrokerAccountBatch(), 1);
    }
}