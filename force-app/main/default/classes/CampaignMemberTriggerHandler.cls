public class CampaignMemberTriggerHandler {
 

  private integer batchSize = 0;
  private boolean isExecuting = false;
  private CampaignMemberTriggerHandlerManager theManager = null;
  public CampaignMemberTriggerHandlerManager CampaignMemberManager = new CampaignMemberTriggerHandlerManager();
  
  
  public CampaignMemberTriggerHandler(Boolean isExecuting, Integer size) {
    batchSize = size;
    isExecuting = isExecuting;
    theManager = new CampaignMemberTriggerHandlerManager();
  
    }
    
    public void OnBeforeInsert(list<CampaignMember> triggernew) {
      for(CampaignMember ocamp :triggernew){
            //  if(ocamp.status != null)
            //ocamp.status = 'Responded';
        }
  }
    
  public void OnAfterInsert(map<Id,CampaignMember> triggernew) {
      CampaignMemberManager.updateCampaingns(triggernew);
  
  }  
  public void onAfterDelete(map<Id,CampaignMember> triggerold) {
            CampaignMemberManager.deleteCampaingns(triggerold);
  }
  
  
  
  public void OnAfterUpdate(map<Id,CampaignMember> triggernew,map<Id,CampaignMember> triggerold) {
  
  }
    
    
}