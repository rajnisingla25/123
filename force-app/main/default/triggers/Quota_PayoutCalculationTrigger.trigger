/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   01-APRIL-2016
Usage           :   This trigger is to calculate payout rate for component 1A,1B,2A,2B,2C,2D,3 and 4A.
Calling Commissions_QuotaPayoutCalculation class from this trigger.
Modified By     :   Srinivas Pendli
Modified Date   :   06-APRIL-2016
Old Trigger
********************************************************************************/

trigger Quota_PayoutCalculationTrigger on Quota__c (after insert, after update,before update){
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    system.debug('');
    system.debug('TriggerEXE=='+Trigger.isExecuting);
    // Created QuotaMap to bifurcate Send Comp Plan functionality with Regular quotas
    Map<Id,Quota__c> mapQuotasForSendCompPlan = new Map<Id,Quota__c>();
    Map<Id,Quota__c> mapQuotasSendCompPlanTo = new Map<Id,Quota__c>();
    List<Id> QuotaIds= new List<Id>();
    for(Quota__c quotaCompPlanDoc : Trigger.New){
        if(quotaCompPlanDoc.Id != null && Trigger.OldMap != null && Trigger.OldMap.containskey(quotaCompPlanDoc.Id) && Trigger.OldMap.get(quotaCompPlanDoc.Id).Send_Comp_Plan__c == false && quotaCompPlanDoc.Send_Comp_Plan__c == true){
            QuotaIds.add(quotaCompPlanDoc.Id);                          
            mapQuotasForSendCompPlan.put(quotaCompPlanDoc.Id, quotaCompPlanDoc);    
        }
    }
        
    if(Trigger.isAfter && !System.isFuture() && !System.isBatch()){
        
        List<Id> quotaIdsTo = new List<id>();
        for(Quota__c quotaCompPlanDocTo : Trigger.New){
            if(quotaCompPlanDocTo.Id != null && Trigger.OldMap != null && Trigger.OldMap.containskey(quotaCompPlanDocTo.Id) && String.isBlank(Trigger.OldMap.get(quotaCompPlanDocTo.Id).Send_Comp_Plan_to__c) && !String.isBlank(quotaCompPlanDocTo.Send_Comp_Plan_to__c)){
                quotaIdsTo.add(quotaCompPlanDocTo.Id);                          
                mapQuotasSendCompPlanTo.put(quotaCompPlanDocTo.Id, quotaCompPlanDocTo);    
            }
        }
        
        system.debug('mapQuotasSendCompPlanTo='+mapQuotasSendCompPlanTo.size());
       // creating one future handler for 15 quotas to send Docusign.
        if(QuotaIds.size()>0){
            Set<Id> sendQuotaIds = new Set<Id>();
            Integer qCount =  QuotaIds.size();  
            for(Integer a = 0; a< qCount; a++){
                sendQuotaIds.add(QuotaIds[0]);
                QuotaIds.remove(0);
                if(QuotaIds.size() == 0 || sendQuotaIds.size() == 1){
                    SendAECompPlanDocusign.sendNow(sendQuotaIds,false);
                    sendQuotaIds = new Set<Id>();  
                }    
            }
        }
        
        // Send DocuSign to Finance User only
        if(quotaIdsTo.size() > 0){
            Set<Id> sendQuotaIdsTo = new Set<id>();
            Integer qCount = quotaIdsTo.size();
            for(Integer a = 0; a< qCount; a++){
                sendQuotaIdsTo.add(quotaIdsTo[0]);
                quotaIdsTo.remove(0);
                if(quotaIdsTo.size() == 0 || sendQuotaIdsTo.size() == 1){
                    system.debug('sendQuotaIdsTo==>'+ sendQuotaIdsTo);
                    SendAECompPlanDocusign.sendNow(sendQuotaIdsTo,true);
                    sendQuotaIdsTo = new Set<Id>();  
                }    
            }
        }
    }
    
    List<Quota_Trigger_Execution_Setting__mdt> quotaTriggerExecSetting = [Select MasterLabel,DeveloperName,Optimization_Go_Live_Date__c,UserName__c From Quota_Trigger_Execution_Setting__mdt];
    Map<String,Quota_Trigger_Execution_Setting__mdt> mapQuotaExecSetting = new Map<String,Quota_Trigger_Execution_Setting__mdt>();
    
    if(quotaTriggerExecSetting!= null && quotaTriggerExecSetting.size() > 0){
        for(Quota_Trigger_Execution_Setting__mdt execSetting : quotaTriggerExecSetting)
            mapQuotaExecSetting.put(execSetting.DeveloperName, execSetting); 
    }
    String usercheck='';
    if(Dtrg.Quota_PayoutCalculationTrigger__c !=null ){
        usercheck=Dtrg.Quota_PayoutCalculationTrigger__c;
    }
    
    if(!usercheck.contains(UserInfo.getUserName())){
        Date goLiveDate = mapQuotaExecSetting.get('Run_Quota_Old_Trigger_For').Optimization_Go_Live_Date__c;
        goLiveDate = goLiveDate != null ? goLiveDate : Date.newInstance(2018, 09, 01);
        String userName = mapQuotaExecSetting.get('Run_Quota_Old_Trigger_For').UserName__c;
        Set<Id> setQuotaIds = new Set<Id>();
        List<Quota__c> lstQuota = new List<Quota__c>();
        
        for(Quota__c quota : Trigger.New){
            if(!mapQuotasForSendCompPlan.containsKey(quota.Id) && !mapQuotasSendCompPlanTo.containsKey(quota.Id)){
                if(quota.Quota_EndDate__c < goLiveDate && userName.containsIgnoreCase(UserInfo.getUserName()))
                    setQuotaIds.add(quota.Id);
                lstQuota.add(quota);
            }
        }
        system.debug('setQuotaIds='+setQuotaIds);
        system.debug('lstQuota='+lstQuota);
        if(trigger.IsAfter && trigger.IsUpdate){
            if(Commissions_TriggerHelperClass.QuotaTriggerNew == false){
                Commissions_TriggerHelperClass.QuotaTriggerNew = true;                
                if(setQuotaIds.size() > 0){
                    Commissions_QuotaPayoutCalculation quota = new Commissions_QuotaPayoutCalculation(); 
                    quota.QuotaPayoutCalculation(setQuotaIds);
                }
            }
            system.debug('>>>> :'+trigger.new[0]);
            Quota__c quota = trigger.new[0];
            //ApexPages.StandardController sc = new ApexPages.standardController(quota );
            //Commissions_QuotaPageControllerRead Qupdate = new Commissions_QuotaPageControllerRead(sc);
            //Qupdate.AddMoreProducts();
        }
        if(trigger.IsBefore && trigger.IsUpdate){
            // if(Commissions_TriggerHelperClass.QuotaTriggerNew == false){
            // Commissions_TriggerHelperClass.QuotaTriggerNew = true;
            Commissions_QuotaPayoutCalculation quota = new Commissions_QuotaPayoutCalculation();            
            set<String> Managers = new set<String>();
            String[] str1;
            String managername='';
            if(lstQuota.size() > 0){
                for(Quota__c quo : lstQuota){   
                    managername = Quo.Owner_Name__c.replaceAll('\'','');          
                    managername = '\''+managername+'\'';             
                    Managers.add(managername);                  
                }   
                quota.ManagersRollUp(lstQuota,Managers);
            }
            // }
        }
    }
}