//Name        : AutoRenewalQuoteCreationSchedulable
//Description : Schedule Job for AutoRenewalQuoteCreationBatch.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class AutoRenewalQuoteCreationSchedulable implements Schedulable {
    global set<ID> AccountIDs = New set<ID>();
    global set<Id> BMQIdset   = new set<Id>();
    global set<Id> BMQUpdset  = new set<Id>();
    global set<Id> AsstIdset  = new set<Id>();
    global set<Id> AcctIdset  = new set<Id>();
    global Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();    
    
    global void execute(SchedulableContext sc) {
    
        Boolean autoCreateprocess = true;
        Boolean autoSubmitprocess = true;
        Boolean autoResetprocess  = true;
        //Boolean autoAcctProcess  = true;
        Date startDate;
        Date endDate;
        
        Schedule_Batch_Setting__c autoCreate = Schedule_Batch_Setting__c.getValues('Auto Renewal Quote Creation');
        Schedule_Batch_Setting__c autoSubmit = Schedule_Batch_Setting__c.getValues('Auto Renewal Quote Submission');
        Schedule_Batch_Setting__c autoReset  = Schedule_Batch_Setting__c.getValues('Auto Renewal Reset Asset');
        //Schedule_Batch_Setting__c acctProcess = Schedule_Batch_Setting__c.getValues('Auto Renewal Account Process');
        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
            
        if(autoCreate != null){autoCreateprocess = autoCreate.Is_Running__c;}
        if(autoSubmit != null){autoSubmitprocess = autoSubmit.Is_Running__c;}
        if(autoReset  != null){autoResetprocess  = autoReset.Is_Running__c;}
        //if(acctProcess != null){autoAcctProcess = acctProcess.Is_Running__c;}
        
        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }
        
        // Flag to enable the Job using Custom Settings
        if(autoCreateprocess) {
            set<ID> AccountOrdIDs = New set<ID>();
            Set<Opportunity> OppSet = new Set<Opportunity>();
            List<Opportunity> OppList = new List<Opportunity> ();
            Set<Asset> AsstSet = new Set<Asset>();
            List<Asset> AsstList = new List<Asset>();
            Integer i = 0;
                    
            for(Asset AssetData : [SELECT id, AccountId, Product2.Orderable__c FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%') 
                                   AND Account.Account_Sub_Type__c='Customer' 
                                   AND Account.Auto_Renewal__c=true AND Product2.Auto_Renewal__c =true
                                   AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                   AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')   
                                   AND End_Date__c >=: startDate AND End_Date__c <=: endDate
                                   ORDER BY AccountId]){
                                   //AND End_Date__c = NEXT_MONTH ORDER BY AccountId]){
           //System.debug('AssetData:'+AssetData);
           System.debug('startDate:'+startDate);
           System.debug('endDate:'+endDate);
                if(i <= 100) {
                    AccountIDs.add(AssetData.AccountId);
                    if(AssetData.Product2.Orderable__c && AssetData.AccountId != null) {
                        AccountOrdIDs.add(AssetData.AccountId);
                        i++;
                    }
                    AssetData.Follow_Up_Status__c = '';
                    AssetData.KickoutReason__c    = '';
                    AsstSet.add(AssetData);
                }
           } // Creating Opportunity for each Account
            For(ID IDloop : AccountOrdIDs){
                Opportunity theOpportunity = new Opportunity(
                    Name = 'The Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = system.today(),
                    AccountId = IDloop,
                    Is_Renewal_Opp__c = true,
                    Account_Type__c = 'Renewal');
                    
                oppSet.add(theOpportunity);
                
            }
             if(!oppSet.isEmpty()){
                OppList.addall(oppSet);
                Insert OppList;                
            }
            
            if(!AsstSet.isEmpty()){
                AsstList.addall(AsstSet);
                Update AsstList;
            }
            
            if(!AccountOrdIDs.isEmpty()) {
                System.debug('OppList:'+OppList);              
                for(Opportunity opp : OppList) {
                    mapAccountOpportunityId.put(opp.AccountId, opp.id);
                }
                System.debug('mapAccountOpportunityId:'+mapAccountOpportunityId);
            }               
            //if(!AccountIDs.isEmpty()) {          
                //AutoRenewalQuoteCreationBatch AssetBatch = new AutoRenewalQuoteCreationBatch(AccountIDs,mapAccountOpportunityId); 
                //database.executebatch(AssetBatch,1);
            //}
            if(!AccountIDs.isEmpty()) {          
                AutoRenewalQuoteCreationBatchNew AssetBatch = new AutoRenewalQuoteCreationBatchNew(AccountIDs,mapAccountOpportunityId); 
                database.executebatch(AssetBatch,1);
            }
        
        }
        // Flag to enable the Job using Custom Settings
        if(autoSubmitprocess) {
        
            //Code for Auto Submission based on Asset End Date on Quote.
            Integer submitDays = 5;
            if(autoSubmit != null){submitDays = Integer.valueOf(autoSubmit.Execution_Time_hr__c);}
            System.debug('submitDays:'+submitDays);
            Date d = System.today() + submitDays + 1;
            Set<Id> bmqSet = new Set<Id> ();
            
            for(BigMachines__Quote__c bmq: [Select Id from BigMachines__Quote__c
                                                where BigMachines_Quote_Type__c = 'Auto-Renew' 
                                                AND BigMachines__Status__c = 'In Progress' 
                                                AND EarliestQuoteProductStartDate__c = :d]){       
                System.debug('bmq.Id:'+bmq.Id);
                if(bmq.Id != null)
                    bmqSet.add(bmq.Id);
            }
            
            if(!bmqSet.isEmpty()) BMQIdset.addAll(bmqSet);
            
            if(!BMQIdset.isEmpty()) {
                AutoRenewalQuoteSubmitBatch QuoteBatch = new AutoRenewalQuoteSubmitBatch(BMQIdset);
                database.executebatch(QuoteBatch,1);
            }
            
            //Updating Quotes without Quote Products as 'Rejected' for reporting purposes.
            for(BigMachines__Quote__c bmq: [Select Id from BigMachines__Quote__c where BigMachines__Status__c = 'In Progress' AND BigMachines_Quote_Type__c = 'Auto-Renew' and BigMachines__Line_Items__c < 1]) {
                BMQUpdset.add(bmq.Id);
            }
            
            // Deleting Oversold Quote
            if(!BMQUpdset.isEmpty()) {
                AutoRenewalQuoteDeletionBatch QuoteBatch = new AutoRenewalQuoteDeletionBatch(BMQUpdset); 
                database.executebatch(QuoteBatch,50);
            }
        }
        
        if(autoResetprocess) {
            //CRM-1776: Updated condition in Query to check for Follow Up Status instead of Renewed Status.
            Date d = System.today().addMonths(-1);
            for(Asset asst: [Select Id, Follow_Up_Status__c, KickoutReason__c, AutoRenewQuoteProduct__c, 
                            Reason__c, Reason_Details__c,AutoRenewalPicked__c, FollowUpStatus_Bkup__c, 
                            KickoutReason_Bkup__c, QuoteProductId_Bkup__c, Reason_Bkup__c, ReasonDetail_Bkup__c 
                            from Asset where Start_Date__c =: d AND Follow_Up_Status__c = 'Renewed' AND Status = 'Active']) {
                AsstIdset.add(asst.Id);
            }
            
            // Updating Asset
            if(!AsstIdset.isEmpty()) {
                AutoRenewalAssetResetBatch AssetBatch = new AutoRenewalAssetResetBatch(AsstIdset); 
                database.executebatch(AssetBatch,50);
            }
            
        }/*
        // Auto Renewal Phase II job
        if(autoAcctProcess){
            for(Asset AssetData : [SELECT id, AccountId, Product2.Orderable__c FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%') 
                                   AND Account.Account_Sub_Type__c='Customer' 
                                   AND Account.Auto_Renewal__c=true AND Account.AR_Default_Renewal_Term__c = null AND Product2.Auto_Renewal__c =true
                                   AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                   AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')   
                                   AND End_Date__c >=: startDate AND End_Date__c <=: endDate
                                   ORDER BY AccountId limit 20]){
                               
               AcctIdset.add(AssetData.AccountId);
           }
        
            ARAccountUpdateBatch AcctBatch = new ARAccountUpdateBatch(AcctIdset);
            database.executebatch(AcctBatch,5);
        }*/
    }
}