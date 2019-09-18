@IsTest
public class ContactMethodTriggerTest
{ 
    static testmethod void testContactMethodEmailInsertion(){ 
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(c.Id,'Email','varisa@yahoo.com',true,true,'BUSINESS_EMAIL');
    }
    
    static testmethod void testContactMethodEmailInsertion1(){
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(c.Id,'Email','varisa@yahoo.com',true,false,'BUSINESS_EMAIL');
        
        System.assertEquals(getContactDetails(c.Id).Email,'varisa@gmail.com',' Assert failed while updating ContactMethod Email to contact ');       
    }
    
    static testmethod void testContactMethodPhoneInsertion(){
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone(null,'9879842313');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c.Id,'Phone','6183032131',true,true,'BUSINESS_PHONE'); 
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(c.Id,'Phone','6183078931',true,false,'PERSONAL_MOBILE'); 
        ContactMethod__c contactMethodRecord4 =  TestDataFactory.createContactMethod(c.Id,'Phone','6183023131',true,true,'BUSINESS_MOBILE'); 
    } 
    
    static testmethod void testContactMethodPhoneInsertion2(){
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone(null,'9879842313');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c.Id,'Phone','183032131',true,true,'BUSINESS_PHONE');
    } 
    
    static testmethod void testContactMethodPhoneInsertion3(){
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c = TestDataFactory.createContactWithEmailAndPhone(null,'9879842313');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c.Id,'Phone',' ',true,true,'BUSINESS_PHONE');
    } 
    
    static testmethod void testContactMethodInactivationforEmail(){  
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone('sanatclara-hq@realtor.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Email','sanatclara-hq@move.com',false,false,'BUSINESS_EMAIL');
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Active__c = true;
        contactMethodRecord.Primary_To_Contact__c = true;
        update contactMethodRecord;
        system.debug(' ************************ '+getContactDetails(cont.Id).Email); 
    }
    
    static testmethod void testContactMethodInactivationforPhone(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','3214568765',false,false,'BUSINESS_PHONE');
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Active__c = true;
        contactMethodRecord.Primary_To_Contact__c = true;
        contactMethodRecord.Source_Type__c = 'Google';
        contactMethodRecord.Sync_With_CDH__c = true;
        contactMethodRecord.Bounce_Back_Email__c = true;
        update contactMethodRecord;
        system.debug(' **** contactMethodRecord *** '+contactMethodRecord);
        system.debug(' **** contact Details *** '+getContactDetails(cont.Id));
    } 
    
    static testmethod void testContactMethodUpdateForAccountEmail(){
        TestDataFactory.createDisbaleTriggerCustomSetting(); 
        createCollectionUser();
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone('test-HQ@move.com',null);
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');              
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Email','test@test.com',true,true,'BUSINESS_EMAIL');
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Email__c = 'test-NCAEmployees@move.com';
        update contactMethodRecord;
        system.debug('cont.Id'+cont.Id);
    }
    
    static testmethod void testContactMethodUpdateForAccountEmail1(){
        TestDataFactory.createDisbaleTriggerCustomSetting(); 
        createCollectionUser();
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone('test-HQ@move.com',null);
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');              
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Email','test@test.com',true,true,'BUSINESS_EMAIL');
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Email__c = 'test-NCAEmployees@move.com';
        contactMethodRecord.Bounce_Back_Email__c = TRUE;
        contactMethodRecord.Sync_With_CDH__c = TRUE;
        contactMethodRecord.Source_Type__c = 'Online';
        contactMethodRecord.Type_Purpose__c = 'PERSONAL_EMAIL'; 
        update contactMethodRecord;
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Bounce_Back_Email__c = FALSE;
        contactMethodRecord.Sync_With_CDH__c = FALSE;
        contactMethodRecord.Source_Type__c = 'Online Form';
        contactMethodRecord.Type_Purpose__c = 'PERSONAL_EMAIL'; 
        update contactMethodRecord;
        system.debug('cont.Id'+cont.Id);
    } 
    
    static testmethod void testContactMethodUpdateForAccountPhone(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        createCollectionUser();
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','test@realtor.com','8008784166');             
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Phone','9988776655',true,true,'BUSINESS_PHONE');
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');       
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6342341234',true,true,'BUSINESS_MOBILE');              
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethodRecord.Phone__c = '5555555555';
        update contactMethodRecord;
    }  
    
    static testmethod void testContactMethodEmailPreferences(){ 
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c1 = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        Contact c2 = TestDataFactory.createContactWithEmailAndPhone('v.arisa@hotmail.com',null);
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c1.Id,'Email','varisa@yahoo.com',true,true,'BUSINESS_EMAIL');
        contactMethodRecord1.RDC_Event_OptIn__c = true;
        contactMethodRecord1.RDC_Promo_OptIn__c = true;
        contactMethodRecord1.TP_Event_OptIn__c = true;
        contactMethodRecord1.TP_Promo_OptIn__c = true;
        contactMethodRecord1.RDC_Info_OptIn__c = false;
        contactMethodRecord1.TP_Info_OptIn__c = false;
        update contactMethodRecord1;
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(c2.Id,'Email','varisa@yahoo.com',true,true,'BUSINESS_EMAIL');
        Test.starttest();    
        Contactmethod__c  cm1 = [select id,name,RDC_Event_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Promo_OptIn__c,RDC_Info_OptIn__c,TP_Info_OptIn__c from Contactmethod__c where id =: contactMethodRecord1.Id];
        Contactmethod__c  cm2 = [select id,name,RDC_Event_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Promo_OptIn__c,RDC_Info_OptIn__c,TP_Info_OptIn__c from Contactmethod__c where id =: contactMethodRecord2.Id];
        
        test.stoptest();    
    } 
    
    static testmethod void testContactMethodPhonePreferences(){ 
        TestDataFactory.createDisbaleTriggerCustomSetting();        
        Contact c1 = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        Contact c2 = TestDataFactory.createContactWithEmailAndPhone('v.arisa@hotmail.com',null);
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(c1.Id,'Phone','9988776655',true,true,'BUSINESS_PHONE');
        update contactMethodRecord1;
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(c2.Id,'Phone','9988776655',true,true,'BUSINESS_MOBILE');
        Test.startTest();    
        Contactmethod__c  cm1 = [select id,name,SMS_RDC_Promo_Pref__c from Contactmethod__c where id =: contactMethodRecord1.Id];
        Contactmethod__c  cm2 = [select id,name,SMS_RDC_Promo_Pref__c from Contactmethod__c where id =: contactMethodRecord2.Id];
        
        System.assertEquals(cm1.SMS_RDC_Promo_Pref__c,cm2.SMS_RDC_Promo_Pref__c,' Assert failed in updating TP_Event_OptIn__c preference ');    
        Test.stoptest();    
    } 
    
    static testmethod void testCMValidations(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        createCollectionUser();
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Social','www.move-inc.com',false,true,'HomePage');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Social',null,true,true,'HomePage');
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(cont.Id,'Email',null,true,true,'BUSINESS_EMAIL');
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(cont.Id,'Email',null,true,true,null);
        ContactMethod__c contactMethodRecord4 =  TestDataFactory.createContactMethod(cont.Id,'Phone',null,true,true,'BUSINESS_PHONE');
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(cont.Id,'Phone','+2342341234',true,true,'BUSINESS_PHONE');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(cont.Id,'Phone','1342341234',true,true,'BUSINESS_PHONE');              
    }
    
    static testmethod void testCMValidations1(){
        TestDataFactory.createDisbaleTriggerCustomSetting();    
        createCollectionUser();
        Contact cont = TestDataFactory.createContactWithEmailAndPhone(null,'9849812175');
        
        ContactMethod__c contactMethod = new ContactMethod__c();
        contactMethod.Contact__c = cont.Id;
        contactMethod.Type__c = 'Social';
        contactMethod.Value__c = 'www.move-inc.com';
        contactMethod.Active__c = TRUE;
        contactMethod.Primary_To_Contact__c = TRUE;
        contactMethod.Source_Type__c = 'Web';
        contactMethod.Type_Purpose__c = 'HomePage';
        insert contactMethod;
        
        CheckRecursiveTrigger.executeTriggerOnce = false;
        contactMethod.Type_Purpose__c = 'Facebook';
        try{
            update contactMethod; 
        }catch(Exception ex){
            system.debug(' exception *** '+ex); 
        }
    }
    
    static testmethod void testSOACallout(){
        TestDataFactory.createDisbaleTriggerCustomSetting(); 
        CDH_Webservices_Endpoints__c cdh = new CDH_Webservices_Endpoints__c(Name='Move Inc',Contact_Method_Sync_Endpoint__c = 'https://soa-external-app.entsys-dev.moveaws.com:7080/soa-infra/resources/CST/SyncContactMethodSFDC/SyncContactMethod',NumberOfContactMethodsPerRequest__c=5);
        insert cdh;
        Contact c = TestDataFactory.createContactWithEmailAndPhone('varisa@gmail.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(c.Id,'Email','varisa@yahoo.com',true,true,'BUSINESS_EMAIL');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerators());
    } 
    
    private static Contact getContactDetails(Id contactId){ 
        return [select Id,Email,Preferred_Phone__c,Phone from Contact where id =: contactId];
    }
    
    private static Account getAccountDetail(Id accountId){
        return [Select id,Email_Address__c,Website,Phone from Account where id=:accountId];       
    }
    
    private static void createCollectionUser(){
        Collection_Users__c coluser = new Collection_Users__c();
        coluser.Name = 'batchintegration user';
        coluser.Id__c  = userinfo.getuserid();
        insert coluser;
    } 
}