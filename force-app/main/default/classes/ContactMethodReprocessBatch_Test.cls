//Name        : ContactMethodReprocessBatch_Test
//Description : Test class for ContactMethodReprocessBatch.
//Frequencey  : Every Day
//Author      : Pallavi Tammana

@isTest(SeeAllData = False)
public class ContactMethodReprocessBatch_Test {
	static testMethod void method1(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone('testBatch@gmail.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(c.Id,'Email','testBatch@yahoo.com',true,true,'Business Email');
        contactMethodRecord.External_ID__c = '';
        update contactMethodRecord;
        Test.startTest();
            ContactMethodReprocessBatch sh1 = new ContactMethodReprocessBatch();    
            database.executebatch(sh1, 25);  
            
        Test.stopTest();
    }
}