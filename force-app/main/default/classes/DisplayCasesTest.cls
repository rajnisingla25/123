@isTest
public class DisplayCasesTest { 
    
    
    private static testMethod void testcode(){
        
        test.startTest();
        DisabledTrigger__c Dtrg         	= new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        
        Id caseRecordTypeId			 		= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        insert new CaseRecordTypes__c(Name='Retention', Record_Type_Id__c = String.valueOf(caseRecordTypeId));
        
        
        displaycases controller = new displaycases();
        controller.QueueId = '';
        controller.getQueue = '';
        controller.caselst = null;
        controller.displaycaselist();
        controller.getQueue();
        controller.displaycase();

		Case cse 			= new Case();
		cse.Subject 		= 'test';
		cse.Description		= 'test description';
		cse.Type			= 'type';
		cse.Status			= 'New';
		insert cse;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        displaycases sccontroller = new displaycases(sc);
        
       test.stopTest();  
        
    }
    
}