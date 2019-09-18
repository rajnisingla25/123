@isTest
private class accountSummaryHelperTest{
    public static List<Account> accList=new List<Account>();
    public static List<Contact> cList=new List<COntact>();
    public static List<Account_Relationship__c> caList=new List<Account_Relationship__c>();
    public static List<Lead> leadList=new List<Lead>();
    public static List<Inventory_Data__c> invDataList=new List<Inventory_Data__c>();
    public static List<Inventory_Data__c> invDataList1=new List<Inventory_Data__c>();
    public static List<Inventory_Account__c> invAccList=new List<Inventory_Account__c>();
    public static List<Inventory_Account__c> invAccList1=new List<Inventory_Account__c>();
    public static List<Zuora__CustomerAccount__c> zCustoAccList=new List<Zuora__CustomerAccount__c>();
    public static List<Asset> assetList=new List<Asset>();
    public static List<Product2> prodList=new List<Product2>();
    public static List<Waitlist_Item__c> wiList = new List<Waitlist_Item__c>();
    private static final integer max_Limit=40;
    static{
        try{
            DisabledTrigger__c vb=new DisabledTrigger__c(
                name='Disabled',
                AssetTrigger__c='',
                IDTrigger__c=''
                
            );
            insert vb;
        }
        catch(Exception ex){
            
        }
        id batchUser=[select id from User where name='Batchintegration User' limit 1].id;
        insert new Collection_Users__c(Name='batchintegration user',
                                       Id__c=batchUser
                                      );
        for(integer i=0;i<max_Limit;i++){
            accList.add(new Account(
                name='TestPCCACCAcc'+i,
                ShippingStreet = 'Test Street',
                ShippingCity = 'City',
                ShippingState = 'State',
                Phone = '8541752214',
                Type = 'Realtor Agent',
                ShippingPostalCode = '1234'+i,SyncButtonEnableDisable__c=true,BrokerAffiliationChanged__c=true,
                EssentialsStatus__c = 'Activated',
                ResidentialBrandPPL__c = 101+i,
                ResidentialLeadPPL__c = 100+i,
                ResidentialAMLC__c =25+i,
                MLS_Set_Id__c = 'MLS_09876' + 'i',
                Advertiserid__c = 'Test1233321' +'i',
                LandAMLC__c = 5555+i,
                Basic_Optout__c = 'Activate',
                RentalAMLC__c = 666+i,
                ownerid=Userinfo.getUserId(),
                Office_Agent_BLA__c= 'BLA Confirmed'
            )); 
        }
        
        insert accList;
        
        for(integer i=0;i<max_Limit;i++){
            cList.add(new contact(
                FirstName='Test12',
                LastName = 'Test Street',
                accountid=accList[i].id,
                Active__c=true,
                Type__c='Agent',
                Email='test@test.com'
            )); 
        }
        
        insert cList;
        
        for(integer i=0;i<max_Limit;i++){
            caList.add(new Account_Relationship__c(
                Parent_Account__c=accList[i].id,
                Contact_To__c=cList[i].id,
                Active__c = TRUE ,  Contact_Role__c = 'Primary Contact' , Relationship_Type__c = 'Contact'
            )); 
        }
        
        insert caList;
        Lead ld = new Lead(
            lastName = 'Test Street',
            Company = 'Test company',
            Account__c  = accList[0].Id,
            ownerid=Userinfo.getUserId()
        );
        leadList.add(ld);
        insert leadList; 
        for(integer i=0;i<max_Limit;i++){
            prodList.add(new Product2(
                name='TestProCCACCAcc'+i,
                isActive=true,
                productCode='3432xvsf'+i,Inventory__c=false
            )); 
        }
        
        insert prodList;
        
        for(integer i=0;i<max_Limit;i++){
            assetList.add(new Asset(
                Product2Id=prodList[i].id,
                Accountid=accList[Integer.valueOf(i/5)].id,name='tesvbvvvn'+i,
                Asset_Type__c = 'Parent',Fulfillment_Status__c ='Fulfilled'
            )); 
        }
        
        insert assetList;
        
        
        for(integer i=0;i<max_Limit;i++){
            zCustoAccList.add(new Zuora__CustomerAccount__c(
                Zuora__BillCycleDay__c='23',
                Zuora__Account__c=accList[Integer.valueOf(i/5)].id,name='tesvbvvvn'+i
            )); 
        }
        
        insert zCustoAccList;
        
        for(integer i=0;i<max_Limit;i++){
            invDataList.add(new Inventory_Data__c(
                name='1789'+i,
                Median_Market_Price__c=45454.00,
                Inventory_Count__c=2,
                Inventory_Count_Half__c=1,
                City__c='Mexico',
                State__c='US'
            )); 
        }
        
        insert invDataList;
        Update invDataList;
        
        for(integer i=0;i<max_Limit;i++){
            invAccList.add(new Inventory_Account__c(
                Inventory_Data__c=invDataList[i].id,
                City__c='Mexico',
                State__c='US',
                Number_of_Listings__c=2,
                Number_of_Buy_Side_Transactions__c=3,
                Listing__c = TRUE,
                Account__c=accList[Integer.valueOf(i/5)].id
            )); 
        }
        
        insert invAccList;
        
        Waitlist__c w = new Waitlist__c();
        w.status__c = 'Active';
        w.Pre_Auth_Contact__c = cList[0].id;
        w.Pre_Auth_Email__c = 'testemail@gmail.com';
        w.Account__c = accList[0].id;
        insert w;
        prodList.clear(); 
        prodList.add(new Product2(
            name='TestProCCACCAcc1',
            isActive=true,
            productCode='COBROKE',
            Inventory__c=false
        )); 
        prodList.add(new Product2(
            name='TestProCCACCAcc2',
            isActive=true,
            productCode='LOCALEXPERT',
            Inventory__c=false
        )); 
        insert prodList;
        for(integer i=0;i<2;i++){
            wiList.add(new Waitlist_Item__c(
                waitlist__c = w.id,
                Waitlist_ID__c = 'UniqueID'+i,
                Waitlist_Expiration_Date__c = system.today().addDays(90),
                Original_Max_Spend__c  = 10000,
                Account__c=accList[0].id,
                Product__c = prodList[0].id,
                Market__c = '17890',
                Market_Type__c = 'Postal Code',
                Product_Size__c = 'Any',
                Lead_Routing__c = 'Any',
                Status__c = 'Active'
            )); 
            
        }
        for(integer i=0;i<2;i++){
            wiList.add(new Waitlist_Item__c(
                waitlist__c = w.id,
                Waitlist_ID__c = 'UniqueID'+i,
                Waitlist_Expiration_Date__c = system.today().addDays(90),
                Original_Max_Spend__c  = 10000,
                Account__c=accList[0].id,
                Product__c = prodList[1].id,
                Market__c = '17890',
                Market_Type__c = 'Postal Code',
                Product_Size__c = 'Any',
                Lead_Routing__c = 'Any',
                Status__c = 'Active'
            )); 
            
        }
        for(integer i=0;i<2;i++){
            wiList.add(new Waitlist_Item__c(
                waitlist__c = w.id,
                Waitlist_ID__c = 'UniqueID'+i,
                Waitlist_Expiration_Date__c = system.today().addDays(90),
                Original_Max_Spend__c  = 10000,
                Account__c=accList[0].id,
                Product__c = prodList[1].id,
                Market__c = '17891',
                Market_Type__c = 'Postal Code',
                Product_Size__c = 'Any',
                Lead_Routing__c = 'Any',
                Status__c = 'Expired'
            )); 
            
        }
        for(integer i=0;i<2;i++){
            wiList.add(new Waitlist_Item__c(
                waitlist__c = w.id,
                Waitlist_ID__c = 'UniqueID'+i,
                Waitlist_Expiration_Date__c = system.today().addDays(90),
                Original_Max_Spend__c  = 10000,
                Account__c=accList[0].id,
                Product__c = prodList[0].id,
                Market__c = '17891',
                Market_Type__c = 'Postal Code',
                Product_Size__c = 'Any',
                Lead_Routing__c = 'Any',
                Status__c = 'Expired'
            )); 
            
        }
        insert wiList;
    } 
    
