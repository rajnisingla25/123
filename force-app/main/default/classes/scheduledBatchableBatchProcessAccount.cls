global class scheduledBatchableBatchProcessAccount implements Schedulable{
     global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled

           // We now call the batch class to be scheduled
        BatchProcessAccount b = new BatchProcessAccount(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,25);
     }
  }