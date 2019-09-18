global class CaseAssignment_Batch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date startdt = Date.Today();
    Date weekStart = startdt.toStartofWeek().addDays(-1);
        String sfownerId = Service_Followup_Queue__c.getValues('OwnerId').QueueId__c;
        String query;
        Date vdate = Date.Today().addDays(-7);
        Schedule_Batch_Setting__c batchsetting = Schedule_Batch_Setting__c.getValues('MLSSupportdays');
        Date mvdate = Date.Today().addDays(Integer.valueof(batchsetting.Execution_Time_hr__c));
        //CRM-5348 - Route MLS Support Follow Up Cases ever 48 hours
        Set<String> prosoftrecordtype = new Set<String>{'ProSoft Standard','Global, ProSoft'};
        System.debug('Venu Todays Number is' + weekStart.daysBetween(startdt));
        If(weekStart.daysBetween(startdt) > 2 && weekStart.daysBetween(startdt) < 7){
        query = 'select Id,Status,Last_Worked__c,Owner.Name,LastModifiedBy.Name,RecordType.Name from Case where OwnerId = :sfownerId AND  ((RecordType.Name != :prosoftrecordtype and Type != \'MLS Support\') OR (RecordType.Name = :prosoftrecordtype and Last_Worked__c <= :vdate and Type != \'MLS Support\') OR (Type = \'MLS Support\' and Last_Worked__c <= :mvdate))';
        }
        else {
        query = 'select Id,Status,Last_Worked__c,Owner.Name,LastModifiedBy.Name,RecordType.Name from Case where OwnerId = :sfownerId AND ((RecordType.Name != :prosoftrecordtype and Type != \'MLS Support\') OR (RecordType.Name = :prosoftrecordtype and Last_Worked__c <= :vdate and Type != \'MLS Support\'))';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> updCaseList = new List<Case>();
        for(Case cs:scope){
            updCaseList.add(cs);
        }
        if(!updCaseList.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(updCaseList, dmo);            
        }

    }
    
    global void finish(Database.BatchableContext BC){
    }
}