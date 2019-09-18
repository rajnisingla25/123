@isTest(seeAllData=false)
private class waitlistLeadScoreoperation_Test {
    

    @testSetup static void DataSetUpClass() {
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
     List<Account> acclist = new List<Account>(); 
          Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmail1@test.com';  
        theTestAccount.Account_Sub_Type__c ='Prospect';   
        theTestAccount.party_id__c = '12345';
        insert theTestAccount; 
        Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '67654';
         Idd.Inventory_Count__c = 20;
         Idd.Inventory_Count_Half__c = 10;
         Idd.Is_available__c = false;
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         
         Inventory_Account__c Iaa = new Inventory_Account__c();
         Iaa.Account__c = theTestAccount.id;
         Iaa.Inventory_Data__c = Idd.id;
         //Iaa.Buyers_Side__c = true;
         //Iaa.Form__c = true;
         //Iaa.Listing__c = true;
         Iaa.Custom_field5__c = true;
         //Iaa.Waitlist__c = true;
         //Iaa.Waitlist_Half__c = true;
         Insert Iaa;
         Iaa.Waitlist__c = true;
         //update Iaa;
         Idd.Is_available__c = true;
         
        // update Idd;
    }
    public static testMethod void mainMethod1(){   
         List<Account> acclist = [Select Id,Name,Party_id__c from Account limit 1]; 
        System.debug('acct---'+acclist);
        test.startTest();
        waitlistLeadScoreoperation wlso = new waitlistLeadScoreoperation();
        WaitlistLeadScoreWrapper wlsr = new WaitlistLeadScoreWrapper();
        wlsr.PartyId = acclist[0].Party_id__c;
        wlsr.ZipCode = '67654';
        wlsr.LeadSize = 'Any';
        wlsr.waitlistType = 'Hot';
        wlsr.waitlistLeadType = 'Fast';
        wlsr.Action = 'Insert';
        wlsr.Name = 'local';
        List<WaitlistLeadScoreWrapper> lstWLSO = new List<WaitlistLeadScoreWrapper>();
        lstWLSO.Add(wlsr);
        waitlistLeadScoreoperation.postWaitlistDataPullInventory(lstWLSO);
        Inventory_Account__c inva = [Select id from Inventory_Account__c limit 1];
        delete inva;
        waitlistLeadScoreoperation.postWaitlistDataPullInventory(lstWLSO);
       // waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FULL','HOT','FAST','UPSERT');
        //waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FULL','HOT','FAST','DELETE');
        }
        
        public static testMethod void mainMethod2(){   
         List<Account> acclist = [Select Id,Name,Party_id__c from Account limit 1]; 
        
        waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FAST','HOT','FULL','UPSERT','COBROKE');
        waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FAST','HOT','FULL','DELETE','COBROKE');
        waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FAST','HOT','FULL','UPSERT','Local Expert Zip');
        waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654','FAST','HOT','FULL','DELETE','Local Expert Zip');
          waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654, CA','FAST','HOT','FULL','UPSERT','Local Expert City');
        waitlistLeadScoreoperation.postWaitlistData(acclist[0].Party_id__c,'67654, CA','FAST','HOT','FULL','DELETE','Local Expert City');
        }
    }