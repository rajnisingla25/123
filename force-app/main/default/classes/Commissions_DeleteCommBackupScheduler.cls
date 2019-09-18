public class Commissions_DeleteCommBackupScheduler implements schedulable{
  public void execute(SchedulableContext SC){
       Database.executeBatch(new Commissions_DeleteCommsBackupBatch());        
    }
}