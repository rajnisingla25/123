@isTest(seeAllData = false)
public class WaitlistExpireBatch_Test {
    public static testMethod void main() {
        Contact testContact2;    
            
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;         
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        
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
        
        testContact2 = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
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
        
        Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Fulfilled';
        wt.Market__c='test';
        wt.Waitlist_ID__c=w.Id;
        wt.Lead_Routing__c='Fast';
        wt.Product__c=p.id;
        wt.Account__c= newAccount.id;
        wt.Market_Type__c='Postal Code';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';    
        insert wt;
        
        Test.startTest();
        WaitlistExpireBatch bw = new WaitlistExpireBatch();
        ID batchprocessid = Database.executeBatch(bw);
        Test.stopTest();
    }
}