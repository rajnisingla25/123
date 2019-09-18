global class BatchProcessCase implements Database.Batchable<sObject>
{
    //Created By Pratik on 24th September 2018 for CRM-4814
  String query;
    
    global Database.querylocator start(Database.BatchableContext BC)
    {
        DateTime dt = System.now().AddDays(1);
        Schedule_Batch_Setting__c NVMNextContTime = Schedule_Batch_Setting__c.getValues('NVM Next Contact Time');
        Integer MinTime = 60;
        if(NVMNextContTime != null)
          MinTime = Integer.valueof(NVMNextContTime.Execution_Min__c);
      DateTime dtm = System.now().AddMinutes(-MinTime);
      if(Test.isRunningTest())
          dtm = dtm.AddHours(2);
        
        Query = 'SELECT NVMConnect__NextContactTime__c,Id FROM Case WHERE NVMConnect__NextContactTime__c != null and LastModifiedDate <=:dtm Order By LastModifiedDate ASC Limit 4';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
      List<Case> lstCase = new List<Case>();
      for(Case newCase : scope)
        {
          newCase.NVMConnect__NextContactTime__c = null;
          lstCase.add(newCase);
    }
        
        if(!lstCase.isEmpty())
            update lstCase;
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}