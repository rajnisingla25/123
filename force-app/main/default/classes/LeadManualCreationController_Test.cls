//Name        : LeadManualCreationController_Test
//Description : Test class for LeadManualCreationController.
//Frequencey  : Every Day
//Author      : Pallavi Tammana

@isTest(SeeAllData = False)
private class LeadManualCreationController_Test{
    static testMethod void method1(){
    
        Set<Id> setAccId = new Set<Id>();
        List<Account> lstAccount = new List<Account>(); 
        List<Contact> lstContact = new List<Contact>();
        List<Account_Relationship__c> lstAR = new List<Account_Relationship__c>();
         
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;
        Switch_LeadTrigger__c arc1 = new Switch_LeadTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc1; 
              
        Account theAccount1 = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount1.Primary_Email__c = 'c.s1@gmail.com';  
        //insert theAccount1;
        lstAccount.add(theAccount1);                
                      
        Account Acc2 = new Account();
        Acc2.name='XYZ';
        Acc2.Phone = '(860) 347-0333';
        Acc2.Preferred_Phone__c = 'Work';
        Acc2.BillingStreet = 'Am Tierpark 16';
        Acc2.BillingCity = 'Cologne';
        Acc2.BillingPostalCode = '54321';
        Acc2.BillingState = 'Nordrhein-Westfalen';
        Acc2.BillingCountry = 'Germany';
        Acc2.Email_Address__c = 'c.s2@gmail.com';
        Acc2.Home_Phone__c= '(847) 915-8382';
        Acc2.Work_Phone__c = '(847) 915-8382';
        Acc2.Mobile1__c = '(847) 915-8382';
        Acc2.Mobile2_Other__c = '(847) 915-8382';
        Acc2.party_id__c = '206084042';
        Acc2.Type = 'Realtor Office';
        Acc2.Account_Sub_Type__c='Prospect';
        Acc2.Auto_Renewal__c = True;
        Acc2.Territories__c = 'test';
        lstAccount.add(Acc2);
        insert lstAccount;
        setAccId.add(theAccount1.Id);
        
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount1.Id,true,false);
        testContact.Email = 'c.s1@gmail.com';
        lstContact.add(testContact);
        //insert testContact;
        
        Contact testContact1 = TestDataFactory.createContact('Test Contact','TestL',Acc2.Id,true,false);
        //testContact1.Email = 'c.s2@gmail.com';
        testContact1.Phone = '(860) 347-0333';
        lstContact.add(testContact1);
        insert lstContact;
        
        Account_Relationship__c ar1 = new Account_Relationship__c();
        ar1.Contact_to__c = testContact.Id;
        ar1.Billing_Contact__c = true;
        ar1.Zuora_Bill_to_Contact_ID__c = testContact.Id;
        ar1.Zuora_Ship_to_Contact_ID__c = testContact.Id;
        ar1.Relationship_Type__c = 'Contact';
        ar1.Active__c = true;
        ar1.Parent_Account__c = theAccount1.Id;
        ar1.Contact_Role__c = 'Primary Contact';
        ar1.Is_Parent_Primary__c = True;
        lstAR.add(ar1);
        //insert ar;
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact1.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = testContact1.Id;
        ar.Zuora_Ship_to_Contact_ID__c = testContact1.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = Acc2.Id;
        ar.Contact_Role__c = 'Primary Contact';
        ar.Is_Parent_Primary__c = True;
        lstAR.add(ar);
        insert lstAR;
         
