//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class: CaseTrigger_Test
// For Trigger Name: CaseTrigger
// On SObject: Case
// Description: Case Creation Validation.
//
// 24th March 2015    Hemendra Singh Bhati   Original (Task # T-373061)
// 30th March 2015    Hemendra Singh Bhati   Modified (Issue # I-153134)
// 07th June 2015     Hemendra Singh Bhati   Modified (Task # T-396116)
//
@IsTest
private class CaseTrigger_Test {
    private static final Integer COUNTER = 10;
    private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    //private static final String RETENTION_REP_PROFILE = '00eg0000000MCsJ';
    private static List<Case_Type_SLA_Setting__c> configList;
    
    private static testMethod void testUpdateAssetAtRiskFunctionality() {
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
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
        createCaseTypeSLAConfig();
        
        Test.startTest();
        // Updating Retention Cases.
        Case theCase = null;
        for(Integer index = 0; index < COUNTER / 2; index++) {
            theCase = theTestCases.get(index);
            if(Math.mod(index, 2) == 0) {
                theCase.Status = 'Closed';
                
            }
            else {
                theCase.Type = 'International';
            }
        }
        
        update theTestCases;
        Delete theTestCases;
        
        Test.stopTest();  
    }
    
    private static testMethod void testCaseTriggerFunctionality() {
        // Extracting Move IT SysAdmin Profile.
        List<Profile> profile = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE limit 1];
        system.assert(profile.size() > 0,'Error: Requested Profile does not exist.');
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        ProductCase__c  pc = new ProductCase__c(Name = 'Add Verification', Case_Type__c = 'Digital Ad Package');
        insert pc;   
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
        
        // Inserting Test Users.
        List<User> theTestUsers = new List<User>();
        for(Integer index = 0; index < COUNTER + 1; index++) {
            theTestUsers.add(TestDataFactory.createUser(null, profile[0].Id, null, 'mppuser_' + index + '@xmail.com', 'mppuser_' + index + '@xmail.com', false));
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
        
        Test.startTest();
        
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
        theCase = TestDataFactory.createCase(
            'The Final Test Case',
            'New',
            'International',
            'The Final Test Case',
            null,
            null,
            false
        );
        theCase.OwnerId = theTestUsers[10].Id;
        theTestCases.add(theCase);
        
        Integer totalInsertsSucceeded = 0;
        Database.SaveResult[] insertResult = Database.insert(theTestCases,false);
        for(Database.SaveResult sr : insertResult) {
            if(sr.isSuccess()) {
                totalInsertsSucceeded++;
            }
        }
        
        system.debug('TRACE TOTAL INSERTS SUCCEEDED: ' + totalInsertsSucceeded);
        
        Test.stopTest();
        
    }
    
