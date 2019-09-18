trigger quotaProductTrigger on Quota_Product__c (before Insert,before Update,after insert, after update, after Delete , after Undelete) {
     if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            quotaProductTriggerHandler.processQuotaproducts(trigger.new);
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete))
    {
        quotaProductTriggerHandler.updateQuotaObjectForQualifier(trigger.new);
        quotaProductTriggerHandler.updateCommWQP(trigger.new);//CRM-3027 - To update quota product on commissions.
    }
    if(trigger.isAfter && trigger.isDelete){
         quotaProductTriggerHandler.updateQuotaObjectForQualifier(trigger.old);
    }
}