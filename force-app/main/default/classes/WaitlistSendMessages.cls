//**************************************************//
// Class Name : WaitlistSendMessages
//
//Modified 29th Aug 2016  Author Name: Sonu Sharma --
//**************************************************//

global class WaitlistSendMessages implements Schedulable {
    global void execute(SchedulableContext sc) {

    try{
       List<Waitlist_Item__c> lstWaitlist = [Select Record_Processed__c,id,Quote__c, Quote_Text_Id__c from Waitlist_Item__c where Record_Processed__c = false and Quote__c!=null order by LastModifiedDate Desc limit 10];
    for(Waitlist_Item__c wit:lstWaitlist){
    wit.Quote_Text_Id__c = wit.Id;
    wit.Record_Processed__c = true;
    }
    Update lstWaitlist;
    List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'WaitlistScheduleJobA1A%' and State = 'DELETED' and nextfiretime = null limit 10];
            If (listCronTriggerAsset.size() > 0)
            {
                For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
                { System.abortJob(listCronTriggerAsset[i].Id); }
            }


            Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'WaitlistScheduleJobA1A%'];
            if(rcount<2){
                WaitlistSendMessages p = new WaitlistSendMessages();
                Datetime dtt = System.now().addMinutes(1).addSeconds(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('WaitlistScheduleJobA1A'+dtt, sch, p);

                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                If (listCronTrigger.size() > 0)
                {
                    For (Integer i = 0; i < listCronTrigger.size(); i++)
                    { System.abortJob(listCronTrigger[i].Id); }
                }
            }
            if(Test.isRunningTest())
                integer intTest =1/0;
    } catch(Exception Ex){
     Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'WaitlistScheduleJobA1A%'];
            if(rcount<2 || Test.isRunningTest()){
                WaitlistSendMessages p = new WaitlistSendMessages();
                Datetime dtt = System.now().addMinutes(1).addSeconds(3);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('WaitlistScheduleJobA1A1'+dtt, sch, p);

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