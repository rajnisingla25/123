//Name        : ARIIQuoteCreationSchedulable
//Description : Schedule Job for all Auto Renewal Phase II.
//Frequencey  : First of every month
//Author      : Pallavi Tammana
//History     : CRM-3263: SFDC tasks for backup process for additional new fields

global class ARIIQuoteCreationSchedulable implements Schedulable {
    // CRM-3596 - Commented all instance variables.
    /*
    global set<ID> AccountIDs = New set<ID>();
    global set<Id> BMQIdset   = new set<Id>();
    global set<Id> BMQUpdset  = new set<Id>();
    global set<Id> AsstIdset  = new set<Id>();
    global set<Id> AcctIdset  = new set<Id>();
    global set<Id> PrcAccset  = new set<Id>();
    global set<Id> PrcAccset1  = new set<Id>();
    global Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
    */

    global void execute(SchedulableContext sc) {

        Boolean autoResetprocess  = true;
        Boolean autoAcctProcess  = true;
        Boolean autoPriceUpdate  = true;
        Boolean autoAsstProcess  = true;
        Boolean autoQuoteCreate = true;
        Boolean runNextProcess = true;

        Date startDate;
        Date endDate;


        //Phase II
        Schedule_Batch_Setting__c acctProcess = Schedule_Batch_Setting__c.getValues('ARII Account Process');
        Schedule_Batch_Setting__c priceUpdate = Schedule_Batch_Setting__c.getValues('ARII Price Update');
        Schedule_Batch_Setting__c asstProcess = Schedule_Batch_Setting__c.getValues('ARII Asset Process');
        Schedule_Batch_Setting__c autoQuote = Schedule_Batch_Setting__c.getValues('ARII Quote Creation');
        Schedule_Batch_Setting__c autoReset  = Schedule_Batch_Setting__c.getValues('ARII Reset Asset');        

        AutoRenewalNextEndDate__c nextEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');

        if(autoReset  != null){autoResetprocess  = autoReset.Is_Running__c;}
        if(acctProcess != null){autoAcctProcess = acctProcess.Is_Running__c;}
        if(priceUpdate != null){autoPriceUpdate = priceUpdate.Is_Running__c;}
        if(asstProcess != null){autoAsstProcess = asstProcess.Is_Running__c;}
        if(autoQuote != null)  {autoQuoteCreate = autoQuote.Is_Running__c;}

        if(nextEndDate != null) {
            startDate    = nextEndDate.Next_Month_Start_Date__c;
            endDate      = nextEndDate.Next_Month_End_Date__c;
        }


        // Updating Account Default Renewal Term
        if(autoAcctProcess && runNextProcess){
            set<ID> AccountIDs = New set<ID>(); // CRM-3596 - Declared variable locally
            for(Asset AssetData : [SELECT id, AccountId, Product2.Orderable__c FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%')
                                   AND Account.Account_Sub_Type__c='Customer'
                                   AND Account.Auto_Renewal__c=true AND Account.AR_Default_Renewal_Term__c = null AND Product2.Auto_Renewal__c =true
                                   AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                   AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')
                                   AND End_Date__c >=: startDate AND End_Date__c <=: endDate
                                   ORDER BY AccountId]){
                if(AccountIDs.size()<1000){
                    AccountIDs.add(AssetData.AccountId);
                }
            }
            if(!AccountIDs.isEmpty()) {
                ARIIAccountUpdateBatch AcctBatch = new ARIIAccountUpdateBatch(AccountIDs);
                database.executebatch(AcctBatch,50);
                runNextProcess = false;
            }
        }

        //Checking the eligibility of Asset for Auto Renewals
        if(autoAsstProcess && runNextProcess) {
            set<ID> AccountIDs = New set<ID>(); // CRM-3596 - Declared variable locally
            Set<Asset> AsstSet = new Set<Asset>();
            List<Asset> AsstList = new List<Asset>();
            for(Asset AssetData : [SELECT id, AccountId, Product2.Orderable__c FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%')
                                   AND Account.Account_Sub_Type__c='Customer'
                                   AND Account.Auto_Renewal__c=true AND Product2.Auto_Renewal__c =true
                                   AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = false
                                   AND (Commerce_Group__c <> 'Broker Marketing Solution' AND Commerce_Group__c <> 'Agent Marketing Solution')
                                   AND End_Date__c >=: startDate AND End_Date__c <=: endDate
                                   ORDER BY AccountId]){
                if(AccountIDs.size()<1000) {
                    AccountIDs.add(AssetData.AccountId);
                    
                }
            }

            if(!AccountIDs.isEmpty()) {
                system.debug('--- accounts --> '+AccountIDs.size());
                ARIIAssetUpdateBatch AssetBatch = new ARIIAssetUpdateBatch(AccountIDs);
                database.executebatch(AssetBatch,50);
                runNextProcess = false;
            }
        }

        

        //Auto Quote Creation and submission of Asset
        if(autoQuoteCreate && runNextProcess) {
            set<ID> AccountIDs = New set<ID>(); // CRM-3596 - Declared variable locally
            set<ID> AccountOrdIDs = New set<ID>();
            Set<Opportunity> OppSet = new Set<Opportunity>();
            List<Opportunity> OppList = new List<Opportunity> ();
            Set<Asset> AsstSet = new Set<Asset>();
            List<Asset> AsstList = new List<Asset>();
            Integer i = 0;
            Integer submitDays;

            AutoRenewalNextEndDate__c asstEndDate = AutoRenewalNextEndDate__c.getValues('Auto Renewal End Date');
            if(asstEndDate != null) {
                submitDays = Integer.valueOf(asstEndDate.SubmitDays__c);
            }
            Date dt = System.today() + submitDays;
            //Date dt = System.today() + submitDays;
            Date currentTodaysDate = System.today(); // CRM-2537
            Date currentSubmitdaysDate = System.today().AddDays(submitDays); // CRM-2537
            Integer currentSubmitMonth = currentSubmitdaysDate.month(); // CRM-2537
            startDate = currentSubmitdaysDate.toStartOfMonth();  // CRM-2537
            endDate = startDate.addMonths(1).addDays(-1); // CRM-2537

            for(Asset AssetData : [SELECT id, AccountId, Product2.Orderable__c,(Select Id,name from Asset_AR_Associations__r) FROM Asset WHERE Asset_Type__c='Parent' AND (not Inflight_Quote__c like '%Renew%')
                                   AND Renewal_Type__c = 'Auto'
                                   AND Follow_Up_Status__c != 'Will Not Renew'
                                   AND Follow_Up_Status__c <> 'Manual Renewal'
                                   AND Status = 'Active' AND Fulfillment_Status__c = 'Fulfilled' AND AutoRenewalPicked__c = true
                                   AND (AutoRenewQuoteProduct__c = null OR AutoRenewQuoteProduct__c = '')
                                   AND End_Date__c =: currentSubmitdaysDate
                                   ORDER BY AccountId]){
                                   //AND End_Date__c = NEXT_MONTH ORDER BY AccountId])
           
           System.debug('startDate:'+startDate);
           System.debug('endDate:'+endDate);
           if(AssetData.Asset_AR_Associations__r.size()>0){
            System.debug('AssetData:'+AssetData);
                if(i <= 100) {
                    AccountIDs.add(AssetData.AccountId);
                    if(AssetData.Product2.Orderable__c && AssetData.AccountId != null) {
                        AccountOrdIDs.add(AssetData.AccountId);
                        i++;
                    }
                }
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
            
            Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>(); // CRM-3596 - Declared variable locally
            if(!AccountOrdIDs.isEmpty()) {
                System.debug('OppList:'+OppList);
                for(Opportunity opp : OppList) {
                    mapAccountOpportunityId.put(opp.AccountId, opp.id);
                }
                System.debug('mapAccountOpportunityId:'+mapAccountOpportunityId);
            }

            if(!AccountIDs.isEmpty()) {
                ARIIAutoQuoteCreationBatch AssetBatch = new ARIIAutoQuoteCreationBatch(AccountIDs,mapAccountOpportunityId);
                database.executebatch(AssetBatch,1);
                runNextProcess = false;
            } else{
                set<Id> BMQIdset   = new set<Id>(); // CRM-3596 - Declared variable locally
                Date dt1 = System.today() + submitDays+1;
                for(BigMachines__Quote__c bmq: [Select Id from BigMachines__Quote__c
                                                    where BigMachines_Quote_Type__c = 'Auto-Renew' 
                                                    AND BigMachines__Status__c = 'In Progress'
                                                    AND CreatedDate=today and SalesOperations__c  = false and Collections__c = false]){       
                    System.debug('bmq.Id:'+bmq.Id);
                    if(bmq.Id != null){
                        BMQIdset.add(bmq.Id);
                    }
                }
                if(!BMQIdset.isEmpty()) {
                    runNextProcess = false;
                    AsyncApexJob[] jobs = [SELECT Id, JobItemsProcessed from AsyncApexJob 
                                    where JobType='BatchApex' AND (status='Processing' OR status = 'Queued' OR status = 'Holding')
                                    AND ApexClassId IN (Select Id from ApexClass where Name = 'ARIIQuoteCreationSchedulable' OR Name = 'ARIIQuoteSubmitBatch')]; //crm-2516
                    if (jobs==null || jobs.size()==0) { 
                        ARIIQuoteSubmitBatch QuoteBatch = new ARIIQuoteSubmitBatch(BMQIdset);
                        database.executebatch(QuoteBatch,1);
                    }
               }
               system.debug('--- inside the else loop --> '+BMQIdset);
            }
           
        }
          //For Reset the Asset and Bkup previous Renewal
        if(autoResetprocess && runNextProcess) {
            //CRM-1776: Updated condition in Query to check for Follow Up Status instead of Renewed Status.
            //CRM-3263: SFDC tasks for backup process for additional new fields
            //CRM-3743: Run Asset Reset batch for Assets with Start date < today - reset dates
            Date d = System.today().addMonths(Integer.valueof(autoReset.Assetresttime__c));
            set<Id> AsstIdset  = new set<Id>(); // CRM-3596 - Declared variable locally
            for(Asset asst: [Select Id, Follow_Up_Status__c, KickoutReason__c, AutoRenewQuoteProduct__c,
                            Reason__c, Reason_Details__c,AutoRenewalPicked__c, FollowUpStatus_Bkup__c,
                            KickoutReason_Bkup__c, QuoteProductId_Bkup__c, Reason_Bkup__c, ReasonDetail_Bkup__c
                            from Asset where Start_Date__c <= :d AND Follow_Up_Status__c = 'Renewed' AND Status = 'Active']) {
                if(AsstIdset.size()<1000){
                    AsstIdset.add(asst.Id);
                }
            }

            // Updating Asset
            if(!AsstIdset.isEmpty()) {
                ARIIAssetResetBatch AssetBatch = new ARIIAssetResetBatch(AsstIdset);
                database.executebatch(AssetBatch,50);
                runNextProcess = false;
            }

        }
        system.debug(''+autoPriceUpdate+runNextProcess);
        //Asset Nightly Price Update
        if(autoPriceUpdate && runNextProcess) {
            system.debug('inside-->');
            Set<ID> AccountIds = new Set<ID>(); //CRM-2456
            List<Asset_AR_Association__c> ARNewList = new List<Asset_AR_Association__c>();
            Map<Id, String> AsstIdMap = new Map<Id, String>();
            Set<Id> ARIdSet = new Set<Id>();
            Integer i = 1;
            Integer j = 0;
            Integer k = 0;
            
            for(Asset asst: [Select id, name, External_ID__c, Parent_Asset__c, AccountId, Account.AR_Default_Renewal_Term__c, Product2Id, Product2.ProductCode, Product2.Orderable__c
                        FROM Asset WHERE Asset_Type__c = 'Parent' AND Status = 'Active' AND Follow_Up_Status__c != 'Pending Renewal'
                        AND Follow_Up_Status__c != 'Will Not Renew' AND Follow_Up_Status__c != 'Renewed' AND Follow_Up_Status__c != 'Manual Renewal'
                        AND AutoRenewalPicked__c = True AND AutoRenewQuoteProduct__c = Null    
                        AND renewal_Type__c = 'Auto'     
                        AND AR_Nightly_Update__c != Today
                        ORDER BY ID]) {           

                if(AccountIds.size() < 1000){
                   AccountIds.add(asst.AccountId); //CRM-2456                    
                }
            }          
             if(!accountIds.isEmpty()){ //CRM-2456
                 ARIIUtility.parallelProcessAccountsForPriceUpdate(accountIds); //CRM-2456
                 runNextProcess = false;
             } //CRM-2456           
        }
    }
}