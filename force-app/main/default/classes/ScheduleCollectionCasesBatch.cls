//****************************************************************************************
//Name          : ScheduleCollectionCasesBatch
//Date          : 2.22.2016
//Created by    : Stanley Sequeira
//Modified by   : 
//Description   : This Batch schedules the CollectionCasesBatch Batch Job
//               
// *****************************************************************************************

global class ScheduleCollectionCasesBatch implements Schedulable{
     global void execute(SchedulableContext sc) {
    // We now call the batch class to be scheduled
        CollectionCasesBatch batch = new CollectionCasesBatch(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batch,1);
     }
  }