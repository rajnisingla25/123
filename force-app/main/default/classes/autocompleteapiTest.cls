@istest
public class autocompleteapiTest {

    static testmethod void autocompleteTest(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        insert new Waitlist_Urls__c(Name='AWSAutocompleteURL', URL__c = 'http://parser-external.geo-qa.moveaws.com/suggest?client_id=SFDC&input=');

        apexpages.currentPage().getparameters().put('input','move');
        autocomplete_api controller = new autocomplete_api();
        
    }
    static testmethod void autocompleteparamTest(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        insert new Waitlist_Urls__c(Name='AWSAutocompleteURL', URL__c = 'http://parser-external.geo-qa.moveaws.com/suggest?client_id=SFDC&input=');
        Account theAccount;       
                theAccount = TestDataFactory.createAccount('The Test Account',null,false);
            theAccount.Primary_Email__c =  'testEmail@testClass.com';
        insert theAccount;
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        apexpages.StandardController sc =new apexpages.StandardController(theAccount);
        apexpages.currentPage().getparameters().put('input','move');
        autocomplete_api controller = new autocomplete_api(sc);
        
        
    }
}