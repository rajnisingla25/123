//
//
// Apex Test Class Name:AccountRelationshipTriggerHandlerManager_Test
// For Testing: AccountRelationshipTriggerHandlerManager
//
// 18th April 2016   Mohammad Imran Ali
//
@isTest
private class AccountRelationshipTriggerHndlrMngr_Test { 
   
    private static final Integer COUNTER = 3;
    static testMethod void AccountRelationshipTriggerHndlrMngr_Method() {
       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
    
        insert parentAccount;
        
        Account parentAccount2 = TestDataFactory.createAccount('Parent Account2', null, false);
        parentAccount2.Primary_Email__c = 'parentAcc2@move.com';
        parentAccount2.Type = 'Realtor Office';
        parentAccount2.Party_ID__c  = '12345';
        parentAccount2.Customer_Id__c  = '12345';
        parentAccount2.BillingPostalCode  = '12345';
        parentAccount2.BillingCity = 'newyork';
        parentAccount2.MLS_Set_Id__c  = '12345';    
            
        insert parentAccount2;


        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        childAccount.Type = 'Realtor Office';   
        insert childAccount; 
        
        Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        Account childAccount2 = TestDataFactory.createAccount('Child Account',null,false);
        childAccount2.Primary_Email__c = 'childacc2@move.com';    
        childAccount2.Type = 'Realtor Agent';
        insert childAccount2;
    
        Account childAccount3 = TestDataFactory.createAccount('Child Account',null,false);
        childAccount3.Primary_Email__c = 'childacc2@move.com';    
        childAccount3.Type = 'Realtor Office';
        insert childAccount3;
        
        Account childAccount4 = TestDataFactory.createAccount('Child Account',null,false);
        childAccount4.Primary_Email__c = 'childacc2@move.com';    
        childAccount4.Type = 'Realtor Agent';
        insert childAccount4;
        
        Contact theContact = new Contact(
                FirstName = 'firstName',
                LastName = 'lastName',
                AccountId = parentAccount2.id,
                Active__c = true,
                Type__c= 'Test');
                insert theContact;
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(theContact.Id,'Email','testing@yahoo.com',true,true,'Business Email');
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        List<Account_Relationship__c> toBeUpdated = new List<Account_Relationship__c>();
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;
        accountRelation.Billing_Contact__c =true;
        toBeInserted.add(accountRelation);
         
        Account_Relationship__c accountRelation2 = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, childAccount3.Id, null, null, true, false);
        accountRelation2.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation2.Active__c = true;
        accountRelation2.Billing_Contact__c =false;
        accountRelation2.Is_Parent_Primary__c = true;
        toBeInserted.add(accountRelation2); 
         
