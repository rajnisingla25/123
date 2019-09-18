global class AutoRenewalOpportunityCreationBatchCls implements Database.Batchable<sObject>, Database.AllowsCallouts{
   global String Query;
   //global date rendat =system.today().addDays(-60);
   global AutoRenewalOpportunityCreationBatchCls(){
            // Query=q;
             //rendat= system.today().addDays(-60);
             //system.debug('####'+rendat);
             Query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,';
             query += 'Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,';
             query += 'End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,';
             query += 'Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Asset_Type__c=\'Parent\' and Auto_Renewal__c=\'Yes\' and Haircut_Asset__c=false';
             //query += ' and End_Date__c=2012-11-06 and Renewal_Start_Date__c=null and Renewal_End_Date__c=null';// and id=\'02ig0000005qMQc\'';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('####'+query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Asset> scope){
                       Map<Id,Set<Id>> AccountAssetIds = new Map<Id,Set<Id>>();
                       Set<Id> setAccountIds = new Set<Id>();
                       for(Asset ass:scope){
                       if(setAccountIds.size()<2){
                       setAccountIds.add(ass.AccountId);
                       }
                       }
                      createOpportunity(setAccountIds);
                       
          // update scope;
   }
   Public void createOpportunity(Set<Id> AccIds) {
        List<Opportunity> lstOpportunity = new List<Opportunity>(); 
            try {
            for(Id AccId:AccIds){
                Opportunity theOpportunity = new Opportunity(
                Name = 'The Opportunity',
                StageName = 'Prospecting',
                CloseDate = system.today(),
                AccountId = AccId,
                Is_Renewal_Opp__c = true,
                Account_Type__c = 'Renewal');
                lstOpportunity.add(theOpportunity); 
                }
        
        
        insert lstOpportunity;
        //return theOpportunity.Id;
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'An internal error occurred while processing your request. Please contact system administrator.'
        ));
        }
    
   // return null;
  }
  
   global void finish(Database.BatchableContext BC){
        Integer intervalMinutes = 5;
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        //System.schedule(AutoRenewalQuoteCreationSchedulable  + '-' + now.format(), cronString, new JobRunner(intervalMinutes));
       AutoRenewalQuoteCreationSchedulable  m = new AutoRenewalQuoteCreationSchedulable();
       String sch = '20 30 8 10 2 ?';
      // String jobID = system.schedule('Auto Quote Creation'+nextRunTime.minute()+''+nextRunTime.hour(), cronString, m);
   }

}