trigger LeadTrigger on Lead (before insert,before update,after insert,after update){
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true. 
    system.debug(dtrg.TaskTrigger__c);
    system.debug(UserInfo.getUserName());
    
    if(Dtrg.TaskTrigger__c!=UserInfo.getUserName()){
    
     /*
     * Added by: Sarang D(Brillio)
     * Purpose: To filter out social media(LinkedIn) type of leads and create Form submission records based on that data.
    */
    if(Dtrg != null && !SFMC_LeadTriggerHelper.sfmcLeadTriggerHandlerExecuted && Trigger.isAfter && Trigger.isInsert
       && Dtrg.SocialMediaLeadTrigger__c != UserInfo.getUserName()){
           SFMC_LeadTriggerHelper.filterSocialMediaLeads(trigger.new);
    }
        if(Trigger.isBefore){
            for(Lead led:Trigger.new){
                if(led.Total_Score_Number__c != led.Total_Score__c){
                    led.Total_Score_Number__c = led.Total_Score__c;
                }
            }
        }
        if(Switch_LeadTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false){
            String userName = UserInfo.getUserName();
            if(!SkipTrigger.skiptrigger){ //&& !userName.contains('nvmapiuser@move.com'))
                List<Asset> arIIAssets;
                if(Trigger.isBefore){           
                    LeadTriggerHandlerClass LeadHandler = new LeadTriggerHandlerClass();
                    //LeadHandler.LeadDuplicate(trigger.new,trigger.isInsert);
                    map<Id,Lead> mapOldProcessLead  = new map<Id,Lead>();
                    map<Id,Lead> mapNewProcessLead  = new map<Id,Lead>();
                    for(Lead led:trigger.new){
                    if(userName.contains('eloqua_integration@move.com') ){
                    mapOldProcessLead.put(led.id,led);
                    }   else {
                    mapNewProcessLead.put(led.id,led);
                    }
                    }
                    if(mapOldProcessLead.values().size()>0 || Test.isRunningTest()){
                    LeadHandler.LeadHandlerBefore(mapOldProcessLead.values());
                    }
                    if(mapNewProcessLead.values().size()>0  || Test.isRunningTest()){
                    LeadHandler.LeadHandlerBeforeNew(mapNewProcessLead.values());
                    }
                    //CRM-1511 - Updating Referral Status based on Lead Status
                    LeadHandler.LeadReferralStatus(trigger.new,trigger.oldmap, trigger.isInsert); 
                    
                    // The below method is added as part of ACP Project to stamp Lead Phone fields from Contact Methods - Venkat Arisa
                    LeadHandler.populateLeadPhoneFields(trigger.new,trigger.oldmap); 
                    
                    LeadHandler.populateSFMCSync(trigger.new,trigger.oldmap, trigger.isInsert); 
                    
                    //Record Sharing
                    /*Commented by CK - This is not being used for Lead Managment and hence commenting this.
We might need to add this back once Lead Sharing will be used by Move */
                    
                    //LeadHandler.LeadSharing(Trigger.new);
                    
                    ARIICustomerResponseProcessing.processBeforeInsertUpdates(Trigger.oldMap, Trigger.newMap, Trigger.new, trigger.isInsert);               
                }   
                if(Trigger.isAfter){
                    LeadTriggerHandlerClass LeadHandler = new LeadTriggerHandlerClass();
                    LeadHandler.LeadHandlerAfter(Trigger.new,Trigger.newMap);
                    System.Debug('--- Inside Lead After --> ');
                    ARIICustomerResponseProcessing.processAfterRecords();
                    
                    //Updated By Pratik on 9th August 2018 for CRM-4544
                    if(Trigger.isUpdate)
                        LeadHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    
                }
                if(trigger.isAfter &&  trigger.isUpdate){        
                    if( !LeadTriggerhandler.isExecuted )
                        LeadTriggerhandler.Afterinsertupdate(trigger.newmap,trigger.oldmap);
                }
            }
        }
    }  
}