global class ProcessOLIAssetJSONSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      Set<Id> theAssetIdsToProcess = new Set<Id>();
      List<Asset> lstAsset = [Select Id,Name,Fulfillment_Status__c,Status from Asset where Fulfillment_Status__c='Waiting to Process' and Status = 'In Active' limit 10000];
      for(Asset ast:lstAsset){
      ast.Fulfillment_Status__c = 'Pending Fulfillment';
      ast.Status = 'Active';
      }
     if(lstAsset.size()>0){
     update lstAsset;
     }
   }
}