    private static testMethod void test() {
        User u=[select id from user where id=:UserInfo.getUserId()];
        string zipcodes = '95134';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        system.runAs(u){
            Account acc=[select id, party_Id__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c,Franchise_Type__c,Basic_Optout__c,Credit_Risk__c,Past_Due__c,Phone,Billing_Preference__c,Email_Address__c,Type,ResidentialBrandPPL__c,ResidentialLeadPPL__c,ResidentialAMLC__c,LandAMLC__c,RentalAMLC__c,MLS_Set_Id__c,Advertiserid__c from Account where id=:accList[0].id limit 1][0];  
            acc.Phone = '12334434';
            update acc;
            Test.setCurrentPageReference(new PageReference('Page.dashboardAccountSummaryNew')); 
            System.currentPageReference().getParameters().put('editurl','test');
            ApexPages.StandardController ctlr = new ApexPages.StandardController(accList[0]);
            accountSummaryHelperCopy ext    = new accountSummaryHelperCopy(ctlr);
            ext.getOwnedProductsNames();
            ext.getConsolidatedBillingDate();
            ext.responseString='';
            ext.loadTheTab();
            ext.doControllerInitialization();
            accountSummaryHelperCopy.getInventoryData(accList[0].Id ,zipcodes);
            accountSummaryHelperCopy.getInventoryDataRemoteAction(accList[0].party_Id__c ,zipcodes);
            ext.waitListMapString='ssssss';
            ext.hexDigest='';
            ext.localTime=System.Now();
            ext.tz=UserInfo.getTimeZone();
            ext.updateAddress();
            ext.transactionId = '';
            
        }
    }
    