        Account_Relationship__c accountRelation3 = TestDataFactory.createAccountRelationship
                                                                (parentAccount2.Id, childAccount2.Id, theContact.Id, null, true, false);
        accountRelation3.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation3.Active__c = true;
        accountRelation3.Billing_Contact__c =true;
        accountRelation3.Is_Parent_Primary__c = false;
        accountRelation3.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation3);    
        insert toBeInserted;
        
        String st= String.valueOf(toBeInserted[0].Parent_Account__c) + '__' + String.valueOf(toBeInserted[0].Child_Account__c);
        Map<id,Account_Relationship__c> var =new Map<id,Account_Relationship__c>();
        Map<id,Account_Relationship__c> var1 =new Map<id,Account_Relationship__c>();
        var.put(toBeInserted[0].id, toBeInserted[0]);
        var1.put(toBeInserted[2].id, toBeInserted[2]);
        
        Map<string,List<Account_Relationship__c>> var2 =new Map<string,List<Account_Relationship__c>>();
        var2.put(st, toBeInserted);
        
        AccountRelationshipTriggerHandler.onAfterInsertUpdateUpdateForCDHUser(var1);
        
        Map<Id, List<Account_Relationship__c>> parentAccountMapping = new Map<Id, List<Account_Relationship__c>>();
        parentAccountMapping.put(parentAccount.Id,toBeInserted);
        /*
        Account_Relationship__c accountRelation4 = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, childAccount.Id, theContact.Id, null, true, false);
        accountRelation4.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation4.Active__c = true;
        accountRelation4.Is_Parent_Primary__c = true;
    
        //toBeInserted.add(accountRelation3);    
        insert accountRelation4;*/
    
        AccountRelationshipTriggerHandlerManager arthm=new AccountRelationshipTriggerHandlerManager();    
        arthm.validateBillingContactDeactivation(toBeInserted,var, true);
        arthm.validatePrimaryParentAccount(toBeInserted,var, true);
        arthm.validateAccountRelationshipRecords(toBeInserted,var, true);
        arthm.validateExistingAccountRelationshipTypeRecords(toBeInserted,var2,var, true); 
        arthm.validateExistingContactRelationshipTypeRecords(toBeInserted,var2,var, true);
        arthm.populateAccountParentBroker(toBeInserted,var, true);
        arthm.updateIsSentToCDH(toBeInserted,var, true);
        arthm.computeTotalAgentsAndTotalOffices(var,var, true);
        arthm.computeTotalAgentsAndTotalOffices(var1,var1, true);
        arthm.validateOfficeIsAssociteWithOneBroker(toBeInserted,var,true);
        /*id contactToId;
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
          Parent_Account__c = parentAccount.id,
          Child_Account__c = childAccount.id,
          Contact_To__c = contactToId,
          //Contact_Role__c = 'contactRole',
          RecordTypeID = contRelationShipRTID,
          Active__c = true,
        Contact_Role__c = 'Primary Contact');
        insert theAccountRelationship ;*/
        arthm.checkcontactUniquenes(toBeInserted,var, true);
        //arthm.CheckChildAccountAssetValidation(var,var, true);
        arthm.updateAccountforParentChild(toBeInserted);
        arthm.populateIsParentPrimary(var,var, true);
        arthm.setbillngcntctfalseinsert(var);
        arthm.setbillngcntctfalseupdate(var,var);
    
        Account_Relationship__c accountRelation5 = [Select Id, RecordTypeID, Parent_Account__c, Is_Parent_Primary__c, Child_Account_Type__c, Parent_Account_Type__c, RecordTypeDeveloperName__c 
            from Account_Relationship__c where Parent_Account__c =: parentAccount.Id limit 1];
        Account_Relationship__c accountRelation6 = [Select Id, RecordTypeID, Parent_Account__c, Is_Parent_Primary__c, Child_Account_Type__c, Parent_Account_Type__c, RecordTypeDeveloperName__c
            from Account_Relationship__c where Parent_Account__c =: parentAccount2.Id limit 1];
            
        List<Account_Relationship__c> toBeUpdated1 = new List<Account_Relationship__c>();
        List<Account_Relationship__c> toBeUpdated2 = new List<Account_Relationship__c>();
        accountRelation5.Child_Account__c = childAccount3.Id;
        accountRelation5.Parent_Account__c = parentAccount.Id;
        accountRelation5.Active__c = true;
        accountRelation5.Contact_Role__c = 'Primary Contact';
        accountRelation5.Billing_Contact__c =true;
        toBeUpdated.add(accountRelation5);
        toBeUpdated1.add(accountRelation5);
        
        accountRelation6.Child_Account__c = childAccount4.Id;
        accountRelation6.Parent_Account__c = parentAccount2.Id;
        accountRelation6.Active__c = false;
        accountRelation6.Is_Parent_Primary__c = true;
        accountRelation6.Billing_Contact__c =false;
        toBeUpdated.add(accountRelation6);
        toBeUpdated2.add(accountRelation6); 
        update toBeUpdated;
    
        map<id,Account_Relationship__c> var3 =new map<id,Account_Relationship__c>();
        arthm.updateIsSentToCDH(toBeUpdated, var, true);
        var3.put(toBeUpdated[1].id, toBeUpdated[1]);
        arthm.CheckChildAccountAssetValidation(var3, var1, false);
        arthm.computeTotalAgentsAndTotalOffices(var3, var1, false);
        arthm.populateAccountParentBroker(toBeUpdated2,var1, false);
        var3.clear(); 
        arthm.validatePrimaryParentAccount(toBeUpdated,var, true);
        st= String.valueOf(toBeUpdated[0].Parent_Account__c) + '__' + String.valueOf(toBeUpdated[0].Child_Account__c);
        var3.put(toBeUpdated[0].id, toBeUpdated[0]);
        var2.put(st, toBeUpdated);
        arthm.validateExistingAccountRelationshipTypeRecords(toBeUpdated1, var2, var, false);
        arthm.validateOfficeIsAssociteWithOneBroker(toBeUpdated1, var1, false);
        arthm.computeTotalAgentsAndTotalOffices(var3, var, false);
        arthm.setbillngcntctfalseupdate(var3,var);
        arthm.populateIsParentPrimary(var3,var, true);
        
        toBeUpdated.clear();
        accountRelation5.Child_Account__c = childAccount3.Id;
        accountRelation5.Parent_Account__c = parentAccount.Id;
        accountRelation5.Active__c = false;
        accountRelation5.Contact_Role__c = '';
        accountRelation5.Billing_Contact__c =false;
        toBeUpdated.add(accountRelation5);        
        update toBeUpdated;        
        arthm.validateBillingContactDeactivation(toBeUpdated,var, false);
		toBeUpdated.clear();
        accountRelation5.Active__c = true;
        toBeUpdated.add(accountRelation5);
        accountRelation6.Active__c = true;
        toBeUpdated.add(accountRelation6);
        update toBeUpdated;
    
    }
    static testMethod void AccountRelationshipTriggerHndlrMngr_Method2() {
       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
         Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        insert parentAccount;
    
        Account parentAccount2 = TestDataFactory.createAccount('Parent Account2', null, false);
        parentAccount2.Primary_Email__c = 'parentAcc2@move.com';
        parentAccount2.Type = 'Realtor Office';
        parentAccount2.Party_ID__c  = '12345';
        parentAccount2.Customer_Id__c  = '12345';
        parentAccount2.BillingPostalCode  = '12345';
        parentAccount2.BillingCity = 'newyork';
        parentAccount2.MLS_Set_Id__c  = '12345';        
        insert parentAccount2;


        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';   
        insert childAccount; 
    
        Account childAccount2 = TestDataFactory.createAccount('Child Account',null,false);
        childAccount2.Primary_Email__c = 'childacc2@move.com';    
        childAccount.Type = 'Realtor Office';
        
        insert childAccount2;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
        Parent_Account__c = parentAccount.id,
        Child_Account__c = childAccount.id,
        //Contact_To__c = contactToId,
        //Contact_Role__c = 'contactRole',
        //RecordTypeID = contRelationShipRTID,
        Active__c = true,     
        Billing_Contact__c = true);
        //Contact_Role__c = 'Primary Contact');
        // insert theAccountRelationship ;
  
    
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                          (parentAccount.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Billing_Contact__c =false;
        accountRelation.Is_Parent_Primary__c = true;  
        toBeInserted.add(accountRelation);  
        toBeInserted.add(theAccountRelationship);   
        insert toBeInserted;
 
         toBeInserted[0].Active__c =false;
         update toBeInserted;
    
        string st= String.valueOf(toBeInserted[0].Parent_Account__c) + '__' + String.valueOf(toBeInserted[0].Child_Account__c);
        map<id,Account_Relationship__c> var =new map<id,Account_Relationship__c>();
        var.put(toBeInserted[0].id, toBeInserted[0]);
        
        map<string,List<Account_Relationship__c>> var2 =new map<string,List<Account_Relationship__c>>();
        var2.put(st, toBeInserted);
        AccountRelationshipTriggerHandlerManager arthm=new AccountRelationshipTriggerHandlerManager();
        id contactToId;
        
        arthm.validateBillingContactDeactivation(toBeInserted,var, false);
        arthm.validatePrimaryParentAccount(toBeInserted,var, false);
        arthm.validateAccountRelationshipRecords(toBeInserted,var, false);
        arthm.validateExistingAccountRelationshipTypeRecords(toBeInserted,var2,var, true); 
        arthm.validateExistingContactRelationshipTypeRecords(toBeInserted,var2,var, true);
        arthm.populateAccountParentBroker(toBeInserted,var, false);
        arthm.updateIsSentToCDH(toBeInserted,var, true);
        arthm.computeTotalAgentsAndTotalOffices(var,var, false);
        arthm.checkcontactUniquenes(toBeInserted,var, false);
        arthm.CheckChildAccountAssetValidation(var,var, false);
        arthm.updateAccountforParentChild(toBeInserted);
        arthm.populateIsParentPrimary(var,var, false);
        arthm.setbillngcntctfalseinsert(var);
        arthm.setbillngcntctfalseupdate(var,var);
    
    }
 
  
    static testMethod void AccountRelationshipTriggerHndlrMngr_Method3() {
       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
         Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;

        // Inserting account records.
        Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        insert parentAccount;
        
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';
        insert childAccount; 
        Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
      
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
  
  
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (parentAccount.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        accountRelation.Is_Parent_Primary__c = true;
        toBeInserted.add(accountRelation); 
        
        Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
        parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
        insert parentAcc1;
        
        accountRelation = TestDataFactory.createAccountRelationship(
                                                                            parentAcc1.Id, childAccount.Id, null, null, true, false);
        accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
        toBeInserted.add(accountRelation); 
        
        List<Contact> contacts= new List<Contact>();
        //Create Contacts
        Contact testContact = TestDataFactory.createContact('TestContact','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContact@move.com';
        testContact.Type__c = 'Billing';
        contacts.add(testContact);
        //Create Contacts
        testContact = TestDataFactory.createContact('TestContactAct','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContacAct@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        testContact = TestDataFactory.createContact('TestContact1','Last1',parentAccount.id,true,false);
        testContact.Email = 'testContact1@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        insert contacts;
        for(contact con: contacts){
            ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(con.Id,'Email','testing@yahoo.com',true,false,'Business Email');    
        }
    
        // Create Relationship records for Contact Relationhsip
        accountRelation = TestDataFactory.createAccountRelationship(
                            parentAcc1.Id, null, contacts.get(0).Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Billing_Contact__c = true;
        toBeInserted.add(accountRelation); 
    
        
        accountRelation = TestDataFactory.createAccountRelationship(
                            parentAccount.Id, null, contacts.get(2).Id, null, true, false);
        accountRelation.Billing_Contact__c = false;
        accountRelation.Is_Parent_Primary__c = true;
        
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        toBeInserted.add(accountRelation);
        
    
        //Test Case 1
        Test.startTest();
        Integer totalInsertsFailed = 0;
        Database.SaveResult[] insertResult = Database.insert(toBeInserted,false);
        for(Database.SaveResult sr : insertResult) {
            if(!sr.isSuccess()) {
                totalInsertsFailed++;
            }
            System.debug('Save Result is : '+sr);
        }
        String st= String.valueOf(toBeInserted[0].Parent_Account__c) + '__' + String.valueOf(toBeInserted[0].Child_Account__c);
        map<id,Account_Relationship__c> var =new map<id,Account_Relationship__c>();
        map<id,Account_Relationship__c> var1 =new map<id,Account_Relationship__c>();        
        var.put(toBeInserted[0].id, toBeInserted[0]);
        var1.put(toBeInserted[1].id, toBeInserted[1]);
        //System.assertEquals(totalInsertsFailed,1);   
        toBeInserted = [SELECT Id, Active__c, RecordTypeId, Parent_Account__c, Child_Account__c, Contact_To__c FROM Account_Relationship__c WHERE Id in: toBeInserted];
        //toBeInserted.get(0).Active__c = false;
          //toBeInserted.get(1).Billing_Contact__c = true;
        update toBeInserted;
        
        Map<string,List<Account_Relationship__c>> var2 =new Map<string,List<Account_Relationship__c>>();
        Map<id,Account_Relationship__c> var3 = new Map<id,Account_Relationship__c>();
        var2.put(st, toBeInserted);
        
        AccountRelationshipTriggerHandlerManager arthm = new AccountRelationshipTriggerHandlerManager();
        arthm.validateAccountRelationshipRecords(toBeInserted, var, true);
        arthm.validateExistingContactRelationshipTypeRecords(toBeInserted, var2, var, true);
        //var3.put(toBeInserted[1].Id, toBeInserted[1]);
        arthm.setbillngcntctfalseupdate(var3, var1);
        Test.stopTest();
    }
   
    static testMethod void AccountRelationshipTriggerHndlrMngr_Method4() {
       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
         Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;

        // Inserting account records.
        Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        insert parentAccount;
        
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';
        insert childAccount; 

        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
      
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        
        List<Contact> contacts= new List<Contact>();
        //Create Contacts
        Contact testContact = TestDataFactory.createContact('TestContact','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContact@move.com';
        testContact.Type__c = 'Billing';
        contacts.add(testContact);
        //Create Contacts
        testContact = TestDataFactory.createContact('TestContactAct','Last',parentAccount.Id, true, false);
        testContact.Email = 'testContacAct@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        testContact = TestDataFactory.createContact('TestContact1','Last1',parentAccount.id,true,false);
        testContact.Email = 'testContact1@move.com';
        testContact.Type__c = 'Primary';
        contacts.add(testContact);
        
        insert contacts;
        for(contact con: contacts){
            ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(con.Id,'Email','testing@yahoo.com',true,true,'Business Email');    
        }
        
        // Create Relationship records for Contact Relationhsip
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                            parentAccount.Id, null, contacts.get(0).Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Billing_Contact__c = false;
        toBeInserted.add(accountRelation); 
    
        
        Account_Relationship__c accountRelation1 = TestDataFactory.createAccountRelationship(
                            parentAccount.Id, null, contacts.get(2).Id, null, true, false);
        accountRelation1.Billing_Contact__c = true;
        accountRelation1.Is_Parent_Primary__c = true;
        accountRelation1.Active__c = true;
        accountRelation1.Relationship_Type__c = 'contact';
        accountRelation1.RecordTypeId =  contactRelationshipRecordTypeId;
        toBeInserted.add(accountRelation1);
        insert toBeInserted;
        Test.startTest();
        

        String st= String.valueOf(toBeInserted[0].Parent_Account__c) + '__' + String.valueOf(toBeInserted[0].Child_Account__c);
        map<id,Account_Relationship__c> var =new map<id,Account_Relationship__c>();
        map<id,Account_Relationship__c> var1 =new map<id,Account_Relationship__c>();        
        var.put(toBeInserted[0].id, toBeInserted[0]);
        var1.put(toBeInserted[1].id, toBeInserted[1]);
        
        AccountRelationshipTriggerHandlerManager arthm = new AccountRelationshipTriggerHandlerManager();
        arthm.setbillngcntctfalseupdate(var, var);
        arthm.setPrimarycntfalseupdate(var, var, true);
        
        //System.assertEquals(totalInsertsFailed,1);   
        Account_Relationship__c accountRelation2 = [SELECT Id, Active__c, RecordTypeId, Parent_Account__c, Child_Account__c, Contact_To__c FROM Account_Relationship__c WHERE Id in: toBeInserted AND Is_Parent_Primary__c =: false];
        //toBeInserted.get(0).Active__c = false;
        accountRelation2.Is_Parent_Primary__c = true;
        accountRelation2.Billing_Contact__c = true;
        toBeInserted.clear();
        toBeInserted.add(accountRelation2);
        update toBeInserted;
        
        Map<string,List<Account_Relationship__c>> var2 =new Map<string,List<Account_Relationship__c>>();
        Map<id,Account_Relationship__c> var3 = new Map<id,Account_Relationship__c>();
        var2.put(st, toBeInserted);
        
        //AccountRelationshipTriggerHandlerManager arthm = new AccountRelationshipTriggerHandlerManager();
        arthm.validateAccountRelationshipRecords(toBeInserted, var, false);
        arthm.validateExistingContactRelationshipTypeRecords(toBeInserted, var2, var, true);
        //var3.put(toBeInserted[1].Id, toBeInserted[1]);
        arthm.setbillngcntctfalseupdate(var3, var1);
        Test.stopTest();
    }
    
   static TestMethod void testCMFunctionality(){
        Test.startTest();
        
        //Inserting Customsetting 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = false);
        insert art; 
        User batchUser = [select id,name from user where name='Batchintegration User'][0];
        Collection_Users__c collUser = new Collection_Users__c(name = 'batchintegration user',Id__c = batchUser.Id);
        insert collUser; 
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','agent@realtor.com','5105648746');
        Contact cont = TestDataFactory.createContactWithEmailAndPhone('testing@gmail.com',null);
        Contact cont1 = TestDataFactory.createContactWithEmailAndPhone('testing12@gmail.com',null);
        
       	ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Email','testing@yahoo.com',true,true,'Business Email');                     
		ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6183032133',true,true,'Business Mobile'); 
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(cont.Id,'Web','www.move-inc.com',true,true,'HomePage');
        ContactMethod__c contactMethodRecord3 =  TestDataFactory.createContactMethod(cont1.Id,'Email','testing12@yahoo.com',true,true,'Business Email');
        ContactMethod__c contactMethodRecord4 =  TestDataFactory.createContactMethod(cont1.Id,'Phone','6183032131',true,true,'Business Mobile'); 
        ContactMethod__c contactMethodRecord5 =  TestDataFactory.createContactMethod(cont1.Id,'Web','www.moveinc.com',true,true,'HomePage');

        CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        Account_Relationship__c accRelationship = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');                 
        accRelationship.Contact_To__c = cont1.Id;
       update accRelationship;
       system.assert(cont1.Id == accRelationship.Contact_To__c);
       accRelationship.Active__c = false;
       update accRelationship;
       accRelationship.Active__c = true;
       update accRelationship;
       Test.stopTest();
    }
    
    static TestMethod void testCMFunctionality1(){
        Test.startTest();
        
        //Inserting Customsetting 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c ='Test@test.com', TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = false);
        insert art; 
        User batchUser = [select id,name from user where name='Batchintegration User'][0];
        Collection_Users__c collUser = new Collection_Users__c(name = 'batchintegration user',Id__c = batchUser.Id);
        insert collUser; 
        
        Account acc = TestDataFactory.createAccountWithEmailAndPhone('Realtor Agent','agent@realtor.com','5105648746');
        Contact cont = TestDataFactory.createContactWithEmailAndPhone('testing@gmail.com',null);
        ContactMethod__c contactMethodRecord =  TestDataFactory.createContactMethod(cont.Id,'Email','testing@yahoo.com',true,true,'Business Email'); 
        ContactMethod__c contactMethodRecord1 =  TestDataFactory.createContactMethod(cont.Id,'Phone','6183032131',true,true,'Business Mobile'); 
        ContactMethod__c contactMethodRecord2 =  TestDataFactory.createContactMethod(cont.Id,'Web','www.move-inc.com',true,true,'HomePage');

        CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        Account_Relationship__c accRelationship = TestDataFactory.createAccountRelationshipWithRecordType(acc.Id,cont.Id,'Primary Contact',true,'Contact Relationship',null,'Contact');  

        CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        accRelationship.Contact_Role__c = 'Secondary Contact';
        update accRelationship;
        
        CheckRecursiveTrigger.executeTriggerOnce = TRUE;
        accRelationship.Contact_Role__c = 'Primary Contact';
        update accRelationship;
        
        system.assert('Primary Contact' == accRelationship.Contact_Role__c);
        Test.stopTest();
    }
   
}