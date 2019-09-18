@isTest 
private class comarketingAccountTest {
    static testMethod void method1() {
        //test data
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
           
        //creating account for agent and lender with type as real estate agent and lender
        // Inserting account records.
            Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
            agentAcc.Primary_Email__c = 'parentAcc@move.com';
            agentAcc.Type = 'Realtor Agent';
            agentAcc.Party_ID__c  = '12345';
            agentAcc.Customer_Id__c  = '12345';
            agentAcc.BillingPostalCode  = '12345';
            agentAcc.BillingCity = 'newyork';
            agentAcc.MLS_Set_Id__c  = '12345';    
        
            insert agentAcc;
            
            Account lenderAcc = TestDataFactory.createAccount('Agent Account', null, false);
            lenderAcc.Primary_Email__c = 'parentAcc@move.com';
        	lenderAcc.Email_Address__c = 'parentAcc@move.com';
            lenderAcc.Type = 'Lender Individual';
            lenderAcc.Party_ID__c  = '67890';
            lenderAcc.Customer_Id__c  = '67890';
            lenderAcc.BillingPostalCode  = '67890';
            lenderAcc.BillingCity = 'newyork';
            lenderAcc.MLS_Set_Id__c  = '67890';    
            lenderAcc.nmls_Id__c = '12355';
        
            insert lenderAcc;
            
           //Inserting Assets
           //status = 'Active' AND productCode = 'COBROKE' AND Fulfillment_Status__c = 'Fulfilled' and asset_type__c = 'Parent'
           
            Product2 prd = new Product2();
            prd.name = 'Test Product';
            prd.productCode = 'COBROKE';
            Insert prd;
            
            Integer COUNTER = 10;
            List<Asset> theTestAssets = new List<Asset>();
            for(Integer index = 0; index < COUNTER; index++) {
                theTestAssets.add(new Asset(
                 Name = 'Test Asset - ' + index,
                 AccountId = agentAcc.Id,
                 Asset_Type__c='Parent',
                 Get_CP_Login_Status__c = 'Ready',
                 Fulfillment_Status__c = 'Fulfilled',
                 Status = 'Active',
                 Product2Id = prd.id,
                 price__c = 400,
                 extended_net_price__c = 400
                ));
            }
            insert theTestAssets;       
        
        //creating contacts
          
              List<Contact> contacts= new List<Contact>();
            //Create Contacts
            Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
             //Create Contacts
            testContact = TestDataFactory.createContact('TestContact','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
            
            insert contacts;
                    
      
                
        //creating account realtionships for agent and lender
            // Create Relationship records for Contact Relationhsip
                List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();

              Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

            Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(0).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(1).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(2).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(3).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            insert toBeInserted;
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = agentAcc.Id;
            ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            ar.comarketer_actual_spend__c = 100;
            insert ar;
            
            comarketing_relationship__c c = new comarketing_relationship__c();
            c.relationship__c = ar.id;
            c.status__c = 'Active';
            insert c;
        //start test
        test.startTest();
           ApexPages.currentPage().getParameters().put('rId', ar.id);
           ApexPages.currentPage().getParameters().put('accountType', 'Agent');
           ApexPages.currentPage().getParameters().put('id', String.valueOf(agentAcc.Id));
           comarketingAccountCtrl cr = new comarketingAccountCtrl();


           cr.add();
           comarketingDetailsCtrl crd = new comarketingDetailsCtrl();

           crd.partyId = '67890';
           crd.onChangePartyID();
           crd.comarketerSpend = '100';
           crd.onChangeLenderSpend();
           crd.relationshipCAP = '2000';
           crd.onChangeLenderSpendMax();
           crd.selectedAssetsPrice = 5000;
           crd.assetPrice = 5000;
           crd.comarketingSpendPercent = 10;
           crd.comarketingCurrentPercent = 20;
           crd.onChangeLenderSpendMax();
           crd.goback();
           crd.getPartyIdLabel();
           
           
           crd.activate();
           crd.createWrapper('12345');
           cr.getRelations();
           cr.cancel();
           cr.returnToAccount();
       
       test.stopTest();
       }
       
       static testMethod void method2() {
        //test data
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
           
        //creating account for agent and lender with type as real estate agent and lender
        // Inserting account records.
            Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
            agentAcc.Primary_Email__c = 'parentAcc@move.com';
            agentAcc.Type = 'Realtor Agent';
            agentAcc.Party_ID__c  = '12345';
            agentAcc.Customer_Id__c  = '12345';
            agentAcc.BillingPostalCode  = '12345';
            agentAcc.BillingCity = 'newyork';
            agentAcc.MLS_Set_Id__c  = '12345';    
        
            insert agentAcc;
            
            Account lenderAcc = TestDataFactory.createAccount('Agent Account', null, false);
            lenderAcc.Primary_Email__c = 'parentAcc@move.com';
           lenderAcc.Email_Address__c = 'parentAcc@move.com';
            lenderAcc.Type = 'Lender Individual';
            lenderAcc.Party_ID__c  = '67890';
            lenderAcc.Customer_Id__c  = '67890';
            lenderAcc.BillingPostalCode  = '67890';
            lenderAcc.BillingCity = 'newyork';
            lenderAcc.MLS_Set_Id__c  = '67890';    
            lenderAcc.nmls_Id__c = '12355';
        
            insert lenderAcc;
            
           //Inserting Assets
           //status = 'Active' AND productCode = 'COBROKE' AND Fulfillment_Status__c = 'Fulfilled' and asset_type__c = 'Parent'
           
            Product2 prd = new Product2();
            prd.name = 'Test Product';
            prd.productCode = 'COBROKE';
            Insert prd;
            
            Integer COUNTER = 10;
            List<Asset> theTestAssets = new List<Asset>();
            for(Integer index = 0; index < COUNTER; index++) {
                theTestAssets.add(new Asset(
                 Name = 'Test Asset - ' + index,
                 AccountId = agentAcc.Id,
                 Asset_Type__c='Parent',
                 Get_CP_Login_Status__c = 'Ready',
                 Fulfillment_Status__c = 'Fulfilled',
                 Status = 'Active',
                 Product2Id = prd.id,
                 price__c = 400,
                 extended_net_price__c = 400
                ));
            }
            insert theTestAssets;       
        
        //creating contacts
          
              List<Contact> contacts= new List<Contact>();
            //Create Contacts
            Contact testContact = TestDataFactory.createContact('TestContact','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',agentAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
             //Create Contacts
            testContact = TestDataFactory.createContact('TestContact','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContact@move.com';
            testContact.Type__c = 'Billing';
            contacts.add(testContact);
            //Create Contacts
            testContact = TestDataFactory.createContact('TestContactAct','Last',lenderAcc.Id, true, false);
            testContact.Email = 'testContacAct@move.com';
            testContact.Type__c = 'Primary';
            contacts.add(testContact);
            
            insert contacts;
                    
      
                
        //creating account realtionships for agent and lender
            // Create Relationship records for Contact Relationhsip
                List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();

              Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

            Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(0).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                agentAcc.Id, null, contacts.get(1).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(2).Id, null, true, false);
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
            accountRelation.Active__c = true;
            accountRelation.Billing_Contact__c = true;
            toBeInserted.add(accountRelation); //5
        
            
            accountRelation = TestDataFactory.createAccountRelationship(
                                lenderAcc.Id, null, contacts.get(3).Id, null, true, false);
            accountRelation.Billing_Contact__c = false;
            accountRelation.Is_Parent_Primary__c = false;
            
            accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        
            toBeInserted.add(accountRelation);
            insert toBeInserted;
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = agentAcc.Id;
            ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            ar.comarketer_actual_spend__c = 100;
            insert ar;
            
            comarketing_relationship__c c = new comarketing_relationship__c();
            c.relationship__c = ar.id;
            
            insert c;
            
            
        //start test
        test.startTest();
           ApexPages.currentPage().getParameters().put('rId', '');
           ApexPages.currentPage().getParameters().put('accountType', 'Lender Individual');
           ApexPages.currentPage().getParameters().put('id', String.valueOf(agentAcc.Id));
           comarketingAccountCtrl cr = new comarketingAccountCtrl();


           cr.add();
           comarketingDetailsCtrl crd = new comarketingDetailsCtrl();

           crd.partyId = '12345';
           crd.onChangePartyID();
           crd.comarketerSpend = '100';
           crd.onChangeLenderSpend();
           crd.relationshipCAP = '2000';
           crd.onChangeLenderSpendMax();
           crd.selectedAssetsPrice = 5000;
           crd.assetPrice = 5000;
           crd.comarketingSpendPercent = 10;
           crd.comarketingCurrentPercent = 20;
           crd.onChangeLenderSpendMax();
           crd.goback();
           crd.getPartyIdLabel();
           
           
           crd.activate();
           crd.createWrapper('67890');
           cr.getRelations();
          // cr.cancel();
           cr.returnToAccount();
       
       test.stopTest();
       }
       }