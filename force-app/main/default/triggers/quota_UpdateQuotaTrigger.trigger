//New Trigger
trigger quota_UpdateQuotaTrigger on Quota__c (before insert,before update) {
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled'); 
    String usercheck='';
    if(Dtrg.Quota_PayoutCalculationTrigger__c !=null ){
        usercheck=Dtrg.Quota_PayoutCalculationTrigger__c;
    }
    // Created QuotaMap to bifurcate Send Comp Plan functionality with Regular quotas
    Map<Id,Quota__c> mapQuotasForSendCompPlan = new Map<Id,Quota__c>();
    for(Quota__c quota : Trigger.New){
        if(Trigger.OldMap != null && Trigger.OldMap.containskey(quota.Id) && Trigger.OldMap.get(quota.Id).Send_Comp_Plan__c == false && Trigger.NewMap.get(quota.Id).Send_Comp_Plan__c == true){
        	mapQuotasForSendCompPlan.put(quota.Id, quota);    
        }
    }
    
    Map<Id,Quota__c> mapQuotasSendCompPlanTo = new Map<Id,Quota__c>();
    List<Id> quotaIdsTo = new List<id>();
    for(Quota__c quotaCompPlanDocTo : Trigger.New){
        if(quotaCompPlanDocTo.Id != null && Trigger.OldMap != null && Trigger.OldMap.containskey(quotaCompPlanDocTo.Id) && String.isBlank(Trigger.OldMap.get(quotaCompPlanDocTo.Id).Send_Comp_Plan_to__c) && !String.isBlank(quotaCompPlanDocTo.Send_Comp_Plan_to__c)){
            quotaIdsTo.add(quotaCompPlanDocTo.Id);                          
            mapQuotasSendCompPlanTo.put(quotaCompPlanDocTo.Id, quotaCompPlanDocTo);    
        }
    }
    
    if(!usercheck.contains(UserInfo.getUserName())){
        List<Quota_Trigger_Execution_Setting__mdt> quotaTriggerExecSetting = [Select MasterLabel,DeveloperName,Optimization_Go_Live_Date__c,UserName__c From Quota_Trigger_Execution_Setting__mdt];
        Map<String,Quota_Trigger_Execution_Setting__mdt> mapQuotaExecSetting = new Map<String,Quota_Trigger_Execution_Setting__mdt>();
        
        if(quotaTriggerExecSetting!= null && quotaTriggerExecSetting.size() > 0){
            for(Quota_Trigger_Execution_Setting__mdt execSetting : quotaTriggerExecSetting)
                mapQuotaExecSetting.put(execSetting.DeveloperName, execSetting); 
        }
        
        Date goLiveDate = mapQuotaExecSetting.get('Run_Quota_Old_Trigger_For').Optimization_Go_Live_Date__c;
        goLiveDate = (goLiveDate != null) ? goLiveDate : Date.newInstance(2018, 09, 01);
            
        String userName = mapQuotaExecSetting.get('Run_Quota_Old_Trigger_For').UserName__c;
        List<Quota__c> lstQuota = new List<Quota__c>();
        
        for(Quota__c quota : Trigger.New){
        System.debug(quota.Quota_StartDate__c +'HHHH'+ goLiveDate);
        System.debug((quota.Quota_StartDate__c >= goLiveDate) + ' PPPP ' +userName.containsIgnoreCase(UserInfo.getUserName()));
            if(quota.Quota_StartDate__c >= goLiveDate && !userName.containsIgnoreCase(UserInfo.getUserName()) && !mapQuotasForSendCompPlan.containsKey(quota.Id) && !mapQuotasSendCompPlanTo.containsKey(quota.Id))// Added 3rd condition for Send Comp Plan
                lstQuota.add(quota);
        }
        system.debug('lstQuota=='+lstQuota);
        if(lstQuota.size() < 1)
            return;            
        
        Commissions_updateQuotaTriggerHandlr_New quota = new Commissions_updateQuotaTriggerHandlr_New();
        quota.quotaTierValuesUpdate(lstQuota,trigger.oldmap);
        
        set<String> Managers = new set<String>();
        String[] str1;
        String managername='';
        for(Quota__c quo : lstQuota){   
        if(Quo.Owner_Name__c!=null){
            managername = Quo.Owner_Name__c.replaceAll('\'','');          
            managername = '\''+managername+'\'';             
            Managers.add(managername);   
            }               
        }   
        system.debug('lstQuota=='+lstQuota);
        system.debug('Managers=='+Managers);
        quota.ManagersRollUp(lstQuota,Managers);
        
    }   
}