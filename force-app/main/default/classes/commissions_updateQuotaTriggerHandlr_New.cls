/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   28-FEB-2018
Usage           :   
CODE MODOFOCATION DETAILS :
1. Modified By  :   Baswaraj Patil on 31-May-2018 - Optimized method quotaTierValuesUpdate
********************************************************************************/
Public class commissions_updateQuotaTriggerHandlr_New{
    Public Void quotaTierValuesUpdate(List<Quota__c> QuotaRecordsList,Map<id,Quota__c> QuotaRecorsListOld){
        if(QuotaRecordsList == null || QuotaRecordsList.size() < 1){
            return;
        }
        Set<Id> periodids = new Set<Id>();
        for(Quota__c quotarecord : QuotaRecordsList){
            periodids.add(quotarecord.Period_Name__c);     
        }
        if(periodids.size() < 1){
            return;
        }
      
        string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
        //string collectionTeam = CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c;
        // CRM-4551 [Start]
        Set<String> setCollectionTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
            if(string.isNotBlank(collTeamName.Team_Name__c)){
                setCollectionTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
            }
        }
        // CRM-4551 [End]
        
        Map<Id, Period__c> mapPayoutTiersPerPeriod = new Map<Id, Period__c>([select Id, 
                                                                                    (SELECT id,Name,High_Level__c,Low_Level__c,
                                                                                            Period__c,Sale_Type__c,Tier_Number__c
                                                                                    FROM Payout_Tiers__r) 
                                                                             From Period__c 
                                                                             Where Id IN :periodids]);          
            
        for(Quota__c quotarecord : QuotaRecordsList){            
            Period__c quotaPeriod = mapPayoutTiersPerPeriod.get(quotarecord.Period_Name__c);
            if(quotaPeriod == null || quotaPeriod.Payout_Tiers__r == null || quotaPeriod.Payout_Tiers__r.size() < 1){
                continue;
            }
            //CRM-4483 [Starts]
            if(QuotaRecorsListOld != NULL && quotarecord.Is_Kicker__c != QuotaRecorsListOld.get(quotarecord.id).Is_Kicker__c){
                quotarecord.New_Sale_Tier_Changed__c = TRUE;
                quotarecord.Renewal_Tier_Changed__c = TRUE;
            }
            // Ends, CRM-4483
            List<Payout_Tier__c> payouttierlst = quotaPeriod.Payout_Tiers__r;
            for(Payout_Tier__c payouttierrecord : payouttierlst){
                // CRM-4272 [Start]
                system.debug('quotarecord.User_Team__c:: '+quotarecord.User_Team__c);
                if(setCollectionTeamNames.contains(quotarecord.User_Team__c.toLowerCase())){ // CRM-4551 == collectionTeam)
                    if(quotarecord.Collection_Quota_Percentage__c >= payouttierrecord.Low_Level__c 
                            && quotarecord.Collection_Quota_Percentage__c <= payouttierrecord.High_Level__c){
                        system.debug('Tier Number: '+ payouttierrecord.Tier_Number__c );    
                        quotarecord.New_Sale_Tier_Number__c = payouttierrecord.Tier_Number__c;
                        if(QuotaRecorsListOld != NULL){
                            if(quotarecord.New_Sale_Tier_Number__c != QuotaRecorsListOld.get(quotarecord.id).New_Sale_Tier_Number__c){
                                quotarecord.New_Sale_Tier_Changed__c = TRUE;                            
                            }
                        }
                        else{                        
                            quotarecord.New_Sale_Tier_Changed__c = TRUE;              
                        }
                    }
                    continue;
                }
                if(quotarecord.User_Team__c == managersTeam && quotarecord.Collection_Target_Amount__c != null && quotarecord.Collection_Target_Amount__c > 0){
                    if(QuotaRecorsListOld != NULL && quotarecord.Collection_Quota_Percentage__c != QuotaRecorsListOld.get(quotarecord.id).Collection_Quota_Percentage__c){
                        quotarecord.New_Sale_Tier_Changed__c = TRUE;                            
                    }
                }
                // [Ends] CRM-4272
                if(quotarecord.Quota_Percentage__c >= payouttierrecord.Low_Level__c 
                        && quotarecord.Quota_Percentage__c <= payouttierrecord.High_Level__c){ 
                    quotarecord.New_Sale_Tier_Number__c = payouttierrecord.Tier_Number__c;
                    if(QuotaRecorsListOld != NULL){
                        if(quotarecord.New_Sale_Tier_Number__c != QuotaRecorsListOld.get(quotarecord.id).New_Sale_Tier_Number__c){
                            quotarecord.New_Sale_Tier_Changed__c = TRUE;
                        }
                    }
                    else{
                        quotarecord.New_Sale_Tier_Changed__c = TRUE;
                    }
                }
                if(quotarecord.Quota_Attainment_Renewal__c >= payouttierrecord.Low_Level__c && quotarecord.Quota_Attainment_Renewal__c <= payouttierrecord.High_Level__c){
                    quotarecord.Renewal_Sale_Tier_Number__c = payouttierrecord.Tier_Number__c;
                    if(QuotaRecorsListOld != NULL){
                        if(quotarecord.Renewal_Sale_Tier_Number__c != QuotaRecorsListOld.get(quotarecord.id).Renewal_Sale_Tier_Number__c){ 
                            quotarecord.Renewal_Tier_Changed__c = TRUE;                           
                        }
                    }
                    else{
                        quotarecord.Renewal_Tier_Changed__c = TRUE;
                    }
                }
            } 
        }
        // CRM-4074 - On Insert of quota, to calculate payout % for each prod
        if(QuotaRecorsListOld == null){
            commissions_QuotaPayoutBatchHandler_New quotaPayout = new commissions_QuotaPayoutBatchHandler_New();
            quotaPayout.quotaPayoutCalculation(QuotaRecordsList, true);
        }
    }
  
    Public Void managersRollUp(List<Quota__c> mgrQuota,Set<String> managersList){        
        String queryString = 'SELECT Id,Owner_Name__c, Roll_up_Total_of_Deals__c, Total_of_Deals__c, Name,Total_Sale__c,Final_Commission_Amount__c,Manager_Total_Sale__c,Managers__c,Total_Sale_Renewal__c,Manager_Total_Sale_Renewal__c,Manager_Total_Clawback_Commissinable_Amt__c,Total_Clawback__c,Collection_Total_Sale__c,Manager_Collection_Sale__c,Manager_Total_Clawback_Commission__c,Total_Clawback_Commission_Amount__c,Quota_StartDate__c,User_Team__c FROM Quota__c WHERE Managers__c INCLUDES(';
        for(String includeValue : managersList){
            queryString += includeValue + ',';
        }
        queryString = queryString.removeEnd(',') +')';
        List<Quota__c> listQuota = (List<Quota__c>)Database.query(queryString);
        
        //Map<id,quota__c> mapQuotas = new Map<id,quota__c>();
        for(Quota__c parent : mgrQuota){
            parent.Manager_Total_Sale__c = 0.0;
            parent.Manager_Total_Sale_Renewal__c = 0.0;
            parent.Manager_Total_Clawback_Commissinable_Amt__c = 0.0;
            parent.Manager_Collection_Sale__c = 0.0;
            for(Quota__c child : listQuota){
                if(String.isNotBlank(child.Managers__c) && child.Managers__c.contains(parent.Owner_Name__c) 
                        && child.Quota_StartDate__c != null && parent.Quota_StartDate__c != null 
                        && child.Quota_StartDate__c.month() == parent.Quota_StartDate__c.month()
                        && child.Quota_StartDate__c.Year() == parent.Quota_StartDate__c.Year()){
                    //MANAGER TOTAL SALE CALCULATION
                    parent.Manager_Total_Sale__c = (parent.Manager_Total_Sale__c + child.Total_Sale__c);
                    parent.Manager_Total_Sale_Renewal__c = (parent.Manager_Total_Sale_Renewal__c + child.Total_Sale_Renewal__c);
                    // CRM-4862: Last Refreshed Date Stamp on Manager Quotas
                    parent.Last_Refreshed_at__c = DateTime.now();
                    system.debug('>>'+child.Total_Clawback__c+' >> '+ child.Owner_Name__c + ', Name:'+child.Name);
                    if(child.Total_of_Deals__c != null){
                        if(parent.Roll_up_Total_of_Deals__c == null){
                            parent.Roll_up_Total_of_Deals__c = 0.0;
                        }
                        parent.Roll_up_Total_of_Deals__c += child.Total_of_Deals__c;	// BLA Commissions
                    }
                    //MANAGER TOTAL CLAWBACK CALCULATION
                    if(child.Total_Clawback__c!= null){
                        system.debug('>>'+child.Total_Clawback__c+' >> '+ child.Owner_Name__c + ', Name:'+child.Name);
                        parent.Manager_Total_Clawback_Commissinable_Amt__c=(parent.Manager_Total_Clawback_Commissinable_Amt__c+ child.Total_Clawback__c);
                        system.debug('__>> '+parent.Manager_Total_Clawback_Commissinable_Amt__c);                                      
                    }                    
                    //MANAGER COLLECTION SALE 
                    if(parent.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                        parent.Manager_Collection_Sale__c = (parent.Manager_Collection_Sale__c+ child.Collection_Total_Sale__c);                                      
                    }
                    //mapQuotas.put(Parent.id,Parent);
                }                                
            } 
        }
    }
}