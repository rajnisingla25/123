@istest(seealldata=true)
public class AccountTreeConfiguration_Test {


         public static testMethod void AccountTreeConfiguration_Test(){
        
        
        Account AccountConfigTest = TestDataFactory.createAccount('Test Account',null,false);
        ApexPages.StandardController sc = New ApexPages.StandardController(AccountConfigTest);
        AccountTreeConfiguration controller = new AccountTreeConfiguration(sc); 
             controller.BatchSize = 1000;
             controller.GlobalSelectedFilter = 'Test Filter';
             controller.GlobalSelectedType = 'Test Select';
    
}
}