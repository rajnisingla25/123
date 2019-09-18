@isTest 
public class CheckAllUsingJavascriptControllerTest {

    static testMethod void test_code(){
      //  ApexPages.StandardController sc = New ApexPages.StandardController();
     	 DisabledTrigger__c Dtrg         	= new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;

    	Account acc              			= TestDataFactory.createAccount('The Test Account', null, false);
        acc.Primary_Email__c     			= 'test@test.com';
        insert acc;
        
        CheckAllUsingJavascriptController ctrl = new CheckAllUsingJavascriptController();
   		//ctrl.CheckAllUsingJavascriptController();
        
    }
    
    
    
}