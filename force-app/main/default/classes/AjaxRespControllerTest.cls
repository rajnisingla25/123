@isTest
public class AjaxRespControllerTest {
    private static final Integer COUNTER = 15;
    static testMethod void ajaxTestController(){
       
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        List<Account> theAccounts = new List<Account>();
        Account theAccount;
        for(Integer index = 0; index < COUNTER; index++) {
                theAccount = TestDataFactory.createAccount(
                'The Test Account' + index,
                null,
                false
              );
            theAccount.Primary_Email__c =  'testEmail'+index+'@testClass.com';
            theAccounts.add(theAccount);
        }
        insert theAccounts;
        /* list<Account> accList = new List<Account>();
        for(integer i=0;i<11;i++){
             Account testAcc = TestDataFactory.createAccount('The Test Account', null, false);
        testAcc.Primary_Email__c = 'testAcc@move'+i+'.com';
        testAcc.Type = Constants.OFFICE_ACCOUNT_TYPE;
        testAcc.Account_Sub_Type__c = 'Prospect'; 
            acclist.add(testAcc);
        }
        insert acclist;*/
        ApexPages.currentPage().getParameters().put('sEcho','14');
        AjaxRespController response = new AjaxRespController();
        response.retrieveData();
    }

}