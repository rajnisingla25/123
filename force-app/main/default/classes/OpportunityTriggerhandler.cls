public class OpportunityTriggerhandler
{
    public static void AfterUpdateOpportunity(map<ID,Opportunity> newOpps,map<ID,Opportunity> oldOpps){
        List<Opportunity> lstOppToUpdate = new List< Opportunity >();
        
        for(Opportunity opp :newOpps.values())
        {
            if(opp.NVM_Callback_DateTime__c != oldOpps.get(opp.Id).NVM_Callback_DateTime__c && (opp.Follow_Up_Status__c == 'Follow up Scheduled- no Pitch' || opp.Follow_Up_Status__c == 'Follow up Scheduled- Pitched') || true)
            {
                lstOppToUpdate.add(opp);
            }
        }
        
        if(!lstOppToUpdate.isEmpty()){
            // handleAfterInsert(lstLeadToUpdate);
            
            List<Account> lstAccount = new List<Account>();
            Set<Id> setAccount = new Set<Id>();
            Set<Id> setOppIds = new Set<Id>();
            
            for(Opportunity optt :lstOppToUpdate)
            {
                if(optt.AccountId != Null){
                    setAccount.add(optt.AccountId);
                }
                setOppIds.add(optt.id);
            }
            
            if(!setAccount.isEmpty())
            {
                Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id,NextContactTime__c, Scheduled_CallBack__c From Account Where Id IN:setAccount]);
                Map<Id,Id> mapTaskAssignTo = new Map<Id,Id>();
                for(Task tsk:[Select id,Opportunity__c, WhatId,OwnerId,Owner.name from task where WhatId=:setOppIds order by createddate Desc limit 6]){
                    if(!tsk.Owner.name.contains('nvmapiuser@move.com') && !mapTaskAssignTo.containskey(tsk.Opportunity__c)){
                        mapTaskAssignTo.put(tsk.WhatId,tsk.OwnerId);
                    }
                }
                for(Opportunity myopp :lstOppToUpdate)
                {
                    if(myopp.AccountId != Null //&& myopp.NVM_Callback_DateTime__c != Null 
                       && mapAccount.containsKey(myopp.AccountId))
                    {
                        Account account = new Account();
                        account.Id = myopp.AccountId;
                        System.debug('Here it is');
                        
                        account.Scheduled_CallBack__c = myopp.NVM_Callback_DateTime__c;
                        //Commented by Pratik on 1st February 2019 for CRM-5497
                        //account.Callback_User__c = mapTaskAssignTo.get(myopp.Id);
                        lstAccount.add(account);
                    }
                }
                
                if(!lstAccount.isEmpty()){
                    SkipAccountTrigger.setSkipTrgTrue();
                    update lstAccount;
                }
            }
        }
    }
    
    
    
    public static void AfterUpdate(map<ID,Opportunity> newOpps,map<ID,Opportunity> oldOpps){
        List<Task> lstTask = new List<Task>();
        Map<Id,Task> mapOldTask = new  Map<Id,Task>();
        
        for(Task tsk:[Select WhoId,Lead__c,WhatId,CreatedDate,Description,NVM_Notes__c from Task where WhatId=:newOpps.keyset() and CreatedDate=Today order by CreatedDate DESC]){
            DateTime dtt = System.now().AddMinutes(-3);
            if(!mapOldTask.containskey(tsk.WhatId) && (tsk.CreatedDate>dtt)){
                System.debug('Working me');
                mapOldTask.put(tsk.WhatId,tsk);
            }
        }
        for(Opportunity opp:newOpps.values()){
            System.debug(opp+'PPPPP');
            if(opp.Follow_Up_Status__c != oldOpps.get(opp.ID).Follow_Up_Status__c || Test.isRunningTest()){
                System.debug(opp+'PPPPP');
                Task t = new Task(); // To Create Task
                
                String userId = UserInfo.getUserId();
                String userName = UserInfo.getUserName();
                Id salesActivitiesRecordTypeId = Schema.SObjectType.TASK.getRecordTypeInfosByName().get('Sales Activities').getRecordTypeId();//[SELECT Id, Name, SobjectType FROM RecordType where Name ='Sales Activities' and SobjectType ='Task'  limit 1].id;
                //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner.
                if(userName.contains('nvmapiuser@move.com'))
                    t.OwnerId = opp.OwnerId;
                else
                    t.OwnerId = userId;
                t.Opportunity__c = opp.ID;
                t.Description = opp.Description;
                t.Status = 'Completed';
                t.Priority = 'Normal';
                t.Subject = opp.Follow_Up_Status__c +' for the Renewal Opportunity - ' + opp.Name ;
                t.WhatId = opp.AccountId;
                //t.WhoId = opp.Contact__c;
                t.Outcome__c = opp.Follow_Up_Status__c;
                //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner
                if(t.Outcome__c =='No Answer'){t.Outcome__c ='Left Message';}
                if(t.Outcome__c =='Follow Up Scheduled'){t.Outcome__c ='Spoke To';}
                t.Issue__c = opp.Rejected_Reason__c;
                t.Type = 'Call - Outbound';
                System.debug('Working me');
                if(mapOldTask.containskey(opp.Id)){
                    System.debug('Working me');
                    t.Description = mapOldTask.get(opp.Id).Description;
                    t.NVM_Notes__c = mapOldTask.get(opp.Id).NVM_Notes__c;
                }
                t.ActivityDate = system.today();
                t.RecordTypeId = salesActivitiesRecordTypeId;
                lstTask.add(t);
            }
        }
        if(lstTask.size()>0){
            insert lstTask;
            
        }
    }
    
    // The following Method updates the phone fields from Contact Method during Opportunity creation when the status is New or In Progress - venkat arisa
    public static void populateOpptyPhoneFields(List<Opportunity> newOpptyList){
        Set<Id> accountsList = new Set<Id>();
        List<Opportunity> newOpportunities = new List<Opportunity>();
        for(Opportunity opptyRecord: newOpptyList){           
            if(opptyRecord.AccountId != null){
                accountsList.add(opptyRecord.AccountId);
                newOpportunities.add(opptyRecord);
            }                  
        }
        
        if(!accountsList.isEmpty()){
            system.debug(' **** accountsList *** '+accountsList);
            system.debug(' **** newOpportunities *** '+newOpportunities);
            MoveUtility.updatePhoneFields(newOpportunities,accountsList); 
        }        
    }
    // The following Method updates the Opportunity with Facebook Lead Id - CRM-6335
    public static void populateOpptyFacebookId(List<Opportunity> newOpptyList){
        Set<Id> LeadIdSet = new Set<Id>();
        System.debug('Im inside Facebook');
        for(Opportunity opptyRecord: newOpptyList){
            if(opptyRecord.Lead__c != null){
                LeadIdSet.add(opptyRecord.Lead__c);
            }                  
        }
        if(!LeadIdSet.isEmpty()){
            Map<Id,String> mapLeadFBId = new Map<Id,String>();
            for(Lead ld:[Select id,Facebook_Lead_ID__c from Lead where Id IN: LeadIdSet]){
                if(ld.Facebook_Lead_ID__c != null){
                    mapLeadFBId.put(ld.Id,ld.Facebook_Lead_ID__c);
                    System.debug('mapLeadFBId:'+mapLeadFBId);
                }
            }
            for(Opportunity opptyRecord: newOpptyList){
                System.debug('opptyRecord.Lead__c:'+opptyRecord.Lead__c);
                if(opptyRecord.Lead__c != null && mapLeadFBId.get(opptyRecord.Lead__c) != null){
                    opptyRecord.Facebook_Lead_ID__c = mapLeadFBId.get(opptyRecord.Lead__c);
                }                  
            } 
        }
    }
}