    private static testMethod void test1() {
        User u=[select id from user where id=:UserInfo.getUserId()];
        string zipcodes = '95134';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        system.runAs(u){
            Account acc=[select id, party_Id__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c,Franchise_Type__c,Basic_Optout__c,Credit_Risk__c,Past_Due__c,Phone,Billing_Preference__c,Email_Address__c,Type,ResidentialBrandPPL__c,ResidentialLeadPPL__c,ResidentialAMLC__c,LandAMLC__c,RentalAMLC__c,MLS_Set_Id__c,Advertiserid__c from Account where id=:accList[0].id limit 1][0];  
            acc.Phone = '12334434';
            update acc;
            Test.setCurrentPageReference(new PageReference('Page.dashboardAccountSummaryNew')); 
            System.currentPageReference().getParameters().put('editurl','test');
            ApexPages.StandardController ctlr = new ApexPages.StandardController(accList[0]);
            OPCityAccountSummaryHelper  ext    = new OPCityAccountSummaryHelper (ctlr);
            ext.getOwnedProductsNames();
            ext.getConsolidatedBillingDate();
            ext.loadTheTab();
            ext.doControllerInitialization();
            ext.waitListMapString='ssssss';
            ext.hexDigest='';
            ext.localTime=System.Now();
            ext.tz=UserInfo.getTimeZone();
            ext.updateAddress();
            ext.transactionId = '';
        }
    } 
    
