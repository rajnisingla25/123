@isTest
public class BatchCaseUpdate_Test
{
    private static final Integer COUNTER = 10;
  	private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    
	public static testmethod void testCaseBatch()
    {
        //Inserting Customsetting for Account     
          DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
                  insert Dtrg;
          Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
          insert art;
          OrderDecompController.stopCreatingAccount = true;
         //Switch_CaseTrigger__c swc = new Switch_CaseTrigger__c(Name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = true);
            //insert swc;    
        // Inserting Test Account.
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'hsingh@appirio.com';
        theTestAccount.ShippingState  = 'CA';
        theTestAccount.ShippingCountry  = 'USA';
        insert theTestAccount;
    
         // Inserting Assets.
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
          theTestAssets.add(new Asset(
            Name = 'The Test Asset - ' + index,
            AccountId = theTestAccount.Id,
            Renewal_Status__c = 'Renew',
            Auto_Renewal__c = 'No',
            Asset_Type__c = 'Parent', 
            Fulfillment_Status__c = 'Fulfilled',          
            Billing_Period__c = 'Monthly',
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(10),        
            Price = 10.00, 
            At_Risk__c = false,        
            Status = 'Active'
          ));
        }
        insert theTestAssets;    
        system.debug('theTestAssets:' + theTestAssets.size());
        
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
            Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
          
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                insert setting;   
        // Inserting Retention Cases.
        List<Case> theTestCases = new List<Case>();
        for(Integer index = 0; index < COUNTER / 2; index++) {
          theTestCases.add(TestDataFactory.createCase(
            'Test Case #' + (index + 1),
            'Pending Cancel',
            'Retention',
            'Test Case #' + (index + 1),
            null,
            null,
            false
          ));
        }
        insert theTestCases;
        
        Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
    	//for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                theTestCases[0].Id,
                'Pending Cancellation',
                'Call',
                Date.today().adddays(-1),
                'In Progress',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTask.WhatId  = theTestCases[0].Id;
        tasklist.add(theTask);
    //}
	insert tasklist;
        
    Test.startTest();
    BatchCaseUpdate newBatchCaseUpdate = new BatchCaseUpdate('Select Id From Case Where Status = \'Pending Cancel\' Limit 1');
    Database.executeBatch(newBatchCaseUpdate, 1);
    Test.stopTest();
  }
}