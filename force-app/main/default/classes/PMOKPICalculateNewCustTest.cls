@isTest
private class PMOKPICalculateNewCustTest {
  
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

        //create opportunity and its line item
        Product2 prod = new Product2(Name = 'testProd', isActive=true, S_No__c=1);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Opportunity opp = new Opportunity(Name='Test', AccountId = a.Id, StageName='Closed Won - Fulfilled', CloseDate = System.today());
        insert opp;

        OpportunityLineItem Opplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id,UnitPrice=0.01,PriceBookEntryId=standardPrice.Id);
        insert Opplineitem2;

        //create asset
        Asset asst = new Asset();
        asst.Name='TestAsset';
        asst.AccountId = a.Id;
        asst.Status = 'Cancelled';
        asst.Start_Date__c = System.today() + 90;
        asst.End_Date__c = System.today() + 95;
        insert asst;

        Integer result = PMOKPICalculateNewCust.calculate(UserInfo.getUserId());
        
    }
}