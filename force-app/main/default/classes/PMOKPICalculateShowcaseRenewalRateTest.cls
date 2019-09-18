/**
 * This class contains unit tests for validating the behavior of Apex class PMOKPICalculateCustsWIncreasedInvst
*/
@isTest
private class PMOKPICalculateShowcaseRenewalRateTest {

    static testMethod void myUnitTest() {
      
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
        
              
        //Create Account
        Account a = new Account(Name='TestAcc');
        insert a;

        Product2 prod = new Product2(Name = 'Connection(SM)', isActive=true, S_No__c=1);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        //create asset
        Asset ast = new Asset(Name='Showcase', Follow_Up_Status__c  = 'Renewed', AccountId = a.id, Product2Id = prod.id, Day_One_End_Date__c = System.today(), Day_One_Total_Net__c = 7) ;
        insert ast;
        
        Integer result = PMOKPICalculateShowcaseRenewalRate.calculate(UserInfo.getUserId());
    }
}