global class DuplicateContactCleanBatch_Schedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DupContactCleanBatch(), 1000);
    }
}