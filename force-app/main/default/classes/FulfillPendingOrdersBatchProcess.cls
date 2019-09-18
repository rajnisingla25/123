global class FulfillPendingOrdersBatchProcess implements Database.Batchable<sObject> {
 
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'Select Id,Name,Line_type__c,Fulfillment_Status__c,Status from Asset where asset_Type__c=\'Parent\' and Fulfillment_Status__c=\'Waiting to Process\' and Fulfillment_Required__c=false order by LastmodifiedDate Desc limit 2';


    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Asset> scope) {
  Integer numbtype = System.now().Minute();
 
  for(Asset ast:scope){
  if(numbtype<61){
       ast.Fulfillment_Status__c = 'Pending Fulfillment';
      if(ast.Line_type__c!='Credit'){
      ast.Status = 'Active';
      }
      if(numbtype<10){
      numbtype = 100;
      }
      }
  }
  update scope;
  }
  global void finish(Database.BatchableContext BC) {
  }
}