//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class: CaseTriggerTest
// For Trigger Name: CaseTrigger
// On SObject: Case
// Description: Case Creation Validation.
//
// 24th March 2015    Hemendra Singh Bhati   Original (Task # T-373061)
// 30th March 2015    Hemendra Singh Bhati   Modified (Issue # I-153134)
// 07th June 2015     Hemendra Singh Bhati   Modified (Task # T-396116)
//
@IsTest
private class CaseTriggerTest {
  private static final Integer COUNTER = 10;
  private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
  //private static final String RETENTION_REP_PROFILE = '00eg0000000MCsJ';
  private static List<Case_Type_SLA_Setting__c> configList;

  private static testMethod void testUpdateAssetAtRiskFunctionality() {
    
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
        'New',
        'Retention',
        'Test Case #' + (index + 1),
        null,
        null,
        false
      ));
    }
    insert theTestCases;

    // Inserted Case Asset Relationships.
    List<Case_Asset_Relationship__c> theCaseAssetRelationships = new List<Case_Asset_Relationship__c>();
    for(Integer index = 0; index < COUNTER / 2; index++) {
      theCaseAssetRelationships.add(new Case_Asset_Relationship__c(
        Asset__c = theTestAssets.get(index).Id,
        Case__c = theTestCases.get(index).Id
      ));
    }
    insert theCaseAssetRelationships;

   /* system.assert(
      [SELECT Id FROM Asset WHERE At_Risk__c = true].size() == 5,
      'Error: The case asset relationship trigger failed to update the related assets at risk flag to true.'
    );*/

    Test.startTest();

    // Updating Retention Cases.
    Case theCase = null;
    for(Integer index = 0; index < COUNTER / 2; index++) {
      theCase = theTestCases.get(index);
      if(Math.mod(index, 2) == 0) {
        theCase.Status = 'Closed';
        theCase.Area__c = 'AgentMatch';
        theCase.RecordTypeId = setting.Record_Type_Id__c;
      }
      else {
        theCase.Type = 'International';
      }
    }
      Try{
          update theTestCases;
      }
      Catch(Exception e){
          system.debug('The error occured here is' +e.getCause() + 'The Message is' + e.getmessage() + 'the line number it is' + e.getLineNumber());
      }
    //Delete theTestCases;
    
    Test.stopTest();

   /* system.assert(
      [SELECT Id FROM Asset WHERE At_Risk__c = true].size() == 0,
      'Error: The case trigger failed to update the related assets at risk flag to false.'
    );*/
  }
    
   
  private static testMethod void testCaseTriggerFunctionality() {
    // Extracting Move IT SysAdmin Profile.
   // Test.startTest();
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
    system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
        //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
      Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
              insert art; 
     Switch_CaseTrigger__c swc = new Switch_CaseTrigger__c(Name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = true);
        insert swc;         
     OrderDecompController.stopCreatingAccount = true;
    // Inserting Test Account.
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'testEmailRandom@test.com';
    theAccount.ShippingState  = 'CA';
    theAccount.ShippingCountry  = 'USA';
    insert theAccount;
    // Inserting Test Contact.
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
    theContact.Email='hsingh@appirio.com';
    theContact.DoNotCall = false;
    insert theContact;
   // Test.stopTest();
    
    
    // Inserting Test Users.
    List<User> theTestUsers = new List<User>();
    for(Integer index = 0; index < COUNTER + 1; index++) {
      theTestUsers.add(TestDataFactory.createUser(null, profile[0].Id, null, 'user_' + index + '@xmail.com', 'user_' + index + '@xmail.com', false));
    }
    insert theTestUsers;
    system.debug('TRACE USERS: ' + theTestUsers);

    // Inserting Public Groups.
    List<String> publicGroupNames = new List<String> {
      'Article Managers',
      'MLS Support Team',
      'CC Collections Team',
      'ListHub Team',
      'Virtual Tour Team',
      'Email Team',
      'Sales Collections Team',
      'Resolution Team',
      'Product Setup Team',
      'Sales Support Team'
    };

    List<Group> thePublicGroups = new List<Group>();
    for(Integer index = 0; index < COUNTER; index++) {
      thePublicGroups.add(TestDataFactory.createPublicGroup(publicGroupNames.get(index), false));
    }
    insert thePublicGroups;
    system.debug('TRACE PUBLIC GROUPS:' + thePublicGroups);

    // Inserting Public Groups Members.
    List<GroupMember> thePublicGroupMembers = new List<GroupMember>();
    system.runAs(theTestUsers[0]) {
        for(Integer index = 0; index < 5; index++) {
          thePublicGroupMembers.add(TestDataFactory.createPublicGroupMember(theTestUsers.get(index).Id, thePublicGroups.get(index).Id, false));
        }

      Integer pointer = 0;
        for(Integer index = 5; index < 10; index++) {
            thePublicGroupMembers.add(TestDataFactory.createPublicGroupMember(thePublicGroups.get(pointer).Id, thePublicGroups.get(index).Id, false));
            pointer++;
        }
        insert thePublicGroupMembers;
    }
    system.debug('TRACE PUBLIC GROUP MEMBERS:' + thePublicGroupMembers);

    // Extracting Newly Inserted Public Group Member Ids.
    Set<Id> thePublicGroupMemberIds = new Set<Id>();
    for(GroupMember thePublicGroupMember : thePublicGroupMembers) {
        thePublicGroupMemberIds.add(thePublicGroupMember.Id);
    }

    // Creating a map of public group name and user Id.
    Map<String,Id> publicGroupNameAndUserIdMapping = new Map<String,Id>();
    Map<Id,Id> publicGroupIdAndUserIdMapping = new Map<Id,Id>();
    for(GroupMember theGroupMember : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE Id IN :thePublicGroupMemberIds]) {
        publicGroupIdAndUserIdMapping.put(theGroupMember.GroupId, theGroupMember.UserOrGroupId);
    }
    for(Group theGroup : [SELECT Id, Name FROM Group WHERE Id IN :publicGroupIdAndUserIdMapping.keySet()]) {
        publicGroupNameAndUserIdMapping.put(theGroup.Name, publicGroupIdAndUserIdMapping.get(theGroup.Id));
    }
    system.debug('TRACE PUBLIC GROUP NAME AND USER ID MAPPING: ' + publicGroupNameAndUserIdMapping);

    // Inserting Test Cases.
    List<String> theCaseTypes = new List<String> {
            'International',
            'FiveStreet',
            'FIND',
            'ListHub',
            'Virtual Tour',
            'Realtor Professional',
            'MLS Support',
            'Collections',
            'Global',
            'Sales Support',
            'Product Setup',
            'Resolution'
    };
    
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;   

    
    
      Case theCase = null;
    List<Case> theTestCases = new List<Case>();

    // Instantiating Cases To Make All Trigger Conditions True.
    for(Integer index = 0; index < COUNTER + 2; index++) {
        theCase = TestDataFactory.createCase(
       'Test Case #' + (index + 1),
       'New',
        theCaseTypes.get(index),
        'Test Case #' + (index + 1),
        null,
        null,
        false
      );

      // Test Case 1 - Public Group - Email Team.
      if(theCaseTypes.get(index).equalsIgnoreCase('Realtor Professional')) {
        theCase.Origin = 'Email';
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Article Managers') ? publicGroupNameAndUserIdMapping.get('Article Managers') : null;
      }
      // Test Case 2 - Public Group - Resolution Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('MLS Support')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('CC Collections Team') ? publicGroupNameAndUserIdMapping.get('CC Collections Team') : null;
      }
      // Test Case 3 - Public Group - Sales Collections Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Collections')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('MLS Support Team') ? publicGroupNameAndUserIdMapping.get('MLS Support Team') : null;
      }
      // Test Case 4 - Public Group - Resolution Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Global')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('CC Collections Team') ? publicGroupNameAndUserIdMapping.get('CC Collections Team') : null;
      }
      // Test Case 5 - Public Group - Sales Support Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Sales Support')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Virtual Tour Team') ? publicGroupNameAndUserIdMapping.get('Virtual Tour Team') : null;
      }
      // Test Case 6 - Public Group - Product Setup Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Product Setup')) {
        theCase.ContactId = theContact.Id;
        theCase.Product_Category__c = 'RDC';
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('ListHub Team') ? publicGroupNameAndUserIdMapping.get('ListHub Team') : null;
      }
      // Test Case 7 - Public Group - Sales Support Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Resolution')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Virtual Tour Team') ? publicGroupNameAndUserIdMapping.get('Virtual Tour Team') : null;
      }

        theTestCases.add(theCase);
    }
      Test.startTest();
    // Instantiating Cases To Make All Trigger Conditions False.
    for(Integer index = 0; index < COUNTER + 2; index++) {
      theCase = TestDataFactory.createCase(
       'Test Case #' + (index + 1),
       'New',
        theCaseTypes.get(index),
        'Test Case #' + (index + 1),
        null,
        null,
        false
      );

      // Test Case 8 - Public Group - Email Team.
      if(theCaseTypes.get(index).equalsIgnoreCase('Realtor Professional')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Virtual Tour Team') ? publicGroupNameAndUserIdMapping.get('Virtual Tour Team') : null;
      }
      // Test Case 9 - Public Group - Resolution Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('MLS Support')) {
        theCase.Origin = 'Email';
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Article Managers') ? publicGroupNameAndUserIdMapping.get('Article Managers') : null;
      }
      // Test Case 10 - Public Group - Sales Collections Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Collections')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('ListHub Team') ? publicGroupNameAndUserIdMapping.get('ListHub Team') : null;
      }
      // Test Case 11 - Public Group - Resolution Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Global')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('MLS Support Team') ? publicGroupNameAndUserIdMapping.get('MLS Support Team') : null;
      }
      // Test Case 12 - Public Group - Sales Support Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Sales Support')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('CC Collections Team') ? publicGroupNameAndUserIdMapping.get('CC Collections Team') : null;
      }
      // Test Case 13 - Public Group - Product Setup Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Product Setup')) {
        theCase.ContactId = theContact.Id;
        theCase.Product_Category__c = 'RDC';
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('Article Managers') ? publicGroupNameAndUserIdMapping.get('Article Managers') : null;
      }
      // Test Case 14 - Public Group - Sales Support Team.
      else if(theCaseTypes.get(index).equalsIgnoreCase('Resolution')) {
        theCase.OwnerId = publicGroupNameAndUserIdMapping.containsKey('ListHub Team') ? publicGroupNameAndUserIdMapping.get('ListHub Team') : null;
      }

      theTestCases.add(theCase);
    }

    // Test Case 15 - Public Group - None.
      /*theCase = TestDataFactory.createCase(
       'The Final Test Case',
       'New',
       'International',
       'The Final Test Case',
       null,
       null,
       false
      );
      theCase.OwnerId = theTestUsers[10].Id;
      theTestCases.add(theCase);*/

    Integer totalInsertsSucceeded = 0;
    Database.SaveResult[] insertResult = Database.insert(theTestCases,false);
    for(Database.SaveResult sr : insertResult) {
      if(sr.isSuccess()) {
        totalInsertsSucceeded++;
      }
    }
    system.debug('TRACE TOTAL INSERTS SUCCEEDED: ' + totalInsertsSucceeded);

    Test.stopTest();
    /*
    system.assert(
      totalInsertsSucceeded == 19,
      'Error: The case trigger after insert functionality failed to validate newly inserted cases.'
    );*/
  }
  
 /* 
  private static testMethod void testCaseHistoryTrackingFuntionality() {
    // Get Move IT SysAdmin Profile
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
    //system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
    //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
    Test.startTest();
    // Create Test Account
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
    testAccount.Primary_Email__c = 'testEmail@test.com';
    testAccount.ShippingState  = 'CA';
    testAccount.ShippingCountry  = 'USA';
    insert testAccount;
      Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
      testContact.Email = 'rshekhawat@appirio.com';
      insert testContact;
      Group testQueue = new Group(Name='Default Queue', type='Queue');
    insert testQueue;
    QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
      System.runAs(new User(Id = UserInfo.getUserId()))
      {
         insert mappingObject;
      }
       
      // Insert Custom Setting for Case Trigger
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Case_History_Tracking_Off__c=false,Set_Overall_Trigger_Off__c=false,Set_Case_Creation_Validation_Off__c=false);
    insert testSetting; 
    //Create Admin User
    User adminUser = TestDataFactory.createUser(null, profile[0].Id, null, 'user_1' + '@xmail.com', 'user_1' + '@xmail.com', true);
    
      //System.runAs(adminUser){
      System.runAs(new User(Id = UserInfo.getUserId())){ 
      Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;   
        
        //Create Cases
        List<Case> caseList = new List<Case>();
        Case theCase = null;
        for(Integer index = 0; index < 5; index++) {
            theCase = TestDataFactory.createCase(
            'Test Case #' + (index + 1),
            'New',
            'Broker Relations',
            'Test Case #' + (index + 1),
            testContact.Id,
            testAccount.Id,
            false
        );
        theCase.Area__c='Credit Request';
        if(math.mod(index,2)==0){
         theCase.OwnerId= testQueue.Id;
        }
        caseList.add(theCase);
       } 
   
      insert caseList;
   
      List<CaseComment> caseCommentList = new List<CaseComment>();
       CaseComment testComment1 = TestDataFactory.createCaseComment('Test Comment', caseList.get(0).Id, true,false);      
      for(Integer index = 0 ; index < 5; index++){
        caseCommentList.add(TestDataFactory.createCaseComment('Test Comment'+index, caseList.get(math.mod(index,2)).Id, true,false));
      }
      caseCommentList.add(testComment1);
      
      insert caseCommentList;
      system.debug('caseCommentList:'+caseCommentList.size());
   
      //Case_Resolution_Tracking__c crt = [SELECT Comment_Count__c FROM Case_Resolution_Tracking__c WHERE Case__c =: caseList.get(0).Id];
      //system.debug('crt :'+crt);
      //System.assert(crt.Comment_Count__c == 5, 'Comment Count Should be 5'); 
   
      //Get a Case Update the Status
      Case tempCase = [SELECT Status FROM Case WHERE Id =: caseList.get(0).Id];
      tempCase.Status ='Open';
      //update tempCase;  
   
      //Assert that an Entry is Made for Status Change for the Case in Case_Resolution_Tracking__c
      //crt = [SELECT New_Status__c,Case__c FROM  Case_Resolution_Tracking__c WHERE Case__c =: tempCase.Id AND Change_Type__c='Status' ORDER BY CreatedDate Desc][0];
      //System.assert(crt!=null);
   
      // Get A Case with User as Owner and Update the Owner
      tempCase = [SELECT Status FROM Case WHERE Id =: caseList.get(1).Id];
      tempCase.OwnerId = testQueue.Id;
      //update tempCase;
   
      // Assert That An Entry is Made For Owner Change of A Case IN Case_Resolution_Tracking__c
      //crt = [SELECT New_Status__c,Case__c FROM  Case_Resolution_Tracking__c WHERE Case__c =: tempCase.Id AND Change_Type__c='Owner' limit 1];
      //System.assert(crt!=null);
   
      testSetting.Set_Case_History_Tracking_Off__c = true;
      update testSetting;
   
      // Get A Case with User as Owner and Update the Owner
      tempCase = [SELECT Status FROM Case WHERE Id =: caseList.get(3).Id];
      tempCase.Status = 'Open';
      //update tempCase;
   
      List<Case_Resolution_Tracking__c> listCaseResoTrack = new List<Case_Resolution_Tracking__c>();
      // Assert That An Entry is Not Made For Stats Change of A Case IN Case_Resolution_Tracking__c as the Custom Setting is Off
      listCaseResoTrack = [SELECT New_Status__c,Case__c FROM  Case_Resolution_Tracking__c WHERE Case__c =: tempCase.Id AND Change_Type__c='Status'];
      // Only One Entry should be there, which was created initially when the Case was Created
      //System.assert(listCaseResoTrack.size()==1);
     Test.stopTest(); 
   
    }
  } 
  
  private static testMethod void testSurveyAndSLAFuntionality() {  
    // Get Move IT SysAdmin Profile
    List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
    //system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
    
    //User adminUser = TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUser@move.com','adminUser@move.com', true);
    //User adminUser1 = TestDataFactory.createUser(null, profile.get(0).Id, null, 'adminUser1@move.com','adminUser1@move.com', true);
    //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
    // Create Test Account
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
    testAccount.Primary_Email__c = 'testEmail@test.com';
    testAccount.ShippingState  = 'CA';
    testAccount.ShippingCountry  = 'USA';
    insert testAccount;
    //Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
    //testContact.Email = 'rshekhawat@appirio.com';
    //testContact.Last_Survey_Send_Date__c = System.today().addDays(-5);
    //insert testContact;
    Group testQueue = new Group(Name='Default Queue', type='Queue');
    insert testQueue;
    createCaseTypeSLAConfig();
    // Insert Custom Setting for Case Trigger
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Case_History_Tracking_Off__c=false,Set_Overall_Trigger_Off__c=false,Set_Case_Creation_Validation_Off__c=false,Set_SLA_Functionality_Off__c=false);
    insert testSetting; 
    QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
    System.runAs(new User(Id = UserInfo.getUserId()))
    {
     insert mappingObject;
    }
    
     // Inserting Public Groups.
    List<String> publicGroupNames = new List<String> {
      'Article Managers',
      'MLS Support Team',
      'CC Collections Team',
      'ListHub Team',
      'Virtual Tour Team',
      'Email Team',
      'Sales Collections Team',
      'Resolution Team',
      'Product Setup Team',
      'Sales Support Team'
    };

    List<Group> thePublicGroups = new List<Group>();
    for(Integer index = 0; index < COUNTER; index++) {
      thePublicGroups.add(TestDataFactory.createPublicGroup(publicGroupNames.get(index), false));
    }
    insert thePublicGroups;
    system.debug('TRACE PUBLIC GROUPS:' + thePublicGroups);

    // Inserting Public Groups Members.
    List<GroupMember> thePublicGroupMembers = new List<GroupMember>();
    system.runAs(new User(Id = UserInfo.getUserId())) {
        for(Integer index = 0; index < 5; index++) {
          thePublicGroupMembers.add(TestDataFactory.createPublicGroupMember(UserInfo.getUserId(), thePublicGroups.get(index).Id, false));
        }
      insert thePublicGroupMembers;
    }

        System.runAs(new User(Id = UserInfo.getUserId())) {
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;   
    Test.startTest();
        //Create Cases
        List<Case> caseList = new List<Case>();
        Case theCase = null;
        //Create Two Case of Collections Type
        for(Integer index = 0; index < 2; index++) {
            theCase = TestDataFactory.createCase(
            'Test Case #' + (index + 1),
            'New',
            'Collections',
            'Test Case #' + (index + 1),
            null,
            testAccount.Id,
            false
        );
        theCase.Area__c='Cancelled';
        caseList.add(theCase);
       } 
       
   
      insert caseList;
      
      //Get the Cases of Collections Type
      List<Case> collectionCases = [Select Id,Status,Next_Touch_Date_Time__c,SLA_Date_Time__c from Case where Type = 'Collections'];
     
      for(Case c: collectionCases){
          c.Status = 'Open';      
      }
      update collectionCases;
      // Get the updated cases
      collectionCases = [Select Id,Status,Next_Touch_Date_Time__c,SLA_Date_Time__c from Case where Type = 'Collections'];
      // Assert that next touch time was set to as future time
      //System.assert(collectionCases.get(1).Next_Touch_Date_Time__c > DateTime.now());
      
      //Insert commemnt on case
      List<CaseComment> caseCommentList = new List<CaseComment>();
      for(Integer index = 0 ; index < 2; index++){
      caseCommentList.add(TestDataFactory.createCaseComment('Test Comment'+index, collectionCases.get(math.mod(index,2)).Id, true,false));
      }
      insert caseCommentList;
      //Update the cases to Closed
      for(Case c: collectionCases){
          c.Status = 'Closed';      
      }
      update collectionCases;
      // Get Updated cases
      collectionCases = [Select Id,SLA_Achieved__c,Next_Touch_Date_Time__c,IsUpdateLastSurveyDate__c,SLA_Date_Time__c from Case where Type = 'Collections'];
      // Assert the SLA was Achieved as case was closed before SLA Date time
      //System.assert(collectionCases.get(0).SLA_Achieved__c == true);
      
      collectionCases.get(0).IsUpdateLastSurveyDate__c = true;
      
      update collectionCases;
      collectionCases = [Select Id,SLA_Achieved__c,Next_Touch_Date_Time__c,IsUpdateLastSurveyDate__c,SLA_Date_Time__c from Case where Type = 'Collections'];
     // testContact = [Select Id,Last_Survey_Send_Date__c FROM Contact WHERE Email = 'rshekhawat@appirio.com'][0];
     // System.assertEquals(System.today(),testContact.Last_Survey_Send_Date__c);
      //System.assertEquals(collectionCases.get(0).IsUpdateLastSurveyDate__c,false);
      Test.stopTest();
     }
  }
  */
    private static testMethod void testCaseAccountPopulationFromRelationship() {  
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
          //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
      Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
              insert art;
       Schedule_Batch_Setting__c schBat = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Assetresttime__c = 60, Execution_Min__c = 50);
        insert schBat;
        OrderDecompController.stopCreatingAccount = true;
        List<Account> listAccount = new list<Account>();
        Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
        parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
        parentAcc1.ShippingState  = 'CA';
        parentAcc1.ShippingCountry  = 'USA';
        listAccount.add(parentAcc1);
        
        Account parentAcc2 = TestDataFactory.createAccount('Parent Acc2',null,false);
        parentAcc2.Primary_Email__c = 'parentAcc2@move.com';
        parentAcc2.ShippingState  = 'CA';
        parentAcc2.ShippingCountry  = 'USA';
        listAccount.add(parentAcc2);        
         insert listAccount; 
        
        List<Contact> listContact = new List<Contact>();    
        Contact testContact = TestDataFactory.createContact('TestContact1','Last1',parentAcc1.id,true,false);
        testContact.Email = 'testContact1@move.com';
        testContact.Type__c = 'Primary';
        listContact.add(testContact);
        
        Contact testContact2 = TestDataFactory.createContact('TestContact2','Last2',parentAcc2.id,true,false);
        testContact2.Email = 'testContact2@move.com';
        testContact2.Type__c = 'Primary';
        listContact.add(testContact2);
        insert listContact;
        
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        // Create Relationship records for Contact Relationhsip
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                            parentAcc1.Id, null, listContact.get(0).Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        toBeInserted.add(accountRelation); 
        
        // Create Relationship records for Contact Relationhsip
        Account_Relationship__c accountRelation1 = TestDataFactory.createAccountRelationship(
                            parentAcc2.Id, null, listContact.get(1).Id, null, true, false);
        accountRelation1.RecordTypeId =     contactRelationshipRecordTypeId;
        accountRelation1.Active__c = true;
        toBeInserted.add(accountRelation1); 
        
        insert toBeInserted;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        Id ctId = CaseRecordTypeInfo.get('Collections').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting;   
         CaseRecordTypes__c collection = new CaseRecordTypes__c(Name = 'Collections' , Record_Type_Id__c = ctId);
                  insert collection;   
 
        Case theCase = TestDataFactory.createCase(
            'The Final Test Case',
            'New',
            'International',
            'The Final Test Case',
            testContact.id,
            null,
            false
        );
        theCase.Relationship__c = accountRelation.Id;
        theCase.RecordTypeId = collection.Record_Type_Id__c;
        theCase.Followup_Status__c = 'Follow Up';
        theCase.Origin ='Email-ListHub:channel.support@listhub.com';
        Case theParentCase = TestDataFactory.createCase(
            'The Final parent Test Case',
            'New',
            'International',
            'The Final Test Case',
            testContact.id,
            null,
            false
        );
        
        List<Case> casesList = new List<Case>();
        casesList.add(theCase);
        casesList.add(theParentCase);
        insert casesList;
    
         Test.startTest();
        theCase.Contactid = testContact2.Id;
        theCase.Relationship__c = accountRelation1.Id;
        
        theCase.Followup_Status__c = 'Other';
        theCase.Outcome__c = 'No Answer';
        theCase.SubStatus__c = 'Review';
        theCase.Type = 'Collections';
        // theCase.Comments__c = 'test Comments';
        update theCase;
        
        theCase.Subject = 'Manual Activities';
        theCase.Type = 'Customer Service';
        theCase.Status = 'Closed';
        theCase.ParentId =theParentCase.Id;
        theCase.RecordTypeId = collection.Record_Type_Id__c;
        theCase.AccountId = parentAcc1.id;
        update theCase;
        
        //new
       set<id> testSet=new set<id>();
       testSet.add(theCase.id);
       CaseTriggerHandlerManager cth = new CaseTriggerHandlerManager();
       cth.AsyncaddRepToAccountTeamOnCaseClosure(testSet);
        
            Test.stopTest();
    }
    
   //New 
    private static testMethod void TestisRepOnVacation() {
         Test.startTest();
       CaseTriggerHandlerManager cth = new CaseTriggerHandlerManager();
       cth.isRepOnVacation(null,null);
       cth.isRepOnVacation(system.today()+2,system.today()+4 );
       cth.isRepOnVacation(system.today()-2,system.today()+4 );
       cth.isRepOnVacation(system.today()-2,system.today()-1 );
       cth.isRepOnVacation(system.today(),system.today() );
         Test.stopTest();
    }
    
    /* Commented for service leap project 
private static void testaAssignCaseToRetentionRepOnAccount(){
//Inserting Customsetting for Account     
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
insert Dtrg;

//Id profile = [SELECT Id FROM Profile WHERE Name = :RETENTION_REP_PROFILE limit 1].id;
Id profile = [SELECT Id FROM Profile WHERE Name = 'Move Service Rep' limit 1].id;

// Create User account for rep
User rep = TestDataFactory.createUser(null, profile, null, 'user_test' + '@gmail.com', 'user_test' + '@gmail.com', false);
rep.Vacation_Start_Date__c = null;
rep.Vacation_End_Date__c = null;
insert rep;

// Test Account
Account theTestAccount = TestDataFactory.createAccount('Team Member Test Account', null, false);
theTestAccount.Primary_Email__c = 'testEmailRandom@test.com';
insert theTestAccount; 

// Test Team Member
AccountTeamMember actMember = new AccountTeamMember();
actMember.AccountId = theTestAccount.Id;
// actMember.UserId = '005g0000002BxaT';
actMember.UserId = Userinfo.getUserId();
actMember.TeamMemberRole='Retention Rep';
insert actMember;

// Create case
Case testCase = TestDataFactory.createCase('Test subject', 'Test status', 'Retention', 'Test description' , null , theTestAccount.Id, false);

insert testCase;

List<Case> newCaseValues = new List<case>();
newCasevalues.add(testCase);        

}
*/
    
    /**
* This Method Creates the Config_EmailToCase__c custom setting
*/
   private static void createCaseTypeSLAConfig(){
    //Create Custom Setting Config_EmailToCase__c    
      configList = new List<Case_Type_SLA_Setting__c>();
      configList.add(new Case_Type_SLA_Setting__c(Name='Collections',
                                                               Enforce_Next_Touch__c=true,
                                                               Enforce_SLA__c=true,
                                                               Next_Touch_Date_Time__c=24,
                                                               SLA_Date_Time__c=48
                                                               ));
      insert configList;
   }
    
    public static testMethod void updateFulfillmentOnOrder(){
         //Inserting Customsettings 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        //Inserting account
        Account testAccount = TestDataFactory.createAccount('The Test Account', null, false);
        testAccount.Primary_Email__c = 'ssk112233@gmail.com';
        testAccount.ShippingState  = 'CA';
        testAccount.ShippingCountry  = 'USA';
        insert testAccount;
        
        Opportunity testopp = new Opportunity(      Name = 'The Opportunity',
                                              StageName = 'Prospecting',
                                              CloseDate = system.today(),
                                              AccountId = testAccount.Id,
                                              Opportunity_Short_Description__c = 'sDesc',
                                              Amount = 0.00);
        
        Account_Listing__c alist = new Account_Listing__c();
        alist.City__c = 'Fremont';
        alist.Account_Name__c = testAccount.Id;
        insert alist;
        
       
        Product2 testProduct1 = Commissions_TestDataFactory.CreateProduct('REESIO Prod',false);
        testProduct1.ProductCode = 'REESIO';   
        insert testProduct1;
        
        Product2 testProduct3 = Commissions_TestDataFactory.CreateProduct('MEDIABUY Prod',false);
        testProduct3.ProductCode = 'MEDIABUY';   
        insert testProduct3;
        
         Product2 testProduct2 = Commissions_TestDataFactory.CreateProduct('TOPIDX Prod',false);
        testProduct1.ProductCode = 'TOPIDX';   
        insert testProduct2;
        
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = Test.getStandardPricebookId();
        thePricebookEntrie1.Product2Id = testProduct1.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        PricebookEntry thePricebookEntrie2 = new PricebookEntry();             
        thePricebookEntrie2.Pricebook2Id = Test.getStandardPricebookId();
        thePricebookEntrie2.Product2Id = testProduct2.Id;
        thePricebookEntrie2.UnitPrice = 1000;
        thePricebookEntrie2.IsActive = true;          
        insert thePricebookEntrie2;
        
        PricebookEntry thePricebookEntrie3 = new PricebookEntry();             
        thePricebookEntrie3.Pricebook2Id = Test.getStandardPricebookId();
        thePricebookEntrie3.Product2Id = testProduct3.Id;
        thePricebookEntrie3.UnitPrice = 1000;
        thePricebookEntrie3.IsActive = true;          
        insert thePricebookEntrie3;
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Account__c  = testAccount.id;        
        quote.BigMachines__Status__c  = 'Ordered';
        quote.BigMachines_Quote_Type__c  = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;               
        
        
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'created';
        theTestOrder.Type = 'New';    
        theTestOrder.Is_BMS__c = true;
        theTestOrder.AccountId = testAccount.Id;
       
        theTestOrder.Pricebook2Id = Test.getStandardPricebookId();
        theTestOrder.Fulfillment_Status__c ='Pending Fulfillment';   
        theTestOrder.Oracle_Quote__c   =   quote.Id;  
        theTestOrder.tigerLeadProductExists__c =false ;
        insert theTestOrder;        
        // Inserting Order Line Items.        
        OrderItem theOrderItem = new OrderItem();           
        theOrderItem.Quantity = 1.00;         
        theOrderItem.PricebookEntryId = thePricebookEntrie1.id;
        theOrderItem.OrderId = theTestOrder.Id;
        theOrderItem.UnitPrice = 1000;
        theOrderItem.Start_Date__c = Date.today();
        theOrderItem.Inactivate_Date__c = Date.today();             
        theOrderItem.Line_Type__c  = 'Add';
        theOrderItem.Fulfillment_Status__c ='Pending Fulfillment';    
        theOrderItem.Part_Number__c = 'REESIO';
        insert theOrderItem; 
        
         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
         Id rtId1 = CaseRecordTypeInfo.get('Standard').getRecordTypeId();
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                  insert setting; 
         
         Case theCase1 = TestDataFactory.createCase(
               'Manual Fulfillment Required',
               'New',
               'Order',
               'The Final Test Case',
               null,
               testAccount.id,
               false
              );
        
        theCase1.order__c = theTestOrder.id;
         theCase1.Subject = 'Manual Fulfillment Required';
         theCase1.Type = 'Order';
         theCase1.RecordTypeId = rtId;
        theCase1.Area__c = 'Access Issues';
        insert theCase1;
        
         Order theTestOrder2 = new Order();        
        theTestOrder2.EffectiveDate = Date.today();
        theTestOrder2.Status = 'created';
        theTestOrder2.Type = 'New';    
        theTestOrder2.Is_BMS__c = true;
        theTestOrder2.AccountId = testAccount.Id;
       
        theTestOrder2.Pricebook2Id = Test.getStandardPricebookId();
        theTestOrder2.Fulfillment_Status__c ='Pending Fulfillment';   
        theTestOrder2.Oracle_Quote__c   =   quote.Id;  
        theTestOrder2.tigerLeadProductExists__c =false ;
        insert theTestOrder2;        
        // Inserting Order Line Items.        
        OrderItem theOrderItem2 = new OrderItem();           
        theOrderItem2.Quantity = 1.00;         
        theOrderItem2.PricebookEntryId = thePricebookEntrie2.id;
        theOrderItem2.OrderId = theTestOrder2.Id;
        theOrderItem2.UnitPrice = 1000;
        theOrderItem2.Start_Date__c = Date.today();
        theOrderItem2.Inactivate_Date__c = Date.today();      
        theOrderItem2.Contract_Term__c = '1';
        theOrderItem2.Line_Type__c  = 'Add';
        theOrderItem2.Fulfillment_Status__c ='Pending Fulfillment';    
        theOrderItem2.Part_Number__c = 'TOPIDX';
        insert theOrderItem2; 
         system.debug('order------item-->'+theOrderItem2.PricebookEntry.product2.productCode +theOrderItem2.Line_Type__c);
         Case theCase2 = TestDataFactory.createCase(
               'Manual Fulfillment Required',
               'New',
               'Order',
               'The Final Test Case',
               null,
               testAccount.id,
               false
              );
        
        Order theTestOrder3 = new Order();        
        theTestOrder3.EffectiveDate = Date.today();
        theTestOrder3.Status = 'created';
        theTestOrder3.Type = 'New';    
        theTestOrder3.Is_BMS__c = true;
        theTestOrder3.AccountId = testAccount.Id;
       
        theTestOrder3.Pricebook2Id = Test.getStandardPricebookId();
        theTestOrder3.Fulfillment_Status__c ='Manual';   
        theTestOrder3.Oracle_Quote__c   =   quote.Id;  
        theTestOrder3.tigerLeadProductExists__c =false ;
        insert theTestOrder3;  
        
         OrderItem theOrderItem3 = new OrderItem();           
        theOrderItem3.Quantity = 1.00;         
        theOrderItem3.PricebookEntryId = thePricebookEntrie3.id;
        theOrderItem3.OrderId = theTestOrder3.Id;
        theOrderItem3.UnitPrice = 1000;
        theOrderItem3.Start_Date__c = Date.today();
        theOrderItem3.Inactivate_Date__c = Date.today();      
        theOrderItem3.Contract_Term__c = '1';
        theOrderItem3.Line_Type__c  = 'Add';
        theOrderItem3.Fulfillment_Status__c ='Pending Fulfillment';    
        theOrderItem3.Part_Number__c = 'MEDIABUY';
        insert theOrderItem3; 
        
         Case theCase3 = TestDataFactory.createCase(
               'Manual Fulfillment Required',
               'New',
               'Order',
               'The Final Test Case',
               null,
               testAccount.id,
               false
              );
        
        theCase3.order__c = theTestOrder3.id;
         theCase3.Subject = 'Manual Fulfillment Required';
         theCase3.Type = 'Order';
         theCase3.RecordTypeId = rtId1;
        insert theCase3;
        
        
         theCase2.order__c = theTestOrder2.id;
         theCase2.Subject = 'TP IDX Fulfillment Required';
         theCase2.Type = 'Order';
         theCase2.Area__c = 'Top Producer IDX';
         theCase2.RecordTypeId = rtId1 ;
         insert theCase2;
        
         test.startTest();
         theCase1.Status = 'closed';
         theCase3.Status = 'closed';
         theCase2.Status = 'closed';
         update theCase1;
         update theCase2;
         update theCase3;
       
        // Top Idx product Test
      /*   theCase1.Order__c = theTestOrder.Id;
         theCase1.Status ='New';
         theCase1.Subject = 'Top Producer IDX';
         theCase1.Area__c = 'Top Producer IDX';
         update theCase1;
         
         theTestOrder.Fulfillment_Status__c = 'Pending Fulfillment';
         update theTestOrder;
         
        theOrderItem.Line_Type__c  = 'Add';
        theOrderItem.Contract_Term__c = '3';
        theOrderItem.Part_Number__c = 'TOPIDX';
        update theOrderItem;    
         
        theCase1.status = 'Closed';
        update theCase1;   
         test.stopTest();*/
        
    }
    public static testMethod void updateSurveyDetails(){
        //Inserting Customsettings 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Id rtId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Retention').RecordTypeId;
        Id recType = Schema.SObjectType.Case.RecordTypeInfosByName.get('Standard').RecordTypeId;
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        OrderDecompController.stopCreatingAccount = true;
        SurveyOnCaseClosed__c survey = new SurveyOnCaseClosed__c(Name = 'Standard1', Type__c = 'ProSoft', Record_Type_Id__c=rtId, Field_to_update__c = 'PS_Service_Survey_Send_Date__c', Area__c = '', Sub_Area__c = '', Account_Type__c = '', Outcome__c = '');
        SurveyOnCaseClosed__c survey1 = new SurveyOnCaseClosed__c(Name = 'Standard2', Type__c = 'ProSoft1', Record_Type_Id__c=rtId, Field_to_update__c = 'PS_Service_Survey_Send_Date__c', Area__c = 'pro', Sub_Area__c = 'subPro', Account_Type__c = '', Outcome__c = 'out');
        List<SurveyOnCaseClosed__c> surList = new List<SurveyOnCaseClosed__c>{survey, survey1};
            insert surList;
        // Inserting Test Account.
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'testEmailRandom@test.com';
        theAccount.ShippingState  = 'CA';
        theAccount.ShippingCountry  = 'USA';
        insert theAccount;
        List<Contact> contList = new List<Contact>();
        // Inserting Test Contact.
        Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theAccount.Id, true, false);
        theContact.Email='hsingh@appirio.com';
        theContact.DoNotCall = false;
        
        Contact theContact1 = TestDataFactory.createContact('The Test1', 'Contact1', theAccount.Id, true, false);
        theContact1.Email='';
        theContact1.DoNotCall = false;
        //       theContact1.BAD_Email__c = 'BAD Email';
        
        
        contList.add(theContact);
        contList.add(theContact1);
        insert contList;
        
        //Id recType = Schema.SObjectType.Case.RecordTypeInfosByName.get('Standard').RecordTypeId;
        
        Case theCase = TestDataFactory.createCase(
            'test survey',
            'New',
            'ProSoft',
            'The Final Test Case',
            null,
            theAccount.id,
            false
        );
        Case theCase1 = TestDataFactory.createCase(
            'test survey',
            'New',
            'ProSoft1',
            'The Final Test Case',
            null,
            theAccount.id,
            false
        );
        theCase.Area__c = 'AgentMatch';
        theCase1.RecordTypeId = theCase.RecordTypeId = rtId;
        theCase.ContactId = theContact.id;
        theCase1.ContactId = theContact1.id;
        theCase1.Area__c = 'pro';
        theCase1.Sub_Area__c = 'subPro';
        theCase1.Outcome__c = 'out';
        List<Case> caseList = new List<Case>{theCase1, theCase};
            insert caseList;
        theCase.Status = 'Closed';
        theCase1.Status = 'Closed';
        theCase.OwnerId = UserInfo.getUserId();
        theCase1.OwnerId = UserInfo.getUserId();
        List<Case> upcaseList = new List<Case>{theCase1, theCase};
        update upcaseList;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        for(Case newCase :upcaseList)
            oldMap.put(newCase.Id, newCase);
        
        CaseTriggerHandlerManager caseManager = new CaseTriggerHandlerManager();
        caseManager.UpdateCaseManagers(upcaseList, oldMap, true);
    }
}