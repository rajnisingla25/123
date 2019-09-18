public class LeadRoutingLogic_RoundRobin {
    
    @future
    Public static void LeadToRoute(Set<Id> setLeadIds){
        LeadRoute(setLeadIds);
    }
    
    Public static void LeadRoute(Set<Id> setLeadIds){
        set<Id> setQueueIds = new Set<Id>();  //All queue Ids
        
        //populate all Queue Ids from leads
        Set<String> setStatus = new Set<String>{'Converted','Rejected'};
            for(Lead led:[Select Id,name,ownerId,owner.type from Lead where Id=:setLeadIds and status!=:setStatus]){
                if(led.owner.type=='Queue'){
                    setQueueIds.add(led.ownerId);
                    //system.debug('setQueueIds =' + setQueueIds);
                }
            }
        
        //List<SortUserIdCountClass> lstSortUserIds = new List<SortUserIdCountClass>();
        //Map<Id,SortUserIdCountClass> mapSortUserIds = new Map<Id,SortUserIdCountClass>();
        if(setQueueIds.size()>0){
            List<Lead> leadsToUpdate = new List<Lead>();
            Map<Id,List<Id>> mapQueueUserIds = new Map<Id,List<Id>>();
            //Get all queues and its members
            //Map<Id, User> mapUser = new Map<Id, User>([select id, Ignore_assignment__c from user where Ignore_assignment__c = true]);
            //system.debug('mapUser=' + mapUser);
            
            for(GroupMember gm:[SELECT Id,UserOrGroupId,GroupId  FROM GroupMember where Group.Type='Queue' and GroupId =:setQueueIds]){
                //if(!mapQueueUserIds.containsKey(gm.GroupId)) mapQueueUserIds.put(gm.GroupId, new List<Id>());
                //if(mapUser.containskey(gm.UserOrGroupId)){ 
                    //system.debug('gm.UserOrGroupId=' + gm.UserOrGroupId);
                    if(!mapQueueUserIds.containsKey(gm.GroupId)){
                        mapQueueUserIds.put(gm.GroupId, new List<Id>());
                    }
                    
                    List<Id> userIds = mapQueueUserIds.get(gm.GroupId);
                    userIds.add(gm.UserOrGroupId);
                    userIds.sort();
                    //system.debug('userIds =' + userIds);
                    // system.debug('userIds size =' + userIds.size());
                    //system.debug('mapQueueUserIds =' + mapQueueUserIds);
                //}
            }
            
            Map<id,List<Lead>> mapQueueLeads = new Map<id,List<Lead>>();
            //get all queues and it's leads
            //for(Lead led:[Select Id,Name,ownerId from Lead where ownerId=:setQueueIds and Account__c!=null and status!=:setStatus order By LastModifiedDate Desc limit 100]){
            for(Lead led:[Select Id,Name,ownerId from Lead where ownerId=:setQueueIds and status!=:setStatus order By LastModifiedDate Desc limit 100]){
                //for(Lead led:[Select Id,Name,ownerId from Lead where ownerId=:setQueueIds and status!=:setStatus order By LastModifiedDate Desc limit 100]){    
                if(!mapQueueLeads.containsKey(led.ownerId)) mapQueueLeads.put(led.ownerId, new List<Lead>());
                List<Lead> leads = mapQueueLeads.get(led.ownerId);
                leads.add(led); 
                //system.debug('mapQueueLeads =' + mapQueueLeads);
                //List<Lead> lstLead = new List<Lead>();
                //setAllLeadIds.add(led.Id); 
                // lstAllLead.add(led);
                //mapLeadList.put(led.ownerId,lstLead);       
            }       
            
            Map<Id,Integer> mapQueueRoundRobinId = new Map<Id,Integer>();            
            
            List<Round_Robin_State__c> roundRobinStatesInsert = new List<Round_Robin_State__c>();
            List<Round_Robin_State__c> roundRobinStatesUpdate = new List<Round_Robin_State__c>();
            //get round robin state 
            //roundRobinStates = Round_Robin_State__c.getAll().Values();
            //if(roundRobinStates.size() > 0){
                for(Round_Robin_State__c roundRobinState:Round_Robin_State__c.getAll().Values()){
                    mapQueueRoundRobinId.put(roundRobinState.Name, Integer.valueOf(roundRobinState.Round_Robin_Id__c));
                }
           // }
            
            Integer roundRobinStateId = 0;
            // assign leads to queue members in round robin method
            for(Id queueId : mapQueueUserIds.keySet()){
                roundRobinStateId = mapQueueRoundRobinId.containsKey(queueId) ? mapQueueRoundRobinId.get(queueId) : 0;
                List<Id> queueMembers = mapQueueUserIds.get(queueId);
                Integer leadNumber = 0;
                Integer roundRobinId = 0;
                Integer queueMemberCount = queueMembers.size();
                if(queueMemberCount<1) continue;
                if(mapQueueLeads.get(QueueId) != null){
                    for(Lead l:mapQueueLeads.get(QueueId)){
                        roundRobinId = Math.Mod(roundRobinStateId +  leadNumber ,queueMemberCount);
                        l.ownerId = queueMembers.get(roundRobinId);
                        l.Interested_in_Tiger_Lead__c = True;
                        leadNumber += 1;
                    }
                }
                
                if(mapQueueLeads.get(QueueId) != null){
                    leadsToUpdate.addAll(mapQueueLeads.get(QueueId));
                }
                
                if(!mapQueueRoundRobinId.containsKey(queueId)){
                    //system.debug('queueId Create=' + queueId);
                    Round_Robin_State__c newRoundRobinState = new Round_Robin_State__c(Name=queueId,Round_Robin_Id__c = roundRobinId + 1 );
                    roundRobinStatesInsert.add(newRoundRobinState);
                }
                else{
                    //system.debug('queueId Update=' + queueId);
                    Round_Robin_State__c existingRoundRobinState = Round_Robin_State__c.getInstance(queueId);
                    existingRoundRobinState.Round_Robin_Id__c = roundRobinId + 1;
                    roundRobinStatesUpdate.add(existingRoundRobinState);
                }             
            }
            
            SkipTrigger.setSkipTrgTrue();
            //update round robin state and leads
            insert roundRobinStatesInsert;
            update roundRobinStatesUpdate;
            if( leadsToUpdate.size() >=1 ) {
                update leadsToUpdate;
            }
        }
    }
    
}