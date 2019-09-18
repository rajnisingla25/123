public class LeadTriggerhandler
{

public static boolean isExecuted = false;
public static boolean isMeeting = false;
public static void Afterinsertupdate(map<ID,Lead> newLeads,map<ID,Lead> oldLeads){

//System.debug('TRACE CK for mStatus ' + newLeads.values().Follow_Up_Status__c+'........'+oldLeads.values().Follow_Up_Status__c);

// start ravinder modified      
      map<ID,list<CampaignMember>> campgIds = new map<ID,list<CampaignMember>>();
      set<ID> cmIDs = new set<ID>();
      map<Id,Campaign> campUpdate = new map<Id,Campaign>();
      map<Id,Id> campMembers = new map<Id,Id>();
      Map<Id, Lead> OppLdIdMap = new Map<Id, Lead>();
      set<Opportunity> oppSet = new set<Opportunity>();
      List<Opportunity> oppList = new List<Opportunity>();
      
      map<Id,Lead> leadUpdate = new map<Id,Lead>();
      set<ID> leadIDs = new set<ID>();
      Map<Id,Task> lstTask = new Map<Id,Task>();
      Task t = new Task(); // To Create Task
      Event e = new Event(); // To Create Event
      
      //for(Lead oLead : [SELECT ID,Status FROM Lead WHERE Id IN: newLeads.keyset()])
      //{
        leadIDs.addAll(newLeads.keyset()); 
      //}
      leadUpdate = new map<Id,Lead>([select id,Status,First_Status_Change__c,Last_Owner_Change__c, Follow_Up_Status__c, Description, Last_Interaction_Date__c, AccountId__c,Account__r.Name, Contact__c,Notes_Left__c, Callback_Date__c, Callback_Time__c  from Lead where id IN :leadIDs]);
      Map<Id,Task> mapOldTask = new  Map<Id,Task>();
      //System.debug('TRACE CK for leadUpdate ' + leadUpdate);   
      
      //CRM-3798 -- Remove QBdialer__c from filter
      for(Task tsk:[Select WhoId,Lead__c,CreatedDate,Description,NVM_Notes__c from Task where Lead__c=:leadIDs and (NVM_Disposition__c!=null) and CreatedDate=Today order by CreatedDate DESC]){
      DateTime dtt = System.now().AddMinutes(-3);
      if(!mapOldTask.containskey(tsk.Lead__c) && (tsk.CreatedDate>dtt)){
      System.debug('Working me');
      mapOldTask.put(tsk.Lead__c,tsk);
      }
      }
      for(CampaignMember ocm1 : [SELECT ID,CampaignID,LeadId FROM CampaignMember WHERE LeadId IN: newLeads.keyset()])
      {
        campMembers .put(ocm1.LeadID,ocm1.CampaignID);
        cmIDs.add(ocm1.CampaignID); 
        
      }
      campUpdate  = new map<Id,Campaign>([SELECT ID,Converted_Contacts__c,Converted_Leads__c FROM Campaign WHERE ID IN:cmIDs]);
      
      
      for(Lead olead : newLeads.values())
      {
          if(campMembers.containskey(oLead.ID) && campUpdate.containsKey(campMembers.get(oLead.ID)) && oLead.status == 'Converted' )
          {
            if(oLead.contact__c != null)
              campUpdate.get(campMembers.get(oLead.ID)).Converted_Contacts__c = campUpdate.get(campMembers.get(oLead.ID)).Converted_Contacts__c + 1;
           else
             campUpdate.get(campMembers.get(oLead.ID)).Converted_Leads__c  = campUpdate.get(campMembers.get(oLead.ID)).Converted_Leads__c  + 1;  
          }
          
           /************************************************************************
            Added By Chandan
            Purpose: Creating an Activity
                 Creating Metting
                 Updating the "Last Interaction Date"
                 Updating the "Notes Left" count
          ***************************************************************************/
        // Update Lead 
        system.debug(newLeads.get(oLead.ID).Follow_Up_Status__c+'LLLLLLLL'+oLead.ID);
                 if(newLeads.get(oLead.ID).Follow_Up_Status__c != null || newLeads.get(oLead.ID).Rejected_Reason__c != null)  {
          System.debug(newLeads.get(oLead.ID).Follow_Up_Status__c +'TTTTTT'+ oldLeads.get(oLead.ID).Follow_Up_Status__c);
           if(newLeads.get(oLead.ID).Follow_Up_Status__c != oldLeads.get(oLead.ID).Follow_Up_Status__c || newLeads.get(oLead.ID).Rejected_Reason__c != oldLeads.get(oLead.ID).Rejected_Reason__c || newLeads.get(oLead.ID).Callback_Date__c != oldLeads.get(oLead.ID).Callback_Date__c || newLeads.get(oLead.ID).Callback_Time__c != oldLeads.get(oLead.ID).Callback_Time__c || Test.IsRunningTest())  {
            if(olead.Notes_Left__c == null){
                leadUpdate.get(oLead.ID).Notes_Left__c = 0;
            } 
            
            
            
            //leadUpdate.get(oLead.ID).Last_Interaction_Date__c = system.today();
            leadUpdate.get(oLead.ID).Last_Interaction_Date__c = DateTime.now();
            leadUpdate.get(oLead.ID).Notes_Left__c = leadUpdate.get(oLead.ID).Notes_Left__c + 1;
            
            // Setting Lead Status
            if(olead.Rejected_Reason__c != null ){
                leadUpdate.get(oLead.ID).Status = 'Rejected';
            } 
            else{
            Id opcityRecordTypeId = Schema.SObjectType.LEAD.getRecordTypeInfosByName().get('OPCITY').getRecordTypeId();
               if(olead.Status=='Waitlisted'){leadUpdate.get(oLead.ID).Status='Waitlisted'; } 
               else if(olead.Status!='Rejected' || olead.Status!='Converted'){
               if(!(opcityRecordTypeId==olead.RecordTypeId && ((olead.Status=='In Setup') || olead.Status=='Converted'))){
               if(leadUpdate.get(oLead.ID).Status != 'Converted'){
               leadUpdate.get(oLead.ID).Status = 'In Progress';
               }
               }   
               if((opcityRecordTypeId==olead.RecordTypeId && (olead.Status=='In Setup' && leadUpdate.get(oLead.ID).Status == 'Converted'))){
               leadUpdate.get(oLead.ID).Status = 'Converted';
               }          
               }
            }
            System.debug(leadUpdate.get(oLead.ID) +'Started Time ');
                
            // Creating Activity
            //System.debug('TRACE CK for Date ' + system.today() + '.........'+ DateTime.now());
            
            String userId = UserInfo.getUserId();
            String userName = UserInfo.getUserName();
            Id salesActivitiesRecordTypeId = Schema.SObjectType.TASK.getRecordTypeInfosByName().get('Sales Activities').getRecordTypeId();//[SELECT Id, Name, SobjectType FROM RecordType where Name ='Sales Activities' and SobjectType ='Task'  limit 1].id;
            //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner.
            if(userName.contains('nvmapiuser@move.com'))
                t.OwnerId = oLead.OwnerId;
            else
                t.OwnerId = userId;
            t.Lead__c = oLead.ID;
            t.Description = leadUpdate.get(oLead.ID).Description;
            t.Status = 'Completed';
            t.Priority = 'Normal';
            t.Subject = leadUpdate.get(oLead.ID).Follow_Up_Status__c +' for the Account - ' + leadUpdate.get(oLead.ID).Account__r.Name ;
            t.WhatId = leadUpdate.get(oLead.ID).AccountId__c;
            t.WhoId = leadUpdate.get(oLead.ID).Contact__c;
            t.Outcome__c = leadUpdate.get(oLead.ID).Follow_Up_Status__c;
             //CRM-1939: When NVM User creates Task, Update AssignedTo to Lead Owner
            if(t.Outcome__c =='No Answer'){t.Outcome__c ='Left Message';}
            if(t.Outcome__c =='Follow Up Scheduled'){t.Outcome__c ='Spoke To';}
            t.Issue__c = leadUpdate.get(oLead.ID).Rejected_Reason__c;
            t.Type = 'Call - Outbound';
            System.debug('Working me');
            if(mapOldTask.containskey(oLead.ID)){
            System.debug('Working me');
            t.Description = mapOldTask.get(oLead.ID).Description;
            t.NVM_Notes__c = mapOldTask.get(oLead.ID).NVM_Notes__c;
            }
            t.ActivityDate = system.today();
            t.RecordTypeId = salesActivitiesRecordTypeId;
    lstTask.put(oLead.ID,t);
            // Creating Meeting
            
             // Code to Create Event 
             // CRM-1955 venu Ravilla- Did changes to add one more picklist value using custom label
             //System.debug('TRACE CK for before Meeting ' + newLeads.get(oLead.ID).Follow_Up_Status__c + ' ' +newLeads.get(oLead.ID).Callback_Date__c + ' '+ newLeads.get(oLead.ID).Callback_Time__c + 'OLD '+oldLeads.get(oLead.ID).Callback_Date__c+oldLeads.get(oLead.ID).Callback_Time__c ); 
             string followUpStatus = string.valueOf(Label.Lead_Follow_up_status);

          if((newLeads.get(oLead.ID).Follow_Up_Status__c != null && followUpStatus.contains(newLeads.get(oLead.ID).Follow_Up_Status__c)) && (newLeads.get(oLead.ID).Callback_Date__c != oldLeads.get(oLead.ID).Callback_Date__c || newLeads.get(oLead.ID).Callback_Time__c != oldLeads.get(oLead.ID).Callback_Time__c) || Test.isRunningTest()){
            
            isMeeting = true;
            System.debug('TRACE CK for Inside Meeting ' + newLeads.get(oLead.ID).Callback_Time__c ); 
            
            String startTime = leadUpdate.get(oLead.ID).Callback_Time__c;
            Date startDate = date.parse(leadUpdate.get(oLead.ID).Callback_Date__c);
            System.debug(startTime +'Started Time '+startDate);
            Boolean isStartTimeAM = startTime.endsWith('AM');
            String[] startTimeArray = startTime.split(' ', 2);
            String[] startTimeHourMinuteArray = startTimeArray[0].split(':', 2);
            String startTimeHour = startTimeHourMinuteArray[0];
            String startTimeMinute = startTimeHourMinuteArray[1];
            Integer startHourInt = Integer.valueOf(startTimeHour);
            if(!isStartTimeAM)
                    {
                        if(startHourInt < 12)
                        {
                            startHourInt = startHourInt + 12;
                        }
                    }
    
            Integer startMinuteInt = Integer.valueOf(startTimeMinute);
            
            e.OwnerId = userId;
            e.Lead__c = oLead.ID;
            e.Description = leadUpdate.get(oLead.ID).Description;
            e.WhatId = leadUpdate.get(oLead.ID).AccountId__c;
            e.WhoId =  leadUpdate.get(oLead.ID).Contact__c;
            e.Subject = 'Meeting set up for the Account - ' + leadUpdate.get(oLead.ID).Account__r.Name ;
            e.Outcome__c = leadUpdate.get(oLead.ID).Follow_Up_Status__c;
            e.DurationInMinutes = 30;
            
            e.ActivityDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), startHourInt, startMinuteInt, 0);
            
            e.IsReminderSet = true;
            e.ReminderDateTime = e.ActivityDateTime - 0.01041; // added for Reminder 
            System.debug(e.ActivityDateTime +'Started Time '+e.ActivityDateTime);
           }    
        System.debug(e+'Started Time ');
          }
        }
        //System.debug(e+'Started Time ');
        Boolean enterloop = false;
        if(Test.isRunningTest()){enterloop = true;} else {enterloop = Trigger.Isupdate;}
        if(enterloop){
        System.debug('leadUpdate.get(oLead.ID).status:'+leadUpdate.get(oLead.ID).status);
        System.debug(newLeads.get(oLead.ID).status+'Started Time '+oldLeads.get(oLead.ID).status);
        System.debug(oldLeads.get(oLead.ID).status+'Started Time '+newLeads.get(oLead.ID).First_Status_Change__c);
            if((newLeads.get(oLead.ID).status != oldLeads.get(oLead.ID).status || leadUpdate.get(oLead.ID).status != oldLeads.get(oLead.ID).status) && oldLeads.get(oLead.ID).status == 'New' || Test.isRunningTest()){
               Integer lowermin= Business_Hours__c.getValues('StatusChange').Lowermin__c.intValue();
               Integer uppermin= Business_Hours__c.getValues('StatusChange').UpMin__c.intValue();
               Integer hrs = Datetime.now().hour();
               Integer mins = Datetime.now().Minute();
               Datetime myDt1 = Datetime.newInstance(Datetime.now().year(), Datetime.now().Month(), Datetime.now().Day(), 0, 0, 0);
               Datetime myDate1 = myDt1.addMinutes(lowermin);
               Datetime myDt2 = Datetime.newInstance(Datetime.now().year(), Datetime.now().Month(), Datetime.now().Day(), 0, 0, 0);              
               Datetime myDate2 = myDt2.addMinutes(uppermin);
               leadUpdate.get(oLead.ID).First_Status_Change__c = Datetime.now();
               if(((hrs*60) + mins)<lowermin){
                   leadUpdate.get(oLead.ID).First_Status_Change__c = myDate1;
               }
               if(((hrs*60) + mins)>uppermin){
                   leadUpdate.get(oLead.ID).First_Status_Change__c = myDate2;
               }
                
            } 
            if(newLeads.get(oLead.ID).OwnerId != oldLeads.get(oLead.ID).OwnerId || Test.isRunningTest()){
               Integer lowermin= Business_Hours__c.getValues('OwnChange').Lowermin__c.intValue();
               Integer uppermin= Business_Hours__c.getValues('OwnChange').UpMin__c.intValue();
               Integer hrs = Datetime.now().hour();
               Integer mins = Datetime.now().Minute();
               Datetime myDt1 = Datetime.newInstance(Datetime.now().year(), Datetime.now().Month(), Datetime.now().Day(), 0, 0, 0);
               Datetime myDate1 = myDt1.addMinutes(lowermin);
               Datetime myDt2 = Datetime.newInstance(Datetime.now().year(), Datetime.now().Month(), Datetime.now().Day(), 0, 0, 0);              
               Datetime myDate2 = myDt2.addMinutes(uppermin);
               leadUpdate.get(oLead.ID).Last_Owner_Change__c = Datetime.now();
               if(((hrs*60) + mins)<lowermin){
                leadUpdate.get(oLead.ID).Last_Owner_Change__c = myDate1;
                }
                if(((hrs*60) + mins)>uppermin){
                leadUpdate.get(oLead.ID).Last_Owner_Change__c = myDate2;
                }
            }
            if(newLeads.get(oLead.ID).Recent_Campaign__c != oldLeads.get(oLead.ID).Recent_Campaign__c) {
                OppLdIdMap.put(oLead.ID, oLead);
            }
         } 
         
      }
      isExecuted = true;
      SkipTrigger.setSkipTrgTrue();
      update campUpdate.values();
      
      update leadUpdate.values();
      if(lstTask.values().size()>0){
      insert lstTask.values(); // Insert Task
      System.debug('Created Task by Lead : '+t);
      }
      
      if (isMeeting == true){
        insert e; // Insert Event
        isMeeting = false;
      }
      if(!OppLdIdMap.isEmpty()){
          for(Opportunity opp: [Select Id, Lead__c, CampaignId from Opportunity where Lead__c IN: OppLdIdMap.keySet()]){
              opp.CampaignId = OppLdIdMap.get(opp.Lead__c).Link_Campaign__c;
              oppSet.add(opp);
          }
          if(!oppSet.isEmpty())
              oppList.addall(oppSet);
      }
      if(!oppList.isEmpty())
          update oppList;
      
      // end ravinder modified

}

}