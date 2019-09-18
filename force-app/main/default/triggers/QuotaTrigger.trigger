trigger QuotaTrigger on Quota__c (before insert,before update,after insert,after update) {
    Commissions_QuotaTriggerHandler QTH = new Commissions_QuotaTriggerHandler();
    if(Commissions_TriggerHelperClass.quotaTriggerCheck == false){                    
        Commissions_TriggerHelperClass.quotaTriggerCheck = true;        
        if(Trigger.isBefore){
            if(Trigger.IsUpdate){
                Map<Id,Quota__c> quotaMapkicker= new Map<Id,Quota__c>();
                for(Quota__c Q : Trigger.New){
                    if(Q.User_Team__c ==  Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                        quotaMapkicker.put(Q.id,Q);
                    }
                }                
                QTH.Kicker(quotaMapkicker);               
            }           
        }                
    }
    if(Trigger.isAfter){
        system.debug('Loop 1');
        if(Trigger.IsUpdate){
        system.debug('Loop 2');
            if(Commissions_TriggerHelperClass.quotaTriggerRDCheck == false){       
                Commissions_TriggerHelperClass.quotaTriggerRDCheck = true;
                Map<Id,Quota__c> quotaMap = new Map<Id,Quota__c>();
                for(Quota__c Q : Trigger.New){
                    if(Q.User_Team__c ==  Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                        quotaMap.put(Q.id,Q);
                    }
                }
                QTH.RDTeamSplitRatio(quotaMap);
            }           
        }
    }
     
}