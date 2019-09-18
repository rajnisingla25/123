trigger InventoryAccountTrg on Inventory_Account__c (before insert,before update, after insert,after update) {
//CRM-3199 -- 

if(Trigger.IsBefore){
for(Inventory_Account__c IA:Trigger.New){
IA.Unique_relation__c = Ia.Account__c+'$$$'+Ia.Inventory_Data__c;
IF(IA.Waitlist__c ==false && IA.Waitlist_Half__c ==false && IA.has_assets__c==false){
IA.Eligibility__c = 0;
IA.Eligibility_Flex__c = 0;
IA.Fast_Price__c = 0;
IA.Flex_Price__c = 0;
}
IA.ODS_updated__c = false;
if(UserInfo.getUserName().contains('infa_cloud_user@move.com') || UserInfo.getUserName().contains('informatica_user@move.com')){
if(!Trigger.IsInsert){
if((IA.Listing__c!=Trigger.oldMap.get(IA.id).Listing__c) || (IA.Form__c!=Trigger.oldMap.get(IA.id).Form__c) || (IA.Buyers_Side__c!=Trigger.oldMap.get(IA.id).Buyers_Side__c) || (IA.Office__c!=Trigger.oldMap.get(IA.id).Office__c) || (IA.Waitlist__c!=Trigger.oldMap.get(IA.id).Waitlist__c) || (IA.Waitlist_Half__c!=Trigger.oldMap.get(IA.id).Waitlist_Half__c)){
IA.ODS_updated__c = true;
}
} else {
IA.ODS_updated__c = true;
}
}
}
}
if(!SkipIATrigger.skiptrigger){
if(trigger.isAfter){
DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true.
    String usercheck='';
    if(Dtrg.IATrigger__c!=null){usercheck=Dtrg.IATrigger__c;}
    if(!usercheck.contains(UserInfo.getUserName())){
LeadScoreCalculationCls lsc = new LeadScoreCalculationCls();
lsc.CalculateScoreInvAccount(Trigger.newMap,Trigger.oldMap);
}
}
}
}