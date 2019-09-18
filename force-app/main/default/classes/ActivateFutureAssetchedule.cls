global class ActivateFutureAssetchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
   try{
List<Asset> lstAssete = [Select Id,Name,Fulfillment_Status__c,Status,Line_Type__c from Asset where Status = 'Future Dated' and Asset_Type__c ='Parent' and Start_Date__c<=Tomorrow limit 10];
      for(Asset ast:lstAssete){
      ast.Fulfillment_Status__c = 'Fulfilled';
      ast.Status = 'Active';
      //ast.Line_Type__c = 'Cancel';
      }
     if(lstAssete.size()>0){
     update lstAssete;
     }
} catch(Exception ex){CatchExceptionProcessRemaining();  }

}
   
   Public void CatchExceptionProcessRemaining(){
   List<Asset> lstAssete = [Select Id,Name,Fulfillment_Status__c,Status,Line_Type__c from Asset where Status = 'Future Dated' and Asset_Type__c ='Parent' and  Start_Date__c<=Tomorrow limit 1];
      for(Asset ast:lstAssete){
      ast.Fulfillment_Status__c = 'Fulfilled';
      ast.Status = 'Active';
      //ast.Line_Type__c = 'Cancel';
update ast;
   }
   }
   }