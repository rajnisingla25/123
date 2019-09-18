/* Trigger to Handle any Inserts/updates to Contact Method & it's related objects
*/
trigger ContactMethodTrigger on ContactMethod__c(before insert,before update,after insert, after update){      
    DisabledTrigger__c disableTrigger = DisabledTrigger__c.getValues('Disabled');    
    Boolean isIntegrationUser = (null != disableTrigger.ContactMethodTrigger__c && disableTrigger.ContactMethodTrigger__c.contains(UserInfo.getUserName())) || 
                                (null != disableTrigger.ContactMethodTrigger_Integration__c  && disableTrigger.ContactMethodTrigger_Integration__c.contains(UserInfo.getUserName())) ||
                                (null != disableTrigger.ContactMethodTrigger_ODS_User__c  && disableTrigger.ContactMethodTrigger_ODS_User__c.contains(UserInfo.getUserName()));
    system.debug(' *** isIntegrationUser *** '+isIntegrationUser);
     
    if(!isIntegrationUser && CheckRecursiveTrigger.executeTriggerOnce)
        return;
    
    if(Trigger.isInsert){  
        if(Trigger.isBefore){
            ContactMethodTriggerHelper.contactMethodValidations(Trigger.New,null);
            ContactMethodTriggerHelper.updateContactMethodPreferences(Trigger.New);
        }      
        if(Trigger.isAfter){
            if(!isIntegrationUser  && !System.isBatch()){
                system.debug(' entered to make SOA Call in Insert'); 
                ContactMethodTriggerHelper.webServiceCallOutToSOA(Trigger.NewMap,null);
            } 
            ContactMethodTriggerHelper.createPhoneRecords(Trigger.NewMap,null);
            ContactMethodTriggerHelper.updateContact(Trigger.NewMap,null);
            ContactMethodTriggerHelper.updateContactMethods(Trigger.NewMap,null);
        }     
    }else if(Trigger.isUpdate){  
        if(Trigger.isBefore){
            ContactMethodTriggerHelper.contactMethodValidations(Trigger.New,Trigger.OldMap);
        }      
        if(Trigger.isAfter){
            if(!isIntegrationUser && !System.isBatch()){
                system.debug(' entered to make SOA Call in Update');
                ContactMethodTriggerHelper.webServiceCallOutToSOA(Trigger.NewMap,Trigger.OldMap);  
            }
            ContactMethodTriggerHelper.createPhoneRecords(Trigger.NewMap,Trigger.OldMap);
            ContactMethodTriggerHelper.updateContact(Trigger.NewMap,Trigger.OldMap);
            ContactMethodTriggerHelper.updateContactMethods(Trigger.NewMap,Trigger.OldMap);
            SFMC_ContactMethodTriggerHelper.CheckAndUpdatePreferenceOfContactMethod(Trigger.NewMap,Trigger.OldMap);
        }      
    }  
    
}