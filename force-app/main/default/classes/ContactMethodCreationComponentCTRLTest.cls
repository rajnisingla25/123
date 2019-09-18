@isTest
public class ContactMethodCreationComponentCTRLTest {
    private static testMethod void testContactCMView() {
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
        
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq1@move.com',false,false,'Personal Email');
        PageReference pf = Page.ContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',con.Id); 
        ContactMethodCreationComponentCTRL controller = new ContactMethodCreationComponentCTRL();
        controller.cancelNewCM();
        controller.addCM();
        controller.saveNewCM(); 
        controller.AddRow();

        ContactMethod__c cm1 = new ContactMethod__c();
        cm1.Contact__c = con.Id;
        cm1.Type__c = 'Phone';
        //cm1.Phone__c = '';
        cm1.Active__c = true;
        cm1.Primary_To_Contact__c = false;
        cm1.Source_Type__c = 'Web';
        cm1.Type_Purpose__c = 'PERSONAL_PHONE';
        cm1.Primary_To_Account__c = True;
        insert cm1;
        pf = Page.ContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',con.Id); 
        controller = new ContactMethodCreationComponentCTRL();
        controller.AddRow();
        controller.addCM();
        controller.saveNewCM();
        ContactMethod__c contactMethodRecord8 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq@move.com',false,false,'Business Email');        
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq@move.com',false,false,'Business Email');
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032122',true,true,'Personal Mobile'); 
        ContactMethod__c contactMethodRecord7 =  TestDataFactory.createContactMethod(con.Id,'Social','www.google.com',true,true,'HomePage');         
        pf = Page.ContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',con.Id); 
        controller = new ContactMethodCreationComponentCTRL();
        controller.AddRow();
        controller.AddRow();
        controller.addCM();
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c];
        controller.saveNewCM();        
        controller.AddRow();
        controller = new ContactMethodCreationComponentCTRL();
        ContactMethod__c cm4 = new ContactMethod__c();
        cm4.Contact__c = con.Id;
        cm4.Type__c = 'Phone';
        cm4.Phone__c = '6183032131';
        cm4.Active__c = true;
        cm4.Primary_To_Contact__c = false;
        cm4.Source_Type__c = 'Web';
        cm4.Type_Purpose__c = 'PERSONAL_PHONE';
        cm4.Primary_To_Account__c = True;
        insert cm4;

