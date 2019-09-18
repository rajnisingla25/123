@isTest(seeAllData =false)
public  class AutoRenewalManualRun_Test {

    public static testMethod void mainMethod1() {
        list<Asset> li2 = new list<Asset>();
        
        set<id> accids = new set<id>();
        Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
        list<Account> accListids = new list<Account>();
           
        Profile p = [select id from profile where name='Move Field Sales Rep'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='autorenewaluser@test.com'); 
        insert u;
    
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        AutoRenewal__c ar = new AutoRenewal__c(Name='Move Field Sales Rep', AccountType__c='RD Account',ProductCodes__c='SHOWCASE');
        insert ar;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='ADVANTAGE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 2;
        insert newProduct;
        
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'TestProduct1';
        newProduct1.Auto_Renewal__c = True;
        newProduct1.ProductCode='SELLERLEADS' ;
        newProduct1.Orderable__c= false;
        newProduct1.S_No__c = 2;
        insert newProduct1;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct1';
        newProduct2.Auto_Renewal__c = True;
        newProduct2.ProductCode = 'SHOWCASE' ;
        newProduct2.Orderable__c= true;
        newProduct2.S_No__c = 2;
        insert newProduct2; 
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);       
        
        System.runAs(u) {
        
            //Inserting Test Account       
            
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.OwnerId = u.Id;
            insert testAccount; 
            accListids.add(testAccount);                                    
            
                  
            Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.Last_Order_Activity_Date__c = null;
            insert assets;
            
            Asset asset = new Asset();
            asset.Name = 'test';
            asset.Renewal_Status__c = 'Renew';
            asset.Auto_Renewal__c = 'Yes';
            asset.Asset_Type__c = 'Parent';
            asset.AccountId = testAccount.id;
            asset.Fulfillment_Status__c = 'Fulfilled';
            asset.Status = 'Active';
            asset.Line_Type__c = 'Backout Credit';
            asset.Billing_Period__c = 'Monthly';
            asset.Start_Date__c = system.today();
            asset.End_Date__c = System.today().addMonths(1);
            asset.Product2Id = newProduct1.id;
            asset.Haircut_Asset__c = false;
            asset.Inflight_Quote__c = null;
            assets.Last_Order_Activity_Date__c = null;
            insert asset;
            
            Asset ass = new Asset();
            ass.Name = 'test';
            ass.Renewal_Status__c = 'Renew';
            ass.Auto_Renewal__c = 'Yes';
            ass.Asset_Type__c = 'Parent';
            ass.AccountId = testAccount.id;
            ass.Fulfillment_Status__c = 'Fulfilled';
            ass.Status = 'Active';
            ass.Line_Type__c = 'Backout Credit';
            ass.Billing_Period__c = 'Monthly';
            ass.Start_Date__c = system.today();
            ass.End_Date__c = System.today().addMonths(1);
            ass.Product2Id = newProduct2.id;
            ass.Haircut_Asset__c = false;
            ass.Inflight_Quote__c = null;
            assets.Last_Order_Activity_Date__c = null;
            insert ass;           

        }
                 
        
        Test.startTest();
        //AutoRenewalManualrun ARMR = new  AutoRenewalManualrun();
        AutoRenewalManualrun.autorenewalmethod(testAccount.id);
          
        Test.stopTest();
       
   }
   
   public static testMethod void mainMethod2() {
        list<Asset> li2 = new list<Asset>();
        
        set<id> accids = new set<id>();
        Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
        list<Account> accListids = new list<Account>();
           
        Profile p = [select id from profile where name='Move Field Sales Rep'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='autorenewaluser@test.com'); 
        insert u;
    
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        AutoRenewal__c ar = new AutoRenewal__c(Name='Move Field Sales Rep', AccountType__c='RD Account',ProductCodes__c='SHOWCASE');
        insert ar;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='ADVANTAGE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 2;
        insert newProduct;
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.Account_Sub_Type__c = 'Customer';
        testAccount1.Auto_Renewal__c = true;
        testAccount1.OwnerId = UserInfo.getUserId();
        insert testAccount1;       
               
        
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Renewal_Status__c = 'Renew';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount1.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.Last_Order_Activity_Date__c = null;
            insert asst;
            
             Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renew';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount1.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = system.today();
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Last_Order_Activity_Date__c = null;
            asst1.Total_Net__c  = 0;
            insert asst1;
                   
        Test.startTest();
        //AutoRenewalManualrun ARMR = new  AutoRenewalManualrun();
        AutoRenewalManualrun.autorenewalmethod(testAccount1.id);
          
        Test.stopTest();
       
   }
}