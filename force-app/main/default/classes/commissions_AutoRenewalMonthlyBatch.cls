/*******************************************************************************
Created By      :   Srinivas Vadla
Created Date    :   01-Nov-2015
Usage           :  
                    The main purpose of this class is to collect the payment records not related to collections and filter the auto renewal assets to create commissions for related invoice item charge amount. 
                        * Batch size for this schedule job is 100.
                        * Schedule Job Name is 'commissions_AutoRenewalMonthlyBatch' - Parent Job and No - Child Job
                        * This Job will be scheduled to run once in a day.
                        * if any exception occurs in job(Record),will pic that record from next run job. 

Modified By     :   Srinivas Vadla
Modified Date   :   2-Feb-2017

********************************************************************************/
global class commissions_AutoRenewalMonthlyBatch implements Schedulable, Database.Batchable < sObject >,Database.Stateful {
    public static final string renew = 'Renew';
    public static final string tigerCommissionCategory = 'tiger';
    public static final string accountType = 'Franchise Company';
    public static final string calculate = 'Calculate';
    public static final string activeStatus = 'Active';
    public static final string BROKER_REGIONAL_DIRECTORS_TEAM = 'Broker Regional Directors Team';
    public static final string MANAGERS_TEAM = 'Managers Team';
    public static final string STATUS_POSTED = 'Posted';
    public static final string STATUS_PROCESSED = 'Processed';
    public static final integer cmp = 0;
    
    global void execute(SchedulableContext SC) {
        commissions_AutoRenewalMonthlyBatch batchInst = new commissions_AutoRenewalMonthlyBatch();
        ID batchprocessid = Database.executeBatch(batchInst, 100);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([Select Id,
            Zuora__Status__c,
            Zuora__Account__c,
            Zuora__AppliedInvoiceAmount__c,
            SalesforceCollectionsRepUsername__c,
            Zuora__Invoice__c
            FROM Zuora__Payment__c
            WHERE Zuora__Status__c =: STATUS_PROCESSED
            AND CreatedDate = TODAY
            AND SalesforceCollectionsRepUsername__c = NULL
        ]);
    }
    global void execute(Database.BatchableContext BC, List < Sobject > scope) {
        DateTime assetLastModifiedDate;
        DateTime assetCreatedDate;
        DateTime assetCreatedDate2;
        Decimal signingAEPercent = 0.0;
        Decimal assetOwnerPercent = 0.0;
        Decimal commissionableAmount = 0.0;
        Id PaymentRecordId ;
        set < String > salesRepIdSet = new set < String > ();
        set < String > paymentIdSet = new set < String > ();
        set < String > invoiceIdSet = new set < String > ();
        set < Id > invoiceItemInvoiceIdSet = new set < Id > ();
        set < String > assetIdSet = new set < String > ();
        set < Id > assetIds = new set < id > ();
        set < Id > productIds = new set < id > ();
        set < Id > accountIds = new set < id > ();
        set < Id > AccountOwnerIds = new set < id > ();
        List < String > userandManagerIds = new List < String > ();
        Set < String > AEManagers = new Set < String > ();
        set < Id > ExIds = new set < Id > ();
        List < Invoice_Item__c > invoiceItemList = new List < Invoice_Item__c > ();
        List< Zuora__PaymentInvoice__c > paymentInvoiceList = new List< Zuora__PaymentInvoice__c > ();
        List < Asset > assetListTocommission = new List < Asset > ();
        Map < id, Quota__c > salesRepQuotaMap = new Map < id, Quota__c > ();
        Map < String, commission__c > newCommissionHolder = new Map < String, commission__c > ();
        List<commission__c> newCommissionHolderList = new List<commission__c>();
        List<commission__c> newCommissionHolderList2 = new List<commission__c>();
        Map < id, commission__c > updateAssets = new Map < id, commission__c > ();
        Map<id,List<Invoice_Item__c >> assetVsInvoiceItemsMap = new Map<id, List<Invoice_Item__c>>();
        Map<Id,Id> UpdatePaymentswithcommMap = new Map<Id,Id>();
        Map<Id,List<Id>> InvoiceVsPaymentMap = new Map<Id,List<Id>>();
        Map<Id,Id> InvoiceVsAssetMap = new Map<Id,Id>();          
        //FETCH RECORD TYPES  
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        Id newSaleB2B = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId();
        Map < id, Quota__c > updateQuota = new Map < Id, Quota__c > ();
        // CRM-4551 [Start]
        Set<String> quotaUserTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
            if(string.isNotBlank(collTeamName.Team_Name__c)){
            	quotaUserTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
        	}
        }
        // CRM-4551 [End]
        For(sObject sc: scope) {
            Zuora__Payment__c newObjScope = (Zuora__Payment__c) sc;
            if (newObjScope.SalesforceCollectionsRepUsername__c == NULL || newObjScope.SalesforceCollectionsRepUsername__c == '') {
                paymentIdSet.add(newObjScope.Id);
                //invoiceIdSet.add(newObjScope.Zuora__Invoice__c);
                List<Id> paymetIdList = new List<Id>();
                if(InvoiceVsPaymentMap.containskey(newObjScope.Zuora__Invoice__c)){
                    paymetIdList = InvoiceVsPaymentMap.get(newObjScope.Zuora__Invoice__c);
                    
                }
                paymetIdList.add(newObjScope.Id);
                InvoiceVsPaymentMap.put(newObjScope.Zuora__Invoice__c,paymetIdList);
            }
        }  
        if (paymentIdSet != NULL && paymentIdSet.size()>0){
            paymentInvoiceList = [Select Id,
                Zuora__Invoice__c,
                Zuora__Payment__c
                FROM Zuora__PaymentInvoice__c
                WHERE Zuora__Payment__c IN: paymentIdSet
                ];
        }
        
        if (paymentInvoiceList != NULL && paymentInvoiceList.size() > 0) {
            for(Zuora__PaymentInvoice__c payinv : paymentInvoiceList){
                invoiceIdSet.add(payinv.Zuora__Invoice__c);
            } 
        }
        Map < Id, Zuora__ZInvoice__c > invoiceMap = new Map < Id, Zuora__ZInvoice__c > ([Select Id,
            Invoice_Status__c,
            Zuora__Status__c
            FROM Zuora__ZInvoice__c
            WHERE Id IN: invoiceIdSet
        ]); 

        if (invoiceMap != NULL && invoiceMap.size() > 0) {
            invoiceItemInvoiceIdSet.addall(invoiceMap.keyset());
        }
        if (invoiceItemInvoiceIdSet != NULL && invoiceItemInvoiceIdSet.size() > 0) {
            invoiceItemList = [Select Id,
                Asset__c,
                Charge_Amount__c,
                Charge_Date__c,
                Asset__r.Product2.ProductCode,
                Invoice__c
                FROM Invoice_Item__c
                WHERE Commissions_are_calculated__c =:FALSE
                AND Invoice__c IN: invoiceItemInvoiceIdSet
            ];
        }
        for(Invoice_Item__c invoiceItemAsset: invoiceItemList) {
            assetIdSet.add(invoiceItemAsset.Asset__c);
            List<Invoice_Item__c> tempList = new List<Invoice_Item__c>();
            if(assetVsInvoiceItemsMap.containskey(invoiceItemAsset.Asset__c)) {
                tempList = assetVsInvoiceItemsMap.get(invoiceItemAsset.Asset__c);
            }
            tempList.add(invoiceItemAsset);
            assetVsInvoiceItemsMap.put(invoiceItemAsset.Asset__c,tempList);
        }
        if (assetIdSet != NULL && assetIdSet.size() > 0) {
            assetListTocommission = [SELECT Id,
                accountId,
                Account.OwnerId,
                Product2Id,
                Ownerid,
                Sign_in_AE__c,
                Asset_Type__c,
                Fulfillment_Status__c,
                Status, Account_Type__c,
                LastModifiedDate, CreatedDate,
                Line_Type__c, Delta_Price_w_o_Tax__c,
                Legacy_Created_Date__c, End_Date__c, Billing_Period__c,
                Total_Net__c, Renewal_Type__c, Commission_field__c, Sign_in_AE__r.Team__c,
                Start_Date__c, Commissions_are_calculated__c, Order_Line_Item__c,
                Order_Line_Item__r.Product_Commission_Category__c
                FROM Asset
                WHERE Fulfillment_Status__c =: Constants.FULFILLMENT_STATUS
                AND Asset_Type__c =: Constants.ASSET_TYPE
                AND Line_Type__c =: renew
                AND Account_Type__c !=: accountType
                AND Month_to_Month__c =: 'Y'
                AND Product2.Renewal_Term_Type__c =: 'Evergreen'
                AND Id IN: assetIdSet
            ];
        }
        for (Asset Assets: assetListTocommission) {
            AssetIds.add(Assets.Id);
            ProductIds.add(Assets.product2Id);
            //SignInAEIds.add(Assets.Sign_in_AE__c);
            AccountOwnerIds.add(Assets.Account.OwnerId);
            ExIds.add(Assets.Sign_in_AE__c);
            accountIds.add(Assets.accountId);
        }
        Map < id, Quota__c > assetOwnerandSignInAEQuotas = new Map<id, Quota__c>([SELECT Id,
            Name, User__c,
            User__r.Team__c, User__r.Managers__c,
            Quota_StartDate__c, Period_Name__r.Sigh_In_AE__c,TOPCRM_Renew__c,TOPIDX_Renew__c,TOPMRKSNP_Renew__c,MRKTBUILD_Renew__c,
            Period_Name__r.asset_Owner__c, User_Team__c, Target_Amount_2__c,
            Record_Processed__c, Period_Name__r.Agent_Asset_Owner__c, Period_Year1__c,
            Period_Name__r.Agent_Sigh_In_AE__c, Is_Kicker__c, Current_Quater__c
            FROM Quota__c
            WHERE User__c In: AccountOwnerIds
            AND Quota_StartDate__c = THIS_YEAR
        ]);
        string[] strgarray;
        //Getting SIGNING AE's AND ASSET OWNER's MANAGERS
        if (assetOwnerandSignInAEQuotas.size() > cmp) {
            for (Quota__c Qs: assetOwnerandSignInAEQuotas.Values()) {
                string manager = Qs.User__r.Managers__c;
                if (manager != null && manager != '') {
                    strgarray = manager.split(';');
                    for (string str: strgarray) {
                        AEManagers.add(str.toLowerCase());
                    }
                }
            }
        }
        //GETTING ALL SIGNING AE's AND ASSET OWNER MANAGERS QUOTAS FOR QUOTA OBJECT
        Map < id, Quota__c > assetOwnerandSignInAEManagersQuotas = new Map < id, Quota__c > ([SELECT Id,
            Name, User__r.Name,
            user__c, User__r.Team__c,
            User__r.Managers__c, Quota_StartDate__c,
            User_Team__c, Is_Kicker__c,
            Period_Name__r.Sigh_In_AE__c,
            Record_Processed__c, Target_Amount_2__c,
            Period_Name__r.asset_owner__c,
            Period_Name__r.Agent_Asset_Owner__c,
            Period_Name__r.Agent_Sigh_In_AE__c,
            Current_Quater__c
            FROM Quota__c
            WHERE User__r.Name IN: AEManagers
            AND Quota_StartDate__c = THIS_YEAR
        ]);
                
        Map < id, User > assetsignInAEs = new Map < id, User > ([SELECT Id,
            Name, Team__c,
            Managers__c, ProfileId,
            Profile.Name, Vacation_Start_Date__c,
            Vacation_End_Date__c
            FROM USER
            WHERE Id IN: AccountOwnerIds
        ]);
        Map < id, Product2 > assetProducts = new Map < id, Product2 > ([SELECT Id,
            Name, Normalization_factor__c,
            Commission_Category__c
            FROM product2
            WHERE Id IN: ProductIds
        ]);
        ProductIds.clear();
        Map < id, Account > allAccounts = new Map < id, Account > ([SELECT Id,
            Name, type,
            RecordTypeId from Account
            WHERE Id IN: accountIds
        ]);
        accountIds.clear();
        //CREATING COMMISSIONS for ACCOUNT OWNER OF PROCESSED ASSETS 
        for (Asset assetcommission: assetListTocommission) {
            signingAEPercent = 0.0;
            assetOwnerPercent = 0.0;
            account acc = allAccounts.get(assetcommission.AccountId);
            commissionableAmount = 0.0;
             
            if (assetcommission.Status == activeStatus && assetcommission.Sign_in_AE__c != null && assetcommission.OwnerId != Null) {
                Product2 Products = assetProducts.get(assetcommission.product2id);
                User SignInAE = assetsignInAEs.get(assetcommission.Sign_in_AE__c);
                User assetOwner = assetsignInAEs.get(assetcommission.OwnerId);
                user assetAccountOwner = assetsignInAEs.get(assetcommission.account.OwnerId);
                set < String > ManagerNames = new Set < String > ();
                DateTime assetLastModifiedDate2;
                DateTime assetCreatedDateDate;
                if (test.IsRunningTest()) {
                    assetLastModifiedDate2 = System.today();
                    assetCreatedDateDate = System.today();
                } else {
                    assetLastModifiedDate2 = assetcommission.LastModifiedDate;
                    assetCreatedDateDate = assetcommission.Start_Date__c;
                }

           Integer month = Date.Today().month();    
           if(assetVsInvoiceItemsMap.containskey(assetcommission.id) && assetVsInvoiceItemsMap.get(assetcommission.id) !=null ) {
              for(Invoice_Item__c invItem : assetVsInvoiceItemsMap.get(assetcommission.id)){
                for (Quota__c quotaRecordSAE: assetOwnerandSignInAEQuotas.Values()) {
                    if ((quotaRecordSAE != Null) && (quotaRecordSAE.User__c == assetcommission.Account.Ownerid) && (quotaRecordSAE.User_Team__c != BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecordSAE.Quota_StartDate__c.month() == month)
                            ) {
                        system.debug('Insite quotas'+assetOwnerandSignInAEQuotas);
                        if (Test.isRunningTest()) {
                            signingAEpercent = 100;
                        } else {
                            if (assetAccountOwner !=NULL) {
                                signingAEpercent = 100;
                            }     
                        }
                        if (signingAEpercent != 0.0) {
                            system.debug('InsideCommissionCreation For SIGNING AE');
                            Commission__c commissionRecord = new Commission__c();
                            commissionRecord.Related_to_Asset__c = assetcommission.id;
                            commissionRecord.Payment__c = PaymentRecordId;
                            commissionRecord.Product__c = assetcommission.product2id;
                            commissionRecord.Line_Type__c = assetcommission.Line_Type__c;
                            commissionRecord.Billing_Type__c = assetcommission.Billing_Period__c;
                           //Added By Srinivas Vadla
                           // JIRA CRM-1395 : Commissionable amount will now store in renewal fields based on kicker
                            if(!quotaUserTeamNames.contains(quotaRecordSAE.User_Team__c.toLowerCase())){// CRM-4551 quotaRecordSAE.User_Team__c != Commissions_Constants.COLLECTION_TEAM  && quotaRecordSAE.User_Team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS
                                if(quotaRecordSAE.Is_Kicker__c){
                                 commissionRecord.Renewal_w_Qualifier_Comm_ble_Amount__c = (invItem.Charge_Amount__c * signingAEpercent)/100;  
                                   if(invItem.Asset__r.Product2.ProductCode=='TOPCRM'){
                                   	commissionRecord.Renewal_w_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPCRM_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='TOPMRKSNP'){
                                   	commissionRecord.Renewal_w_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPMRKSNP_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='TOPIDX'){
                                   	commissionRecord.Renewal_w_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPIDX_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='MRKTBUILD'){
                                   	commissionRecord.Renewal_w_Qualifier_Payout_Rate__c = quotaRecordSAE.MRKTBUILD_Renew__c;
                                   }
                                }
                                else if(!quotaRecordSAE.Is_Kicker__c){
                                    commissionRecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = (invItem.Charge_Amount__c * signingAEpercent)/100;
                                                                        
                                    if(invItem.Asset__r.Product2.ProductCode=='TOPCRM'){
                                   	commissionRecord.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPCRM_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='TOPMRKSNP'){
                                   	commissionRecord.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPMRKSNP_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='TOPIDX'){
                                   	commissionRecord.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecordSAE.TOPIDX_Renew__c;
                                   } else if(invItem.Asset__r.Product2.ProductCode=='MRKTBUILD'){
                                   	commissionRecord.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecordSAE.MRKTBUILD_Renew__c;
                                   }
                                }
                             }
                            if (quotaRecordSAE.User_Team__c == MANAGERS_TEAM) {
                                commissionRecord.RecordTypeId = newSaleManagerRT;
                            } else {
                                commissionRecord.RecordTypeId = newSaleRT;
                            }
                            commissionRecord.Asset_Amount__c = commissionableAmount; 
                            commissionRecord.Commission_Split__c = signingAEpercent;
                            commissionRecord.Signing_AE__c = assetcommission.Sign_in_AE__c;
                            commissionRecord.Related_to_Quota__c = quotaRecordSAE.id;
                            commissionRecord.User_Team__c = quotaRecordSAE.User__r.Team__c;
                            commissionRecord.Status__c = activeStatus;
                            commissionRecord.Asset_Amount__c = invItem.Charge_Amount__c;
                            commissionRecord.Invoice_Item__c = invItem.id;  
                            newCommissionHolderList.add(commissionRecord);
                            quotaRecordSAE.Record_Processed__c = FALSE;
                            updateQuota.put(quotaRecordSAE.id, quotaRecordSAE);
                        }
                      }
                    }
                  }
                } 

            }
        }
        Database.SaveResult[] commissionResult = Database.insert(newCommissionHolderList, false);   
        
        Map <Id, Invoice_Item__c> invItemMapToUpdate = new Map <Id, Invoice_Item__c> ();
        Set< Asset > assetSetToUpdate = new Set< Asset > ();
        List < Asset > assetListToUpdate = new List < Asset > ();
        List < commission__c > commissionList = new List < commission__c > ();
        commissionList.addall(newCommissionHolderList);
        Integer i = 0;
        
        for(Database.SaveResult sr: commissionResult) {
            Id assetId = commissionList.get(i).Related_to_Asset__c;
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Commission. Commission ID: ' + sr.getId());
                Invoice_Item__c invItem = new Invoice_Item__c();
                invItem.Id = commissionList.get(i).Invoice_Item__c;
                invItem.Commissions_are_calculated__c = TRUE;
                set<Id> invitmIds = new set<Id>();
                invitmIds.add(invItem.Id);
                if(invitmIds.size()>0 && invitmIds != NULL){
                invItemMapToUpdate.put(invItem.Id,invItem);
                }

            } else {
                // Operation failed, so get all errors    
                Asset asst = new Asset();
                asst.Id = assetId;
                for (Database.Error err: sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    asst.Commission_Error_Message__c = 'The following error has occurrederred' + err.getMessage() + 'Status Code' + err.getStatusCode();
                }
                assetSetToUpdate.add(asst);
            }
            i++;
        } 
        assetListToUpdate.addAll(assetSetToUpdate);
        
        if(assetListToUpdate!=Null && assetListToUpdate.size() > 0){ 
            UPDATE assetListToUpdate;
         }
        if(invItemMapToUpdate !=Null && invItemMapToUpdate.size() > 0){  
             UPDATE invItemMapToUpdate.Values();
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
    }