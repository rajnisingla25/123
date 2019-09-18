Public class Commissions_UserTriggerHandler{
    Public void TeamChange(Map<id,User> NewUserMaps,Map<id,User> OldUserMaps){
            Set<id> UserIds = new Set<Id>();
            for(User Ur : NewUserMaps.Values()){
                UserIds.add(Ur.Id);
            }
            Date startOfMonth = Date.today().toStartOfMonth();
            Map<id,User> UserMaps = New Map<id,User>([Select id,Name,Username,Team__c,CreatedDate From User Where Id IN:UserIds]);
            for(User NewUser : NewUserMaps.values()){
                User OldUser = UserMaps.get(NewUser.id); 
                if(Date.Today() != startOfMonth){
                    if((OldUserMaps.get(NewUser.Id).Team__c != NUll)){
                        if((NewUser.Team__c != OldUserMaps.get(NewUser.Id).Team__c)){
                             NewUser.Team__c.AddError('Cannot Change Team Name in middle of month.');
                        }
                    }
                }
                    
            }
    }
}