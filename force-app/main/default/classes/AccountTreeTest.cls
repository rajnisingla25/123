@isTest
public class AccountTreeTest {
    
    private static testMethod void test_accountTree(){
 
        PageReference pgr = page.AccountTree;
        Test.SetCurrentPage(pgr);
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        ApexPages.StandardController sc = New ApexPages.StandardController(testAccount);
        AccountTree controller = new AccountTree(sc); 
		controller.getFilterList();
        
      
    }
    
 

}