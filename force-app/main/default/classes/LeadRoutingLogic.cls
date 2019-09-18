Public class LeadRoutingLogic{
@future
Public static void LeadToRoute(Set<Id> setLeadIds){
LeadRoute(setLeadIds);
}

Public static void LeadRoute(Set<Id> setLeadIds){
set<Id> setQueueIds = new Set<Id>();
Set<Id> setAllUserIds = new Set<Id>();
Set<Id> setCampaignIds = new Set<Id>();
Map<Id,Integer> mapUserCount = new Map<Id,Integer>();
Map<Id,Set<Id>> mapSetIds = new Map<Id,Set<Id>>();
Map<Id,List<Lead>> mapLeadList = new Map<Id,List<Lead>>();
Map<Id,Decimal> mapCampaignRoutingLimit = new Map<Id,Decimal>();
Map<Id,Id> mapLeadCampaignId = new Map<Id,Id>();
Set<String> setStatus = new Set<String>{'Converted','Rejected'};
for(Lead led:[Select Id,name,ownerId,owner.type from Lead where Id=:setLeadIds and status!=:setStatus]){
if(led.owner.type=='Queue'){
setQueueIds.add(led.ownerId);
}
}
List<SortUserIdCountClass> lstSortUserIds = new List<SortUserIdCountClass>();
Map<Id,SortUserIdCountClass> mapSortUserIds = new Map<Id,SortUserIdCountClass>();
if(setQueueIds.size()>0){
for(GroupMember gm:[SELECT Id,UserOrGroupId,GroupId  FROM GroupMember where Group.Type='Queue' and GroupId =:setQueueIds]){
Set<Id> setUserIds = new Set<Id>();
setAllUserIds.add(gm.UserOrGroupId);
setUserIds.add(gm.UserOrGroupId);
mapSetIds.put(gm.GroupId,setUserIds);
mapUserCount.put(gm.UserOrGroupId,0); 
SortUserIdCountClass suId = new SortUserIdCountClass();
  suId.userIds = gm.UserOrGroupId;
  suId.aleadcount = 0;
  mapSortUserIds.Put(gm.UserOrGroupId,suId);
}
 List<Lead> lstAllLead = new List<Lead>();
  Set<Id> setAllLeadIds = new Set<Id>();
  List<Id> lstAssignUserId = new List<Id>();
  
  for(Lead led:[Select Id,Name,ownerId from Lead where ownerId=:setQueueIds and Account__c!=null and status!=:setStatus order By LastModifiedDate Desc limit 100]){
  //List<Lead> lstLead = new List<Lead>();
  setAllLeadIds.add(led.Id); 
  lstAllLead.add(led);
  //mapLeadList.put(led.ownerId,lstLead);
  
  }
  for(CampaignMember cmm:[Select Id,Name,LeadId,CampaignId from CampaignMember where LeadId=:setAllLeadIds]){
  setCampaignIds.add(cmm.CampaignId);
  mapLeadCampaignId.put(cmm.LeadId,cmm.CampaignId);
  } 
 for(AggregateResult results : [select ownerId,count(Id) cnt from Lead where ownerId=:setAllUserIds and status!=:setStatus  group by ownerId]) { 
  SortUserIdCountClass suId = new SortUserIdCountClass();
  suId.userIds = (ID)results.get('ownerId');
  suId.aleadcount = Integer.valueof(results.get('cnt'));
  //lstSortUserIds.add(suId);
  mapSortUserIds.Put(suId.userIds,suId);
  mapUserCount.put((ID)results.get('ownerId'),Integer.valueof(results.get('cnt')));
  }
  System.debug(mapUserCount+'$$$');
  Robin_Round__c mhc = Robin_Round__c.getInstance('MaxCount');
//string mPhone = mhc.Corporate_number__c;
  Decimal Maxcount=mhc.Default_Size__c;
  for(Routing_Campaign__c rc:[Select Id,Name,Campaign__c,Lead_Routing_Rule__c,Lead_Routing_Rule__r.Max_Count__c from Routing_Campaign__c where Campaign__c=:setCampaignIds]){
  mapCampaignRoutingLimit.put(rc.Campaign__c,rc.Lead_Routing_Rule__r.Max_Count__c);
  Maxcount = rc.Lead_Routing_Rule__r.Max_Count__c;
  }

  SortUserIdCountClass.sortBy = SortUserIdCountClass.SORT_BY.LCount;
  lstSortUserIds = mapSortUserIds.values();
  lstSortUserIds.sort();
  System.debug('$$$$$'+lstSortUserIds);
  System.debug(lstAssignUserId.size()+'###'+lstAllLead.size());
  if(lstSortUserIds.size()>0){
  while(lstAssignUserId.size()<=lstAllLead.size()){
  System.debug(lstAssignUserId.size()+'########'+lstAllLead.size());
  integer kk=1;
  for(SortUserIdCountClass idd:lstSortUserIds){
  if(idd.aleadcount<Maxcount){
  System.debug(idd.userIds+'#####546');
  lstAssignUserId.add(idd.userIds);
  idd.aleadcount = idd.aleadcount+1;
  } else {
  kk++;
  }
  }
  if(kk>lstSortUserIds.size()){break;}
  }
  }
  Integer mincount = 0;
  if(lstAllLead.size()>=lstAssignUserId.size()){mincount = lstAssignUserId.size();} else{mincount = lstAllLead.size();}
  System.debug('$$$$$');
  for(integer ii=0;ii<mincount;ii++){
  lstAllLead[ii].ownerId=lstAssignUserId[ii];
  }
  SkipTrigger.setSkipTrgTrue();
  update lstAllLead;
  }
}
Public class SortUserIdCountWrapperClass{
Public String userIds{get;set;}
Public Decimal aleadcount{get;set;}
}
}