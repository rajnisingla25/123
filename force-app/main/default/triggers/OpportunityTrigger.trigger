trigger OpportunityTrigger on Opportunity (before update,after update,after Insert,before insert) {
    //static Set<Id> convertedLeads = new Set<Id>();
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    if(Dtrg.Opportunity_Trigger__c!=UserInfo.getUserName()){
        if(Trigger.isBefore && Trigger.isUpdate){
            for(Opportunity opp:Trigger.new){
                if(Opp.StageName == 'Closed Won - Fulfilled'){
                    if(Trigger.oldMap.get(opp.id).StageName == 'Closed Won - Fulfilled'){
                        Opp.CloseDate = Trigger.oldMap.get(opp.id).CloseDate;
                    } else {
                        Opp.CloseDate = System.today();
                    }
                }
                if(Opp.NextContactTime__c != null){
                    Datetime dt =System.now().addMonths(5);
                    if(Opp.NVM_contact_timestamp__c == null){
                        if(Opp.NextContactTime__c >dt){
                            opp.NVM_contact_timestamp__c = System.now();
                        } else {
                            opp.NVM_contact_timestamp__c = Opp.NextContactTime__c;
                        }
                    }
                }
            }
        }
        
        if(Trigger.isBefore && Trigger.isInsert){
             // the following method is added as part of ACP project to populate phone fields - venkat arisa
              OpportunityTriggerhandler.populateOpptyPhoneFields(Trigger.New);
            OpportunityTriggerhandler.populateOpptyFacebookId(Trigger.New);//CRM-6335
        }
        
        if(Trigger.isAfter){
            Set<Id> LeadIds = new Set<Id>();
            Map<Id,Id> mapLeadAccountIds = new Map<Id,Id>();
            List<Lead> lstLead = new List<Lead>();
            List<Lead> lstAllLead = new List<Lead>();
            
            for(Opportunity opp:Trigger.new){
                if(Opp.StageName == 'Closed Won - Fulfilled'){
                    
                    if(opp.Lead__c!=null && !orderTriggerHandlerManager.convertedLeads.contains(opp.Lead__c)){
                        LeadIds.add(opp.Lead__c);
                    }
                }
                
                
            }
            if(!LeadIds.isEmpty()){
                for(Lead led:[Select id,Name,Account__c,IsConverted,Status from Lead where Id=:LeadIds]){
                    led.Status='Converted';
                    lstLead.add(led);
                    orderTriggerHandlerManager.convertedLeads.add(led.Id);
                }
                Update lstLead;
            }
            
            
        }
        
        OpportunityTriggerhandler oppTriggerhandler = new OpportunityTriggerhandler();
        if(trigger.isAfter && trigger.isUpdate){
            //oppTriggerhandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            Set<Id> setIds = new Set<Id>();
            System.debug(setIds+'PPPPP');
            for(Opportunity oppy: trigger.new){
                if(oppy.Follow_up_status__c!=Trigger.oldMap.get(oppy.id).Follow_up_status__c){
                    setIds.add(oppy.id);
                }
            }
            if(setIds.size()>0){
                System.debug(setIds+'PPPPP');
                // OpportunityTriggerhandler oth = new OpportunityTriggerhandler();
                // OpportunityTriggerhandler.AfterUpdate(Trigger.newMap,Trigger.oldMap);
                
                OpportunityTriggerhandler.AfterUpdateOpportunity(Trigger.newMap,Trigger.oldMap);
            }
            
        }
        
        if(trigger.isAfter && trigger.isInsert){
            system.debug('inside quote update with oppty');
            //oppTriggerhandler.afterInsert(Trigger.newMap);
            List<BigMachines__Quote__c> bigMachinesQuote=new List<BigMachines__Quote__c>();
            for(Opportunity oppy: trigger.new){
                if(oppy.Bigmachine_Quote_ID1__c!=null){
                    system.debug('inside quote update with oppty');
                    BigMachines__Quote__c bmq = new BigMachines__Quote__c();
                    bmq.Id = oppy.Bigmachine_Quote_ID1__c;
                    bmq.BigMachines__Opportunity__c = oppy.Id;
                    bigMachinesQuote.add(bmq);
                    system.debug('inside quote update with oppty'+bmq);
                }
            }
            if(bigMachinesQuote!=null&& bigMachinesQuote.size()>0){
                update bigMachinesQuote;
            }
            
        }
    }
}