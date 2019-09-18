@IsTest
Public class Z_UpdatePaymentProfile_Test{
    Static TestMethod Void PayMentTesting(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
            newAccount.Primary_Email__c = 'theAcc@move.com';
            newAccount.party_id__c = '206084041';
            newAccount.Billing_Preference__c = 'Invoice-CC';        
        insert newAccount;
        
        Zuora__CustomerAccount__c zc = New Zuora__CustomerAccount__c();
        zc.Zuora__Account__c = newAccount.id;
        Insert zc;
        
        PaymentProfiles__c pp = New PaymentProfiles__c();
        pp.Account__c = newAccount.id;
            pp.ACH_ABA_Code__c = 'Test';
            pp.ACH_Account_Name__c = 'The Test Accountqq';
            pp.ACH_Account_Number_Mask__c = 'sk__c';
            pp.ACH_Account_Type__c = 'Broker';
            pp.ACH_Bank_Name__c = 'HDFC';
            pp.BillingAccountId__c = zc.id;
            pp.Payment_Method_Type__c = 'Ren';
            pp.ExpirationDate__c = '4'+ '/' + '100';
            pp.CardholderName__c = 'Testhoo';
            pp.MaskNumber__c = '804';
            pp.CreditCardType__c = 'Master';
            
        Insert pp;
        
        Test.startTest();
        List<id> tempMethodListIds = New List<id>();
        Zuora__PaymentMethod__c tempMethod = New Zuora__PaymentMethod__c();
            tempMethod.Zuora__External_Id__c = pp.id;
            tempMethod.Zuora__AchAbaCode__c = 'Testing1';
            tempMethod.Zuora__AchAccountName__c= 'The Test Account';
            tempMethod.Zuora__AchAccountNumberMask__c = 'Testssc';
            tempMethod.Zuora__AchAccountType__c= 'Broker';
            tempMethod.Zuora__AchBankName__c= 'ICICI';
            tempMethod.Zuora__CreditCardExpirationMonth__c = '3';
            tempMethod.Zuora__CreditCardExpirationYear__c= '100';
            tempMethod.Zuora__Type__c= 'Ren';           
            tempMethod.Zuora__CreditCardHolderName__c= 'Tester';
            tempMethod.Zuora__CreditCardMaskNumber__c= '433';  
            tempMethod.Zuora__BillingAccount__c =  zc.id;   
            tempMethod.Zuora__CreditCardType__c = 'VISA';  
        Insert tempMethod;
        tempMethodListIds.add(tempMethod.id);
        pp.PaymentMethodId__c = tempMethod.id;
        pp.ACH_ABA_Code__c = tempMethod.Zuora__AchAbaCode__c;
        pp.ACH_Account_Name__c = tempMethod.Zuora__AchAccountName__c;
        pp.ACH_Account_Number_Mask__c = tempMethod.Zuora__AchAccountNumberMask__c;
        pp.ACH_Account_Type__c = tempMethod.Zuora__AchAccountType__c;
        pp.ACH_Bank_Name__c = tempMethod.Zuora__AchBankName__c;
        pp.BillingAccountId__c = tempMethod.Zuora__BillingAccount__c;
        pp.Payment_Method_Type__c = tempMethod.Zuora__Type__c;
        pp.ExpirationDate__c = tempMethod.Zuora__CreditCardExpirationMonth__c + '/' + tempMethod.Zuora__CreditCardExpirationYear__c;
        pp.CardholderName__c = tempMethod.Zuora__CreditCardHolderName__c;
        pp.MaskNumber__c = tempMethod.Zuora__CreditCardMaskNumber__c;
        pp.CreditCardType__c = tempMethod.Zuora__CreditCardType__c;
        
        Update pp;
            
        Z_UpdatePaymentProfile Zup = New Z_UpdatePaymentProfile();
        Z_UpdatePaymentProfile.UpdatePaymentProfile(tempMethodListIds);
        //Zup.tempProfile =  pp;
        Test.stopTest(); 
    }
}