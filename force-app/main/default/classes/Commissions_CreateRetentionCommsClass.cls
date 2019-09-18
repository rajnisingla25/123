/*******************************************************************************
Created By          :    Srinivas Pendli    
Created Date        :    29.09.2015 
Company             :    NTT Data,Inc.
Usage               :    The main purpose of this class is to create Retention commissions for Retention team members.
                         Find the below important points to understand the business logic.                         
                         1.When ever a retention case is closed it will create a commission records based on no.of Assets.
                             if a case have 'x' number of case assets it will create a 'x' no.of commissions to the case owner                         
                         2.It will rollup commission value to Retention team member current month quota.
                         3.It will get current month payout/payout rate from payout table based a quota achived value of Retention team member
                             current month quota.
                             I.Every Retention team member Quota have team value/Name
                             II.It won't create a commission if team is not populated in the Quota or if team member doesn't have a quota or
                                 if a user is not assiged to any team (In this case Retention team).
                         4.No Clawback records for Retention team.
                         5.This code/Logic contains only Retention team commission Logic.
                         6.It contains @future method to calculate payout/payout Rate.
                             I.New payout/payout rate and quota achived value will update to all commissions of current month Retention team quota.
Modified By         :    Srinivas Pendli
Modifide Date       :    29.10.2016
************************************************************************************/

 Public without sharing class Commissions_CreateRetentionCommsClass {
    Public void CaseCommission(Map<id,Case> NewCaseAsset){
        Set<Id> caseownerIds = new Set<Id>();
        Set<Id> CaseIds = new Set<Id>();
        Map<id,Quota__c> updateQuotas = new Map<id,Quota__c>();
        Map<String,Commission__c> NewCaseCommissionList =  new Map<String,commission__c>();
        
        for(Case cs : NewCaseAsset.values()){
            if(cs.Status == 'Closed'){
                CaseIds.add(cs.Id);
                caseownerIds.add(cs.Ownerid);
            }           
        }

        if(CaseIds.size() > 0 && caseownerIds.size() > 0){
            system.debug('caseownerIds : '+caseownerIds);
            Integer MonthValue =  system.today().Month();   
            Integer YearValue = system.today().Year(); 
            Date startOfMonth = Date.today().toStartOfMonth();
            Map<id,Quota__c> mapCaseOwnerQuotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,
                                                Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_Owner__c,User_Team__c,Period_Name__r.Agent_Asset_Owner__c,
                                                Period_Year1__c,Period_Name__r.Agent_Sigh_In_AE__c,Is_Kicker__c,Current_Quater__c from Quota__c where 
                                                Period_Year1__c =: YearValue and Quota_StartDate__c =: startOfMonth and User__c In : caseownerIds]);
            system.debug('mapCaseOwnerQuotas : '+mapCaseOwnerQuotas);                                   
            if(mapCaseOwnerQuotas.size() > 0){              
                Map<id,Case_Asset_Relationship__c> mapCaseAssetRelationship = new Map<id,Case_Asset_Relationship__c>([select id,Name,Saved_Amount__c,
                                                    Asset_type__c,New_Risk__c,Asset__c,case__c from Case_Asset_Relationship__c where 
                                                    Case__c In : CaseIds]);                
                system.debug('mapCaseAssetRelationship : '+mapCaseAssetRelationship);
                
                //****************CASE OWNER CALACULATION *************************************
                Set<Id> mapCaseOwnerQuotasUserIds = new Set<Id>();
                for(Quota__c quotaUser : mapCaseOwnerQuotas.Values()){
                    mapCaseOwnerQuotasUserIds.add(quotaUser.User__c);
                }              
                Map<id,User> caseOwners  = new Map<id,User>([select id,Name,Team__c,Managers__c,ProfileId,Profile.Name,Vacation_Start_Date__c,Vacation_End_Date__c from user where 
                                       Id IN : mapCaseOwnerQuotasUserIds]);      
                
                //************************************MANAGERS CALCULATION*****************************************
                Set<String> caseOwnersManagers =  new Set<String>();        
                string[] str1;        
                for(Quota__c Qs : mapCaseOwnerQuotas.Values()){
                    string x1 = Qs.User__r.Managers__c;            
                    if(x1 != null){
                        str1 = x1.split(';');           
                        for(string str : str1){        
                            caseOwnersManagers.add(str.toLowerCase());
                        }
                    }
                }
                Map<id,Quota__c> caseOwnersManagers_Quotas = new Map<id,Quota__c>([select id,Name,User__r.Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,User_Team__c,Is_Kicker__c,
                                                                Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_owner__c,Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,
                                                                Current_Quater__c from Quota__c where Period_Year1__c =: YearValue and Quota_StartDate__c =: startOfMonth and User__r.Name In : caseOwnersManagers]);
                
                //Retention Record Types
                Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId(); 
                Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId();   
                DateTime caseModifideDate;
                
                for(Case_Asset_Relationship__c CAS : mapCaseAssetRelationship.Values()){
                    case cs = NewCaseAsset.get(CAS.Case__c);                    
                    User caseOwner = caseOwners.get(cs.OwnerId);
                    if((caseOwner.Id != Null) && (cs.status == 'Closed' && cs.Type == 'Retention') && (CAS.Asset_type__c=='Parent')){
                        set<String> ManagerNames16 = new Set<String>(); 
                        ManagerNames16.clear();
                        string[] str66;      
                        String x66 = caseOwner.Managers__c;            
                        if(x66 != null){
                            str66 = x66.split(';');           
                            for(string str : str66){
                                ManagerNames16.add(str.toLowerCase());
                            }
                        }
                        if(test.isRunningTest()){
                            caseModifideDate = system.now();
                        }
                        if(!test.isRunningTest()){
                            caseModifideDate = cs.LastModifiedDate;
                        }
                        for(Quota__c quotaRecord : mapCaseOwnerQuotas.Values()){
                            if((quotaRecord.User__c != Null) && (quotaRecord.User__c == cs.OwnerId)){
                                if(quotaRecord.Quota_StartDate__c.Month() == caseModifideDate.Month()){
                                    Commission__c commissionRecord = new Commission__c();                       
                                    commissionRecord.RecordTypeId = newSaleRT;  
                                    commissionRecord.Case_Asset_Relationship__c = CAS.id; 
                                    commissionRecord.Status__c = 'Active';                      
                                    commissionRecord.Asset_Amount__c= CAS.Saved_Amount__c;
                                    commissionRecord.Retention_Commissionable_Amount1__c = CAS.Saved_Amount__c;
                                    commissionRecord.Commission_Split__c = 100;
                                    commissionRecord.Signing_AE__c = quotaRecord.User__c;       
                                    commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                    commissionRecord.Case__c= cs.id;                        
                                    commissionRecord.User_Team__c = quotaRecord.User_Team__c; 
                                    commissionRecord.RecordTypeId = newSaleRT;  
                                     System.debug('####### commissionRecord Before If');                                                         
                                    if(commissionRecord.Retention_Commissionable_Amount1__c != 0){ 
                                        NewCaseCommissionList.put(CAS.id+'##',commissionRecord);
                                        updateQuotas.put(quotaRecord.id,quotaRecord);
                                        System.debug('####### commissionRecord end If');
                                    }
                                }
                            }
                        }                       
                        
                        for(Quota__c quotaRecord : caseOwnersManagers_Quotas.Values()){
                            if(ManagerNames16.contains(quotaRecord.User__r.Name.toLowerCase())){
                                if(!ManagerNames16.contains(caseOwner.Name.toLowerCase())){
                                    if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM)){                                       
                                        if(quotaRecord.Quota_StartDate__c.Month() == caseModifideDate.Month()){
                                            system.debug('CAS >>> 2:'+CAS.Name);
                                            Commission__c commissionRecord = new Commission__c();                       
                                            commissionRecord.RecordTypeId = newSaleManagerRT;
                                            commissionRecord.Case_Asset_Relationship__c = CAS.id;   
                                            commissionRecord.Status__c = 'Active';
                                            commissionRecord.Asset_Amount__c= CAS.Saved_Amount__c;
                                            commissionRecord.Commissionable_Amount2__c = CAS.Saved_Amount__c;
                                            commissionRecord.Commission_Split__c = 100;
                                            commissionRecord.Signing_AE__c = quotaRecord.User__c;       
                                            commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                            commissionRecord.Case__c= cs.id;
                                            commissionRecord.RecordTypeId = newSaleManagerRT;                                   
                                            commissionRecord.User_Team__c = quotaRecord.User_Team__c;                                  
                                            if(commissionRecord.Commissionable_Amount2__c != 0){  
                                                NewCaseCommissionList.put(CAS.id+'###',commissionRecord);
                                                updateQuotas.put(quotaRecord.id,quotaRecord);
                                            }
                                        }
                                    }
                                }
                            }                    
                            ManagerNames16.clear();
                        }                   
                    }                
                }
            }
        }
        system.debug('NewCaseCommissionList :'+NewCaseCommissionList.size());        
        if(NewCaseCommissionList.size () >= 0){       
            insert NewCaseCommissionList.values();  
        }
        if(updateQuotas.size() > 0){
            update updateQuotas.values();
        }
    }
}