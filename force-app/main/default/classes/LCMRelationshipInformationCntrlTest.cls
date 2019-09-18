@isTest 
public class LCMRelationshipInformationCntrlTest {
    
    static testMethod void testCase1() {
        
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
        lenderAcc.Type = 'Lender Individual';
        lenderAcc.Party_ID__c  = '67890';
        lenderAcc.Customer_Id__c  = '67890';
        lenderAcc.BillingPostalCode  = '67890';
        lenderAcc.BillingCity = 'newyork';
        lenderAcc.MLS_Set_Id__c  = '67890';    
        lenderAcc.nmls_Id__c = '12355';
        
        insert lenderAcc;
       
        Product2 prd = new Product2();
        prd.name = 'Test Product';
        prd.productCode = 'COBROKE';
        Insert prd;
        
        Integer COUNTER = 2;
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
                price__c = 400
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
        
        insert contacts;
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.parent_account__c = agentAcc.Id;
        ar.child_account__c = lenderAcc.id;
        ar.relationship_type__c = 'Partner';
        ar.comarketing_status__c= 'Active';
        ar.comarketer_spend__c = 100;
        ar.total_connections_price__c = 5000;
        ar.total_relationship_assets_price__c = 5000;
        ar.comarketer_actual_spend__c = 100;
        ar.Initial_comarketer_spend_percent__c = 10;
        ar.Parent_account_email__c='agenttest123458@abc.com';
        ar.Child_account_email__c = 'lendertest123458@abc.com';
        insert ar;
        comarketing_relationship__c c = new comarketing_relationship__c();
            c.relationship__c = ar.id;
            insert c;
        ApexPages.currentPage().getParameters().put('rId', ar.id);
        ApexPages.currentPage().getParameters().put('accountType', 'Agent');
        ApexPages.currentPage().getParameters().put('id', String.valueOf(agentAcc.Id));
        comarketingAccountCtrl cr = new comarketingAccountCtrl();
        
        cr.add();
        comarketingDetailsCtrl crd = new comarketingDetailsCtrl();
        
        crd.partyId = '67890';
        crd.comarketerSpend = '100';
        crd.relationshipCAP = '2000';
        crd.selectedAssetsPrice = 5000;
        crd.assetPrice = 5000;
        crd.comarketingSpendPercent = 10;
        
        crd.onChangeLenderSpendMax();
        crd.activate();
        cr.cancel();
        ar.Comarketing_Status__c = 'Active';
        update ar;
        List<Comarketing_Relationship__c> clist = [Select id, status__c from Comarketing_Relationship__c limit 5];
        system.debug('cr---'+clist);
        //start test
        test.startTest();
        
        LCMRelationshipInformationCntrl lri = new LCMRelationshipInformationCntrl();
        lri.setRelId(ar.id);
        lri.getRelId();
        lri.getComarketingRel();
        c.Status__c = 'Cancelled';
        update c;
		LCMCancelNotificationJob lcmJob = new LCMCancelNotificationJob();
        database.executebatch(lcmJob, 10);        
        test.stopTest();
    }
    
}