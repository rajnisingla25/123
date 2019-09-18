trigger Commission_CreateCommissionsforCollections on Payment_History__c (after insert,after update) {
 DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
  // Turn off trigger if the value of custom setting field is true. 
  if(Dtrg.Payment_History_Trigger__c!=UserInfo.getUserName()){
    Commissions_CreateCollectionCommsClass Collections = new Commissions_CreateCollectionCommsClass();
    if(Trigger.IsInsert && Trigger.isAfter){
        //Collections.CreateCommissions(trigger.NewMap);
    }
   } 
}