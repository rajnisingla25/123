@isTest(Seealldata = true)
private class NotesTrigger_Test{ 
        public static testMethod void main1(){
     /*//Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
       insert Dtrg;  */ 
  Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
    newAccount.Primary_Email__c = 'theAcc@move.com';
    newAccount.party_id__c = '206084041';
    newAccount.Billing_Preference__c = 'Invoice-CC';        
    insert newAccount;
    
    Note notes = [Select id from note limit 1];
    try{
    delete notes;
    }catch(Exception e){}
    }
  }