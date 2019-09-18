public class WelcomeEmailGenerationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    // CRM-2700
    set<ID> AcctIdset = new set<ID>();
    public WelcomeEmailGenerationBatch(set<ID> AcctIds) {
        AcctIdset.addall(AcctIds);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
            
        String Query = 'Select id, Welcome_email_URL_Last_run_date__c, WelcomeURLGeneration__c, Type, SSO_Email__c, Advertiserid__c, Party_ID__c from Account where Id IN: AcctIdset';  
        Query += ' ' +label.WelcomeURLGenerationQuery; 
        System.debug('Query:'+Query);
        return Database.getQueryLocator(Query);
    } 
    
    public void execute(Database.BatchableContext BC, List<Account> accRecords){
        List<String> lstEssAct = new List<String>();
        Set<String> EssActSet = new Set<String>();
        SkipAccountTrigger.setSkipTrgTrue();
        for(Account a: accRecords){
            a.Welcome_email_URL_Last_run_date__c = system.date.today();
            a.WelcomeURLGeneration__c = True;
        }
        update accRecords;
    }    
    
    public void finish(Database.BatchableContext BC){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch finished');       
                
    }
    
}