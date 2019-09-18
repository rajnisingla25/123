@isTest
public class WaitlistRenewalJob_Test {
    
    public static testMethod void test1(){
        //Creating test data
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Account newAccount = createAccount();
        insertWaitlistDetails(newAccount);
        Test.startTest();
        Database.executeBatch(new waitlistRenewalJob());
        Test.stopTest();
        }
    
    private static void insertWaitlistDetails(account newAccount){
        Contact c = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
        Product2 p =new Product2();
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w2 = new Waitlist__c();
        w2.Account__c= newAccount.id;
        w2.Pre_Auth_Contact__c= c.id;
        w2.Status__c='Created';
        w2.Pre_Auth_Email__c='aj@gmail.com';
        w2.Status__c = 'Active';
        w2.Pre_Auth_Type__c = 'New';
        w2.Submitted_Date__c = system.today();
        insert w2;
        
		Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Status__c = 'Renewed';
        w.Pre_Auth_Type__c = 'Renew';
        w.Submitted_Date__c = system.today();
        insert w;

        Waitlist_Item__c wt = new Waitlist_Item__c();
    	wt.Waitlist__c =w.id;
    	wt.Original_Max_Spend__c=2000;
    	wt.Status__c='Renewed';
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
        
        Waitlist_Item__c wt2 = new Waitlist_Item__c();
    	wt2.Waitlist__c =w2.id;
    	wt2.Original_Max_Spend__c=2000;
    	wt2.Status__c='Active';
    	wt2.Market__c='test';
    	wt2.Waitlist_ID__c='wwwww';
    	wt2.Lead_Routing__c='Fast';
    	wt2.Product__c=p.id;
    	wt2.Account__c= newAccount.id;
   		wt2.Market_Type__c='Postal Code';
    	wt2.Waitlist_Expiration_Date__c=date.today();
    	wt2.Product_Size__c='Full';
    	wt2.Wailist_Type__c = 'Pre-Auth';
    	wt2.Amendment_Status__c='Pending Pre-Auth Approval';
   		insert wt2;
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
    
}