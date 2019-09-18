trigger commissionTrigger on Commission__c (before insert, after insert, after update, after Delete, after Undelete) {
    //CRM-2988 : Added below check to not execute when it is executing from batch class.
    if(true ||!system.isBatch()) {
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
         // Turn off trigger if the value of custom setting field is true.
        String usercheck='';
        if(Dtrg.Commission_Trigger__c!=null){
            usercheck=Dtrg.Commission_Trigger__c;
        }
        if(!usercheck.contains(UserInfo.getUserName())){
            if(trigger.isBefore && (trigger.isInsert|| trigger.isUndelete)){
                commissionTriggerHandler.updateCommissionswQP(trigger.new);//CRM-3027 - To update quota product on commissions.
                commissionTriggerHandler.updateCommissionsPayoutRate(trigger.New); // CRM-4379 - Payout % to populate for Other Product Commission Records 
            }
            if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete)){
                    commissionTriggerHandler.processQuotaproducts(trigger.new);
            }
            if(trigger.isAfter && trigger.isDelete){
                commissionTriggerHandler.processQuotaproducts(trigger.old);
            }
        }
      /*  if(Trigger.isAfter && Trigger.isUpdate){
        for(Commission__c c : Trigger.new){
            if(c.Commissionable_Amount2__c ==0.0 && Trigger.oldMap.get(c.id).Commissionable_Amount2__c==100.0){
               c.AddError('Failed');
            }
            }
        }*/
    }
}