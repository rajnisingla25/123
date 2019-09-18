@istest
public class geo_apiTest {

    static testmethod void autocompleteTest(){
        
        apexpages.currentPage().getparameters().put('input','move');
        geo_api controller = new geo_api();
        
    }
    static testmethod void autocompleteparamTest(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account theAccount;       
                theAccount = TestDataFactory.createAccount('The Test Account',null,false);
            theAccount.Primary_Email__c =  'testEmail@testClass.com';
        insert theAccount;
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        apexpages.StandardController sc =new apexpages.StandardController(theAccount);
        apexpages.currentPage().getparameters().put('input','move');
        geo_api controller = new geo_api(sc);
        
        
    }
}