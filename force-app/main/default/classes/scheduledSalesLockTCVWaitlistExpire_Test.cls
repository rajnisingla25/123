@isTest
public  class scheduledSalesLockTCVWaitlistExpire_Test
{
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
      public static testmethod void testschedules()
      {
        Integer COUNTER = 12;
        DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
        Schedule_Batch_Setting__c settingsbatch1 = new Schedule_Batch_Setting__c(Name= 'User process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch1;
        Schedule_Batch_Setting__c settingsbatch2 = new Schedule_Batch_Setting__c(Name= 'Waitlist Expire Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch2;
        Schedule_Batch_Setting__c settingsbatch3 = new Schedule_Batch_Setting__c(Name= 'TCV Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch3;
        Schedule_Batch_Setting__c settingsbatch4 = new Schedule_Batch_Setting__c(Name= 'Update Account Primary Email Process',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 23);
        insert settingsbatch4;
        
       Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);  
        test.startTest();
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = testAcc.Id,
             Asset_Type__c='Parent',
             Get_CP_Login_Status__c = 'Ready',
             Fulfillment_Status__c = 'Fulfilled'
            ));
        }
     insert theTestAssets;           
       AssetCreateCPandLogin_Schedule sh1 = new AssetCreateCPandLogin_Schedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Activate Future Asset',sch,sh1);
         Test.stopTest(); 
  }
  Public static testmethod void testschedule(){
    List<Schedule_Batch_Setting__c> lstScheduleBatchSetting = new List<Schedule_Batch_Setting__c>();
  Schedule_Batch_Setting__c settingsbatch1 = new Schedule_Batch_Setting__c(Name= 'User process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        lstScheduleBatchSetting.add(settingsbatch1);
        Schedule_Batch_Setting__c settingsbatch2 = new Schedule_Batch_Setting__c(Name= 'Waitlist Expire Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        lstScheduleBatchSetting.add(settingsbatch2);
        Schedule_Batch_Setting__c settingsbatch3 = new Schedule_Batch_Setting__c(Name= 'TCV Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        lstScheduleBatchSetting.add(settingsbatch3);
        Schedule_Batch_Setting__c settingsbatch4 = new Schedule_Batch_Setting__c(Name= 'Update Account Primary Email Process',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        lstScheduleBatchSetting.add(settingsbatch4);
        Schedule_Batch_Setting__c settingsbatch5 = new Schedule_Batch_Setting__c(Name= 'Zoura Process',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24, Last_Execution__c=date.today()-1);
        lstScheduleBatchSetting.add(settingsbatch5);
        Schedule_Batch_Setting__c settingsbatch8 = new Schedule_Batch_Setting__c(Name= 'Case Process',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24, Last_Execution__c=date.today()-1);
        lstScheduleBatchSetting.add(settingsbatch8);
        Schedule_Batch_Setting__c settingsbatch9 = new Schedule_Batch_Setting__c(Name= 'Inventory Error Process Job',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24, Last_Execution__c=date.today()-1);
        lstScheduleBatchSetting.add(settingsbatch9);
        Schedule_Batch_Setting__c NVMNextContTime = new  Schedule_Batch_Setting__c(Name= 'NVM Next Contact Time',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24, Last_Execution__c=date.today()-1);
        lstScheduleBatchSetting.add(NVMNextContTime);
        Schedule_Batch_Setting__c Opcityrenewal = new  Schedule_Batch_Setting__c(Name= 'OpcityAssetRenewalProcess',Execution_Min__c=10,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24, Last_Execution__c=date.today()-1);
        lstScheduleBatchSetting.add(Opcityrenewal);
        Schedule_Batch_Setting__c quotePurge = new  Schedule_Batch_Setting__c(Name= 'Quote Purge', Is_Running__c=true);
        lstScheduleBatchSetting.add(quotePurge);
        Schedule_Batch_Setting__c scheduleSetting = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Execution_Min__c = 1, Assetresttime__c = 1);
        lstScheduleBatchSetting.add(scheduleSetting);
        Schedule_Batch_Setting__c lcmBatch = new Schedule_Batch_Setting__c(Name = 'LCM Cancel Notification', Is_Running__c=true,Execution_Time_hr__c = 0);
        lstScheduleBatchSetting.add(lcmBatch);
        Schedule_Batch_Setting__c lcmBatch2 = new Schedule_Batch_Setting__c(Name = 'LCM Data Validation', Is_Running__c=true,Execution_Time_hr__c = 0);
        //lstScheduleBatchSetting.add(lcmBatch2); 
        insert lstScheduleBatchSetting;
        
        
      Datetime lastrun = DateTime.parse('02/12/2018 8:00 AM');
       Schedule_Batch_Setting__c settingsbatch6 = new Schedule_Batch_Setting__c(Name= 'Monitor Async Apex Job',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24,Last_Execution__c = lastrun);
        insert settingsbatch6;
        Error_Notification_Email_Settings__c settingsbatch7 = new Error_Notification_Email_Settings__c(Name= 'MonitorAsyncApexJob',Asset_Creation_Error_Emails__c ='Test@test.com');
         insert settingsbatch7;
       DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AccountTrigger__c =UserInfo.getUserName(), TaskTrigger__c = UserInfo.getUserName(),AssetTrigger__c =USerInfo.getUserName(), QuoteTrigger__c='tezt@test.com', Order_Trigger__c=UserInfo.getUserName());
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
       
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        parentAccount.Type = 'Realtor Agent';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';   
        parentAccount.Account_Sub_Type__c = 'Customer'; 
      
      parentAccount.Sales_lock_Date__c = date.today() -1;
      
        insert parentAccount;
        
        
        Contact theContact = new Contact(
                FirstName = 'firstName',
                LastName = 'lastName',
                AccountId = parentAccount.id,
                Active__c = true,
                Type__c= 'Test',
                Email='xyz@abc.com');
                insert theContact;
        
        Account_Relationship__c accountRelation = new Account_Relationship__c ();
        accountRelation.Parent_account__c = parentAccount.Id;
        accountRelation.contact_to__c = theContact.Id;
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Billing_Contact__c = true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        accountRelation.relationship_type__c = 'Partner';
        accountRelation.comarketing_status__c = 'Active';
        accountRelation.current_comarketer_spend_percent__c = 10;
        accountrelation.comarketer_actual_spend__c = 900;
        accountRelation.total_connections_price__c = 9000;
        accountrelation.total_relationship_assets_price__c = 9000;
        accountRelation.Total_comarketing_assets__c = 10;
        accountRelation.relationship_CAP__c = 800;
        insert accountRelation;
       
        theContact.email = '123@123.com';
        
      BigMachines__Quote__c q12 = new BigMachines__Quote__c(
        BigMachines__Account__c = parentAccount.Id,       
        BigMachines__Status__c = 'Pending',
        BigMachines_Quote_Type__c = 'New',
        BigMachines__Site__c = 'a1Nj0000000Cu4VEAS'
                 );
        insert q12 ;
      
      MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
      mtduc.newAccount = parentAccount;
      
      OrderDecompController.stopCreatingAccount = true;
      
      Product2 newProduct = mtduc.CreateProductSingle();
      newProduct.productCode = 'COBROKE';
      update newProduct;
      List<Asset> alist = new List<Asset>();
      Asset assets = mtduc.CreateFullfilledAssetSingle();
      Asset assets2 = mtduc.CreateFullfilledAssetSingle();
      

      Asset assets3 = mtduc.CreateFullfilledAssetSingle();

      assets.line_type__c = 'cancel';
      assets.status = 'Cancelled';
      assets.fulfillment_status__c = 'Fulfilled';
      assets.extended_net_price__c = 30;
      assets.billing_period__c = 'Monthly';
      update assets;
      
      
      assets2.line_type__c = 'Add';
      assets2.fulfillment_status__c = 'Fulfilled';
      assets2.status = 'Active';
      assets2.extended_net_price__c = 250;
      assets2.billing_period__c = 'Monthly';
      update assets2;
      
      assets3.line_type__c = 'Amend';
      assets3.status = 'Active';
      assets3.extended_net_price__c = 30;
      assets3.billing_period__c = 'Monthly';
      update assets3;
      
       List<comarketing_relationship__c> clist = new List<Comarketing_Relationship__c>();
        
        Comarketing_Relationship__c cr = new Comarketing_Relationship__c();
        cr.relationship__c = accountRelation.id;
        cr.agent_account__c = accountrelation.parent_account__c;
        cr.status__c = 'Active';
        cr.cfcb_asset__c = assets.id;
        cr.Lender_Asset_Monthly_Contribution__c = 10;
        cr.Agent_Asset_Monthly_Contribution__c = 10;
        cr.Lender_Percentage_Contribution__c = 10;
        cr.Agent_Lender_Asset_Id__c = '67567';
        clist.add(cr);
        Comarketing_Relationship__c cr2 = new Comarketing_Relationship__c();
        cr2.relationship__c = accountRelation.id;
        cr2.agent_account__c = accountrelation.parent_account__c;
        cr2.status__c = 'Active';
        cr2.cfcb_asset__c = assets3.id;
        cr2.Lender_Asset_Monthly_Contribution__c = 0;
        cr2.Agent_Asset_Monthly_Contribution__c = 10;
        cr2.Lender_Percentage_Contribution__c = 0;
        cr2.Agent_Lender_Asset_Id__c ='12345';
        clist.add(cr2);
          
        insert clist;  
      // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;
        insert thePricebookEntrie;
      
      // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < 5;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today(),
            Status = 'Created',            
            AccountId = parentAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Renew',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
      
      
      for(Order newOrder :theTestOrders)
          newOrder.Status = 'Complete';
      
      update theTestOrders;
      
        mtduc.CreatePresaleAvailable();

        mtduc.CreateUserSingle();  
        mtduc.CreateTigerLeadSingle();
        //mtduc.UpdateUserSingle();   
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateContractSingle();
         
        mtduc.CreateCaseSingle2();

        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle(); 
        mtduc.CreateProductSingle(); 
        mtduc.CreateOrderSingle();
        mtduc.CreateProductManualSingle();
        //mtduc.CreateFullfilledAssetSingle();
        mtduc.CreatePricebookEntrySingle();
        mtduc.CreatePricebookEntryManualSingle();
        //System.debug(mtduc.thePricebookEntrie+'666666');
        mtduc.CreateOpportunityProductSingle();
        List<Account> lstAccount = [Select Id From Account Limit 1];
        List<Opportunity> lstOpportunity = [Select Id From Opportunity Limit 1];
        //mtduc.CreateOracleQuoteSingle();
        BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = lstAccount[0].id;
        OracleQuote.BigMachines__Opportunity__c = lstOpportunity[0].id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        OracleQuote.NotEligibleForBundling__c = true;
        OracleQuote.BigMachines__Site__c = Label.BigMachineSite;
        insert OracleQuote;
        Test.setCreatedDate(OracleQuote.Id, Datetime.now().addDays(-1));
      scheduledSalesLockTCVWaitlistExpire sh1 = new scheduledSalesLockTCVWaitlistExpire();
      SchedulableContext sc;
      try{
          Test.startTest();
      sh1.execute(sc);
          Test.stopTest();
      }catch(exception e){}
    }
}