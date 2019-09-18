@isTest
Public class DocuSignAgreementClass_Test{
    static testMethod void DocuSignAgreementClass_Test(){
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact;
     //Inserting Wait list  
   List<Waitlist__c> wApps = new List<Waitlist__c>(); 
   Set<Id> Wids = new Set<Id>();
   Map<id,Waitlist__c> WAMap = new Map<id,Waitlist__c>();           
  Waitlist__c wldata = new Waitlist__c();
    wldata.Account__c = testAccount.id;
    wldata.Status__c = 'Created';
    wldata.Pre_Auth_Contact__c = testContact.Id;
    wldata.Pre_Auth_Email__c = testContact.Email;
    wApps.add(wldata);
    Insert wApps;     
 Wids.add(wldata.Id);
 WAMap.put(wldata.Id , wldata);
 
 DocuSignAgreementClass cs = new DocuSignAgreementClass();
 cs.AgreementMethod(wApps,Wids,WAMap);
 }
}