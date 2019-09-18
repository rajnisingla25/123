//
// (c) 2015 NTTDATA,.
//
// Batch Class Name: LeadRoutingBatch
// Description: This batch process will be creating assets from order line items for order whose "Status" is "Created" and the boolean flag
// "Is_Order_Creation_Complete__c" is set to "true".
//
// 25th June 2015   Sonu Sharma   Original (Task # T-398617)


global class LeadRoutingBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Group grp = [SELECT Id FROM Group where Group.Type='Queue' and DeveloperName = 'Unassigned_Leads'];
        Set<Id> theOrderIdsToProcess = new Set<Id>();
        Set<Id> setQueueIds = new  Set<Id>();
        Lead_Custom_Setting__c lcs= Lead_Custom_Setting__c.getValues('LeadSetting');
        Set<String> excludeLeads = new Set<String>();
        excludeLeads.AddAll(lcs.Lead__c.split(','));
        theOrderIdsToProcess.add(grp.id);
        Lead_Batch_Schedule__c lbs = Lead_Batch_Schedule__c.getValues('LeadRoutingBatchSchedule');
        System.debug('lbs:'+lbs);
        if(lbs.Value__c != 'Yes') {
            Set<String> setStatus = new Set<String>{'Converted','Rejected'};
                for(Lead led:[SELECT Id,OwnerId FROM Lead WHERE Owner.Type='Queue' and Account__c!=null  AND OwnerId Not IN :theOrderIdsToProcess and Marketing_Lead_Type__c Not IN:excludeLeads and Ignore_Owner_Assignment__c!='Yes' and status Not IN :setStatus order by lastmodifiedDate limit 3000]){
                    if(setQueueIds.size()<11){
                        setQueueIds.add(led.ownerId);
                    }
                }
            System.debug(setQueueIds+'#######');
            for(Id ids:setQueueIds){
                String query = 'SELECT Id,OwnerId FROM Lead WHERE Owner.Type=\'Queue\' and Account__c!=null  AND OwnerId = :ids and Ignore_Owner_Assignment__c!=\'Yes\' and status Not IN :setStatus and Marketing_Lead_Type__c Not IN:excludeLeads limit 100';
                List<Lead> lstLeads =  Database.Query(query);
                
                Set<Id> setLeadIds = new Set<Id>();
                for(Lead led:lstLeads){
                    setLeadIds.add(led.id);
                }
                if(setLeadIds.size()>0){
                    //LeadRoutingLogic.LeadToRoute(setLeadIds);
                    LeadRoutingLogic_RoundRobin.LeadToRoute(setLeadIds);
                }
            }
            Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'LeadRoutingJob1A1%'];
            if(rcount<4){
                LeadRoutingBatchSchedule p = new LeadRoutingBatchSchedule();
                Datetime dtt = System.now().addMinutes(10);     
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('LeadRoutingJob1A1'+dtt, sch, p);
                
                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                If (listCronTrigger.size() > 0)
                {
                    For (Integer i = 0; i < listCronTrigger.size(); i++)
                    { System.abortJob(listCronTrigger[i].Id); }
                }
            }
        }
    }
}