    private static testMethod void testCaseAccountPopulationFromRelationship() {  
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;       
        ProductCase__c  pc = new ProductCase__c(Name = 'Add Verification', Case_Type__c = 'Digital Ad Package');
        insert pc;  
        ProductCase__c  pc1 = new ProductCase__c(Name = 'DIGITIALAGENT', Case_Type__c = 'Digital Ad Package',Case_Area__c = 'New/Renewal Order',Case_Sub_Area__c ='DART API Failure');
        insert pc1;     
        List<Account> listAccount = new list<Account>();
        Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
        parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
        parentAcc1.ShippingState  = 'CA';
        parentAcc1.ShippingCountry  = 'USA';
        parentAcc1.Type = 'Realtor Agent';
        listAccount.add(parentAcc1);
        
        Account parentAcc2 = TestDataFactory.createAccount('Parent Acc2',null,false);
        parentAcc2.Primary_Email__c = 'parentAcc2@move.com';
        parentAcc2.ShippingState  = 'CA';
        parentAcc2.ShippingCountry  = 'USA';
        parentAcc2.Type = 'Realtor Agent';
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
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;   
        BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
        quote.BigMachines__Account__c                   = listAccount[0].id;        
        quote.BigMachines__Status__c                    = 'Pending';
        quote.BigMachines_Quote_Type__c                 = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;               
        Set<Id> setQuoteDapIds = new Set<Id>();              
        setQuoteDapIds.add(quote.Id);                   
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';        
        newProduct.ProductCode              ='DIGITALAGENT' ;
        newProduct.S_No__c                  = 2;
        insert newProduct; 
        
        // Extracting Standard Price Book ID.
        Id theStandardPriceBookId = Test.getStandardPricebookId();                
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie1.Product2Id = newProduct.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        System.debug('theTestProducts:' + thePricebookEntrie1.id);   
        // Inserting Test Orders.       
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
        theTestOrder.Type = 'New';          
        theTestOrder.AccountId = listAccount[0].Id;
        theTestOrder.Pricebook2Id = theStandardPriceBookId;           
        theTestOrder.Fulfillment_Status__c ='Fulfilled';   
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
        theOrderItem.Fulfillment_Status__c ='Fulfilled';          
        insert theOrderItem;    
        
        System.debug('theOrderItems:' + theOrderItem.id );     
        
        // Inserting Test Assets.
        Asset theTestAsset = new Asset();        
        theTestAsset.Name = 'The Test Asset';
        theTestAsset.Status = 'Active';
        theTestAsset.AccountId = listAccount[0].Id;
        theTestAsset.asset_type__c ='Parent';           
        theTestAsset.Fulfillment_Status__c = 'Fulfilled';
        theTestAsset.Asset_Type__c = 'Parent';
        theTestAsset.Order_Line_Item__c = theOrderItem.Id;
        theTestAsset.Line_type__c ='Add';          
        theTestAsset.Product2Id = newProduct.Id; 
        insert theTestAsset; 
        
        Case theCase = TestDataFactory.createCase(
            'The Final Test Case',
            'New',
            'International',
            'The Final Test Case',
            testContact.id,
            listAccount[0].id,
            false
        );
        theCase.Relationship__c = accountRelation.Id;
        theCase.Oracle_Quote__c= quote.Id;
        theCase.Origin = 'Email';   
        insert theCase;    
        
        //theCase = [Select Accountid , Oracle_Quote__c From Case WHERE Id =: theCase.Id];   
        
        List<Case> lstCase = new List<Case>();
        CaseTriggerHandler cth = new CaseTriggerHandler(true,1);
        set<Case> caseIds = new set<Case>();
        caseIds.add(theCase);
        cth.DAPCloseCase(caseIds);  
        
        
        //CaseTriggerHandler.DAPAssetFulfill(null);    
        cth.AdVerificationCase(setQuoteDapIds);
        Test.startTest();      
        CaseTriggerHandler.DAPAssetFulfill(setQuoteDapIds);
        
        ID CollectionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Collections').RecordTypeId;      
        Case theCase1 = TestDataFactory.createCase(
            'The Final Test Case',
            'New',
            'International',
            'The Final Test Case',
            testContact.id,
            listAccount[0].id,
            false
        );
        theCase1.Relationship__c = accountRelation.Id;
        theCase1.Oracle_Quote__c= quote.Id;
        theCase1.Origin = 'Email';              
        theCase1.SubStatus__c = 'Pending Customer';
        theCase1.ParentId = theCase.id;
        theCase1.Followup_Status__c = 'Call Back';
        try{
            insert theCase1; 
        }catch(exception e){}       
        theCase1.Type = 'Digital Ad Package';
        theCase1.Area__c = 'New/Renewal Order';
        theCase1.Sub_Area__c  = 'DART API Failure';  
        theCase1.Status = 'Closed' ;
        theCase1.order__c = theTestOrder.Id; 
        theCase1.RecordTypeId = CollectionRtID;              
        theCase1.SubStatus__c = 'Monitoring'; 
        theCase1.Origin = 'Phone';
        theCase1.ownerId = userinfo.getuserid();
        theCase1.Followup_Status__c = 'Other';
        update theCase1;
        
        Test.stopTest();
        
    }
    private static testmethod void testaAssignCaseToRetentionRepOnAccount(){
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;    
        //Id profile = [SELECT Id FROM Profile WHERE Name = :RETENTION_REP_PROFILE limit 1].id;
        Id profile = [SELECT Id FROM Profile WHERE Name = 'Move Service Rep' limit 1].id;
        
        // Create User account for rep
        User rep = TestDataFactory.createUser(null, profile, null, 'mppuser_test' + '@gmail.com', 'mppuser_test' + '@gmail.com', false);
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
        testcase.RecordTypeId = rtId;
        testCase.Area__c = 'AgentMatch';
        insert testCase;      
        CaseTriggerHandlerManager handler = new CaseTriggerHandlerManager();
        handler.isRepOnVacation(null,null);
        
    } 
    private static testmethod void testCaseToRetention(){
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        // Test Account
        Account theTestAccount = TestDataFactory.createAccount('Team Member Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmailRandom@test.com';
        theTestAccount.Type = 'Realtor Agent';
        insert theTestAccount; 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;    
        // Create case
        Case testCase = TestDataFactory.createCase('Test subject', 'Test status', 'Retention', 'Test description' , null , theTestAccount.Id, false);
        testcase.RecordTypeId = rtId;
        testCase.Area__c = 'AgentMatch';
        insert testCase;   
        testcase.status = 'closed';
        
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';        
        newProduct.ProductCode              ='DIGITALAGENT' ;
        newProduct.S_No__c                  = 2;
        insert newProduct; 
        
        Id theStandardPriceBookId = Test.getStandardPricebookId();                
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie1.Product2Id = newProduct.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
        theTestOrder.Type = 'New';          
        theTestOrder.AccountId = theTestAccount.Id;
        theTestOrder.Pricebook2Id = theStandardPriceBookId;           
        theTestOrder.Fulfillment_Status__c ='Fulfilled';   
        //theTestOrder.Oracle_Quote__c   =   quote.Id;  
        theTestOrder.tigerLeadProductExists__c =false ;
        theTestOrder.Case__c = testCase.Id;
        
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
        theOrderItem.Fulfillment_Status__c ='Fulfilled';  
        theOrderItem.Contract_Term__c = '3';
        insert theOrderItem;    
        
        
        update testcase;    
        
        // Top Idx product Test
        /*testCase.Order__c = theTestOrder.Id;
testCase.Status ='New';
testcase.Subject = 'Top Producer IDX';
testCase.Area__c = 'Top Producer IDX';
update testCase;

theTestOrder.Fulfillment_Status__c = 'Pending Fulfillment';
update theTestOrder;

theOrderItem.Line_Type__c  = 'Add';
theOrderItem.Contract_Term__c = '3';
theOrderItem.Part_Number__c = 'TopIDX';
update theOrderItem;    

testCase.status = 'Closed';
update testCase; */
    }
    
    /**
* This Method Creates the Config_EmailToCase__c custom setting
*/
    private static void createCaseTypeSLAConfig(){
        //Create Custom Setting Config_EmailToCase__c    
        configList = new List<Case_Type_SLA_Setting__c>();
        configList.add(new Case_Type_SLA_Setting__c(Name='Creative',
                                                    Enforce_Next_Touch__c=true,
                                                    Enforce_SLA__c=true,
                                                    Next_Touch_Date_Time__c=24,
                                                    SLA_Date_Time__c=48
                                                   ));
        configList.add(new Case_Type_SLA_Setting__c(Name='New',
                                                    Enforce_Next_Touch__c=true,
                                                    Enforce_SLA__c=true,
                                                    Next_Touch_Date_Time__c=24,
                                                    SLA_Date_Time__c=48
                                                   ));
        insert configList;
    }
    
    
    private static testmethod void testCaseToOrder(){
        //Inserting Customsetting for Account     
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'test',AssetTrigger__c = UserInfo.getUserName());
        insert Dtrg;
        OrderDecompController.stopCreatingAccount = true;
        // Test Account
        Account theTestAccount = TestDataFactory.createAccount('Team Member Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmailRandom@test.com';
        theTestAccount.Type = 'Realtor Agent';
        insert theTestAccount; 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;    
        // Create case
        Case testCase = TestDataFactory.createCase('Test subject', 'Test status', 'Retention', 'Test description' , null , theTestAccount.Id, false);
        testcase.RecordTypeId = rtId;
        testCase.Area__c = 'AgentMatch';
        insert testCase;   
        testcase.status = 'New';
        testcase.Type='Order';
        
        
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';        
        newProduct.ProductCode              ='OPCITYCORE' ;
        newProduct.S_No__c                  = 2;
        insert newProduct; 
        
        Id theStandardPriceBookId = Test.getStandardPricebookId();                
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie1.Product2Id = newProduct.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        Test.startTest();
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
        theTestOrder.Type = 'New';          
        theTestOrder.AccountId = theTestAccount.Id;
        theTestOrder.Pricebook2Id = theStandardPriceBookId;           
        theTestOrder.Fulfillment_Status__c ='Pending Fulfillment';   
        //theTestOrder.Oracle_Quote__c   =   quote.Id;  
        theTestOrder.tigerLeadProductExists__c =false ;
        theTestOrder.Case__c = testCase.Id;
        
        insert theTestOrder; 
        testCase.Order__c = theTestOrder.Id;
        update testCase;        
        Asset theTestAsset = new Asset();        
        theTestAsset.Name = 'The Test Asset';
        theTestAsset.Status = 'Active';
        theTestAsset.AccountId = theTestAccount.Id;
        theTestAsset.asset_type__c ='Parent';           
        theTestAsset.Fulfillment_Status__c = 'Fulfilled';
        theTestAsset.Asset_Type__c = 'Parent';
        //theTestAsset.Order_Line_Item__c = theOrderItem.Id;
        theTestAsset.Line_type__c ='Add';          
        theTestAsset.Product2Id = newProduct.Id; 
        insert theTestAsset; 
        
        // Inserting Order Line Items.        
        OrderItem theOrderItem = new OrderItem();
        theOrderItem.Part_Number__c = 'OPCITYCORE';           
        theOrderItem.Quantity = 1.00;         
        theOrderItem.PricebookEntryId = thePricebookEntrie1.id;
        theOrderItem.OrderId = theTestOrder.Id;
        theOrderItem.UnitPrice = 1000;
        theOrderItem.Start_Date__c = Date.today();
        theOrderItem.Inactivate_Date__c = Date.today();             
        theOrderItem.Line_Type__c  = 'Add';
        theOrderItem.Fulfillment_Status__c ='Fulfilled';  
        theOrderItem.Contract_Term__c = '3';
        //theOrderItem.Product__c = newProduct.Id;
        theOrderItem.Asset__c=theTestAsset.Id;
        insert theOrderItem;    
        
        testCase.Status='Closed';
        
        update testcase; 
        Test.stopTest();
    }
}