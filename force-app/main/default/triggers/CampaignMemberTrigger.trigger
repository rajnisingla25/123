trigger CampaignMemberTrigger on CampaignMember (after insert,after update,after delete,before insert,before update,before delete) {
        
  CampaignMemberTriggerHandler theCampaignTriggerHandler = new CampaignMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
     

    if(trigger.isAfter){

        if(trigger.isUpdate){
          
            theCampaignTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
        }

        if(trigger.isInsert){

           theCampaignTriggerHandler.onAfterInsert(trigger.newMap);
        }
        
     }
        // 
         if(trigger.isInsert && Trigger.isBefore){

           theCampaignTriggerHandler.OnBeforeInsert(trigger.new);
        }
        
        if(trigger.isDelete && trigger.isAfter)
        {
           theCampaignTriggerHandler.onAfterDelete(trigger.oldmap);   
        }
    
    

}