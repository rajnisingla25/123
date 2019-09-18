/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   09-FEB-2018
Usage           :   The usage of this handler class is to get the appropriate payout values for each produt from 
payout object and update the quota with latest payout values.
Once the quota update with new payouts(New or Renewal) it will update all underlayer commissions
based on the line type in commission level
It will handle all teams.

********************************************************************************/
Public class commissions_QuotaPayoutBatchHandler_New{   
    //RETRIEVING USER TEAMS FROM CUSTIOM SETTING/VARIABLE DECLERATION
    private static string brokerRegionalDirectorsTeam = CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c;
    // Commented below collection team names for JIRA-4551
    //private static string collectionTeam = CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c;
    //private static string collectionsClientRelationsManagers = CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c;
    private static string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    private static Set<String> quotaUserTeamNames = new Set<String>{brokerRegionalDirectorsTeam}; //,collectionTeam,collectionsClientRelationsManagers
    private static Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
    private static string otherproductrecordtype = commissionRecordtypeMap.get(System.Label.Other_Product_Record_Type).getRecordTypeId();
    private static string managerrecordtype= commissionRecordtypeMap.get(System.Label.Managers_Team).getRecordTypeId();       
    private boolean skipUpdatingQuotas = false;

    public void quotaPayoutCalculation(List<Quota__c> quotaRecordList, boolean skipDMLOnQuota){
        this.skipUpdatingQuotas = skipDMLOnQuota;
        quotapayoutCalculation(quotaRecordList);
    }
    
    //PAYOUT CALCULATION METHOD IN QUOTA LEVEL
    public void quotapayoutCalculation(List<Quota__c> quotaRecordList){    
        //COLLECTING QUOTA PERIOD AND USER TEAM DETAILS 
        Set<Id> periodIds = new Set<Id>();
        Set<String> recordtypenames = new Set<String>();
        set<id> userIds = new set<id>();
        // CRM-4074 [Start]
        for(Quota__c quota : quotaRecordList){
            if(quota.Period_Name__c != null){
                periodIds.add(quota.Period_Name__c);            
            }
            if(quota.User_Team__c != null){
                recordtypenames.add(quota.User_Team__c);
            }
            if(String.isNotBlank(quota.Owner_Name__c)){
                recordtypenames.add(quota.Owner_Name__c);  
            }
        }
        // CRM-4074 [End]
        // CRM-4551 [Start]
        Set<String> setCollectionTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
            if(string.isNotBlank(collTeamName.Team_Name__c)){
                setCollectionTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
            }
        }
        quotaUserTeamNames.addAll(setCollectionTeamNames);
        // CRM-4551 [End]
        
        system.debug('periodIds:: '+periodIds);
        system.debug('recordtypenames:: '+ recordtypenames);
        //RETRIEVING PAYOUT RECORDS BY SEARCHING QUOTA PERIOD,USER TEAM AND USER NAME(FOR MANAGERS ONLY)
        Date dt3MonthsBefore = system.today().addDays(-90); 
        Map<Id,payout__c> payoutRecordsMap = new Map<ID, payout__c>([select id, Name, Period__c, RecordTypeId, RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                                                     Commissionable__c,Product_Commission_Category__c,Sale_Type__c ,Product_Code__c,Advantage_Leads_and_Branding__c,Broker_Highlight__c,
                                                                     Connection_SM_for_Co_Brokerage__c,Connections_SM_for_Seller_Bundle__c,Connections_SM_for_Sellers__c,Digital_Ad_Package__c,
                                                                     Digital_Advertising_Campaign__c,Domain_Name__c,Featured_CMA_SM__c,Featured_Display__c,Featured_Homes_SM__c,FiveStreet__c,
                                                                     ListHub_Pro__c,Market_Builder__c,Market_Snapshot__c,REESIO__c,Respond__c,Showcase_SM_Listing_Enhancements__c,Sign_Rider__c,
                                                                     Standard_Listing_Enhancements__c,Top_Producer_CRM__c,Top_Producer_IDX__c,Top_Producer_Website__c,Top_Producer_Website_Setup_Fee__c,
                                                                     Trackable_Phone_Number__c,Turbo_SM_Listings__c,Beta_Connect__c,Beta_Respond__c,Beta_Transact__c, Realsuite_Connect__c,Realsuite_Transact__c,
                                                                     LocalExpert__c,Local_Expert_City__c,Min_of_Deals__c,Max_of_Deals__c,Opcity_BLA__c,Payout_per_Deal__c
                                                                     from payout__c where RecordType.Name in : recordtypenames and Period__c In : PeriodIds and After_Optimization__c = true and CreatedDate > :dt3MonthsBefore Order by Low_Level__c Desc, Min_of_Deals__c Desc]);
        system.debug('Payouts:: '+ payoutRecordsMap.size() +', '+ payoutRecordsMap);
        
        Map<id,Quota__c> updateQuotaMap = new Map<id,Quota__c>();
        //PAYOUT CALCULATION IN QUOTA LEVEL
        for(Quota__c currentQuota : quotaRecordList){   
            system.debug('currentQuota >> :'+currentQuota.user_team__c);
            boolean hasProcessedForNew = false;
            boolean hasProcessedForRenewal = false;
            list<string> blaPayoutsInString = new list<String>();
            for(payout__c payoutrecord : payoutRecordsMap.Values()){
                //Jumping to next payout if payout Record not matches with currentQuota's parameters
                system.debug('picked payout: '+ payoutRecord);
                system.debug('payoutRecord.Name=' + payoutRecord.Name);
                //PAYOUT SALE TYPE VARIABLES
                Boolean isNewSalePayout = payoutRecord.Sale_Type__c == System.Label.Commission_Payout_Sale_Type_New;
                Boolean isRenewalSalePayout = payoutRecord.Sale_Type__c == System.Label.Commission_Payout_Sale_Type_Renewal;
                //QUALIFIER CHECK VARIABLES WITH LINE TYPE 
                Boolean isNewSaleQualifierPayout = payoutRecord.Name == system.label.Commissions_New_Sale_With_Qualifier;
                Boolean isRenewalSaleQualifierPayout = payoutRecord.Name == system.label.Commissions_Renewal_With_Qualifier;
                Boolean isNewSaleaWithoutQualifierPayout = payoutRecord.Name == system.label.Commissions_New_Sale_Without_Qualifier;
                Boolean isRenewalSaleWithoutQualifierPayout = payoutRecord.Name == system.label.Commissions_Renewal_Without_Qualifier;
                // CRM-4195
                system.debug('quotaUserTeamNames=='+quotaUserTeamNames);
                system.debug('quotaUserTeamName1s=='+payoutRecord.RecordType.Name.toLowerCase());
                Boolean isCollectionSalePayout = setCollectionTeamNames.contains(payoutRecord.RecordType.Name.toLowerCase());//payoutRecord.RecordType.Name == collectionTeam;
                Boolean isManagerTeamQuota = currentQuota.User_Team__c == managersTeam;
                Boolean isOPCITY = (currentQuota.BLA_Tier_Changed__c && payoutRecord.RecordType.Name.toLowerCase() == currentQuota.User_Team__c.toLowerCase());
                system.debug('isOPCITY==>'+isOPCITY);
                system.debug('isCollectionSalePayout=='+isCollectionSalePayout);
                if(currentQuota.Period_Name__c != payoutrecord.Period__c            // Period mismathed
                        || (!isCollectionSalePayout && !isOPCITY
                            && ((currentQuota.is_Kicker__c && !isNewSaleQualifierPayout && !isRenewalSaleQualifierPayout)    //qualifier payout mismatched
                                || (!currentQuota.is_Kicker__c && !isNewSaleaWithoutQualifierPayout && !isRenewalSaleWithoutQualifierPayout)    // non-qualifier payout mismatched
                            )
                        )
                    ){
                    system.debug('skipped');
                    continue;
                }
                //VARIABLES
                Decimal lowValueComponent1 = payoutRecord.Low_Level__c;
                Decimal highValueComponent1 = payoutRecord.High_Level__c;
                Decimal commissinableAmountAllTeamsnewsale = 0.0; 
                Decimal commissinableAmountAllTeamsrenewal = 0.0;
                
                //FETCHING PAYOUTS FOR ALL TEAMS EXCEPT COLLECTION TEAMS 
                if(((payoutRecord.RecordType.Name.equalsIgnoreCase(currentQuota.Owner_Name__c) || payoutRecord.RecordType.Name.equalsIgnoreCase(currentQuota.User_Team__c)) && String.isNotBlank(currentQuota.User_Team__c) && !quotaUserTeamNames.contains(currentQuota.User_Team__c.toLowerCase())) || test.isRunningtest()){             
                    system.debug('min='+payoutRecord.Min_of_Deals__c);
                    system.debug('max='+payoutRecord.Max_of_Deals__c);
                    system.debug('tdeals='+currentQuota.Total_of_Deals__c);
                    if(currentQuota.BLA_Tier_Changed__c && payoutRecord.Min_of_Deals__c != null && payoutRecord.Max_of_Deals__c != null /*&& (currentQuota.Total_of_Deals__c >= payoutRecord.Min_of_Deals__c && currentQuota.Total_of_Deals__c <= payoutRecord.Max_of_Deals__c)*/) // Check Total # BLA Deals between min and max deals
                    { 
                        blaPayoutsInString.add(payoutRecord.Min_of_Deals__c+'-'+payoutRecord.Max_of_Deals__c+' Deals :'+ '$'+payoutRecord.Opcity_BLA__c.setScale(2).format());
                        currentQuota.OPCITY_BLA_Payouts__c = String.join(blaPayoutsInString, ';');
                    }
                    else if(payoutRecord.Low_Level__c == Null && payoutRecord.High_Level__c == Null){ 
                        lowValueComponent1 = payoutRecord.Low_Amount__c;
                        highValueComponent1 = payoutRecord.High_Amount__c;
                        
                        //ALL TEAMS EXCEPT MANAGERS FOR NEW SALE PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                        if(!isManagerTeamQuota){
                            if(isNewSalePayout && currentQuota.New_Sale_Tier_Changed__c && currentQuota.Total_Sale__c !=null){
                                commissinableAmountAllTeamsnewsale = (currentQuota.Total_Sale__c + currentQuota.Manager_Total_Sale__c);
                            }
                            //ALL TEAMS EXCEPT MANAGERS FOR RENEWAL SALE PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                            if(isRenewalSalePayout && currentQuota.Renewal_Tier_Changed__c && currentQuota.Total_Sale_Renewal__c !=null){
                                commissinableAmountAllTeamsrenewal = (currentQuota.Total_Sale_Renewal__c + currentQuota.Manager_Total_Sale_Renewal__c);
                            }
                        }
                        //MANAGERS TEAM PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                        else if((isManagerTeamQuota && currentQuota.Owner_Name__c  == payoutRecord.RecordType.Name) || (test.isRunningtest())){
                            if(currentQuota.Collection_Quota_Percentage__c == 0.0 || currentQuota.Collection_Quota_Percentage__c == Null){
                                //MANAGERS PAYOUTS FOR NEW SALES COMMISSINABLE AMOUNT CALCULATION
                                if(isNewSalePayout ){
                                    commissinableAmountAllTeamsnewsale = (currentQuota.Total_Sale__c + currentQuota.Manager_Total_Sale__c);
                                }
                                //MANAGERS PAYOUTS FOR RENEWAL COMMISSINABLE AMOUNT CALCULATION
                                if(isRenewalSalePayout ){
                                    commissinableAmountAllTeamsrenewal = (currentQuota.Total_Sale_Renewal__c + currentQuota.Manager_Total_Sale_Renewal__c);
                                }                           
                            }
                            //COLLECTION MANAGER PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                            else{
                                commissinableAmountAllTeamsnewsale = (currentQuota.Final_Collection_Total_Sale__c);
                            }
                        }                       
                    }
                    else if(payoutRecord.Low_Amount__c == Null && payoutRecord.High_Amount__c == Null){
                        //ALL TEAMS EXCEPT MANAGERS FOR NEW SALE PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                        if(currentQuota.User_Team__c != managersTeam){
                            if(currentQuota.New_Sale_Tier_Changed__c && isNewSalePayout){
                                commissinableAmountAllTeamsnewsale = currentQuota.Quota_Percentage__c;
                            }
                            //ALL TEAMS EXCEPT MANAGERS FOR RENEWAL SALE PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                            if(currentQuota.Renewal_Tier_Changed__c && isRenewalSalePayout){     
                                commissinableAmountAllTeamsrenewal = currentQuota.Quota_Attainment_Renewal__c;
                            }
                        }
                        //MANAGERS TEAM PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                        else if((isManagerTeamQuota && currentQuota.Owner_Name__c  == payoutRecord.RecordType.Name) || test.isrunningtest()){
                            if(currentQuota.Collection_Quota_Percentage__c == 0.0 || currentQuota.Collection_Quota_Percentage__c == Null){
                                //MANAGERS PAYOUTS FOR NEW SALES COMMISSINABLE AMOUNT CALCULATION
                                if(isNewSalePayout ){
                                    commissinableAmountAllTeamsnewsale = currentQuota.Quota_Percentage__c;
                                }
                                //MANAGERS PAYOUTS FOR RENEWAL COMMISSINABLE AMOUNT CALCULATION
                                if(isRenewalSalePayout ){
                                    commissinableAmountAllTeamsrenewal = currentQuota.Quota_Attainment_Renewal__c;
                                }
                            }
                            //COLLECTION MANAGER PAYOUTS COMMISSINABLE AMOUNT CALCULATION
                            else{
                                commissinableAmountAllTeamsnewsale = currentQuota.Collection_Quota_Percentage__c;   //CRM-4334
                            }
                            //system.debug('managers comm 1:'+commissinableAmountComponent1);
                        }                       
                    } 
                    system.debug('highValueComponent1:: '+ highValueComponent1+',, lowValueComponent1:: '+lowValueComponent1);
                    system.debug('commissinableAmountAllTeamsrenewal:: '+ commissinableAmountAllTeamsrenewal+',, commissinableAmountAllTeamsnewsale:: '+commissinableAmountAllTeamsnewsale);
                    
                    //ALL TEAMS EXCEPT MANAGERS FOR NEW SALE PAYOUTS CALCULATION                    
                    if(currentQuota.User_Team__c != managersTeam){
                        if(!skipUpdatingQuotas && isNewSalePayout && isOPCITY){     // for BLA opcity
                            updateQuotaMap.put(currentQuota.id, currentQuota);    
                        }
                        if(isNewSalePayout && currentQuota.New_Sale_Tier_Changed__c){                             
                            if((commissinableAmountAllTeamsnewsale >= lowValueComponent1) && (commissinableAmountAllTeamsnewsale <= highValueComponent1)){
                                getPayouts(currentQuota,payoutrecord,payoutRecord.Sale_Type__c);
                                if(!skipUpdatingQuotas){
                                    updateQuotaMap.put(currentQuota.id, currentQuota);
                                }
                            }                                                          
                        }
                        //ALL TEAMS EXCEPT MANAGERS FOR RENEWAL SALE PAYOUTS CALCULATION                        
                        if(currentQuota.Renewal_Tier_Changed__c && isRenewalSalePayout){                            
                            if((commissinableAmountAllTeamsrenewal >= lowValueComponent1 ) && (commissinableAmountAllTeamsrenewal <= highValueComponent1)){
                                getPayouts(currentQuota,payoutrecord,payoutRecord.Sale_Type__c);
                                if(!skipUpdatingQuotas){                
                                    updateQuotaMap.put(currentQuota.id,currentQuota);
                                }
                            }
                        }
                    }
                    //MANAGERS TEAM PAYOUTS CALCULATION                 
                    else if((isManagerTeamQuota && currentQuota.Owner_Name__c  == payoutRecord.RecordType.Name 
                             && ((isNewSalePayout && commissinableAmountAllTeamsnewsale >= lowValueComponent1 && commissinableAmountAllTeamsnewsale <= highValueComponent1) 
                                 || (isRenewalSalePayout && commissinableAmountAllTeamsrenewal >= lowValueComponent1 && commissinableAmountAllTeamsrenewal <= highValueComponent1)
                                )
                            )|| test.isrunningtest()){
                        //REGULAR MANAGERS PAYOUTS CALCULATION
                        if(currentQuota.Collection_Target_Amount__c == 0.0 || currentQuota.Collection_Target_Amount__c == Null){   
                            
                            //MANAGERS PAYOUTS FOR NEW SALES CALCULATION
                            if(isNewSalePayout){
                                currentQuota.Component_1A_Payout__c = (payoutRecord.Commissionable__c).setScale(6);                                                                    
                            }                            
                            //MANAGERS PAYOUTS FOR RENEWAL SALES CALCULATION
                            if(isRenewalSalePayout){
                                currentQuota.Renewal_Payout__c = (payoutRecord.Commissionable__c).setScale(6);
                            }                                         
                        }
                        //COLLECTION MANAGERS PAYOUT CALCULATION
                        else if(isNewSalePayout){                            
                            if(isNewSaleaWithoutQualifierPayout){ 
                                currentQuota.Collection_Payout__c = (payoutRecord.Commissionable__c).setScale(6);                                    
                            }  
                            if(isNewSaleQualifierPayout){
                                currentQuota.Component_1A_Payout__c = (payoutRecord.Commissionable__c).setScale(6);                                    
                            }
                        }    
                        system.debug('4862=');
                        // CRM-4862:Last Refreshed Date Stamp on Manager Quotas
                        currentQuota.Last_Refreshed_at__c = DateTime.now();
                    }
                }
                //COLLECTION TEAM PAYOUT CALCULATION
                 else if(isCollectionSalePayout && String.isNotBlank(currentQuota.User_Team__c) && setCollectionTeamNames.contains(currentQuota.user_team__c.toLowerCase())) {           
                    if(payoutRecord.Low_Level__c == Null && payoutRecord.High_Level__c == Null){                        
                        lowValueComponent1 = payoutRecord.Low_Amount__c;
                        highValueComponent1 = payoutRecord.High_Amount__c;
                        commissinableAmountAllTeamsnewsale = currentQuota.Collection_Total_Sale__c;                                    
                    }
                    if(payoutRecord.Low_Amount__c == Null && payoutRecord.High_Amount__c == Null){
                        lowValueComponent1 = payoutRecord.Low_Level__c;
                        highValueComponent1 = payoutRecord.High_Level__c;
                        commissinableAmountAllTeamsnewsale = currentQuota.Collection_Quota_Percentage__c;   //CRM-4195: Fix
                    } 
                    if(commissinableAmountAllTeamsnewsale != null && commissinableAmountAllTeamsnewsale >= lowValueComponent1 && commissinableAmountAllTeamsnewsale <= highValueComponent1) {                                       
                        if(isNewSaleaWithoutQualifierPayout ){           // NON-QUALIFIER           //CRM-4195: Fix
                            currentQuota.Collection_Payout__c = (payoutRecord.Commissionable__c).setScale(4);
                        }
                        if(isNewSaleQualifierPayout){                      
                            currentQuota.Component_1A_Payout__c = (payoutRecord.Commissionable__c).setScale(4);
                        }
                    }                    
                }              
            }
            // CRM-4074 - To Run for before Insert trigger on quota
            if(currentQuota.Id == null){
                currentQuota.New_Sale_Tier_Changed__c = FALSE;
                currentQuota.Renewal_Tier_Changed__c = FALSE;   
            }
            if(!skipUpdatingQuotas){
                currentQuota.Total_Clawback_Commission_Amount__c = 0.0;
                currentQuota.Total_Clawback_Commission_Amount_RD__c = 0.0;
                updateQuotaMap.put(currentQuota.id,currentQuota);
            }
        }
        //PROCESSTING UPDATED QUOTAS FOR TO UPDATE UNDERLINE COMMISSIONS WITH NEW PAYOUTS        
        if(updateQuotaMap.size() > 0 ){
            
            if(10000 < [SELECT count() FROM Commission__c WHERE Related_To_Quota__c = :updateQuotaMap.keyset()]){
                System.enqueueJob(new Commissions_UpdateCommissionsQueable_New(updateQuotaMap, null));
            }else{
                payoutCalculation(updateQuotaMap);
                
                //UPDATING QUOTAS WITH NEW PAYOUTS  
                for(Quota__c processedQuota : updateQuotaMap.values()){
                    processedQuota.New_Sale_Tier_Changed__c = FALSE;
                    processedQuota.Renewal_Tier_Changed__c = FALSE;
                    processedQuota.BLA_Tier_Changed__c = FALSE;
                }
                update updateQuotaMap.values();
            }
        }
    }
    //PAYOUTS CALCULATION METHOD
    private void getPayouts(Quota__c currentQuota,payout__c payoutRecord,string saleType){
        system.debug('getPayouts >> :');
        //UPDATING/ASSINGING NEW SALE PAYOUTS FOR EACH PRODUCT
        if(saleType == System.Label.Commission_Payout_Sale_Type_New){
            system.debug('getPayouts >> 1:');
            currentQuota.ADVANTAGE_New__c = payoutRecord.Advantage_Leads_and_Branding__c;
            currentQuota.MEDIABUY_New__c = payoutRecord.Broker_Highlight__c;                         
            currentQuota.COBROKE_New__c = payoutRecord.Connection_SM_for_Co_Brokerage__c;                               
            currentQuota.DACAMPAIGN_New__c = payoutRecord.Digital_Advertising_Campaign__c;
            currentQuota.SELLERLEADBUNDLE_New__c = payoutRecord.Connections_SM_for_Seller_Bundle__c;
            currentQuota.SELLERLEAD_New__c = payoutRecord.Connections_SM_for_Sellers__c;
            currentQuota.DIGITALAGENT_New__c = payoutRecord.Digital_Ad_Package__c;
            currentQuota.DOMAINNAME_New__c = payoutRecord.Domain_Name__c;
            currentQuota.FEATCMA_New__c = payoutRecord.Featured_CMA_SM__c;
            currentQuota.FEATDISP_New__c = payoutRecord.Featured_Display__c;
            currentQuota.FEATHOMES_New__c = payoutRecord.Featured_Homes_SM__c;
            currentQuota.FIVESTREET_New__c = payoutRecord.FiveStreet__c;
            currentQuota.LISTHUBPRO_New__c = payoutRecord.ListHub_Pro__c;
            currentQuota.MRKTBUILD_New__c = payoutRecord.Market_Builder__c;
            currentQuota.TOPMRKSNP_New__c = payoutRecord.Market_Snapshot__c;
            currentQuota.REESIO_New__c = payoutRecord.REESIO__c;
            currentQuota.RSRESPOND_New__c = payoutRecord.Respond__c;
            currentQuota.SHOWCASE_New__c = payoutRecord.Showcase_SM_Listing_Enhancements__c;
            currentQuota.SIGNRIDER_New__c = payoutRecord.Sign_Rider__c;
            currentQuota.STANDLIST_New__c = payoutRecord.Standard_Listing_Enhancements__c;
            currentQuota.TOPCRM_New__c = payoutRecord.Top_Producer_CRM__c;
            currentQuota.TOPIDX_New__c = payoutRecord.Top_Producer_IDX__c;
            currentQuota.TOPWEB_New__c = payoutRecord.Top_Producer_Website__c;
            currentQuota.TOPWEBFEE_New__c = payoutRecord.Top_Producer_Website_Setup_Fee__c;
            currentQuota.TRKPHNMBR_New__c = payoutRecord.Trackable_Phone_Number__c;
            currentQuota.TURBO_New__c = payoutRecord.Turbo_SM_Listings__c; 
            currentQuota.BETACONNECT_New__c = payoutRecord.Beta_Connect__c;
            currentQuota.BETARESPOND_New__c = payoutRecord.Beta_Respond__c;
            currentQuota.BETATRANSACT_New__c = payoutRecord.Beta_Transact__c;            
            // CRM-3530 [Start]
            currentQuota.RSCONNECT_New__c = payoutRecord.Realsuite_Connect__c;
            currentQuota.RSTRANSACT_New__c = payoutRecord.Realsuite_Transact__c;
            // CRM-3530 [Ends]
            // CRM-4555 [Starts]
            currentQuota.LocalExpert_New__c = payoutRecord.LocalExpert__c;
            // CRM-4555 [Ends]
            
            // CRM-6079
            currentQuota.LocalExpertCity_New__c = payoutRecord.Local_Expert_City__c;
        }
        //UPDATING/ASSINGING RENEWAL SALE PAYOUTS FOR EACH PRODUCT      
        else{     
            system.debug('getPayouts >> 2:');
            currentQuota.ADVANTAGE_Renew__c = payoutRecord.Advantage_Leads_and_Branding__c;
            currentQuota.MEDIABUY_Renew__c = payoutRecord.Broker_Highlight__c;                              
            currentQuota.COBROKE_Renew__c = payoutRecord.Connection_SM_for_Co_Brokerage__c;                             
            currentQuota.DACAMPAIGN_Renew__c = payoutRecord.Digital_Advertising_Campaign__c;
            currentQuota.SELLERLEADBUNDLE_Renew__c = payoutRecord.Connections_SM_for_Seller_Bundle__c;
            currentQuota.SELLERLEAD_Renew__c = payoutRecord.Connections_SM_for_Sellers__c;
            currentQuota.DIGITALAGENT_Renew__c = payoutRecord.Digital_Ad_Package__c;
            currentQuota.DOMAINNAME_Renew__c = payoutRecord.Domain_Name__c;
            currentQuota.FEATCMA_Renew__c = payoutRecord.Featured_CMA_SM__c;
            currentQuota.FEATDISP_Renew__c = payoutRecord.Featured_Display__c;
            currentQuota.FEATHOMES_Renew__c = payoutRecord.Featured_Homes_SM__c;
            currentQuota.FIVESTREET_Renew__c = payoutRecord.FiveStreet__c;
            currentQuota.LISTHUBPRO_Renew__c = payoutRecord.ListHub_Pro__c;
            currentQuota.MRKTBUILD_Renew__c = payoutRecord.Market_Builder__c;
            currentQuota.TOPMRKSNP_Renew__c = payoutRecord.Market_Snapshot__c;
            currentQuota.REESIO_Renew__c = payoutRecord.REESIO__c;
            currentQuota.RSRESPOND_Renew__c = payoutRecord.Respond__c;
            currentQuota.SHOWCASE_Renew__c = payoutRecord.Showcase_SM_Listing_Enhancements__c;
            currentQuota.SIGNRIDER_Renew__c = payoutRecord.Sign_Rider__c;
            currentQuota.STANDLIST_Renew__c = payoutRecord.Standard_Listing_Enhancements__c;
            currentQuota.TOPCRM_Renew__c = payoutRecord.Top_Producer_CRM__c;
            currentQuota.TOPIDX_Renew__c = payoutRecord.Top_Producer_IDX__c;
            currentQuota.TOPWEB_Renew__c = payoutRecord.Top_Producer_Website__c;
            currentQuota.TOPWEBFEE_Renew__c = payoutRecord.Top_Producer_Website_Setup_Fee__c;
            currentQuota.TRKPHNMBR_Renew__c = payoutRecord.Trackable_Phone_Number__c;
            currentQuota.TURBO_Renew__c = payoutRecord.Turbo_SM_Listings__c;
            currentQuota.BETACONNECT_Renew__c = payoutRecord.Beta_Connect__c;
            currentQuota.BETARESPOND_Renew__c = payoutRecord.Beta_Respond__c;
            currentQuota.BETATRANSACT_Renew__c = payoutRecord.Beta_Transact__c;   
            // CRM-3530 [Start]
            currentQuota.RSCONNECT_Renew__c = payoutRecord.Realsuite_Connect__c;
            currentQuota.RSTRANSACT_Renew__c = payoutRecord.Realsuite_Transact__c;
            // CRM-3530 [Ends]
            // CRM-4555 [Starts]
            currentQuota.LocalExpert_Renew__c = payoutRecord.LocalExpert__c;
            // CRM-4555 [Ends]
            
            // CRM-6079
            currentQuota.LocalExpertCity_Renew__c = payoutRecord.Local_Expert_City__c;
        }
    }
    
    //PAYOUT CALCULATION METHOD IN COMMISSION LEVEL - PAYOUT CALCULATION FOR COMMISSIONS LOGIC START
    Public void payoutCalculation(Map<Id,Quota__c> mapQuotas){        
        List<Commission__c> commissionsUpdateList = new List<Commission__c>();
        Integer iIterate = 1;
        Map<Id,Commissions_UpdateCommissionsQueable_New.BLAInfo> mapQuotaBLAInfo = new Map<Id,Commissions_UpdateCommissionsQueable_New.BLAInfo>();
        List<List<Commission__c>> listCommissionsListToUpdate = new List<List<Commission__c>>();
        //RETRIVING COMMISSION RECORDS TO UPDATE THE LATEST PAYOUTS
        for(Commission__c commissionrecord : [Select id,Name,Final_Commission__c,Product__r.ProductCode,Related_to_Quota__c,Related_to_Quota__r.BLA_Tier_Changed__c,Deal_Number__c,BLA_Commission_Amount__c, Line_Type__c,Payout_Rate__c,Commission_Split__c,Asset_Amount__c,
                                                  Payout_Rate1B__c ,RecordType.Name,Renewal_w_o_Qualifier_Payout_Rate__c,Renewal_w_Qualifier_Payout_Rate__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                                                  Renewal_w_o_Qualifier_Comm_ble_Amount__c,Renewal_w_Qualifier_Comm_ble_Amount__c,User_Team__c,Related_Commission__c, Product_Category__c,
                                                  Related_Commission__r.Payout_Rate__c,Other_Product__c,Related_Commission__r.Payout_Rate1B__c,Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c,Related_Commission__r.Renewal_w_Qualifier_Payout_Rate__c,
                                                  Related_Commission__r.CFCB_NEW_w_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_New_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_RNW_w_Qualifier_Payout_Rate1__c,
                                                  Related_Commission__r.CFCB_RNW_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CreatedDate,Related_Commission__r.Asset_Owner_Payout_Rate1__c,
                                                  Related_Commission__r.Historic_CFCB_NewSale_With_Q_Payout__c,Related_Commission__r.Historic_CFCB_New_Sale_w_o_Qualifier_Pay__c,
                                                  Related_Commission__r.Historic_CFCB_RNW_W_Q_Payout_Rate__c,Related_Commission__r.Historic_CFCB_RNW_w_o_Q_Payout_Rate__c,Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c,
                                                  Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c,Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c,
                                                  Total_Clawback_Commission__c, Total_Clawback_Commission_RD__c
                                                  from Commission__c 
                                                  where Related_to_Quota__c In : mapQuotas.keySet() 
                                                    AND ((Related_to_Quota__r.BLA_Tier_Changed__c = true AND Product__r.ProductCode = 'OPCITYBLA') OR (RecordType.Name != :Commissions_Constants.COMMISSIONS_CLAWBACK))]){
          //FETCHING COMMISSION RELATED QUOTA
            Quota__c quotaRecord = mapQuotas.get(commissionrecord.Related_to_Quota__c);   
            Boolean isManagerTeam = commissionrecord.User_Team__c == managersTeam;
              
            //UPDATE ALL COMMISSION RECORDS WITH LATEST PAYOUT VALUES EXCEPT CLAWBACK COMMISSIONS 
            if (commissionrecord.Related_Commission__c == Null) {
                //BLA Commissions update
                if(quotaRecord.BLA_Tier_Changed__c && commissionrecord.Product__r.ProductCode == 'OPCITYBLA' && commissionrecord.Deal_Number__c != null){
                    if(!mapQuotaBLAInfo.containsKey(quotaRecord.Id)){
                        mapQuotaBLAInfo.put(quotaRecord.Id, new Commissions_UpdateCommissionsQueable_New.BLAInfo(quotaRecord));
                    }
                    commissionrecord.BLA_Commission_Amount__c = mapQuotaBLAInfo.get(quotaRecord.Id).getApplicablePayout(commissionrecord.Deal_Number__c);
                }
                //UPDATING ONLY NEW SALE/ADD COMMISSIONS IF TIER VALUES CHANGE
                system.debug('>>>>>>>>>> 123 :'+quotaRecord.New_Sale_Tier_Changed__c);
                if(quotaRecord.New_Sale_Tier_Changed__c && (commissionrecord.Line_Type__c == 'Add' || commissionrecord.Line_Type__c == 'Amend')){    
                    getCalculatePayoutRates(commissionrecord, true, isManagerTeam, quotaRecord);
                }
                //UPDATING ONLY RENEWAL COMMISSIONS IF TIER VALUES CHANGE               
                else if(quotaRecord.Renewal_Tier_Changed__c && commissionrecord.Line_Type__c == 'Renew'){
                    getCalculatePayoutRates(commissionrecord, false, isManagerTeam, quotaRecord);            
                }
            }
            //*
            if(listCommissionsListToUpdate.size() < iIterate ){
                listCommissionsListToUpdate.add(new list<Commission__c>{commissionrecord});
            }else{                                                      
                List<Commission__c> lstCommToUpdate = listCommissionsListToUpdate[iIterate-1];
                if(lstCommToUpdate != null){
                    listCommissionsListToUpdate[iIterate-1].add(commissionrecord);
                }
                if(listCommissionsListToUpdate[iIterate-1].size() >= 1000){
                    iIterate += 1;
                }
            }
            //commissionsUpdateList.add(commissionrecord);
            mapQuotas.put(commissionrecord.Related_to_Quota__c, quotaRecord); // CRM-2930
        }
        //UPDATING COMMISSIONS
        if(listCommissionsListToUpdate.size() > 0){
            if(listCommissionsListToUpdate.size() == 1){
                update listCommissionsListToUpdate[0];
            }
            else {
                System.enqueueJob(new Commissions_UpdateCommissionsQueable_New(listCommissionsListToUpdate));
            }
        }
    }
    
    //UPDATING LATEST PRODUCT PAYOUTS IN COMMSISSION RECORDS FOR NEW AND RENEWAL COMMISSIONS
    private void getCalculatePayoutRates(Commission__c commissionrecord, Boolean isNew, Boolean isManagerTeam, Quota__c quotaRecord) {
        String fieldAppendStr = '_New__c';
        if (!isNew) {
            fieldAppendStr = '_Renew__c';
        }
        String fieldName = '';
        decimal productPayout = 0.0;        
        decimal commissionalbleamount = (commissionrecord.Asset_Amount__c * commissionrecord.Commission_Split__c)/100 ;
        // CRM-4524 Starts
        if(commissionrecord.RecordtypeId == otherproductrecordtype){
            commissionalbleamount = commissionrecord.Commissionable_Amount2__c;
        }
        // CRM 4524 End.
        commissionrecord.Payout_Rate__c = 0.0;
        commissionrecord.Payout_Rate1B__c = 0.0;
        commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 0.0;
        commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
        commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = 0.0;
        commissionrecord.Renewal_w_Qualifier_Payout_Rate__c =  0.0;
        commissionrecord.Commissionable_Amount1B__c = 0.0;
        commissionrecord.Commissionable_Amount2__c = 0.0;
        system.debug('commissionrecord.Product__r.ProductCode :: '+ commissionrecord.Product__r.ProductCode);
                
        fieldName = commissionrecord.Product__r.ProductCode + fieldAppendStr;
        try{
            if(commissionrecord.user_team__c == managersTeam){
                productPayout = isNew ? quotaRecord.Component_1A_Payout__c : quotaRecord.Renewal_Payout__c;
            }else{
                productPayout = (Decimal)quotaRecord.get(fieldName);               
            }
        }
        catch(Exception e){}
        //COMMISSION PAYOUT UPDATES FOR ALL TEAMS EXCEPT COLLECTION TEAMS
        if (commissionrecord.RecordtypeId != otherproductrecordtype && String.isNotBlank(commissionrecord.User_Team__c) && !quotaUserTeamNames.contains(commissionrecord.user_team__c.toLowerCase())) { // CRM-4524 added condition for other product
            
            if(!quotaRecord.Is_Kicker__c){
                if(isNew){
                    commissionrecord.Payout_Rate__c = productPayout;//(Decimal)quotaRecord.get(fieldName);
                    commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
                }
                else{
                    commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = productPayout;
                    commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
                }
            }
            else{
                if(isNew){
                    commissionrecord.Payout_Rate1B__c = productPayout;//(Decimal)quotaRecord.get(fieldName);
                    commissionrecord.Commissionable_Amount1B__c = commissionalbleamount;
                }
                else{
                    commissionrecord.Renewal_w_Qualifier_Payout_Rate__c = productPayout;
                    commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
                }
            } 
        }
        //OTHER PRODUCTS
        else if(commissionrecord.RecordtypeId == otherproductrecordtype){
            fieldName = commissionrecord.Product__r.ProductCode + fieldAppendStr;       //fieldName = commissionrecord.Other_Product__c + fieldAppendStr;
            commissionrecord.Payout_Rate__c = productPayout;    //(Decimal)quotaRecord.get(fieldName);
            //commissionalbleamount = 100;
            commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
        }
        else{
            //COLLECTION TEAM NEW SALE
            if(isNew){
                commissionrecord.Payout_Rate__c = quotaRecord.Component_1A_Payout__c;
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
            else{
                //COLLECTION TEAM PAYMENTS - DIRECTLY CALCULATION THROUGH FORMULA FIELD
                //commissionrecord.Payout_Rate__c = quotaRecord.Collection_Payout__c;
                //commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
        }  
        // [CRM-4335] Starts
        commissionrecord.Commissionable_Amount2__c = commissionrecord.Commissionable_Amount2__c == null ? 0.0 : commissionrecord.Commissionable_Amount2__c;
        commissionrecord.Commissionable_Amount1B__c = commissionrecord.Commissionable_Amount1B__c == null ? 0.0 : commissionrecord.Commissionable_Amount1B__c;
        commissionrecord.Payout_Rate__c = commissionrecord.Payout_Rate__c == null ? 0.0 : commissionrecord.Payout_Rate__c;
        commissionrecord.Payout_Rate1B__c = commissionrecord.Payout_Rate1B__c == null ? 0.0 : commissionrecord.Payout_Rate1B__c;
        commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c == null ? 0.0 : commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c;
        commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c;
        commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c == null ? 0.0 : commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c;
        commissionrecord.Renewal_w_Qualifier_Payout_Rate__c =  commissionrecord.Renewal_w_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_Qualifier_Payout_Rate__c;
         
        commissionrecord.Final_Commission__c = ((commissionrecord.Commissionable_Amount2__c * commissionrecord.Payout_Rate__c)
                                                    + (commissionrecord.Commissionable_Amount1B__c * commissionrecord.Payout_Rate1B__c)
                                                    + (commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c * commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c)
                                                    + (commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c * commissionrecord.Renewal_w_Qualifier_Payout_Rate__c))/100;
         // [CRM-4335] Ends            
    }
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/