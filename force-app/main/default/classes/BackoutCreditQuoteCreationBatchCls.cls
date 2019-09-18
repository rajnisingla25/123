global class BackoutCreditQuoteCreationBatchCls implements Database.Batchable<sObject>, Database.AllowsCallouts{
   global String Query;
   //global date rendat =system.today().addDays(-60);
    global Set<Id> theAssetIdsToProcess = new Set<Id>();
    global Map<Id,Id> theAccountOpportunity = new Map<Id,Id>();
    global Map<Id,Id> theAccountOpportunityId = new Map<Id,Id>();
    global Map<Id,Map<Id,Id>> theAccountAsset = new Map<Id,Map<Id,Id>>();
   global BackoutCreditQuoteCreationBatchCls(){
          //  if(theAssetIdsToProcess.size()>0){
                     //  query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Line_Type__c,Ultimate_Parent__c from Asset where Asset_Type__c=\'Parent\' and LastModifiedDate=Today and Product2.ProductCode=\'SHOWCASE\' and Account.Type=\'Broker\' and Line_Type__c!=\'Cancel\'';
           query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Line_Type__c,Ultimate_Parent__c from Asset where Asset_Type__c=\'Parent\' and Status=\'Active\'';
            query += ' AND Id IN :theAssetIdsToProcess';
          //  }
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('####'+query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Asset> scope){
                       Set<Id> setAccountIds = new Set<Id>();
                       Set<Id> setAssetIds = new Set<Id>();
                       Map<Id,Map<Id,String>> mapAgentAccountIds = new Map<Id,Map<Id,String>>();
                       Set<Id> setAgentAssetIds = new Set<Id>();
                       Set<Id> setOfficeIds = new Set<Id>();
                       Set<Id> setAgentAccountIds = new Set<Id>();
                       Set<Id> setMLSAccountIds = new Set<Id>();
                       Set<Id> setMLSOfficeAccountIds = new Set<Id>();
                       List<Asset> cancellstAsset = new List<Asset>();
                       
                       for(Asset ast:scope){
                       setAccountIds.add(ast.AccountId);
                       setAssetIds.add(ast.Id);
                       }
                       System.debug(setAssetIds+'$$$$$');

                           Set<String> prodCode = new Set<String>();
       					 prodCode.add('ADVANTAGE');
        				prodCode.add('SHOWCASE');




      for(Asset ast:[Select Id,AccountId, MLS_Set__c ,MLS_Set__r.MLS__c ,name from Asset where
                     Ultimate_Parent_Id_Text__c=:setAssetIds and Asset_Type__c='Participant'
                     and (Product2.ProductCode='SHOWCASE' OR Product2.ProductCode='ADVANTAGE')
                     and Status='Active' and Line_Type__c='Add']){//and Account.Type='Realtor Office'
      //setMLSOfficeAccountIds.add(ast.AccountId);
      setOfficeIds.add(ast.MLS_Set__c);
      setMLSAccountIds.add(ast.MLS_Set__r.MLS__c);
      }
        
      //Set<Id> setAllOfficeToParenIds = new Set<Id>();
      for(Asset ast:[Select Id,AccountId, MLS_Set__c ,MLS_Set__r.MLS__c ,name from Asset where
                     Ultimate_Parent_Id_Text__c=:setAssetIds and Asset_Type__c='Fulfill To'
                     and (Product2.ProductCode='ADVANTAGE')
                     and Status='Active' and Line_Type__c='Add']){//and Account.Type='Realtor Office'
      setAgentAccountIds.Add(ast.AccountId);
      }
      System.debug('Office Ids'+setMLSOfficeAccountIds);
      for(MLS__c mlls:[SELECT Id,Name,Agent__c,Agent__r.Name,Office__c
                       FROM MLS__c WHERE Id =:setOfficeIds AND Status__c = 'Active']){ //AND Office__c = :setMLSOfficeAccountIds
      setAgentAccountIds.add(mlls.Office__c);
      }
      //SELECT Id,Name,Agent__c,Agent__r.Name,Office__c FROM MLS__c WHERE MLS__c = '001Z000000yWcq4' AND Office__c = '001Z000000yVwOx' AND Status__c = 'Active'
      //Set<Id> setAgentAccIds = new Set<Id>();
      for(Account_Relationship__c accRelation:[Select Id,Name, Child_Account__c from Account_Relationship__c where Parent_Account__c=:setAgentAccountIds and Child_Account__r.Status__c='Active' and Active__c = true and Child_Account__r.Type='Realtor Agent']){  
             Map<Id,String> setAccountAssetIds = new Map<Id,String>();
             //setAgentAccIds.add(accRelation.Child_Account__c);
      mapAgentAccountIds.put(accRelation.Child_Account__c,setAccountAssetIds);
             }
      for(Asset asst:[Select Id,Name,Line_Type__c,Status,AccountId  from Asset where
                      Ultimate_Parent_Id_Text__c!=:setAssetIds and
                      AccountId=:mapAgentAccountIds.keyset() and Asset_Type__c='Parent'
                      and (Product2.ProductCode='SHOWCASE' OR Product2.ProductCode='ADVANTAGE')
                      and Account.Type='Realtor Agent' and Line_Type__c!='Cancel' and Status='Active']){
      System.debug('Working till here!');
      if(mapAgentAccountIds.containskey(asst.AccountId)){
      System.debug('Working till here!');
      Map<Id,String> setAccountAssetIds = mapAgentAccountIds.get(asst.AccountId);
      setAccountAssetIds.put(asst.id,'');
      mapAgentAccountIds.put(asst.AccountId,setAccountAssetIds);
         } 
      }   
      
      if(mapAgentAccountIds.keyset().size()>0){
      for(Id idds:mapAgentAccountIds.keyset()){
      //System.debug(theAccountOpportunity+'Working till here!'+idds+' ** '+mapAgentAccountIds+'KKKK'+mapAgentAccountIds.get(idds));
      if(mapAgentAccountIds.containskey(idds)){
      System.debug('Working till here!');
      if(mapAgentAccountIds.get(idds).size()>0){
      System.debug('Working till here!');
      Opportunity theOpportunity;
      //Map<Id,Id> mapAccountOppId = new Map<Id,Id>();
        Id RecordTypeId = [Select Id,Name from RecordType where DeveloperName='Inside_Sales'].Id;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Account acct:[Select Id,name,type from Account where Id=:idds]){
        //acct.addError('This is working!');
        theOpportunity = new Opportunity(
          Name = 'The Opportunity',
          StageName = 'Prospecting',
          CloseDate = system.today(),
          AccountId = acct.Id,
          Account_Type__c = 'Short',
          //Lead__c = leadId,
          //campaignId = campaignId,
          RecordTypeId = RecordTypeId
          
        );
        System.debug('Working fine!');
        lstOpportunity.add(theOpportunity);
        }
        if(lstOpportunity.size()>0){
          //insert lstOpportunity;
          //System.debug('Working fine!'+lstOpportunity);
          for(Opportunity opp:lstOpportunity){
          //System.debug('Working fine!'+opp.id);
          //theAccountOpportunity.put(opp.AccountId,opp.Id);
          }
          }
          
          
       
       if(mapAgentAccountIds.containskey(idds)){
       //theAccountOpportunityId.put(idds,theAccountOpportunity.get(idds));
       theAccountAsset.put(idds,mapAgentAccountIds.get(idds));
       System.debug('Working till here!');
       WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
       //wscbm.CreateQuote(null,null,idds,theAccountOpportunity.get(idds),null,'Backout','cancel',true,true,mapAgentAccountIds.get(idds));
       wscbm.CreateQuote(null,null,idds,null,null,'Backout','cancel',true,true,mapAgentAccountIds.get(idds));

       }
       }
       }
       }
      }   
                 
   }
   
  
   global void finish(Database.BatchableContext BC){
        if(theAccountOpportunityId.keyset().size()>0){
        System.debug('Working till here!'+theAccountOpportunityId);
        for(Id iiidd:theAccountOpportunityId.keyset()){
        /*  BackoutQuoteCreationCalloutBatchCls theBatchProcess = new BackoutQuoteCreationCalloutBatchCls();
        theBatchProcess.theAccountId = iiidd;
        theBatchProcess.theOpportunityId = theAccountOpportunityId.get(iiidd);
        theBatchProcess.theAgentAssetMap = theAccountAsset.get(iiidd);
        System.debug('Asset Ids : '+theBatchProcess.theOpportunityId);
        Id theBatchProcessId = Database.executeBatch(theBatchProcess);
        system.debug('TRACE: AssetTrigger - theBatchProcessId - ' + theBatchProcessId);*/
          }
          }
          }

}