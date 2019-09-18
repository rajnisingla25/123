@isTest(SeeAllData=true)
private class PMOKPICalculateTasksWithOpenRetCasesTest {
  
  @isTest
    static void calculateTest() {
        
        List<RecordType> rlist = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Retention'];
        Case c;
        
        account acc = new account(Name= 'testAcc');
        insert acc ; 
        
        if(rlist != null && rlist.size() > 0)
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', Status='Open', RecordTypeId = rlist[0].Id, accountId = acc.id);
        else
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', Status='Open', accountId = acc.id);
        
        insert c;
        //create task for the case
        Task t = new Task(ActivityDate = (Datetime.now().Date() - 1), WhatId = c.id, status='Completed');
        insert t;
        Task t1 = new Task(ActivityDate = (Datetime.now().Date() - 1), WhatId = c.id, status='Completed');
        insert t1;

        Integer result = PMOKPICalculateTasksWithOpenRetCases.calculate(UserInfo.getUserId());
        //System.assertEquals (1, result);
    } 
    
}