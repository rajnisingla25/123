@isTest
public class Z_scheduleSendToZBilling_Test {
  /*  public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    private static Pricebook2 Pbook;

@isTest
static void testZscheduleSendToZBilling() {

//Custom Settings//
    //  //Inserting Customsetting for Account 
    //DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    //    insert Dtrg;
     
    // // Inserting Test Account.
    // List<Account> accountList =new List<Account>();
    //Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    //theTestAccount.Primary_Email__c = 'testEmail1@test.com';
    //theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    //theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
    //accountList.add(theTestAccount);
    //Account theTestAccount2 = TestDataFactory.createAccount('Th2e Test Account', null, false);
    //theTestAccount2.Primary_Email__c = 'testEm2ail1@test.com';
    //theTestAccount2.Type = Constants.OFFICE_ACCOUNT_TYPE;
    //theTestAccount2.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
    //accountList.add(theTestAccount2);
    //insert accountList;
    //List<String> accIdList =new List<String>();
    //accIdList.add('2c92c0f84f2ac59d014f3812491f5a0c');
    //// set up to create a product   
    // // Get price book entries
    // Pricebook2 testPriceBook = new Pricebook2(
    //            Name = 'Standard Price Book'
    //    );
    //    insert testPriceBook;
    //  Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];
    //    List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
    //    List<Product2> product2List = new List<Product2>();
        
    //    Product2 prod = new Product2(
    //        Name = 'H00-062',
    //        Family = 'Professional Development',            
    //        ProductCode='COBROKE',
    //        S_No__c =  1
    //    );
    //    insert prod;
        
    //    Id standardPriceBookId = Test.getStandardPricebookId();
        
    //    PricebookEntry pb1 = new PricebookEntry(
    //        Pricebook2Id = standardPriceBookId, 
    //        Product2Id = prod.Id,
    //        UnitPrice = 1000, 
    //        IsActive = true 
    //    );
    //    pdPbeList.add(pb1);
               
    //    insert pdPbeList;
    
    //// Contract set up//
    //Contract contractVar= new Contract(
    //AccountID= accountList.get(0).ID,
    //Status = 'Draft',
    ////ActivatedDate = Date.Today(),
    //ContractTerm= 1,
    //StartDate =Date.Today()
    ////EndDate = Date.Today()+30
    //);
    //insert contractVar;
    //// Order set up//
    //Order ord= new Order(
    //AccountID = accountList.get(0).ID,
    //EffectiveDate = Date.Today(),
    //Pricebook2Id = standardPriceBookId,
    //ContractID = contractVar.ID,
    //Status  = 'Created'
    //); 
    //insert ord;
    
    
    //OrderItem oi = new OrderItem(OrderId=ord.ID, Quantity= 1, UnitPrice = 1000, PricebookEntryId=pdPbeList[0].ID);
    //try{
    //insert oi; 
    //}catch(exception e){}
    //zqu__Quote__c zqu=new zqu__Quote__c(
    //zqu__Account__c=accountList.get(0).ID,
    //zqu__ZuoraAccountID__c= '2c92c0f84f2ac59d014f3812491f5a0c',
    //zqu__SubscriptionType__c='New Subscription',
    //Charge_To_Be_Updated__c=false,
    //Order_Product__c=oi.ID,
    //zqu__Status__c = 'New'
    
    //);
    //insert zqu;  

    //  Test.startTest();     
    //    String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP, new Z_scheduleSendToZBilling(accIdList));
    //  CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    //  System.assertEquals(CRON_EXP,ct.CronExpression);     
    //  System.assertEquals(0, ct.TimesTriggered);     
    //  System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime)); 
    //  Test.stopTest();
     
        } */
 }