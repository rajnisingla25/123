//****************************************************************************************
//Name          : ScheduleInvoiceBatchProcessing
//Date          : 2.22.2016
//Created by    : Stanley Sequeira
//Modified by   : 
//Description   : This Batch schedules the InvoiceBatchProcessing Batch Job
//               
// *****************************************************************************************
 
 global class ScheduleInvoiceBatchProcessing implements Schedulable{
     global void execute(SchedulableContext sc) {
    // We now call the batch class to be scheduled
        InvoiceBatchProcessing batch = new InvoiceBatchProcessing(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batch,1);
     }
  }