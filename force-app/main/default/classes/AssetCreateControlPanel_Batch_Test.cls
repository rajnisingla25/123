@isTest
global class AssetCreateControlPanel_Batch_Test {
    

// Private Data Member.
    private static final Integer COUNTER = 3;
    private static Pricebook2 Pbook;
     @isTest 
     static void testassertFunctionality() {
    //Custom Settings//
     DisabledTrigger__c Dtrg = new DisabledTrigger__c();
     Dtrg.TaskTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AssetTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AccountTrigger__c = 'datamigration@move.com.sit';
     Dtrg.Name = 'Disabled';
     insert Dtrg;
     
     // Inserting Test Account.
     List<Account> accountList =new List<Account>();
    Account theTestAccount = TestDataFactory.createAccount('The Test Account bala', null, false);
    theTestAccount.Primary_Email__c = 'testEmail1@test.com';
    theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
    accountList.add(theTestAccount);

    insert AccountList;
    getPDFFromAssets(AccountList.get(0));
    
   
    }
     private static void getPDFFromAssets(Account theTestAccount) {
         
          // Get price book entries
    /* Pricebook2 testPriceBook = new Pricebook2(
                Name = 'Standard Price Book'
        );
        insert testPriceBook;
      Pbook = [Select p.Id, p.Name from Pricebook2 p where Name='Standard Price Book' limit 1];*/
        List<PricebookEntry> pdPbeList = new List<PricebookEntry>();
        List<Product2> product2List = new List<Product2>();
        
        Product2 prod = new Product2(
            Name = 'H00-062', 
            Family = 'Professional Development',            
            ProductCode='COBROKE',
            S_No__c =  1
        );
        insert prod;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pb1 = new PricebookEntry(
            Pricebook2Id = standardPriceBookId, 
            Product2Id = prod.Id,
            UnitPrice = 1000, 
            IsActive = true 
        );
        pdPbeList.add(pb1);
       
        insert pdPbeList;
         
         
    // Inserting Assets.
        Asset asst1 = new Asset();
            asst1.Name = 'Test Asset1 - ';
            asst1.AccountId = theTestAccount.Id;
            asst1.Price = 10;
            asst1.End_Date__c = Date.today().addDays(3);
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Product_Logins__c='www.login.salesforce.com/';
            asst1.Status = 'Active';
            asst1.BOP_Code__c='';
            asst1.External_ID__c='1-898249952-PR1';                 
            asst1.Product2ID=prod.ID;
            asst1.Line_Type__c = 'Add';                     
            asst1.Asset_Type__c = 'Parent';
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Get_CP_Login_Status__c ='Ready';
        insert asst1;
        
        /*List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
             Name = 'Test Asset test - ' + index,
             AccountId = theTestAccount.Id,
             Price = 10,
             End_Date__c = Date.today().addDays(index),
             Auto_Renewal__c = 'Yes',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active',
             BOP_Code__c='',
             External_ID__c='1-898249952-PR1',                  
             Product2ID=prod.ID,
             Line_Type__c = 'Add',                     
             Asset_Type__c = 'Parent',
             Fulfillment_Status__c = 'Fulfilled',
             Get_CP_Login_Status__c ='Ready'
            ));
        }
        
        Asset asst2 = new Asset();
            asst2.Name = 'Test Asset2 - ';
            asst2.AccountId = theTestAccount.Id;
            asst2.Price = 10;
            asst2.End_Date__c = Date.today().addDays(3);
            asst2.Auto_Renewal__c = 'Yes';
            asst2.Product_Logins__c='www.login.salesforce.com/';
            asst2.Status = 'Active';
            asst2.BOP_Code__c='';
            asst2.Parent_Asset__c = asst1.id;
            asst2.External_ID__c='1-898249952-PR1';                 
            asst2.Product2ID=prod.ID;
            asst2.Line_Type__c = 'Add';                     
            asst2.Asset_Type__c = 'Fulfill To';
            asst2.Fulfillment_Status__c = 'Fulfilled';
            asst2.Get_CP_Login_Status__c ='Ready';
        theTestAssets.add(asst2);  
            insert theTestAssets;*/
    Test.startTest();
    AssetCreateControlPanel_Batch batch = new AssetCreateControlPanel_Batch();
    Database.executeBatch(batch,8);
    Test.stopTest();
    } 


   
   
}