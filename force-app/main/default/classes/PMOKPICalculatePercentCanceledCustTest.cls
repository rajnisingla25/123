@isTest
private class PMOKPICalculatePercentCanceledCustTest {
  
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

        
        List<Asset> assetlist = new List<Asset>();
        //create asset1
        Asset asst = new Asset();
        asst.Name='TestAsset1';
        asst.AccountId = a.Id;
        asst.Status = 'Cancelled';
        asst.Cancellation_Effective_Date__c = System.today() - 1;
        asst.Start_Date__c = System.today();
        asst.End_Date__c = System.today();
        assetlist.add(asst);

        asst = new Asset();
        asst.Name='TestAsset2';
        asst.AccountId = a.Id;
        asst.Status = 'Active';
        asst.Start_Date__c = System.today();
        asst.End_Date__c = System.today();
        asst.Fulfillment_Status__c = 'Fulfilled';
        assetlist.add(asst);

        insert assetlist;

        Decimal result = PMOKPICalculatePercentCanceledCust.calculate(UserInfo.getUserId());
        
    }
}