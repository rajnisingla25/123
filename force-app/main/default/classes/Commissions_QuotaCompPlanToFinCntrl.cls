public class Commissions_QuotaCompPlanToFinCntrl {
    
    public List<Quota__c> quotaList {get;set;}
    Set<Id> setSelectedQuotaIds = new Set<Id>();
    public String listviewURL {get;set;}
    public boolean hasAccessToSend{get;set;}
    public Set<String> setProfileNames = new Set<String>{'System Administrator','Sales Commissions Analyst','VP of Finance','Move BA','Move Developer','Admin Read Only'};
    
    public Commissions_QuotaCompPlanToFinCntrl(ApexPages.StandardSetController standardController){
        listviewURL = ApexPages.currentPage().getParameters().get('retURL');
        List<Quota__c> lst = (List<Quota__c>)standardController.getSelected();
		system.debug('TotalRecords==> '+lst.size());        
        for (Quota__c quota : (List<Quota__c>)standardController.getSelected()){ 
            setSelectedQuotaIds.add(quota.Id);
        } 
        system.debug('setSelectedQuotaIds==>'+setSelectedQuotaIds);
    }

    public PageReference sendCompPlanToFinanceUserOnly(){
        Profile profile = [Select Id,Name From Profile Where Id = :UserInfo.getProfileId() LIMIT 1];
        if(setProfileNames.contains(profile.Name))
          hasAccessToSend = true;
        else
            hasAccessToSend = false;
        
        if(!hasAccessToSend){
            return null;
        }
        else{
            
            List<Quota__c> quotaListToUpdate = new List<Quota__c>();
            if(setSelectedQuotaIds.size() > 0){
                quotaList = new List<Quota__c>([SELECT Id,Send_Comp_Plan_to__c FROM Quota__c WHERE ID IN: setSelectedQuotaIds]);
            }
            system.debug('quotaList==> '+quotaList);
            if(quotaList != null && quotaList.size() > 0){
                for(Quota__c quotaToUpdate : quotaList){
                    quotaToUpdate.Send_Comp_Plan_to__c = UserInfo.getUserEmail();
                    quotaListToUpdate.add(quotaToUpdate);
                }
            }
            system.debug('quotaListToUpdate==> '+quotaListToUpdate);
            if(quotaListToUpdate.size() > 0){
                Database.SaveResult[] updateResult = Database.update(quotaListToUpdate);
                system.debug('DMLLimit==>'+Limits.getDmlRows());
                system.debug('listviewURL==>'+listviewURL);
                if(updateResult[0].isSuccess()){
                    PageReference pageRef = new PageReference(listviewURL);
                    return pageRef;	 
                }
            }
        }       
        return null;
    }
    
    public PageReference goBackandSelectMore(){
        PageReference pageRef = new PageReference(listviewURL);
        return pageRef;
    }
    
}