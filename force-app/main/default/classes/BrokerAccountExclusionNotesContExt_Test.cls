/***********************************************************************
 Class          : BrokerAccountExclusionNotesContExt_Test
 Author         : Ravindra Shekhawat
 Descritption   : Provide test coverage to BrokerAccountExclusionNotesContExtension.cls
 ************************************************************************/
@isTest
private class BrokerAccountExclusionNotesContExt_Test {

    static Account testOfficeAccount;
    static Account testAgentAccount;
    static Account testBrokerAccount;
    static testMethod void testExclusionNotesFunctionality() {
            createTestData();
            Test.startTest();
                ApexPages.currentPage().getParameters().put('id',testOfficeAccount.Id);
        
                ApexPages.StandardController stdController = new ApexPages.StandardController(testOfficeAccount);
                // BrokerAccountExclusionNotesContExtensionController
                BrokerAccountExclusionNotesContExtension extension = new BrokerAccountExclusionNotesContExtension(stdController);
                System.assert(extension.filterCriteria.contains(testBrokerAccount.Id));
            
                ApexPages.currentPage().getParameters().put('id',testAgentAccount.Id);
                stdController = new ApexPages.StandardController(testAgentAccount);
                extension = new BrokerAccountExclusionNotesContExtension(stdController);
                System.assert(extension.filterCriteria.contains(testBrokerAccount.Id));
                 //Inserting Customsetting for Account 
                DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
                insert Dtrg;
                Account testOtherAccount = TestDataFactory.createAccount('Non Office-Agent Account',null,false);
                testOtherAccount.Type='Other';
                testOtherAccount.Primary_Email__c='otherAccount@move.com';
                insert testOtherAccount;
                
                ApexPages.currentPage().getParameters().put('id',testOtherAccount.Id);
                stdController = new ApexPages.StandardController(testOtherAccount);
                extension = new BrokerAccountExclusionNotesContExtension(stdController);
                System.assert(extension.falseAccountType==true);
                    
     }
     
     private static void createTestData(){
             //Inserting Customsetting for Account 
                DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
                insert Dtrg;
            // Create Broker,Agent and Office Type of Account       
            List<Account> accountsToInsert = new List<Account>();
        
            testBrokerAccount = TestDataFactory.createAccount('Test Broker Account',null,false);
            testBrokerAccount.Exclusion_Notes__c = 'Test Exclusion Notes';
            testBrokerAccount.Sales_Calls__c = 'Yes';
            testBrokerAccount.Customer_Care_Calls__c = 'Yes';
            testBrokerAccount.Marketing_Emails__c = 'No';
            testBrokerAccount.Agent_SLE__c = 'Yes';
            testBrokerAccount.Type = 'Broker';
            testBrokerAccount.Primary_Email__c = 'testBroker@move.com';
            
            accountsToInsert.add(testBrokerAccount);
            
            // Create contact
            Contact testContact = TestDataFactory.createContact('Test Contact','#1',testBrokerAccount.Id,true,false);
            testContact.Email='testContact@move.com';
            testOfficeAccount = TestDataFactory.createAccount('Test Office Account',null,false);
            testOfficeAccount.Type='Realtor Office';
            testOfficeAccount.Primary_Email__c = 'testOffice@move.com';
            
            accountsToInsert.add(testOfficeAccount);
            
            testAgentAccount = TestDataFactory.createAccount('Test Agent Account',null,false);
            testAgentAccount.Type='Realtor Agent';
            testAgentAccount.Primary_Email__c = 'testAgent@move.com';
            
            accountsToInsert.add(testAgentAccount);
            insert accountsToInsert;
            
            // Create Relationship Objects
            List<Account_Relationship__c> relationships = new List<Account_Relationship__c>();
            relationships.add(TestDataFactory.createAccountRelationship(testBrokerAccount.Id,testOfficeAccount.Id,testContact.Id,'Billing Contact',true,false));
            relationships.add(TestDataFactory.createAccountRelationship(testOfficeAccount.Id,testAgentAccount.Id,testContact.Id,'Primary Contact',true,false));
            
            insert relationships;
            
     
     }

}