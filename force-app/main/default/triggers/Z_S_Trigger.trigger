trigger Z_S_Trigger on Zuora__Subscription__c (before insert,before update, after insert,after update) {
    
    DisabledTrigger__c dtrg= DisabledTrigger__c.getValues('Disabled');

    // Turn off trigger if the value of custom setting field is true. 
    if(dtrg.TaskTrigger__c!=UserInfo.getUserName()) { 
        
        if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
            for(Zuora__Subscription__c s:Trigger.new) {
                if (s.Asset__c != s.AssetID__c) {
                    s.Asset__c = s.AssetID__c;
                }
                 System.debug('s.CMRelationshipId__c@  '+s.CMRelationshipId__c);
                ////LCM-49 Create subscription record in Zuora application.
                if(s.CMRelationship__c != s.CMRelationshipId__c){
                    System.debug('s.CMRelationshipId__c@@  '+s.CMRelationshipId__c);
                   s.CMRelationship__c = s.CMRelationshipId__c; 
                }
            }
        }

        Z_S_TriggerHandler handler = new Z_S_TriggerHandler();
  
        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('Before executing onAfterInsert');
            handler.onAfterInsert(Trigger.new);
        }
                
        //Populate subscription info on Assets
        if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
            System.debug('Before executing updateAssetSubscriptionIds');
            handler.updateAssetSubscriptionIds(Trigger.new);
        }
    } 
}