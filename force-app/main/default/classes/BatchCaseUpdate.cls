//Created by Pratik for CRM-4871 on 4th October 2018
public class BatchCaseUpdate implements Database.Batchable<sObject>
{
    String query;
    
    public BatchCaseUpdate(String strQuery)
    {
        query = strQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('####'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope)
    {
        Map<Id, Case> mapCase = new Map<Id, Case>();
        for(Case newCase :scope)
            mapCase.put(newCase.id, newCase);
        
        List<Task> lstTask = [Select WhatId 
                              	From Task 
                             	Where ActivityDate < TODAY 
                             	AND WhatId IN:mapCase.keySet() 
                             	AND Status != 'Completed' 
                             	AND Subject = 'Pending Cancellation'];
        
        List<Case> lstCase = new List<Case>();
        
        for(Task task :lstTask)
        {
            if(mapCase.containsKey(task.WhatId))
            {
                Case objCase = new Case();
                objCase.Id = task.WhatId;
                objCase.Status = 'Cancel';
                lstCase.add(objCase);
            }
        }
        
        if(!lstCase.isEmpty())
            update lstCase;
    }
    
    public void finish(Database.BatchableContext BC){}
}