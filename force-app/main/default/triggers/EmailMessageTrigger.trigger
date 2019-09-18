trigger EmailMessageTrigger on EmailMessage (after insert) {
    
    Switch_EmailMessageTrigger__c swc = Switch_EmailMessageTrigger__c.getValues('Disabled');    
    if(!swc.Set_AccountContactMapping_Off__c){
        AccountContactMappingHandler acmh = new AccountContactMappingHandler();
        acmh.FindEmailMatch(trigger.new);
    }
    if(!swc.Set_C3ToolsCloning_Off__c){
        if(!EmailMessageHandler.isFirstRun){
            EmailMessageHandler.assignToExistingCase(trigger.new);
        }
    }
    
}