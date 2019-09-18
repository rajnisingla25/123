@isTest
public class ContactMethodViewCTRLTest {
    
    private static testMethod void testContactMethodView() {
        // Inserting Custom Setting Data.
        CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
            Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
        );
        insert customSettingData;
        //Inserting Customsetting
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Contact theContact = null;
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        insert acc;
        List<Contact> theTestContacts = new List<Contact>();
        
        theContact = TestDataFactory.createContact('The Test1', 'Contact 1', null, true, false);
        theContact.Phone = '9876543210';
        theContact.Email = 'hsingh@appirio.com';
        theContact.Type__c = 'Agent';
        theContact.AccountId = acc.id;
        theContact.Contact_Party_ID__c = '28993480';
        theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;        
        insert theContact;
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(theContact.Id,'Social','www.move-inc.com',true,true,'HOMEPAGE');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(theContact.Id,'Phone','6342341234',true,true,'BUSINESS_MOBILE'); 
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(theContact.Id,'Email','test@test.com',true,true,'BUSINESS_EMAIL');
        
        
        Contact theContact1 = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact1.Phone = '9876543211';
        theContact1.Email = 'hsingh@appirio.com';
        theContact1.Type__c = 'Agent';
        theContact1.AccountId = acc.id;
        theContact1.Contact_Party_ID__c = '28993489';
        theContact1.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;        
        insert theContact1;
        
        ContactMethod__c contactMethodRecord12 =  TestDataFactory.createContactMethod(theContact1.Id,'Social','www.google.com',true,true,'HOMEPAGE');
        ContactMethod__c contactMethodRecord62 =  TestDataFactory.createContactMethod(theContact1.Id,'Phone','6342341432',true,true,'BUSINESS_MOBILE'); 
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(theContact1.Id,'Email','test12@test.com',true,true,'BUSINESS_EMAIL');
        
        Test.startTest();      
        PageReference pgr=page.ContactMethodView;
        pgr.getParameters().put('id',theContact.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(theContact);
        ContactMethodViewCTRL controller = new ContactMethodViewCTRL(sc);
        controller.viewTable = true;
        controller.buttonName = 'show OptIns';
        controller.viewTable = false;
        controller.showHideTable();
        pagereference p = controller.saveRecords();
        p = controller.cancelAll();
        controller = new ContactMethodViewCTRL(sc);
        contactMethodRecord.Type_Purpose__c = 'Personal Email'; 
        update contactMethodRecord;
        controller.viewTable = false;
        controller.buttonName = 'Hide OptIns';
        
        p = controller.saveRecords();
        controller.setRefresh(true);
        
        
        PageReference pgr1=page.ContactMethodView;
        pgr1.getParameters().put('id',theContact.id);
        Test.SetCurrentPage(pgr1);
        ApexPages.StandardController sc1 = new ApexPages.standardController(theContact);
        ContactMethodViewCTRL controller1 = new ContactMethodViewCTRL(sc1);
        controller1.viewTable = true;
        controller1.buttonName = 'show OptIns';
        controller1.viewTable = true;
        controller1.showHideTable();
        
    } 
    
     private static testMethod void testContactMethodView1() {
         // Inserting Custom Setting Data.
         CDH_Webservices_Endpoints__c customSettingData = new CDH_Webservices_Endpoints__c(
             Contact_Match_Endpoint__c = 'http://206.131.186.15:80/soa-infra/services/CST/MatchContactCDH/matchcontactcdhservice_client_ep?WSDL'
         );
         insert customSettingData;
         //Inserting Customsetting
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg;
         
         Contact theContact = null;
         Account acc = TestDataFactory.createAccount('TestAcc',null,false);
         acc.Type='Agent';
         insert acc;
         List<Contact> theTestContacts = new List<Contact>();
         
         theContact = TestDataFactory.createContact('The Test1', 'Contact 1', null, true, false);
         theContact.Phone = '9876543210';
         theContact.Email = 'hsingh@appirio.com';
         theContact.Type__c = 'Agent';
         theContact.AccountId = acc.id;
         theContact.Contact_Party_ID__c = '28993480';
         theContact.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;        
         insert theContact;
         
         Contact theContact1 = TestDataFactory.createContact('The Test11', 'Contact 11', null, true, false);
         theContact1.Phone = '9876543210';
         theContact1.Email = 'hsingh@appirio.com';
         theContact1.Type__c = 'Agent';
         theContact1.AccountId = acc.id;
         theContact1.Contact_Party_ID__c = '28993481';
         theContact1.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;        
         insert theContact1;
         ContactMethod__c contactMethodRecord12 =  TestDataFactory.createContactMethod(theContact.Id,'Phone','7875645612',true,false,'BUSINESS_FAX');
         ContactMethod__c contactMethodRecord13 =  TestDataFactory.createContactMethod(theContact1.Id,'Phone','7875667612',true,true,'BUSINESS_MOBILE');
         ContactMethod__c contactMethodRecord14 =  TestDataFactory.createContactMethod(theContact1.Id,'Social','www.google.com',true,false,'HOMEPAGE');
         ContactMethod__c contactMethodRecord15 =  TestDataFactory.createContactMethod(theContact1.Id,'Phone','7875645612',true,false,'BUSINESS_FAX');

         
         Test.startTest();      
         PageReference pgr=page.ContactMethodView;
         pgr.getParameters().put('id',theContact.id);
         Test.SetCurrentPage(pgr);
         ApexPages.StandardController sc = new ApexPages.standardController(theContact);
         ContactMethodViewCTRL controller = new ContactMethodViewCTRL(sc);
         controller.viewTable = true;
         controller.buttonName = 'show OptIns';
         controller.viewTable = false;
         controller.showHideTable();
         pagereference p = controller.saveRecords();
         p = controller.cancelAll();
         
         pgr.getParameters().put('id',theContact1.id);
         controller = new ContactMethodViewCTRL(sc);
         contactMethodRecord15.Primary_To_Contact__c = true; 
         contactMethodRecord13.Phone_Extension__c = '321';
         contactMethodRecord14.value__c = 'www.yahoo.com';
          
   
         controller.viewTable = false;
         controller.buttonName = 'Hide OptIns';
         
         p = controller.saveRecords();
         controller.setRefresh(true); 

      } 
}