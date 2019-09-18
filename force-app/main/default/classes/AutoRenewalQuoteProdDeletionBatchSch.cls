//Name        : AutoRenewalQuoteProdDeletionBatchSch
//Description : This Batch deletes Quote Products which are Oversold and updates the Quotes to Rejected for all auto renewable assets which are oversold.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteProdDeletionBatchSch implements Schedulable{
    
    global set<ID> BMQIdset = New set<ID>();
    global set<ID> AcctIdset = New set<ID>();
    global set<ID> AsstIdset = New set<ID>();
    
    global void execute(SchedulableContext sc) {
        
        for(BigMachines__Quote_Product__c bmqp: [Select Id, BigMachines__Quote__r.Id, Asset__r.Id, Account_Id__c from BigMachines__Quote_Product__c 
                    where Need_Manual_Renew__c = True and BigMachines__Quote__r.BigMachines_Quote_Type__c = 'Auto-Renew']){       
                BMQIdset.add(bmqp.BigMachines__Quote__r.Id);
                AsstIdset.add(bmqp.Asset__r.Id);
                AcctIdset.add(bmqp.Account_Id__c);
                
        }
        
        // Deleting Oversold Quote
        if(!BMQIdset.isEmpty()) {
            AutoRenewalQuoteAssetBatch QuoteBatch = new AutoRenewalQuoteAssetBatch(BMQIdset, AcctIdset, AsstIdset); 
            database.executebatch(QuoteBatch,50);
        }
        
        /*
        // Deleting Oversold Quote Products
        if(!BMQIdset.isEmpty()) {
            AutoRenewalDeleteQuoteProdBatch QuoteProdBatch = new AutoRenewalDeleteQuoteProdBatch(BMQIdset); 
            database.executebatch(QuoteProdBatch,1);
        }
        
        //Updating the Quotes to Rejected.
        for(BigMachines__Quote__c bmq: [Select Id from BigMachines__Quote__c where BigMachines__Status__c = 'In Progress' AND BigMachines_Quote_Type__c = 'Auto-Renew' and BigMachines__Line_Items__c < 1]) {
            BMQUpdset.add(bmq.Id);
        }
        
        // Deleting Oversold Quote
        if(!BMQUpdset.isEmpty()) {
            AutoRenewalQuoteDeletionBatch QuoteBatch = new AutoRenewalQuoteDeletionBatch(BMQUpdset); 
            database.executebatch(QuoteBatch,50);
        }
        */
        
    }
    
}