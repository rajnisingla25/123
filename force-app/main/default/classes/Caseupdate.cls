//Created by : Venu Ravilla- CRM-2121- To close any retentions cases owned by the WLV retentions team if all the related assets are either expired or canceled

/*DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true. 
    private static boolean run = true;
    if (Dtrg.TaskTrigger__c != UserInfo.getUserName()) */

global class Caseupdate implements database.batchable<Sobject>
{
   
  global database.querylocator start(database.batchablecontext Bc)
  {
        Id rententionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
   // string query='select id,Status, Owner_Profile__c, RecordTypeId,(select Id, parentId,status from Cases), (select id,case__c,asset_status__c from Case_Asset_Relationships__r  ) from case where Status != \''+ String.escapeSingleQuotes('closed')+'\' and RecordTypeId = \''+ String.escapeSingleQuotes(String.valueOf(RententionrecordTypeId))+'\' and Owner_Profile__c = \''+ String.escapeSingleQuotes('Move Retentions & Collections')+'\'';
      string query='select id,Status, ParentId, Owner_Profile__c, RecordTypeId, (select id,case__c,asset_status__c from Case_Asset_Relationships__r) from case where Status != \''+ String.escapeSingleQuotes('closed')+'\' and RecordTypeId = \''+ String.escapeSingleQuotes(String.valueOf(RententionrecordTypeId)) +'\' and Type = \''+ String.escapeSingleQuotes('Retention') +'\' and ParentId = null and Owner_Profile__c = \''+ String.escapeSingleQuotes('Move Retentions & Collections')+'\'';
     // string query='select id,Status, ParentId, Owner_Profile__c, RecordTypeId, (select id,case__c,asset_status__c from Case_Asset_Relationships__r) from case where Status != \''+ String.escapeSingleQuotes('closed')+'\' and RecordTypeId = \''+ String.escapeSingleQuotes(String.valueOf(RententionrecordTypeId)) +'\' and Type = \''+ String.escapeSingleQuotes('Retention') and ParentId == Null +'\' and Owner_Profile__c = \''+ String.escapeSingleQuotes('Move Retentions & Collections')+'\'';
    system.debug('*****query'+query);
    return database.getquerylocator(query);
  }
  global void execute(database.batchablecontext Bc, List<case>lstcase)
  {
        system.debug('Case List:' + lstCase);
      	system.debug('Case List Size for Processing:' + lstCase.size());       
        List<Case> caseList = new List<Case>();
        for (Case c: lstcase) {
            boolean allExpiredCancelled = True;
            boolean allExpiredChildCases = false;
            boolean isConditionChecked = false;
          for(Case_Asset_Relationship__c car :c.Case_Asset_Relationships__r)
            {
                system.debug('status ' + car.asset_status__c);  
                if (allExpiredCancelled) 
                {  
                  if (car.Asset_Status__c =='Cancelled' || car.Asset_Status__c =='Expired') 
                      allExpiredCancelled = true;
                  else
                      allExpiredCancelled = false;
                }                  
            }
            system.debug('allExpiredCancelled:' + allExpiredCancelled);
            system.debug('Case_Asset_Relationships__r Size:' + c.Case_Asset_Relationships__r.size());
            if (c.Case_Asset_Relationships__r.size() == 0)
               allExpiredCancelled = false;
            
            /* if ((allExpiredCancelled) && (c.ParentId == null))
            { 
               allExpiredChildCases = True;
            } */
            
            /* for(Case childCases :c.Cases)
            {
                if (!allExpiredChildCases) 
                {  
                  //if (childCases.status =='Closed') 
                      if (childCases.ParentId == null) 
                      allExpiredChildCases = True;
                  else
                      allExpiredChildCases = false;
                }
          
           // system.debug('status2 ' + childCases.asset_status__c);        
            } */
           // if (allExpiredCancelled && allExpiredChildCases) {
            system.debug('Case Parent Id:' + c.ParentId);
           // if (allExpiredCancelled && c.ParentId == null) {  // || string.isBlank(string.valueOf(c.parentId)
                if (allExpiredCancelled) {
                c.status = 'Closed';
                system.debug('Case Added for Close:' + c.id);
                caseList.add(c);
            }
        } 
        
        if (CaseList.size() > 0)
            system.debug('case for closing:'+ CaseList.size());
            update caseList;        
  }

    global void finish(database.batchablecontext Bc)
  {
  }
  }