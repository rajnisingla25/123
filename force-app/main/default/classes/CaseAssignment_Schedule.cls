global class CaseAssignment_Schedule implements Schedulable{
public static String CRON_EXP = '0 0 * * * ?';
global void execute(SchedulableContext ctx) {
//CRM-1732 Batch size
Integer BatchSize=1;
Schedule_Batch_Setting__c batchsetting= Schedule_Batch_Setting__c.getValues('CaseAssignmentprocess');
if(batchsize!=null){
BatchSize = Integer.valueof(batchsetting.Execution_Time_hr__c);
}

    CaseAssignment_Batch batch = new CaseAssignment_Batch(); 
    database.executebatch(batch,BatchSize);
}
}