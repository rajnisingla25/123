@isTest
public  class BatchToProcessAutoRenewAccount_Test{
    static testMethod void BatchToProcessAutoRenewAccount_Test(){
        
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        // Id rectId= Schema.SObjectType.MLS__c.RecordTypeInfosByName.get('Broker').RecordTypeId;
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
        newAccount.MLS_Set_Id__c = 'A-CHIL-88662'; 
        newAccount.Customer_Care_Calls__c = 'Yes';
        newAccount.Sales_Calls__c = 'TRUE';
        newAccount.Status__c = 'Active';
        newAccount.Marketing_Emails__c = 'Test@test.com';
        newAccount.Agent_SLE__c = 'Yes';
        newAccount.Exclusion_Notes__c = 'This is a test'; 
              
        insert newAccount;
        BatchToProcessAutoRenewAccount bpa = new BatchToProcessAutoRenewAccount();
Database.executeBatch(bpa,7);
        }
        }