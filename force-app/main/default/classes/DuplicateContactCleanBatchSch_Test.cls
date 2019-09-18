@isTest
private class DuplicateContactCleanBatchSch_Test{
    static testMethod void method1(){
        DuplicateContactBatch__c dcb = new DuplicateContactBatch__c(Name = 'DupContactCleanBatch', Bad_Contact_Email__c = 'BAD Email', Bad_Email__c = 'Yes');
        insert dcb;
        test.startTest();
        DuplicateContactCleanBatch_Schedule sh1 = new DuplicateContactCleanBatch_Schedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}