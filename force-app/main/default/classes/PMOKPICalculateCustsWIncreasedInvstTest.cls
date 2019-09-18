/**
 * This class contains unit tests for validating the behavior of Apex class PMOKPICalculateCustsWIncreasedInvst
*/
@isTest
private class PMOKPICalculateCustsWIncreasedInvstTest {

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

        //create opportunity and its line item
        Product2 prod = new Product2(Name = 'Connection(SM)', isActive=true, S_No__c=1);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        //create asset
        Asset ast = new Asset(Name='Test Name', AccountId = a.id, Product2Id = prod.id, Day_One_End_Date__c = System.today(), Day_One_Total_Net__c = 7) ;
        insert ast;
        
        //create order
        Order o = new Order(Accountid = a.id, EffectiveDate = system.today(), Status='Created', Type = 'Modify', Pricebook2Id = pricebookId);
        insert o;
        
        //create order product
        OrderItem oi = new OrderItem(OrderId = o.id, PricebookEntryId = standardPrice.id, Quantity= 1, UnitPrice = 10, Line_Type__c= 'Add');
        insert oi; 
        o.status = 'Complete'; update o;
        
        Integer result = PMOKPICalculateCustsWIncreasedInvst.calculate(UserInfo.getUserId());
    }
}