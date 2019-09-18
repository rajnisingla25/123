@isTest
private class AccountTree_Test{
    private static Account newAccount;
    
         public static testMethod void main1(){
        
        Test.startTest();  
            newAccount = new Account();
            newAccount.name = 'XYZ';
            newAccount.Phone = '4989388991291';
            newAccount.BillingStreet = 'Am Tierpark 16';
            newAccount.BillingCity = 'Cologne';
            newAccount.BillingPostalCode = '54321';
            newAccount.BillingState = 'Nordrhein-Westfalen';
            newAccount.BillingCountry = 'Germany';
            newAccount.Primary_Email__c = 'ra@gmail.com';
            newAccount.Home_Phone__c =  '4989388991';
            newAccount.Work_Phone__c =  '4989388991';
            newAccount.Mobile1__c =  '4989388991291';
            newAccount.Mobile2_Other__c =  '4989388991';
            newAccount.party_id__c = '';
        //    Database.insert(newAccount);
            
          
                     
            ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
            AccountTree obj1 = new AccountTree(sc);
       
            obj1.getFilterList();
             
         
            Test.stopTest();        
        }
}