public class Commissions_SnapshotScheduler implements schedulable{
  public void execute(SchedulableContext SC){
       Database.executeBatch(new Commissions_TransactionReportingBatch());        
    }
}

  

 /*public void execute(SchedulableContext SC){
         runprocess();
    }
     @future(callout = true)
    public static void runprocess(){
      Database.executeBatch(new Commissions_TransactionReportingBatch());         
    }*/