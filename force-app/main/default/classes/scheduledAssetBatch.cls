global class scheduledAssetBatch implements Schedulable{
     global void execute(SchedulableContext sc) {
        BatchAssetAmountUpdate b = new BatchAssetAmountUpdate();       
        database.executebatch(b,1);
     }
  }