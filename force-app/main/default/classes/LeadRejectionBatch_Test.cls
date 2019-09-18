//Name        : LeadRejectionBatch_Test
//Description : Test class for LeadRejectionBatch.
//Frequencey  : Every Day
//Author      : Pallavi Tammana

@isTest(SeeAllData = False)
private class LeadRejectionBatch_Test{
    static testMethod void method1(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;       
        Account theAccount1 = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount1.Primary_Email__c = 'theAccount@move.com';  
        insert theAccount1;
           
        SkipTrigger.setSkipTrgTrue();
        Lead theLead = TestDataFactory.CreateLead('Test','Test','New',theAccount1.Id,null,'Test',false); 
        theLead.Ignore_Owner_Assignment__c = 'No';
        theLead.Status = 'New';
        insert theLead;
        Datetime yesterday = Datetime.now().addDays(-122);
        Test.setCreatedDate(theLead.Id, yesterday);
        update theLead;
        Test.startTest();
            LeadRejectionBatch sh1 = new LeadRejectionBatch();    
            database.executebatch(sh1, 25);  
            
        Test.stopTest();
    }
}