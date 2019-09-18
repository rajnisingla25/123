public class EmployeeDashboardAccountDeleteJobSch implements Schedulable {
    public void execute(SchedulableContext sc) {
        // CRM-4046: Updated batch size to 1 
        ID BatchId = Database.executeBatch(new EmployeeDashboardAccountDeleteJob(), 1);
    } 
}