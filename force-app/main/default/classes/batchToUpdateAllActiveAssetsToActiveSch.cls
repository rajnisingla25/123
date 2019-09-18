global with sharing class batchToUpdateAllActiveAssetsToActiveSch implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        ID BatchId = Database.executeBatch(new batchToUpdateAllActiveAssetsToActiveMLS(), 200);
    } 
}