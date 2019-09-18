@isTest
private class PMOKPICalculateCollectionsIn7DaysTest {
  
  @isTest
    static void calculateTest() {
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
        //
        List<RecordType> rlist_ret = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Retention' LIMIT 1];
        List<RecordType> rlist_coll = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Collection' LIMIT 1];
        List<RecordType> rlist_glob = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Global' LIMIT 1];
        
        List<CaseRecordTypes__c> crtlist = new List<CaseRecordTypes__c>();
        CaseRecordTypes__c crt;
        if(rlist_ret != null && rlist_ret.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Retention';
            crt.Record_Type_Id__c = rlist_ret[0].Id;
            crtlist.add(crt);
        }
        
        if(rlist_coll != null && rlist_coll.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Collection';
            crt.Record_Type_Id__c = rlist_coll[0].Id;
            crtlist.add(crt);
        }        

        if(rlist_glob != null && rlist_glob.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Global';
            crt.Record_Type_Id__c = rlist_glob[0].Id;
            crtlist.add(crt);        
        }        
        insert crtlist;
        
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        Contact ctc = new Contact(FirstName='Test1', LastName='TestCtc', Email = 'test@test.com', AccountId = acc.id); 
        insert ctc;
        
        List<RecordType> rlist = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Collections'];
        Case c;
        if(rlist != null && rlist.size() > 0)
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', RecordTypeId = rlist[0].Id, AccountId = acc.id, ContactId = ctc.id);
        else
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', AccountId = acc.id, ContactId = ctc.id);
        
        insert c;
        //create task for the case
        List<Task> tasks = new List<Task>();
        Task t = new Task(ActivityDate = System.Today(), WhatId = c.id, Type='Call');
        tasks.add(t);
        t = new Task(ActivityDate = System.Today(), WhatId = c.id, Type='Emails');
        tasks.add(t);
        insert tasks;
        
        Integer result = PMOKPICalculateCollectionsWithin7Days.calculate(UserInfo.getUserId());
        //System.assertEquals (1, result);
    } 
    
    @isTest
    static void calculateTest1() {
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
        //
        List<RecordType> rlist_ret = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Retention' LIMIT 1];
        List<RecordType> rlist_coll = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Collection' LIMIT 1];
        List<RecordType> rlist_glob = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Global' LIMIT 1];
        
        List<CaseRecordTypes__c> crtlist = new List<CaseRecordTypes__c>();
        CaseRecordTypes__c crt;
        if(rlist_ret != null && rlist_ret.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Retention';
            crt.Record_Type_Id__c = rlist_ret[0].Id;
            crtlist.add(crt);
        }
        
        if(rlist_coll != null && rlist_coll.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Collection';
            crt.Record_Type_Id__c = rlist_coll[0].Id;
            crtlist.add(crt);
        }        

        if(rlist_glob != null && rlist_glob.size() > 0){
            crt = new CaseRecordTypes__c();
            crt.name = 'Global';
            crt.Record_Type_Id__c = rlist_glob[0].Id;
            crtlist.add(crt);        
        }        
        insert crtlist;

        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        Contact ctc = new Contact(FirstName='Test1', LastName='TestCtc', Email = 'test@test.com', AccountId = acc.id); 
        insert ctc;
        List<RecordType> rlist = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Retantion'];
        
        Case c;
        if(rlist != null && rlist.size() > 0)
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', RecordTypeId = rlist[0].Id, AccountId = acc.id, ContactId = ctc.id);
        else
            c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', AccountId = acc.id, ContactId = ctc.id);
        
        insert c;
        //create task for the case
        
        List<Task> tasks = new List<Task>();
        Task t = new Task(ActivityDate = System.Today(), WhatId = c.id, Type='Call');
        tasks.add(t);
        t = new Task(ActivityDate = System.Today(), WhatId = c.id, Type='Emails');
        tasks.add(t);
        insert tasks;
        
        Integer result = PMOKPICalculateCollectionsWithin7Days.calculate(UserInfo.getUserId());
        //System.assertEquals (1, result);
    }
    
}