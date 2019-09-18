@isTest
public class AccountContactMethodViewCTRLTest {
    private static testMethod void testAccountView() {
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;   
        Test.startTest();      
        PageReference pgr=page.AccountContactMethodView;
        pgr.getParameters().put('accID',acc.id);
        Test.SetCurrentPage(pgr);
        ApexPages.currentPage().getParameters().put('accID','acc.Id');
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        AccountContactMethodViewCTRL controller = new AccountContactMethodViewCTRL(sc);
        //pagereference p = controller.
        Test.stopTest();
    }

}