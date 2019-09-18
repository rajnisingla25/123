@isTest
private class UpdateSalesLock_Test {

    static testmethod void UpdateSalesLock_Testmethod() {
        // The query used by the batch job.
        String query = 'SELECT   Account_Sub_Type__c,Lock_Expiration_Date__c,Sales_lock_Date__c,Sales_Lock_User__c FROM Account WHERE Sales_lock_Date__c <= TODAY limit 25';

       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        // Inserting Test Account      
       Account[] Acc = new List<Account>();
       for (Integer i=0;i<10;i++) {
           Account A = new Account(
               Name='Account ' + i,
               Type='Broker',
               Display_Name__c='Broker',
               Sales_lock_Date__c = Date.Today(), 
               Sales_Lock_User__c = userinfo.getuserid(),
               billingStreet = '123 w fake',
               BillingCity='San Jose',
               billingState = 'CA',
               billingPostalCode = '95132',
               billingcountry = 'USA',
               Work_Phone__c = '6692257629'
               //RecordTypeId= '012j0000000PMBT'
               );
           Acc.add(A);
       }
       insert Acc;

      Test.StartTest();
      BatchProcessAccount objBatch = new BatchProcessAccount();
      ID batchprocessid = Database.executeBatch(objBatch);
      Test.StopTest();

       // Verify Account got updated 
       //Integer i = [SELECT COUNT() FROM Account];
       //System.assertEquals(i, 0);
    }
}