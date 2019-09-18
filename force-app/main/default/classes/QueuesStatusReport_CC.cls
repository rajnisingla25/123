public with sharing class QueuesStatusReport_CC {

    map<ID,QueueSobject> queuesMap = new map<ID,QueueSobject>(); 
    map<ID,Case> caseMap = new map<ID,Case>();
    list<Case> caseList = new list<Case>();
    map<ID,String> QueueNames = new map<Id,String>();
    public list<wrQueueCases> QueueCases {get;set;}

    
    public QueuesStatusReport_CC (){
     QueueCases = new list<wrQueueCases>();  
     onPageLoad(); 
    }
    
    public void onPageLoad(){
    
           // get all queues for Case object
           for(QueueSobject oQueue :[SELECT ID ,QueueId , SobjectType FROM QueueSobject WHERE SobjectType =: 'Case']){
               queuesMap.put(oQueue.QueueId,oQueue);
           }
           // all the related cases for if case owners have any queues
           caseList = [SELECT ID,OwnerID,Owner.Name FROM Case WHERE OwnerID IN: queuesMap.keyset() ];                         
           
            // split based on user or a group
            // query Queue Members and check if members is any public group
            List<GroupMember> cr_users = [Select GroupId , 
                                                 UserOrGroupId 
                                          From 
                                                 GroupMember 
                                          where GroupId  IN: queuesMap.keyset()
                                          ];
            
            set<ID> grpIds = new set<ID>();
            // Queue,Group IDs
            Map<ID,List<ID>> qGroupIDs = new Map<ID,List<ID>>();
            Map<ID,List<String>> qGroupNames = new Map<ID,List<ID>>();
            map<ID,ID> group2Queue = new map<ID,ID>();
            map<string,String> publicgroupNames = new map<string,String>();
            // Split based on the Public group
                
            for(GroupMember qs : cr_users){
                
                if(qs.UserOrGroupId != null && !queuesMap.containsKey(qs.UserOrGroupId )){                                    
                    string UserID = qs.UserOrGroupId;                
                    // Check if any of the group members have public group
                    if(!UserID.startsWith('005')) {                                                           
                         grpIds.add(qs.UserOrGroupId);                                                                                                         
                         // GroupID,QueueID                           
                         group2Queue.put(qs.UserOrGroupId,qs.GroupID);  
                                                      
                         if(!qGroupIDs.containsKey(qs.GroupId)){
                             qGroupIDs.put(qs.GroupId,new List<ID>()); 
                             qGroupIDs.get(qs.GroupID).add(qs.UserOrGroupId); 
                                                                             
                         }
                         else{                                                  
                             qGroupIDs.get(qs.GroupID).add(qs.UserOrGroupId);                             
                         }                             
                    }                
                }                
            }
            // Queue,list<Group Ids>
            //qGroupIDs
            
            // GroupID,QueueID                           
            //group2Queue
            
            map<ID,list<String>> abc = new map<ID,list<String>>();
            // get all the group names in the queue Members
            for(Group oGroup : [SELECT ID,Type,Name  FROM Group WHERE Type = 'Regular']){
                    publicgroupNames.put(oGroup.ID,oGroup.Name); 
            }
            for(ID iQuee : qGroupIDs.keyset()){
                for(id iGroup : qGroupIDs.get(iQuee))
                {
                    if(!abc.containsKey(iQuee)){
                    abc.put(iQuee,new list<String>());
                    if(publicgroupNames.get(iGroup) != null)
                    abc.get(iQuee).add(publicgroupNames.get(iGroup));
                    }
                    else{
                    if(publicgroupNames.get(iGroup) != null)
                    abc.get(iQuee).add(publicgroupNames.get(iGroup));
                    }
                }
            }
            map<ID,set<String>> gGroupStrings = new map<ID,set<String>>();
            for(ID oqId : abc.keyset())
            {                
                if(abc.containskey(oqid))
                {         
                       
                    for(string ogId : abc.get(oqID)){
                        if(!gGroupStrings.containsKey(oqId )){
                                 gGroupStrings.put(oqId ,new set<String>());
                                 gGroupStrings.get(oqId).add(ogid);                                                    
                             }
                             else{
                                 gGroupStrings.get(oqId).add(ogid);                        
                             } 
                             
                        }
                        
                 }
            }
                                                         
            system.debug('**gGroupStrings**'+gGroupStrings);                                                      
            for(Case oCase :caseList){
               if(ocase.OwnerID != null)
                   QueueNames.put(oCase.OwnerId,oCase.Owner.Name);                 
            }
            
           map<ID,String> casemap_new = new map<ID,String>();
           map<ID,String> casemap_LWD = new map<ID,String>();                      
           map<ID,String> casemap_FollowUp = new map<ID,String>();
           map<ID,String> casemap_FollowUp_LWD = new map<ID,String>();

           
           
            
           AggregateResult[] caseGR_new  = [SELECT Count(ID),OwnerID FROM Case WHERE OwnerID IN: queuesMap.keyset() AND Status = 'New' GROUP BY OwnerID];
           AggregateResult[] caseGR_LWD  = [SELECT MAX(LastModifiedDate),OwnerID FROM Case WHERE OwnerID IN: queuesMap.keyset() AND Status = 'New' GROUP BY OwnerID];           
           AggregateResult[] caseGR_FollowUp  = [SELECT Count(ID),OwnerID FROM Case WHERE OwnerID IN: queuesMap.keyset() AND Status != 'New' ANd Status != 'Closed' GROUP BY OwnerID];            
           AggregateResult[] caseGR_FollowUp_LWD  = [SELECT MAX(LastModifiedDate),OwnerID FROM Case WHERE OwnerID IN: queuesMap.keyset() AND Status != 'New' ANd Status != 'Closed' GROUP BY OwnerID];                       
          
          
            for (AggregateResult ar1 : caseGR_new )  {
                string oOwnerID = (string)ar1.get('OwnerID');
                string oCount   = ''+(Integer)ar1.get('expr0');                
                casemap_new.put(oOwnerID,oCount);
            }
            
            for (AggregateResult ar2 : caseGR_FollowUp )  {
                string oOwnerID = (string)ar2.get('OwnerID');
                string oCount   = ''+(Integer)ar2.get('expr0');                
                casemap_FollowUp.put(oOwnerID,oCount);
            }
            
            for (AggregateResult ar3 : caseGR_LWD )  {
                string oOwnerID = (string)ar3.get('OwnerID');
                datetime datetimeLWD = (DateTime)ar3.get('expr0');                
                string oLWD = ''+datetimeLWD.format('MM/dd/yyyy');
                casemap_LWD .put(oOwnerID,oLWD);
            }
            
            for (AggregateResult ar4 : caseGR_FollowUp_LWD  )  {
                string oOwnerID = (string)ar4.get('OwnerID');
                datetime datetimeLWD = (DateTime)ar4.get('expr0');                
                string oLWD = ''+datetimeLWD.format('MM/dd/yyyy');                            
                casemap_FollowUp_LWD.put(oOwnerID,oLWD);
            }
                        
            
            map<Id,String> mapQCategory = new map<ID,String>();
            
            for(Id oQueueId :queuesMap.keyset() ){
                if(oQueueId != null && QueueNames.containsKey(oQueueId)){
                    string gName = '';    
                    if( gGroupStrings.get(oQueueId) != null)                                        
                        for(string ostr :gGroupStrings.get(oQueueId))
                        {
                            gName += ostr + ' , ';            
                        }
                    for (Categorization__c oCater : Categorization__c.getAll().values())                        
                    {
                        //map<string,set<string>> mapCat = new map<String,set<string>>();
                        //if(!mapCat.containsKey(oCater.Name))
                        //    mapCat.put(oCater.Name,new set<String>());                        
                        
                        if(!String.isEmpty(oCater.Queue_Names__c)){
                            set<string> QueueNameset = new set<String>();
                            QueueNameset.addAll(stringtoSet(oCater.Queue_Names__c));
                            if(QueueNameset.contains(QueueNames.get(oQueueId))){
                                mapQCategory.put(oQueueId,oCater.Name);
                            }
                         //mapCat.get(oCater.Name).addAll(QueueNameset);
                        }
                        
                    }
                    system.debug('***eachGroup'+gGroupStrings.get(oQueueId));                                                                                     
                    QueueCases.add(new wrQueueCases(oQueueId,
                                                    QueueNames.get(oQueueId),
                                                    casemap_new.get(oQueueId),
                                                    casemap_FollowUp.get(oQueueId),
                                                    //gName,
                                                    mapQCategory.get(oQueueId),
                                                    casemap_LWD.get(oQueueId),
                                                    casemap_FollowUp_LWD.get(oQueueId))
                                  );    
                 }
            }
                                                                                  
    }
    
    public set<String> stringtoSet(string ostr)
    {
        set<string> strString = new set<String>();
        for(string ostring : ostr.split(',')){
            strString.add(oString);
        }
        return strString;
    }
    
    public class wrQueueCases{
    
        public string QueueId {get;set;}
        public string QueueName {get;set;}
        public string casesNew {get;set;}
        public string casesFollowup {get;set;}        
        public string caseNewOldestDate {get;set;}        
        public string casesFollowupOldestDate {get;set;} 
        public string GroupName {get;set;} 
        public string categoryName {get;set;}      
                        
        
            public  wrQueueCases(ID oQueueID, string oQueueName,String oCasesNew ,String oCasesFollowup,String oCatName,String ocaseNewOldestDate,String ocasesFollowupOldestDate )
            {             
                //GroupName       = oGroupName.replace(',', ''); 
                QueueName       = oQueueName;                
                casesNew        = oCasesNew;                
                casesFollowup   = oCasesFollowup;                
                caseNewOldestDate = ocaseNewOldestDate;
                casesFollowupOldestDate = ocasesFollowupOldestDate; 
                categoryName    = oCatName;
                
            }
    }
}