trigger Commissions_RDOpenbookTrigger on Commission__c (before Insert,before update){
    set<Id> QuotaIds = new Set<Id>();
    Map<Id,Commission__c> commissionMap = new Map<Id,Commission__c>();
    for(commission__c commissionRecord : trigger.New){
        if((commissionRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && 
            (commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c !=Null)){
            commissionMap.put(commissionRecord.Id,commissionRecord);
        }        
    }
    if(commissionMap.size() > 0){
        Commissions_RDOpenbookTgrHandler commission = new Commissions_RDOpenbookTgrHandler();
        commission.openBookCommission(commissionMap);
    }
}