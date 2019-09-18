@isTest
private class PMOKPICalculateAccountsUpsoldTest {
  
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
        
        List<RecordType> rlist = [Select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Case' AND DeveloperName='Retention'];
        //Create Account 
        Account a = new Account(Name='TestAcc', Display_Name__c='TestAcc');
        insert a;
        //create case with that account
        Case c = new Case(Subject='TestCase', Description='TestDesc', Type='Collections', AccountId = a.id, RecordTypeId = rlist[0].Id);
        
        insert c;
        //create Opportunity
        Opportunity o = new Opportunity(Name = 'testName', AccountId = a.id, StageName = 'Closed Won - Fulfilled', CloseDate = System.today());
        insert o;
        
        Integer result = PMOKPICalculateAccountsUpsold.calculate(UserInfo.getUserId());
    } 
}