    private static testMethod void testLECity() {
        User u=[select id from user where id=:UserInfo.getUserId()];
        string zipcodes = '95134,95191,95101';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        system.runAs(u){
            DisabledTrigger__c vb=new DisabledTrigger__c(name='Disabled',AssetTrigger__c='',IDTrigger__c='');
            insert vb;
            Account acc = createAccount('Realtor Agent');
            Waitlist_Item__c qitem = createWaitlist(acc.Id,'95101');
            
            Inventory_Data__c invData = createInventoryData('CA-San Jose','San Jose','CA');
            Inventory_Account__c InterestedMarket = createInterestedMarket(invData.Id,acc.Id);
            Inventory_Data__c invData1 = createInventoryData('95191','San Jose','CA');
            Inventory_Account__c InterestedMarket1 = createInterestedMarket(invData1.Id,acc.Id);
            Inventory_Data__c invData2 = createInventoryData('95101','San Jose','CA');
            Inventory_Account__c InterestedMarket2 = createInterestedMarket(invData2.Id,acc.Id);
            Inventory_Data__c invData3 = createInventoryData('95109','San Jose','CA');
            Inventory_Data__c invData4 = createInventoryData('95110','San Jose','CA');
            
            Inventory_Data__c invData5 = createInventoryData('CA-Oakland','Oakland','CA');
            Inventory_Data__c invData6 = createInventoryData('94606','Oakland','CA');
            Inventory_Account__c InterestedMarket3 = createInterestedMarket(invData6.Id,acc.Id);
            
            Test.setCurrentPageReference(new PageReference('Page.dashboardAccountSummaryNew')); 
            System.currentPageReference().getParameters().put('editurl','test');
            ApexPages.StandardController ctlr = new ApexPages.StandardController(acc);
            accountSummaryHelperCopy ext    = new accountSummaryHelperCopy(ctlr);
            ext.getOwnedProductsNames();
            ext.getConsolidatedBillingDate();
            ext.responseString='';
            ext.loadTheTab();
            ext.doControllerInitialization();
            accountSummaryHelperCopy.getInventoryData(acc.Id ,zipcodes);
            accountSummaryHelperCopy.getInventoryDataRemoteAction(acc.party_Id__c ,zipcodes);
            ext.waitListMapString='ssssss';
            ext.hexDigest='';
            ext.localTime=System.Now();
            ext.tz=UserInfo.getTimeZone(); 
            ext.updateAddress();
            ext.transactionId = '';
            ext.setQuickQuoteUrl(acc);
            
        }
    }
    
    static Inventory_Data__c createInventoryData(String name,string cityName, String stateName){
        Inventory_Data__c Inv1 = new Inventory_Data__c();
        Inv1.Name = name;
        Inv1.SOV10__c = 10;
        Inv1.SOV10_Price__c = 100;
        Inv1.City__c = cityName;
        Inv1.Inventory_Count_Half__c = 5;
        Inv1.Error__c = true;
        Inv1.State__c = stateName;
        insert Inv1;
        return Inv1;
    }
    
    static Inventory_Account__c createInterestedMarket(String invDataId,String accId){
        Inventory_Account__c InterestedMarket = new Inventory_Account__c();
        InterestedMarket.Inventory_Data__c = invDataId;
        InterestedMarket.Account__c = accId;
        InterestedMarket.SOV20__c = true;
        InterestedMarket.SOV30__c = true;
        InterestedMarket.SOV50__c = true;
        InterestedMarket.SOV20_Price__c = 5.00;
        InterestedMarket.SOV30_Price__c = 50.00;
        InterestedMarket.SOV50_Price__c = 150.00;
        InterestedMarket.Number_of_Listings__c=2;
        InterestedMarket.Number_of_Buy_Side_Transactions__c=3;
        InterestedMarket.Listing__c = TRUE;
        InterestedMarket.has_assets_LEC__c = TRUE;
        InterestedMarket.waitlist_type_LEC__c = 'Hot';
        
        insert InterestedMarket;
        return InterestedMarket;
    }
    
    static Account createAccount(String acctype){
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = acctype;
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Account_Status__c = 'Active';
        newAccount2.Territories__c = 'test';
        
        newAccount2.Zoura_Account_id__c ='Test';
        newAccount2.Office_Agent_BLA__c =null;
        newAccount2.EssentialsStatus__c = 'Activated';     
        newAccount2.Resend_Welcome_Email__c =false;  
        insert newAccount2;
        return newAccount2;
    }
    
    static Waitlist_Item__c createWaitlist(String accId,String marketZip){
        Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
          contact c = new contact();
        c.lastname = 'test';
        c.accountid = accId;
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email ='ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone= '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c='1234567890';
        insert c;   
         
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= accId;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Active'; 
        wt.Market__c=marketZip;
        wt.Waitlist_ID__c='wwwww';
        wt.Lead_Routing__c='Fast';
        wt.Product__c=p.id;
        wt.Account__c= accId;
        wt.Market_Type__c='Postal Code';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';
        wt.Wailist_Type__c = 'Pre-Auth';
        wt.Amendment_Status__c='Pending Pre-Auth Approval';
        
        insert wt;
        return wt;
    }
}