        Lead theLead = TestDataFactory.CreateLead('Test','Test','New',theAccount1.Id,null,'Test',false); 
        theLead.Ignore_Owner_Assignment__c = 'No';
        theLead.Status = 'New';
        theLead.Email = 'c.s1@gmail.com';
        theLead.Marketing_Lead_Type__c = 'Organic Leads';        
        theLead.Callback_Time__c = '6:00 AM';
        theLead.Callback_Date__c = '10/10/2016';
        insert theLead;
        
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Testing';
        LedB1.Status = 'New';
        LedB1.Company = 'Testing';
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = 'Test';
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        LedB1.Account__c = theAccount1.id;
        LedB1.Callback_Time__c = '6:00 AM';
        LedB1.Callback_Date__c = '10/10/2016';
        LedB1.Business_Unit__c = 'Realtor.com';
        LedB1.Lead_origin__c = 'Email';
        LedB1.Product_Type__c = 'COBROKE';
        
        Lead LedB = new Lead();
        LedB.LastName = 'Mr';
        LedB.FirstName = 'Testing';
        LedB.Status = 'New';
        LedB.Company = 'Testing';
        LedB.Phone = '(860) 347-0335';
        LedB.Email = 'c.s3@gmail.com';
        LedB.Marketing_Lead_Type__c = 'Organic Leads';
        LedB.Recent_Campaign__c = 'Test';
        LedB.RDC_Contact_Type__c = 'Single Agent';
        LedB.Account__c = Acc2.id;
        LedB.Callback_Time__c = '6:00 AM';
        LedB.Callback_Date__c = '10/10/2016';
        LedB.Business_Unit__c = 'Realtor.com';
        LedB.Lead_origin__c = 'Email';
        LedB.Product_Type__c = 'COBROKE';
        
        Test.startTest();
        
       
        PageReference pageRef = Page.LeadManualCreation;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('FirstName', 'TestLead');
        pageRef.getParameters().put('LastName', 'LeadTesting');
        pageRef.getParameters().put('Email', 'c.s1@gmail.com');
        pageRef.getParameters().put('Phone', '(860) 347-0333');
        pageRef.getParameters().put('AccountId', theAccount1.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(LedB1);
        LeadManualCreationController testAccPlan = new LeadManualCreationController(sc);
        /*testAccPlan.FirstName = 'TestLead';
        testAccPlan.LastName = 'LeadTest';
        testAccPlan.Email = 'c.s1@gmail.com';  
        testAccPlan.Phone = '(860) 347-0333';
        testAccPlan.AccId = theAccount1.id;*/
        
        testAccPlan.save();
        testAccPlan.cancel();
        
        PageReference pageRef1 = Page.LeadManualCreation;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('FirstName', 'TestLead');
        pageRef1.getParameters().put('LastName', 'LeadTesting');
        pageRef1.getParameters().put('Email', 'c.s2@gmail.com');
        pageRef1.getParameters().put('Phone', '(860) 347-0333');
        pageRef1.getParameters().put('AccountId', Acc2.Id);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(LedB);
        LeadManualCreationController testAccPlan1 = new LeadManualCreationController(sc1);
        /*testAccPlan1.FirstName = 'TestLead';
        testAccPlan1.LastName = 'LeadTest';
        testAccPlan1.Email = 'c.s2@gmail.com';  
        testAccPlan1.Phone = '(860) 347-0333';
        testAccPlan1.AccId = Acc2.id;*/
        
        testAccPlan1.save();
        testAccPlan1.cancel();
        
        PageReference pageRef11 = Page.LeadManualCreation;
        Test.setCurrentPage(pageRef11);
        pageRef11.getParameters().put('FirstName', 'TestLead');
        pageRef11.getParameters().put('LastName', 'LeadTesting');
        pageRef11.getParameters().put('Email', 'c.s3@gmail.com');
        pageRef11.getParameters().put('Phone', '(860) 347-0333');
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(LedB);
        LeadManualCreationController testAccPlan2 = new LeadManualCreationController(sc2);
        testAccPlan2.FirstName = 'Testing';
        testAccPlan2.LastName = 'LeadTesting';
        testAccPlan2.Email = 'c.s3@gmail.com';
        testAccPlan2.Phone = '4446764455';
        //testAccPlan2.save();
        Test.stopTest();
    }
}