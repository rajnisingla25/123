trigger Commissions_CollectionsTrigger on Payment_History__c (after insert) {
    Commissions_CreateCollectionCommsClass collectionsMethod = new Commissions_CreateCollectionCommsClass();
    Map<Id,Payment_History__c> collectionsMap = new Map<id,Payment_History__c>();
    for(Payment_History__c PH : Trigger.New){
        //collectionsMap.put(PH.Id,Ph);
    }
    if(collectionsMap.size()> 0){
        //collectionsMethod.CreateCommissions(collectionsMap);  
    }
}