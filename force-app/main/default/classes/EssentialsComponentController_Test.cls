// Name: EssentialsComponentController_Test
// Description: Test Class for the Controller 'EssentialsComponentController'
// Author: Pallavi Tammana

@isTest
public class EssentialsComponentController_Test{
    
    static testmethod void EssentialsComponentController_Test() {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;
        
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        
        Contact testContact2;      
      
        testContact2 = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
                
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact2.Id;
        ar.RecordTypeId = contactRelationshipRecordTypeId;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = newAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        ar.Is_Parent_Primary__c = True;
        insert ar;
        
        test.starttest();
        EssentialsComponentController ecc = new EssentialsComponentController();
        ecc.setaccId(newAccount.Id);
        ecc.ContactName(newAccount.Id);
        test.stoptest();
    }
}