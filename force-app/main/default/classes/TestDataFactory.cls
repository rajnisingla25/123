//
// (c) 2015 Appirio, Inc.
//
// Apex Class Name: TestDataFactory
// Description: Contains methods to generate data for apex test classes.
//
// 15th March 2015   Hemendra Singh Bhati   Original (Task # T-369907)
// 25th March 2015   Hemendra Singh Bhati   Modified (Task # T-373061) - Added Methods: createPublicGroup(), createPublicGroupMember().
// 07th May 2015     Hemendra Singh Bhati   Modified (Task # T-380800) - Added Methods: createProductAndAccountFieldsMappingData().
@isTest
public without sharing class TestDataFactory {
    // This method creates a new user.
    public static User createUser(Id userRoleId, Id profileId, Id contactId, String email, String userName, Boolean isInsert) {
        User theUser = new User(
            ProfileId = profileId,
            Alias = 'theUser',
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'First',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = userName
        );
        if(contactId != null) {
            theUser.ContactId = contactId;
        }
        if(userRoleId != null) {
            theUser.UserRoleId = userRoleId;
        }
        if(isInsert) {
            insert theUser;
        }
        return theUser;
    }
    
    // This method creates a new account.
    public static Account createAccount(String theName, Id OwnerId, Boolean isInsert) {
        Account theAccount = new Account(Name = theName);
        theAccount.ShippingStreet = 'Test Street';
        theAccount.ShippingCity = 'City';
        theAccount.ShippingState = 'State';
        theAccount.ShippingPostalCode = '12345';
        if(OwnerId != null) {
            theAccount.OwnerId = OwnerId;
        }
        if(isInsert) {
            insert theAccount;
        }
        return theAccount;
    }
    
    // This method creates a new contact.
    public static Contact createContact(String firstName, String lastName, Id accountId, Boolean isActive, Boolean isInsert) {
        Contact theContact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = accountId,
            Active__c = isActive
        );
        if(isInsert) {
            insert theContact;
        }
        return theContact;
    }
    
    //This method creates a new Lead.    
    public static Lead CreateLead(String firstName, String lastName, String Status,Id accountId, Id ContactId,String Company,Boolean isInsert){ 
        Lead Led = new Lead(
            LastName = lastName,
            FirstName = firstName,
            Status = Status,
            Company = Company,       
            Account__c = accountId,
            Contact__c = ContactId );
        if(isInsert) {
            insert Led;
        }
        return Led;
        
    }       
    
    // This method creates a new case.
    public static Case createCase(String subject, String status, String theType, String description, Id contactId,
                                  Id accountId, Boolean isInsert) {
                                      Case theCase = new Case(
                                          Subject = subject,
                                          Status = status,
                                          Type = theType,
                                          Description = description
                                      );
                                      if(accountId != null) {
                                          theCase.AccountId = accountId;
                                      }
                                      if(contactId != null) {
                                          theCase.ContactId = contactId;
                                      }
                                      if(isInsert) {
                                          insert theCase;
                                      }
                                      return theCase;
                                  }
    
    // This method creates a new account relationship.
    public static Account_Relationship__c createAccountRelationship(Id parentAccountId, Id childAccountId, Id contactToId,
                                                                    String contactRole, Boolean isActive, Boolean isInsert) { 
                                                                        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
                                                                            Parent_Account__c = parentAccountId,
                                                                            Child_Account__c = childAccountId,
                                                                            Contact_To__c = contactToId,
                                                                            Contact_Role__c = contactRole,
                                                                            Active__c = isActive
                                                                        );
                                                                        if(isInsert) {
                                                                            insert theAccountRelationship;
                                                                        }
                                                                        return theAccountRelationship;
                                                                    }
    // This method creates a new account relationship.
    public static Account_Relationship__c createAccountRelationshipWithRecordType(Id parentAccountId, Id contactId,String contactRole, Boolean isActive,String recordTypeName,String recordTypeId,String relationType) {        
        Id recTypeId = recordTypeId != null? recordTypeId:Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
            Parent_Account__c = parentAccountId,
            Relationship_Type__c = relationType,
            Contact_To__c = contactId,
            Contact_Role__c = contactRole,
            Active__c = isActive,
            RecordTypeId = recTypeId
        );
        
        try{
          insert theAccountRelationship;
        }catch(DMLException DMlEx){
            system.debug(''+DMlEx.getMessage());
        }
        
        return theAccountRelationship;
    }
    
    // This method creates a case comment related to a case : Ravindra Shekhawat
    public static CaseComment createCaseComment(String commentBody, Id caseId, Boolean isPublished, Boolean isInsert) {
        CaseComment newComment = new CaseComment(
            ParentId = caseId,
            IsPublished = isPublished,
            CommentBody = commentBody
        );
        if(isInsert) {
            insert newComment;
        }
        return newComment;
    }
    
    // This method creates records for custom setting named "Switch_TaskTrigger__c".
    public static Switch_TaskTrigger__c createSwitchTaskTriggerCustomSettingData(Boolean overallTriggerOff,
                                                                                 Boolean accountSalesLockUserOff, Boolean isInsert) {
                                                                                     Switch_TaskTrigger__c theCustomSettingData = new Switch_TaskTrigger__c(
                                                                                         Set_Overall_Trigger_Off__c = overallTriggerOff,
                                                                                         Set_Account_Sales_Lock_User_Off__c = accountSalesLockUserOff
                                                                                     );
                                                                                     if(isInsert) {
                                                                                         insert theCustomSettingData;
                                                                                     }
                                                                                     return theCustomSettingData;
                                                                                 }
    
    // This method creates a new task record.
    public static Task createTask(Id relatedId, String theSubject, String theType, Date activityDate, String theStatus, Boolean isInsert) {
        Task theTask = new Task(
            WhatId = relatedId,
            Subject = theSubject,
            Type = theType,
            ActivityDate = activityDate,
            Status = theStatus
        );
        if(isInsert) {
            insert theTask;
        }
        return theTask;
    }
    
    // This method creates a new public group.
    public static Group createPublicGroup(String groupName, Boolean isInsert) {
        Group theGroup = new Group(
            Type = 'Regular',
            Name = groupName
        );
        if(isInsert) {
            insert theGroup;
        }
        return theGroup;
    }
    
    // This method creates a new public group member.
    public static GroupMember createPublicGroupMember(Id userOrGroupId, Id groupId, Boolean isInsert) {
        GroupMember theGroupMember = new GroupMember(
            UserOrGroupId = userOrGroupId,
            GroupId = groupId
        );
        if(isInsert) {
            insert theGroupMember;
        }
        return theGroupMember;
    }
    
    // This method create Article of FAQ_kav Type : Ravindra Shekhawat.
    public static FAQ__kav createFAQArticle(boolean isInsert,String title,Integer artNumber){
        FAQ__kav articleKav = new FAQ__kav(
            Language ='en_US',
            Title='Test Article',
            UrlName='JF-TestData-00'+artNumber
        );
        
        if(isInsert){
            insert articleKav;
        }
        return articleKav;
    }
    
    /*
@method      : createProductAndAccountFieldsMappingData
@description : This method creates test data for custom setting named "Product_And_Account_Fields_Mapping__c".
@params      : void
@returns     : List<Product_And_Account_Fields_Mapping__c>
*/
    public static List<Product_And_Account_Fields_Mapping__c> createProductAndAccountFieldsMappingData() {
        // Custom Setting Data.
        Map<String, String> theCustomSettingData = new Map<String, String>{
            '41500002' => 'Own_OSR__c',
                '41500007' => 'Own_FH__c',
                'DIGITALAGENT' => 'Own_DAP__c',
                'FIVESTREET' => 'Own_FS__c',
                'LISTHUB' => 'Own_LH__c',
                'TPCRMLICEN' => 'Own_TP_CRM__c',
                'TPFTWEBSIT' => 'Own_TP_Website__c',
                'TPIDXLICEN' => 'Own_IDX__c',
                'TPMKTSNAPT' => 'Own_MS__c'
                };
                    
                    // Inserting Custom Setting Data.
                    List<Product_And_Account_Fields_Mapping__c> theCustomSettingRecords = new List<Product_And_Account_Fields_Mapping__c>();
        for(String productCode : theCustomSettingData.keySet()) {
            theCustomSettingRecords.add(new Product_And_Account_Fields_Mapping__c(
                Name = productCode,
                Accout_Field_API_Name__c = theCustomSettingData.get(productCode)
            ));
        }
        insert theCustomSettingRecords;
        return theCustomSettingRecords;
    }
    
    // Asset-2956 Assert ApexMessages in test Class
    public static boolean wasMessageAdded(ApexPages.Message message) {
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean messageFound = false;
        for(ApexPages.Message msg : pageMessages) {
            if(message.getSummary() == message.getSummary()
               && message.getDetail() == message.getDetail()
               && message.getSeverity() == message.getSeverity()) {
                   messageFound = true;        
               }
        }
        
        return messageFound;
    }
    
    public static Account createAccountWithEmailAndPhone(String accountType,String email, String phone){
        Account acc = new Account();
        acc.Type = accountType;
        acc.Name = 'Venkat Test Account';
        acc.Display_Name__c = 'Venkat Test Account';
        acc.BillingCountry = 'US';
        acc.BillingCity = 'Santa Clara';
        //acc.BillingCode = '95053';
        acc.Billingstreet = '500 El Camino Real';
        acc.Email_Address__c = email;
        acc.Phone = phone;
        acc.Website = 'www.move.com';
        try{
            insert acc;
        }catch(DMLException DMLEx){
            system.debug(' *** Failed to Create Account '+DMLEx.getMessage());
        }       
        System.debug(' *** ACC '+acc.Id);        
        return acc;
    }
    
    public static Contact createContactWithEmailAndPhone(String email, String phone){
        Contact contactRecord = new Contact();
        contactRecord.lastname = 'Arisa';
        contactRecord.firstname = 'Venkat';
        contactRecord.Active__c = true;
        contactRecord.email = email;
        contactRecord.Phone = phone;
        
        try{
            insert contactRecord;       
            system.debug(' *** contactRecord ** '+contactRecord);
        }catch(DMLException DMLEx){
            system.debug(' *** DMLEx *** '+DMLEx.getMessage());
        }
        
        return contactRecord;
    }
    
    public static ContactMethod__c createContactMethod(Id contactId,String type, String value,Boolean isActive,Boolean isPrimaryToContact,String typePurpose){
        ContactMethod__c contactMethod = new ContactMethod__c();
        contactMethod.Contact__c = contactId;
        contactMethod.Type__c = type;
        contactMethod.Value__c = type == 'Web' ? value:null;
        contactMethod.Email__c = type == 'Email' ? value:null;
        contactMethod.Phone__c = type == 'Phone' ? value:null;
        contactMethod.Active__c = isActive;
        contactMethod.Primary_To_Contact__c = isPrimaryToContact;
        contactMethod.Source_Type__c = 'Web';
        contactMethod.Type_Purpose__c = typePurpose;
        
        try{
            insert contactMethod;
            system.debug(' *** contactMethod ** '+contactMethod);
        }catch(DMLException DMLEx){
            system.debug(' *** Failed to create contact Method *** '+DMLEx.getMessage());
        }
        
        return contactMethod;        
    }
    
    
    public static DisabledTrigger__c createDisbaleTriggerCustomSetting(){
        DisabledTrigger__c disbaleTgr = new DisabledTrigger__c();
        disbaleTgr.Name = 'Disabled';
        disbaleTgr.TaskTrigger__c = 'datamigration@move.com.dev';
        insert disbaleTgr;
        
        return disbaleTgr;
    }   
    
    
}