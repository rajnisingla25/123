@isTest
public with sharing class commissions_AutoRenewalMonthlyBatch_Test {
    static testmethod void testCommissionAutoRenewal() {
        
        OrderDecompController.stopCreatingAccount = true;
       // OrderDecompController.stopCreatingAccountobj =true;
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.ProductRestrictionTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.TaskTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        
        CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;
        
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM;  
        string status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Integer Year = Date.Today().Year(); 
        List<user> allUsers = new  List<user>();
        Profile p = [select id from profile where name='System Administrator'];
        User user2 = Commissions_TestDataFactory.createUser(Null,p.id,null,'testautorenewalcomm1@move.com','testautorenewalcomm1@move.com',false,ManagerTeam);
        user2.Vacation_Start_Date__c = Date.today();
        user2.Vacation_End_Date__c = Date.today();
        User2.Team__c = 'Managers Team';
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        allUsers.add(User2);
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'testautorenewalcomm2@move.com','testautorenewalcomm2@move.com',false,WLVTerritory);
        user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        user1.Vacation_End_Date__c = Date.today().adddays(10);
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = WLVTerritory;
        allUsers.add(User1);
        
        User user4 = Commissions_TestDataFactory.createUser(null,p.id,null,'testautorenewalcomm3@move.com','testautorenewalcomm3@move.com',false,ManagerTeam);
        user4.LastName ='Matthews';
        user4.FirstName='Adrian';
        user4.Team__c = ManagerTeam;
        allUsers.add(User4);
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'testautorenewalcomm4@move.com','testautorenewalcomm4@move.com',false,WLVTerritory);
        //user3.managers__c = user2.Id;
        user3.managers__c = 'Adrian Matthews';
        user3.FirstName = 'FName1';
        User3.Team__c = WLVTerritory;
        //insert user3;
        allUsers.add(User3);
        Insert allUsers;
        
        Account theAccount = TestDataFactory.createAccount('The Test Account', user4.Id, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
        theAccount.Type = 'realtor';
         theAccount.Past_Due__c =true;
        insert theAccount;
        
        Zuora__CustomerAccount__c testBillingAcc = new Zuora__CustomerAccount__c();
        testBillingAcc.Name = 'my test billing account';
        testBillingAcc.Zuora__Account__c = theAccount.Id;
       
        testBillingAcc.Zuora__External_Id__c = 'testzuoraid0000000004';
         
        testBillingAcc.Zuora__BillCycleDay__c='1';
        insert testBillingAcc;
        
         Zuora__Subscription__c  Sub= new Zuora__Subscription__c();
        Sub.Zuora__Account__c = theAccount.Id;
        Sub.Name = '283838';
        Sub.Zuora__CustomerAccount__c = testBillingAcc.Id;
         Sub.Zuora__Status__c 	 ='Active';
        Sub.Zuora__SubscriptionEndDate__c = date.today();
        insert Sub;
        
        List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__DueDate__c = System.TODAY();
        inv.Zuora__Balance2__c = 0; 
        inv.Zuora__Account__c = theAccount.Id;
        insert inv;
        List<Zuora__Payment__c> paymentList = new List<Zuora__Payment__c>();  
        for (Integer i = 0; i < 10; i++) {
            Zuora__Payment__c Zpay = new Zuora__Payment__c();
            Zpay.Zuora__Status__c = 'Processed';
            Zpay.SalesforceCollectionsRepUsername__c = '';
            Zpay.Zuora__Invoice__c = inv.Id;
            Zpay.Zuora__BillingAccount__c = testBillingAcc.Id;
            paymentList.add(Zpay);
        }
        insert paymentList;
        Zuora__PaymentInvoice__c invpay = new Zuora__PaymentInvoice__c();
        invpay.Zuora__Payment__c = paymentList[0].Id;
        invpay.Zuora__Invoice__c = inv.Id;
        invpay.Zuora__ApplyAmount__c = 25.00;
        insert invpay;
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'Top Producer IDX';
        prdctdata.Commission_Category__c='Normal';
        prdctdata.S_No__c=12;
        prdctdata.ProductCode = 'TOPCRM';
        prdctdata.Renewal_Term_Type__c = 'Evergreen';
        insert prdctdata; 
        
        Id pricebookId= Test.getStandardPricebookId(); 
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;     
        
        Contract c = new Contract();
        c.Accountid=theAccount.id;       
        insert c;   
        Order r = new Order();       
        r.AccountId=theAccount.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user2.id;
        insert r;   
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        insert oi;
        
        SkipAssetTrigger.setSkipTrgTrue();

       id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid = user2.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(100);
        assets.Asset_Type__c = 'Parent';
        assets.Line_Type__c = 'renew';
        assets.Month_to_Month__c = 'Y';
        assets.Product2Id = prdctdata.Id;
        assets.Sign_in_AE__c= user2.id;
        assets.Order_Line_Item__c = oi.id;
        assets.AccountId = theAccount.id;
        insert assets;
        
        list<Invoice_Item__c> invoiceItemList = new list<Invoice_Item__c>();
        for( integer counter = 0 ;counter <= 10 ;counter++){
            invoiceItemList.add( new Invoice_Item__c(
                Name = 'Test INVItem '+counter,
                Charge_Date__c = date.Today()-3,
                Charge_Amount__c = 123.22,
                Service_End_Date__c = date.Today() + 5,
                Service_Start_Date__c = date.Today()-5,
                Tax_Amount__c = 123.22,
                Unit_Price__c = 123.22,
                Asset__c = assets.Id,
               // Invoice_Zuora_ID__c = '8585234234',
                //RPC_Zuora_ID__c = '856858889',
//                Product_Zuora_ID__c = '9768755566',
                Invoice__c = inv.Id)); 
        }
        insert invoiceItemList;
        
        Period__c period = new Period__c(
            Name='test',
            Start_Date__c = Date.today().toStartOfMonth(),
            BOBAmount__c = 1000,
            Tiger_Lead_Qualifier_Amount__c = 10000);
        insert period;
        
        List<Quota__c> allQuotas = new List<Quota__c>();     
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.User__c= User2.Id;
        QuotaHandler.User_Team__c = 'Managers Team';
        QuotaHandler.Period_Name__c = period.id;
        QuotaHandler.Target_Amount_2__c = 1000;
        
        allQuotas.add(QuotaHandler);
        
        Quota__c  QuotaHandlermn = new Quota__c(
            User__c = User4.Id,
            TP_Units_Sold__c=6,
            Is_Kicker__c = true,
            User_Team__c = 'Managers Team',
            Current_Quater__c = 'Q4',       
            Period_Name__c=Period.Id);      
        insert QuotaHandlermn; 
        
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.Target_Amount__c = 345345;
        QuotaHandlerM.User__c= user1.Id;
        QuotaHandlerM.User_Team__c = ManagerTeam;
        QuotaHandlerM.Period_Name__c = period.id;
        QuotaHandlerM.Target_Amount_2__c = 1000;         
        
        insert allQuotas;  
        
        
        
        List<Commission__c> allcommissions = new List<Commission__c>();   
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm.Related_to_Asset__c = assets.Id;
        comm.Asset_Amount__c = 100;
        comm.user_team__c = WLVTerritory;
        comm.Invoice_Item__c = invoiceItemList[0].Id;
        allcommissions.add(comm);
        
        Commission__c  comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandlermn.Id, prdctdata.Id,rectypidq,null,false);
        comm1.Related_to_Asset__c = assets.Id;
        comm1.Asset_Amount__c = 100;
        comm1.user_team__c = ManagerTeam;
        comm1.Invoice_Item__c = invoiceItemList[0].Id;
        
        allcommissions.add(comm1);
        
        Commission__c  comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandlermn.Id, prdctdata.Id,rectypidq,null,false);
        comm2.Related_to_Asset__c = assets.Id;
        comm2.Asset_Amount__c = 100;
        comm2.user_team__c = ManagerTeam;
        comm2.Invoice_Item__c = invoiceItemList[0].Id;
        
        allcommissions.add(comm2);
        Commission__c  comm3 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,false);
        comm3.Related_to_Asset__c = assets.Id;
        comm3.Asset_Amount__c = 100;
        comm3.user_team__c = ManagerTeam;
        comm3.Invoice_Item__c =invoiceItemList[0].Id ;
        
        allcommissions.add(comm3);
        
        
        
       Test.startTest();
        commissions_AutoRenewalMonthlyBatch autoCommission = new commissions_AutoRenewalMonthlyBatch();
        try{
            Database.executeBatch(autoCommission);
        }catch(Exception e){
            
        }
        Database.SaveResult[] result = Database.insert(allcommissions, false);
        for(Integer i=0;i<result.size();i++){
            if (result.get(i).isSuccess()) {
                //invoiceItemList[0].Commissions_are_calculated__c = TRUE;
                //update invoiceItemList;
            }
            if (!result.get(i).isSuccess()) {
                // assets.Commission_Error_Message__c = 'The following error has occurrederred';
                //update assets;
            }
        }
        Test.stopTest();
        
    }   
}