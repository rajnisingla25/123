@isTest
private class PMOKPICalculatePreAuthTest {
  
    @isTest
    static void calculateTest() {
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
        
        //Create Account
        Account a = new Account(Name='TestAcc');
        insert a;
        //Create Contact
        Contact c = new Contact(LastName='test1', FirstName='test2');
        insert c;

        //Create Waitlist__c and its item
        waitlist__c w = new waitlist__c();
        w.Account__c = a.Id;
        w.Status__c = 'Active';
        w.Pre_Auth_Contact__c = c.id;
        w.Pre_Auth_Email__c = 'test@test.com';
        insert w;

        Waitlist_Item__c wi = new Waitlist_Item__c();
        wi.Waitlist__c = w.id;
        wi.Wailist_Type__c = 'Pre-Auth';

        wi.Account__c = a.id;
        wi.Market__c = 'test';
        wi.Original_Max_Spend__c = 1;
        wi.Waitlist_Expiration_Date__c = System.today();
        wi.Waitlist_ID__c = '' + w.Id;

        insert wi;


        Integer result = PMOKPICalculatePreAuth.calculate(UserInfo.getUserId());
        
    }
}