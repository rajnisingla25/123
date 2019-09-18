@isTest
public class BatchWaitlistPopulateState_Test {

public static testMethod void test1(){  
//creating test data
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Account newAccount = createAccount();
        createContact(newAccount);
        createAccountRelationship(newAccount);
        insertWaitlistDetails(newAccount);
        Test.startTest();
        BatchWaitlistPopulateState Capture = new BatchWaitlistPopulateState();
        ID batchprocessid = Database.executeBatch(Capture);
        Test.stopTest();
}
  
private static account createAccount(){
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Current_Monthly_Pre_Auth_Spend__c=12;
        newAccount.Total_MAX_Monthly_Pre_Auth_Spend__c=125;
        newAccount.Billing_Preference__c = 'Invoice-CC';  
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Type='MLS Account';
        newAccount.billingstate = 'CA';
        newAccount.Preferred_Phone__c = '1232334455';
        insert newAccount;
        return newAccount;
    }
    
   
    private static contact createContact(account newAccount){
        contact c = new contact();
        c.lastname = 'test';
        c.accountid = newAccount.id;
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email ='ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone= '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c='1234567890';
        insert c; 
        return c;
    }

    private static void createAccountRelationship(account newAccount){
        Contact testContact2 = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact2.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = newAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        insert ar;
    }

    

    private static void insertWaitlistDetails(account newAccount){
        Contact c = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
        Product2 p =new Product2();
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
         Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Status__c = 'Active';
        insert w;

        Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Active';
        wt.Market__c='test';
        wt.Waitlist_ID__c='wwwww';
        wt.Lead_Routing__c='Fast';
        wt.Product__c=p.id;
        wt.Account__c= newAccount.id;
        wt.Market_Type__c='Postal Code';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';
        wt.Wailist_Type__c = 'Pre-Auth';
        wt.Amendment_Status__c='Pending Pre-Auth Approval';
        insert wt;
    }

}