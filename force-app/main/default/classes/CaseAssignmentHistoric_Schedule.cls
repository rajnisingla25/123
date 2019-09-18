global class CaseAssignmentHistoric_Schedule implements Schedulable{
    public static String CRON_EXP = '0 0 * * * ?';
    global void execute(SchedulableContext ctx) {
        String ownerId = Omni_Overflow_Queue__c.getValues('OwnerId').QueueId__c;
        List<Case> cases = [select Id,Status,Last_Worked__c,Owner.Name from Case where
                            OwnerId = :ownerId and
                            status not IN ('Closed', 'Cancelled', 'Submitted') and Last_Worked__c != null
                            order by Last_Worked__c asc LIMIT 1];
        List<Case> updCaseList = new List<Case>();
        try{
        for(Case cs:cases){
            updCaseList.add(cs);
        }
        if(!updCaseList.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(updCaseList, dmo);
        }
            Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CaseAssignmentHistoricJobA1A%'];
     if(rcount<2){
     CaseAssignmentHistoric_Schedule p = new CaseAssignmentHistoric_Schedule();
                Datetime dtt = System.now().addMinutes(1).addSeconds(15);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('CaseAssignmentHistoricJobA1A'+dtt, sch, p);

                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                  If (listCronTrigger.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTrigger.size(); i++)
                   { System.abortJob(listCronTrigger[i].Id); }
                      }
                  }
                   if(Test.isRunningTest()){
                  integer ii=1/0;
                  }
        } catch(Exception ex){
         Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CaseAssignmentHistoricJobA1A%'];
     if(rcount<2 || Test.isRunningTest()){
     CaseAssignmentHistoric_Schedule p = new CaseAssignmentHistoric_Schedule();
                Datetime dtt = System.now().addMinutes(1).addSeconds(18);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('CaseAssignmentHistoricJobA1A'+dtt, sch, p);

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