@isTest
public  class AccountHighlightsPanelService_Test{
    static testMethod void AccountHighlightsPanelService_Test(){
        
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        newAccount.OwnerId = UserInfo.getUserId();
        newAccount.Credit_Status__c = 'Current';
        newAccount.Total_CLC__c = 11;
        newAccount.Customer_Care_Calls__c = 'Yes';
        newAccount.Sales_Calls__c = 'TRUE';
        newAccount.Marketing_Emails__c = 'Test@test.com';
        newAccount.Agent_SLE__c = 'Yes';
        newAccount.Exclusion_Notes__c = 'This is a test'; 
              
        insert newAccount;
     
     ApexPages.StandardController ctlr = new ApexPages.StandardController(newAccount); 
         AccountHighlightsPanelServiceExtension Ext = new AccountHighlightsPanelServiceExtension(ctlr);
  }       
     static testMethod void AccountHighlightsPanelService_Test1(){
           //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
      Account newAccount1 = new Account();
        newAccount1.name='XYZ1';
        newAccount1.Phone = '+49-12345';
        newAccount1.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount1.BillingCity = 'HOPEWELL JUNCTION';
        newAccount1.BillingPostalCode = '12533';
        newAccount1.BillingState = 'NY';
        newAccount1.BillingCountry = 'USA';
        newAccount1.Primary_Email__c= 'ra@gmail.com';
        newAccount1.Home_Phone__c= '967622877';
        newAccount1.Work_Phone__c = '456789';
        newAccount1.Mobile1__c = '1234566';
        newAccount1.Mobile2_Other__c = '1245787';
        newAccount1.party_id__c = '206084041';
        newAccount1.OwnerId = UserInfo.getUserId();
        newAccount1.Type = 'Realtor Agent';    
        newAccount1.MLS_Set_Id__c = 'A-CHIL-88662'; 
        //newAccount1.Customer_Id__c = '1818121';                 
        insert newAccount1;    
        
      ApexPages.StandardController ctlr1 = new ApexPages.StandardController(newAccount1); 
         AccountHighlightsPanelServiceExtension Ext = new AccountHighlightsPanelServiceExtension(ctlr1);
        
    }    
}