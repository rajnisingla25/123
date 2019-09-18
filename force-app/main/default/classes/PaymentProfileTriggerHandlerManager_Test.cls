//Name        : PaymentProfileTriggerHandlerManager_Test
//Description : Test class for PaymentProfileTriggerHandlerManager
//Frequencey  : Every Insert and Update
//Author      : Pallavi Tammana
//History     : CRM-3185: populate Payment Method Id on Payment profile.

@isTest(SeeAllData = False)
private class PaymentProfileTriggerHandlerManager_Test {

    private static testMethod void PaymentProfileTest() {
    
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        String zID = '2c92c0f94c750685014c78c1967e660a';
        String zID1 = '2c92c0f94c750685014c78c1967e661b';
        List<PaymentProfiles__c> PProfileList = new List<PaymentProfiles__c>();
        Map<id,PaymentProfiles__c> PProfileMap =new Map<id,PaymentProfiles__c>();
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
    
        Zuora__PaymentMethod__c Pmethod = new Zuora__PaymentMethod__c();
        Pmethod.Name = 'Test';
        Pmethod.Zuora__BillingAccount__c = cAccount.id;
        Pmethod.Zuora__Type__c = 'Electronic';       
        Pmethod.Zuora__External_Id__c = zID;
        insert Pmethod;
        
        Zuora__PaymentMethod__c Pmethod1 = new Zuora__PaymentMethod__c();
        Pmethod1.Name = 'Test1';
        Pmethod1.Zuora__BillingAccount__c = cAccount.id;
        Pmethod1.Zuora__Type__c = 'Electronic'; 
        Pmethod1.Zuora__External_Id__c = zID1;       
        insert Pmethod1;
        
        Test.startTest();
        
        PaymentProfiles__c Pprofile = new PaymentProfiles__c();
        Pprofile.Account__c = Acc.id;
        Pprofile.PaymentMethodId__c = zID;
        PProfileList.add(Pprofile);
        insert Pprofile;
        PProfileMap.put(Pprofile.Id, Pprofile);
        
        PaymentProfileTriggerHandler PPTrHdr= new PaymentProfileTriggerHandler();
        PPTrHdr.BeforeInsertUpdate(PProfileList,null,true);
        
        PaymentProfileTriggerHandlerManager PPTrHdrMgr = new PaymentProfileTriggerHandlerManager();
        PPTrHdrMgr.UpdatePaymentMethod(PProfileList,null,true);
        
        Pprofile.Payment_Method__c = null;
        Pprofile.PaymentMethodId__c = zID1;
        update Pprofile;
        
        PPTrHdr= new PaymentProfileTriggerHandler();
        PPTrHdr.BeforeInsertUpdate(PProfileList,PProfileMap,false);
        PPTrHdrMgr = new PaymentProfileTriggerHandlerManager();
        PPTrHdrMgr.UpdatePaymentMethod(PProfileList,PProfileMap,false);
        
        Test.stopTest();

    }

}