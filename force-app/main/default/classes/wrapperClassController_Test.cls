@isTest(seeAllData =false)
public  class wrapperClassController_Test{
    public static testMethod void main(){          
       MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
     //Insert Custom Setting for Case Trigger
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert testSetting; 
    mtduc.CreateBrokerAccountSingle();
    Account newAccount = mtduc.newAccount;
    mtduc.CreateContactSingle(); 
    Contact myContact = mtduc.myContact;
    Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = newAccount.id;
        Led.Contact__c = myContact.id; 
        Insert Led;  
        
        Account_Relationship__c AR = new Account_Relationship__c();
        AR.Zuora_Bill_to_Contact_ID__c= 'Test';
        AR.Parent_Account__c = newAccount.id;
        AR.Contact_To__c = myContact.id;
       
        Insert AR;
        
        PageReference pgr = page.getAccountsOnContacts;
        pgr.getParameters().put('Id',Led.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(Led);
        wrapperClassController WC = new wrapperClassController(Sc);
        WC.Save();
        WC.GoLead();
        WC.CreateNewAccount();
        wrapperClassController.WrapperClass WC1 = new wrapperClassController.WrapperClass(AR);    
        
    }
    public static testMethod void main1(){          
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
        //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
     //Insert Custom Setting for Case Trigger
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
    insert testSetting; 
    mtduc.CreateBrokerAccountSingle();
    Account newAccount = mtduc.newAccount;
    mtduc.CreateContactSingle(); 
    Contact myContact = mtduc.myContact;
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = newAccount.id;
        Led.Contact__c = myContact.id; 
        Insert Led;
        Account_Relationship__c AR = new Account_Relationship__c();
       
        AR.Zuora_Bill_to_Contact_ID__c= 'Test';
        AR.Parent_Account__c = newAccount.id;
        AR.Contact_To__c = myContact.id;
                
        PageReference pgr = page.getAccountsOnContacts;
        pgr.getParameters().put('Id',Led.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(Led);
        wrapperClassController WC = new wrapperClassController(Sc);
        WC.Save();
        WC.GoLead();
        WC.CreateNewAccount();
        wrapperClassController.WrapperClass WC1 = new wrapperClassController.WrapperClass(AR);    
        
    }
}