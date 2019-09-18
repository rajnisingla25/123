@isTest
public class AccountCMViewCTRLTest {
    
    private static testMethod void testAccountCMView() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        	insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
            insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
          insert art;
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        Test.startTest();
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        acc.Account_Sub_Type__c = 'customer';
        acc.SyncButtonEnableDisable__c = False;
        acc.BrokerAffiliationChanged__c = False;
        acc.PrimaryEmail_CMId__c = '';
        acc.PrimaryPhone_CMId__c = '';
        acc.RecordTypeId = b2bRecordTypeId;
        insert acc;
        Contact con = TestDataFactory.createContactWithEmailAndPhone('testing12@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');                      
        Contact con1 = TestDataFactory.createContactWithEmailAndPhone('testing123@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec1 = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con1.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');                      
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032131',true,true,'BUSINESS_PHONE');         
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq1@move.com',true,true,'PERSONAL_EMAIL');
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(con1.Id,'Email','sanatclara-hq@move.com',true,true,'BUSINESS_EMAIL');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032122',true,true,'PERSONAL_MOBILE'); 
        ContactMethod__c contactMethodRecord4 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032126',true,false,'BUSINESS_MOBILE'); 
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032125',true,false,'PERSONAL_MOBILE'); 
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032125',true,false,'BUSINESS_FAX');
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(con.Id,'Social','6183032125',true,false,'BUSINESS_FAX');
        
        Contact con2 = TestDataFactory.createContactWithEmailAndPhone('test123@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec11 = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con1.Id,'Secondary Contact',true,'Contact Relationship',null,'Contact'); 
        ContactMethod__c contactMethodRecord41 =  TestDataFactory.createContactMethod(con2.Id,'Phone','6183032126',true,false,'BUSINESS_MOBILE'); 
        
        PageReference pf = Page.AccountContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.currentPage().getParameters().put('bIsnewRow','true');
        ApexPages.currentPage().getParameters().put('viewTable','true'); 
        AccountCMViewCTRL controller = new AccountCMViewCTRL(); 
        controller.save();
        controller.supress();
        controller.showall();
        controller.showHideTable();
        controller.saveRecords();
        controller.cancelAll();
        controller.addCM();
        controller.deleteRel();
        
        Test.stopTest();
    }
    
       private static testMethod void testAccountCMView1() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        	insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
            insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
          insert art;
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        Test.startTest();
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        acc.Account_Sub_Type__c = 'customer';
        acc.SyncButtonEnableDisable__c = False;
        acc.BrokerAffiliationChanged__c = False;
        acc.PrimaryEmail_CMId__c = '';
        acc.PrimaryPhone_CMId__c = '';
        acc.RecordTypeId = b2bRecordTypeId;
        insert acc;
        Contact con = TestDataFactory.createContactWithEmailAndPhone('testing12@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con.Id,'Primary Contact',false,'Contact Relationship',null,'Contact');                      
        Contact con1 = TestDataFactory.createContactWithEmailAndPhone('testing123@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec1 = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con1.Id,'Secondary Contact',true,'Contact Relationship',null,'Contact');                      
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032131',true,true,'BUSINESS_PHONE');         
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq1@move.com',true,true,'PERSONAL_EMAIL');
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(con1.Id,'Email','sanatclara-hq@move.com',true,true,'BUSINESS_EMAIL');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032122',true,true,'PERSONAL_MOBILE'); 
        ContactMethod__c contactMethodRecord4 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032126',true,false,'BUSINESS_MOBILE'); 
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032125',true,false,'PERSONAL_MOBILE'); 
        ContactMethod__c contactMethodRecord6 =  TestDataFactory.createContactMethod(con.Id,'Social','6183032125',true,true,'BUSINESS_FAX');
        
        Contact con2 = TestDataFactory.createContactWithEmailAndPhone('test123@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec11 = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con2.Id,'Secondary Contact',true,'Contact Relationship',null,'Contact'); 
        ContactMethod__c contactMethodRecord41 =  TestDataFactory.createContactMethod(con2.Id,'Phone','6183032126',true,false,'BUSINESS_MOBILE'); 
        
        PageReference pf = Page.AccountContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.currentPage().getParameters().put('bIsnewRow','true');
        ApexPages.currentPage().getParameters().put('viewTable','false'); 
        AccountCMViewCTRL controller = new AccountCMViewCTRL();
        controller.save();
        controller.supress();
        controller.showall();
        controller.showHideTable();
        controller.saveRecords();
        controller.cancelAll();
        controller.addCM();
        controller.deleteRel();
           controller.showPopup();
           controller.closePopup();
        
        Test.stopTest();
    }

}