        ApexPages.currentPage().getParameters().put('accountId',acc.Id);
        controller.accountId = acc.Id;
        controller.saveNewCM();
        controller = new ContactMethodCreationComponentCTRL();
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq4@move.com',true,true,'Personal Email');         
        contactMethodRecord5.Primary_To_Account__c = True;
        update contactMethodRecord5;
        controller.addCM();
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Phone_Extension__c FROM ContactMethod__c];
        controller.saveNewCM();
    
    }
    
    private static testMethod void testContactCMView1() {
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
        
        ContactMethod__c cm1 = new ContactMethod__c();
        cm1.Contact__c = con.Id;
        cm1.Type__c = 'Phone';
        cm1.Phone__c = '6183032131';
        cm1.Active__c = true;
        cm1.Primary_To_Contact__c = false;
        cm1.Source_Type__c = 'Web';
        cm1.Type_Purpose__c = 'PERSONAL_PHONE';
        cm1.Primary_To_Account__c = True;
        insert cm1;
        
        PageReference pf = Page.ContactMethodView;
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id',con.Id); 
        ContactMethodCreationComponentCTRL controller = new ContactMethodCreationComponentCTRL();
        controller.addCM();
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Phone_Extension__c FROM ContactMethod__c];
        controller.saveNewCM();
        controller.AddRow();
        
        cm1 = new ContactMethod__c();
        cm1.Contact__c = con.Id;
        cm1.Type__c = 'Email';
        cm1.Active__c = true;
        cm1.Primary_To_Contact__c = false;
        cm1.Source_Type__c = 'Web';
        cm1.Type_Purpose__c = 'PERSONAL_PHONE';
        cm1.Primary_To_Account__c = True;
        insert cm1;
        
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:cm1.Id];
        controller.saveNewCM();
        
        cm1 = new ContactMethod__c();
        cm1.Contact__c = con.Id;
        cm1.Type__c = 'Social';
        cm1.Active__c = true;
        cm1.Primary_To_Contact__c = false;
        cm1.Source_Type__c = 'Web';
        cm1.Type_Purpose__c = 'PERSONAL_PHONE';
        cm1.Primary_To_Account__c = True;
        insert cm1;
        
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:cm1.Id];
        controller.saveNewCM();
        
        cm1 = new ContactMethod__c();
        cm1.Contact__c = con.Id;
        cm1.Type__c = 'Phone';
        cm1.Active__c = true;
        cm1.Primary_To_Contact__c = false;
        cm1.Source_Type__c = 'Web';
        cm1.Phone__c = '1234567890';
        cm1.Primary_To_Account__c = True;
        insert cm1;
        
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:cm1.Id];
        controller.saveNewCM();
        
        ContactMethod__c contactMethodRecord11 =  TestDataFactory.createContactMethod(con.Id,'Phone','6183032122321',true,true,'Personal Mobile');              
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:contactMethodRecord11.Id];
        controller.saveNewCM();
        
        ApexPages.currentPage().getParameters().put('id',NULL); 
        ContactMethodCreationComponentCTRL controllerNew = new ContactMethodCreationComponentCTRL();
        
         ContactMethod__c contactMethodRecord12 =  TestDataFactory.createContactMethod(con.Id,'Phone','618303abc2122',true,true,'Personal Mobile');
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:contactMethodRecord12.Id];
        controller.saveNewCM();
        
        ApexPages.currentPage().getParameters().put('id',NULL); 
        ContactMethodCreationComponentCTRL controllerNew1 = new ContactMethodCreationComponentCTRL();
        
        ContactMethod__c contactMethodRecord13 =  TestDataFactory.createContactMethod(con.Id,'Phone','618303abc2122',true,true,'BUSINESS_FAX');
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:contactMethodRecord13.Id];
        controller.saveNewCM();
        
        ApexPages.currentPage().getParameters().put('id',NULL); 
        ContactMethodCreationComponentCTRL controllerNew2 = new ContactMethodCreationComponentCTRL();
        
        ContactMethod__c contactMethodRecord14 =  TestDataFactory.createContactMethod(con.Id,'Phone','618303abc2122',true,true,'BUSINESS_MOBILE');
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:contactMethodRecord14.Id];
        controller.saveNewCM();
        
        ApexPages.currentPage().getParameters().put('id',NULL); 
        
        ContactMethodCreationComponentCTRL controllerNew3 = new ContactMethodCreationComponentCTRL();
        ContactMethod__c contactMethodRecord15 =  TestDataFactory.createContactMethod(con.Id,'Web','www.google.com',true,true,'HOMEPAGE ');
        controller.LstContactMethod = [Select Id, Source_Type__c,Active__c, Contact__c, Contact__r.Id, 
                                            Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                            Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c 
                                            Where Id =:contactMethodRecord15.Id];
        controller.saveNewCM();
        
        ApexPages.currentPage().getParameters().put('id',NULL); 
        ContactMethodCreationComponentCTRL controllerNew4 = new ContactMethodCreationComponentCTRL();
    }
    
     private static testMethod void testContactCMView3() {
     
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
          insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
            insert coll;
        Switch_AccountRelationshipTrigger__c  art = new Switch_AccountRelationshipTrigger__c(Set_Overall_Trigger_Off__c = true);
          insert art;
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        
        Account acc = TestDataFactory.createAccount('TestAcc',null,false);
        acc.Type='Agent';
        acc.Account_Sub_Type__c = 'customer';
        acc.SyncButtonEnableDisable__c = False;
        acc.BrokerAffiliationChanged__c = False;
        acc.PrimaryEmail_CMId__c = '';
        acc.PrimaryPhone_CMId__c = '';
        acc.RecordTypeId = b2bRecordTypeId;
        insert acc;
        Contact con = TestDataFactory.createContactWithEmailAndPhone('testing123@gmail.com',null);
        Account_Relationship__c  relatiosnShiprec = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,con.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');                      
        Test.startTest();
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(con.Id,'Email','sanatclara-hq4@move.com',true,true,'Personal Email');         
       
        ContactMethodCreationComponentCTRL controller = new ContactMethodCreationComponentCTRL();
        ApexPages.currentPage().getParameters().put('accountId',acc.Id);
        controller.accountId = acc.Id;
        controller.saveNewCM();
        controller = new ContactMethodCreationComponentCTRL();
        controller.accountId = acc.Id;
        controller.conID = con.Id;
        controller.LstContactMethod.add(new ContactMethod__c(Contact__c = con.Id, Active__c = True, Source_Type__c = 'Web', 
                                                              Type__c = 'Phone', Phone__c = '6565656677',
                                                             Primary_To_Contact__c = True, Primary_To_Account__c = True, 
                                                              Type_Purpose__c = 'Personal Phone'));
        controller.saveNewCM();
        controller.LstContactMethod.add(new ContactMethod__c(Contact__c = con.Id, Active__c = True, Source_Type__c = 'Web', 
                                                              Type__c = 'Phone', Phone__c = '6565656688',
                                                             Primary_To_Contact__c = True, Primary_To_Account__c = True, 
                                                              Type_Purpose__c = 'PERSONAL_MOBILE'));       
         controller.saveNewCM();
         controller.LstContactMethod.add(new ContactMethod__c(Contact__c = con.Id, Active__c = True, Source_Type__c = 'Web', 
                                                              Type__c = 'Email', Email__c = 'sanatclara-hq66@move.com',
                                                             Primary_To_Contact__c = True, Primary_To_Account__c = True, 
                                                              Type_Purpose__c = 'Personal Email'));

         controller.saveNewCM();
         Test.stopTest();
     }

}