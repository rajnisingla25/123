@isTest(seeAllData = false)
public class ProductConcatHelper_Test {
    public static testMethod void mainTest1() {
        //inserting custom setting data
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
       // Inserting Test Account.    
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmail1@test.com';
        theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;        
        insert theTestAccount;
      //Inserting assets  
      List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < 10; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = theTestAccount.Id,
         Price = 10,
         End_Date__c = Date.today().addDays(index),
         Auto_Renewal__c = 'Yes',
         Status = 'Active'
        ));
    }
        insert theTestAssets;  
          /*Id pricebookId= Test.getStandardPricebookId();
       Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', IsActive = true,S_No__c=12);
            database.insert (prod);
         PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
            database.insert (custompbe); */   
      
       /**Order r =new Order();       
            r.AccountId=theTestAccount.id;
            r.Name='test';
            r.EffectiveDate=System.today();            
            r.Status='Created';
            r.Pricebook2Id = pricebookId;
          
            database.insert (r); 
     OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=custompbe.id,unitPrice=1,Ext_Days__c = 10,Fulfillment_Status__c = 'Active');
     

            database.insert (oi);  ***/
            
       ProductConcatHelper ph = new ProductConcatHelper();
       ProductConcatHelper.concatString(theTestAssets);     
  }
}