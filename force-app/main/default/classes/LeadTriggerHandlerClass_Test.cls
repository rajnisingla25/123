@isTest(seeAllData = false)
public  class LeadTriggerHandlerClass_Test
{
    static
    {
        LeadTriggerhandler.isExecuted = True;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        Dtrg.AccountRelationshipTrigger__c = UserInfo.getUserName();
        
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
    }
    
    @testSetup static void setup() {
        
        List<Account> lstAccount = new     List<Account>();  
        
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '(860) 347-0333';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Email_Address__c= 'c.s1@gmail.com';
        newAccount.Home_Phone__c= '(510) 915-8382';
        newAccount.Work_Phone__c = '(510) 915-8382';
        newAccount.Mobile1__c = '(510) 915-8382';
        newAccount.Mobile2_Other__c = '(510) 915-8382';
        newAccount.party_id__c = '206084041';
        //newAccount.Type = 'Broker';
        newAccount.Type = 'Realtor Agent';
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        lstAccount.add(newAccount);
        //insert newAccount;
        
        Account Acc2 = new Account();
        Acc2.name='XYZ';
        Acc2.Phone = '(860) 347-0333';
        Acc2.Preferred_Phone__c = 'Work';
        Acc2.BillingStreet = 'Am Tierpark 16';
        Acc2.BillingCity = 'Cologne';
        Acc2.BillingPostalCode = '54321';
        Acc2.BillingState = 'Nordrhein-Westfalen';
        Acc2.BillingCountry = 'Germany';
        Acc2.Email_Address__c = 'c.s1@gmail.com';
        Acc2.Home_Phone__c= '(847) 915-8382';
        Acc2.Work_Phone__c = '(847) 915-8382';
        Acc2.Mobile1__c = '(847) 915-8382';
        Acc2.Mobile2_Other__c = '(847) 915-8382';
        Acc2.party_id__c = '206084042';
        Acc2.Type = 'Realtor Agent';
        Acc2.Account_Sub_Type__c='Prospect';
        Acc2.Auto_Renewal__c = True;
        Acc2.Territories__c = 'test';
        lstAccount.add(Acc2);
        //insert Acc2;
        Insert lstAccount;
        
        
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account= newAccount;
        myContact.MailingStreet= newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity=newAccount.BillingCity;
        myContact.MailingPostalCode=newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        
        List<Account_Relationship__c> AccRelList = new List<Account_Relationship__c>();
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        Account_Relationship__c accRelationship = new Account_Relationship__c();
        accRelationship.Parent_Account__c = newAccount.id;
        accRelationship.Contact_To__c = myContact.id;
        accRelationship.Relationship_Type__c = 'Contact';    
        accRelationship.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship);
        
        insert AccRelList;
        
        List<Lead> LedBefore = new List<Lead>();
        List<Lead> LedBefore2 = new List<Lead>();
        
        // Lead with No Account and Single Match for RDC Contact Type = Single Agent       
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test';
        LedB1.Status = 'New';
        LedB1.Company = 'Test';
        LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = 'Test';
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        LedB1.Account__c = newAccount.id;
        //LedB1.Contact__c = myContact1.id;
        LedBefore.add(LedB1); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Phone and Email of Account - Acc2       
        Lead LedB2 = new Lead();
        LedB2.LastName = 'Mr';
        LedB2.FirstName = 'Test';
        LedB2.Status = 'New';
        LedB2.Company = 'Test';
        LedB2.Contact__c = myContact.id;
        LedB2.Phone = '(860) 347-0333';
        LedB2.Email = 'c.s1@gmail.com';
        LedB2.Marketing_Lead_Type__c = 'Organic Leads';
        LedB2.Recent_Campaign__c = 'Test';
        LedB2.RDC_Contact_Type__c = 'Managing Broker';
        
        LedBefore.add(LedB2); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Phone of Account - Acc2      
        Lead LedB3 = new Lead();
        LedB3.LastName = 'Mr';
        LedB3.FirstName = 'Test';
        LedB3.Status = 'New';
        LedB3.Company = 'Test'; 
        LedB3.Phone ='(860) 347-0333';
        LedB3.Email = 'c.s1@gmail.com';
        LedB3.Marketing_Lead_Type__c = 'Organic Leads';
        LedB3.Recent_Campaign__c = 'Test';
        LedB3.RDC_Contact_Type__c = 'Single Agent';
        LedB3.Contact__c = myContact.id;
        LedBefore.add(LedB3); 
        
