/*
    Purpose: Class to create mostly used test class record.
    Created by: Varun Agarwal
    Created date : 16/1/2018
*/
public with sharing class SFMC_TestDataFactory {
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

  // This method creates a new account.#
  public static Account createAccount(String theName, Id OwnerId, Boolean isInsert) {
    Account theAccount = new Account(Name = theName);
    theAccount.ShippingStreet = 'Test Street';
    theAccount.ShippingCity = 'City';
    theAccount.ShippingState = 'State';
    theAccount.ShippingPostalCode = '12345';
    theAccount.Type = 'Realtor Agent';
    if(OwnerId != null) {
      theAccount.OwnerId = OwnerId;
    }
    if(isInsert) {
      insert theAccount;
    }
    return theAccount;
  }


  // This method creates a new contact.#
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
    
    
     //This method creates a new Lead.    
   public static Lead CreateLead(String firstName, String lastName, String Status,Id accountId, Id ContactId,String Company, String leadOrigin, Boolean isInsert){ 
       Lead Led = new Lead(
        LastName = lastName,
        FirstName = firstName,
        Status = Status,
        Company = Company,   
        Lead_Origin__c = leadOrigin,    
        Account__c = accountId,
        Contact__c = ContactId );
   if(isInsert) {
      insert Led;
    }
    return Led;
        
    }   
       
    //This method creates a new Lead. 
   public static Lead CreateLead(String firstName, String lastName, String Status,Id accountId, Id ContactId, Id contactMethodId,String Company,Boolean isInsert){ 
       Lead Led = CreateLead(firstName,lastName,Status,accountId,ContactId,Company,false);
       Led.Contact_Method__c = contactMethodId;
   if(isInsert) {
      insert Led;
    }
    return Led;
        
    }

     //This method creates a new Lead with campaign
    public static Lead CreateLead(String firstName, String lastName, String Status,Id accountId, Id ContactId, Id contactMethodId,String Company,String campaignId, Boolean isInsert){ 
       Lead Led = CreateLead(firstName,lastName,Status,accountId,ContactId,contactMethodId,Company,false);
       Led.Link_Campaign__c= campaignId;
   if(isInsert) {
      insert Led;
    }
    return Led;
        
    }

     //This method creates a new Lead with Last Reset Date
    public static Lead CreateLead(String firstName, String lastName, String Status,Id accountId, Id ContactId,String Company,Datetime resetDate, Boolean isInsert){ 
       Lead Led = CreateLead(firstName,lastName,Status,accountId,ContactId,Company,false);
       Led.Engagement_Score_Reset_Date__c= resetDate;
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
    //#
     public static Campaign CreateCampaign(String Name, Boolean isActive, Boolean isInsert){
            Campaign campaignRecord = new Campaign(Name = Name, IsActive = isActive);
            if(isInsert){
              insert campaignRecord;
            }
            return campaignRecord;
     }
     
     

     public static Campaign CreateCampaign(String Name, String TargetAccountType,Boolean isActive, Boolean isInsert){
            Campaign campaignRecord = CreateCampaign(Name,isActive,false);
            campaignRecord.Target_Account_Type__c = TargetAccountType;
            if(isInsert){
              insert campaignRecord;
            }
            return campaignRecord;
     }
     
    // This method creates a new contact Method.#
    public static ContactMethod__c createContactMethod(Id contactId,String mType,String typePurpose,String value, Boolean isActive, Boolean isInsert) {
        ContactMethod__c theContactMethod = new ContactMethod__c(
                Contact__c = contactId,
                Type__c = mType,
                Type_Purpose__c = typePurpose,
                Email__c = mType.equals('Email') ? value : null,
                Phone__c = mType.equals('Phone') ? value : null,
                Value__c = value,            
                Active__c = isActive,
                Source_Type__c = 'Landing Page'
        );        
        if(isInsert) {
          insert theContactMethod;
        }
        return theContactMethod;
    }
    
    public static ContactMethod__c createContactMethod(Id contactId,String type, String value,Boolean isActive,Boolean isPrimaryToContact,String typePurpose,Boolean isInsert){
        ContactMethod__c contactMethod = new ContactMethod__c();
        contactMethod.Contact__c = contactId;
        contactMethod.Type__c = type;
        contactMethod.Value__c = type.equals('Web') ? value : null;
        contactMethod.Email__c = type.equals('Email') ? value : null;
        contactMethod.Phone__c = type.equals('Phone') ? value : null;
        contactMethod.Active__c = isActive;
        contactMethod.Primary_To_Contact__c = isPrimaryToContact;
        contactMethod.Source_Type__c = type;
        contactMethod.Type_Purpose__c = typePurpose;
        
        if(isInsert){
            try{
                insert contactMethod;
                system.debug(' *** contactMethod ** '+contactMethod);
            }catch(DMLException DMLEx){
                system.debug(' *** Failed to create contact Method *** '+DMLEx.getMessage());
            }
          }
        
        return contactMethod;        
    }
    
    public static Engagement_Activity_Type__c createEngagementActivtyType(String sType,Decimal score, Decimal weightage, boolean isInsert){
        Engagement_Activity_Type__c theEAType = new Engagement_Activity_Type__c(
            Type__c = sType,
            Weightage__c = weightage,
            Score__c = score
        );
        if(isInsert) {
          insert theEAType;
        }
        return theEAType;
    }
    public static Engagement_Activity__c createEngagementActivty(Id contactId, Id leadId,Id engagementActivtyTypeId,boolean isInsert){
        Engagement_Activity__c theEAREcord = new Engagement_Activity__c(
            Contact__c = contactId,
            Lead__c = leadId,
            Engagement_Activity_Type__c = engagementActivtyTypeId,
            Score__c = 100,
            Activity_Date__c = system.now()
        );
        if(isInsert) {
          insert theEAREcord;
        }
        return theEAREcord;
    }
    public static Engagement_Activity__c createEngagementActivity(Id contactMethodId, Id engagementActivtyTypeId,boolean isInsert){
        Engagement_Activity__c theEAREcord = new Engagement_Activity__c(
            Contact_Method__c = contactMethodId,
            Engagement_Activity_Type__c = engagementActivtyTypeId,
            Score__c = 100
        );
        if(isInsert) {
          insert theEAREcord;
        }
        return theEAREcord;
    }

    public static Engagement_Activity__c createEngagementActivity(Id contactMethodId, Id engagementActivtyTypeId, Id campaignId,boolean isInsert){
        Engagement_Activity__c theEAREcord  = createEngagementActivity(contactMethodId,engagementActivtyTypeId,false);
        theEAREcord.Campaign__c = campaignId;
        theEAREcord.Activity_Date__c = system.now();
        if(isInsert) {
          insert theEAREcord;
        }
        return theEAREcord;
    }

    public static LeadScoreManageRun__c createLeadManageRunCustomsetting(String Name,DateTime lastRunDate,Boolean isInsert){
        LeadScoreManageRun__c leadScoreManageRunObj = new LeadScoreManageRun__c();
        leadScoreManageRunObj.name = Name;  
        leadScoreManageRunObj.LastRunDate__c = lastRunDate; 
        if(isInsert){
            insert leadScoreManageRunObj;
        }
        return leadScoreManageRunObj;
    }
    //#
    public static Form_Submission__c createFormSubmission(String name,String email,string phone,boolean isInsert){
        Form_Submission__c theFormSubmissionrecord = new Form_Submission__c(
            First_Name__c = name,
            Last_Name__c = name,
            Email__c = email,
            Phone__c = phone
        );
        if(isInsert) {
          insert theFormSubmissionrecord;
        }
        return theFormSubmissionrecord;
    }
    public static MergeHistory__c createMergeHistory(String victimID,String SurvivorId,String ObjectName,boolean isInsert){
        MergeHistory__c theMergeHistoryRecord = new MergeHistory__c(
            Victim_Id__c = victimID,
            Survivor_Id__c = SurvivorId,
            Object_Name__c = ObjectName
        );
        if(isInsert) {
          insert theMergeHistoryRecord;
        }
        return theMergeHistoryRecord;
        
    }
}