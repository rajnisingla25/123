trigger InventoryDataTrg on Inventory_Data__c (before update,after update) {

    if(Trigger.isBefore){
         for(Inventory_Data__c idd:Trigger.new){
            Idd.Is_available__c = false;
            if (Idd.Inventory_Count__c > 0 || Idd.Inventory_Count_Half__c > 0) {
                Idd.Is_available__c = true;
            }
        }
    }
                    
    if(Trigger.isAfter){
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
            // Turn off trigger if the value of custom setting field is true.
        String usercheck='';
        Boolean executeupdate = true;
        Boolean executewaitlistScoring = true;
        Set<Id> SetZipIds = new Set<Id>();
        Set<Id> SetCityIds = new Set<Id>(); //Local expert city Id set
        for(Inventory_Data__c idd:Trigger.new){
            //for local expert city
            if(idd.SOV10__c != Trigger.oldMap.get(Idd.id).SOV10__c){ // && ((idd.SOV10__c == 0 && Trigger.oldmap.get(Idd.id).sov10__c != 0) || (idd.SOV10__c > 0 && Trigger.oldMap.get(Idd.id).Sov10__c == 0))){
                SetCityIds.add(Idd.id);
            }
            
            if (Idd.SOA_Error__c) {
                executeupdate = false;  
            }
            if ((Idd.SOV20__c == Trigger.oldMap.get(Idd.id).SOV20__c) && (Idd.SOV30__c == Trigger.oldMap.get(Idd.id).SOV30__c) && (Idd.SOV50__c == Trigger.oldMap.get(Idd.id).SOV50__c) && (Idd.Inventory_Count__c == Trigger.oldMap.get(Idd.id).Inventory_Count__c) && (Idd.Inventory_Count_Half__c == Trigger.oldMap.get(Idd.id).Inventory_Count_Half__c)) {
                //executewaitlistScoring = false;
            }else {
                SetZipIds.add(Idd.id);
            }
        }
        if(Dtrg.IDTrigger__c!=null){usercheck=Dtrg.IDTrigger__c;}
        if(!usercheck.contains(UserInfo.getUserName())){
            if(executeupdate){
                LeadScoreCalculationCls lsc = new LeadScoreCalculationCls();
                lsc.CalculateScore(Trigger.newMap,Trigger.oldMap);
                if(!LeadScoreCalculationCls.skiptrigger){
                    if(executewaitlistScoring){
                        if(SetZipIds.size()>0){
                            //CRM-2541 - Pull invenotry information realtime
                            LeadScoreCalculationCls.pullInventoryWaitlistInformation(SetZipIds);
                        }
                        
                    }
                    //LeadScoreCalculationCls lsc = new LeadScoreCalculationCls();
                    lsc.CalculateOpcityScore(Trigger.newMap,Trigger.oldMap);
                }
            }
            
            //Local Expert city Code here
                        if(!setCityIds.isEmpty()){
                            LeadScoreCalculationCls.pullInventoryWaitlistInformationforCity(setCityIds);
                        }
            


        }
    }
}