        Insert LedBefore;                      
    }
    
    public static testMethod void main(){      
        
        Account newAccount = new Account();
        Account Acc2 = new Account();
        List<Account> lstAccount = [Select Id,Name,Email_Address__c,BillingStreet,BillingState,BillingCity,BillingPostalCode,BillingCountry,Phone from Account];
        newAccount = lstAccount[0];
        Acc2 = lstAccount[1];
        
        List<Contact> lstContact = new List<Contact>();
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account= newAccount;
        myContact.MailingStreet= newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity=newAccount.BillingCity;
        myContact.MailingPostalCode=newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        lstContact.add(myContact);
        //insert myContact;
        myContact = lstContact[0];
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= newAccount;
        myContact2.MailingStreet= newAccount.BillingStreet;
        myContact2.MailingState = newAccount.BillingState;
        myContact2.MailingCity=newAccount.BillingCity;
        myContact2.MailingPostalCode=newAccount.BillingPostalCode;
        myContact2.MailingCountry = newAccount.BillingCountry;
        myContact2.Phone=newAccount.Phone;
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        lstContact.add(myContact2);
        Insert lstContact;
        //insert myContact2;
        myContact2 = lstContact[1];
        
        
        List<Account_Relationship__c> AccRelList = new List<Account_Relationship__c>();
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        Account_Relationship__c accRelationship = new Account_Relationship__c();
        accRelationship.Parent_Account__c = newAccount.id;
        accRelationship.Contact_To__c = myContact.id;
        accRelationship.Relationship_Type__c = 'Contact';    
        accRelationship.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship);
        
        Account_Relationship__c accRelationship2 = new Account_Relationship__c();
        accRelationship2.Parent_Account__c = Acc2.id;
        accRelationship2.Contact_To__c = myContact2.id;
        accRelationship2.Relationship_Type__c = 'Contact';    
        accRelationship2.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship2.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship2);
        
        Account_Relationship__c accRelationship3 = new Account_Relationship__c();
        accRelationship3.Parent_Account__c = newAccount.id;
        accRelationship3.Contact_To__c = myContact2.id;
        accRelationship3.Relationship_Type__c = 'Contact';    
        accRelationship3.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship3.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship3);
        
        insert AccRelList;
        
        List<id> accountlist = new List<id>();
        accountlist.add(newAccount.id);
        
        Map<Id,List<Id>> mapContactAccountIds = new  Map<Id,List<Id>>();
        mapContactAccountIds.put(newAccount.id,accountlist);
        
        // Added by Ck to take care of additional List and Map
        String keyAccountPhoneEmailIds = Acc2.Phone+Acc2.Email_Address__c;
        List<Id> lstAccPhoneEmailIds = new List<id>();
        lstAccPhoneEmailIds.add(Acc2.id);
        
        Map<String,List<Id>> mapLeadAccountPhoneEmailIds = new  Map<String,List<Id>>();
        mapLeadAccountPhoneEmailIds.put(keyAccountPhoneEmailIds,lstAccPhoneEmailIds);
        
        // Addition Ends
        
        Group AssignedPublicGroups = new Group();
        AssignedPublicGroups.DeveloperName = 'test_group1';
        AssignedPublicGroups.Name = 'test_group1'; 
        AssignedPublicGroups.type = 'Regular'; 
        insert AssignedPublicGroups; 
        system.debug('AssignedPublicGroups:' + AssignedPublicGroups.Id);
        //SELECT CreatedById,DeveloperName,Id,Name,OwnerId FROM Group where Type !=: Constants.QueueName limit 1];     
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            
            GroupMember gp = new GroupMember(GroupId = AssignedPublicGroups.Id,UserOrGroupId = UserInfo.getUserId());
            insert gp;            
            
            QueuesObject testQueue = new QueueSObject(QueueID = AssignedPublicGroups.id, SObjectType = 'Lead');
            insert testQueue;
            system.debug('testQueue:' + testQueue.Id);
        }
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        test.startTest();
        insert Campaigns;
        
        
        List<Lead> LedBefore = new List<Lead>();
        List<Lead> LedBefore2 = new List<Lead>();
        
        // Lead with No Account and Single Match for RDC Contact Type = Single Agent       
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test';
        LedB1.Status = 'New';
        LedB1.Company = 'Test';
        LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = 'Test';
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        LedB1.Account__c = acc2.id;
        //LedB1.Contact__c = myContact1.id;
        LedBefore.add(LedB1); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Phone and Email of Account - Acc2       
        Lead LedB2 = new Lead();
        LedB2.LastName = 'Mr';
        LedB2.FirstName = 'Test';
        LedB2.Status = 'New';
        LedB2.Company = 'Test';
        LedB2.Contact__c = myContact2.id;
        LedB2.Phone = '(860) 347-0333';
        LedB2.Email = 'c.s1@gmail.com';
        LedB2.Marketing_Lead_Type__c = 'Organic Leads';
        LedB2.Recent_Campaign__c = 'Test';
        LedB2.RDC_Contact_Type__c = 'Managing Broker';
        
        LedBefore.add(LedB2); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Phone of Account - Acc2      
        Lead LedB3 = new Lead();
        LedB3.LastName = 'Mr';
        LedB3.FirstName = 'Test';
        LedB3.Status = 'New';
        LedB3.Company = 'Test'; 
        LedB3.Phone ='(860) 347-0333';
        LedB3.Email = 'c.s1@gmail.com';
        LedB3.Marketing_Lead_Type__c = 'Organic Leads';
        LedB3.Recent_Campaign__c = 'Test';
        LedB3.RDC_Contact_Type__c = 'Single Agent';
        LedB3.Contact__c = myContact2.id;
        LedBefore.add(LedB3); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Email of Account - Acc2       
        Lead LedB4 = new Lead();
        LedB4.LastName = 'Mr';
        LedB4.FirstName = 'Test';
        LedB4.Status = 'New';
        LedB4.Company = 'Test';    
        LedB4.Phone = '(860) 347-0333';
        LedB4.Email = 'c.s1@gmail.com';
        LedB4.Marketing_Lead_Type__c = 'Organic Leads';
        LedB4.Recent_Campaign__c = 'Test';
        LedB4.RDC_Contact_Type__c = 'Single Agent';
        LedB4.Contact__c = myContact2.id;
        LedBefore.add(LedB4);
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Null
        // Match will be by Phone and Email of Account - Acc2 
        Lead LedB5 = new Lead();
        LedB5.LastName = 'Mr';
        LedB5.FirstName = 'Test';
        LedB5.Status = 'New';
        LedB5.Company = 'Test';    
        LedB5.Phone = '(860) 347-0333';
        LedB5.Email = 'c.s1@gmail.com';
        LedB5.Marketing_Lead_Type__c = 'Organic Leads';
        LedB5.Recent_Campaign__c = 'Test';
        LedB5.Link_Campaign__c = Campaigns.id;  
        LedB5.RDC_Contact_Type__c = 'Managing Broker';
        LedB5.Contact__c = myContact2.id;
        LedBefore.add(LedB5); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Null
        // Match will be by Phone of Account - Acc2   
        Lead LedB6 = new Lead();
        LedB6.LastName = 'Mr';
        LedB6.FirstName = 'Test';
        LedB6.Status = 'New';
        LedB6.Company = 'Test';
        // LedB6.Account__c = newAccount.id;
        LedB6.Contact__c = myContact2.id;
        ledB6.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        LedB6.Phone = '(860) 347-0333';
        LedB6.Email = 'c.s1@gmail.com';
        LedB6.Marketing_Lead_Type__c = 'Organic Leads';
        LedB6.Recent_Campaign__c = 'Test';
        LedB6.Link_Campaign__c = Campaigns.id;
        LedB6.RDC_Contact_Type__c = 'Managing Broker';
        
        LedBefore.add(LedB6); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Null
        // Match will be by Email of Account - Acc2  
        Lead LedB7 = new Lead();
        LedB7.LastName = 'Mr';
        LedB7.FirstName = 'Test';
        LedB7.Status = 'New';
        LedB7.Company = 'Test';
        //LedB7.Account__c = newAccount.id;
        LedB7.Contact__c = myContact2.id;
        ledB7.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        //LedB7.Phone = '8479158382';
        LedB7.Phone = '(860) 347-0333';
        LedB7.Email = 'c.s1@gmail.com';
        LedB7.Marketing_Lead_Type__c = 'Organic Leads';
        LedB7.Recent_Campaign__c = 'Test';
        LedB7.Recent_Campaign_Id__c = Campaigns.id;
        LedB7.RDC_Contact_Type__c = 'Managing Broker';
        
        LedBefore.add(LedB7);
        
        // Lead with No Account and Multiple Match for RDC Contact Type != Null
        // Match will be by Email of Account - Acc2
        Lead LedB8 = new Lead();
        LedB8.LastName = 'Mr';
        LedB8.FirstName = 'Test';
        LedB8.Status = 'New';
        LedB8.Company = 'Test';
        //LedB8.Account__c = Account.id;
        LedB8.Contact__c = myContact2.id;
        ledB8.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        LedB8.Phone = '(860) 347-0333';
        LedB8.Email = 'c.s1@gmail.com';
        LedB8.Marketing_Lead_Type__c = 'Organic Leads';
        LedB8.Recent_Campaign__c = 'Test';
        
        LedB8.RDC_Contact_Type__c = 'Single Agent';
        
        LedBefore.add(LedB8); 
        
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Null
        // Match will be by Email of Account - Acc2
        Lead LedB9 = new Lead();
        LedB9.LastName = 'Mr';
        LedB9.FirstName = 'Test';
        LedB9.Status = 'New';
        LedB9.Company = 'Test';
        //LedB9.Account__c = Account.id;
        LedB9.Contact__c = myContact.id;
        ledB9.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        LedB9.Phone = '(860) 347-0333';
        LedB9.Email = 'c.s1@gmail.com';
        LedB9.Marketing_Lead_Type__c = 'Organic Leads';
        LedB9.Recent_Campaign__c = 'Test';
        LedB9.Link_Campaign__c = Campaigns.id;
        //LedB9.RDC_Contact_Type__c = 'Single Agent';
        
        LedBefore.add(LedB9);
        
        //Lead with Account Acc2 email
        Lead LedB13 = new Lead();
        LedB13.LastName = 'Mr';
        LedB13.FirstName = 'Test';
        LedB13.Status = 'New';
        LedB13.Company = 'Test';
        //LedB13.Account__c = newAccount.id;
        //LedB13.Contact__c = myContact.id;
        LedB13.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        LedB13.Phone = '(860) 347-0333';
        LedB13.Email = 'c.s1@gmail.com';
        LedB13.Marketing_Lead_Type__c = 'Organic Leads';
        LedB13.Recent_Campaign__c = 'Test';
        LedB13.Recent_Campaign_Id__c = Campaigns.id;
        
        //LedB12.RDC_Contact_Type__c = 'Single Agent';
        
        LedBefore.add(LedB13);
        
        
        Insert LedBefore;
        //Insert LedBefore2;
        
        List<Lead> LedAll = new List<Lead>();
        
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = newAccount.id;
        Led.Contact__c = myContact.id;
        led.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led.Phone = '(860) 347-0333';
        Led.Email = 'c.s1@gmail.com';
        Led.Marketing_Lead_Type__c = 'Organic Leads';
        Led.Recent_Campaign__c = 'Test';
        Led.Recent_Campaign_Id__c = Campaigns.id;
        LedB4.RDC_Contact_Type__c = 'Managing Broker';
        
        LedAll.add(Led); 
        
        //Insert LedAll; 
        
        List<Lead> LedAll1 = new List<Lead>();
        
        Lead Led1 = new Lead();
        Led1.LastName = 'Mr';
        Led1.FirstName = 'Test';
        Led1.Status = 'New';
        Led1.Company = 'Test';
        Led1.Account__c = newAccount.id;
        Led1.Contact__c = myContact.id;
        led1.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led1.Phone = '(860) 347-0333';
        Led1.Email = 'c.s1@gmail.com';
        Led1.Marketing_Lead_Type__c = 'Organic Leads';
        Led1.Recent_Campaign__c = 'Test';
        Led1.Recent_Campaign_Id__c = Campaigns.id;
        LedB4.RDC_Contact_Type__c = 'Managing Broker';
        Led1.Follow_Up_Status__c='Sent Email';
        Led1.Rejected_Reason__c ='Test';
        Led1.Callback_Time__c = '6:00 AM';
        Led1.Callback_Date__c = '10/10/2016';
        LedAll.add(Led1);  
        
        Insert LedAll;     
        
        
        Map<id,Lead> LedMap = new Map<id,Lead>();
        LedMap.put(LedAll[1].id,LedAll[1]);          
        Account_Relationship__c AR = new Account_Relationship__c();
        AR.Zuora_Bill_to_Contact_ID__c= 'Test';
        AR.Parent_Account__c = newAccount.id;
        AR.Contact_To__c = myContact.id; 
        //Insert AR;        
        Map<Id,List<Id>> mapContatAccountIds = new  Map<Id,List<String>>();
        
        Campaign_History__c Campaignhist = new Campaign_History__c(); 
        Campaignhist.Account__c = newAccount.id;
        Campaignhist.Contact__c = myContact.id;   
        //Campaignhist.Lead__c = LedAll[0].id;
        Campaignhist.Lead__c = LedBefore[5].id;
        Campaignhist.Campaign__c = Campaigns.id;
        insert Campaignhist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact.Id; 
        m1.CampaignId = Campaigns.Id;
        
        // m1.LeadId = LedAll[0].id;
        //m1.LeadId = LedBefore[5].id;  // changed to below line on 5th May 2016
        m1.LeadId = Led1.id; 
        insert m1;
        //for(Lead leadck : LedAll){
        // List<Account> insertedAccounts = [Select Id from Account where Type = 'Broker' AND Phone =: leadck.Phone AND Email_Address__c =: leadck.email];
        // }
        
        LeadTriggerhandler.isExecuted = False;
        LedAll[1].Status = 'Converted';
        LedAll[1].Follow_Up_Status__c='Contacted - Callback';
        // LedAll[1].Rejected_Reason__c='xyz';
        // LedAll[1].Notes_Left__c=0;
        LedAll[1].Callback_Time__c  = '8:00 AM';
        Led1.Callback_Date__c = '11/10/2016';
        //update LedAll;
        
        Map<id,Lead> LedMapNew = new Map<id,Lead>();
        LedMapNew.put(LedAll[1].id,LedAll[1]);   
        system.debug('Old values'+LedMap);
        system.debug('New values'+LedMapNew);
        
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(LedBefore);
        //LHC.LeadHandlerBefore(LedBefore2);
        
        //LHC.LeadHandlerBefore(LedAll);
        
        LHC.LeadHandlerAfter(LedAll,LedMap);
        //LHC.LeadHandlerAfter(LedBefore,LedMap);
        
        //LHC.LeadSharing(LedAll);
        Led1.OwnerId = AssignedPublicGroups.Id;
        
        // LHC.LeadHandlerAfterRR(LedAll);
        LHC.LeadHandlerAfter(LedAll,LedMap);
        LeadTriggerhandler hand = new LeadTriggerhandler();
        try{
            //  LeadTriggerhandler.Afterinsertupdate(LedMapNew,LedMap);
        }catch(exception e){}
        
        //LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        test.stopTest();
    }
    
    public static testMethod void main1(){            
        
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '(510) 915-8382';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Email_Address__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '(510) 915-8382';
        newAccount.Work_Phone__c = '(510) 915-8382';
        newAccount.Mobile1__c = '(510) 915-8382';
        newAccount.Mobile2_Other__c = '(510) 915-8382';
        newAccount.party_id__c = '206084041';
        //newAccount.Type = 'Broker';
        newAccount.Type = 'Broker';
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        insert newAccount;
        
        Account Acc2 = new Account();
        Acc2.name='XYZ';
        Acc2.Phone = '(847) 915-8382';
        Acc2.Preferred_Phone__c = 'Work';
        Acc2.BillingStreet = 'Am Tierpark 16';
        Acc2.BillingCity = 'Cologne';
        Acc2.BillingPostalCode = '54321';
        Acc2.BillingState = 'Nordrhein-Westfalen';
        Acc2.BillingCountry = 'Germany';
        Acc2.Email_Address__c = 'Acc2@gmail.com';
        Acc2.Home_Phone__c= '(847) 915-8382';
        Acc2.Work_Phone__c = '(847) 915-8382';
        Acc2.Mobile1__c = '(847) 915-8382';
        Acc2.Mobile2_Other__c = '(847) 915-8382';
        Acc2.party_id__c = '206084042';
        //Acc2.Type = 'Broker';
        Acc2.Type = 'Broker';
        Acc2.Account_Sub_Type__c='Customer';
        Acc2.Auto_Renewal__c = True;
        Acc2.Territories__c = 'test';
        insert Acc2;
        
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account= newAccount;
        myContact.MailingStreet= newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity=newAccount.BillingCity;
        myContact.MailingPostalCode=newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        
        List<Account_Relationship__c> AccRelList = new List<Account_Relationship__c>();
        
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        Account_Relationship__c accRelationship = new Account_Relationship__c();
        accRelationship.Parent_Account__c = newAccount.id;
        accRelationship.Contact_To__c = myContact.id;
        accRelationship.Relationship_Type__c = 'Contact';    
        accRelationship.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship);
        
        Account_Relationship__c accRelationship2 = new Account_Relationship__c();
        accRelationship2.Parent_Account__c = Acc2.id;
        accRelationship2.Contact_To__c = myContact.id;
        accRelationship2.Relationship_Type__c = 'Contact';    
        accRelationship2.RecordTypeId =  contactRelationshipRecordTypeId;
        accRelationship2.Active__c = true;
        //accRelationship.Parent_Account_Type__c='Test';      
        //accRelationship.Billing_Contact__c = true;
        
        AccRelList.add(accRelationship2);
        
        insert AccRelList;
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Broker';
        
        insert Campaigns;
        
        List<Lead> LedBefore = new List<Lead>();
        
        // Lead with No Account and Single Match for RDC Contact Type = Single Agent       
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test';
        LedB1.Status = 'New';
        LedB1.Company = 'Test';
        LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = 'Test';
        LedB1.RDC_Contact_Type__c = null;
        LedB1.Account__c = newAccount.id;
        LedBefore.add(LedB1); 
        
        // Lead with No Account and Multiple Match for RDC Contact Type = Single Agent
        // Match will be by Phone and Email of Account - Acc2       
        Lead LedB2 = new Lead();
        LedB2.LastName = 'Mr';
        LedB2.FirstName = 'Test';
        LedB2.Status = 'New';
        LedB2.Company = 'Test';
        LedB2.Contact__c = myContact.id;
        LedB2.Phone = Acc2.Phone;
        LedB2.Email = Acc2.Email_Address__c;
        LedB2.Marketing_Lead_Type__c = 'Organic Leads';
        LedB2.Recent_Campaign__c = 'Test';
        LedB2.RDC_Contact_Type__c = null;
        
        LedBefore.add(LedB2);
        
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(LedBefore);
    }
    
    public static testMethod void main2(){ 
    Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        newAccount1.Primary_Email__c= 'c.s1@gmail.com';
        insert newAccount1;
        
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '(860) 347-0333';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Email_Address__c= 'c.s1@gmail.com';
        newAccount.Home_Phone__c= '(510) 915-8382';
        newAccount.Work_Phone__c = '(510) 915-8382';
        newAccount.Mobile1__c = '(510) 915-8382';
        newAccount.Mobile2_Other__c = '(510) 915-8382';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Realtor Agent';
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Primary_Email__c= 'c.s1@gmail.com';
        insert newAccount;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
        Led11.Account__c = newAccount1.id;
        Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = 'Single Agent';
        Led11.phone = '(860) 347-0333';
        
        Lead Led1 = new Lead();
        Led1.LastName = 'Mr';
        Led1.FirstName = 'Test';
        Led1.Status = 'New';
        Led1.Company = 'Test';
        Led1.Account__c = newAccount.id;
        Led1.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led1.Email ='c.s1@gmail.com';
        Led1.Marketing_Lead_Type__c = 'Organic Leads';
        Led1.Recent_Campaign__c = 'Test';
        Led1.Recent_Campaign_Id__c = Campaigns.id;
        Led1.RDC_Contact_Type__c = 'Single Agent';
        Led1.phone = '(860) 347-0333';
        Ldlist.add(Led11);
        Ldlist.add(Led1);
        //insert ldlist;
        
        Account newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = Led1.phone;
        newAccount2.BillingStreet = 'Am Tierpark 16';
        newAccount2.BillingCity = 'Cologne';
        newAccount2.BillingPostalCode = '54321';
        newAccount2.BillingState = 'Nordrhein-Westfalen';
        newAccount2.BillingCountry = 'Germany';
        newAccount2.Email_Address__c= Led1.Email;
        newAccount2.Primary_Email__c= Led1.Email;
        newAccount2.Type = 'Realtor Agent';
        newAccount2.Account_Sub_Type__c='Customer';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
        insert newAccount2;
        
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(ldlist);
    }
    public static testMethod void main3(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Broker';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
        Led11.Account__c = newAccount1.id;
        Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = '';
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(ldlist);
    }
    public static testMethod void main4(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
        Led11.Account__c = newAccount1.id;
        Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = '';
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(ldlist);
    }
    
    public static testMethod void main41(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
        Led11.Account__c = newAccount1.id;
        Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Event';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = 'Single Agent';
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(ldlist);
    }
    
     public static testMethod void main42(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
       // Led11.Account__c = newAccount1.id;
     //   Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Event';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = null;
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        List<Lead> lstLead = [Select id,LastName,FirstName,Status,Company, Lead_Target_Account_Type__c, OwnerId, Contact__c, Account__c ,Phone,Email,Marketing_Lead_Type__c,Recent_Campaign__c,Recent_Campaign_Id__c,
        RDC_Contact_Type__c,Link_Campaign__c from lead where Id=:ldlist[0].id];
        LHC.LeadHandlerBefore(lstLead);
    }
    
    public static testMethod void main43(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Broker';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
       // Led11.Account__c = newAccount1.id;
     //   Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Event';
        Led11.Recent_Campaign__c = 'Test';
        //Led11.Lead_Target_Account_Type__c = 'Broker';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = null;
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        List<Lead> lstLead = [Select id,LastName,FirstName,Status,Company, Lead_Target_Account_Type__c, OwnerId, Contact__c, Account__c ,Phone,Email,Marketing_Lead_Type__c,Recent_Campaign__c,Recent_Campaign_Id__c,
        RDC_Contact_Type__c,Link_Campaign__c from lead where Id=:ldlist[0].id];
        LHC.LeadHandlerBefore(lstLead);
    }
    
    public static testMethod void main44(){ 
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='Joe.Schmoe@test.de';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
       // Led11.Account__c = newAccount1.id;
     //   Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Phone = '(860) 347-0333';
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Event';
        Led11.Recent_Campaign__c = 'Test';
        //Led11.Lead_Target_Account_Type__c = 'Agent';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = null;
        LEd11.Link_Campaign__c = Campaigns.id;
        Ldlist.add(Led11);
        insert ldlist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact1.Id; 
        m1.CampaignId = Campaigns.Id;        
        m1.LeadId = Led11.id; 
        insert m1;
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LHC.LeadHandlerBefore(ldlist);
    }
    
    public static testMethod void main5(){ 
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Target_Account_Type__c = 'Agent';
        insert Campaigns;
        
        Account newAccount1 = new Account();
        newAccount1.name='XYZ';
        newAccount1.Phone = '(860) 347-0333';
        newAccount1.BillingStreet = 'Am Tierpark 16';
        newAccount1.BillingCity = 'Cologne';
        newAccount1.BillingPostalCode = '54321';
        newAccount1.BillingState = 'Nordrhein-Westfalen';
        newAccount1.BillingCountry = 'Germany';
        newAccount1.Email_Address__c= 'c.s1@gmail.com';
        newAccount1.Primary_Email__c= 'c.s1@gmail.com';
        newAccount1.Home_Phone__c= '(510) 915-8382';
        newAccount1.Work_Phone__c = '(510) 915-8382';
        newAccount1.Mobile1__c = '(510) 915-8382';
        newAccount1.Mobile2_Other__c = '(510) 915-8382';
        newAccount1.party_id__c = '206084041';
        newAccount1.Type = 'Realtor Agent';
        newAccount1.Account_Sub_Type__c='Customer';
        newAccount1.Auto_Renewal__c = True;
        newAccount1.Territories__c = 'test';
        insert newAccount1;
        
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '(860) 347-0333';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Email_Address__c= 'c.s1@gmail.com';
        newAccount.Home_Phone__c= '(510) 915-8382';
        newAccount.Work_Phone__c = '(510) 915-8382';
        newAccount.Mobile1__c = '(510) 915-8382';
        newAccount.Mobile2_Other__c = '(510) 915-8382';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Realtor Agent';
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Primary_Email__c= 'c.s1@gmail.com';
        insert newAccount;
        
        Contact myContact1 = new Contact ();
        myContact1.FirstName='Joe';
        myContact1.LastName='Schmoe';
        myContact1.Email='c.s1@gmail.com';
        myContact1.Accountid= newAccount1.id;
        myContact1.MailingStreet= newAccount1.BillingStreet;
        myContact1.MailingState = newAccount1.BillingState;
        myContact1.MailingCity=newAccount1.BillingCity;
        myContact1.MailingPostalCode=newAccount1.BillingPostalCode;
        myContact1.MailingCountry = newAccount1.BillingCountry;
        myContact1.Phone=newAccount1.Phone;
        myContact1.Type__c = 'Other';
        myContact1.Active__c = true;
        insert myContact1;
        
        List<Lead> ldlist = new List<Lead>();
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New';
        Led11.Company = 'Test';
        Led11.Account__c = newAccount1.id;
        Led11.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led11.Email = 'c.s1@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test';
        Led11.Recent_Campaign_Id__c = Campaigns.id;
        Led11.RDC_Contact_Type__c = '';
        Led11.phone = '(860) 347-0333';
        
        Lead Led1 = new Lead();
        Led1.LastName = 'Mr';
        Led1.FirstName = 'Test';
        Led1.Status = 'New';
        Led1.Company = 'Test';
        Led1.Account__c = newAccount.id;
        Led1.Contact__c = myContact1.id;
        //led11.Assigned_Group__c = AssignedPublicGroups.DeveloperName;
        Led1.Email ='c.s1@gmail.com';
        Led1.Marketing_Lead_Type__c = 'Organic Leads';
        Led1.Recent_Campaign__c = 'Test';
        Led1.Recent_Campaign_Id__c = campaigns.id;
        Led1.RDC_Contact_Type__c = '';
        Led1.phone = '(860) 347-0333';
        Ldlist.add(Led11);
        Ldlist.add(Led1);
        insert ldlist;
        ldlist[0].Follow_Up_Status__c='Follow Up Scheduled';
        ldlist[0].NVM_Callback_DateTime__c = DateTime.now();
        update ldlist[0];
        
        Account newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = Led1.phone;
        newAccount2.BillingStreet = 'Am Tierpark 16';
        newAccount2.BillingCity = 'Cologne';
        newAccount2.BillingPostalCode = '54321';
        newAccount2.BillingState = 'Nordrhein-Westfalen';
        newAccount2.BillingCountry = 'Germany';
        newAccount2.Email_Address__c= Led1.Email;
        newAccount2.Primary_Email__c= Led1.Email;
        newAccount2.Type = 'Realtor Agent';
        newAccount2.Account_Sub_Type__c='Customer';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
        insert newAccount2;
        
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
    } 
    
    public static testMethod void main6(){      
        Lead lstLead = [Select Id,name,Status,Follow_Up_Status__c from Lead limit 1];    
        lstLead.Status = 'In Progress';
        update lstLead;
    }
    
    public static testMethod void main7(){
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        
        Map<Id,Lead> mapLead = new Map<Id,Lead>(); 
        Map<Id,Lead> mapNewLead = new Map<Id,Lead>(); 
        Lead lstLead = [Select Id,name,Status,Follow_Up_Status__c,Rejected_Reason__c,First_Status_Change__c,Callback_Time__c,Callback_Date__c from Lead limit 1]; 
        mapLead.put(lstLead.id,lstLead);   
        lstLead.Status = 'New';
        lstLead.Marketing_Lead_Type__c = 'COBROKE';
        lstLead.Follow_Up_Status__c='Sent Email';
        lstLead.Email = 'c.s12@gmail.com';
        lstLead.Rejected_Reason__c ='Test';
        lstLead.Callback_Date__c = '12/03/2018';
        lstLead.Callback_Time__c = '6:00 AM';
        update lstLead;
        
        lstLead.Status = 'Converted';
        update lstLead;
        mapNewLead.put(lstLead.id,lstLead);
        
        LeadTriggerHandlerClass LHC = new LeadTriggerHandlerClass();
        LeadTriggerhandler hand = new LeadTriggerhandler();
        //LHC.LeadHandlerAfter(mapLead,mapLead);
        
        //try{
        LeadTriggerhandler.Afterinsertupdate(mapLead,mapLead);
        LHC.LeadDuplicate(mapLead.values(),true);
        //}catch(exception e){}
    }
    
    public static testMethod void testPhonefieldsPopulation(){      
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        Collection_Users__c coluser = new Collection_Users__c();
        coluser.Name = 'batchintegration user';
        coluser.Id__c  = userinfo.getuserid();
        insert coluser;
        List<ContactMethod__c> updCMlist = new List<ContactMethod__c>();
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','9988776655',true,true,'Business Phone');
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');       
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342341234',true,true,'Business Mobile');
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342343424',true,true,'Personal Phone');
        ContactMethod__c contactMethodRecord8 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342462334',true,true,'Business Phone');
        ContactMethod__c contactMethodRecord9 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342539234',true,true,'Personal Mobile');
        
        contactMethodRecord7.Phone_Extension__c = '4321';
        contactMethodRecord8.Phone_Extension__c = '4121';
        updCMlist.add(contactMethodRecord7);
        updCMlist.add(contactMethodRecord8);       
        update updCMlist;
        
        Lead Led11 = new Lead();
        Led11.LastName = 'Mr';
        Led11.FirstName = 'Test';
        Led11.Status = 'New1';
        Led11.Company = 'Test1';
        Led11.Account__c = acc.id;
        Led11.Contact__c = cont.id;
        Led11.Email = 'c.s12@gmail.com';
        Led11.Marketing_Lead_Type__c = 'Organic Leads';
        Led11.Recent_Campaign__c = 'Test2';
        Led11.Recent_Campaign_Id__c = '1234';
        Led11.RDC_Contact_Type__c = '';        
        try{
            insert Led11;  
        }catch(Exception Ex){
            system.debug(' *** failed to create lead *** '+ex);
        }
    }
}