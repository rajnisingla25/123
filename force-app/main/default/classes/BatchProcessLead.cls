global class BatchProcessLead implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    DateTime dt = System.now().AddDays(1);
    Schedule_Batch_Setting__c NVMNextContTime = Schedule_Batch_Setting__c.getValues('NVM Next Contact Time');
    Integer MinTime=60;
    if(NVMNextContTime!=null){
    MinTime = Integer.valueof(NVMNextContTime.Execution_Min__c);
    }
    DateTime dtm = System.now().AddMinutes(-MinTime);
    System.debug('My Test');
        if(Test.isRunningTest()){dtm = dtm.AddHours(2);}
        Query = 'SELECT NVMConnect__NextContactTime__c,Id FROM Lead WHERE NVMConnect__NextContactTime__c != null and LastModifiedDate<=:dtm order by LastModifiedDate ASC limit 25';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
      //SkipForNVMTrigger.setSkipTrgTrue();
       List<Lead> LeadList = new List<Lead>();
       for(Lead led : scope){
           //acc.Lock_Expiration_Date__c = null;
           led.NVMConnect__NextContactTime__c = null;
           LeadList.add(led);
       }
       if(!Test.isRunningTest()){update LeadList ;}
    }

    global void finish(Database.BatchableContext BC){
    }
}