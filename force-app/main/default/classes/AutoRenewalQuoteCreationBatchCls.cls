global class AutoRenewalQuoteCreationBatchCls implements Database.Batchable<sObject>, Database.AllowsCallouts{
   global String Query;
   global String assetId;
   //global date rendat =system.today().addDays(-60);
   global AutoRenewalQuoteCreationBatchCls(){
            // Query=q;
             //rendat= system.today().addDays(-60);
             //system.debug('####'+rendat);
          
   
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
   
         Query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,';
             query += 'Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,';
             query += 'End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,';
             query += 'Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Asset_Type__c=\'Parent\' and Auto_Renewal__c=\'Yes\' and Haircut_Asset__c=false';
             //query += ' and End_Date__c=N_DAYS_AGO:60';// ';// and id=\'02ig0000005qMQc\'';
             //End_Date__c>=N_DAYS_AGO:65 and   End_Date__c<=N_DAYS_AGO:60 and Renewal_Start_Date__c=null and Renewal_End_Date__c=null
             query += ' End_Date__c<=N_DAYS_AGO:15 and End_Date__c>=N_DAYS_AGO:60';
             if(assetId==null){
             query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Asset_Type__c=\'Parent\' and Auto_Renewal__c=\'Yes\' and  Renewal_Start_Date__c=null and Renewal_End_Date__c=null and Haircut_Asset__c=false and End_Date__c<=N_DAYS_AGO:15 and End_Date__c>=N_DAYS_AGO:60';
             } else {
             query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Id =:assetId';
             }
      system.debug(assetId+'####'+query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Asset> scope){
                       Map<Id,Map<Id,String>> AccountAssetIds = new Map<Id,Map<Id,String>>();
                       Set<Id> setAccountIds = new Set<Id>();
                       Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
                       for(Asset ass:scope){
                       if(setAccountIds.size()<2){ //Need to change size here
                       setAccountIds.add(ass.AccountId);
                       }
                       }
                       if(setAccountIds.size()>0){
                       //createOpportunity(setAccountIds);
                       }
                       List<Asset> lstupdateAsset = new List<Asset>();
                       for(Asset ass:[Select id,name,Parent_Asset__c,AccountId,Product2Id,Start_Date__c,End_Date__c,Renewal_Start_Date__c,Renewal_End_Date__c from Asset where Asset_Type__c='Parent' and Auto_Renewal__c='Yes' and Status!='Expired' and AccountId=:setAccountIds]){
                       if(ass.AccountId!=null){
                       if(AccountAssetIds.containskey(ass.AccountId)){
                       Map<Id,String> assetIds = AccountAssetIds.get(ass.AccountId);
                       assetIds.put(ass.id,'');
                       AccountAssetIds.put(ass.AccountId,assetIds);
                       } else {
                       Map<Id,String> assetIds = new Map<Id,String>();
                       assetIds.put(ass.id,'');
                       AccountAssetIds.put(ass.AccountId,assetIds);
                       }
                       if(ass.End_Date__c!=null){ass.Renewal_Start_Date__c = (ass.End_Date__c+1);}
                       ass.Renewal_End_Date__c   = (ass.End_Date__c.addMonths(6));
                       lstupdateAsset.add(ass);
                       }
                       }
                       for(Opportunity opp:[Select Id,Name,AccountId from Opportunity where Is_Renewal_Opp__c=true and AccountId=:setAccountIds]){
                       mapAccountOpportunityId.put(opp.AccountId,opp.id);
                       }
                       for(Id assids:AccountAssetIds.keyset()){
                       Id oppId=null;
                       if(mapAccountOpportunityId.containskey(assids)){oppId=mapAccountOpportunityId.get(assids);}
                       Map<Id,String> assetIds = AccountAssetIds.get(assids);
                       System.debug('$$$$$$ '+assetIds);
                       WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
                       if (!Test.isRunningTest()){
                       wscbm.CreateQuote(null,null,assids,oppId,null,'Auto Renewal','renew',true,true,assetIds);
                       }
                       }
                       if(lstupdateAsset.size()>0){
                       update lstupdateAsset;
                       }
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