//Name        : ARIIAutoQuoteCreationBatch
//Description : This Batch creates quote for all auto renewable assets which are due for renewal in the following month.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class ARIIAutoQuoteCreationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    global String Query;
    global String assetId;
    global set<ID> AccountIDs = new set<ID>();
    global Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
    global String sessionId;
    global Date startDate;
    global Date endDate;
     
    
    global ARIIAutoQuoteCreationBatch (set<ID> AcctIDs,Map<Id,Id> mapAccntOpptyId){
        AccountIDs.addall(AcctIDs);
        mapAccountOpportunityId.putAll(mapAccntOpptyId);
        System.debug('AccountIDs:'+AccountIDs);            
        System.debug('mapAccountOpportunityId:'+mapAccountOpportunityId);
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
            
            
        }
                             
    }
    global String session(String user, String pwd) {
        if(sessionId == null) {
           
            ARIICPQCalls wcbm = new ARIICPQCalls();
            sessionId = ARIICPQCalls.GetSessionId(null,null);
            
        }
        return sessionId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('$$$$$$ AccountIDs:'+AccountIDs);
        Query = 'SELECT ID, Account.OwnerId FROM Account WHERE ID IN :AccountIDs ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Asset> lstupdateAsset = new List<Asset>();
        Map<Id,String> AssetIds = New Map<Id,String>();
        Set<Asset> updateAsstSet = new Set<Asset>();
        Set<Asset> AsstSet = new Set<Asset>();
        List<AutoRenewal__c> Exclusionlst = AutoRenewal__c.getAll().values();
        Set<AutoRenewal__c> Exclusionset = New Set<AutoRenewal__c>(Exclusionlst);
        String AcctOwnrPrfNm = [Select Id, Profile_Name__c from User Where Id = :scope[0].OwnerId].Profile_Name__c;
        Set<Id> AsstIdSet = new Set<Id>();
        Integer submitDays;
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            submitDays = Integer.valueOf(nextEndDate.SubmitDays__c);
        }
        Date dt = System.today() + submitDays;
        //Date dt = System.today() + submitDays;
        Date currentTodaysDate = System.today(); // CRM-2537
        Date currentSubmitdaysDate = System.today().AddDays(submitDays); // CRM-2537
        Integer currentSubmitMonth = currentSubmitdaysDate.month(); // CRM-2537
        startDate = currentSubmitdaysDate.toStartOfMonth();  // CRM-2537
        endDate = startDate.addMonths(1).addDays(-1); // CRM-2537
                
        List<Asset> AssetData = [SELECT id, name, Parent_Asset__c, AccountId, Account.OwnerId, Product2Id, 
                                 Product2.ProductCode, Status, Product2.Orderable__c,Asset_Stage__c, Quantity, 
                                 Follow_Up_Status__c, Auto_Renewal__c, BOP_Code__c, Email__c,End_Date__c, Lead_Type__c, 
                                 Line_Type__c, List_Price__c, Market_Zip__c,Market__c, Market_Tier__c, Renewal_Type__c,
                                 Ultimate_Parent__c, Last_Order_Activity_Date__c, Start_Date__c, Total_Net__c, KickoutReason__c,
                                 (Select Id,name from Asset_AR_Associations__r)
                                 FROM Asset WHERE Asset_Type__c='Parent' AND Status = 'Active' 
                                    
                                 AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = true AND Renewal_Type__c = 'Auto'
                                 
                                 AND Follow_Up_Status__c <> 'Manual Renewal' 
                                 AND Follow_Up_Status__c != 'Will Not Renew'
                                 AND (AutoRenewQuoteProduct__c = null OR AutoRenewQuoteProduct__c = '')
                                 AND End_Date__c >=: currentSubmitdaysDate AND End_Date__c <=: endDate 
                                 AND AccountId = :scope[0].ID AND (not Inflight_Quote__c like '%Renew%') ORDER BY AccountId];
        System.debug('AssetData:'+AssetData);
        System.debug('startDate:'+startDate);
        System.debug('endDate:'+endDate);
        session(null,null); 
        System.debug('sessionId:'+sessionId);
        
       
        for(Asset Assetloop : AssetData) {
           system.debug('Size --> '+Assetloop.Asset_AR_Associations__r.size());
	       system.debug('product orderable --> '+Assetloop.Product2.Orderable__c);

            if(Assetloop.Product2.Orderable__c && Assetloop.Asset_AR_Associations__r.size()>0) { 
                if((Assetloop.Total_Net__c != 0  || Assetloop.Product2.ProductCode == 'FIVESTREET' || Assetloop.Product2.ProductCode =='SELLERLEADBUNDLE')) {
                    System.debug('AcctOwnrPrfNm:'+AcctOwnrPrfNm);
                    AutoRenewal__c Exclusions = AutoRenewal__c.getInstance(AcctOwnrPrfNm);
                    System.debug('Exclusions:'+Exclusions);
                    //Verifying Product Exclusions using Custom Settings                       
                    If(Exclusions != NULL && Exclusions.ProductCodes__c != NULL){
                        if(!Exclusions.ProductCodes__c.contains(Assetloop.Product2.ProductCode)){
                            AsstSet.add(Assetloop);
                            System.debug('AsstSet:'+AsstSet);
                        }                            
                    }else{                           
                        AsstSet.add(Assetloop);
                        System.debug('AsstSet:'+AsstSet);
                    }
                }
            }
        }
        
        for(Asset Assetloop: AsstSet) {
                AssetIds.put(Assetloop.id,'');
                if(Assetloop.Last_Order_Activity_Date__c == null)
                   Assetloop.Last_Order_Activity_Date__c =  Assetloop.Start_Date__c;
                updateAsstSet.add(Assetloop);
            System.debug('updateAsstSet:'+updateAsstSet);
        }
                       
        System.debug('AssetIds:'+AssetIds);
        //Create Quote
        if (!Test.isRunningTest() && !AssetIds.isEmpty()){
           
            ARIICPQCalls wscbm = new ARIICPQCalls();
            System.debug('sessionId:'+sessionId);
            if(sessionId != null){
            ARIICPQCalls.bmsessionid = sessionId;}
            ARIICPQCalls.CreateQuote(scope[0].ID,mapAccountOpportunityId.get(scope[0].ID),AssetIds);
       
       }
        
        //Update Assets
        if(!updateAsstSet.isEmpty()){
            lstupdateAsset.addall(updateAsstSet);
            update lstupdateAsset;
        }      
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('startDate:'+startDate);
        System.debug('endDate:'+endDate);
        set<Id> BMQIdset   = new set<Id>();
        Integer submitDays;
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            submitDays = Integer.valueOf(nextEndDate.SubmitDays__c);
        }
        Date dt = System.today() + submitDays;
        Date currentTodaysDate = System.today(); // CRM-2537
        Date currentSubmitdaysDate = System.today().AddDays(submitDays); // CRM-2537
        Integer currentSubmitMonth = currentSubmitdaysDate.month(); // CRM-2537
        startDate = currentSubmitdaysDate.toStartOfMonth();  // CRM-2537
        endDate = startDate.addMonths(1).addDays(-1); // CRM-2537
        List<Asset> AssetList = [SELECT id,(Select Id,name from Asset_AR_Associations__r) FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%') 
                               AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = true
                               AND Follow_Up_Status__c != 'Will Not Renew' AND Follow_Up_Status__c <> 'Manual Renewal'
                                
                               AND End_Date__c =: currentSubmitdaysDate AND (AutoRenewQuoteProduct__c = '' OR AutoRenewQuoteProduct__c = null)];
        //Scheduling further Jobs to process remaining records.  
        Boolean runQuoteCreationProcess = false;   
        for(Asset ast:AssetList){  
        if(ast.Asset_AR_Associations__r.size()>0){
        runQuoteCreationProcess = true;
        }
        }                  
        if(!Test.isRunningTest()){
            if(AssetList.size()>0 && runQuoteCreationProcess) {       
                ARIIQuoteCreationSchedulable ARschBatch = new ARIIQuoteCreationSchedulable();
                Datetime dtt = System.now().addMinutes(2);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ARIIBatchJobRecAR'+dtt, sch, ARschBatch);
                system.debug('--- inside asset list --> '+assetList);
            } else { //Scheduling Job to submit the Quotes
                Date dt1 = System.today() + submitDays+1;
                for(BigMachines__Quote__c bmq: [Select Id from BigMachines__Quote__c
                                                    where BigMachines_Quote_Type__c = 'Auto-Renew' 
                                                    AND BigMachines__Status__c = 'In Progress'
                                                    AND CreatedDate=today]){       
                    System.debug('bmq.Id:'+bmq.Id);
                 if(bmq.Id != null){
                        BMQIdset.add(bmq.Id);}
                    }
               if(!BMQIdset.isEmpty()) {
                ARIIQuoteSubmitBatch QuoteBatch = new ARIIQuoteSubmitBatch(BMQIdset);
                database.executebatch(QuoteBatch,1);
                }
                system.debug('--- inside the else loop --> '+BMQIdset);
            }
             
        }
        
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'ARIIBatchJob%' and State = 'DELETED' and nextfiretime = null limit 10];
        If (listCronTriggerAsset.size() > 0) {
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++) { System.abortJob(listCronTriggerAsset[i].Id); }
        }                     
        
    }
}