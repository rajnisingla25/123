/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   15-FEB-2018
Usage              :   The usage of this batch class is to fetch all quota records to calculate/update the latest payout values for 
                       each product in quota level and it will update all commissions under the quotas.
                       
                       It will fetch the quota record which are TRUE values (flag check to process) for below fields
                       * New Sale Tier Changed = TRUE (New_Sale_Tier_Changed__c)
                       * Renewal Tier Changed = TRUE (Renewal_Tier_Changed__c) 

********************************************************************************/
global class commissions_QuotaPayoutBatch_New implements Schedulable,Database.Batchable<sObject>, Database.Stateful{
    //TO HOLD THE SPECIFIED QUOTA IDS
    private set<Id> quotaIds = new set<Id>();

    //CRM-4196 [starts]
    //TO enable Manager payout calculation only
    private Boolean calculateOnlyManagerPayout = false;
    //QuotaIds to EXCLUDE for payout calculation
    private set<Id> userIdsToExcludeQuotas = new set<Id>();
    //PARAMETERIZED CONSTRUCTOR TO EXCLUDE QUOTA IDS FILTER
    global commissions_QuotaPayoutBatch_New (set<id> setExcludeQuotaUserIds, Boolean isMgrPayoutOnly){
        this.calculateOnlyManagerPayout = isMgrPayoutOnly;
        if(setExcludeQuotaUserIds != null){
            this.userIdsToExcludeQuotas = setExcludeQuotaUserIds;
        }
    }
    // CRM-4196 [ends]
    
    //PARAMETERIZED CONSTRUCTOR TO SET UP THE QUOTA IDS FILTER
    global commissions_QuotaPayoutBatch_New (set<id> setQuotaIds){
        if(setQuotaIds != null){
            this.quotaIds = setQuotaIds;
        }
    }

    global commissions_QuotaPayoutBatch_New (){}

    //START METHOD
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String BLATeamName = CommissionTeams__c.getInstance('WLV_BLA_Sales_Team').Team_Name__c;
        //DYNAMIC QUERY TO FILTER PAYOUT TIER CHANGED QUOTAS AS PER SPECIFIED QUOTA iD SET, IF QUOTA IDS NOT SPECIFIED THEN FETCHES ALL PAYOUT TIER CHANGED QUOTAS
        string dynamicQuery = 'select id, Name,User_Team__c,Period_Name__c,User__r.Name,Owner_Name__c,Is_Kicker__c,Final_Collection_Total_Sale__c, '+
                                    'Quota_Percentage__c,New_Sale_Tier_Changed__c,Total_Sale__c,Component_1A_Payout__c,Total_Sale_Renewal__c,Manager_Total_Sale_Renewal__c, '+
                                    'Collection_Total_Sale__c,Collection_Target_Amount__c,Renewal_Tier_Changed__c,Component_1B_Payout__c,Total_Clawback_Commission_Amount__c, '+
                                    'Collection_Quota_Percentage__c,Manager_Total_Sale__c,Current_Quater__c,ADVANTAGE_New__c,ADVANTAGE_Renew__c,COBROKE_New__c, '+
                                    'COBROKE_Renew__c,DACAMPAIGN_New__c,DACAMPAIGN_Renew__c,DIGITALAGENT_New__c,DIGITALAGENT_Renew__c,DOMAINNAME_New__c,DOMAINNAME_Renew__c, '+
                                    'FEATCMA_New__c,FEATCMA_Renew__c,FEATDISP_New__c,FEATDISP_Renew__c,FEATHOMES_New__c,FEATHOMES_Renew__c,FIVESTREET_New__c, '+
                                    'FIVESTREET_Renew__c,LISTHUBPRO_New__c,LISTHUBPRO_Renew__c,MRKTBUILD_New__c,MRKTBUILD_Renew__c,SELLERLEAD_New__c,SELLERLEAD_Renew__c, '+
                                    'SELLERLEADBUNDLE_New__c,SELLERLEADBUNDLE_Renew__c,SHOWCASE_New__c,SHOWCASE_Renew__c,SIGNRIDER_New__c,SIGNRIDER_Renew__c, '+
                                    'STANDLIST_New__c,STANDLIST_Renew__c,TOPCRM_New__c,TOPCRM_Renew__c,TOPIDX_New__c,TOPIDX_Renew__c,TOPMRKSNP_New__c,TOPMRKSNP_Renew__c, '+
                                    'TOPWEB_New__c,TOPWEB_Renew__c,TOPWEBFEE_New__c,TOPWEBFEE_Renew__c,TRKPHNMBR_New__c,TRKPHNMBR_Renew__c,TURBO_New__c,TURBO_Renew__c, '+
                                    'WEBSITE_New__c,WEBSITE_Renew__c,WEBSITEFEE_New__c,WEBSITEFEE_Renew__c,REESIO_New__c,REESIO_Renew__c,RSRESPOND_New__c,RSRESPOND_Renew__c, '+
                                    'MEDIABUY_New__c ,MEDIABUY_Renew__c,Renewal_Payout__c,Quota_Attainment_Renewal__c,RSCONNECT_New__c, '+
                                    'RSCONNECT_Renew__c,RSTRANSACT_New__c,RSTRANSACT_Renew__c,BETACONNECT_New__c,BETACONNECT_Renew__c, '+
                                    'BETARESPOND_New__c,BETARESPOND_Renew__c,BETATRANSACT_New__c,BETATRANSACT_Renew__c,Record_Processed__c, '+
                                    'Total_Clawback_Commission_Amount_RD__c,LocalExpert_New__c,LocalExpert_Renew__c,LocalExpertCity_New__c,LocalExpertCity_Renew__c , ' +
                                    'Quota_StartDate__c,Manager_Total_Clawback_Commissinable_Amt__c,Manager_Collection_Sale__c, '+
            						'BLA_Tier_Changed__c,Total_of_Deals__c,Target_Deals__c,Roll_up_Total_of_Deals__c,Roll_up_BLA_Final_Commission_Amount__c,OPCITY_BLA_Payouts__c '+ //BLA comm fields		
                                'from Quota__c ';
        string queryFilter = 'where (New_Sale_Tier_Changed__c = true OR Renewal_Tier_Changed__c = true OR User_Team__c = :BLATeamName)' + 
                                    (quotaIds != null && quotaIds.size() > 0 ? ' AND Id IN :quotaIds' : '');
        //CRM-4196 [starts]
        system.debug('calculateOnlyManagerPayout: '+ calculateOnlyManagerPayout);
        if(calculateOnlyManagerPayout){
            string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
            Integer monthValue = system.today().Month();
            String brokerRDteam = 'Q2' ;   
            If (monthValue <= 3) {       
                brokerRDteam = 'Q3';
            } else if (monthValue <= 6) {
                brokerRDteam = 'Q4';
            } else if (monthValue <= 9) {
                brokerRDteam = 'Q1';
            }
            queryFilter = 'where User__c NOT IN :userIdsToExcludeQuotas '+
                            'AND User_Team__c = :managersTeam '+ 
                            'AND (Quota_StartDate__c = THIS_MONTH '+
                                'OR (Quota_StartDate__c = THIS_YEAR and Current_Quater__c =:brokerRDteam))';
        }
        dynamicQuery = dynamicQuery + '' + queryFilter;
        //CRM-4196 [ends]
        system.debug('QUERY::: '+ dynamicQuery);
        //RETRIVING PAYOUT TIER CHANGED QUOTAS WITH SPECIFIED SET OF QUOTA IDS, IF QUOTA IDS NOT SPECIFIED THEN FETCHES ALL PAYOUT TIER CHANGED QUOTAS
        return Database.getQueryLocator(dynamicQuery);
                
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Quota__c> scope) {
        system.debug('scope >> :'+scope);
        if(scope.size() > 0){
            //CRM-4196 [starts]
            if(calculateOnlyManagerPayout) {
                set<String> managers = new set<String>();
                for(Quota__c q : scope){
                    if(String.isBlank(q.Owner_Name__c)){
                        continue;
                    }
                    String managername = q.Owner_Name__c.replaceAll('\'','');
                    managername = '\'' + managername + '\'';
                    managers.add(managername);                  
                }   
                system.debug('managers >> '+ managers);
                Commissions_updateQuotaTriggerHandlr_New quotaHandler = new Commissions_updateQuotaTriggerHandlr_New();    
                quotaHandler.ManagersRollUp(scope, managers);
                //update scope;
            }
            //CRM-4196 [ends]
            //PROCESSING ALL RETRIVED QUOTAS FOR QUOTA PAYOUT CALCULATION (Commissions_QuotaPayoutCalculation_New CLASS)
            Commissions_QuotaPayoutBatchHandler_New quotapayout = new Commissions_QuotaPayoutBatchHandler_New();
            quotapayout.quotapayoutCalculation(scope);   
        }      

    }  
    //FINISH METHOD 
    global void finish(Database.BatchableContext BC) {
    }
    global void execute(SchedulableContext scon) {
        //Database.executeBatch(new Commissions_QuotaPayoutBatch_New(),100);
    }
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/