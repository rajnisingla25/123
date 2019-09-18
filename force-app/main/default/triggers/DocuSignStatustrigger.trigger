trigger DocuSignStatustrigger on dsfs__DocuSign_Status__c (before update, after update, after insert) {
    DocuSignStatustriggerHandler Handler =new DocuSignStatustriggerHandler();
    //CRM-5678
    if(trigger.isBefore && trigger.isUpdate && !(DocuSignStatustriggerHandler.skipbeforeupdaterun)){
       	Handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
        DocuSignStatustriggerHandler.skipbeforeupdaterun = true;
    }//CRM-5678 Ends
    

     	if(trigger.isInsert && trigger.isAfter){
              Handler.onAfterInsert(trigger.newMap);
   		 }
         
    
    if(trigger.isAfter && (trigger.isUpdate) && !(DocuSignStatustriggerHandler.skipafterupdaterun)){
       Handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
        Handler.onAfterUpdateforWaitList(trigger.newMap);
        Handler.updateAccount(trigger.newMap);//CRM-1103 - to update account after completion of docusign for payment plan
    }
}