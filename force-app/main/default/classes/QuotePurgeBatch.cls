public class QuotePurgeBatch implements Database.Batchable<sObject>
{
	public QuotePurgeBatch()
    {
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
	{
        String query = 'Select Id, (Select BigMachines__Quote__c From BigMachines__BigMachines_Quote_Products__r) From BigMachines__Quote__c Where NotEligibleForBundling__c = TRUE AND CreatedDate <= YESTERDAY ';
        //query += 'AND Id NOT IN (Select BigMachines__Quote__c From BigMachines__Quote_Product__c)';
        return Database.getQueryLocator(query);
   	}

   	public void execute(Database.BatchableContext BC, List<BigMachines__Quote__c> lstQuote)
   	{
        List<BigMachines__Quote__c> lstBigMachinesQuoteToDelete = new List<BigMachines__Quote__c>();
        
        if(!lstQuote.isEmpty())
        {
            for(BigMachines__Quote__c bigMachinesQuote :lstQuote)
            {
                if(bigMachinesQuote.BigMachines__BigMachines_Quote_Products__r.isEmpty())
                	lstBigMachinesQuoteToDelete.add(bigMachinesQuote);
            }
        }
        
        if(!lstBigMachinesQuoteToDelete.isEmpty())
            delete lstBigMachinesQuoteToDelete;
    }
    
    public void finish(Database.BatchableContext BC)
    {
    }
}