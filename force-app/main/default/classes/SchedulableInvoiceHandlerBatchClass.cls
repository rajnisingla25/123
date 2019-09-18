global class SchedulableInvoiceHandlerBatchClass implements Schedulable{
 

global void execute(SchedulableContext SC) {
    
Database.executeBatch(new InvoiceHandlerBatchClass(null,FALSE),50);
 
 
   }
 }