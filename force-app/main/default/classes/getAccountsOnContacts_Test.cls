//
// (c) 2015 NTTDATA.
//
// Test Class Name: getAccountsOnContacts_Test
// For Apex Class: getAccountsOnContacts 

@isTest(seeAllData=false)
private class getAccountsOnContacts_Test{
    private static testMethod void getAccountsOnContacts_Test() {
        PointOfSalesInboundEmailHandler.SkipForPOSExecution = false;
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;    
        // Inserting Test Account.
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'hsingh@appirio.com';
        theTestAccount.Preferred_Phone__c = 'Home Phone';
        theTestAccount.Home_Phone__c = '9876543210';
        theTestAccount.Phone = '9876543210';
        insert theTestAccount;
        
        // Inserting Test Contact.
        Contact theContact = TestDataFactory.createContact('The Test', 'Contact', theTestAccount.Id, true, false);
        theContact.Email='hsingh@appirio.com';
        theContact.Preferred_Phone__c = 'Home Phone';
        theContact.HomePhone = '9876543210';
        insert theContact;
        
        //Inserting Test Lead
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = theTestAccount.id;
        Led.Contact__c = theContact.id; 
        Insert Led;
        
        //Inserting Account Relationship 
        Account_Relationship__c AR = new Account_Relationship__c();
        AR.Zuora_Bill_to_Contact_ID__c= 'Test';
        AR.Parent_Account__c = theTestAccount.id;
        AR.Contact_To__c = theContact.id;        
        Insert AR;
        
        PageReference pgr = page.getAccountsOnContacts;
        pgr.getParameters().put('id',Led.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(Led);
        getAccountsOnContacts IP = new getAccountsOnContacts(Sc);  
        IP.Led = Led.Id;
        IP.paramValue = AR.id; 
        IP.Ischecked = True; 
        IP.Save();    
        IP.CreateNewAccount();
        
        Task t = new  Task();
        t.OwnerId = userinfo.getUserId();
        t.ActivityDate =System.today();
        t.Subject= 'Subject';
        t.Priority='Normal';
        t.Status='Open ';
        t.Type='Email';
        t.Outcome__c='Spoke To / Emailed Info';
        t.WhatId=theTestAccount.id; 
        t.Actual_End__c =System.today();
        Insert t;
        
        t.Subject= 'Subject1';
        update t;
        
        delete t;
    }
}