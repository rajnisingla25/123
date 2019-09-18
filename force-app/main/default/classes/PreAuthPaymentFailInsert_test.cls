@IsTest
public class PreAuthPaymentFailInsert_test {
    
    static testMethod void NotifyAE_Test(){
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Collection Team');
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        
        Account acc = TestDataFactory.createAccount('The Test Account', null, false);
        acc.Primary_Email__c = 'theAcc@move.com';
        acc.Type = Constants.OFFICE_ACCOUNT_TYPE;
        insert acc;
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',true);         
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = prod.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie; 
        
        Asset assets 				= new Asset();
        assets.RecordTypeId 		= rectypidasset;
        assets.Name 				= 'test';
        assets.Ownerid				= user1.id;
        assets.Commission_field__c  = 'Ignore';
        insert assets;
        
        List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = 'Paid';
        inv.Zuora__Account__c = Acc.Id;
        insert inv; 
        
        Map<Id,Zuora__Subscription__c> Subscriptions = new Map<Id,Zuora__Subscription__c>();
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'Test';
        sub.Zuora__Account__c = acc.id;        
        sub.Zuora__SubscriptionStartDate__c = system.Today();  
        sub.Zuora__SubscriptionEndDate__c = system.Today().adddays(10);  
        sub.Zuora__NextRenewalDate__c  = system.Today();    
        sub.Asset__c = assets.id; 
        sub.Zuora__Zuora_Id__c  = '2c92c0f95133f635015164f8c4956ab4';    
        insert sub;
        Subscriptions.put(sub.Id,sub);
        
        List<Invoice_Item__c > invoiceitems = new List<Invoice_Item__c >();   
        Invoice_Item__c invitem = new Invoice_Item__c();
        invitem.Name = 'Test';
        invitem.Invoice__c = inv.id;
        invitem.Subscription__c = sub.id;
        invitem.Asset__c = assets.id;
        invoiceitems.add(invitem);
        insert invoiceitems;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
        
        Zuora__Payment__c payment = new Zuora__Payment__c (
            Name						= 'Test Payment',
            Zuora__Status__c 			= 'Error ',
            Zuora__BillingAccount__c 	= cAccount.id,
            Zuora__PaymentMethod__c 	= '123456',
            Zuora__EffectiveDate__c 	= Date.today(),
            Zuora__Account__c			= acc.id,
            Zuora__Amount__c 			= 45000);
        insert Payment;
        
        contact c = new contact();
        c.lastname = 'test';
        c.accountid = acc.id;
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
        w.Account__c= acc.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Active';
        w.Pre_Auth_Email__c='aj@gmail.com';
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Active';
        wt.Market__c='test';
        wt.Waitlist_ID__c=w.Id;
        wt.rank__c = 1;    
        wt.Lead_Routing__c='Fast';
        wt.Product__c=prod.id;
        wt.Account__c= acc.id;
        wt.Market_Type__c='Postal Code';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';
        wt.Wailist_Type__c  = 'Pre-Auth';
        //wt.Quote__c = quote.id;
        insert wt;
        
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName();         
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = acc.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        OpportunityLineItem opl = new  OpportunityLineItem();
        opl.PricebookEntryId = thePricebookEntrie.id;
        opl.Quantity = 1;
        opl.TotalPrice = 1000;
        opl.OpportunityId=op.id;
        insert opl;
        
        BigMachines__Quote__c quote         = new BigMachines__Quote__c();
        quote.BigMachines__Account__c       = acc.Id;        
        quote.BigMachines__Status__c        = 'Approved';
        quote.BigMachines_Quote_Type__c     = 'New';   
        quote.BigMachines__Is_Primary__c    = true;
        quote.BigMachines__Opportunity__c   = op.id;
        quote.Waitlist_Item__c				= wt.id;
        insert quote;
        
        BigMachines__Quote_Product__c bquote = new BigMachines__Quote_Product__c();
        bquote.BigMachines__Quote__c = quote.Id;
        bquote.Line_Type__c = 'Renew';
        bquote.BigMachines__Product__c = thePricebookEntrie.Product2Id;
        bquote.BigMachines__Quantity__c = 1;
        bquote.BigMachines__Sales_Price__c = 10; 
        bquote.Product_Account__c  = acc.id;
        bquote.BigMachines__Description__c = 'Search and Paws';     
        insert bquote;
        
        Order  Orders = new Order();
        Orders.AccountId = acc.id;
        Orders.Fulfillment_Status__c = 'Fulfilled';
        Orders.Status = 'Created';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = thePricebookEntrie.Pricebook2Id;
        Orders.EffectiveDate = system.today();
        Orders.EndDate = system.today().addDays(10);
        orders.Oracle_Quote__c  = quote.id;
        insert Orders;
        
        OrderItem OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        OrderItems.Asset__c = assets.id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.PricebookEntryId = thePricebookEntrie.Id;
        insert OrderItems;
        
        test.startTest();
        Zuora__PaymentInvoice__c Invoicepayment = new Zuora__PaymentInvoice__c (
            Zuora__Payment__c  		= Payment.id,
            Zuora__Invoice__c  		= inv.id,
            Zuora__ApplyAmount__c 	= 45000);
        insert Invoicepayment;
        test.stopTest();
    }
}