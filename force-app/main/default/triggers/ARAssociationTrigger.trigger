trigger ARAssociationTrigger on Asset_AR_Association__c (after insert,after update,before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
        }
        if(Trigger.isUpdate){
        }
        if(Trigger.isDelete){
              ARAssociationTriggerHandler.updateARIIAssetStatus(Trigger.old, true);
        }
    }
    else{
        if(Trigger.isInsert){
            ARAssociationTriggerHandler.updateARIIAssetStatus(Trigger.new, false);
            
        }
        if(Trigger.isUpdate){
           ARAssociationTriggerHandler.updateARIIAssetStatus(Trigger.new, false);
        }
        if(Trigger.isDelete){
        } 
    }
}