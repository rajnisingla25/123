//Name        : ARIIAssettPriceUpdateBatch
//Description : This Batch calls CPQ for Nightly Price update on Assets
//Frequencey  : Every Month
//Author      : Pallavi Tammana
//History     : CRM-3258: SFDC tasks for AR Price Info and additional new fields


global class ARIIAssettPriceUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global set<ID> AcctIdset = new set<ID>();
    global String Query;
    global BigMachineUrls__c bmURL;
       
    global ARIIAssettPriceUpdateBatch(set<ID> AcctIds) {
        AcctIdset.addall(AcctIds);                
    }
    
     global ARIIAssettPriceUpdateBatch(set<ID> AcctIds, BigMachineUrls__c bURL) {     //CRM-2456
        AcctIdset.addall(AcctIds);    //CRM-2456
        bmUrl = bURL;      //CRM-2456
         
     }//CRM-2456
    
    
     
     global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('$$$$$$ AcctIdset:'+AcctIdset);
        Query = 'SELECT ID, Account.OwnerId FROM Account WHERE ID IN :AcctIdset ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
    
        Map<id,Asset> AsstUpdMap = new Map<id,Asset>();
        Map<Id, String> AcctbmqIdMap = new Map<Id, String>();
        String AsstConfigoptions = null;
        String QuoteId = null;
        Decimal term = null;
        String options = null;
        for(BigMachines__Quote__c bmq: [select Id, BigMachines__Transaction_Id__c, BigMachines__Account__c, Name from BigMachines__Quote__c 
                                where BigMachines__Account__c =: scope[0].ID order by CreatedDate asc limit 1]){
            AcctbmqIdMap.put(bmq.BigMachines__Account__c, bmq.BigMachines__Transaction_Id__c);
            QuoteId = bmq.BigMachines__Transaction_Id__c;
        }    
                
        for(Asset asst: [Select id, name, Parent_Asset__c, ConfigOptions__c, AccountId, Account.AR_Default_Renewal_Term__c, Product2Id, Product2.ProductCode, Product2.Orderable__c
                        FROM Asset WHERE Asset_Type__c = 'Parent' AND Status = 'Active' AND AccountId = :scope[0].ID
                        AND Follow_Up_Status__c != 'Pending Renewal' AND Follow_Up_Status__c != 'Will Not Renew' 
                        AND Follow_Up_Status__c != 'Renewed' AND Follow_Up_Status__c != 'Manual Renewal'
                        AND Renewal_Type__c = 'Auto' 
                        AND AutoRenewalPicked__c = True AND AutoRenewQuoteProduct__c = Null AND AR_Nightly_Update__c != Today
                        ORDER BY ID]) {
            
            //AND Product2.Auto_Renewal__c  = True AND Product2.Orderable__c  = True
            AsstUpdMap.put(asst.id,asst);//CRM-2398
            
            term = asst.Account.AR_Default_Renewal_Term__c;
            //CRM-3258: Sending ConfigOptions to CPQ
            if(asst.ConfigOptions__c != null){
                options = asst.ConfigOptions__c;
                if(options.contains(';')){AsstConfigoptions=options.replace(';','~'); }
                else
                    AsstConfigoptions=options;
                System.debug('AsstConfigoptions'+AsstConfigoptions);
            }
        }
        
        //Price Update call to CPQ
        if (!Test.isRunningTest() && !AsstUpdMap.keySet().isEmpty()){
             
                ARIICPQCalls wscbm;
                if(bmURL != null){
                    wscbm = new ARIICPQCalls(bmURL);  //CRM-2456   
                }else{
                    wscbm = new ARIICPQCalls(); //CRM-2456
                }
                String returnResponse = ARIICPQCalls.AssetNightlyPriceUpdate(QuoteId, 'plainSave_t', AsstUpdMap.keySet(), AsstConfigoptions);
                if(!returnResponse.contains('Exception')){
                ARIICPQCalls.AssetNightlyPriceUpdate(QuoteId, 'autoRenewAssetExport', AsstUpdMap.keySet(), AsstConfigoptions);
                }
            
        }
        
        //CRM-2398
        for(Asset_AR_Association__c ar: [Select AR_Oversold_Flag__c, Asset_Id__c from asset_ar_association__c where Asset_Id__c IN: AsstUpdMap.keySet()]){
            if(AsstUpdMap.containsKey(ar.Asset_Id__c)) {            
                Asset asst = AsstUpdMap.get(ar.Asset_Id__c); //CRM-2398
                asst.AR_Nightly_Update__c = System.Today();
                AsstUpdMap.put(asst.id,asst);//CRM-2398  
            }
        }
        
        // Update Asset Nightly Price Date to today
        update AsstUpdMap.values(); //CRM-2398 
    }
    
    global void finish(Database.BatchableContext BC) {
        Map<Id,String> AcctAsstIds = New Map<Id,String>();
        Set<Id> AsstIdSet = new Set<Id>();
        Set<Asset> AsstSet = new Set<Asset>();
        List<Asset> AsstList = new List<Asset>();
        Date jobDate;
        
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
        if(nextEndDate != null) {
            jobDate    = nextEndDate.Job_Run_Date__c;
        }
        
        List<Asset> AssetList = [SELECT id FROM Asset WHERE Asset_Type__c='Parent' AND AutoRenewalPicked__c = true
                               AND Status = 'Active' AND Follow_Up_Status__c != 'Will Not Renew' AND Follow_Up_Status__c != 'Manual Renewal'
                               AND Follow_Up_Status__c != 'Renewed' AND Follow_Up_Status__c != 'Pending Renewal'
                               AND AR_Nightly_Update__c != Today
                               AND Renewal_Type__c = 'Auto' 
                               AND AutoRenewQuoteProduct__c = Null ]; //AND AR_Oversold_Flag__c = False];                               
        //Scheduling further Jobs to process remaining records.                       
        if(!AssetList.isEmpty()) {
            AsyncApexJob[] jobs = [SELECT Id, JobItemsProcessed from AsyncApexJob 
                                    where JobType='BatchApex' AND (status='Processing' OR status = 'Queued' OR status = 'Holding')
                                    AND ApexClassId IN (Select Id from ApexClass where Name = 'ARIIAssettPriceUpdateBatch' OR Name = 'ARIIQuoteCreationSchedulable')]; //crm-2516
            if (jobs==null || jobs.size()==0) {       
                ARIIQuoteCreationSchedulable ARschBatch = new ARIIQuoteCreationSchedulable();
                Datetime dtt = System.now().addMinutes(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ARIIBatchJobRecAR'+dtt, sch, ARschBatch);
            }
        }
        else { //Update all the Assets of Oversold market Assets in the Account            
            AsyncApexJob[] jobs = [SELECT Id, JobItemsProcessed from AsyncApexJob 
                                    where JobType='BatchApex' AND (status='Processing' OR status = 'Queued' OR status = 'Holding')
                                    AND ApexClassId IN (Select Id from ApexClass where Name = 'ARIIAssettPriceUpdateBatch' OR Name = 'ARIIQuoteCreationSchedulable')]; //crm-2516
            if (jobs==null || jobs.size()==0) { 
            ARIIQuoteCreationSchedulable ARschBatch = new ARIIQuoteCreationSchedulable();
                Datetime dtt = System.now().addMinutes(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ARIIBatchJobRecAR'+dtt, sch, ARschBatch);
            }
            
        }
        
        //CRM-2264 Inserting error records when CPQ is flagging the assets as error assets. 
        List< Error__c > errorRecords = new List< Error__c>();
        List<Asset_AR_Association__c> arList = new List<Asset_AR_Association__c>();
        for(Asset_AR_Association__c ar: [Select id, Error_Description__c, Error_Flag__c, Asset_Id__c From Asset_AR_Association__c Where Error_Flag__c = true]){
            Error__c errRec = new Error__c();
            errRec.Name = 'ARIIAssettPriceUpdateBatch';
            errRec.entity_id__c = ar.asset_Id__c;
            errRec.Error_Description__c = ar.Error_Description__c;
            errRec.Interface_Name__c = 'ARIIAssettPriceUpdateBatch';
            errorRecords.add(errRec);
            ar.Error_Flag__c = False;
            arList.add(ar);
        }
        if(errorRecords.size()>0){
            Insert errorRecords;
        }
        if(arList.size()>0){ 
           update arList;
        }
        // End of CRM-2264 code. 
        
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'ARIIBatchJob%' and State = 'DELETED' and nextfiretime = null limit 10];
        If (listCronTriggerAsset.size() > 0) {
            For (Integer i = 0; i < listCronTriggerAsset.size(); i++) { System.abortJob(listCronTriggerAsset[i].Id); }
        }
                  
    }
}