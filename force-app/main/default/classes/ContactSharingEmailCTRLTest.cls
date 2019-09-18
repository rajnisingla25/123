@isTest
public class ContactSharingEmailCTRLTest {

    private static testMethod void testEmailSharing() {
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
        theTestContacts.add(theContact);
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(theContact.Id,'Social','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(theContact.Id,'Phone','6342341234',true,true,'Business Mobile'); 
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(theContact.Id,'Email','test@test.com',true,true,'Business Email');
    
        Contact theContact1 = TestDataFactory.createContact('The Test', 'Contact 2', null, true, false);
        theContact1.Phone = '9876543211';
        theContact1.Email = 'hsingh@appirio.com';
        theContact1.Type__c = 'Agent';
        theContact1.AccountId = acc.id;
        theContact1.Contact_Party_ID__c = '28993489';
        theContact1.RecordtypeId = [Select ID,Name,sObjectType from RecordType where sObjectType='Contact' and Name = 'Standard'].Id;
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(theContact1.Id,'Email','test@test.com',true,true,'Business Email');

        insert theContact1;
        
        Test.startTest();      
        PageReference pgr=page.ContactSharingEmail;
        pgr.getParameters().put('id',theContact.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(theContact);
        ContactSharingEmailCTRL controller = new ContactSharingEmailCTRL(sc);
        pagereference p = controller.back();
        Test.stopTest();        
        
    } 
}