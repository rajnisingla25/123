//
// (c) 2015 Appirio, Inc.
//
// Test Class Name: GetAssetHierarchy_Test
// For Apex Class: GetAssetHierarchy
// Description: Its a webservice class to extract asset hierarchy.
//
// 20th May 2015    Hemendra Singh Bhati    Original (Task # T-396116)
//
@isTest(seeAllData=false)
private class GetAssetHierarchy_Test {
    // Private Data Member.
    private static final Integer COUNTER = 10;

    private static testMethod void testAssetHierarchyWebService() {
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AccountTrigger__c ='Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;      
    // Inserting Test Account.
    Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.party_id__c = '206084041';
    theTestAccount.Primary_Email__c = 'sonu.sharma@move.com';
    theTestAccount.Preferred_Phone__c = 'Home Phone';
    theTestAccount.Home_Phone__c = '9876543210';
    theTestAccount.Phone = '9876543210';
    insert theTestAccount;

    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theTestAccount.Id, true, false);
    theContact.Email='sonu.sharma@move.com';
    theContact.Preferred_Phone__c = 'Home Phone';
    theContact.HomePhone = '9876543210';
    theContact.Phone = '9876543210';
    insert theContact;

    // Inserting Contact Relationship Record.
    Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
      Parent_Account__c = theTestAccount.Id,
      Contact_To__c = theContact.Id,
      Contact_Role__c = 'Primary Contact'
      //theContact.Contact_Role__c = 'Primary Contact';
     // theContact.Contact_To__c = 'Primary Contact';
    );
    insert theAccountRelationship;

    Test.startTest();

    // Inserting Parent Asset.
    Asset theParentAsset = new Asset(
      Name = 'The Parent Asset',
      AccountId = theTestAccount.Id,
      ContactId = theContact.Id,
      Price = 10,
      End_Date__c = Date.today().addDays(5),
      Auto_Renewal__c = 'Yes',
      Asset_Type__c = 'Parent',
      Fulfillment_Status__c = 'Pending Fulfillment',
      Line_type__c = 'Renew',
      Status = 'Active',
      Product_Account__c = theTestAccount.Id);
  
    insert theParentAsset;

    theParentAsset.Status = 'Expired';
    theParentAsset.Fulfillment_Status__c = 'Success';
    update theParentAsset;
    // Inserting FulfillTo Assets.
    List<Asset> theFulfillToAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
        theFulfillToAssets.add(new Asset(
        Name = 'The FulfillTo Asset - ' + index,
        AccountId = theTestAccount.Id,
        Parent_Asset__c = theParentAsset.Id,
        Product_Account__c = theTestAccount.Id,
        Price = 10,
        End_Date__c = Date.today().addDays(index),
        Auto_Renewal__c = 'Yes',
        Asset_Type__c = 'Fulfill To',
        Status = 'Active',
        Fulfillment_Status__c = 'Fulfilled'
      ));
    }
    insert theFulfillToAssets;

    // Inserting Participant Assets.
    List<Asset> theParticipantAssets = new List<Asset>();
    for(Asset theFulfillToAsset : theFulfillToAssets) {
      for(Integer index = 0; index < 2; index++) {
        theParticipantAssets.add(new Asset(
          Name = 'The Participant Asset - ' + index,
          AccountId = theTestAccount.Id,
          Parent_Asset__c = theFulfillToAsset.Id,
          Product_Account__c = theTestAccount.Id,
          Price = 10,
          End_Date__c = Date.today().addDays(index),
          Auto_Renewal__c = 'Yes',
          Asset_Type__c = 'Participant',
          Status = 'Active'
        ));
      }
    }
    insert theParticipantAssets;

    // Initiating Web-Service Call - Test Case 1
    Id theParentAssetId = null;
    GetAssetHierarchy.ParentAsset theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAssetId, true);
    system.assert(theResult == null, 'Error: The web-service class failed to handle invalid parent asset Id.');

    // Initiating Web-Service Call - Test Case 2
    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 3 - Updated Parent Asset Contact Preferred Phone Value.
    theContact.Preferred_Phone__c = 'Mobile';
    theContact.MobilePhone = '9876543210';
    update theContact;

    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 4 - Updated Parent Asset Contact Preferred Phone Value.
    theContact.Preferred_Phone__c = 'Work Phone';
    theContact.Work_Phone__c = '9876543210';
    update theContact;

    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 5 - Updated Parent Asset Contact Preferred Phone Value.
    theContact.Preferred_Phone__c = 'Other';
    theContact.OtherPhone = '9876543210';
    //update theContact;

    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 6 - Updated Parent Asset Contact Preferred Phone Value.
    theContact.Preferred_Phone__c = 'Another';
    theContact.OtherPhone = '9876543210';
    //update theContact;

    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 7 - Updated Parent Asset Account Preferred Phone Value.
    theTestAccount.Preferred_Phone__c = 'Work Phone';
    theTestAccount.Work_Phone__c = '9876543210';
    //update theTestAccount;

    theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 8 - Updated Parent Asset Account Preferred Phone Value.
    theTestAccount.Preferred_Phone__c = 'Mobile1Phone';
    theTestAccount.Mobile1__c = '9876543210';
 //   update theTestAccount;

    //theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    //system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    // Initiating Web-Service Call - Test Case 9 - Updated Parent Asset Account Preferred Phone Value.
    theTestAccount.Preferred_Phone__c = 'Mobile2 Phone';
    theTestAccount.Mobile2_Other__c = '9876543210';


    //theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
    //system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

   // Initiating Web-Service Call - Test Case 10 - Updated Parent Asset Account Preferred Phone Value.
    theTestAccount.Preferred_Phone__c = 'Another';
    theTestAccount.Home_Phone__c = '9876543210';
   //update theTestAccount;

    //theResult = GetAssetHierarchy.getAssetHierarchyDetails(theParentAsset.Id, true);
   //system.assert(theResult != null, 'Error: The web-service class failed to generate asset hierarchy response data.');

    Test.stopTest();
    }
}