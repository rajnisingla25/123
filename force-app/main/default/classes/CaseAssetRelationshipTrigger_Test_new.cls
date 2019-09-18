@isTest
private class CaseAssetRelationshipTrigger_Test_new {
  // Private Data Member.
  private static final Integer COUNTER = 5;

  private static testMethod void testTriggerFunctionality() {
  
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    // Inserting Test Account.
    Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theTestAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theTestAccount;

    // Inserting Assets.
    List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
      theTestAssets.add(new Asset(
        Name = 'The Test Asset - ' + index,
        AccountId = theTestAccount.Id,
        At_Risk__c = false,
        Status = 'Active',
        start_date__c = system.today(),
        End_Date__c = system.today().adddays(10),
        Daily_Rate_on_Asset__c = 10
      ));
    }
    insert theTestAssets;
    
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    
    // Inserting Open Retention Cases.
    List<Case> theTestCases = new List<Case>();
    for(Integer index = 0; index < COUNTER; index++) {
      theTestCases.add(TestDataFactory.createCase(
        'Open Retention Case #' + (index + 1),
        'New',
        'Retention',
        'Open Retention Case #' + (index + 1),
        null,
        null,
        false
      ));
    }
    insert theTestCases;

    Test.startTest();

    // Inserted Case Asset Relationships.
    List<Case_Asset_Relationship__c> theCaseAssetRelationships = new List<Case_Asset_Relationship__c>();
    for(Integer index = 0; index < COUNTER; index++) {
      theCaseAssetRelationships.add(new Case_Asset_Relationship__c(
        Asset__c = theTestAssets.get(index).Id,
        Case__c = theTestCases.get(index).Id
      ));
    }
    insert theCaseAssetRelationships;
    
    
    
    update theCaseAssetRelationships;
    system.assert(
      [SELECT Id FROM Asset WHERE At_Risk__c = true].size() == 5,
      'Error: The case asset relationship trigger failed to update the related assets at risk flag to true.'
    );
    
    for(Asset ast: theTestAssets){
        ast.End_Date__c = system.today().adddays(20);
    }
    update theTestAssets;
    
    // Updating Case Asset Relationships Inserted Above.
    Integer index = 4;
    for(Case_Asset_Relationship__c theCaseAssetRelationship : theCaseAssetRelationships) {
      //theCaseAssetRelationship.Asset__c = theTestAssets.get(index).Id;
      //theCaseAssetRelationship.Case__c = (index == 0) ? null : theTestCases.get(index).Id;
      index--;
    }
   // update theCaseAssetRelationships;

    //system.assert(
    //  [SELECT Id FROM Asset WHERE At_Risk__c = true].size() == 4,
    //  'Error: The case asset relationship trigger failed to re-calculate the related assets at risk flag to true.'
    //);

    // Deleting All Case Asset Relationships.
    delete theCaseAssetRelationships;
    system.assert(
      [SELECT Id FROM Asset WHERE At_Risk__c = true].size() == 0,
      'Error: The case asset relationship trigger failed to reset the related assets at risk flag to false.'
    );

    // Determining Execution Context.
    CaseAssetRelationshipTriggerHandler theHandler = new CaseAssetRelationshipTriggerHandler();
    Boolean isTriggerContext = theHandler.IsTriggerContext;
    Boolean isVisualforcePageContext = theHandler.IsVisualforcePageContext;
    Boolean isWebServiceContext = theHandler.IsWebServiceContext;
    Boolean isExecuteAnonymousContext = theHandler.IsExecuteAnonymousContext;
    system.debug('HSB: ' + isTriggerContext);
    system.debug('HSB: ' + isVisualforcePageContext);
    system.debug('HSB: ' + isWebServiceContext);
    system.debug('HSB: ' + isExecuteAnonymousContext);

    Test.stopTest();
  }
}