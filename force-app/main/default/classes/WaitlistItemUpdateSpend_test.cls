@IsTest
public class WaitlistItemUpdateSpend_test{
private static final Integer COUNTER = 5;
    Static Testmethod void WaitlistItemUpdateSpendTesting(){
        DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
        
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, True);                 
        
        Schema.DescribeSObjectResult conSchema         = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo   = conSchema.getRecordTypeInfosByName();         
        Id cntctrectypid = ContactRecordTypeInfo.get('Standard').getRecordTypeId();
        Contact cntctdata = new Contact();
            cntctdata.RecordTypeId = cntctrectypid;
            cntctdata.AccountId = newAccount.Id;
            cntctdata.FirstName = 'firstname';
            cntctdata.LastName = 'lastname';
            cntctdata.email = 's@s.com';
        Insert cntctdata;
        
        Product2 theTestProduct = new Product2(
          Name = 'Connection(SM) for Co-Brokerage',
          Family = 'Hardware',
          S_No__c = 2,
          ProductCode = 'FIVESTREET'
        );
        insert theTestProduct;
        
        // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
       
        PricebookEntry thePricebookEntrie = new PricebookEntry();            
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = theTestProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
        
        Schema.DescribeSObjectResult cfrcSchema         = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo   = cfrcSchema.getRecordTypeInfosByName();         
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
        insert setting;         
        List<Case> theTestCases = new List<Case>();
            for(Integer index = 0; index < COUNTER; index++) {
                theTestCases.add(TestDataFactory.createCase(
                    'Open Retention Case of #' + (index + 1),
                    'New',
                    'Retention',
                    'Open Retention Case #' + (index + 1),
                    null,
                    null,
                    false
                ));
            }
        insert theTestCases;
           
        BigMachines__Quote__c quote          = new BigMachines__Quote__c();
        quote.BigMachines__Account__c       = newAccount.Id;        
        quote.BigMachines__Status__c        = 'Pending';
        quote.BigMachines_Quote_Type__c     = 'New';   
        quote.Case__c                       = theTestCases[0].Id;       
        insert quote;
        
        Test.StartTest();
        List<Order> theTestOrders = new List<Order>();
            for(Integer index = 0;index < COUNTER;index++) {
                theTestOrders.add(new Order(
                    EffectiveDate = System.today()+10,
                    Status = 'Created',            
                    AccountId = newAccount.Id,
                    Fulfillment_Status__c ='Fulfilled',
                    Oracle_Quote__c = quote.id,
                    Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
                ));
            }
        insert theTestOrders;
        
        List<OrderItem> theTestOrderItems = new List<OrderItem>();        
            for(Order theTestOrder : theTestOrders) {
                theTestOrderItems.add(new OrderItem(
                    Quantity = decimal.valueof('1'),
                    PricebookEntryId = thePricebookEntrie.id,        
                    OrderId = theTestOrder.Id,
                    Fulfillment_Status__c ='Fulfilled',
                    //Asset__c = asst1.Id, 
                    Credit_Amount__c = 10.00, 
                    Line_Type__c = 'Credit',         
                    UnitPrice = 100.00
                ));
                theTestOrderItems.add(new OrderItem(
                    Quantity = decimal.valueof('1'),
                    PricebookEntryId = thePricebookEntrie.id,        
                    OrderId = theTestOrder.Id,
                    Fulfillment_Status__c ='Fulfilled',
                    //Asset__c = asst1.Id, 
                    Credit_Amount__c = 10.00, 
                    Line_Type__c = 'Credit',         
                    UnitPrice = 100.00
                ));

            }
        insert theTestOrderItems; 
         
        Asset asst1 = new Asset();
            asst1.Name = 'Test Asset - ';
            asst1.AccountId = newAccount.id;
            asst1.Price = 10;
            asst1.End_Date__c = Date.today().addDays(3);
            asst1.Status = 'Active';
            asst1.Product2ID= theTestProduct.Id;
            asst1.Line_Type__c = 'Add';                     
            asst1.Asset_Type__c = 'Parent';
            asst1.Fulfillment_Status__c = 'Fulfilled';           
            asst1.Daily_Rate_on_Asset__c = 3.20;
            asst1.Extended_Net_Price__c = 3.20;
            asst1.Total_Net__c = 50.21;
            asst1.start_date__c = system.today();
            asst1.order_line_Item__c = theTestOrderItems[0].id ;           
         insert asst1;  

        Asset asst2 = new Asset();
            asst2.Name = 'Test Asset - 2';
            asst2.AccountId = newAccount.id;
            asst2.Price = 10;
            asst2.End_Date__c = Date.today().addDays(3);
            asst2.Status = 'Active';
            asst2.Product2ID= theTestProduct.Id;
            asst2.Line_Type__c = 'Add';                     
            asst2.Asset_Type__c = 'Parent';
            asst2.Fulfillment_Status__c = 'Fulfilled';           
            asst2.Daily_Rate_on_Asset__c = 3.20;
            asst2.Total_Net__c = 50.21;
            asst2.start_date__c = system.today();
            asst2.order_line_Item__c = theTestOrderItems[1].id ;           
            asst1.Extended_Net_Price__c = 3.20;
         insert asst2;   
        
        Waitlist__c wldata = new Waitlist__c();
            wldata.Account__c = newAccount.id;
            wldata.Status__c = 'Created';
            wldata.Pre_Auth_Contact__c = cntctdata.Id;
            wldata.Pre_Auth_Email__c = cntctdata.Email;
        Insert wldata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
            wlidata1.Waitlist__c    = wldata.Id;
            wlidata1.Waitlist_ID__c = '1234'; 
            wlidata1.Waitlist_Expiration_Date__c  = system.today();
            wlidata1.Current_Utilized_Spend__c = 0; 
            wlidata1.Original_Max_Spend__c = 100;
            wlidata1.Status__c = 'Pending Pre-Auth';
            wlidata1.Account__c = newAccount.id;
            wlidata1.Product__c = theTestProduct.id;
            wlidata1.Market__c = '30339';
            wlidata1.Market_Type__c = 'City';
            wlidata1.Product_Size__c = 'Full';
            wlidata1.rank__c = 0;
            wlidata1.Quote__c = quote.id;
        insert wlidata1;
        wlidata1.Current_Utilized_Spend__c =  asst1.Extended_Net_Price__c;
        Update  wlidata1;
        map<id,Asset> NewAssetmap = New map<id,Asset>();
        NewAssetmap.put(asst1.id, asst1);
        
        WaitlistItemUpdateSpend wius = New WaitlistItemUpdateSpend();
        WaitlistItemUpdateSpend.updatecurrentutlzdspend(NewAssetmap);
        Test.stopTest();
    }
}