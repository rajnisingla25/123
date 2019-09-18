@isTest
private class TLcoachingCall_Test{
    static TestMethod void CreateTLCall()
    {           
        User u1 = [SELECT Id FROM User WHERE Alias='rpasa'AND IsActive = true];

        System.RunAs(u1){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'hsinqwqwwqegh@appirio.com';
        theTestAccount.ShippingState  = 'CA';
        theTestAccount.ShippingCountry  = 'USA';
        theTestAccount.Home_Phone__c = '7943693';
        theTestAccount.Advertiser_Email__c = 'test@test.com'; 
        theTestAccount.ShippingStreet = 'shipping test';
        theTestAccount.BillingStreet = 'billing test';
        theTestAccount.Name = 'test name';
        insert theTestAccount;
        
        
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theTestAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        //Switch_CaseTrigger__c testcasesetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c  = true);
        //insert testcasesetting; 
        

        TL_Follow_Up_Communication__c TLCall = new TL_Follow_Up_Communication__c();
        TLCall.OwnerId = userinfo.getUserId();
        TLCall.name = 'Weekly Coaching Call';
        TLCall.Account__c = theTestAccount.ID;
        TLCall.Status__c = 'Completed';
        TLCall.Call_Health__c = 'Good';
        TLCall.Call_Health_Summary__c = 'test';
        TLCall.Contact__c = testContact.ID;
        TLCall.Week_Number__c = 'Test Week';
        
        insert TLCall;
        
        
        update TLCall;
        
        
        CaseRecordTypes__c CT = new CaseRecordTypes__c();
        CT.Name='Retention';
        CT.Record_Type_Id__c = '012Z00000000tvX';
        insert CT;
        
  
         Case theCase1 = new Case();
         theCase1.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
         theCase1.Subject = 'Invalid Rights';
         theCase1.Status = 'New';
         theCase1.Origin = 'phone';
         theCase1.Type = 'Customer Service';
         theCase1.Description = 'Test Description';
         theCase1.Area__c = 'Access Issues';
         theCase1.AccountId = theTestAccount.ID;
         theCase1.ContactId = testContact.ID;
         theCase1.OwnerId = userinfo.getUserId();
         theCase1.TL_Coaching__c = TLCall.Id;
         insert theCase1;
         
         Case theCase2 = new Case();
         theCase2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
         theCase2.Subject = 'Invalid Rights';
         theCase2.Status = 'Open';
         theCase2.Origin = 'phone';
         theCase2.Type = 'Customer Service';
         theCase2.Description = 'Test Description';
         theCase2.Area__c = 'Access Issues';
         theCase2.AccountId = theTestAccount.ID;
         theCase2.ContactId = testContact.ID;
         theCase2.OwnerId = userinfo.getUserId();
         theCase2.TL_Coaching__c = TLCall.Id;
         insert theCase2;
         
         try {
         update TLCall;
         System.assert(false, 'exception expected');
         } catch (DmlException e) {
         String message = e.getMessage();
         System.assert(message.contains('You cannot Mark this as Complete. There are Open Cases under this'), 'message=' + message);
           }
        
    }
}
}