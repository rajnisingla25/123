public class WelcomeEmailGenerationBatchSch implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        set<Id> AcctIdset  = new set<Id>();
        for(Account AcctData: [Select id, Welcome_email_URL_Last_run_date__c, WelcomeURLGeneration__c, Type, SSO_Email__c, Advertiserid__c, Party_ID__c 
                                from Account where (Type = 'Broker' Or Type = 'Realtor Agent') and Advertiserid__c != null 
                                And MLS_Set_Id__c <>null AND (NOT MLS_Set_Id__c LIKE '%B1CA,B2CA,B3CA,B4CA,B5CA,B6CA%') And WelcomeURLGeneration__c = False And
                                (Welcome_email_URL_Last_run_date__c = null or Welcome_email_URL_Last_run_date__c <= N_DAYS_AGO:60) limit 20000]) {
            if(AcctData.SSO_Email__c == null) {
                AcctIdset.add(AcctData.Id);
            }
        }
        
        Integer btSize = Integer.valueof(label.WelcomeURLBatchSize);
        if(!AcctIdset.isEmpty()) {
                WelcomeEmailGenerationBatch AcctBatch = new WelcomeEmailGenerationBatch(AcctIdset);
                database.executebatch(AcctBatch,btSize);
        }     
        //ID BatchId = Database.executeBatch(new WelcomeEmailGenerationBatch(), btSize);
    } 
}