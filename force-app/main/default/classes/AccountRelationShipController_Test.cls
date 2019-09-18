@isTest
private class AccountRelationShipController_Test {


  @testSetup static void createAccountRealationShiprecords(){
           //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;     

    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

    // Inserting account records.
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
  
  
    //Create Account Relationship Records for Accounts
    Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (parentAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Is_Parent_Primary__c = true;   

    toBeInserted.add(accountRelation); //0

    accountRelation = TestDataFactory.createAccountRelationship(parentAccount.Id, childAccount2.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Is_Parent_Primary__c = false; 
    toBeInserted.add(accountRelation);    // 1


    //accountRelation = TestDataFactory.createAccountRelationship(parentAccount.ID, childAccount2.Id, null, null, true, false);
    //accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    //accountRelation.Active__c = true;
    //accountRelation.Is_Parent_Primary__c = false; 
   // toBeInserted.add(accountRelation);    


    accountRelation = TestDataFactory.createAccountRelationship(parentAccount.Id, parentAccount2.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;    
    toBeInserted.add(accountRelation); //2 


    //Create Account Relationship Records for Accounts
    accountRelation = TestDataFactory.createAccountRelationship
                                                            (parentAccount2.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Is_Parent_Primary__c = true;    

    toBeInserted.add(accountRelation); //3

    Account parentAcc1 = TestDataFactory.createAccount('Parent Acc1',null,false);
    parentAcc1.Primary_Email__c = 'parentAcc1@move.com';
      

    insert parentAcc1;
    
    accountRelation = TestDataFactory.createAccountRelationship(parentAcc1.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;    
    toBeInserted.add(accountRelation); // 4
    
    

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
    
    // Create Relationship records for Contact Relationhsip
    accountRelation = TestDataFactory.createAccountRelationship(
                        parentAcc1.Id, null, contacts.get(0).Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); //5

    
    accountRelation = TestDataFactory.createAccountRelationship(
                        parentAccount.Id, null, contacts.get(2).Id, null, true, false);
    accountRelation.Billing_Contact__c = false;
    accountRelation.Is_Parent_Primary__c = false;
    
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;

    toBeInserted.add(accountRelation);
    insert toBeInserted;
        toBeInserted[1].Is_Parent_Primary__c = true;
        toBeInserted[3].Child_Account__c =  childAccount2.ID;
        toBeInserted[2].Is_Parent_Primary__c = true;
    update toBeInserted;

  }

  @isTest static void test_method_one() {
        test.startTest();
    // Implement test code
    Account_Relationship__c accountRelation = [SELECT ID,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c != null LIMIT 1];
    Account oaccount = [SELECt ID FROM Account WHERE ID=: accountRelation.Parent_Account__c];
    PageReference pageRef = Page.AccountRelationShipPage;

        pageRef.getParameters().put('id', String.valueOf(oaccount.ID));
        Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(oaccount);
        AccountRelationShipController testaccCTRL = new AccountRelationShipController(sc);        
        testaccCTRL.accName = 'acc';
        testaccCTRL.accPartyID = '12345';
        //testaccCTRL.acccustomerID = '12345';
        testaccCTRL.accZipcode = '12345';
        testaccCTRL.accCity = 'newyork';
        testaccCTRL.accMLS = '12345';    

        testaccCTRL.SearchRelatedAccount();
        testaccCTRL.getSelected();
        testaccCTRL.comma2Set('');
        testaccCTRL.accIdSelected = oaccount.ID;
        testaccCTRL.accountBrokers[0].selected = true;
        testaccCTRL.accountOffices[0].selected = true;
        testaccCTRL.Submit();
        testaccCTRL.getfieldsfromSobject('asset');
        test.stoptest();


  }
  
  @isTest static void test_method_two() {
    test.startTest();
// Implement test code
        Account_Relationship__c accountRelation = [SELECT ID,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c != null LIMIT 1];
        Account oaccount = [SELECt ID FROM Account WHERE ID=: accountRelation.Parent_Account__c];
        PageReference pageRef = Page.AccountRelationShipPage;

        pageRef.getParameters().put('id', String.valueOf(oaccount.ID));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(oaccount);
        AccountRelationShipController testaccCTRL = new AccountRelationShipController(sc);        
        testaccCTRL.accName = 'acc';
        testaccCTRL.accPartyID = '12345';
        //testaccCTRL.acccustomerID = '12345';
        testaccCTRL.accZipcode = '12345';
        testaccCTRL.accCity = 'newyork';
        testaccCTRL.accMLS = '12345';    

        testaccCTRL.SearchRelatedAccount();
        testaccCTRL.getSelected();
        testaccCTRL.comma2Set('');
        testaccCTRL.accountBrokers.clear();
        //testaccCTRL.accIdSelected = oaccount.ID;        
        testaccCTRL.accountOffices[0].selected = true;
        //pageRef.getParameters().put('primaryOfficeSelected',oaccount.ID);
        testaccCTRL.selectAccount();
        //testaccCTRL.Convert();

        testaccCTRL.Submit();
        test.stoptest();
  }

    
    @isTest static void test_method_three() {
        test.startTest();
        // Implement test code
        //  Account acc = [SELECT ID FROM Account WHERE Primary_Email__c = 'parentAcc2@move.com'];
        Account_Relationship__c accountRelation = [SELECT ID,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c != null LIMIT 1];
       
        Account oaccount = [SELECt ID FROM Account WHERE ID=: accountRelation.Parent_Account__c];
        PageReference pageRef = Page.AccountRelationShipPage;

        pageRef.getParameters().put('id', String.valueOf(oaccount.ID));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(oaccount);
        AccountRelationShipController testaccCTRL = new AccountRelationShipController(sc);        
        testaccCTRL.accName = 'acc';
        testaccCTRL.accPartyID = '12345';
        //testaccCTRL.acccustomerID = '12345';
        testaccCTRL.accZipcode = '12345';
        testaccCTRL.accCity = 'newyork';
        testaccCTRL.accMLS = '12345';    

        testaccCTRL.SearchRelatedAccount();
        testaccCTRL.getSelected();
        testaccCTRL.comma2Set('');
        testaccCTRL.accountBrokers.clear();        
        testaccCTRL.accountOffices[0].selected = true;        
        testaccCTRL.Submit();
        test.stoptest();
        Account_Relationship__c accountRelation2 = [SELECT ID,Parent_Account__c,Parent_Account__r.Type,child_Account__r.type FROM Account_Relationship__c WHERE Parent_Account__c != null limit 1];
        AccountRelationShipController.AccountRelationWrapper arwn = new AccountRelationShipController.AccountRelationWrapper(accountRelation2);

    }

   @isTest static void test_method_four() {
        test.startTest();
        // Implement test code
          Account acc = [SELECT ID FROM Account WHERE Primary_Email__c = 'parentAcc2@move.com'];
        Account_Relationship__c accountRelation = [SELECT ID,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c =: acc.id LIMIT 1];
       
        Account oaccount = [SELECt ID FROM Account WHERE ID=: accountRelation.Parent_Account__c];
        PageReference pageRef = Page.AccountRelationShipPage;

        pageRef.getParameters().put('id', String.valueOf(oaccount.ID));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(oaccount);
        AccountRelationShipController testaccCTRL = new AccountRelationShipController(sc);        
        testaccCTRL.accName = 'acc';
        testaccCTRL.accPartyID = '12345';
        //testaccCTRL.acccustomerID = '12345';
        testaccCTRL.accZipcode = '12345';
        testaccCTRL.accCity = 'newyork';
        testaccCTRL.accMLS = '12345';    

        testaccCTRL.SearchRelatedAccount();
        testaccCTRL.getSelected();
        testaccCTRL.comma2Set('');
        testaccCTRL.accountBrokers.clear();        
        testaccCTRL.accountOffices[0].selected = true;        
        testaccCTRL.Submit();
        string submit = testaccCTRL.submitlogic(string.valueof(acc.id));
        pagereference pf = testaccctrl.Convert(); 
       test.stoptest();
        Account_Relationship__c accountRelation2 = [SELECT ID,Parent_Account__c,Parent_Account__r.Type,child_Account__r.type FROM Account_Relationship__c WHERE Parent_Account__c != null limit 1];
        AccountRelationShipController.AccountRelationWrapper arwn = new AccountRelationShipController.AccountRelationWrapper(accountRelation2);

    }

}